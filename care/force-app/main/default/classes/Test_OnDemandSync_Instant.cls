@isTest
public class Test_OnDemandSync_Instant {
    Public static String DummyEmail = 'dummyemail@dummy.com';

    static void SanityCheckContactAndCaseTwo(String AccountId, Integer MemberId){
        // this helped method checks US records

        Contact con = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,
                       AccountId,MemberID__c  FROM Contact WHERE AccountId = :AccountId];
        
        system.assertEquals(con.MemberId__c, MemberId,'Contact does not have correct Member Id Set');
        system.assertEquals(con.Account.MemberID__c,String.valueOf(MemberId),'Account does not have correct Member Id Set');
        
    }
    
    static void SanityCheckContactAndCaseTwo(String AccountId, String MemberId, String locale){
        // this helped method checks international recordss
        Account acc = [SELECT id,Global_Member_Id__c, Locale__pc FROM Account WHERE id = :AccountId];
        
        system.assertEquals(acc.Global_Member_Id__c, MemberId,'Account does not have correct Member Id Set');
        system.assertEquals(acc.Locale__pc, locale,'Account does not have correct Locale Set');
        
    }

    
    @isTest static void AccountDoesNotExistYet(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicChildCareSeekerEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');
        
        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicChildCareSeekerMemberId);
    }

    @isTest static void AccountDoesNotExistYetUK(){
        String locale = 'en_GB';
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'memberId'=>TestUtil.InternationalPremiumSeekerMemberId,'salesforceId'=>null,'email'=>TestUtil.InternationalPremiumSeekerEmail,'locale'=>TestUtil.InternationalPremiumSeekerLocale,'countryCode'=>TestUtil.InternationalPremiumSeekerCountryCode,'lastLogin'=>Test_OnDemandSync.lastLogin});
        batchMap.put(TestUtil.InternationalPremiumSeekerEmail,resultsList);
        responseMap.put('batch', batchMap);        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker', locale);
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');
        
        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.InternationalPremiumSeekerMemberId, locale);
    }


    @isTest static void ProviderDoesNotExistYet(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicProviderMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicProviderEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');        

        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicProviderMemberId);
    }
    
    @isTest static void AccountAlreadyExists(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        TestUtil.createBasicChildCareSeeker(); // invoke Account trigger
        Contact con = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName LIMIT 1];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');   

        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicChildCareSeekerMemberId);
    }

    @isTest static void ProviderAlreadyExists(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        TestUtil.createBasicProvider(); // invoke Account trigger
        Contact con = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName LIMIT 1];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');   

        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicProviderMemberId);
    }

    @isTest static void ProviderAlreadyExistsUk(){
        String locale = 'en_GB';
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        TestUtil.SterlingCreatesBasicProvider_enGB(); // invoke Account trigger
        Contact con = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'lastLogin'=>Test_OnDemandSync.lastLogin,'memberId'=>con.Account.Global_Member_Id__c,'salesforceId'=>con.id,'email'=>con.email,'locale'=>con.Locale__c,'countryCode'=>con.Account.PersonMailingCountry});
        batchMap.put(con.email,resultsList);
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Provider',locale);
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');   

        Test.stopTest();

        //SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicProviderMemberId);
    }

    @isTest static void AccountAlreadyExistsButUSPlatformDoesNotKnowIt(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        TestUtil.createBasicChildCareSeeker(); // invoke Account trigger
        Contact con = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName LIMIT 1];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>null,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');   

        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicChildCareSeekerMemberId);
    }

    @isTest static void USPlatformThinksAnAccountExistsButItDoesnt(){
         Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(DummyEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'salesforceId'=>'DUMMYID','email'=>TestUtil.BasicChildCareSeekerEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();

        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        System.assertNotEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
        System.assertNotEquals(false, CDCCPreChatController.isDummyEmail(insertChatCaseResponseMap.get('DummyEmail')), 'Returned Email is not Dummy Email');   

        Test.stopTest();

        SanityCheckContactAndCaseTwo(insertChatCaseResponseMap.get('AccountId'),TestUtil.BasicChildCareSeekerMemberId);
    }

    @isTest static void EmulatePlatformError_AccountDoesNotExistYet(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build error response
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('batch', null);
        responseMap.put('error', Test_OnDemandSync.SamplePlatformErrorMessage);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();
        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        Test.stopTest();

        System.assertEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should be null (due to error)');
        System.assertEquals('Malformed Request: ' + Test_OnDemandSync.SamplePlatformErrorMessage, insertChatCaseResponseMap.get('Error'),'Error field is not set to error');
    }

    @isTest static void EmulateJSONError_AccountDoesNotExistYet(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
                
        // Build error response that will trigger a JSON error
        Map<String, Object> responseMap = null;
        
        Test.startTest();
        Map<String, String> insertChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'','Seeker','en_US');
        
        Test.stopTest();

        System.assertEquals(null, insertChatCaseResponseMap.get('AccountId'), 'AccountId Id should be null (due to error)');
        System.assertEquals('JSON Format Error', insertChatCaseResponseMap.get('Error'),'Error is not JSON Format Error');        

    }

}