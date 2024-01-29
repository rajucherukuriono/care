global class ScheduleCCPAAccessDataGenerateFiles implements Schedulable {
   global void execute(SchedulableContext SC) {
   
   List<AsyncApexJob> accessDataJobs=new List<AsyncApexJob>([SELECT ApexClassId,CompletedDate,CreatedById,CreatedDate,ExtendedStatus,Id,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems FROM AsyncApexJob where apexclass.name='BatchCCPAAccessDataGenerateFiles' and status in ('Holding','Queued','Preparing','Processing')]);
   while(!accessDataJobs.isEmpty())
   {
   for(AsyncApexJob aJob:accessDataJobs){
   System.abortJob(aJob.id);
   }
    accessDataJobs=new List<AsyncApexJob>([SELECT ApexClassId,CompletedDate,CreatedById,CreatedDate,ExtendedStatus,Id,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems FROM AsyncApexJob where apexclass.name='BatchCCPAAccessDataGenerateFiles' and status in ('Holding','Queued','Preparing','Processing')]);
    }
        System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null));
   }
}