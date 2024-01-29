/***************************************************************************************************
   Name        : BUCAccountRestService_Test
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revtec360.com
   Created Date: 04/24/2022
   Description : Unit test class for BUCCaseRestService

   Changes     :
******************************************************************************************************/
@isTest
private class BUCCaseRestService_Test {

    @testSetup static void setup() {
        insert new Account(Name = 'test');
    }

    @isTest static void test_postCase() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];

        RestRequest req = new RestRequest();
        // req.requestUri = '/' + accountRecord.Galore_Business_Id__c;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        BUCCaseRestService.PostCaseRequest caseReq = new BUCCaseRestService.PostCaseRequest();
        caseReq.case_record_type = 'COI expiration';
        caseReq.account_id = accountRecord.Id;
        caseReq.reason = 'test';
        caseReq.locationCount = '1';
        caseReq.status = '';
        caseReq.priority = '';


        BUCCaseRestService.postCase(caseReq);

        String responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();

        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(1, cases.size());

        BUCCaseRestService.postCase(caseReq);

        responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();

        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);
        cases = [SELECT Id FROM Case];
        System.assertEquals(2, cases.size());

        // Test invalid record type
        caseReq.case_record_type = 'some non-existent record type name';
        BUCCaseRestService.postCase(caseReq);
        responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();
        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);

        cases = [SELECT Id FROM Case];
        System.assertEquals(2, cases.size());
    }

    // @isTest static void postAccount_invalid_galore_business_id() {
    //     String galoreBusId = 'invalid galore business id';

    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/' + galoreBusId;
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(404, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

    // @isTest static void postAccount_fail_no_galore_business_id() {
    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/';
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(404, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

    // @isTest static void postAccount_fail_throwRootExceptionFail() {
    //     String galoreBusId = 'test';

    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/' + galoreBusId;
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest, flags);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(500, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

}