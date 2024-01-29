@isTest(SeeAllData=false)
private class Test_ProcessMemberGDPInstantRequest{
    Public static Id intlCCRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center');
    Public static Id intlEmailRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
    Public static Id intlSARecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
    Public static String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
    Public static String socialMediaIntlId=getRecordTypesStatic.recordTypeNameIdMap.get('Social Media International');
    Public static String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
    public static Id socialMediaContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('International Social Contact').getRecordTypeId();
    @isTest(SeeAllData=false)
    static void testNormal() 
    {
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        contact con1=new contact(firstName='Care', recordTypeId=socialMediaContact, lastname='Admin');
        contact con2=new contact(lastname='caredotcom', recordTypeId=socialMediaContact );
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        //SocialPost sp1=new SocialPost(Provider='Facebook',Name='SocialPost1',Posted=System.now(),parentId=c7.id,MessageType='Post',whoid=con1.id);
        //SocialPost sp2=new SocialPost(Provider='Twitter',Name='SocialPost2',Posted=System.now(),parentId=c7.id,MessageType='Reply',whoid=con2.id);
        //insert new list<SocialPost>{sp1, sp2};
        a.Gdpr_Request__c='RTBF';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testNonClearedSafetyCase() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='testNonClearedSafetyCase';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlSARecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlSARecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlSARecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlSARecId,Status='New');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testInvalidRecordType() 
    {
        Account a=new Account(lastName='FirstName LastName',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        //a.lastname='Test1';
        //update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testEmployerProgram() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',Employer_Program__pc='Google');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testPremium() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',Type__pc='Premium');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';
        update a; 
    }
    @isTest(SeeAllData=false)
    static void testRTBFOverride() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',Type__pc='Premium');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF Override';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testRTBFFix() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';update a; 
        a.Gdpr_Request__c='RTBF Fix';
        update a;
    }
    @isTest(SeeAllData=false)
    static void testRTBFDoNotProcess() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF';update a; 
        a.Gdpr_Request__c='RTBF Do Not Process';
        update a; 
    }
    @isTest(SeeAllData=true)
    static void testRTBFAnonymize() 
    {
        Account a=new Account(lastname='Test',recordtypeid=seekerRecId,Global_Member_Id__c='12345678');
        insert a;
        a.lastname='Test1';
        update a;
        AccountHistory ah=new AccountHistory(accountid=a.id);
        //insert ah;
        Case c1=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c2=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c3=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c4=new Case(accountid=a.id,Recordtypeid=intlEmailRecId,Status='Cleared');
        Case c5=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        Case c6=new Case(accountid=a.id,Recordtypeid=intlSARecId,status='Cleared');
        insert new List<case>{c1,c2,c3,c4,c5,c6};
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
        EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 
        EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        EmailMessage  emailMsg4= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
        insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3,emailMsg4}; 
        a.Gdpr_Request__c='RTBF Fix';update a; 
        a.Gdpr_Request__c='RTBF Anonymize';
        update a; 
    }
    @isTest(SeeAllData=false)
    static void testDummy() 
    {
        ProcessMemberGDPInstantRequest.dummyCoverageMethod();
        ProcessMemberGDPRequest.dummyCoverageMethod();
        GDPRFailoverHandler.dummyCoverageMethod();
        getRecordTypesStatic.getFilteredRecNameIdMap(new List<String>{'Standard','International Seeker','International Provider'});
        NotifyInstantGDPRequestToSterling.dummyCoverageMethod();
        ProcessGDPRData.dummyCoverageMethod();
    }
    @isTest(SeeAllData=false)
    static void testBatchGDPRFailoverHandler() 
    {
        Test.startTest();
        System.schedule('Process GDPR Fail Over Data Test', '0 0 * * * ?', new  BatchGDPRFailoverHandler());
        Test.stopTest();
    }
}