/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Application Architect Salesforce [sridharn@wavelabs.com]
** Modified Date:  04.02.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-3000 CCPA - Access Data - Data Classification for Fields
** SFORCE-3001 CCPA - Access Data - Custom Web Service
** SFORCE-3002 CCPA - Access Data - Prepare a Sample JSON File
** SFORCE-3003 CCPA - Access Data - Query SFDC Fields
** SFORCE-3004 CCPA - Access Data - Encrypted the Queried SFDC Fields
** SFORCE-3005 CCPA - Access Data - Map specific field by record type
** SFORCE-3006 CCPA - Access Data - Generate JSON Files
** SFORCE-3004 CCPA - Access Data - Decrypt Files When US Platform Pulling Them
** SFORCE-3008 CCPA - Access Data - Need a Batch job to asynchronous Prepare Access Data Files
** SFORCE-3009 CCPA - Access Data - Secure Files so only Modify All and View All Data can see
** _______________________________________________________________________________
*/


@isTest(SeeAllData=false)
private class Test_CCPAAccessDataRequestProcess
{

@isTest(SeeAllData=false)
static void testCCPAAccessDataRequest1() 
{
Test.startTest();

String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
   
   update prObj1;
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   //System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,'999666'));
      BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.schedule('Data Access Schedule Batch1','01 01 * * * ?',new ScheduleCCPAAccessDataGenerateFiles());
System.schedule('Data Access Schedule Batch2','01 01 * * * ?',new ScheduleCCPAAccessDataGenerateFiles());          
 Test.stopTest();
}

@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSwitchOff() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
   
   update prObj1;
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform'; Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSwitchOn() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
   
   update prObj1;
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        //prList[0].Request_Status__c='Completed - Success';
        //update prList[0];
 Test.stopTest();
}

@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodCaseOffSetTest() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Case',0,new List<String>{'Case','Email Message','Survey Feedback','Social  Post','Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        

}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSurveyFeedbackOffSetTest() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
   

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
     BatchCCPAAccessDataGenerateFiles.doChainJob=false;   
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Survey Feedback',0,new List<String>{'Survey Feedback'}));

   
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSocialPostOffSetTest() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
   

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
      BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Social Post',0,new List<String>{'Social Post'}));

   
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodLiveChatTranscriptOffSetTest() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
   

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);   
      BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Case',0,new List<String>{'Case'}));      
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Survey Feedback',0,new List<String>{'Survey Feedback'}));
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Email Message',0,new List<String>{'Email Message'}));
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Social Post',0,new List<String>{'Social Post'}));
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Live Chat Transcript',0,new List<String>{'Live Chat Transcript'}));
   
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodEmailMessageOffSetTest() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;

    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
   

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
      BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Email Message',0,new List<String>{'Email Message'}));

   
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
 Test.stopTest();
}

 
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodEmptyPRTest() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;
    //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String specificMemId,boolean testException)
List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(false,''+prObj1.id));  
Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodTestingContext() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;
    //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String specificMemId,boolean testException)
       List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
          BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(true,''+prObj1.id));  
Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodTestingContextNoPR() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';

insert prObj1;update prObj1;
    //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String specificMemId,boolean testException)
       List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
          BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(new BatchCCPAAccessDataGenerateFiles(true,null));  
Test.stopTest();
}

@isTest(SeeAllData=false)
static void testCCPAAccessDataDummyCoverageMethod() 
{
Test.startTest();
new BatchCCPAAccessDataGenerateFiles().dummyCoverageMethod();
Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodCaseOffSetTestttttt() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Case',0,new List<String>{'Case','Email Message','Survey Feedback','Social  Post','Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 /* 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        */

}

