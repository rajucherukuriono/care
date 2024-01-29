global class BatchUserPasswordNotifierSchedule implements Schedulable {

   global void execute(SchedulableContext ctx) {
      BatchUserPasswordNotifier bat=new BatchUserPasswordNotifier(90,10,False);
     // if(!Test.isRunningTest()){ 
      Database.executeBatch(bat);
  // }
   }
}