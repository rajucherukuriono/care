//Modified by By: Mohammed Ashwaq
//Modified Date: 10/11/2020
//Test class for: BatchGDPRAccFeedHistDelProcess
@isTest(SeeAllData = true)
private class Test_BatchGDPRAccFeedHistDelProcessSADT {
    Public static String intlPvdr = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    Public static String intlSeeker = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    Public static String day = String.valueOf(Datetime.now().day());
    Public static String month = String.valueOf(Datetime.now().month());
    Public static String year = String.valueOf(Datetime.now().year());
    Public static String hour = String.valueOf(Datetime.now().hour());
    Public static String min = String.valueOf(Datetime.now().minute() <= 58 ? Datetime.now().minute() + 1 : Datetime.now().minute());
    Public static String ss = String.valueOf(Datetime.now().second());
    Public static String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ' + '?  ' + year;
    @isTest(SeeAllData = true)
    static void test5() {
        Test.startTest();
        Account a = new Account(lastname = 'Test', Gdpr_request__c = 'RTBF Anonymize', recordtypeid = intlSeeker, Global_Member_Id__c = '123456781');
        Account a1 = new Account(lastname = 'Test', Gdpr_request__c = 'RTBF Anonymize', recordtypeid = intlSeeker, Global_Member_Id__c = '1234567891');
        insert new List < Account > {a,a1};
        a.lastname = 'Test1';
        update new List < Account > {a,a1};
        AccountHistory ah = new AccountHistory(accountid = a.id);
        Request_Data__c gdprObj = new Request_Data__c(Status__c = 'New', Request_Type__c = 'RTBF Anonymize', Global_Member_Id__c = '123456781');
        Request_Data__c gdprObj1 = new Request_Data__c(Status__c = 'New', Request_Type__c = 'RTBF Anonymize', Global_Member_Id__c = '1234567891');
        upsert new List < Request_Data__c > { gdprObj, gdprObj1};
        List < Id > caseFeedList;
        GDPR_Settings__mdt rtbfSettings = [select id, DeveloperName, Process_RTBF_Retention_Request_Type__c, MasterLabel, Data_Batch_Size__c, Feed_Data_Batch_Size__c, History_Data_Batch_Size__c, Override_Account_Record_Type__c, Override_Employer_Program__c, Override_Premium__c, Override_Safety_Case__c, RTBF_Retention__c, Schedule_Mode__c, Status_To_Process__c, Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c = 'RTBF'];
        List < Request_Data__c > gdprList = new List < Request_Data__c > {gdprObj, gdprObj1};
        BatchGDPRAccFeedDelProcess btch = new BatchGDPRAccFeedDelProcess();
        //Database.executeBatch(new BatchGDPRAccHistoryDelProcess(true));
        List<CronTrigger> cronObj=[SELECT id FROM CronTrigger where CronJobDetail.name='Process GdprHistory Schedule'];
        if(cronObj.size()>0){
            System.abortJob(cronObj[0].id);
        }
        else{
            System.schedule('Process GdprHistory Schedule', nextFireTime, new BatchGDPRAccFeedDelProcess(true));
        }
        Test.stopTest();
    }
    @isTest(SeeAllData = true)
    static void test4() {
        Test.startTest();
        Account a = new Account(lastname = 'Test', Gdpr_request__c = 'Retention', recordtypeid = intlSeeker, Global_Member_Id__c = '12345678', Type__pc = 'Premium');
        insert a;
        a.lastname = 'Test1';
        update a;
        AccountHistory ah = new AccountHistory(accountid = a.id);
        //insert ah;
        Request_Data__c gdprObj = new Request_Data__c(Request_Type__c = 'Retention', Status__c = 'New', Global_Member_Id__c = '12345678');
        System.assert(gdprObj.Global_Member_Id__c == a.Global_Member_Id__c);
        upsert gdprObj;
        Test.stopTest();
    }
    @isTest(SeeAllData = true)
    static void test3() {
        Test.startTest();
        Account a = new Account(lastname = 'Test', Gdpr_request__c = 'RTBF Override', recordtypeid = intlSeeker, Global_Member_Id__c = '12345678', Type__pc = 'Premium');
        insert a;
        a.lastname = 'Test1';
        update a;
        AccountHistory ah = new AccountHistory(accountid = null);
        Request_Data__c gdprObj = new Request_Data__c(Request_Type__c = 'RTBF Fix', Status__c = 'New', Global_Member_Id__c = '12345678');
        System.assert(gdprObj.Global_Member_Id__c == a.Global_Member_Id__c);
        upsert gdprObj;
        gdprObj.Request_Type__c = 'RTBF Override';
        update gdprObj;
        Test.stopTest();
    }
    @isTest(SeeAllData = true)
    static void test2() {
        Test.startTest();
        Account a = new Account(lastname = 'Test', Gdpr_request__c = 'RTBF Do Not Process', recordtypeid = intlSeeker, Global_Member_Id__c = '12345678', Type__pc = 'Premium');
        insert a;
        a.lastname = 'Test1';
        update a;
        AccountHistory ah = new AccountHistory(accountid = a.id);
        //insert ah;
        Request_Data__c gdprObj = new Request_Data__c(Request_Type__c = 'RTBF Do Not Process', Status__c = 'New', Global_Member_Id__c = '12345678');
        System.assert(gdprObj.Global_Member_Id__c == a.Global_Member_Id__c);
        upsert gdprObj;
        gdprObj.Request_Type__c = 'RTBF Do Not Process';
        gdprObj.status__c = 'RTBF Do Not Process';
        gdprObj.Response_Date__c = Datetime.now().date();
        update gdprObj;
        Test.stopTest();
    }
}