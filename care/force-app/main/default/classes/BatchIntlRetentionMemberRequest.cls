global class BatchIntlRetentionMemberRequest implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    public Integer batchSize=200;
    public List<Account> accList=new List<Account>();
    global Database.Querylocator start(Database.BatchableContext bc)
    {
    List<Process_Control_Settings__mdt>  pcsList= [select id,DeveloperName,MasterLabel,Process_Name__c,Switch__c from Process_Control_Settings__mdt where Process_Name__c='Intl Retention Batch'];
    List<Id> pcIdList=new List<id>();
    String retentionSwitch=pcsList[0].Switch__c;
    if(retentionSwitch == 'On')
    {
        query = 'select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c from Account where Gdpr_Request__c in (\'RT Open Inactive\',\'RT Closed Acct\',\'RT Incomplete\',\'RT Anonymize\')';
        if(isTestingContext)
        {
        query = 'select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c from Account where Gdpr_Request__c in (\'RT Open Inactive\',\'RT Closed Acct\',\'RT Incomplete\',\'RT Anonymize\')'+' LIMIT 10';
        }
        System.debug('Retention Query firing is ===>:'+query);
      }
      else
      {
          query = 'select id,GDPR_Request__c,Request_Type__c,PersonEmail,Locale__pc,recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c,Salesforce_Last_Action_Date__c from Account where Gdpr_Request__c in (\'RT Open Inactive\',\'RT Closed Acct\',\'RT Incomplete\',\'RT Anonymize\')'+' LIMIT 0';
      }
        return Database.getQuerylocator(query);
  } 
    global BatchIntlRetentionMemberRequest() 
    {
        
        
    }
global BatchIntlRetentionMemberRequest(boolean isTestingContext,Integer batchSize) {
        this.isTestingContext=isTestingContext;
        this.batchSize=batchSize;        
    }
    
    /**
* Schedulable method, execute the schedule apex job
*/
    
    global void execute(SchedulableContext sc) 
    {
        Database.executeBatch(this,batchSize);        
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<Account> accList)
    {
        (new BatchIntlRetentionMemberRequestHelper()).ProcessRetentionRequests(accList);
    }
    
    global void finish(Database.BatchableContext bc)
    {
              
    }
    
}