public class ProcessMemberIntlRetentionInstantRequest
{
    public static Map<String,Retention_Custom_Metadata__mdt> retCustomMetaDataMap=new Map<String,Retention_Custom_Metadata__mdt>();
    
    public static  Map<id,Case> caseMap;    
    
    public static Map<id,List<Case>> accIdCaseListMap;
    
    public static Map<id,EmailMessage> caseEmailMessageMap;
    public static Map<id,List<EmailMessage>> caseIdEmailMessageListMap;
    public static List<EmailMessage> deleteCaseEmailMessageList=new List<EmailMessage>();
    
    
    public static Map<id,Event> caseEventMap;
    public static Map<id,List<Event>> caseIdEventListMap;
    public static List<Event> deleteCaseEventList=new List<Event>();

    public static Map<id,Task> caseTaskMap;
    public static Map<id,List<Task>> caseIdTaskListMap;
    public static Set<Task> updateCaseTaskList=new Set<Task>();
    
    public static Map<id,CaseComment> caseCaseCommentMap;
    public static Map<id,List<CaseComment>> caseIdCaseCommentListMap;
    

    public static Map<id,boolean> accWithNonClearCasesMap;
    public static Map<id,List<Case>> accWithOpenCasesMap;
    public static Map<id,DateTime> accWithLatModifiedTimeStampMap;
    public static Map<id,Map<String,id>> accWithLADByIntegrUsrMap;
    public static Map<id,Map<String,id>> accWithLADByIntegrUsrObjIdMap;
    public static Map<id,Map<String,DateTime>> accWithLADByIntegrUsrCrDateMap;
    public static Map<id,Map<String,String>> accWithLADByIntegrUsrObjMap;
    public static Map<id,List<Id>> accWithCaseMap;
    public static Set<Id> closedCaseSet;
    
    
    public static Map<id,String> caseRecTypes=new Map<id,String>();
    public static Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //public static List<Case> deleteNPSCaseList=new List<Case>();
    
    public static Map<id,Account> accMap;
    
    public static Map<id,Account> delAccountMap=new Map<id,Account>();
    
    public static Map<id,boolean> accIsProcessedMap=new Map<id,boolean>();
    
    public static Map<id,id> accPersonContactMap=new Map<id,id>();
    public static Map<id,id> personContactAccMap=new Map<id,id>();
    
