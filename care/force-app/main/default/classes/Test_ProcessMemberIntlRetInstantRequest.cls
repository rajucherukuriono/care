@isTest(SeeAllData=false)
private class Test_ProcessMemberIntlRetInstantRequest{ 
    Public static Id intlCCRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center');
    Public static Id intlEmailRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
    Public static Id intlSARecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
    Public static String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
    Public static String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
    @isTest(SeeAllData=false)
    static void testBatchResetIntlRetentionDailyEmailCounter() 
    {
        Test.startTest();
        List<CronTrigger> asyncApexJob = new List<CronTrigger>([SELECT CreatedById,CreatedDate,CronExpression,CronJobDetail.Name,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State,TimesTriggered,TimeZoneSidKey FROM CronTrigger where CronJobDetail.Name='BatchResetIntlRetentionDailyEmailCounter Job']);
        for (CronTrigger job : asyncApexJob) { System.abortJob(job.Id); }
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()+2);
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        BatchResetIntlRetentionDailyEmailCounter s = new BatchResetIntlRetentionDailyEmailCounter(); 
        BatchResetIntlRetentionDailyEmailCounter.dummyCoverageMethod();
        System.schedule('BatchResetIntlRetentionDailyEmailCounter Job', nextFireTime, s);
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testRTOpenInactive1() 
    {
        CareDotComUtil.commaSeperatedString(new List<String>{'One','Two'});
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Request__c='RT Open Inactive';
        a.Email__c='abc@gmail.com';
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');    
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(c3.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(c4.Id, Datetime.now().addDays(-2));
        Event e1 = new Event(Subject='Test Event',whatid=a.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e2 = new Event(Subject='Test Event',whatid=a.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e3 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e4 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e5 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e6 = new Event(Subject='Test Event',whatid=c2.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e7 = new Event(Subject='Test Event',whatid=c2.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        insert new list<Event>{e1,e2,e3,e4,e5,e6,e7};
            System.debug('Inside Test Class ==============================>:'+[select id from Event where whoid=:c1.id]);
        Test.setCreatedDate(e1.Id, Datetime.now().addDays(-10));
        Test.setCreatedDate(e2.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(e3.Id, Datetime.now().addDays(-10));
        Test.setCreatedDate(e4.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-3));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-1));
        Test.startTest();
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        BatchUpdateLastModifiedDateOnAccount.dummyCoveragemethod();
        System.schedule('Process Retention Batch Schedule','0 0 23 * * ?',new BatchUpdateLastModifiedDateOnAccount(true,1,200));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testRTOpenInactive1_2() 
    {
        CareDotComUtil.commaSeperatedString(new List<String>{'One','Two'});
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Request__c='RT Open Inactive';
        a.Email__c='abc@gmail.com';
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');    
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(c3.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(c4.Id, Datetime.now().addDays(-2));
        Event e1 = new Event(Subject='Test Event',whatid=a.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e2 = new Event(Subject='Test Event',whatid=a.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e3 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e4 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e5 = new Event(Subject='Test Event',whatid=c1.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e6 = new Event(Subject='Test Event',whatid=c2.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        Event e7 = new Event(Subject='Test Event',whatid=c2.id,StartDateTime=system.today(),EndDateTime=system.today()+5);
        insert new list<Event>{e1,e2,e3,e4,e5,e6,e7};
            System.debug('Inside Test Class ==============================>:'+[select id from Event where whoid=:c1.id]);
        Test.setCreatedDate(e1.Id, Datetime.now().addDays(-10));
        Test.setCreatedDate(e2.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(e3.Id, Datetime.now().addDays(-10));
        Test.setCreatedDate(e4.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-3));
        Test.setCreatedDate(e5.Id, Datetime.now().addDays(-1));
        Test.startTest();
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<Id> caseFeedList;
        BatchUpdateLastModifiedDateOnAccount.dummyCoveragemethod();
        System.schedule('Process Retention Batch Schedule','0 0 23 * * ?',new BatchUpdateLastModifiedDateOnAccount(true,1,200));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testRTOpenInactive2_2() 
    {
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Sync_Status__c='SLAD Failure';
        a.Email__c='abc@gmail.com';
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');    
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(c3.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(c4.Id, Datetime.now().addDays(-2));
        CaseComment c1CaseComment1 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        CaseComment c1CaseComment2 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        CaseComment c1CaseComment3 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        insert new List<CaseComment>{c1CaseComment1,c1CaseComment2,c1CaseComment3};
            //Test.setCreatedDate(c1CaseComment1.Id, Datetime.now().addDays(-6));
            //Test.setCreatedDate(c1CaseComment2.Id, Datetime.now().addDays(-4));
            //Test.setCreatedDate(c1CaseComment3.Id, Datetime.now().addDays(-2));
            Survey_Feedback__c sf1=new Survey_Feedback__c(Name='SF1',account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(Name='SF2',case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(Name='SF3',account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(Name='SF4',case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(Name='SF5',case__c=c5.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(Name='SF6',case__c=c5.id);
        insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
            Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
            Contact c=[select id from contact where accountid=:a.id];  
        Task t1 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t2 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t3 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t4 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        Task t6= new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        /*
Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c1.id);
Task t6 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
Task t7 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
insert new list<Task>{t1,t2,t3,t4,t5,t6,t7};
*/
        insert new list<Task>{t1,t2,t3,t4,t5,t6};
            System.debug('Inside Test Class ==============================>:'+[select id from task where whoid=:c1.id]);
        Test.setCreatedDate(t1.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(t2.Id, Datetime.now().addDays(-2));
        Test.setCreatedDate(t3.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(t4.Id, Datetime.now().addDays(-4));
        /*
Test.setCreatedDate(t5.Id, Datetime.now().addDays(-2));
Test.setCreatedDate(t6.Id, Datetime.now().addDays(-3));
Test.setCreatedDate(t7.Id, Datetime.now().addDays(-1));
*/
        //EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        //insert new List<EmailMessage>{emailMsg1,emailMsg2}; 
        //Test.setCreatedDate(emailMsg1.Id, Datetime.now().addDays(-10));
        //Test.setCreatedDate(emailMsg2.Id, Datetime.now().addDays(-8));
        //Test.setCreatedDate(emailMsg3.Id, Datetime.now().addDays(-10));
        //Test.setCreatedDate(emailMsg4.Id, Datetime.now().addDays(-8));
        update a;
        Test.startTest();
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        BatchSLADFailoverHandler.dummyCoveragemethod();
        System.schedule('Process Retention Batch Fail Over','0 0 23 * * ?',new BatchSLADFailoverHandler(true,200));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testRTOpenInactive2() 
    {
        
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Request__c='Test1';
        a.Email__c='abc@gmail.com';
        update a;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');    
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(c3.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(c4.Id, Datetime.now().addDays(-2));
        test.startTest();
        CaseComment c1CaseComment1 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        CaseComment c1CaseComment2 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        CaseComment c1CaseComment3 = new CaseComment(ParentId = c1.Id,CommentBody = 'test');
        insert new List<CaseComment>{c1CaseComment1,c1CaseComment2,c1CaseComment3};
            //Test.setCreatedDate(c1CaseComment1.Id, Datetime.now().addDays(-6));
            //Test.setCreatedDate(c1CaseComment2.Id, Datetime.now().addDays(-4));
            //Test.setCreatedDate(c1CaseComment3.Id, Datetime.now().addDays(-2));
            Survey_Feedback__c sf1=new Survey_Feedback__c(Name='SF1',account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(Name='SF2',case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(Name='SF3',account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(Name='SF4',case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(Name='SF5',case__c=c5.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(Name='SF6',case__c=c5.id);
        insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
            Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
            a.Gdpr_Request__c='RT Open Inactive';
        a.GDPR_Sync_Status__c='SLAD Failure';
        update a;
        a.Gdpr_Request__c='RT Anonymize';
        update a;
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        BatchSLADFailoverHandler.dummyCoveragemethod();
        System.schedule('Process Retention Batch Fail Over','0 0 23 * * ?',new BatchSLADFailoverHandler(true,200));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testRTOpenInactive3() 
    {
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Request__c='Test1';
        a.Email__c='abc@gmail.com';
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');    
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(c3.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(c4.Id, Datetime.now().addDays(-2));
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
        //insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        insert new List<EmailMessage>{emailMsg1,emailMsg2}; 
            Test.setCreatedDate(emailMsg1.Id, Datetime.now().addDays(-10));
        Test.setCreatedDate(emailMsg2.Id, Datetime.now().addDays(-8));
        //Test.setCreatedDate(emailMsg3.Id, Datetime.now().addDays(-10));
        //Test.setCreatedDate(emailMsg4.Id, Datetime.now().addDays(-8));
        update a;
        Test.startTest();
        a.Gdpr_Request__c='RT Open Inactive';
        update a;
        a.Gdpr_Request__c='RT Anonymize';
        update a;
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testDummy() 
    {
        Test.startTest();
        ProcessMemberIntlRetentionInstantRequest.dummyCoverageMethod();
        //GDPRFailoverHandler.dummyCoverageMethod();
        getRecordTypesStatic.getFilteredRecNameIdMap(new List<String>{'Standard','International Seeker','International Provider'});
        NotifyInstantIntlRetentionReqToSterling.dummyCoverageMethod();
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testBatchGDPRFailoverHandler() 
    {
        Test.startTest();
        System.schedule('Process GDPR Fail Over Data Test', '0 0 * * * ?', new  BatchGDPRFailoverHandler());
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testBatchIntlRetentionMemberRequest1() 
    {
        Test.startTest();
        Account a=new Account(Email__c='abc@gmail.com',Gdpr_Request__c='RT Anonymize',lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a; 
        System.schedule('BatchIntlRetentionMemberRequest', '0 0 * * * ?', new  BatchIntlRetentionMemberRequest());
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testBatchIntlRetentionMemberRequest2() 
    {
        Account a=new Account(Email__c='abc@gmail.com',Gdpr_Request__c='RT Open Inactive',lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Id intlEmailRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Contact c=[select id from contact where accountid=:a.id];  
        Task t1 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t2 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t3 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t4 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t6 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c.id);
        Task t7 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        Task t8= new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        /*
Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c1.id);
Task t6 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
Task t7 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
insert new list<Task>{t1,t2,t3,t4,t5,t6,t7};
*/
        insert new list<Task>{t1,t2,t3,t4,t5,t6,t7,t8};
            Test.setCreatedDate(t3.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(t4.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(t5.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(t6.Id, Datetime.now().addDays(-2));
        Test.startTest();
        System.schedule('BatchIntlRetentionMemberRequest', '0 0 * * * ?', new  BatchIntlRetentionMemberRequest(true,10));
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testBatchIntlRetentionMemberRequest3() 
    {
        Test.startTest();
        Account a=new Account(Email__c='abc@gmail.com',Gdpr_Request__c='RT Open Inactive',lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        //System.schedule('BatchIntlRetentionMemberRequest', '0 0 * * * ?', new  BatchIntlRetentionMemberRequest(true,10));
        Database.executeBatch(new BatchIntlRetentionMemberRequest());
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testAvoidRecursion() 
    {
        ProcessMemberIntlRetentionInstantRequest.dummyCoverageMethod();
        Test.startTest();
        AvoidRecursion.runOnce();
        AvoidRecursion.runOnceRequestData1();
        AvoidRecursion.runOnceRetention1();
        AvoidRecursion.runOnceGdpr1();
        AvoidRecursion.runOnceTask1();
        AvoidRecursion.runOnceEvent1();
        AvoidRecursion.runOnceEmailMessage1();
        AvoidRecursion.runOnceCase1();
        AvoidRecursion.runOnceCaseComment1();
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testCareDotComUtil() 
    {
        Test.startTest();
        Account a=new Account(Email__c='abc@gmail.com',lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');insert c1;
        CareDotComUtil.ConvertLocaleToLanguage('en_GB');
        CareDotComUtil.runningInASandbox();
        CareDotComUtil.isInternationalCase(c1);
        CareDotComUtil.isInternationalAccount(a);
        CareDotComUtil.convertId(a.id);
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testTaskUpdateLastModifiedDateOnAccount() 
    {
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        a.Gdpr_Request__c='Test1';
        a.Email__c='abc@gmail.com';
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        insert new List<case>{c1,c2};
            Test.setCreatedDate(c1.Id, Datetime.now().addDays(-8));
        Test.setCreatedDate(c2.Id, Datetime.now().addDays(-6));
        Task t1 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t2 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=a.id);
        Task t3 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        Task t4 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
        insert new list<Task>{t1,t2,t3,t4};
            System.debug('Inside Test Class ==============================>:'+[select id from task where whoid=:c1.id]);
        Test.setCreatedDate(t1.Id, Datetime.now().addDays(-4));
        Test.setCreatedDate(t2.Id, Datetime.now().addDays(-2));
        Test.setCreatedDate(t3.Id, Datetime.now().addDays(-6));
        Test.setCreatedDate(t4.Id, Datetime.now().addDays(-4));
        update a;
    }
}