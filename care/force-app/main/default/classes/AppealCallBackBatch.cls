public class AppealCallBackBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> ErrStatus= New Set<String>();
         Errstatus.add('Error:{"message":"Invalid request"}');
         Errstatus.add('Error:{"message":"no appeal found with given case id"}');
        string Q='SELECT ID,CaseNumber,Status,Appeal_Decision__c, Appeal_Decision_Reason__c,Appeal_Free_form_justification__c,LastModifiedDate FROM Case WHERE recordtype.Name=\'Standard\'AND LastModifiedDate =Last_n_days:1 AND Syc_Status_message__c NOT IN:ErrStatus AND Syc_Status_message__c!=\'\' AND Syc_Status_message__c Like \'%Error%\'';
         return Database.getQueryLocator(Q);
   }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
          System.enqueueJob(new AppealCallBackCallout((List<case>)scope)); 
    }

   public void finish(Database.BatchableContext BC){
   }
   
    public void execute(SchedulableContext sc)
    {
      AppealCallBackBatch aCallBatch= new AppealCallBackBatch();
        database.executeBatch(aCallBatch, 1);
    }
     

}