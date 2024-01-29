@isTest(SeeAllData=false)
public class BatchUserPasswordNotifierTest{

@isTest(SeeAllData=false)
public static void test() 
{

Test.startTest();
    Database.executeBatch(new BatchUserPasswordNotifier(90,80,true));
    
   /* 
    BatchUserPasswordNotifier passwordNotif = new BatchUserPasswordNotifier(90,0);
//This will schedule to run every day at 10:29
string s3 = '29 10 * * * ?';
//system.schedule('Daily Password expire notifier',s3,passwordNotif);
String hour = String.valueOf(Datetime.now().hour());
String min = String.valueOf(Datetime.now().minute()+1 ); String ss = String.valueOf(Datetime.now().second());

//parse to cron expression
String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
system.schedule('Daily Password expire notifier',nextFireTime,passwordNotif);

*/
Test.stopTest();
}

}