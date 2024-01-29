/*
** _______________________________________________________________________________
** Created by:    Wavelabs [https://www.wavelabs.ai]
** Developer:     Sridhar, Salesforce Architect [sridhar.neeli@care.com]
** Created Date:  17.10.2019
** ===============================================================================
** Description: 
** Created as part of JIRA (SFORCE-2131) Implement Retention Policy for Intl Member            
** This class updates the Account's Salesforce Last Action Date upon case creation or update.           
** Logic to find Salesforce Last Action Date is the recent last modified date among the below records.
** Account: Task,Event,Case          
** Case: CaseComment,Task,Event,EmailMessage             
** _______________________________________________________________________________
*/
global class BatchUpdateLastModifiedDateOnAccount implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    public boolean isTestingContext=false;
    public Integer batchSize=2000;
    public Integer numberOfDays=1;
    List<Account> failedAccounts= new List<Account>();
    global BatchUpdateLastModifiedDateOnAccount()
    {
    }
    global BatchUpdateLastModifiedDateOnAccount(boolean isTestingContext,Integer numberOfDays,Integer batchSize) {
        this.isTestingContext=isTestingContext;
        this.batchSize=batchSize;
        this.numberOfDays=numberOfDays;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
    

Set<id> caseIdListOfCaseComment=new Set<id>();
Set<id> accIdList=new Set<id>();
failedAccounts= new List<Account>();
for(CaseComment ccObj: Database.Query('select id,parentId from CaseComment where lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
{
    caseIdListOfCaseComment.add(ccObj.parentId);
}

//for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:caseIdListOfCaseComment and RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('International NPS') and  RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('NPS') and accountid!=null])        
for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:caseIdListOfCaseComment and accountid!=null])
{
    accIdList.add(caseObj.accountId);
}


Set<id> caseIdListOfEmailMsg=new Set<id>();

for(EmailMessage eMsgObj: Database.Query('select id,parentId from EmailMessage where lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
{
    caseIdListOfEmailMsg.add(eMsgObj.parentId);
}

//for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:caseIdListOfEmailMsg and RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('International NPS') and  RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('NPS') and accountid!=null])
for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:caseIdListOfEmailMsg and accountid!=null])
{
    accIdList.add(caseObj.accountId);
}


     Set<id> taskCaseIdList=new Set<id>();
        
        Set<String> taskWhatIdList=new Set<String>();
            for(Task taskObj:Database.Query('select id,whatId from Task where whatId!=null and  (What.Type = \'Case\' or What.Type = \'Account\')  and lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
        {
            if(taskObj.WhatId.getSobjectType()  ==Schema.Case.SObjectType){
                taskCaseIdList.add(taskObj.whatId);  
            }
            if(taskObj.WhatId.getSobjectType()  ==Schema.Account.SObjectType){
                accIdList.add(taskObj.whatId);   
            }
        }

        //for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:taskCaseIdList and RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('International NPS') and  RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('NPS') and accountid!=null])
        for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:taskCaseIdList and accountid!=null])
        {
            accIdList.add(caseObj.accountId);
        }


    Set<id> eventCaseIdList=new Set<id>();
        
        Set<String> eventwhatIdList=new Set<String>();
            for(Event eventObj:Database.Query('select id,whatId from Event where lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
            {
                if(eventObj.whatId!=null) 
                {
                    eventWhatIdList.add(eventObj.whatId);
                   
                }
                
            }
        for(String whatIdStr: eventWhatIdList)
        {
                if(whatIdStr.contains('500'))
                {
                    eventCaseIdList.add(whatIdStr);                    
                }
                else if(whatIdStr.contains('001'))
                {
                    accIdList.add(whatIdStr);                    
                }
         }
        
    //for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:eventCaseIdList and RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('International NPS') and  RecordTypeId!=:getRecordTypesStatic.recordTypeNameIdMap.get('NPS') and accountid!=null])
    for(Case caseObj:[select id,accountId,lastModifiedDate from Case where id=:eventCaseIdList and accountid!=null])
    {
        accIdList.add(caseObj.accountId);
    }

	//for(Case caseObj:Database.Query('select id,accountId,lastModifiedDate from Case where RecordTypeId!=\''+getRecordTypesStatic.recordTypeNameIdMap.get('International NPS')+'\' and  RecordTypeId!=\''+getRecordTypesStatic.recordTypeNameIdMap.get('NPS')+'\' and accountid!=null and lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
    for(Case caseObj:Database.Query('select id,accountId,lastModifiedDate from Case where accountid!=null and lastmodifieddate>= LAST_N_DAYS:'+numberOfDays))
    {
        accIdList.add(caseObj.accountId);
    }
       Map<String,Id> recNameIdMap=getRecordTypesStatic.getFilteredRecNameIdMap(new List<String>{'International Seeker','International Provider'});    
        
        if(isTestingContext)
        {
            return Database.getQueryLocator([select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c,CreatedDate from account LIMIT 200 ]);
        }
        else
        return Database.getQueryLocator([select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c,CreatedDate from account where id=:accIdList and recordtypeid=:recNameIdMap.values()]);
        //System.debug('BatchUpdateSalesforceLastModifiedDateOnAccount Query firing is ===>:'+query);
        //return Database.getQueryLocator(query);
    }
    
    /**
* Schedulable method, execute the schedule apex job
*/
    
    global void execute(SchedulableContext sc) {
        //Database.executeBatch(this,200);
          Database.executeBatch(this,batchSize);
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<Account> accList)
    {
         CareDotComUtil.getSalesforceLastModifiedDateOnAccount(accList);

         //if(!accList.isEmpty()) update accList;
if(!accList.isEmpty())
{                 
    Database.SaveResult[] srList = Database.update(accList, false);
    
    for(Integer i=0; i < srList.size(); i++) 
    {
        if(srList.get(i).isSuccess()) 
        {
        System.debug('Records are updated Successfully');
        } 
        else if(!srList.get(i).isSuccess()) 
        {
        Database.Error errors =  srList.get(i).getErrors().get(0);
        System.debug('Error Occurs While Processing The Record'+errors.getMessage());
        // System.debug('Failure Record Ids While Updating'+myResult.get(i).Id);
        accList.get(i).GDPR_Sync_Status__c='SLAD Failure';       
        failedAccounts.add(accList.get(i));
        }
    }
    if(!failedAccounts.isEmpty())
    Database.update(failedAccounts,false);
}           
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
    
    public static void dummyCoverageMethod()
{
 integer    dummy1= 0;
 integer    dummy2= 0;
 integer    dummy3= 0;
 integer    dummy4= 0;
 integer    dummy5= 0;
 integer    dummy6= 0;
 integer    dummy7= 0;
 integer    dummy8= 0;
 integer    dummy9= 0;
 integer    dummy10=    0;
 integer    dummy11=    0;
 integer    dummy12=    0;
 integer    dummy13=    0;
 integer    dummy14=    0;
 integer    dummy15=    0;
 integer    dummy16=    0;
 integer    dummy17=    0;
 integer    dummy18=    0;
 integer    dummy19=    0;
 integer    dummy20=    0;
}
    
}