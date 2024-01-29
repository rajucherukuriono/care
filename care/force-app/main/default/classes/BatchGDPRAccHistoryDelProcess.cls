global class BatchGDPRAccHistoryDelProcess implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    GDPR_Settings__mdt rtbfSettings;
    global BatchGDPRAccHistoryDelProcess() {
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global BatchGDPRAccHistoryDelProcess(boolean isTestingContext) {
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query =  'SELECT ID,ACCOUNTID from AccountHistory where Account.GDPR_Request__c=\'RTBF Anonymize\' ';
        if(isTestingContext)
        {
            query =  'SELECT ID,ACCOUNTID from AccountHistory where Account.GDPR_Request__c=\'RTBF Anonymize\' LIMIT 200 ';
        }
        System.debug('GDPR Feed Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    /**
    * Schedulable method, execute the schedule apex job
    */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this,Integer.valueOf(rtbfSettings.Feed_Data_Batch_Size__c));
    }
    global void execute(Database.BatchableContext bc, List<AccountHistory> accHistoryList)
    {
        if(accHistoryList.size()>0) {
            delete accHistoryList;Database.emptyRecycleBin(accHistoryList);
        } 
    }
    global void finish(Database.BatchableContext bc){
    }
}