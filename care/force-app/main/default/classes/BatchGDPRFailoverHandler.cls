global class BatchGDPRFailoverHandler implements Schedulable {
    /**
    * Schedulable method, execute the schedule apex job
    */
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new GDPRFailoverHandler(false));
    }
}