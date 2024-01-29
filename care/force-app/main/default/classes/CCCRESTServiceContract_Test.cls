/***************************************************************************************************
   Name        : CCCRESTServiceContract_Test
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: February 3rd, 2021
   Description : Unit test class for CCCRESTServiceContract

   Changes     : 02/03/2021 - John Wrightsman (Class Created)
******************************************************************************************************/
@isTest
private class CCCRESTServiceContract_Test {

    @testSetup static void setup() {
        insert new Opportunity(Name = 'Test', CloseDate = Date.today(), StageName = 'Prospecting');

        CCCTestDataFactory.createContractComposerApiUser();
    }

    @isTest static void patchContract_successful() {
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        // Pick a contract status from the metadata setting to send.
        CCC_Opportunity_StageName_Map__mdt stageNameMapSetting = [SELECT Contract_Status__c, Opportunity_StageName__c FROM CCC_Opportunity_StageName_Map__mdt WHERE Active__c = true LIMIT 1];

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = stageNameMapSetting.Contract_Status__c;
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opportunityId;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq);
        }
        Test.stopTest();

        // Should be successful
        System.assertEquals(null, RestContext.response.responseBody, 'Expected: null - Received:' + RestContext.response.responseBody);
        System.assertEquals(200, RestContext.response.statusCode);

        // Check Opportunity to see that the StageName was set
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :opportunityId];
        System.assertEquals(stageNameMapSetting.Opportunity_StageName__c, opp.StageName, 'Expected:' + stageNameMapSetting.Opportunity_StageName__c + ' Received:' + opp.StageName);
    }

    @isTest static void patchContract_non_mapped_contract_status() {
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = 'non_mapped_status';
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opportunityId;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq);
        }
        Test.stopTest();

        System.assertEquals(403, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf('No Opportunity stage name mapping exists for this contract_status'), RestContext.response.responseBody, 'Received:' + RestContext.response.responseBody.toString());
    }

    @isTest static void patchContract_invalid_opp_id() {
        String opportunityId = 'InvalidOpportunityId';

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = 'pending_activation';
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opportunityId;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq);
        }
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf('Invalid Opportunity Id'), RestContext.response.responseBody, 'Received:' + RestContext.response.responseBody.toString());
    }

    @isTest static void patchContract_opp_not_found() {
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        // Replace last 8 chars with 'X' so that it is still a valid opportunity id format
        opportunityId = opportunityId.substring(0, 10) + 'XXXXXXXX';

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = 'pending_activation';
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opportunityId;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq);
        }
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf('Opportunity not found'), RestContext.response.responseBody, 'Received:' + RestContext.response.responseBody.toString());
    }

    @isTest static void patchContract_fail_opp_closed_won() {
        Opportunity opp = [SELECT StageName FROM Opportunity LIMIT 1];
        opp.StageName = 'Closed Won';
        update opp;

        // Pick a contract status from the metadata setting to send.
        CCC_Opportunity_StageName_Map__mdt stageNameMapSetting = [SELECT Contract_Status__c, Opportunity_StageName__c FROM CCC_Opportunity_StageName_Map__mdt WHERE Active__c = true LIMIT 1];

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = stageNameMapSetting.Contract_Status__c;
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opp.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq);
        }
        Test.stopTest();

        // Should fail
        System.assertEquals(Blob.valueOf('The Opportunity stage is Closed Won and cannot be updated'), RestContext.response.responseBody, 'Received:' + RestContext.response.responseBody.toString());
        System.assertEquals(409, RestContext.response.statusCode);
    }

    @isTest static void patchContract_throwRootExceptionFail() {
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        // Pick a contract status from the metadata setting to send.
        CCC_Opportunity_StageName_Map__mdt stageNameMapSetting = [SELECT Contract_Status__c, Opportunity_StageName__c FROM CCC_Opportunity_StageName_Map__mdt WHERE Active__c = true LIMIT 1];

        CCCRESTServiceContract.PatchContactRequest patchReq = new CCCRESTServiceContract.PatchContactRequest();
        patchReq.contract_status = stageNameMapSetting.Contract_Status__c;
        String jsonBody = JSON.serialize(patchReq);

        RestRequest req = new RestRequest();
        req.requestUri = '/' + opportunityId;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

		RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set flag to throw root exception
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceContract.patchContract(patchReq, flags);
        }
        Test.stopTest();

        // Should receive status 500 and error message
        System.assertEquals(500, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().startsWith('Throw Root Exception Unit Test.'));
    }
}