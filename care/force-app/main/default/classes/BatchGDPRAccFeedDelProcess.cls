global class BatchGDPRAccFeedDelProcess implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    GDPR_Settings__mdt rtbfSettings;
    global BatchGDPRAccFeedDelProcess(){
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,History_Data_Batch_Size__c,Feed_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global BatchGDPRAccFeedDelProcess(boolean isTestingContext) {
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,History_Data_Batch_Size__c,Feed_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query =  'SELECT ID,PARENTID,body from AccountFeed where Parent.GDPR_Request__c=\'RTBF Anonymize\'';
        if(isTestingContext){
            query =  'SELECT ID,PARENTID,body from AccountFeed where Parent.GDPR_Request__c=\'RTBF Anonymize\' LIMIT 200 ';
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
    global void execute(Database.BatchableContext bc, List<AccountFeed> accFeedList)
    {
        //if(accFeedList.size()>0)       {delete accFeedList;Database.emptyRecycleBin(accFeedList); } 
        List<AccountFeed> accFeedDelList=new  List<AccountFeed>();
        for(AccountFeed accFeedObj: accFeedList)
        {
            System.debug('accFeedObj.Body===============>:'+accFeedObj.Body);
            //System.debug('accFeedObj.Body==>:'+String.valueOf(accFeedObj.Body+String.valueOf(accFeedObj.Body==null?'':accFeedObj.Body).contains('Account is successfully processed for '));
            if(accFeedObj.Body==null || (accFeedObj.Body!=null && !String.valueOf(accFeedObj.Body).contains('Account is successfully processed for ')))
            {
                accFeedDelList.add(accFeedObj);
            }
        }
        if(accFeedDelList.size()>0){
            delete accFeedDelList;Database.emptyRecycleBin(accFeedDelList); 
        } 
    }
    global void finish(Database.BatchableContext bc){
    }
}