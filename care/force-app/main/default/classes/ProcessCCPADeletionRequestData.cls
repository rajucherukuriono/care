/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.com]
** Modified Date:  02.25.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-2708 CCPA - SFDC Member Deletion Processing requiremet and below are related child records.
** SFORCE-2779 CCPA Deletion: SFDC Case Validation Rules
** SFORCE-2780 CCPA Deletion: Delete child records on the Person Account and afterward the PA
** SFORCE-2781 CCPA Deletion: Schedule SFDC Case Validation Rules
** SFORCE-2781 CCPA Deletion: Schedule SFDC Case Validation Rules
** SFORCE-2783 CCPA Deletion: Update and Delay deletion of Privacy Request records after PA and related child records confirmed to delete
** SFORCE-2822 CCPA Deletion: On/off Switch on SFDC Record Deletion
** SFORCE-2799 CCPA Deletion: Create an Email Notification if the Scheduled for the Case Validation Job Fails
** _______________________________________________________________________________
*/

public class ProcessCCPADeletionRequestData
{
Map<String, String> accRelatedObjMap = new Map<String, String>{
'Survey_Feedback__c1' => 'Account__c', 
'Survey_Feedback__c2' => 'BUC_Account_ID__c',
//'Account_Plan__c' => 'Company_Name__c',
//'Candidate_Profile__c' => 'Provider_Account__c',
//'Event_Members__c' => 'Seeker_Registered__c',
//'Event__c' => 'Business_Account__c',
//'Event__c' => 'Business_Account_w_Benefits__c',
'Feedback__c' => 'Account__c',  
'Flag__c' => 'Flagger__c',
//'Infraction__c' => 'BUC_Center_Name__c',
//'Lead' => 'Business_Account__c',
//'Opportunity' => 'AccountId',
//'Request_Data__c' => 'Account_ID__c',
//'Review__c' => 'BUC_Center_Name__c',
'Survey_Feedback__c3' => 'Contact__c',
//'Vetting__c' => 'BUC_Center_Name__c',
'Case' => 'AccountId',
'LiveChatTranscript'=>'AccountId',
'Note'=>'parentId',
'Event'=>'whatId',
'Task'=>'whatId',
'Attachment'=>'parentId',
'SocialPost' => 'whoId'
};
  
Map<String, String> caseRelatedObjMap = new Map<String, String>{
//'Action_Plan_Needs__c' => 'Case__c',
'Note' => 'parentId',
'Feedback__c' => 'CaseNumber__c',  
'Flag__c' => 'Black_List_Case__c',
'Survey_Feedback__c' => 'Case__c',
'SocialPost' => 'parentId',
'LiveChatTranscript'=>'CaseId',
'EmailMessage'=>'parentId',
'Event'=>'whatId',
'Task'=>'whatId',
'Attachment'=>'parentId',
'CaseComment'=>'parentId',
'CaseFeed'=>'ParentId',
'CaseHistory'=>'caseId'
};
    
Id intlSeekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
Id intlProviderRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
    
       
public  List<Privacy_Request__c>  ProcessCCPADeletionRequestData(List<Privacy_Request__c> prList)
{ 
    System.debug('Inside ProcessCCPADeletionRequestData Class Which Deletes Everything...');
    List<Integer> accList=new List<Integer>();
    List<Privacy_Request__c> prDelList=new List<Privacy_Request__c>();
    List<Id> pcIdList=new List<id>();
    for(Privacy_Request__c prObj:prList)
    {
        //if(prObj.Request_Status__c=='Queued - Salesforce Platform' && prObj.Fulfillment_Date__c==Date.today())
        //if(prObj.Fulfillment_Date__c==Date.today())
        //{
        accList.add(Integer.valueOf(prObj.Universal_Member_Id__c));
        

    //}
    prDelList.add(prObj);
            System.debug('Request Status======================================>:'+prObj.id+'--------'+prObj.Request_Status__c+'Queued - Salesforce Platform   '+prObj.Universal_Member_Id__c);
}
 System.debug('prDelList.size()==========>:'+prDelList.size()+'   !prDelList.isEmpty()=====>:'+!prDelList.isEmpty());
            if(!prDelList.isEmpty())
            {
            System.debug('Calling BatchProcessCCPADeletionRequestPRData batch job with size ========>:'+prDelList.size());
             //Database.delete(prDelList,false);Database.emptyRecycleBin(prDelList);  
            
                String cronID = System.scheduleBatch(new BatchProcessCCPADeletionRequestPRData(false,prDelList), 'BatchProcessCCPADeletionRequestPRData'+system.now(), 1);
               /* 
                CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime
                FROM CronTrigger WHERE Id = :cronID];
                */
                
                
                // TimesTriggered should be 0 because the job hasn't started yet.
                //System.assertEquals(0, ct.TimesTriggered);
                //System.debug('Next fire time: ' + ct.NextFireTime); 
            }
            
                  
   Map<Id,Account> accDelList=new Map<Id,Account>();
   for(Account accObj: [select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,MemberId__pc,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c,CreatedDate from Account where MemberId__pc=:accList])
    {
        accDelList.put(accObj.id,accObj);
        pcIdList.add(accObj.personContactId);
        System.debug('2======================================>:'+accObj.personContactId);
    }
    if(!accList.isEmpty())
    {
        Map<id,Survey_Feedback__c> sfMemberSurveysMap=new Map<id,Survey_Feedback__c>([select id from Survey_Feedback__c where RecordType.Name='Member Surveys' and Survey_Member_ID__c = :convertSetToStrList(accList)]);
            if(!sfMemberSurveysMap.isEmpty()) {Database.delete(sfMemberSurveysMap.values(),false);Database.emptyRecycleBin(sfMemberSurveysMap.values());  }
            }
  
    if(!accDelList.isEmpty())
    {
    


    
    List<id> accContentNoteIdList=new List<id>();
    for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:accDelList.keySet() LIMIT 50000])
    {
        accContentNoteIdList.add(links.ContentDocumentId);
    }

