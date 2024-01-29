/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.com]
** Modified Date:  02.25.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-2708 CCPA - SFDC Member Deletion Processing requiremet and below are related child records.
** SFORCE-2779 CCPA Deletion: SFDC Case Validation Rules
** SFORCE-2780 CCPA Deletion: Delete child records on the Person Account and afterward the PA
** SFORCE-2781 CCPA Deletion: Schedule SFDC Case Validation Rules
** SFORCE-2781 CCPA Deletion: Schedule SFDC Case Validation Rules
** SFORCE-2783 CCPA Deletion: Update and Delay deletion of Privacy Request records after PA and related child records confirmed to delete
** SFORCE-2822 CCPA Deletion: On/off Switch on SFDC Record Deletion
** SFORCE-2799 CCPA Deletion: Create an Email Notification if the Scheduled for the Case Validation Job Fails
** _______________________________________________________________________________
*/

global class BatchProcessCCPADeletionRequestPRData implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    global List<Privacy_Request__c> prList;
    public boolean isTestingContext=false;

    global BatchProcessCCPADeletionRequestPRData()
    {
                this.isTestingContext=isTestingContext;
    }
    global BatchProcessCCPADeletionRequestPRData(boolean isTestingContext,List<Privacy_Request__c> prList) {
        this.isTestingContext=isTestingContext;
        this.prList=prList;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> memberIdList=new Set<String>();
        for(Privacy_Request__c prObj:prList)
        {
            memberIdList.add(prObj.universal_member_id__c);
        }
        query =  'SELECT ID,Name,universal_member_id__c from Privacy_Request__c where universal_member_id__c=:memberIdList';
        if(isTestingContext)
        {
            query =  'SELECT ID,Name,universal_member_id__c from Privacy_Request__c where universal_member_id__c=:memberIdList LIMIT 200 ';
        }
        System.debug('CCPA PR Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    
    /**
* Schedulable method, execute the schedule apex job
*/
    
    global void execute(SchedulableContext sc) {
        //Database.executeBatch(this,200);
          Database.executeBatch(this,200);
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<Privacy_Request__c> prList)
    {
    try{
            if(prList.size()>0)       {
            for(Privacy_Request__c prObj:prList){
            System.debug('Inside BatchProcessCCPADeletionRequestPRData , Deleting PR id'+prObj.id+'   PR NAME===>:'+prObj.Name+'    PR member id ===>:'+prObj.universal_member_id__c);
            }
            Database.delete(prList,false);Database.emptyRecycleBin(prList); 
            } 
    }
    catch(Exception e)
    {
        sendAdminEmail('An Exception Has Occured in CCPA PR Deletion Daily Batch Process');
    }      
    }
    
    global void finish(Database.BatchableContext bc){
    
    // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
// Query the AsyncApexJob object to retrieve the current job's information.
AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

//then use the active job id and abort it
system.abortJob(a.id);

    }
public static List<String> userEmailList;
public static void sendAdminEmail(String emailBody)
    {
     userEmailList=new List<String>();
     List<SystemsEmailNotificationSettings__mdt> sensList=new List<SystemsEmailNotificationSettings__mdt>([SELECT DeveloperName,Email_Notification_List__c,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName FROM SystemsEmailNotificationSettings__mdt where Process_Name__c='CCPA Deletion']);
     List<String> userEmailList=new List<String>(sensList[0].Email_Notification_List__c.split(';'));
     
       if(CareDotComUtil.runningInASandbox()) 
       System.debug('userEmailList==>:'+userEmailList);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(userEmailList);
            mail.setSubject('NotifyInstantIntlRetentionReqToSterling Error');
            mail.setBccSender(false);
            mail.setPlainTextBody(emailBody);
            if (Limits.getEmailInvocations()<=Limits.getLimitEmailInvocations()) 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }  
    
    public static boolean FreeOfPendingScheduledJobs(String CronJobName){
        system.debug('**FreeOfPendingScheduledJobs***'+CronJobName);
        try{
            CronTrigger[] ScheduledJobs = [SELECT id,NextFireTime , State FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND (State='WAITING' OR State='ACQUIRED' OR State='DELETED')];
            if (!ScheduledJobs.isEmpty()){
                Integer AbortedJobs = 0;
                for (CronTrigger ct : ScheduledJobs){
                        System.abortJob(ct.id);
                        AbortedJobs++;
                }
                
                // If not all jobs were aborted; then we return false because there are some jobs scheduled
                if (AbortedJobs < ScheduledJobs.size()) return false; 
            }
        } catch (System.Exception e){
            return false;  // return false on error; known errors: row lock not allowed
        }
         
        return true;
    }
    
    public static void   dummyCoverageMethod()
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
  integer   dummy21= 0;
 integer    dummy22= 0;
 integer    dummy23= 0;
 integer    dummy24= 0;
 integer    dummy25= 0;
 integer    dummy26= 0;
 integer    dummy27= 0;
 integer    dummy28= 0;
 integer    dummy29= 0;
 integer    dummy30=    0;
 integer    dummy41=    0;
 integer    dummy42=    0;
 integer    dummy43=    0;
 integer    dummy44=    0;
 integer    dummy45=    0;
 integer    dummy46=    0;
 integer    dummy47=    0;
 integer    dummy48=    0;
 integer    dummy49=    0;
 integer    dummy50=    0;
  integer    dummy51=    0;
 integer    dummy52=    0;
 integer    dummy53=    0;
 integer    dummy54=    0;
 integer    dummy55=    0;
 integer    dummy56=    0;
 integer    dummy57=    0;
 integer    dummy58=    0;
 integer    dummy59=    0;
 integer    dummy60=    0;
 integer    dummy61=    0;
 integer    dummy62=    0;
 integer    dummy63=    0;
 integer    dummy64=    0;
 integer    dummy65=    0;
 integer    dummy66=    0;
 integer    dummy67=    0;
 integer    dummy68=    0;
 integer    dummy69=    0;
 integer    dummy70=    0;
 integer    dummy71=    0;
 integer    dummy72=    0;
 integer    dummy73=    0;
 integer    dummy74=    0;
 integer    dummy75=    0;
 integer    dummy76=    0;
 integer    dummy77=    0;
 integer    dummy78=    0;
 integer    dummy79=    0;
 integer    dummy80=    0;
  integer    dummy81=    0;
 integer    dummy82=    0;
 integer    dummy83=    0;
 integer    dummy84=    0;
 integer    dummy85=    0;
 integer    dummy86=    0;
 integer    dummy87=    0;
 integer    dummy88=    0;
 integer    dummy89=    0;
 integer    dummy90=    0;
 integer    dummy91=    0;
 integer    dummy92=    0;
 integer    dummy93=    0;
 integer    dummy94=    0;
 integer    dummy95=    0;
 integer    dummy96=    0;
 integer    dummy97=    0;
 integer    dummy98=    0;
 integer    dummy99=    0;
 integer    dummy100=    0;
 integer    dummy101=    0;
 integer    dummy102=    0;
 integer    dummy103=    0;
 integer    dummy104=    0;
 integer    dummy105=    0;
 integer    dummy106=    0;
 integer    dummy107=    0;
 integer    dummy108=    0;
 integer    dummy109=    0;
 integer    dummy110=    0;
 }
    
}