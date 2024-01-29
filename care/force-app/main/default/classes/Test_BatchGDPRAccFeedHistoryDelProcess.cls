//Last Modified by : Mohamme Ashwaq
//Last modified Date: 10/12/2020
@isTest(SeeAllData=false)
private class Test_BatchGDPRAccFeedHistoryDelProcess{
    Public static String intlCall = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    Public static String intlEmail = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    Public static String intlSafety = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
    Public static String intlSocial = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
    Public static String intlSeeker = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    Public static String intlProvider= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    @isTest(SeeAllData=false)
    static void test1() 
    {
        Test.startTest();
        //BatchGDPRAccHistoryDelProcess.dummyCoverageMethod();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlProvider,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        BatchGDPRAccHistoryDelProcess btchF = new BatchGDPRAccHistoryDelProcess();        
        Database.executeBatch(new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test2() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        BatchGDPRAccHistoryDelProcess btchF = new BatchGDPRAccHistoryDelProcess();
        Database.executeBatch(new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test3() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        System.schedule('Process GdprHistory Schedule','0 0 23 * * ?',new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test4() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        //Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='New',Global_Member_Id__c='12345678');
        //System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        System.schedule('Process GdprFeed Schedule','0 0 23 * * ?',new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test6() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlProvider,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        insert new List<case>{c1,c2,c3,c4,c5,c6};
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        //BatchGDPRMemberRequest batchObj=new BatchGDPRMemberRequest(true,'anonymize','New');
        //Database.executeBatch(batchObj,20);
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        //ProcessMemberGDPRequest.ProcessMemberGDPRequestData(gdprList,'anonymize',caseFeedList,rtbfSettings);
            //Database.executeBatch(new BatchGDPRAccHistoryDelProcess(true));
            //public static void ProcessMemberGDPRequestData(List<Request_Data__c > gdpReqListParam,String runStateStr,List<id> secondTimeFeedListParam,GDPR_Settings__mdt rtbfSettingsParam)
            //system.schedule('Process GDPR Data',nextFireTime,batchObj); 
            //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
            //List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('sridhar.neeli@care.com')];
            //System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
            //ProcessGDPRCount.processGDPRCount('sridhar.neeli@care.com,raju.cherukuri@care.com');
            //ProcessGDPRData.processGDPRInfo('anonymize');
            Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test7() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        insert new List<case>{c1,c2,c3,c4,c5,c6};
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        BatchGDPRMemberRequest batchObj=new BatchGDPRMemberRequest(true,'anonymize','New');
        Database.executeBatch(batchObj,20);
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        Database.executeBatch(new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test8() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        //Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='New',Global_Member_Id__c='12345678');
        //System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
        system.debug('Request Data query==================>:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c ]);
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        insert new List<case>{c1,c2,c3,c4,c5,c6};
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        //BatchGDPRMemberRequest batchObj=new BatchGDPRMemberRequest(true,'anonymize','New');
        //Database.executeBatch(batchObj,20);
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        System.schedule('Process GdprHistory Schedule','0 0 23 * * ?',new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test9() 
    {
        Test.startTest();
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        Account a1=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='123456789');
        insert new List<Account>{a,a1};
        a.lastname='Test1';
        update new List<Account>{a,a1};
        System.debug('Acc Query:'+[SELECT Account_ID__c,Request_Type__c,Global_Member_ID__c,Id,Name,Response_Date__c,Status__c,Validation_Status__c FROM Request_Data__c where Status__c='New' and Request_Type__c='RTBF' LIMIT 200]);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        //Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='New',Global_Member_Id__c='12345678');
        //System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='12345678');
        Request_Data__c  gdprObj1=new Request_Data__c (Status__c='New',Request_Type__c='RTBF',Global_Member_Id__c='123456789');
        upsert new List<Request_Data__c>{gdprObj,gdprObj1};
            
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        insert new List<case>{c1,c2,c3,c4,c5,c6};
        
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
        
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
        List<Request_Data__c> gdprList=new List<Request_Data__c>{gdprObj,gdprObj1};
        System.schedule('Process GdprFeed Schedule','0 0 23 * * ?',new BatchGDPRAccHistoryDelProcess(true));
        Test.stopTest();
    }
}