@isTest(SeeAllData=false)
public class BatchUserPasswordNotifierScheduleTest {
    
    public static testMethod void testschedule() {
      Test.StartTest();
       BatchUserPasswordNotifierSchedule sh1 = new BatchUserPasswordNotifierSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        BatchUserPasswordNotifier bat=new BatchUserPasswordNotifier(90,88,False);
        Database.executeBatch(bat);
      Test.stopTest();
        
    }

    
}