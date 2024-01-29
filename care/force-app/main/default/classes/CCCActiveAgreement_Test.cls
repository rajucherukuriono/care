/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 01/05/2020
Description: Test methods for CCCActiveAgreementController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCActiveAgreement_Test {
    private static CCCActiveAgreementController.ServerResponse response;

    @testSetup static void setup() {

        // Create Account
        CCCTestDataFactory.createAccount('Test Account');

        // Retrieve our new Account
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Assign a Galore Id for API calls
        accountRecord.Galore_Business_Id__c = 'XYZ';
        update accountRecord;

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void test_cancelAgreement_Fail_EmptyAccountId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(null, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty accountId parameter passed.'), 'Expected message to end with: Empty accountId parameter passed.');
    }

    @isTest static void test_cancelAgreement_Fail_EmptySalesContractId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty salesContractId parameter passed.'), 'Expected message to end with: Empty salesContractId parameter passed.');
    }

    @isTest static void test_cancelAgreement_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String cancelEndpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(cancelEndpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_cancelAgreement_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_cancelAgreement_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_cancelAgreement_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Not Found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Sales Contract not found on external system.'), 'Expected message to end with: Sales Contract not found on external system.');
    }

    @isTest static void test_cancelAgreement_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_cancelAgreement_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500');
    }

    @isTest static void test_cancelAgreement_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5', flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_cancelAgreement_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_API_Endpoint_Setting__mdt apiSetting;

        // Update our account with a Galore Id
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Update Sales Contract
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String cancelEndpointURL = apiSetting.URL__c.replace(':uuid', 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');

        // Get API Setting - Fetch a Business
        apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String fetchEndpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Update Sales Contract
        CCCAPIRespUpdateSalesContract.ServerResponse mockCancelResponse = new CCCAPIRespUpdateSalesContract.ServerResponse();
        mockCancelResponse.sales_contract = new CCCAPIRespUpdateSalesContract.SalesforceContract();
        mockCancelResponse.sales_contract.salesforce_opportunity_id = 'ABCDEFGHIJKLMNOPQR';
        mockCancelResponse.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockFetchResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockFetchResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockFetchResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockFetchResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockFetchResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockFetchResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockFetchResponse.business.locations[0].name = 'XYZ';
        mockFetchResponse.business.locations[0].budget_currency = 'USD';
        mockFetchResponse.business.locations[0].run_ads = false;
        mockFetchResponse.business.locations[0].ads_status = 'unknown';
        mockFetchResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockFetchResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockFetchResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockFetchResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockFetchResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockFetchResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockFetchResponse.business.locations[0].offerings[0].active = true;
        mockFetchResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockFetchResponse.business.locations[0].offerings[0].service = 'centers';
        mockFetchResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockFetchResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockFetchResponse.business.locations[0].offerings[1].active = true;
        mockFetchResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockFetchResponse.business.locations[0].offerings[1].service = 'centers';
        mockFetchResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockFetchResponse.business.locations[0].address.line1 = '123 Street';
        mockFetchResponse.business.locations[0].address.line2 = null;
        mockFetchResponse.business.locations[0].address.city = 'City';
        mockFetchResponse.business.locations[0].address.state = 'Idaho';
        mockFetchResponse.business.locations[0].address.postal_code = '47123';
        mockFetchResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockFetchResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockFetchResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockFetchResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockFetchResponse.business.reviews[0].first_name = 'First';
        mockFetchResponse.business.reviews[0].last_name = 'Last';
        mockFetchResponse.business.reviews[0].email = 'first.last@email.com';
        mockFetchResponse.business.reviews[0].phone = '1111111111';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(cancelEndpointURL, JSON.serialize(mockCancelResponse), 200, 'Success');
        mock.add(fetchEndpointURL, JSON.serialize(mockFetchResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.cancelAgreement(accountRecord.Id, 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5');
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_createReview_Fail_EmptyReviewRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty reviewRecordJSON parameter passed.'), 'Expected message to end with: Empty reviewRecordJSON parameter passed.');
    }

    @isTest static void test_createReview_Fail_InvalidReviewRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview('BAD JSON');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Invalid reviewRecordJSON parameter passed.'), 'Expected message to end with: Invalid reviewRecordJSON parameter passed.');
    }

    @isTest static void test_createReview_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_createReview_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_createReview_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_createReview_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Not Found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Review not found on external system.'), 'Expected message to end with: Review not found on external system.');
    }

    @isTest static void test_createReview_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_createReview_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500');
    }

    @isTest static void test_createReview_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord), flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_createReview_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Create Review record
        CCCAPIReqCreateReview.ReviewObject reviewRecord = new CCCAPIReqCreateReview.ReviewObject();
        reviewRecord.business_id = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Create Review
        CCCAPIRespCreateReview.ServerResponse mockResponse = new CCCAPIRespCreateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespCreateReview.ReviewObject();
        mockResponse.review.uuid = 'aef3962b-37a7-4fac-8548-82ec60468e2f';
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.createReview(JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.reviewRecord, 'Expected reviewRecord to not be null');
    }

    @isTest static void test_getActiveAgreementData_Fail_EmptyAccountId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty accountId parameter passed.'), 'Expected message to end with: Empty accountId parameter passed.');
    }

    @isTest static void test_getActiveAgreementData_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_getActiveAgreementData_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.business.locations[0].name = 'XYZ';
        mockResponse.business.locations[0].budget_currency = 'USD';
        mockResponse.business.locations[0].run_ads = false;
        mockResponse.business.locations[0].ads_status = 'unknown';
        mockResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockResponse.business.locations[0].offerings[0].active = true;
        mockResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[0].service = 'centers';
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockResponse.business.locations[0].offerings[1].active = true;
        mockResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[1].service = 'centers';
        mockResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockResponse.business.locations[0].address.line1 = '123 Street';
        mockResponse.business.locations[0].address.line2 = null;
        mockResponse.business.locations[0].address.city = 'City';
        mockResponse.business.locations[0].address.state = 'Idaho';
        mockResponse.business.locations[0].address.postal_code = '47123';
        mockResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockResponse.business.reviews[0].first_name = 'First';
        mockResponse.business.reviews[0].last_name = 'Last';
        mockResponse.business.reviews[0].email = 'first.last@email.com';
        mockResponse.business.reviews[0].phone = '1111111111';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing. - Received:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.business.locations[0].name = 'XYZ';
        mockResponse.business.locations[0].budget_currency = 'USD';
        mockResponse.business.locations[0].run_ads = false;
        mockResponse.business.locations[0].ads_status = 'unknown';
        mockResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockResponse.business.locations[0].offerings[0].active = true;
        mockResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[0].service = 'centers';
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockResponse.business.locations[0].offerings[1].active = true;
        mockResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[1].service = 'centers';
        mockResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockResponse.business.locations[0].address.line1 = '123 Street';
        mockResponse.business.locations[0].address.line2 = null;
        mockResponse.business.locations[0].address.city = 'City';
        mockResponse.business.locations[0].address.state = 'Idaho';
        mockResponse.business.locations[0].address.postal_code = '47123';
        mockResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockResponse.business.reviews[0].first_name = 'First';
        mockResponse.business.reviews[0].last_name = 'Last';
        mockResponse.business.reviews[0].email = 'first.last@email.com';
        mockResponse.business.reviews[0].phone = '1111111111';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid. - Received:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.business.locations[0].name = 'XYZ';
        mockResponse.business.locations[0].budget_currency = 'USD';
        mockResponse.business.locations[0].run_ads = false;
        mockResponse.business.locations[0].ads_status = 'unknown';
        mockResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockResponse.business.locations[0].offerings[0].active = true;
        mockResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[0].service = 'centers';
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockResponse.business.locations[0].offerings[1].active = true;
        mockResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[1].service = 'centers';
        mockResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockResponse.business.locations[0].address.line1 = '123 Street';
        mockResponse.business.locations[0].address.line2 = null;
        mockResponse.business.locations[0].address.city = 'City';
        mockResponse.business.locations[0].address.state = 'Idaho';
        mockResponse.business.locations[0].address.postal_code = '47123';
        mockResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockResponse.business.reviews[0].first_name = 'First';
        mockResponse.business.reviews[0].last_name = 'Last';
        mockResponse.business.reviews[0].email = 'first.last@email.com';
        mockResponse.business.reviews[0].phone = '1111111111';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The specified Business was not found.'), 'Expected message to end with: The specified Business was not found. - Received:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.error = 'Error';
        mockResponse.error_message = 'Error Message';
        mockResponse.error_code = '422';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly. - Received:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.business.locations[0].name = 'XYZ';
        mockResponse.business.locations[0].budget_currency = 'USD';
        mockResponse.business.locations[0].run_ads = false;
        mockResponse.business.locations[0].ads_status = 'unknown';
        mockResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockResponse.business.locations[0].offerings[0].active = true;
        mockResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[0].service = 'centers';
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockResponse.business.locations[0].offerings[1].active = true;
        mockResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[1].service = 'centers';
        mockResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockResponse.business.locations[0].address.line1 = '123 Street';
        mockResponse.business.locations[0].address.line2 = null;
        mockResponse.business.locations[0].address.city = 'City';
        mockResponse.business.locations[0].address.state = 'Idaho';
        mockResponse.business.locations[0].address.postal_code = '47123';
        mockResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockResponse.business.reviews[0].first_name = 'First';
        mockResponse.business.reviews[0].last_name = 'Last';
        mockResponse.business.reviews[0].email = 'first.last@email.com';
        mockResponse.business.reviews[0].phone = '1111111111';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500 - Received:' + response.message);
    }

    @isTest static void test_getActiveAgreementData_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Get API Setting - Fetch a Business
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Fetch_a_Business').one();
        String endpointURL = apiSetting.URL__c.replace(':businessId', accountRecord.Galore_Business_Id__c);

        // Mock Response - Fetch a Business
        CCCAPIRespFetchABusiness.ServerResponse mockResponse = new CCCAPIRespFetchABusiness.ServerResponse();
        mockResponse.business = new CCCAPIRespFetchABusiness.BusinessObject();
        mockResponse.business.business_id = 'XXXXXXXXXXXXXXXXXXXXXXXXXX';
        mockResponse.business.sales_contract_uuid = 'ZZZZZZZZZZZZZZZZZZ';
        mockResponse.business.locations = new List<CCCAPIRespFetchABusiness.LocationObject>();
        mockResponse.business.locations.add(new CCCAPIRespFetchABusiness.LocationObject());
        mockResponse.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.business.locations[0].salesforce_id = 'ABCDEFGHIJKLMNOPQR';
        mockResponse.business.locations[0].name = 'XYZ';
        mockResponse.business.locations[0].budget_currency = 'USD';
        mockResponse.business.locations[0].run_ads = false;
        mockResponse.business.locations[0].ads_status = 'unknown';
        mockResponse.business.locations[0].advertising_areas = new List<String>{'46033', '46062', '46032', '46074'};
        mockResponse.business.locations[0].monthly_advertising_budget_cents = 0;
        mockResponse.business.locations[0].monthly_advertising_budget = 0.0;
        mockResponse.business.locations[0].offerings = new List<CCCAPIRespFetchABusiness.OfferingObject>();
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[0].uuid = '3f69c7d1-41e1-4114-8642-49e14200eb81';
        mockResponse.business.locations[0].offerings[0].active = true;
        mockResponse.business.locations[0].offerings[0].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[0].service = 'centers';
        mockResponse.business.locations[0].offerings.add(new CCCAPIRespFetchABusiness.OfferingObject());
        mockResponse.business.locations[0].offerings[1].uuid = '500d8e6d-f218-4d2a-96c6-cd0697cb40ec';
        mockResponse.business.locations[0].offerings[1].active = true;
        mockResponse.business.locations[0].offerings[1].vertical = 'child_care';
        mockResponse.business.locations[0].offerings[1].service = 'centers';
        mockResponse.business.locations[0].address = new CCCAPIRespFetchABusiness.AddressObject();
        mockResponse.business.locations[0].address.line1 = '123 Street';
        mockResponse.business.locations[0].address.line2 = null;
        mockResponse.business.locations[0].address.city = 'City';
        mockResponse.business.locations[0].address.state = 'Idaho';
        mockResponse.business.locations[0].address.postal_code = '47123';
        mockResponse.business.reviews = new List<CCCAPIRespFetchABusiness.ReviewObject>();
        mockResponse.business.reviews.add(new CCCAPIRespFetchABusiness.ReviewObject());
        mockResponse.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.business.reviews[0].business_id = '32f8450d-973c-4dbf-8286-0e4b0e4b18bd';
        mockResponse.business.reviews[0].first_name = 'First';
        mockResponse.business.reviews[0].last_name = 'Last';
        mockResponse.business.reviews[0].email = 'first.last@email.com';
        mockResponse.business.reviews[0].phone = '1111111111';
        mockResponse.business.reviews[0].location_name = 'Location Name';
        mockResponse.business.reviews[0].verified = false;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.getActiveAgreementData(accountRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.businessRecord, 'businessRecord should not be null');
        System.assertNotEquals(null, response.accountRecord, 'accountRecord should not be null');
    }

    @isTest static void test_updateOffering_Fail_EmptyOfferingId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(null, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty offeringId parameter passed.'), 'Expected message to end with: Empty offeringId parameter passed.');
    }

    @isTest static void test_updateOffering_Fail_EmptyOfferingRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty offeringRecordJSON parameter passed.'), 'Expected message to end with: Empty offeringRecordJSON parameter passed.');
    }

    @isTest static void test_updateOffering_Fail_InvalidOfferingRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, 'BAD JSON');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Invalid offeringRecordJSON parameter passed.'), 'Expected message to end with: Invalid offeringRecordJSON parameter passed.');
    }

    @isTest static void test_updateOffering_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String offeringId = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', offeringId);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(offeringId, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_updateOffering_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', OFFERING_ID);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.offering = new CCCAPIRespUpdateOffering.OfferingObject();
        mockResponse.offering.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.offering.active = true;
        mockResponse.offering.capacity = 50;
        mockResponse.offering.vertical = '';
        mockResponse.offering.service = '';
        mockResponse.offering.min_months = 6;
        mockResponse.offering.max_months = 24;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_updateOffering_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', OFFERING_ID);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.offering = new CCCAPIRespUpdateOffering.OfferingObject();
        mockResponse.offering.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.offering.active = true;
        mockResponse.offering.capacity = 50;
        mockResponse.offering.vertical = '';
        mockResponse.offering.service = '';
        mockResponse.offering.min_months = 6;
        mockResponse.offering.max_months = 24;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_updateOffering_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', OFFERING_ID);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.offering = new CCCAPIRespUpdateOffering.OfferingObject();
        mockResponse.offering.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.offering.active = true;
        mockResponse.offering.capacity = 50;
        mockResponse.offering.vertical = '';
        mockResponse.offering.service = '';
        mockResponse.offering.min_months = 6;
        mockResponse.offering.max_months = 24;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Not Found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Offering not found on external system.'), 'Expected message to end with: Offering not found on external system.');
    }

    @isTest static void test_updateOffering_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', OFFERING_ID);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.error = 'Error';
        mockResponse.error_message = 'Error Message';
        mockResponse.error_code = '422';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_updateOffering_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', OFFERING_ID);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.offering = new CCCAPIRespUpdateOffering.OfferingObject();
        mockResponse.offering.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.offering.active = true;
        mockResponse.offering.capacity = 50;
        mockResponse.offering.vertical = '';
        mockResponse.offering.service = '';
        mockResponse.offering.min_months = 6;
        mockResponse.offering.max_months = 24;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500');
    }

    @isTest static void test_updateOffering_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String OFFERING_ID = '80ab6a75-ffd8-411c-bd76-5169fe226db5';

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(OFFERING_ID, JSON.serialize(offeringRecord), flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_updateOffering_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String offeringId = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';

        // Get API Setting - Update Offering
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Offering').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', offeringId);

        // Update Offering record
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord = new CCCAPIReqUpdateOffering.OfferingObject();
        offeringRecord.active = false;

        // Mock Response - Update Offering
        CCCAPIRespUpdateOffering.ServerResponse mockResponse = new CCCAPIRespUpdateOffering.ServerResponse();
        mockResponse.offering = new CCCAPIRespUpdateOffering.OfferingObject();
        mockResponse.offering.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.offering.active = true;
        mockResponse.offering.capacity = 50;
        mockResponse.offering.vertical = '';
        mockResponse.offering.service = '';
        mockResponse.offering.min_months = 6;
        mockResponse.offering.max_months = 24;

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateOffering(offeringId, JSON.serialize(offeringRecord));
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.offeringRecord, 'Expected offeringRecord to not be null');

    }

    @isTest static void test_updateProvider_Fail_EmptyProviderId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(null, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty providerId parameter passed.'), 'Expected message to end with: Empty providerId parameter passed.');
    }

    @isTest static void test_updateProvider_Fail_EmptyProviderRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String providerId = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(providerId, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty providerRecordJSON parameter passed.'), 'Expected message to end with: Empty providerRecordJSON parameter passed.');
    }

    @isTest static void test_updateProvider_Fail_InvalidProviderRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String providerId = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(providerId, 'BAD JSON');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Invalid providerRecordJSON parameter passed.'), 'Expected message to end with: Invalid providerRecordJSON parameter passed.');
    }

    @isTest static void test_updateProvider_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_updateProvider_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        // Mock Response - Update Provider
        CCCAPIRespUpdateProvider.ServerResponse mockResponse = new CCCAPIRespUpdateProvider.ServerResponse();
        mockResponse.provider = new CCCAPIRespUpdateProvider.ProviderObject();
        mockResponse.provider.name = 'Stepping Stone South Park Meadows';
        mockResponse.provider.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.provider.salesforce_id = '123abc-saleforce-id';
        mockResponse.provider.monthly_advertising_budget = 500.00;
        mockResponse.provider.budget_currency = 'USD';
        mockResponse.provider.advertising_areas = new List<String> {'78748', '77801', '93849'};
        mockResponse.provider.phone = '555-555-5555';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_updateProvider_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        // Mock Response - Update Provider
        CCCAPIRespUpdateProvider.ServerResponse mockResponse = new CCCAPIRespUpdateProvider.ServerResponse();
        mockResponse.provider = new CCCAPIRespUpdateProvider.ProviderObject();
        mockResponse.provider.name = 'Stepping Stone South Park Meadows';
        mockResponse.provider.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.provider.salesforce_id = '123abc-saleforce-id';
        mockResponse.provider.monthly_advertising_budget = 500.00;
        mockResponse.provider.budget_currency = 'USD';
        mockResponse.provider.advertising_areas = new List<String> {'78748', '77801', '93849'};
        mockResponse.provider.phone = '555-555-5555';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_updateProvider_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        // Mock Response - Update Provider
        CCCAPIRespUpdateProvider.ServerResponse mockResponse = new CCCAPIRespUpdateProvider.ServerResponse();
        mockResponse.provider = new CCCAPIRespUpdateProvider.ProviderObject();
        mockResponse.provider.name = 'Stepping Stone South Park Meadows';
        mockResponse.provider.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.provider.salesforce_id = '123abc-saleforce-id';
        mockResponse.provider.monthly_advertising_budget = 500.00;
        mockResponse.provider.budget_currency = 'USD';
        mockResponse.provider.advertising_areas = new List<String> {'78748', '77801', '93849'};
        mockResponse.provider.phone = '555-555-5555';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Not Found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Review not found on external system.'), 'Expected message to end with: Review not found on external system.');
    }

    @isTest static void test_updateProvider_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        // Mock Response - Update Provider
        CCCAPIRespUpdateProvider.ServerResponse mockResponse = new CCCAPIRespUpdateProvider.ServerResponse();
        mockResponse.error = 'Error';
        mockResponse.error_message = 'Error Message';
        mockResponse.error_code = '422';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_updateProvider_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500');
    }

    @isTest static void test_updateProvider_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord), flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_updateProvider_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Get API Setting - Update Provider
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Provider').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', PROVIDER_ID);

        // Update Provider record
        CCCAPIReqUpdateProvider.ProviderObject providerRecord = new CCCAPIReqUpdateProvider.ProviderObject();
        providerRecord.ads_status = 'inactive';

        // Mock Response - Update Provider
        CCCAPIRespUpdateProvider.ServerResponse mockResponse = new CCCAPIRespUpdateProvider.ServerResponse();
        mockResponse.provider = new CCCAPIRespUpdateProvider.ProviderObject();
        mockResponse.provider.name = 'Stepping Stone South Park Meadows';
        mockResponse.provider.uuid = 'afbded54-65ac-4e28-b7e4-3e62ce1af7f5';
        mockResponse.provider.salesforce_id = '123abc-saleforce-id';
        mockResponse.provider.monthly_advertising_budget = 500.00;
        mockResponse.provider.budget_currency = 'USD';
        mockResponse.provider.advertising_areas = new List<String> {'78748', '77801', '93849'};
        mockResponse.provider.phone = '555-555-5555';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateProvider(PROVIDER_ID, JSON.serialize(providerRecord));
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.providerRecord, 'Expected providerRecord to not be null');
    }

    @isTest static void test_updateReview_Fail_EmptyReviewId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(null, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty reviewId parameter passed.'), 'Expected message to end with: Empty reviewId parameter passed.');
    }

    @isTest static void test_updateReview_Fail_EmptyReviewRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty reviewRecordJSON parameter passed.'), 'Expected message to end with: Empty reviewRecordJSON parameter passed.');
    }

    @isTest static void test_updateReview_Fail_InvalidReviewRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, 'BAD JSON');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Invalid reviewRecordJSON parameter passed.'), 'Expected message to end with: Invalid reviewRecordJSON parameter passed.');
    }

    @isTest static void test_updateReview_Fail_Return200_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_updateReview_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 401, 'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_updateReview_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 403, 'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_updateReview_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 404, 'Not Found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Review not found on external system.'), 'Expected message to end with: Review not found on external system.');
    }

    @isTest static void test_updateReview_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 422, 'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_updateReview_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 500, 'Internal Server Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Failed: Status: Internal Server Error StatusCode: 500'), 'Expected message to end with: Failed: Status: Internal Server Error StatusCode: 500');
    }

    @isTest static void test_updateReview_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PROVIDER_ID = 'bfb60d13-7a48-46ca-9475-6ea88e7ddd3a';

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(PROVIDER_ID, JSON.serialize(reviewRecord), flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_updateReview_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Update Review record
        CCCAPIReqUpdateReview.ReviewObject reviewRecord = new CCCAPIReqUpdateReview.ReviewObject();
        reviewRecord.first_name = 'test';
        reviewRecord.last_name = 'test';
        reviewRecord.email = 'test@example.com';
        reviewRecord.phone = '8005551234';
        reviewRecord.location_name = 'test';

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse mockResponse = new CCCAPIRespUpdateReview.ServerResponse();
        mockResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        mockResponse.review.uuid = REVIEW_ID;
        mockResponse.review.first_name = 'test';
        mockResponse.review.last_name = 'test';
        mockResponse.review.email = 'test@example.com';
        mockResponse.review.phone = '8005551234';
        mockResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCActiveAgreementController.updateReview(REVIEW_ID, JSON.serialize(reviewRecord));
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.reviewRecord, 'Expected reviewRecord to not be null');
    }
}