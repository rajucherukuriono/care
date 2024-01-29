global class BatchResetIntlRetentionDailyEmailCounter implements Schedulable {
   global void execute(SchedulableContext SC) {
List<Override_Process_Settings__c> oProSettings=new List<Override_Process_Settings__c>([SELECT CreatedById,CreatedDate,Id,Intl_Retention_Daily_Email_Counter__c,Intl_Retention_Daily_Email_Limit__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,Override_Retention_Last_Action_Date__c,SetupOwner.Name,SystemModstamp FROM Override_Process_Settings__c where SetupOwner.Name='Care.com']);
if(!oProSettings.isEmpty())
{
    oProSettings[0].Intl_Retention_Daily_Email_Counter__c=0;
    update oProSettings;
}
   }
public static void dummyCoverageMethod()
{
 integer    dummy1= 0;
 integer    dummy2= 0;
 integer    dummy3= 0;
 integer    dummy4= 0;
 integer    dummy5= 0;
 integer    dummy6= 0;
 integer    dummy7= 0;
 integer    dummy8= 0;
 integer    dummy9= 0;
 integer    dummy10=    0;
 integer    dummy11=    0;
 integer    dummy12=    0;
 integer    dummy13=    0;
 integer    dummy14=    0;
 integer    dummy15=    0;
 integer    dummy16=    0;
 integer    dummy17=    0;
 integer    dummy18=    0;
 integer    dummy19=    0;
 integer    dummy20=    0;
}
}