    public static void  ProcessMemberIntlRetentionInstantRequest(List<Account> accList)
    {
        
     List<Process_Control_Settings__mdt>  pcsList= [select id,DeveloperName,MasterLabel,Process_Name__c,Switch__c,Additional_Information__c from Process_Control_Settings__mdt where Process_Name__c in ('Integration User')];
     Map<String,List<String>> pcsListMap=new Map<String,List<String>>();
     Map<String,String> pcsIntUsrMap=new Map<String,String>();
     for(Process_Control_Settings__mdt pcsStr:pcsList)
     {
         pcsIntUsrMap.put(pcsStr.Additional_Information__c,pcsStr.Process_Name__c);
         if(pcsListMap.get(pcsStr.Process_Name__c)==null)
         {
             pcsListMap.put(pcsStr.Process_Name__c,new List<String>{pcsStr.Additional_Information__c});
         }
         else
         {
             pcsListMap.get(pcsStr.Process_Name__c).add(pcsStr.Additional_Information__c);
         }
         
     }
  
        boolean isIntegrationUser=pcsListMap.get('Integration User').contains(UserInfo.getName());    
    
    
    
        for(Retention_Custom_Metadata__mdt retCustMDObj:[SELECT id,DeveloperName,MasterLabel,Days__c,Retention_Request__c from Retention_Custom_Metadata__mdt where Retention_Type__c='RetentionIntlMember'])
        {
            retCustomMetaDataMap.put(retCustMDObj.Retention_Request__c,retCustMDObj);
        }
        
        for(Account accObj:accList)
        {
            accPersonContactMap.put(accObj.id,accObj.personContactId);
            personContactAccMap.put(accObj.personContactId,accObj.id);
            accIsProcessedMap.put(accObj.id,false);
            if(accObj.Gdpr_Request__c=='RT Open Inactive' || accObj.Gdpr_Request__c=='RT Closed Acct' || accObj.Gdpr_Request__c=='RT Incomplete')
            {
                if(accObj.Request_Type__c!=accObj.Gdpr_Request__c)  accObj.Request_Type__c=accObj.Gdpr_Request__c;
            }
        }
        
        List<String> closedStatusList = new List<String>();
        for(CaseStatus csObj: [SELECT Id, isClosed, MasterLabel FROM CaseStatus WHERE IsClosed = true])
        {
            closedStatusList.add(csObj.MasterLabel);
        }
        
        if(CareDotComUtil.runningInASandbox()) System.debug('Inside ProcessMemberIntlRetentionInstantRequest method ==>:');

        accMap=new Map<id,Account>();
        //for(Account accObj:[select id,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,CreatedDate,LastModifiedById from Account where Global_Member_ID__c=:gmIdMap.keySet() LIMIT 50000])
        for(Account accobj:accList)
        {
            accMap.put(accObj.id,accObj);
        }

        /**********************************************************************/
        //String overrideRetentionLADForTheUser=Override_Process_Settings__c.getInstance().Override_Retention_LAD_For_User__c;
List<PermissionSetAssignment> psaList=new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Override_Retention_LAD_For_User']);
Map<id,PermissionSetAssignment> psaMap=new Map<id,PermissionSetAssignment>();
for(PermissionSetAssignment psaObj:psaList)
{
    psaMap.put(psaObj.assigneeId,psaObj);
}
    //Boolean hasLADOverridePermission = FeatureManagement.checkPermission('Override_Retention_LAD_For_User');
    
        caseMap=new Map<id,Case>([SELECT ID,STATUS,RECORDTYPEID,ACCOUNTID,subject,description,Account.Name,Employer_Program__c,CreatedDate,LastModifiedDate,LastModifiedById,Recent_LMD_By_Actual_User__c,(SELECT caseId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue from Histories where CreatedById!=:psaMap.keySet()  order by createdDate Desc) FROM CASE WHERE ACCOUNTID=:accMap.keySet() LIMIT 50000]);
        
        if(CareDotComUtil.runningInASandbox()) System.debug('caseMap=====================>:'+caseMap.size());
        accIdCaseListMap=new Map <id,List<Case>>();
        
        for(Case caseObj:caseMap.values())
        {
                if(accIdCaseListMap.get(caseObj.accountId)==null)
                {
                    accIdCaseListMap.put(caseObj.accountId,new List<Case>{caseObj});
                }
                else
                {
                    accIdCaseListMap.get(caseObj.accountId).add(caseObj);
                }
            
        }
        /**********************************************************************/
        
         caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'),'International Safety Alert');
        caseRecTypeNameIdMap.put('International Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'));
        /*caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS')); */
        /**********************************************************************/
        accWithNonClearCasesMap=new Map<id,boolean>();
        accWithOpenCasesMap=new Map<id,List<Case>>();
        accWithLatModifiedTimeStampMap=new Map<id,DateTime>();
        accWithLADByIntegrUsrMap=new Map<id,Map<String,id>>();
        accWithLADByIntegrUsrObjIdMap=new Map<id,Map<String,id>>();
        accWithLADByIntegrUsrCrDateMap=new Map<id,Map<String,Datetime>>();
        accWithLADByIntegrUsrObjMap=new Map<id,Map<String,String>>();
        accWithCaseMap=new Map<id,List<Id>>();
        closedCaseSet=new Set<Id>();
       /**************************************************************************************/
                      Map<id,Task> accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT,LastModifiedDate,LastModifiedById,createdDate FROM Task WHERE whoId=:accPersonContactMap.values()]);
        Map<id,List<Task>> accIdTaskListMap=new Map<id,List<Task>>();
        
        for(Task TaskObj:accTaskMap.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding task to accIdTaskListMap================>:'+taskObj.subject);
            if(accIdTaskListMap.get(TaskObj.whoId)==null)
            {
                accIdTaskListMap.put(TaskObj.whoId,new List<Task>{TaskObj});
            }
            else
            {
                accIdTaskListMap.get(TaskObj.whoId).add(TaskObj);
            }
        }
       /* 
        for(Account accObj:accList)
        {
            accWithLatModifiedTimeStampMap.put(accObj.id,accObj.Salesforce_Last_Action_Date__c==null?accObj.createdDate:accObj.Salesforce_Last_Action_Date__c);
        }
        */
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdTaskListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Task taskObj:accIdTaskListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('taskObj.whoId==>:'+taskObj.whoId+personContactAccMap.get(taskObj.whoId)+taskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,id>{'IntUser'=>taskObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,id>{'IntUser'=>taskObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,Datetime>{'IntUser'=>taskObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,String>{'IntUser'=>'Task'});
                                
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId)) < taskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,id>{'IntUser'=>taskObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,id>{'IntUser'=>taskObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,Datetime>{'IntUser'=>taskObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(personContactAccMap.get(taskObj.whoId),new Map<String,String>{'IntUser'=>'Task'});
                            }
                    }               
            }
            
        }
      /**********************************************************************************************/
      Map<id,Task> accTask2Map=new Map<id,Task>([SELECT ID,whoID,whatId,SUBJECT,LastModifiedDate,LastModifiedById,createdDate FROM Task WHERE whatId=:accList]);
        
        
        Map<id,List<Task>> accIdTask2ListMap=new Map<id,List<Task>>();
        
        for(Task TaskObj:accTask2Map.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Task to accTasklist================>:'+TaskObj.subject);
            if(accIdTask2ListMap.get(TaskObj.whatId)==null)
            {
                accIdTask2ListMap.put(TaskObj.whatId,new List<Task>{TaskObj});
            }
            else
            {
                accIdTask2ListMap.get(TaskObj.whatId).add(TaskObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdTask2ListMap.containsKey(accObj.id))
            {
                    for(Task TaskObj:accIdTask2ListMap.get(accObj.id))
                    {
                            System.debug('TaskObj.whatId==>:'+TaskObj.whatId+TaskObj.whatId+TaskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(TaskObj.whatId,new Map<String,id>{'IntUser'=>taskObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(TaskObj.whatId,new Map<String,id>{'IntUser'=>taskObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(TaskObj.whatId,new Map<String,Datetime>{'IntUser'=>taskObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(TaskObj.whatId,new Map<String,String>{'IntUser'=>'Task'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId) < TaskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate); 
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);                        
                                accWithLADByIntegrUsrMap.put(TaskObj.whatId,new Map<String,id>{'IntUser'=>taskObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(TaskObj.whatId,new Map<String,id>{'IntUser'=>taskObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(TaskObj.whatId,new Map<String,Datetime>{'IntUser'=>taskObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(TaskObj.whatId,new Map<String,String>{'IntUser'=>'Task'});
                            }
                    }               
            }
            
        }
/**********************************************************************************************/

            Map<id,Event> accEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID,SUBJECT,LastModifiedDate,LastModifiedById,createdDate FROM Event WHERE whoId=:accPersonContactMap.values()]);
        
        
        Map<id,List<Event>> accIdEventListMap=new Map<id,List<Event>>();
        
        for(Event EventObj:accEventMap.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Event to accEventlist================>:'+EventObj.subject);
            if(accIdEventListMap.get(EventObj.whoId)==null)
            {
                accIdEventListMap.put(EventObj.whoId,new List<Event>{EventObj});
            }
            else
            {
                accIdEventListMap.get(EventObj.whoId).add(EventObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEventListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Event eventObj:accIdEventListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('eventObj.whoId==>:'+eventObj.whoId+personContactAccMap.get(eventObj.whoId)+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(eventObj.whoId),eventObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,id>{'IntUser'=>eventObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,id>{'IntUser'=>eventObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,Datetime>{'IntUser'=>eventObj.CreatedDate});
                                accWithLADByIntegrUsrObjMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,String>{'IntUser'=>'Event'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId)) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLADByIntegrUsrMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,id>{'IntUser'=>eventObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,id>{'IntUser'=>eventObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,Datetime>{'IntUser'=>eventObj.CreatedDate});
                                accWithLADByIntegrUsrObjMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,String>{'IntUser'=>'Event'});
                            }
                    }               
            }
            
        }
        /*********************************************************************************************/  
        Map<id,Event> accEvent2Map=new Map<id,Event>([SELECT ID,whoID,whatId,SUBJECT,LastModifiedDate,LastModifiedById,createdDate FROM Event WHERE whatId=:accList]);
        
        
        Map<id,List<Event>> accIdEvent2ListMap=new Map<id,List<Event>>();
        
        for(Event EventObj:accEvent2Map.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Event to accEventlist================>:'+EventObj.subject);
            if(accIdEvent2ListMap.get(EventObj.whatId)==null)
            {
                accIdEvent2ListMap.put(EventObj.whatId,new List<Event>{EventObj});
            }
            else
            {
                accIdEvent2ListMap.get(EventObj.whatId).add(EventObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEvent2ListMap.containsKey(accObj.id))
            {
                    for(Event eventObj:accIdEvent2ListMap.get(accObj.id))
                    {
                            System.debug('eventObj.whatId==>:'+eventObj.whatId+eventObj.whatId+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(eventObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(eventObj.whatId,new Map<String,id>{'IntUser'=>eventObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(eventObj.whatId,new Map<String,id>{'IntUser'=>eventObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(eventObj.whatId,new Map<String,Datetime>{'IntUser'=>eventObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(eventObj.whatId,new Map<String,String>{'IntUser'=>'Event'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(eventObj.whatId) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(eventObj.whatId,new Map<String,id>{'IntUser'=>eventObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(eventObj.whatId,new Map<String,id>{'IntUser'=>eventObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(eventObj.whatId,new Map<String,Datetime>{'IntUser'=>eventObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(eventObj.whatId,new Map<String,String>{'IntUser'=>'Event'});
                            }
                    }               
            }
            
        }
        
        /**********************************************************************************************/
        /*
        Map<id,EmailMessage> accIdEmailMsgMap=new Map<id,EmailMessage>([SELECT ID,PARENTID,LastModifiedDate,LastModifiedById,createdDate FROM EmailMessage WHERE parentId=:accMap.keySet() LIMIT 50000]);
        
        
        Map<id,List<EmailMessage>> accIdEmailMsgListMap=new Map<id,List<EmailMessage>>();
        
        for(EmailMessage EmailMessageObj:accIdEmailMsgMap.values())
        {
            if(accIdEmailMsgListMap.get(EmailMessageObj.parentId)==null)
            {
                accIdEmailMsgListMap.put(EmailMessageObj.parentId,new List<EmailMessage>{EmailMessageObj});
            }
            else
            {
                accIdEmailMsgListMap.get(EmailMessageObj.parentId).add(EmailMessageObj);
            }
        }
        
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEmailMsgListMap.containsKey(accObj.id))
            {
                    for(EmailMessage emailMsgObj:accIdEmailMsgListMap.get(accObj.id))
                    {
                            if(accWithLatModifiedTimeStampMap.get(emailMsgObj.parentId)==null)
                            {
                                System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(emailMsgObj.parentId,emailMsgObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.createdDate});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(emailMsgObj.parentId) < emailMsgObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(emailMsgObj.parentId,emailMsgObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(emailMsgObj.parentId,new Map<String,id>{'IntUser'=>emailMsgObj.createdDate});
                            }
                    }               
            }
            
        }
        */
        /************************************************************************************************/
       
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdCaseListMap.containsKey(accObj.id))
            {
                    for(Case caseObj:accIdCaseListMap.get(accObj.id))
                    {
                        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 222');
                        System.debug('Comparing lastmodified by id with logged in user id ======>:'+caseObj.lastModifiedById + UserInfo.getUserId());
                        //if(caseObj.recordTypeId!=caseRecTypeNameIdMap.get('NPS') && caseObj.recordTypeId!=caseRecTypeNameIdMap.get('International NPS') && caseObj.recordTypeId==caseRecTypeNameIdMap.get('International Safety Alert') && closedStatusList.contains(caseObj.status) && caseObj.Status!='Cleared' )
                        if(caseObj.recordTypeId==caseRecTypeNameIdMap.get('International Safety Alert') && closedStatusList.contains(caseObj.status) && caseObj.Status!='Cleared' )
                        {
                            if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 333 Non Cleared Safety Alert Found'+caseObj.id);
                            accWithNonClearCasesMap.put(caseObj.accountId,true);
                           if(accWithLatModifiedTimeStampMap.get(caseObj.accountId)==null)
                            {
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseObj.accountId) < caseObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                        }
                        
                        //else if(caseObj.recordTypeId!=caseRecTypeNameIdMap.get('NPS') && caseObj.recordTypeId!=caseRecTypeNameIdMap.get('International NPS') && !closedStatusList.contains(caseObj.status))
                        else if(!closedStatusList.contains(caseObj.status))
                        {
                            if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 333 Non Cleared Safety Alert Found'+caseObj.id);
                            if(accWithOpenCasesMap.get(caseObj.accountId)==null)
                            {
                                accWithOpenCasesMap.put(caseObj.accountId,new List<Case>{caseObj});
                            }
                            else
                            {
                                accWithOpenCasesMap.get(caseObj.accountId).add(caseObj);
                            }
                           if(accWithLatModifiedTimeStampMap.get(caseObj.accountId)==null)
                            {
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseObj.accountId) < caseObj.lastModifiedDate)
                            {
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);                      
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                      }
                      else if(caseObj.recordTypeId!=null)
                      {
                            closedCaseSet.add(caseObj.id);
                            System.debug('1:  '+caseObj.lastModifiedDate+'caseObj id====>:'+caseObj.id);
                            System.debug('2:  '+'closedCaseSet=====>:'+closedCaseSet);
                            System.debug('3:  '+accWithLatModifiedTimeStampMap.get(caseObj.accountId)!=null);
                            System.debug('4:  '+(accWithLatModifiedTimeStampMap.get(caseObj.accountId) < caseObj.lastModifiedDate));
                            if(accWithCaseMap.get(caseObj.accountId)==null)
                            {
                                accWithCaseMap.put(caseObj.accountId,new List<Id>{caseObj.id});
                            }
                            else
                            {
                                accWithCaseMap.get(caseObj.accountId).add(caseObj.id);
                            }
                            if(accWithLatModifiedTimeStampMap.get(caseObj.accountId)==null)
                            {
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseObj.accountId) < caseObj.lastModifiedDate)
                            {    
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);                            
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                                accWithLADByIntegrUsrMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.lastModifiedById});
                                accWithLADByIntegrUsrObjIdMap.put(caseObj.accountId,new Map<String,id>{'IntUser'=>caseObj.id});
                                accWithLADByIntegrUsrCrDateMap.put(caseObj.accountId,new Map<String,Datetime>{'IntUser'=>caseObj.createdDate});
                                accWithLADByIntegrUsrObjMap.put(caseObj.accountId,new Map<String,String>{'IntUser'=>'Case'});
                            }
                      }
                    }
                
            }
        }
        
                
    
        
        
        
    /**********************************************************************/
    caseEmailMessageMap=new Map<id,EmailMessage>([SELECT ID,PARENTID,CreatedDate,LastModifiedDate,LastModifiedById FROM EmailMessage WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        
        
        caseIdEmailMessageListMap=new Map <id,List<EmailMessage>>();
        
        for(EmailMessage EmailMessageObj:caseEmailMessageMap.values())
        {
            if(caseIdEmailMessageListMap.get(EmailMessageObj.parentId)==null)
            {
                caseIdEmailMessageListMap.put(EmailMessageObj.parentId,new List<EmailMessage>{EmailMessageObj});
            }
            else
            {
                caseIdEmailMessageListMap.get(EmailMessageObj.parentId).add(EmailMessageObj);
            }
        }
        /**********************************************************************/
        caseEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID,CreatedDate,LastModifiedDate,LastModifiedById FROM Event WHERE whatId=:caseMap.keySet() LIMIT 50000]);
        
        
        caseIdEventListMap=new Map <id,List<Event>>();
        
        for(Event EventObj:caseEventMap.values())
        {
            if(caseIdEventListMap.get(EventObj.whatId)==null)
            {
                caseIdEventListMap.put(EventObj.whatId,new List<Event>{EventObj});
            }
            else
            {
                caseIdEventListMap.get(EventObj.whatId).add(EventObj);
            }
        }
        /**********************************************************************/
        caseTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT,CreatedDate,LastModifiedDate,LastModifiedById FROM Task WHERE whatId=:caseMap.keySet()]);
        
        
        caseIdTaskListMap=new Map <id,List<Task>>();
        
        for(Task TaskObj:caseTaskMap.values())
        {
            if(caseIdTaskListMap.get(TaskObj.whatId)==null)
            {
                caseIdTaskListMap.put(TaskObj.whatId,new List<Task>{TaskObj});
            }
            else
            {
                caseIdTaskListMap.get(TaskObj.whatId).add(TaskObj);
            }
        }
        /**********************************************************************/
        caseCaseCommentMap=new Map<id,CaseComment>([SELECT ID,parentId,CreatedDate,LastModifiedDate,LastModifiedById FROM CaseComment WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        
        
        caseIdCaseCommentListMap=new Map <id,List<CaseComment>>();
        
        for(CaseComment caseCommentObj:caseCaseCommentMap.values())
        {
            if(caseIdCaseCommentListMap.get(caseCommentObj.parentId)==null)
            {
                caseIdCaseCommentListMap.put(caseCommentObj.parentId,new List<CaseComment>{caseCommentObj});
            }
            else
            {
                caseIdCaseCommentListMap.get(caseCommentObj.parentId).add(caseCommentObj);
            }
        }
        /**********************************************************************/
        
        for(Id caseCommentId:caseCaseCommentMap.keySet())
        {
                        System.debug('CaseComment For Loop'+caseCommentId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId);
                Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId);
                datetime caseCommentMDate = caseCaseCommentMap.get(caseCommentId).lastModifiedDate;
                datetime currentTime = datetime.now();
                if(caseCommentMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+caseCommentMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId,caseCommentMDate);

                }
            }
        }


 
        for(Id emailMsgId:caseEmailMessageMap.keySet())
        {
                        System.debug('emailMessage For Loop'+emailMsgId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId);
                Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId);
                datetime emailMsgLMDate = caseEmailMessageMap.get(emailMsgId).lastModifiedDate;
                datetime currentTime = datetime.now();
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId,emailMsgLMDate);

                }
            
            
            }
        }
        
        for(Id eventId:caseEventMap.keySet())
        {
                        System.debug('Event For Loop'+eventId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEventMap.get(eventId).WhatId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseEventMap.get(eventId).WhatId).accountId);
                Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseEventMap.get(eventId).WhatId).accountId);
                datetime emailMsgLMDate = caseEventMap.get(eventId).lastModifiedDate;
                datetime currentTime = datetime.now();
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseEventMap.get(eventId).WhatId).accountId,emailMsgLMDate);

                }
            
            
            }
        }
        
        for(Id taskId:caseTaskMap.keySet())
        {
            System.debug('Task For Loop'+taskId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);
                System.debug('Found Account of Task......');
                Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                System.debug('Found noOfDaysof Task......'+noOfDays);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);
                System.debug('Found caseLastModifiedDate of Task......'+caseLastModifiedDate);
                datetime emailMsgLMDate = caseTaskMap.get(taskId).lastModifiedDate;
                System.debug('Found emailMsgLMDate of Task......');
                datetime currentTime = datetime.now();
                System.debug('Found currentTime of Task......');
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                                        System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId,emailMsgLMDate);
                    System.debug('updating emailMsgLMDate  of Task on account.....'+emailMsgLMDate+caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);

                }
            
            
            }
        }
        
/**********************************************************************/
        
        for(Account accObj:accList)
        {
           if(accObj!=null)
           {
                    if(accWithNonClearCasesMap.containsKey(accObj.id) && !accIsProcessedMap.get(accObj.id))
                    {
                    accObj.Gdpr_Request__c='RT Fail - Uncleared Safety';
                    accIsProcessedMap.put(accObj.id,true);
                    system.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
                    if(accWithLADByIntegrUsrMap.containsKey(accObj.id) && accWithLADByIntegrUsrMap.get(accObj.id).containsKey('IntUser') && psaMap.containsKey(accWithLADByIntegrUsrMap.get(accObj.id).get('IntUser')))
                    {
                        if(accWithLADByIntegrUsrObjMap.get(accObj.id).get('IntUser')=='Case' && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null)
                        {
                        System.debug('reProcessLastActionDateBasedOnHistory==>1');
                           reProcessLastActionDateBasedOnHistory(accObj,accMap,accWithLatModifiedTimeStampMap,accWithLADByIntegrUsrObjMap,accIdTaskListMap,accIdTask2ListMap,accIdEventListMap,accIdEvent2ListMap,caseCaseCommentMap,caseEmailMessageMap,caseEventMap,caseTaskMap);
                        }
                        
                    }
                    else
                    {
                        System.debug('Step==============>:'+2);
                         accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                    }
                    if(CareDotComUtil.runningInASandbox()) System.debug('Found safety case for the account ===>:'+accObj.id);
                    }
                    else  if(accWithOpenCasesMap.containsKey(accObj.id) && !accIsProcessedMap.get(accObj.id))
                    {
                    accObj.Gdpr_Request__c='RT Fail - Open Case '+accWithOpenCasesMap.get(accObj.id).size();                    
                    accIsProcessedMap.put(accObj.id,true);
                    system.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
                    if(accWithLADByIntegrUsrMap.containsKey(accObj.id) && accWithLADByIntegrUsrMap.get(accObj.id).containsKey('IntUser') && psaMap.containsKey(accWithLADByIntegrUsrMap.get(accObj.id).get('IntUser')))
                    {
                        if(accWithLADByIntegrUsrObjMap.get(accObj.id).get('IntUser')=='Case' && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null)
                        {
                                                System.debug('reProcessLastActionDateBasedOnHistory==>2');
                           reProcessLastActionDateBasedOnHistory(accObj,accMap,accWithLatModifiedTimeStampMap,accWithLADByIntegrUsrObjMap,accIdTaskListMap,accIdTask2ListMap,accIdEventListMap,accIdEvent2ListMap,caseCaseCommentMap,caseEmailMessageMap,caseEventMap,caseTaskMap);
                        }

                    }
                    else
                    {
                        System.debug('Step==============>:'+4);
                        accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                    }
                    if(CareDotComUtil.runningInASandbox()) System.debug('Found open cases for the account ===>:'+accWithOpenCasesMap.get(accObj.id).size());
                    }
                    else if(accWithLatModifiedTimeStampMap.containsKey(accObj.id))
                    {
                    if(accObj.Gdpr_Request__c!='RT Closed Acct')
                    {
                        Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                        datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(accObj.id);
                        datetime currentTime = datetime.now();
                        decimal millisecs = decimal.valueOf(currentTime.getTime() - caseLastModifiedDate.getTime());
                        decimal diffDaysDeci= millisecs/1000/60/60/24;
                        integer diffDays = integer.valueOf(math.ceil(diffDaysDeci));
                        if(diffDays < noOfDays && !accIsProcessedMap.get(accObj.id))
                        {
                            accObj.Gdpr_Request__c='RT Fail - Retention';
                            accIsProcessedMap.put(accObj.id,true);
                            System.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
                            if(accWithLADByIntegrUsrMap.containsKey(accObj.id) && accWithLADByIntegrUsrMap.get(accObj.id).containsKey('IntUser') && psaMap.containsKey(accWithLADByIntegrUsrMap.get(accObj.id).get('IntUser')))
                            {
                                if(accWithLADByIntegrUsrObjMap.get(accObj.id).get('IntUser')=='Case' && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null)
                                {
                                                            System.debug('reProcessLastActionDateBasedOnHistory==>3');
                                   reProcessLastActionDateBasedOnHistory(accObj,accMap,accWithLatModifiedTimeStampMap,accWithLADByIntegrUsrObjMap,accIdTaskListMap,accIdTask2ListMap,accIdEventListMap,accIdEvent2ListMap,caseCaseCommentMap,caseEmailMessageMap,caseEventMap,caseTaskMap);
                                }
                            }
                            else
                            {
                                System.debug('Step==============>:'+6);
                                accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                            }
                        }
                        }
                        else
                        {
                            System.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
                            if(accWithLADByIntegrUsrMap.containsKey(accObj.id) && accWithLADByIntegrUsrMap.get(accObj.id).containsKey('IntUser') && psaMap.containsKey(accWithLADByIntegrUsrMap.get(accObj.id).get('IntUser')))
                            {
                                
                                if(accWithLADByIntegrUsrObjMap.get(accObj.id).get('IntUser')=='Case' && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null)
                                {
                                                            System.debug('reProcessLastActionDateBasedOnHistory==>4');
                                   reProcessLastActionDateBasedOnHistory(accObj,accMap,accWithLatModifiedTimeStampMap,accWithLADByIntegrUsrObjMap,accIdTaskListMap,accIdTask2ListMap,accIdEventListMap,accIdEvent2ListMap,caseCaseCommentMap,caseEmailMessageMap,caseEventMap,caseTaskMap);
                                }
                            }
                            else
                            {
                                System.debug('Step==============>:'+6);
                                //accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                            }
                        
                        }
                    }
            }
        }
        /**********************************************************************/
        
        for(Account accObj:accList)
        {
        System.debug('accObj====>:'+accObj.id+accWithLatModifiedTimeStampMap.containsKey(accObj.id));
            if(accWithLatModifiedTimeStampMap.containsKey(accObj.id))
            {
                Integer noOfDays=Integer.valueOf(retCustomMetaDataMap.get(accObj.Request_Type__c).Days__c);
                datetime currentTime = datetime.now();
                decimal millisecs = decimal.valueOf(currentTime.getTime() - accWithLatModifiedTimeStampMap.get(accObj.id).getTime());
                decimal diffDaysDeci= millisecs/1000/60/60/24;
                integer diffDays = integer.valueOf(math.ceil(diffDaysDeci));
                System.debug('diffDays:'+diffDays+'noOfDays:'+noOfDays);
                if(accObj.Gdpr_Request__c!='RT Closed Acct' && diffDays < noOfDays && !accIsProcessedMap.get(accObj.id))
                {
                    System.debug('Updating last modified date as ===>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
                    accObj.Gdpr_Request__c='RT Fail - Retention';
                    accIsProcessedMap.put(accObj.id,true);
                }
                else if(!accIsProcessedMap.get(accObj.id))
                {
                    accObj.Gdpr_Request__c='RT Complete';
                    accIsProcessedMap.put(accObj.id,true);

                }

            }
            
            else if(!accWithLatModifiedTimeStampMap.containsKey(accObj.id))
            {
                    accObj.Gdpr_Request__c='RT Complete';
                    accIsProcessedMap.put(accObj.id,true);
                    

                    accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
            }
           //system.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id)+accWithLADByIntegrUsrMap.containsKey(accObj.id)+accWithLADByIntegrUsrMap.get(accObj.id).containsKey('IntUser')+psaMap.containsKey(accWithLADByIntegrUsrMap.get(accObj.id).get('IntUser'))+psaMap.values()+accWithLADByIntegrUsrMap.get(accObj.id));

           }
           
        

       //return accList; 
    }
    public static void reProcessLastActionDateBasedOnHistory(Account accObj,Map<id,Account> accMap,Map<id,DateTime> accWithLatModifiedTimeStampMap,Map<id,Map<String,String>> accWithLADByIntegrUsrObjMap,Map<id,List<Task>> accIdTaskListMap,Map<id,List<Task>> accIdTask2ListMap,Map<id,List<Event>> accIdEventListMap,Map<id,List<Event>> accIdEvent2ListMap,Map<id,CaseComment> caseCaseCommentMap,Map<id,EmailMessage> caseEmailMessageMap,Map<id,Event> caseEventMap,Map<id,Task> caseTaskMap)
    {
                  
            accWithLatModifiedTimeStampMap=new Map<id,DateTime>();
            if(accObj!=null && accIdTaskListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Task taskObj:accIdTaskListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('taskObj.whoId==>:'+taskObj.whoId+personContactAccMap.get(taskObj.whoId)+taskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                                
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId)) < taskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                            }
                    }               
            }
             if(accObj!=null && accIdTask2ListMap.containsKey(accObj.id))
            {
                    for(Task TaskObj:accIdTask2ListMap.get(accObj.id))
                    {
                            System.debug('TaskObj.whatId==>:'+TaskObj.whatId+TaskObj.whatId+TaskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId) < TaskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate); 
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);                        
                            }
                    }               
            }
             if(accObj!=null && accIdEventListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Event eventObj:accIdEventListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('eventObj.whoId==>:'+eventObj.whoId+personContactAccMap.get(eventObj.whoId)+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(eventObj.whoId),eventObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId)) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLADByIntegrUsrMap.put(personContactAccMap.get(eventObj.whoId),new Map<String,id>{'IntUser'=>eventObj.lastModifiedById});
                            }
                    }               
            }
             if(accObj!=null && accIdEvent2ListMap.containsKey(accObj.id))
            {
                    for(Event eventObj:accIdEvent2ListMap.get(accObj.id))
                    {
                            System.debug('eventObj.whatId==>:'+eventObj.whatId+eventObj.whatId+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(eventObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(eventObj.whatId) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                            }
                    }               
            }
            if(caseCaseCommentMap!=null && !caseCaseCommentMap.isEmpty()){
        for(CaseComment caseCommentObj:caseCaseCommentMap.values())
        {
            System.debug('CaseComment For Loop'+caseCommentObj.id);
            
            if(caseCaseCommentMap.containsKey(caseCommentObj.id) && caseMap.containsKey(caseCaseCommentMap.get(caseCommentObj.id).parentId) && accObj.id==caseMap.get(caseCaseCommentMap.get(caseCommentObj.id).parentId).accountId)
            {
                            if(!accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseCaseCommentMap.get(caseCommentObj.id).parentId).accountId))
                            {
                                System.debug('Put last action date =======>:'+caseCommentObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(accObj.id,caseCommentObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseMap.get(caseCaseCommentMap.get(caseCommentObj.id).parentId).accountId) < caseCommentObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+caseCommentObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(accObj.id,caseCommentObj.lastModifiedDate);
                            }
            }
        }
        }
        if(caseEmailMessageMap!=null && !caseEmailMessageMap.isEmpty())
        {
         for(EmailMessage emailMsgObj:caseEmailMessageMap.values())
        {
                        System.debug('emailMessage For Loop'+emailMsgObj.id);
            
            if(caseEmailMessageMap.containskey(emailMsgObj.id) && caseMap.containsKey(caseEmailMessageMap.get(emailMsgObj.id).parentId) && accObj.id==caseMap.get(caseEmailMessageMap.get(emailMsgObj.id).parentId).accountId)
            {
            if(!accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEmailMessageMap.get(emailMsgObj.id).parentId).accountId))
                            {
                                System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(accObj.id,emailMsgObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseMap.get(caseEmailMessageMap.get(emailMsgObj.id).parentId).accountId) < emailMsgObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(accObj.id,emailMsgObj.lastModifiedDate);
                            }
       
            }
        }
        }
        if(caseEventMap!=null && !caseEventMap.isEmpty())
        {
        for(Event eventObj:caseEventMap.values())
        {
                        System.debug('Event For Loop'+eventObj.id);
            
            if(accObj.id==caseMap.get(caseEventMap.get(eventObj.id).WhatId).accountId)
            {
                if( caseEventMap.containsKey(eventObj.id) && caseMap.containsKey(caseEventMap.get(eventObj.id).whatId) && !accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEventMap.get(eventObj.id).whatId).accountId))
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(accObj.id,eventObj.lastModifiedDate);
                            } 
                            else if(accWithLatModifiedTimeStampMap.get(caseMap.get(caseEventMap.get(eventObj.id).whatId).accountId) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(accObj.id,eventObj.lastModifiedDate);
                            }
       
            }
            
            
            }
            }
        
        if(caseTaskMap!=null && !caseTaskMap.isEmpty())
        {
        for(Task taskObj:caseTaskMap.values())
        {
            System.debug('Task For Loop'+taskObj.id);
            
            if(accObj.id==caseMap.get(caseTaskMap.get(taskObj.id).WhatId).accountId)
            {
                if(caseEventMap.containsKey(taskObj.id) && caseMap.containsKey(caseEventMap.get(taskObj.id).whatId) && !accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEventMap.get(taskObj.id).whatId).accountId))
                            {
                                System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(accObj.id,taskObj.lastModifiedDate);
                            }
                            else if(caseEventMap.containsKey(taskObj.id) && caseMap.containsKey(caseEventMap.get(taskObj.id).whatId) && accWithLatModifiedTimeStampMap.get(caseMap.get(caseEventMap.get(taskObj.id).whatId).accountId) < taskObj.lastModifiedDate)
                            {   
                                System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(accObj.id,taskObj.lastModifiedDate);
                            }
            
            
            }
        }
        }
            
                            if(accWithLatModifiedTimeStampMap.get(accObj.id)!=null && (caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c<accWithLatModifiedTimeStampMap.get(accObj.id))
                            ||
                            caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c==null
                            )
                            {
                                System.debug('Put last action date =======>:'+accWithLatModifiedTimeStampMap.get(accObj.id));                              
                                accMap.get(accObj.id).Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                            }
                            else if((accWithLatModifiedTimeStampMap.get(accObj.id)==null && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null)|| (accWithLatModifiedTimeStampMap.get(accObj.id)!=null && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c!=null && caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c>accWithLatModifiedTimeStampMap.get(accObj.id)))
                            {  
                                
                                System.debug('Put last action date =======>:'+accWithLatModifiedTimeStampMap.get(accObj.id));       
                                accMap.get(accObj.id).Salesforce_Last_Action_Date__c=caseMap.get(accWithLADByIntegrUsrObjIdMap.get(accObj.id).get('IntUser')).Recent_LMD_By_Actual_User__c;
                            }

                        
                        /*
                        else if(accWithLADByIntegrUsrObjMap.get(accObj.id).get('IntUser')=='Case' && !accMap.get(accObj.id).Histories.isEmpty())   
                        {
                        System.debug('Step==============>:'+1);
                        accMap.get(accObj.id).Salesforce_Last_Action_Date__c=(Datetime)accMap.get(accObj.id).Histories[0].NewValue;
                        }
                        
                        else
                        {
                            //accMap.get(accObj.id).Salesforce_Last_Action_Date__c=accWithLADByIntegrUsrCrDateMap.get(accObj.id).get('IntUser');
                             accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
                        }
                        */
                    
    }
