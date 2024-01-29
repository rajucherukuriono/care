@isTest(SeeAllData=false)
private class Test_BatchGDPRMemberRequest{
    Public static String intlCall = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    Public static String intlEmail = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    Public static String intlSafety = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
    Public static String intlSocial = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
    Public static String intlSeeker = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    Public static String intlProvider= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    @isTest(SeeAllData=false)
    static void test3() 
    {
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='New',Global_Member_Id__c='12345678');
        System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        //Request_Data__c  gdprObj=new Request_Data__c (Status__c='New',Global_Member_Id__c='12345678');
        upsert gdprObj;
        List<id> caseListIds;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);        
        insert new List<case>{c1,c2,c3,c4,c5,c6};
        caseListIds = new List<Id>{c1.Id,c2.Id,c3.id,c4.id,c5.id,c6.id};
        Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(case__c=c5.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(case__c=c5.id);
        try{
            insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
        }
        catch(Exception e){}
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        insert new List<Attachment>{att1,att2,att3,att4}; 
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        Test.startTest();
        BatchGDPRFeedProcess bfp = new BatchGDPRFeedProcess();
        Database.executeBatch(new BatchGDPRFeedProcess(false, caseListIds));
        
        BatchGDPRHistoryProcess bfh = new BatchGDPRHistoryProcess();
        Database.executeBatch(new BatchGDPRHistoryProcess(false, caseListIds));
        
        BatchGDPRMemberRequest btchMR = new BatchGDPRMemberRequest();
        //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
        //List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('sridhar.neeli@care.com')];
        //System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
        //ProcessGDPRCount.processGDPRCount('sridhar.neeli@care.com,raju.cherukuri@care.com');
        ProcessGDPRData.processGDPRInfo('anonymize');
        Test.stopTest();
    }
    /*@isTest(SeeAllData=false)
    static void test4() 
    {
        Test.startTest();
        ProcessMemberGDPRequest.dummyCoverageMethod();
        Test.stopTest();
    } */
    @isTest(SeeAllData=false)
    static void test5() 
    {
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        CareDotComUtil.convertId(a.id);
        CareDotComUtil.runningInASandbox();
        String sLanguage = 'English';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'German';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'French';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Dutch';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Danish';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Finnish';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Swedish';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Spanish';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        sLanguage = 'Norwegian';
        CareDotComUtil.ConvertLocaleToLanguage(sLanguage);
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='Test',Global_Member_Id__c='12345678');
        System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        //Request_Data__c  gdprObj=new Request_Data__c (Status__c='Test',Global_Member_Id__c='12345678');
        upsert gdprObj;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        try{
            insert new List<case>{c1,c2,c3,c4,c5,c6};
        }
        catch(Exception e){}
        Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Content',
            PathOnClient = 'Content.html',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;//create the the content version record 
        FeedItem feedAcc1 = new FeedItem (
            parentid = a.id,
            type = 'ContentPost',
            RelatedRecordId = contentVersion_1.id,
            Body = 'Hello'
        );
        FeedItem feedAcc2 = new FeedItem (
            parentid = a.id,
            type = 'ContentPost',
            RelatedRecordId = contentVersion_1.id,
            Body = 'Hello'
        );
        FeedItem feedCase1 = new FeedItem (
            parentid = c1.id,
            type = 'ContentPost',
            RelatedRecordId = contentVersion_1.id,
            Body = 'Hello'
        );
        FeedItem feedCase2 = new FeedItem (
            parentid = c1.id,
            type = 'ContentPost',
            RelatedRecordId = contentVersion_1.id,
            Body = 'Hello'
        );	
        try{
            insert feedAcc1;   insert feedAcc2;         insert feedCase1; insert feedCase2;  //insert feedSf1 ;
        }
        catch(Exception e){}
        Task t1 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=a.id);
        Task t2 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=a.id);
        Task t3 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=c1.id);
        Task t4 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=c1.id);
        Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=c5.id);
        Task t6 = new Task(Subject='Test Task',Status='New',Priority='Normal',CallType='Outbound',whatid=c5.id);
        Event e1 = new Event(Subject='Test Event',whatid=a.id,DurationInMinutes=10,ActivityDateTime=Datetime.Now());
        Event e2 = new Event(Subject='Test Event',whatid=a.id,DurationInMinutes=10,ActivityDateTime=Datetime.Now());
        Event e3 = new Event(Subject='Test Event',whatid=c1.id,DurationInMinutes=10,ActivityDateTime=Datetime.Now());
        Event e4 = new Event(Subject='Test Event',whatid=c1.id,DurationInMinutes=10,ActivityDateTime=Datetime.Now());
        insert new List<Task>{t1,t2,t3,t4,t5,t6};
        insert new List<Event>{e1,e2,e3,e4};
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1'));
        try 
        {
            insert new List<Attachment>{att1,att2,att3,att4}; 
        } 
        catch (exception e) { }
        //EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        //EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        //EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        //EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        //insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        //insert new List<EmailMessage>{emailMsg1,emailMsg2}; 
        //then create feedItem record
        //System.assert(e.getMessage().contains('Sorry..!! You cannot attach this file format'));
        Test.startTest();
        //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
        //List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('sridhar.neeli@care.com')];
        //System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
        //ProcessGDPRCount.processGDPRCount('sridhar.neeli@care.com,raju.cherukuri@care.com');
        //ProcessGDPRData.processGDPRInfo('preCheck');
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test6() 
    {
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='Test',Global_Member_Id__c='12345678');
        System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        //Request_Data__c  gdprObj=new Request_Data__c (Status__c='Test',Global_Member_Id__c='12345678');
        upsert gdprObj;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlProvider);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        try{
            insert new List<case>{c1,c2,c3,c4,c5,c6};
        }
        catch(Exception e){}
        Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(case__c=c5.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(case__c=c5.id);
        try{
            insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
        }
        catch(Exception e){}
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        try{
            insert new List<Attachment>{att1,att2,att3,att4}; 
        }
        catch(Exception e){}
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        try 
        {
            insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        }
        catch (exception e) { }
        Test.startTest();
        //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
        //List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('sridhar.neeli@care.com')];
        //System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
        //ProcessGDPRCount.processGDPRCount('sridhar.neeli@care.com,raju.cherukuri@care.com');
        // commenting out this as part of gears deployment last modified on 16/12/2020
        // ProcessGDPRData.processGDPRInfo('anonymize'); 
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void test7() 
    {
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=intlSeeker,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Request_Data__c  gdprObj=new Request_Data__c (Request_Type__c='RTBF',Status__c='Test',Global_Member_Id__c='12345678');
        System.assert(gdprObj.Global_Member_Id__c==a.Global_Member_Id__c);
        upsert gdprObj;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmail);
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSafety);
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSafety);
        try 
        {
            insert new List<case>{c1,c2,c3,c4,c5,c6}; 
        } 
        catch (exception e) { }
        Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf3=new Survey_Feedback__c(account__c=a.id);
        Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c1.id);
        Survey_Feedback__c sf5=new Survey_Feedback__c(case__c=c5.id);
        Survey_Feedback__c sf6=new Survey_Feedback__c(case__c=c5.id);
        try{
            insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4,sf5,sf6};
        }
        catch(Exception e){}
        Attachment att1 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body')); 
        Attachment att2 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body')); 
        Attachment att3 = new Attachment(parentid=a.id,name='Att1',body=Blob.valueOf('Test Body1')); 
        Attachment att4 = new Attachment(parentid=c1.id,name='Att2',body=Blob.valueOf('Test Body1')); 
        try 
        {
            insert new List<Attachment>{att1,att2,att3,att4}; 
        }
        catch (exception e) { }
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        try{
            insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4};
        }
        catch(Exception e){}
        Test.startTest();
        //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
        //List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('sridhar.neeli@care.com')];
        //System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
        //ProcessGDPRCount.processGDPRCount('sridhar.neeli@care.com,raju.cherukuri@care.com');
        // commenting out this as part of gears deployment last modified on 16/12/2020
        // ProcessGDPRData.processGDPRInfo('anonymize');
        Test.stopTest();
    }
}