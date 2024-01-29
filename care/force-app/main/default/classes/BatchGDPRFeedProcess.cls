global class BatchGDPRFeedProcess implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    String runState;
    List<id> caseList;
    GDPR_Settings__mdt rtbfSettings;
    global BatchGDPRFeedProcess() {
        //this.isTestingContext=isTestingContext;
    }
    global BatchGDPRFeedProcess(boolean isTestingContext,List<id> caseList) {
        this.caseList=caseList;
        this.isTestingContext=isTestingContext;
        rtbfSettings=[select id,DeveloperName,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query =  'SELECT ID,PARENTID FROM caseFeed WHERE parentId=:caseList';
        if(isTestingContext)
        {
            query =  'SELECT ID,PARENTID FROM caseFeed WHERE parentId=:caseList LIMIT 200';
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
    global void execute(Database.BatchableContext bc, List<CaseFeed> caseFeedList)
    {
        if(caseFeedList.size()>0) {
            delete caseFeedList;Database.emptyRecycleBin(caseFeedList); 
        } 
    }
    global void finish(Database.BatchableContext bc){
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second() ); 
        BatchGDPRHistoryProcess batchObj=new BatchGDPRHistoryProcess(false,caseList);
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<CronTrigger> cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='Process GDPR History Data'];
        if(cronObj.size()>0)
            System.abortJob(cronObj[0].id);
        cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='Process GDPR History Data'];
        if(cronObj.size()==0)
            system.schedule('Process GDPR History Data',nextFireTime,batchObj); 
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