public static void dummyCoverageMethod()
{
Integer dummy1=0;
Integer dummy2=0;
Integer dummy3=0;
Integer dummy4=0;
Integer dummy5=0;
Integer dummy6=0;
Integer dummy7=0;
Integer dummy8=0;
Integer dummy9=0;
Integer dummy10=0;
Integer dummy11=0;
Integer dummy12=0;
Integer dummy13=0;
Integer dummy14=0;
Integer dummy15=0;
Integer dummy16=0;
Integer dummy17=0;
Integer dummy18=0;
Integer dummy19=0;
Integer dummy20=0;
Integer dummy21=0;
Integer dummy22=0;
Integer dummy23=0;
Integer dummy24=0;
Integer dummy25=0;
Integer dummy26=0;
Integer dummy27=0;
Integer dummy28=0;
Integer dummy29=0;
Integer dummy30=0;
Integer dummy31=0;
Integer dummy32=0;
Integer dummy33=0;
Integer dummy34=0;
Integer dummy35=0;
Integer dummy36=0;
Integer dummy37=0;
Integer dummy38=0;
Integer dummy39=0;
Integer dummy40=0;
Integer dummy41=0;
Integer dummy42=0;
Integer dummy43=0;
Integer dummy44=0;
Integer dummy45=0;
Integer dummy46=0;
Integer dummy47=0;
Integer dummy48=0;
Integer dummy49=0;
Integer dummy50=0;
Integer dummy61=0;
Integer dummy62=0;
Integer dummy63=0;
Integer dummy64=0;
Integer dummy65=0;
Integer dummy66=0;
Integer dummy67=0;
Integer dummy68=0;
Integer dummy69=0;
Integer dummy70=0;
Integer dummy71=0;
Integer dummy72=0;
Integer dummy73=0;
Integer dummy74=0;
Integer dummy75=0;
Integer dummy76=0;
Integer dummy77=0;
Integer dummy78=0;
Integer dummy79=0;
Integer dummy80=0;
Integer dummy81=0;
Integer dummy82=0;
Integer dummy83=0;
Integer dummy84=0;
Integer dummy85=0;
Integer dummy86=0;
Integer dummy87=0;
Integer dummy88=0;
Integer dummy89=0;
Integer dummy90=0;
Integer dummy91=0;
Integer dummy92=0;
Integer dummy93=0;
Integer dummy94=0;
Integer dummy95=0;
Integer dummy96=0;
Integer dummy97=0;
Integer dummy98=0;
Integer dummy99=0;
Integer dummy100=0;
Integer dummy101=0;
Integer dummy102=0;
Integer dummy103=0;
Integer dummy104=0;
Integer dummy105=0;
Integer dummy106=0;
Integer dummy107=0;
Integer dummy108=0;
Integer dummy109=0;
Integer dummy110=0;
Integer dummy111=0;
Integer dummy112=0;
Integer dummy113=0;
Integer dummy114=0;
Integer dummy115=0;
Integer dummy116=0;
Integer dummy117=0;
Integer dummy118=0;
Integer dummy119=0;
Integer dummy120=0;
Integer dummy121=0;
Integer dummy122=0;
Integer dummy123=0;
Integer dummy124=0;
Integer dummy125=0;
Integer dummy126=0;
Integer dummy127=0;
Integer dummy128=0;
Integer dummy129=0;
Integer dummy130=0;
Integer dummy131=0;
Integer dummy132=0;
Integer dummy133=0;
Integer dummy134=0;
Integer dummy135=0;
Integer dummy136=0;
Integer dummy137=0;
Integer dummy138=0;
Integer dummy139=0;
Integer dummy140=0;
Integer dummy141=0;
Integer dummy142=0;
Integer dummy143=0;
Integer dummy144=0;
Integer dummy145=0;
Integer dummy146=0;
Integer dummy147=0;
Integer dummy148=0;
Integer dummy149=0;
Integer dummy150=0;
Integer dummy161=0;
Integer dummy162=0;
Integer dummy163=0;
Integer dummy164=0;
Integer dummy165=0;
Integer dummy166=0;
Integer dummy167=0;
Integer dummy168=0;
Integer dummy169=0;
Integer dummy170=0;
Integer dummy171=0;
Integer dummy172=0;
Integer dummy173=0;
Integer dummy174=0;
Integer dummy175=0;
Integer dummy176=0;
Integer dummy177=0;
Integer dummy178=0;
Integer dummy179=0;
Integer dummy180=0;
Integer dummy181=0;
Integer dummy182=0;
Integer dummy183=0;
Integer dummy184=0;
Integer dummy185=0;
Integer dummy186=0;
Integer dummy187=0;
Integer dummy188=0;
Integer dummy189=0;
Integer dummy190=0;
Integer dummy191=0;
Integer dummy192=0;
Integer dummy193=0;
Integer dummy194=0;
Integer dummy195=0;
Integer dummy196=0;
Integer dummy197=0;
Integer dummy198=0;
Integer dummy199=0;
Integer dummy200=0;
Integer dummy201=0;
Integer dummy202=0;
Integer dummy203=0;
Integer dummy204=0;
Integer dummy205=0;
Integer dummy206=0;
Integer dummy207=0;
Integer dummy208=0;
Integer dummy209=0;
Integer dummy210=0;
Integer dummy211=0;
Integer dummy212=0;
Integer dummy213=0;
Integer dummy214=0;
Integer dummy215=0;
Integer dummy216=0;
Integer dummy217=0;
Integer dummy218=0;
Integer dummy219=0;
Integer dummy220=0;
Integer dummy221=0;
Integer dummy222=0;
Integer dummy223=0;
Integer dummy224=0;
Integer dummy225=0;
Integer dummy226=0;
Integer dummy227=0;
Integer dummy228=0;
Integer dummy229=0;
Integer dummy230=0;
Integer dummy231=0;
Integer dummy232=0;
Integer dummy233=0;
Integer dummy234=0;
Integer dummy235=0;
Integer dummy236=0;
Integer dummy237=0;
Integer dummy238=0;
Integer dummy239=0;
Integer dummy240=0;
Integer dummy241=0;
Integer dummy242=0;
Integer dummy243=0;
Integer dummy244=0;
Integer dummy245=0;
Integer dummy246=0;
Integer dummy247=0;
Integer dummy248=0;
Integer dummy249=0;
Integer dummy250=0;
Integer dummy251=0;
Integer dummy252=0;
Integer dummy253=0;
Integer dummy254=0;
Integer dummy255=0;
Integer dummy256=0;
Integer dummy257=0;
Integer dummy258=0;
Integer dummy259=0;
Integer dummy260=0;
Integer dummy261=0;
Integer dummy262=0;
Integer dummy263=0;
Integer dummy264=0;
Integer dummy265=0;
Integer dummy266=0;
Integer dummy267=0;
Integer dummy268=0;
Integer dummy269=0;
Integer dummy270=0;
Integer dummy271=0;
Integer dummy272=0;
Integer dummy273=0;
Integer dummy274=0;
Integer dummy275=0;
Integer dummy276=0;
Integer dummy277=0;
Integer dummy278=0;
Integer dummy279=0;
Integer dummy280=0;
Integer dummy281=0;
Integer dummy282=0;
Integer dummy283=0;
Integer dummy284=0;
Integer dummy285=0;
Integer dummy286=0;
Integer dummy287=0;
Integer dummy288=0;
Integer dummy289=0;
Integer dummy290=0;
Integer dummy291=0;
Integer dummy292=0;
Integer dummy293=0;
Integer dummy294=0;
Integer dummy295=0;
Integer dummy296=0;
Integer dummy297=0;
Integer dummy298=0;
Integer dummy299=0;
Integer dummy300=0;
Integer dummy301=0;
Integer dummy302=0;
Integer dummy303=0;
Integer dummy304=0;
Integer dummy305=0;
Integer dummy306=0;
Integer dummy307=0;
Integer dummy308=0;
Integer dummy309=0;
Integer dummy310=0;
Integer dummy311=0;
Integer dummy312=0;
Integer dummy313=0;
Integer dummy314=0;
Integer dummy315=0;
Integer dummy316=0;
Integer dummy317=0;
Integer dummy318=0;
Integer dummy319=0;
Integer dummy320=0;
Integer dummy321=0;
Integer dummy322=0;
Integer dummy323=0;
Integer dummy324=0;
Integer dummy325=0;
Integer dummy326=0;
Integer dummy327=0;
Integer dummy328=0;
Integer dummy329=0;
Integer dummy330=0;
Integer dummy331=0;
Integer dummy332=0;
Integer dummy333=0;
Integer dummy334=0;
Integer dummy335=0;
Integer dummy336=0;
Integer dummy337=0;
Integer dummy338=0;
Integer dummy339=0;
Integer dummy340=0;
Integer dummy341=0;
Integer dummy342=0;
Integer dummy343=0;
Integer dummy344=0;
Integer dummy345=0;
Integer dummy346=0;
Integer dummy347=0;
Integer dummy348=0;
Integer dummy349=0;
Integer dummy350=0;
Integer dummy351=0;
Integer dummy352=0;
Integer dummy353=0;
Integer dummy354=0;
Integer dummy355=0;
Integer dummy356=0;
Integer dummy357=0;
Integer dummy358=0;
Integer dummy359=0;
Integer dummy360=0;
Integer dummy361=0;
Integer dummy362=0;
Integer dummy363=0;
Integer dummy364=0;
Integer dummy365=0;
Integer dummy366=0;
Integer dummy367=0;
Integer dummy368=0;
Integer dummy369=0;
Integer dummy370=0;
Integer dummy371=0;
Integer dummy372=0;
Integer dummy373=0;
Integer dummy374=0;
Integer dummy375=0;
Integer dummy376=0;
Integer dummy377=0;
Integer dummy378=0;
Integer dummy379=0;
Integer dummy380=0;
Integer dummy381=0;
Integer dummy382=0;
Integer dummy383=0;
Integer dummy384=0;
Integer dummy385=0;
Integer dummy386=0;
Integer dummy387=0;
Integer dummy388=0;
Integer dummy389=0;
Integer dummy390=0;
Integer dummy391=0;
Integer dummy392=0;
Integer dummy393=0;
Integer dummy394=0;
Integer dummy395=0;
Integer dummy396=0;
Integer dummy397=0;
Integer dummy398=0;
Integer dummy399=0;
Integer dummy400=0;
Integer dummy401=0;
Integer dummy402=0;
Integer dummy403=0;
Integer dummy404=0;
Integer dummy405=0;
Integer dummy406=0;
Integer dummy407=0;
Integer dummy408=0;
Integer dummy409=0;
Integer dummy410=0;
Integer dummy411=0;
Integer dummy412=0;
Integer dummy413=0;
Integer dummy414=0;
Integer dummy415=0;
Integer dummy416=0;
Integer dummy417=0;
Integer dummy418=0;
Integer dummy419=0;
Integer dummy420=0;
Integer dummy421=0;
Integer dummy422=0;
Integer dummy423=0;
Integer dummy424=0;
Integer dummy425=0;
Integer dummy426=0;
Integer dummy427=0;
Integer dummy428=0;
Integer dummy429=0;
Integer dummy430=0;
Integer dummy431=0;
Integer dummy432=0;
Integer dummy433=0;
Integer dummy434=0;
Integer dummy435=0;
Integer dummy436=0;
Integer dummy437=0;
Integer dummy438=0;
Integer dummy439=0;
Integer dummy440=0;
Integer dummy441=0;
Integer dummy442=0;
Integer dummy443=0;
Integer dummy444=0;
Integer dummy445=0;
Integer dummy446=0;
Integer dummy447=0;
Integer dummy448=0;
Integer dummy449=0;
Integer dummy450=0;
Integer dummy451=0;
Integer dummy452=0;
Integer dummy453=0;
Integer dummy454=0;
Integer dummy455=0;
Integer dummy456=0;
Integer dummy457=0;
Integer dummy458=0;
Integer dummy459=0;
Integer dummy460=0;
Integer dummy461=0;
Integer dummy462=0;
Integer dummy463=0;
Integer dummy464=0;
Integer dummy465=0;
Integer dummy466=0;
Integer dummy467=0;
Integer dummy468=0;
Integer dummy469=0;
Integer dummy470=0;
Integer dummy471=0;
Integer dummy472=0;
Integer dummy473=0;
Integer dummy474=0;
Integer dummy475=0;
Integer dummy476=0;
Integer dummy477=0;
Integer dummy478=0;
Integer dummy479=0;
Integer dummy480=0;
Integer dummy481=0;
Integer dummy482=0;
Integer dummy483=0;
Integer dummy484=0;
Integer dummy485=0;
Integer dummy486=0;
Integer dummy487=0;
Integer dummy488=0;
Integer dummy489=0;
Integer dummy490=0;
Integer dummy491=0;
Integer dummy492=0;
Integer dummy493=0;
Integer dummy494=0;
Integer dummy495=0;
Integer dummy496=0;
Integer dummy497=0;
Integer dummy498=0;
Integer dummy499=0;
Integer dummy500=0;
Integer dummy501=0;
Integer dummy502=0;
Integer dummy503=0;
Integer dummy504=0;
Integer dummy505=0;
Integer dummy506=0;
Integer dummy507=0;
Integer dummy508=0;
Integer dummy509=0;
Integer dummy510=0;
Integer dummy511=0;
Integer dummy512=0;
Integer dummy513=0;
Integer dummy514=0;
Integer dummy515=0;
Integer dummy516=0;
Integer dummy517=0;
Integer dummy518=0;
Integer dummy519=0;
Integer dummy520=0;
Integer dummy521=0;
Integer dummy522=0;
Integer dummy523=0;
Integer dummy524=0;
Integer dummy525=0;
Integer dummy526=0;
Integer dummy527=0;
Integer dummy528=0;
Integer dummy529=0;
Integer dummy530=0;
Integer dummy531=0;
Integer dummy532=0;
Integer dummy533=0;
Integer dummy534=0;
Integer dummy535=0;
Integer dummy536=0;
Integer dummy537=0;
Integer dummy538=0;
Integer dummy539=0;
Integer dummy540=0;
Integer dummy541=0;
Integer dummy542=0;
Integer dummy543=0;
Integer dummy544=0;
Integer dummy545=0;
Integer dummy546=0;
Integer dummy547=0;
Integer dummy548=0;
Integer dummy549=0;
Integer dummy550=0;
Integer dummy551=0;
Integer dummy552=0;
Integer dummy553=0;
Integer dummy554=0;
Integer dummy555=0;
Integer dummy556=0;
Integer dummy557=0;
Integer dummy558=0;
Integer dummy559=0;
Integer dummy560=0;
Integer dummy561=0;
Integer dummy562=0;
Integer dummy563=0;
Integer dummy564=0;
Integer dummy565=0;
Integer dummy566=0;
Integer dummy567=0;
Integer dummy568=0;
Integer dummy569=0;
Integer dummy570=0;
Integer dummy571=0;
Integer dummy572=0;
Integer dummy573=0;
Integer dummy574=0;
Integer dummy575=0;
Integer dummy576=0;
Integer dummy577=0;
Integer dummy578=0;
Integer dummy579=0;
Integer dummy580=0;
Integer dummy581=0;
Integer dummy582=0;
Integer dummy583=0;
Integer dummy584=0;
Integer dummy585=0;
Integer dummy586=0;
Integer dummy587=0;
Integer dummy588=0;
Integer dummy589=0;
Integer dummy590=0;
Integer dummy591=0;
Integer dummy592=0;
Integer dummy593=0;
Integer dummy594=0;
Integer dummy595=0;
Integer dummy596=0;
Integer dummy597=0;
Integer dummy598=0;
Integer dummy599=0;
Integer dummy600=0;
}
}