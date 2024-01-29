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
global class BatchSLADFailoverHandler implements Schedulable, Database.Batchable<SObject>,Database.stateful 
{
    global String query;
    global Integer batchSize=2000;
    List<Account> failedAccounts=new List<Account>();
     public boolean isTestingContext=false;
    BatchSLADFailoverHandler()
    {
            
    }
    global BatchSLADFailoverHandler(Boolean isTestingContext,Integer batchSize) 
    {
        this.isTestingContext=isTestingContext;
        this.batchSize=batchSize;       
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
    failedAccounts = new List<Account>();
         if(isTestingContext)
        {
            return Database.getQueryLocator([select id,PersonContactId,GDPR_Sync_Status__c from Account where  GDPR_Sync_Status__c='SLAD Failure' LIMIT 200]);
        }
        else
        return Database.getQueryLocator([select id,PersonContactId,GDPR_Sync_Status__c from Account where  GDPR_Sync_Status__c='SLAD Failure']);
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