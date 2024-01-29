/***************************************************************************************************
   Name        : CCCRESTServiceAccount_Test
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: 08/20/2021
   Description : Unit test class for CCCRESTServiceLocation

   Changes     : 08/20/2021 - John Wrightsman (Class Created)
******************************************************************************************************/
@isTest
private class CCCRESTServiceAccount_Test {

    @testSetup static void setup() {
        insert new Account(Name = 'test', Galore_Business_Id__c = 'test', Galore_Status__c = '');

        CCCTestDataFactory.createContractComposerApiUser();
    }

    @isTest static void postAccount_successful() {
        Account accountRecord = [SELECT Galore_Business_Id__c FROM Account LIMIT 1];

        RestRequest req = new RestRequest();
        req.requestUri = '/' + accountRecord.Galore_Business_Id__c;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
        accountRequest.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceAccount.postAccount(accountRequest);
        }
        Test.stopTest();

        String responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();

        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);

        // Check Account Galore_Status__c
        String galoreStatus = [SELECT Galore_Status__c FROM Account WHERE Galore_Business_Id__c = :accountRecord.Galore_Business_Id__c].Galore_Status__c;
        System.assertEquals('test', galoreStatus, 'Expected:test Received:' + galoreStatus);
    }

    @isTest static void postAccount_invalid_galore_business_id() {
        String galoreBusId = 'invalid galore business id';

        RestRequest req = new RestRequest();
        req.requestUri = '/' + galoreBusId;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
        accountRequest.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceAccount.postAccount(accountRequest);
        }
        Test.stopTest();

        // Should fail
        System.assertEquals(404, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

    @isTest static void postAccount_fail_no_galore_business_id() {
        RestRequest req = new RestRequest();
        req.requestUri = '/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
        accountRequest.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceAccount.postAccount(accountRequest);
        }
        Test.stopTest();

        // Should fail
        System.assertEquals(404, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

    @isTest static void postAccount_fail_throwRootExceptionFail() {
        String galoreBusId = 'test';

        RestRequest req = new RestRequest();
        req.requestUri = '/' + galoreBusId;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
        accountRequest.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceAccount.postAccount(accountRequest, flags);
        }
        Test.stopTest();

        // Should fail
        System.assertEquals(500, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

}