@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodEmailMessageTestttttt() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Email Message',0,new List<String>{'Email Message','Survey Feedback','Social  Post','Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 /* 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        */

}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSocialPostTestttttt() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Social Post',0,new List<String>{'Survey Feedback','Social  Post','Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 /* 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        */

}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodSurveyFeedbackTestttttt() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Survey Feedback',0,new List<String>{'Survey Feedback','Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 /* 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        */

}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodLiveChatTranscriptTestttttt() 
{
Privacy_Request__c prObj1=new Privacy_Request__c();
prObj1.Request_Status__c='Request Accepted';
//prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.Email__c='test@gmail.com';
//query = 'SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c FROM Privacy_Request__c 
//where Universal_Member_Id__c!=null and id=:prIdInProgress and isDeleted=false and Source_System__c=\'US Platform\' and Request_Type__c=\'Access Data\' and Request_Status__c in (\'Request Accepted\')';
insert prObj1;
System.debug('Inside Test Class');
System.debug([SELECT No_Of_Files_Retrieved__c,Address__c,Auto_Expire__c,Case_Thread_Id__c,Case__c,Country__c,CSR_Email__c,CSR_Name__c,Data_Categories__c,Data_URL__c,Data__c,Email_Formula__c,Email__c,Extension_Notification_Date__c,Fail_Decline_Reason__c,Fulfillment_Date_Rationale__c,Fulfillment_Date__c,Id,IsDeleted,Name,Name_Formula__c,Name__c,Requestor_Email__c,Requestor_Name__c,Requestor_Relationship_to_Member__c,Request_Date__c,Request_Status__c,Request_Type__c,Source_System__c,State_Province__c,Universal_Member_Id_Formula__c,Universal_Member_Id__c from Privacy_Request__c]);




String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');



    Account a=new Account(lastname='testNormal',MemberId__pc=97596486,personEmail='sridhar.neeli@care.com',locale__pc='uk');
    insert a;


    Map<id,String> caseRecTypes=new Map<id,String>();
    //Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
    //caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),'Safety Alert');
    //caseRecTypeNameIdMap.put('Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'));
       
    
    //Case c1=new Case(accountid=a.id,Recordtypeid=caseRecTypeNameIdMap.get('Safety Alert'),Status='Closed',Closed_Reason__c='CLEARED',createddate=system.now().addyears(-3));
    Case c1=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert c1;
    Case c2=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c2};
        Case c3=new Case(recordTypeId=standardRecId,accountid=a.id,Status='Closed',Reason='Account',Secondary_Case_Reason__c='Access Data',subject='Test Subject',description='Test Description',Origin='Web',contact_Theme__c='Safety',contact_reason__c='Safety Communication',contact_secondary_reason__c='Other',Sentiment__c='Positive');
    insert new List<case>{c3};
    
    EmailMessage  emailMsg1= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id); 
    EmailMessage  emailMsg2= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c2.Id); 
    EmailMessage  emailMsg3= new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c3.Id); 

    insert new List<EmailMessage>{emailMsg1,emailMsg2,emailMsg3}; 
 
    Survey_Feedback__c sf1=new Survey_Feedback__c(account__c=a.id);
    Survey_Feedback__c sf2=new Survey_Feedback__c(case__c=c1.id);
    Survey_Feedback__c sf3=new Survey_Feedback__c(case__c=c2.id);
    Survey_Feedback__c sf4=new Survey_Feedback__c(case__c=c3.id);

   insert new List<Survey_Feedback__c>{sf1,sf2,sf3,sf4};
   
   
    SocialPost sp1=new SocialPost(Name='SocialPost1',parentId=c1.id);
    SocialPost sp2=new SocialPost(Name='SocialPost2',parentId=c2.id);
    SocialPost sp3=new SocialPost(Name='SocialPost3',parentId=c3.id);

   insert new List<SocialPost>{sp1,sp2,sp3};

        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
   
    LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c1.id);
    LiveChatTranscript lct2=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c2.id);
    LiveChatTranscript lct3=new LiveChatTranscript(LiveChatVisitorid=lcv.id,caseId=c3.id);

   insert new List<LiveChatTranscript>{lct1,lct2,lct3};
      List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);

   
   //global BatchCCPAAccessDataGenerateFiles(boolean isTestingContext,String prIdInProgress,String objectName,Integer offSet,List<String> objectsToRead) 
   
   BatchCCPAAccessDataGenerateFiles batchObj=new BatchCCPAAccessDataGenerateFiles(false,null,''+prObj1.id,'Live Chat Transcript',0,new List<String>{'Live Chat Transcript'});
   BatchCCPAAccessDataGenerateFiles.doChainJob=false;
System.enqueueJob(batchObj);      
 /* 
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';

   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        prList[0].Request_Status__c='Completed - Success';
        update prList[0];
        */

}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodJsonError() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1;

   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cA"AE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        //prList[0].Request_Status__c='Completed - Success';
        //update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodNoOfFilesZero() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=0;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1;
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost(prList[0].id,'1');
        
        //prList[0].Request_Status__c='Completed - Success';
        //update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDoPostMethodWithInvalidPR() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=0;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1;
   //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);
//prList[0].Request_Status__c='Queued - Remote Platform';



        RestRequest request = new RestRequest();
        RestResponse response= new RestResponse();
      
        request.requestUri ='/services/apexrest/retrieveCCPADataAccessFile';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response=response;
        RetrieveCCPADataAccessFile.doPost('78794375934','1');
        
        //prList[0].Request_Status__c='Completed - Success';
        //update prList[0];
 Test.stopTest();
}
@isTest(SeeAllData=false)
static void testCCPAAccessDataDeletePR() 
{
Test.startTest();


String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Provider');

Privacy_Request__c prObj1=new Privacy_Request__c();
//prObj1.Request_Status__c='Request Accepted';
prObj1.Request_Status__c='Queued - Remote Platform';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Source_System__c='US Platform';
prObj1.Request_Type__c='Access Data';
prObj1.Universal_Member_Id__c='97596486';
prObj1.Request_Date__c=System.today();
prObj1.Fulfillment_Date__c=System.today();
prObj1.Name__c='prObj11';
prObj1.No_Of_Files_Retrieved__c=1;
prObj1.Email__c='test@gmail.com';

insert prObj1; 

 //String jsonString='{"#18.0 PR-2134 2020-04-09 04:46:51":{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}}';
   String jsonString='{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}';
   List<privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
   
    Process_Security_Settings__mdt  pssList= [SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data') LIMIT 1];
     pssList.Switch__c='On';
   
   
new BatchCCPAAccessDataGenerateFiles().addAttachmentsToPrivcyRequest('1_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
//prList[0].No_Of_Files_Retrieved__c+'_'+prList[0].Name+' '+Datetime.now(), jsonString,prList[0].id);
System.debug('prList[0].id============>:'+prList[0].id);
prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c,Request_Status__c from Privacy_Request__c where Universal_Member_Id__c='97596486']);
System.debug('prList[0].No_Of_Files_Retrieved__c============>:'+ prList[0].No_Of_Files_Retrieved__c);
System.debug('prList[0].Request_Status__c============>:'+ prList[0].Request_Status__c);


delete prObj1;
   
 Test.stopTest();
}

}