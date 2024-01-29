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
@isTest(SeeAllData=false)
private class Test_CCPADeletionRequestProcess
{
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest19() 
    {
        Test.startTest();
        //BatchProcessCCPADeletionRequestPRData obj=new BatchProcessCCPADeletionRequestPRData();
        BatchProcessCCPADeletionRequestPRData.dummyCoverageMethod();
        BatchProcessCCPADeletionRequestData.dummyCoverageMethod();
        ProcessCCPADeletionInstantRequest.dummyCoverageMethod(); 
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
        insert c1;
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-2));
        insert new List<case>{c2};
            Case c3=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-1));
        insert new List<case>{c3};
            update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest191() 
    {
        Test.startTest();
        //BatchProcessCCPADeletionRequestPRData obj=new BatchProcessCCPADeletionRequestPRData();
        BatchProcessCCPADeletionRequestPRData.dummyCoverageMethod();
        BatchProcessCCPADeletionRequestData.dummyCoverageMethod();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Queued - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
        insert c1;
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-2));
        insert new List<case>{c2};
            Case c3=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-1));
        insert new List<case>{c3};
            update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest16() 
    {
        Test.startTest();
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today().addYears(1);
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest17() 
    {
        Test.startTest();
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(-1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        /*
String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
insert a;
Map<id,String> caseRecTypes=new Map<id,String>();
Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
insert new List<case>{c1,c2};
*/
        update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest18() 
    {
        Test.startTest();
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today();
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest1() 
    {
        Test.startTest();
        ProcessCCPADeletionInstantRequest obj=new ProcessCCPADeletionInstantRequest();
        //obj.setFromBatch(obj.getFromBatch());
        obj.isDeclinedReasonSetBySalesforcePlatform('Completed - Success');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Privacy_Request__c prObj3=new Privacy_Request__c();
        prObj3.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj3.Source_System__c='US Platform';
        prObj3.Request_Type__c='Delete Data';
        prObj3.Universal_Member_Id__c='100001';
        prObj3.Request_Date__c=System.today();
        prObj3.Fulfillment_Date__c=System.today().addYears(1);
        prObj3.Name__c='prObj31';
        prObj3.Email__c='test@gmail.com';
        insert prObj3;
        Privacy_Request__c prObj2=new Privacy_Request__c();
        prObj2.Request_Status__c='Request Accepted';
        prObj2.Source_System__c='US Platform';
        prObj2.Request_Type__c='Delete Data';
        prObj2.Universal_Member_Id__c='100001';
        prObj2.Request_Date__c=System.today();
        prObj2.Fulfillment_Date__c=System.today().addYears(1);
        prObj2.Name__c='prObj2';
        prObj2.Email__c='test@gmail.com';
        insert prObj2;update prObj2;
        //insert new List<Privacy_Request__c> {prObj1,prObj2};
        //update new List<Privacy_Request__c> {prObj1,prObj2};
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest7() 
    {
        Test.startTest();
        ProcessCCPADeletionInstantRequest obj=new ProcessCCPADeletionInstantRequest();
        obj.setFromBatch(obj.getFromBatch());
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Privacy_Request__c prObj4=new Privacy_Request__c();
        prObj4.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj4.Source_System__c='US Platform';
        prObj4.Request_Type__c='Delete Data';
        prObj4.Universal_Member_Id__c='100001';
        prObj4.Request_Date__c=System.today();
        prObj4.Fulfillment_Date__c=System.today().addYears(1);
        prObj4.Name__c='prObj41';
        prObj4.Email__c='test@gmail.com';
        insert prObj4;
        Privacy_Request__c prObj3=new Privacy_Request__c();
        prObj3.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj3.Source_System__c='US Platform';
        prObj3.Request_Type__c='Delete Data';
        prObj3.Universal_Member_Id__c='100001';
        prObj3.Request_Date__c=System.today();
        prObj3.Fulfillment_Date__c=System.today().addYears(1);
        prObj3.Name__c='prObj31';
        prObj3.Email__c='test@gmail.com';
        insert prObj3;
        Privacy_Request__c prObj2=new Privacy_Request__c();
        prObj2.Request_Status__c='Request Accepted';
        prObj2.Source_System__c='US Platform';
        prObj2.Request_Type__c='Delete Data';
        prObj2.Universal_Member_Id__c='100001';
        prObj2.Request_Date__c=System.today();
        prObj2.Fulfillment_Date__c=System.today().addYears(1);
        prObj2.Name__c='prObj2';
        prObj2.Email__c='test@gmail.com';
        insert prObj2;update prObj2;
        //insert new List<Privacy_Request__c> {prObj1,prObj2};
        //update new List<Privacy_Request__c> {prObj1,prObj2};
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest2() 
    {
        Test.startTest();
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Completed - Success';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Privacy_Request__c prObj3=new Privacy_Request__c();
        prObj3.Request_Status__c='Completed - Success';
        prObj3.Source_System__c='US Platform';
        prObj3.Request_Type__c='Delete Data';
        prObj3.Universal_Member_Id__c='100001';
        prObj3.Request_Date__c=System.today();
        prObj3.Fulfillment_Date__c=System.today().addYears(1);
        prObj3.Name__c='prObj31';
        prObj3.Email__c='test@gmail.com';
        insert prObj3;
        Privacy_Request__c prObj4=new Privacy_Request__c();
        prObj4.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj4.Source_System__c='US Platform';
        prObj4.Request_Type__c='Delete Data';
        prObj4.Universal_Member_Id__c='100001';
        prObj4.Request_Date__c=System.today();
        prObj4.Fulfillment_Date__c=System.today().addYears(1);
        prObj4.Name__c='prObj41';
        prObj4.Email__c='test@gmail.com';
        insert prObj4;
        Privacy_Request__c prObj5=new Privacy_Request__c();
        prObj5.Request_Status__c='Pending - Soft Decline - Salesforce Platform';
        prObj5.Source_System__c='US Platform';
        prObj5.Request_Type__c='Delete Data';
        prObj5.Universal_Member_Id__c='100001';
        prObj5.Request_Date__c=System.today();
        prObj5.Fulfillment_Date__c=System.today().addYears(1);
        prObj5.Name__c='prObj51';
        prObj5.Email__c='test@gmail.com';
        insert prObj5;
        Privacy_Request__c prObj2=new Privacy_Request__c();
        prObj2.Request_Status__c='Request Accepted';
        prObj2.Source_System__c='US Platform';
        prObj2.Request_Type__c='Delete Data';
        prObj2.Universal_Member_Id__c='100001';
        prObj2.Request_Date__c=System.today();
        prObj2.Fulfillment_Date__c=System.today().addYears(1);
        prObj2.Name__c='prObj2';
        prObj2.Email__c='test@gmail.com';
        insert prObj2;update prObj2;
        //insert new List<Privacy_Request__c> {prObj1,prObj2};
        //update new List<Privacy_Request__c> {prObj1,prObj2};
        Test.stopTest();
    }
    /*@isTest(SeeAllData=false)
    static void testCCPADeletionRequest3() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('NPS'),Status='Closed');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('International NPS'),Status='Closed');
        insert new List<case>{c1,c2};
            update prObj1;
        Test.stopTest();
    } */
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest4() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
        caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
        insert new List<case>{c1,c2};
            update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest15() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today();
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
        caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='New');
        insert new List<case>{c1,c2};
            update prObj1;
        Test.stopTest(); 
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest6() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='New');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='New');
        insert new List<case>{c1,c2};
            update prObj1;
        Test.stopTest(); 
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest5() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Queued - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today();
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        /*
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
        caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed',Reason='CCPA',Secondary_Case_Reason__c='CCPA');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed',Reason='CCPA',Secondary_Case_Reason__c='CCPA');
        insert new List<case>{c1,c2};
        Survey_Feedback__c sf1=new Survey_Feedback__c(Name='SF1',account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(Name='SF2',case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(Name='SF3',account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(Name='SF4',case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(Name='SF2',case__c=c2.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(Name='SF2',case__c=c2.id);
        insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
        */
        //update prObj1;
        Database.executeBatch(new BatchProcessCCPADeletionRequestData(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest8() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(-1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED');
        insert c1;
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED');
        insert new List<case>{c2};
            update prObj1;
        Test.stopTest();
    }
    /*@isTest(SeeAllData=false)
    static void testCCPADeletionRequest9() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Queued - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(2);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('NPS'),Status='Closed');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('International NPS'),Status='Closed');
        insert new List<case>{c1,c2};
            //update prObj1;
            Database.executeBatch(new BatchProcessCCPADeletionRequestData(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest10() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Queued - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today();
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('NPS'),Status='Closed');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('International NPS'),Status='Closed');
        insert new List<case>{c1,c2};
            //update prObj1;
            Database.executeBatch(new BatchProcessCCPADeletionRequestData(true));
        Test.stopTest();
    } 
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest11() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Queued - Salesforce Platform';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(-2);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('NPS'),Status='Closed');
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('International NPS'),Status='Closed');
        insert new List<case>{c1,c2};
            //update prObj1;
            Database.executeBatch(new BatchProcessCCPADeletionRequestData(true));
        Test.stopTest();
    }*/
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest12() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
        caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
        id qLegalEscalations=[select id from group where DeveloperName='Q_Legal_Escalations'].id;
        System.debug('qLegalEscalations==========================================>:'+qLegalEscalations);
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed', Description='Test Description', Legal_Case_Type__c='Other', Safety_Notes__c='Test Description' ,ownerId=qLegalEscalations,Reason='CCPA',Secondary_Case_Reason__c='CCPA' );
        c1.Contact_Theme__c='Safety';
        c1.Contact_Reason__c = 'Safety Communication';
        c1.Contact_Secondary_Reason__c = 'Other';
        c1.Sentiment__c='Positive';
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed',Description='Test Description', Legal_Case_Type__c='Other', Safety_Notes__c='Test Description',ownerId=qLegalEscalations,Reason='CCPA',Secondary_Case_Reason__c='CCPA');
        c2.Contact_Theme__c='Safety';
        c2.Contact_Reason__c = 'Safety Communication';
        c2.Contact_Secondary_Reason__c = 'Other';
        c2.Sentiment__c='Positive';
        insert new List<case>{c1,c2};
            update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest13() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Access Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Privacy_Request__c prObj2=new Privacy_Request__c();
        prObj2.Request_Status__c='Queued - Salesforce Platform';
        prObj2.Source_System__c='US Platform';
        prObj2.Request_Type__c='Delete Data';
        prObj2.Universal_Member_Id__c='100001';
        prObj2.Request_Date__c=System.today();
        prObj2.Fulfillment_Date__c=System.today();
        prObj2.Name__c='prObj21';
        prObj2.Email__c='test@gmail.com';
        insert prObj2;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Standard'),'Standard');
        caseRecTypeNameIdMap.put('Standard',getRecordTypesStatic.recordTypeNameIdMap.get('Standard'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed',Reason='CCPA',Secondary_Case_Reason__c='CCPA');
        c1.Contact_Theme__c='Safety';
        c1.Contact_Reason__c = 'Safety Communication';
        c1.Contact_Secondary_Reason__c = 'Other';
        c1.Sentiment__c='Positive';
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Standard'),Status='Closed',Reason='CCPA',Secondary_Case_Reason__c='CCPA');
        c2.Contact_Theme__c='Safety';
        c2.Contact_Reason__c = 'Safety Communication';
        c2.Contact_Secondary_Reason__c = 'Other';
        c2.Sentiment__c='Positive';
        insert new List<case>{c1,c2};
            //update prObj1;
            Database.executeBatch(new BatchProcessCCPADeletionRequestData(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCCPADeletionRequest14() 
    {
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
        Privacy_Request__c prObj1=new Privacy_Request__c();
        prObj1.Request_Status__c='Request Accepted';
        prObj1.Source_System__c='US Platform';
        prObj1.Request_Type__c='Delete Data';
        prObj1.Universal_Member_Id__c='100001';
        prObj1.Request_Date__c=System.today();
        prObj1.Fulfillment_Date__c=System.today().addYears(-1);
        prObj1.Name__c='prObj11';
        prObj1.Email__c='test@gmail.com';
        insert prObj1;
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,MemberId__pc=100001,personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Map<id,String> caseRecTypes=new Map<id,String>();
        Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
        caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
        Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='Auto Closed');
        insert c1;
        Case c2=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='Auto Closed');
        insert new List<case>{c2};
            update prObj1;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testAvoidRecursion()
    {
        Test.startTest();
        AvoidRecursion.runOnce();
        AvoidRecursion.runOnceRequestData1();
        AvoidRecursion.runOnceRetention1();
        AvoidRecursion.runOnceGdpr1();
        AvoidRecursion.runOnceTask1();
        AvoidRecursion.runOnceEvent1();
        AvoidRecursion.runOnceEmailMessage1();
        AvoidRecursion.runOnceCase3();
        AvoidRecursion.runOnceCase2();
        AvoidRecursion.runOnceCase1();
        AvoidRecursion.runOnceCaseComment1();
        AvoidRecursion.runOnceCCPADeletion1();
        Test.stopTest();
    }
}