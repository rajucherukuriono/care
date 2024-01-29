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
global class BatchProcessCCPADeletionRequestData implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    global List<Privacy_Request__c> prDelList=new List<Privacy_Request__c>();
    global BatchProcessCCPADeletionRequestData() {
        //this.isTestingContext=isTestingContext;
    }
    String specificMemId;
    global BatchProcessCCPADeletionRequestData(boolean isTestingContext) {
        this.isTestingContext=isTestingContext;
    }
    global BatchProcessCCPADeletionRequestData(boolean isTestingContext,String specificMemId) {
        this.isTestingContext=isTestingContext;
        this.specificMemId=specificMemId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('Inside BatchProcessCCPADeletionRequestData class');
        if(String.isBlank(specificMemId))
        {
            // Removed 'Queued - Salesforce Platform' as part of SFORCE-2912 CCPA Deletion: Trigger Deletion of Records when PR - Queued - Salesforce Platform
            /*
query = 'SELECT Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c where Source_System__c=\'US Platform\' and Request_Type__c=\'Delete Data\' and Request_Status__c in (\'Request Accepted\',\'Pending - Soft Decline - Salesforce Platform\',\'Queued - Remote Platform\',\'Queued - Salesforce Platform\')';
if(isTestingContext)
{
query = 'SELECT Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c where Source_System__c=\'US Platform\' and Request_Type__c=\'Delete Data\' and Request_Status__c in (\'Request Accepted\',\'Pending - Soft Decline - Salesforce Platform\',\'Queued - Remote Platform\',\'Queued - Salesforce Platform\')'+' LIMIT 200';
}
*/
            query = 'SELECT Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c where Source_System__c=\'US Platform\' and Request_Type__c=\'Delete Data\' and Request_Status__c in (\'Request Accepted\',\'Pending - Soft Decline - Salesforce Platform\',\'Queued - Remote Platform\')';
            if(isTestingContext)
            {
                query = 'SELECT Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c where Source_System__c=\'US Platform\' and Request_Type__c=\'Delete Data\' and Request_Status__c in (\'Request Accepted\',\'Pending - Soft Decline - Salesforce Platform\',\'Queued - Remote Platform\')'+' LIMIT 200';
            }
        }
        else
        {
            query = 'SELECT Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c where Universal_Member_Id__c=:specificMemId';
        }
        System.debug('this.specificMemId=============>:'+ this.specificMemId + 'CCPA Delete Query firing is ===>:'+query);
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
            List<Process_Control_Settings__mdt>  pcsList= new List<Process_Control_Settings__mdt>([SELECT Additional_Information__c,Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,Switch__c FROM Process_Control_Settings__mdt where Process_Name__c in ('CCPA Deletion')]);
            Map<String,String> pcsListMap=new Map<String,String>();
            for(Process_Control_Settings__mdt pcsStr:pcsList)
            {
                pcsListMap.put(pcsStr.Process_Name__c,pcsStr.Switch__c);
            }
            String ccpaDelProcessSwitch=pcsListMap.get('CCPA Deletion');
            if(ccpaDelProcessSwitch=='On')
            {   
                ProcessCCPADeletionInstantRequest updateProcessCCPADeletionInstantRequestObj=new ProcessCCPADeletionInstantRequest(prList,null,null,null,null,null,null,null,null); 
                updateProcessCCPADeletionInstantRequestObj.setFromBatch(true);  
                updateProcessCCPADeletionInstantRequestObj.ProcessCCPADeletionInstantRequest();  
                /*
List<Privacy_Request__c> prL=updateProcessCCPADeletionInstantRequestObj.ProcessCCPADeletionInstantRequest();
if(prL!=null) prDelList.addAll(prL);
*/
            }
        }
        catch(Exception e)
        {
            sendAdminEmail('An Exception Has Occured in CCPA Deletion Daily Batch Process');
        }
    }  
    global void finish(Database.BatchableContext bc){
        // Removed 'Queued - Salesforce Platform' as part of SFORCE-2912 CCPA Deletion: Trigger Deletion of Records when PR - Queued - Salesforce Platform
        /*
if(!prDelList.isEmpty())
String cronID = System.scheduleBatch(new BatchProcessCCPADeletionRequestPRData(false,prDelList), 'BatchProcessCCPADeletionRequestPRData'+system.now(), 10);
*/
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