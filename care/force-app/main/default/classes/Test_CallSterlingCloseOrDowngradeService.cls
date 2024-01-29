@isTest
public class Test_CallSterlingCloseOrDowngradeService {
    
    static testMethod void Downgrade_MemberNotInSalesforce() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SterlingMockHTTPResponse());
        ID IsRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
        ID IeRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
        Case c = new Case();
        c.SuppliedName = 'MemberOutside OfSalesforce';
        c.SuppliedEmail = 'premiumoutofsfdc@care.com';
        c.SuppliedPhone = '+44 20 7828 2840';
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.Subject = 'Test Member Not in SFDC';
        /*c.Contact_Theme__c='Safety';
c.Contact_Reason__c = 'Safety Communication';
c.Contact_Secondary_Reason__c = 'Other'; */
        c.Member_Country__c='uk';
        c.Action_Time__c='Now';
        c.Cancel__c=true;    
        c.Sentiment__c='Positive';    
        c.Member_Locale__c='en_GB';          
        insert c;
        System.debug('c.Status===>:'+c.Status);
        c.Status='Closed';
        update c;
        Test.stopTest();
        
    }
    static testMethod void notifySalesforceAdminTest() {
        Test.startTest();
        ID IsRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
        ID IeRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
        Case c = new Case();
        c.SuppliedName = 'MemberOutside OfSalesforce';
        c.SuppliedEmail = 'premiumoutofsfdc@care.com';
        c.SuppliedPhone = '+44 20 7828 2840';
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.Subject = 'Test Member Not in SFDC';
        /*c.Contact_Theme__c='Safety';
c.Contact_Reason__c = 'Safety Communication';
c.Contact_Secondary_Reason__c = 'Other'; */
        c.Member_Country__c='uk';
        c.Action_Time__c='Now';
        c.Cancel__c=true;    
        c.Sentiment__c='Positive';    
        c.Member_Locale__c='en_GB';          
        insert c;
        CallSterlingCloseOrDowngradeService.testException=4;
        System.debug('c.Status===>:'+c.Status);
        c.Status='Closed';
        update c;
        Test.stopTest();
        
    }
    static testMethod void Cancel_OpenBasicSeeker_GenerateAPIError() {
       
        // In this test, we trigger an API error (via a special email address: generateapierror@care.com monitored from SterlingMockHTTPResponse)
        Test.setMock(HttpCalloutMock.class, new SterlingMockHTTPResponse());
        ID IsRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
        ID IeRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = IsRtId;
        a.FirstName = 'OpenBasic';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998002';
        a.Language__pc = 'English';
        a.Locale__pc = 'en_GB';
        a.Status__pc = 'Open';
        a.Type__pc = 'Basic';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'ie';
        a.PersonEmail = 'generateapierror@care.com';        
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        a.MembershipCreationDate__pc = date.today();
        
        insert a;
        
        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = a.PersonEmail;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.ContactId = pc.id;
        c.Subject = 'Test Open Basic';
        /*c.Contact_Theme__c='Safety';
c.Contact_Reason__c = 'Safety Communication'; 
c.Contact_Secondary_Reason__c = 'Other'; */
        c.Cancel__c=true;
        c.Action_Time__c='Now';
        c.Member_Country__c='uk';
        c.Member_Locale__c='en_GB';
        c.sentiment__c='Positive';
        insert c;
        
        c.Status='Closed';
        update c;
        
        
    }    
    
    
   static testMethod void handle_error() {
            HttpRequest req = new HttpRequest();            
            req.setHeader('Content-Type', 'application/json');
            req.setBody('{"example":"test"}');
            HttpResponse res = new HttpResponse();
            CallSterlingCloseOrDowngradeService.handleAPIError(res, req); 
   }
}