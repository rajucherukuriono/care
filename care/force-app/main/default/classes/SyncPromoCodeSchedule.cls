global class SyncPromoCodeSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        /*SyncPromoCodeBatch myBatch = new SyncPromoCodeBatch();
            ID batchprocessid = Database.executeBatch(myBatch);
            System.debug('*****Returned batch process ID: ' + batchProcessId);
        */ 
        //Commented as part of SFORCE-3680
    }
}