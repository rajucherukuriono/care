global class BatchGDPRHistoryProcess implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    String runState;
    List<id> caseList;
    GDPR_Settings__mdt rtbfSettings;
    global BatchGDPRHistoryProcess() {
        //this.isTestingContext=isTestingContext;
    }
    global BatchGDPRHistoryProcess(boolean isTestingContext,List<id> caseList) {
        this.caseList=caseList;
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query =  'SELECT ID,CASEID FROM CaseHistory WHERE CASEID=:caseList';
        if(isTestingContext)
        {
            query =  'SELECT ID,CASEID FROM CaseHistory WHERE CASEID=:caseList LIMIT 200';
        }
        System.debug('GDPR History Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    /**
    * Schedulable method, execute the schedule apex job
    */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this,Integer.valueOf(rtbfSettings.History_Data_Batch_Size__c));
    }
    global void execute(Database.BatchableContext bc, List<CaseHistory> caseHistoryList)
    {
        system.debug('Deleting '+caseHistoryList.size()+' Number of case history records');
        if(caseHistoryList.size()>0){
            delete caseHistoryList;Database.emptyRecycleBin(caseHistoryList);
        }
    }
    global void finish(Database.BatchableContext bc){
        /*
        Map<id,CaseFeed> caseFeedMap=new Map<id,CaseFeed>([SELECT ID,PARENTID FROM caseFeed WHERE parentId=:secondTimeFeedList]);
        Map<id,CaseHistory> caseHistoryMap=new Map<id,CaseHistory>([SELECT ID,CASEID FROM caseHistory WHERE caseId=:secondTimeFeedList]);
        System.debug('caseFeedMap.size()=====>:After Process 1'+caseFeedMap.size());
        if(caseFeedMap.size()>0)       delete caseFeedMap.values();
        System.debug('caseHistoryMap.size()=====>:After Process  1'+caseHistoryMap.size());
        if(caseHistoryMap.size()>0) delete caseHistoryMap.values();
        */
    }
}