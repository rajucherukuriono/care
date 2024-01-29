public class BatchIntlRetentionMemberRequestHelper
 {
        public void processRetentionRequests(List<Account> accList)
        {
            List<String> retReqList=new List<String>{'RT Open Inactive','RT Closed Acct','RT Incomplete','RT Anonymize'};
            Id intlSeekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
            Id intlProviderRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
            List<Process_Control_Settings__mdt>  pcsList= [select id,DeveloperName,MasterLabel,Process_Name__c,Switch__c from Process_Control_Settings__mdt where Process_Name__c='Intl Retention'];
            List<Id> pcIdList=new List<id>();
            String retentionSwitch=pcsList[0].Switch__c;
            if(retentionSwitch == 'On')
            {
            List<Account> accProcessList=new List<Account>();
            List<Account> accDelList=new List<Account>();
            for(Account accObj:accList)
            {
                if(retReqList.contains(accObj.GDPR_Request__c) && accObj.GDPR_Request__c!='RT Anonymize')
                {
                    accProcessList.add(accObj);
                }
                else if(retReqList.contains(accObj.GDPR_Request__c) && accObj.GDPR_Request__c=='RT Anonymize' && (accObj.recordTypeId==intlSeekerRecId  || accObj.recordTypeId==intlProviderRecId))
                {
                    accDelList.add(accObj);
                    pcIdList.add(accObj.personContactId);
                }
            }
            //RT Anonymize
            if(!accProcessList.isEmpty() && AvoidRecursion.runOnce())
            {
            accProcessList=[select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c from Account where id=:accProcessList];
                
                ProcessMemberIntlRetentionInstantRequest.ProcessMemberIntlRetentionInstantRequest(accProcessList);
                update accProcessList;
                NotifyInstantIntlRetentionReqToSterling.notifyInstantRetentionRequestToSterling(accProcessList);
            }
            if(!accDelList.isEmpty())
            {
                List<case> delCaseList=new List<case>([select id from case where accountid=:accDelList ALL ROWS]);
                if(!delCaseList.isEmpty())  
                {
                    Database.delete(delCaseList,false);
                    Database.emptyRecycleBin(delCaseList); 
                }
                
                List<Account> delAccList=new List<Account>([select id from Account where id=:accDelList]);
                system.debug('Deleting account records ====>:'+delAccList.size());
                if(!delAccList.isEmpty())  
                {
                
                
                Map<id,Task> accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT FROM Task WHERE whatId=:delAccList ALL ROWS]);
                Map<id,Note> accNotesAndAttachmentsMap=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:delAccList LIMIT 50000]);
                Map<id,Attachment> accAttachmentMap=new Map<id,Attachment>([SELECT ID,PARENTID FROM Attachment WHERE parentId=:delAccList LIMIT 50000]);
                Map<id,AccountHistory> accountHistoryMap=new Map<id,AccountHistory>([SELECT ID,ACCOUNTID FROM AccountHistory WHERE accountId=:delAccList LIMIT 50000]);
                Map<id,accountFeed> accountFeedMap=new Map<id,accountFeed>([SELECT ID,PARENTID FROM accountFeed WHERE parentId=:delAccList LIMIT 50000]);
                Map<id,Flag__c> flagAccountMap=new Map<id,Flag__c>([SELECT ID,Flagger__c from Flag__c where Flagger__c=:pcIdList LIMIT 50000]);
                
                /*
                if(!accTaskMap.isEmpty())
                    Database.DeleteResult[] delTaskList = Database.delete(accTaskMap.values(), false);
                    if(!accNotesAndAttachmentsMap.isEmpty())
                    Database.DeleteResult[] delNotesAndAttachmentsList = Database.delete(accNotesAndAttachmentsMap.values(), false);
                    if(!accAttachmentMap.isEmpty())
                    Database.DeleteResult[] delAttachmentList = Database.delete(accAttachmentMap.values(), false);
                    if(!accountHistoryMap.isEmpty())
                    Database.DeleteResult[] delAttachmentList = Database.delete(accountHistoryMap.values(), false);
                    if(!accountFeedMap.isEmpty())
                    Database.DeleteResult[] delAttachmentList = Database.delete(accountFeedMap.values(), false);
                    */
                    
                    if(!flagAccountMap.isEmpty())
                    Database.DeleteResult[] delFlagList = Database.delete(flagAccountMap.values(), false);
                
                    Database.DeleteResult[] delAccListResults = Database.delete(delAccList, false);

        // Iterate through each returned result
        for(Database.DeleteResult dr : delAccListResults) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }


                    Database.emptyRecycleBin(delAccList); 
                }
            }
          }
  }
}