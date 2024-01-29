trigger ProcessIntlRetentionRequestTrigger on Account (after Update)
 {
 

 //Map<String, String> accRelatedObjMap = new Map<String, String>{'Survey_Feedback__c1' => 'Account__c','Survey_Feedback__c2' => 'BUC_Account_ID__c','Account_Plan__c' => 'Company_Name__c', 'Candidate_Profile__c' => 'Provider_Account__c', 'Event_Members__c' => 'Seeker_Registered__c', 'Event__c' => 'Business_Account__c', 'Event__c' => 'Business_Account_w_Benefits__c', 'Feedback__c' => 'Account__c', 'Flag__c' => 'Flagger__c', 'Infraction__c' => 'BUC_Center_Name__c', 'Lead' => 'Business_Account__c',  'Opportunity' => 'AccountId', 'Promo_Code__c' => 'Account__c', 'Request_Data__c' => 'Account_ID__c', 'Review__c' => 'BUC_Center_Name__c',  'Survey_Feedback__c3' => 'Contact__c', 'Vetting__c' => 'BUC_Center_Name__c','Case' => 'AccountId'};

  Map<String, String> accRelatedObjMap = new Map<String, String>{ 'GetFeedback_Aut__Answer__c'=> 'GetFeedback_Aut__Contact__c', 'Survey_Feedback__c1' => 'Account__c','Survey_Feedback__c2' => 'BUC_Account_ID__c','Account_Plan__c' => 'Company_Name__c', 'Candidate_Profile__c' => 'Provider_Account__c', 'Event_Members__c' => 'Seeker_Registered__c', 'Event__c' => 'Business_Account__c', 'Event__c' => 'Business_Account_w_Benefits__c', 'Feedback__c' => 'Account__c', 'Flag__c' => 'Flagger__c', 'Infraction__c' => 'BUC_Center_Name__c', 'Lead' => 'Business_Account__c',  'Opportunity' => 'AccountId', 'Request_Data__c' => 'Account_ID__c', 'Review__c' => 'BUC_Center_Name__c',  'Survey_Feedback__c3' => 'Contact__c', 'Vetting__c' => 'BUC_Center_Name__c','Case' => 'AccountId'};
  
 Map<String, String> caseRelatedObjMap = new Map<String, String>{'Action_Plan_Needs__c' => 'Case__c','Feedback__c' => 'CaseNumber__c', 'Flag__c' => 'Black_List_Case__c', 'Survey_Feedback__c' => 'Case__c'};
 
 
 
    List<String> retReqList=new List<String>{'RT Open Inactive','RT Closed Acct','RT Incomplete','RT Anonymize'};
    Id intlSeekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
    Id intlProviderRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
    List<Process_Control_Settings__mdt>  pcsList= [select id,DeveloperName,MasterLabel,Process_Name__c,Switch__c from Process_Control_Settings__mdt where Process_Name__c='Intl Retention'];
    List<Id> pcIdList=new List<id>();
    String retentionSwitch=pcsList[0].Switch__c;
    List<Account> sendOffNotificationList=new List<Account>();

    List<Account> accProcessList=new List<Account>();
    List<id> accDelList=new List<id>();
    for(Account accObj:Trigger.new)
    {
        if(retReqList.contains(accObj.GDPR_Request__c) && accObj.GDPR_Request__c!='RT Anonymize')
        {
            accProcessList.add(accObj);
            sendOffNotificationList.add(accObj);
        }
        else if(retReqList.contains(accObj.GDPR_Request__c) && accObj.GDPR_Request__c=='RT Anonymize' && (accObj.recordTypeId==intlSeekerRecId  || accObj.recordTypeId==intlProviderRecId))
        {
            accDelList.add(accObj.id);
            sendOffNotificationList.add(accObj);
            pcIdList.add(accObj.personContactId);
        }
    }
    if(retentionSwitch == 'On')
    {
    //RT Anonymize
    if(!accProcessList.isEmpty() && AvoidRecursion.runOnceRetention1())
    {
    accProcessList=[select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c,CreatedDate from Account where id=:accProcessList FOR UPDATE];
        
        ProcessMemberIntlRetentionInstantRequest.ProcessMemberIntlRetentionInstantRequest(accProcessList);
        update accProcessList;
        NotifyInstantIntlRetentionReqToSterling.notifyInstantRetentionRequestToSterling(accProcessList);
    }
    if(!accDelList.isEmpty())
    {
    

    List<id> accContentNoteIdList=new List<id>();
    for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:accDelList LIMIT 50000])
    {
        accContentNoteIdList.add(links.ContentDocumentId);
    }

    Map<Id,ContentNote> accNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:accContentNoteIdList LIMIT 50000]);
    Map<Id,ContentDocument> accContentDocumentMap = new Map<id,ContentDocument>([select id from ContentDocument where id=:accContentNoteIdList LIMIT 50000]);
    
    if(!accNoteMap.isEmpty()) {Database.delete(accNoteMap.values(),false);Database.emptyRecycleBin(accNoteMap.values());  }
    if(!accContentDocumentMap.isEmpty()) {Database.delete(accContentDocumentMap.values(),false);Database.emptyRecycleBin(accContentDocumentMap.values());  }
    
    Map<id,Note>  accNotesAndAttachments=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:accDelList LIMIT 50000]);
    if(!accNotesAndAttachments.isEmpty()) {Database.delete(accNotesAndAttachments.values(),false);Database.emptyRecycleBin(accNotesAndAttachments.values());  }


        Map<id,case> delCaseMap=new Map<id,case>([select id from case where accountid=:accDelList ALL ROWS]);
        if(!delCaseMap.keySet().isEmpty())  
        {

            deleteRecsIncludingRecycleBin(caseRelatedObjMap,new List<id>(delCaseMap.keySet()),null,true);
 
            List<id> caseContentNoteIdList=new List<id>();
            for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:delCaseMap.keySet() LIMIT 50000])
            {
                caseContentNoteIdList.add(links.ContentDocumentId);
            }

            Map<id,ContentNote> caseNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:caseContentNoteIdList LIMIT 50000]);
            if(!caseNoteMap.isEmpty()) {Database.delete(caseNoteMap.values(),false);Database.emptyRecycleBin(caseNoteMap.values());  }
            
            Map<id,Note>  caseNotesAndAttachmentsMap=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:delCaseMap.keySet() LIMIT 50000]);
            if(!caseNotesAndAttachmentsMap.isEmpty()) { Database.delete(caseNotesAndAttachmentsMap.values(),false);Database.emptyRecycleBin(caseNotesAndAttachmentsMap.values());  }
            
            Map<Id,ContentDocument> caseContentDocumentMap = new Map<id,ContentDocument>([select id from ContentDocument where id=:caseContentNoteIdList LIMIT 50000]);
            if(!caseContentDocumentMap.isEmpty()) { Database.delete(caseContentDocumentMap.values(),false);Database.emptyRecycleBin(caseContentDocumentMap.values());  }
                        
                        
            Database.delete(delCaseMap.values(),false);
            Database.emptyRecycleBin(delCaseMap.values());
        }
        
        
        
        List<Account> delAccList=new List<Account>([select id from Account where id=:accDelList]);
        system.debug('Deleting account records ====>:'+delAccList.size());
        if(!delAccList.isEmpty())  
        {
        /*
        
        Map<id,Task> accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT FROM Task WHERE whatId=:delAccList ALL ROWS]);
        Map<id,Note> accNotesAndAttachmentsMap=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:delAccList LIMIT 50000]);
        Map<id,Attachment> accAttachmentMap=new Map<id,Attachment>([SELECT ID,PARENTID FROM Attachment WHERE parentId=:delAccList LIMIT 50000]);
        Map<id,AccountHistory> accountHistoryMap=new Map<id,AccountHistory>([SELECT ID,ACCOUNTID FROM AccountHistory WHERE accountId=:delAccList LIMIT 50000]);
        Map<id,accountFeed> accountFeedMap=new Map<id,accountFeed>([SELECT ID,PARENTID FROM accountFeed WHERE parentId=:delAccList LIMIT 50000]);
        Map<id,Flag__c> flagAccountMap=new Map<id,Flag__c>([SELECT ID,Flagger__c from Flag__c where Flagger__c=:pcIdList LIMIT 50000]);
        */
    deleteRecsIncludingRecycleBin(accRelatedObjMap,accDelList,pcIdList,false);
        
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
  else if(retentionSwitch == 'Off' && !sendOffNotificationList.isEmpty() && AvoidRecursion.runOnceRetention1())
  {
      sendOffNotificationList=[select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c,CreatedDate from Account where id=:sendOffNotificationList FOR UPDATE];
      
      for(Account accObj:sendOffNotificationList){
      accObj.Gdpr_Request__c='RT Process Off';
      }
      update sendOffNotificationList;
        NotifyInstantIntlRetentionReqToSterling.notifyInstantRetentionRequestToSterling(sendOffNotificationList);
  }
  
   public void deleteRecsIncludingRecycleBin(Map<String,String> delObjMap,List<id> accList,List<Id> pcIdList,boolean directDelete)
{
    System.debug('Inside deleteRecsIncludingRecycleBin==>:'+delObjMap+'   accList==>:'+accList+'     pcIdList==>:'+pcIdList);
    if(!directDelete)
    {
        integer surveyFbkCounter=0;
        if(delObjMap!=null && accList!=null && !accList.isEmpty())
        {
            for(String objName:delObjMap.keySet())
            {
                if(objName=='Flag__c')
                {
                    String query='SELECT ID from '+objName+' where '+delObjMap.get(objName)+' in '+commaSeperatedString(pcIdList)+' LIMIT 50000';
                    System.debug('Executing the query ==========>:'+query);
                    List<Sobject> sObjectList=Database.query(query);
                    if(sObjectList!=null && !sObjectList.isEmpty())
                    {
                                Database.DeleteResult[] delList = Database.delete(sObjectList, false);
                                Database.emptyRecycleBin(sObjectList); 
                    }
    
                }
                else if(objName.contains('GetFeedback_Aut__Answer__c'))
                {
                    String query='SELECT ID from '+objName+' where '+delObjMap.get(objName)+' in '+commaSeperatedString(pcIdList)+' LIMIT 50000';
                    List<Sobject> sObjectList=Database.query(query);
                    if(sObjectList!=null && !sObjectList.isEmpty())
                    {
                        Database.DeleteResult[] delList = Database.delete(sObjectList, false);
                        Database.emptyRecycleBin(sObjectList); 
                    }
                }                
                else if(objName.contains('Survey_Feedback__c'))
                {
                    if(surveyFbkCounter==0)
                    {
                        String query1='SELECT ID from '+'Survey_Feedback__c'+' where Account__c in '+commaSeperatedString(accList)+' LIMIT 50000';
                        System.debug('Executing the query ==========>:'+query1);
                        List<Sobject> sObjectList1=Database.query(query1);
                        if(sObjectList1!=null && !sObjectList1.isEmpty())
                        {
                                    Database.DeleteResult[] delList = Database.delete(sObjectList1, false);
                                    Database.emptyRecycleBin(sObjectList1); 
                        }
                        ++surveyFbkCounter;
                    }
                    if(surveyFbkCounter==1)
                    {
                        String query2='SELECT ID from '+'Survey_Feedback__c'+' where Contact__c in '+commaSeperatedString(pcIdList)+' LIMIT 50000';
                        System.debug('Executing the query ==========>:'+query2);
                        List<Sobject> sObjectList2=Database.query(query2);
                        if(sObjectList2!=null && !sObjectList2.isEmpty())
                        {
                                    Database.DeleteResult[] delFlagList = Database.delete(sObjectList2, false);
                                    Database.emptyRecycleBin(sObjectList2); 
                        }
                        ++surveyFbkCounter;
                    }
                    if(surveyFbkCounter==2)
                    {
                        String query2='SELECT ID from '+'Survey_Feedback__c'+' where BUC_Account_ID__c in '+commaSeperatedString(accList)+' LIMIT 50000';
                        System.debug('Executing the query ==========>:'+query2);
                        List<Sobject> sObjectList2=Database.query(query2);
                        if(sObjectList2!=null && !sObjectList2.isEmpty())
                        {
                                    Database.DeleteResult[] delFlagList = Database.delete(sObjectList2, false);
                                    Database.emptyRecycleBin(sObjectList2); 
                        }
                        ++surveyFbkCounter;
                    }
                    
                }
                
                else
                {
                    String query='SELECT ID from '+objName+' where '+delObjMap.get(objName)+' in '+commaSeperatedString(accList)+' LIMIT 50000';
                    System.debug('Executing the query ==========>:'+query);
                    List<Sobject> sObjectList=Database.query(query);
                    if(sObjectList!=null && !sObjectList.isEmpty())
                    {
                                Database.DeleteResult[] delFlagList = Database.delete(sObjectList, false);
                                Database.emptyRecycleBin(sObjectList); 
                    }
                }
                }
            }
        }
        if(directDelete)
        {
            if(delObjMap!=null && accList!=null && !accList.isEmpty())
            {
                    for(String objName:delObjMap.keySet())
                    {
                            String query='SELECT ID from '+objName+' where '+delObjMap.get(objName)+' in '+commaSeperatedString(accList)+' LIMIT 50000';
                            System.debug('Executing the query ==========>:'+query);
                            List<Sobject> sObjectList=Database.query(query);
                            if(sObjectList!=null && !sObjectList.isEmpty())
                            {
                                        Database.DeleteResult[] delFlagList = Database.delete(sObjectList, false);
                                        Database.emptyRecycleBin(sObjectList); 
                            }
                    }
             }
         }
}

public String commaSeperatedString(List<String> strList){
String csStr='';
if(strList!=null){
for(integer i=0;i<strList.size();i++)
{
    if(i==strList.size()-1)
    {
        csStr+='\''+strList[i]+'\'';
    }
    else
    {
        csStr+='\''+strList[i]+'\',';
    }
}
}
if(csStr!='') csStr='('+csStr+')';
return csStr;
}

 public List<String> convertSetToStrList(List<Integer> memIdList){
 List<String> memList=new List<String>();
 for(Integer memId:memIdList)
 {
    memList.add(String.valueOf(memId));
 }
 return memList;
 }
 

}