    Map<Id,ContentNote> accNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:accContentNoteIdList LIMIT 50000]);
    Map<Id,ContentDocument> accContentDocumentMap = new Map<id,ContentDocument>([select id from ContentDocument where id=:accContentNoteIdList LIMIT 50000]);
    
    if(!accNoteMap.isEmpty()) {Database.delete(accNoteMap.values(),false);Database.emptyRecycleBin(accNoteMap.values());  }
    if(!accContentDocumentMap.isEmpty()) {Database.delete(accContentDocumentMap.values(),false);Database.emptyRecycleBin(accContentDocumentMap.values());  }

Map<id,SocialPersona> socPerMap=new Map<id,SocialPersona>([select id,parentid from socialPersona where parentid=:pcIdList OR parentId=:accDelList.keySet()]);
if(!socPerMap.isEmpty()) { Database.delete(socPerMap.values(),false);Database.emptyRecycleBin(socPerMap.values());  }

        Map<id,case> delCaseMap=new Map<id,case>([select id from case where accountid=:accDelList.keySet() ALL ROWS]);
        if(!delCaseMap.keySet().isEmpty())  
        {
            List<id> caseContentNoteIdList=new List<id>();
            for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:delCaseMap.keySet() LIMIT 50000])
            {
                caseContentNoteIdList.add(links.ContentDocumentId);
            }

            Map<id,ContentNote> caseNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:caseContentNoteIdList LIMIT 50000]);
            if(!caseNoteMap.isEmpty()) {Database.delete(caseNoteMap.values(),false);Database.emptyRecycleBin(caseNoteMap.values());  }
            
            
            Map<Id,ContentDocument> caseContentDocumentMap = new Map<id,ContentDocument>([select id from ContentDocument where id=:caseContentNoteIdList LIMIT 50000]);
            if(!caseContentDocumentMap.isEmpty()) { Database.delete(caseContentDocumentMap.values(),false);Database.emptyRecycleBin(caseContentDocumentMap.values());  }
            deleteRecsIncludingRecycleBin(caseRelatedObjMap,new List<id>(delCaseMap.keySet()),null,true);
        }
        
        
        
        //List<Account> delAccList=new List<Account>([select id from Account where id=:accDelList.keySet()]);
        system.debug('Deleting account records ====>:'+accDelList.size());
        if(!accDelList.isEmpty())  
        {
        /*
        
        Map<id,Task> accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT FROM Task WHERE whatId=:delAccList ALL ROWS]);
        Map<id,Note> accNotesAndAttachmentsMap=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:delAccList LIMIT 50000]);
        Map<id,Attachment> accAttachmentMap=new Map<id,Attachment>([SELECT ID,PARENTID FROM Attachment WHERE parentId=:delAccList LIMIT 50000]);
        Map<id,AccountHistory> accountHistoryMap=new Map<id,AccountHistory>([SELECT ID,ACCOUNTID FROM AccountHistory WHERE accountId=:delAccList LIMIT 50000]);
        Map<id,accountFeed> accountFeedMap=new Map<id,accountFeed>([SELECT ID,PARENTID FROM accountFeed WHERE parentId=:delAccList LIMIT 50000]);
        Map<id,Flag__c> flagAccountMap=new Map<id,Flag__c>([SELECT ID,Flagger__c from Flag__c where Flagger__c=:pcIdList LIMIT 50000]);
        */
    deleteRecsIncludingRecycleBin(accRelatedObjMap,new List<id>(accDelList.keySet()),pcIdList,false);
        
            Database.DeleteResult[] delAccListResults = Database.delete(accDelList.values(), false);
                    System.debug('3 all accounts delted======================================>:');

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


            Database.emptyRecycleBin(accDelList.values()); 
            
        }
    }
       return prDelList; 
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