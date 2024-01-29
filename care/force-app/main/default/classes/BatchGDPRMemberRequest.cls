global class BatchGDPRMemberRequest implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    String runState;
    String statusToProcess='';
    public List<id> caseFeedList;
    public GDPR_Settings__mdt rtbfSettings;
    global BatchGDPRMemberRequest() {
        //this.isTestingContext=isTestingContext;
    }
    global BatchGDPRMemberRequest(boolean isTestingContext,String runState,String statusToProcess) {
        this.runState=runState;
        this.statusToProcess=statusToProcess;
        this.isTestingContext=isTestingContext;
        this.rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        query = 'SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c=\''+statusToProcess+'\''+' and Request_Type__c=\''+rtbfSettings.Process_RTBF_Retention_Request_Type__c+'\'';
        if(isTestingContext)
        {
            query = 'SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c=\''+statusToProcess+'\''+' and Request_Type__c=\''+rtbfSettings.Process_RTBF_Retention_Request_Type__c+'\''+' LIMIT 200';
        }
        System.debug('GDPR Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    /**
    * Schedulable method, execute the schedule apex job
    */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this,Integer.valueOf(rtbfSettings.Data_Batch_Size__c));
    }
    global void execute(Database.BatchableContext bc, List<Request_Data__c> gdprList)
    {
        if(caseFeedList==null) caseFeedList=new List<id>();
        ProcessMemberGDPRequest.ProcessMemberGDPRequestData(gdprList,runState,caseFeedList,rtbfSettings);
    }
    global void finish(Database.BatchableContext bc){
        if(runState=='anonymize')
        {                  
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
            //if(Integer.valueOf(ss)<54)   ss=String.valueOf(5+Integer.valueOf(ss));    //ss=String.valueOf(59); 
            BatchGDPRFeedProcess batchObj=new BatchGDPRFeedProcess(false,caseFeedList);
            //parse to cron expression 
            //String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?'; 
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
            List<CronTrigger> cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='Process GDPR Feed Data'];
            if(cronObj.size()>0)
                System.abortJob(cronObj[0].id);
            cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='Process GDPR Feed Data'];
            if(cronObj.size()==0)
                system.schedule('Process GDPR Feed Data',nextFireTime,batchObj);
        }                 
    }
}