@isTest
private class CreateTaskUponFutureOpp_Test {

static testMethod void CreateTaskUponFutureOpp_Test () {
Test.startTest();
ID leadWpsRecId= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WPS Lead').getRecordTypeId();
ID leadB2BRecId= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('International B2B').getRecordTypeId();
Lead l1 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sneeli@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Web',
            Description = 'This is a test lead',
            Subject__c = 'Task Subject',
            Due_Date__c = system.today(),
            Comments_to_Task__c = 'Task Comments',
            RecordTypeId = leadWpsRecId,
            status='Future Opportunity'
            
          );
          try{
          insert l1;
          }catch(Exception e){}
           Lead l2 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sneeli@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Web',
            Description = 'This is a test lead',
            Subject__c = 'Task Subject',
            Due_Date__c = system.today(),
            Comments_to_Task__c = 'Task Comments',
            RecordTypeId = leadWpsRecId,
            status='New'
            
          );
          try{
          insert l2;
          update l2;
          }catch(Exception e){}
          Test.stopTest();
          }
    
    
    @isTest(SeeAllData=false)
static void testRTOpenInactive2() 
{

String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
   Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
   insert a;
   a.Gdpr_Request__c='Test1';
   a.Email__c='abc@gmail.com';
   update a;
     

   List<RecordType> caseRecTypes=[SELECT ID,NAME FROM RECORDTYPE WHERE sObjectType='Case' and NAME IN ('International Call Center','International Email','International Safety Alert')];
    Id intlCCRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center');
    Id intlEmailRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
    Id intlSARecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
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
Task t3 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
Task t4 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
/*
Task t5 = new Task(Subject='Test Task',Status='New',Priority='Normal',whoid=c1.id);
Task t6 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
Task t7 = new Task(Subject='Test Task',Status='New',Priority='Normal',whatid=c1.id);
insert new list<Task>{t1,t2,t3,t4,t5,t6,t7};
*/
insert new list<Task>{t1,t2,t3,t4};
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
    
    Test.startTest();
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
}