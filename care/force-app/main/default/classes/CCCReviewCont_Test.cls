/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 01/08/2021
Description: Test methods for CCCReviewController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCReviewCont_Test {
    private static CCCReviewController.ServerResponse response;

    @testSetup static void setup() {

        // Create Composer Service records
        CCCTestDataFactory.createComposerServiceRecords();

        // Create Account
        CCCTestDataFactory.createAccount('Test Account');

        // Retrieve our new Account
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Assign a Galore Id for API calls
        accountRecord.Galore_Business_Id__c = 'XYZ';
        update accountRecord;


        // Retrieve our active Senior Care, Housing Composer Service record to assign to the Opportunity
        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Housing' AND Active__c = TRUE LIMIT 1];
        composerServiceRecord.Service_Specific_Fields__c = 'Age_Range__c,Capacity__c';
        update composerServiceRecord;

        // Create Opportunity
        CCCTestDataFactory.createOpportunity_SalesOrigination(accountRecord.Id, composerServiceRecord.Id);

        // Retrieve our new Opportunity
        Opportunity opportunitySORecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Create Opportunity Service Area records
        CCCTestDataFactory.createOpportunityServiceAreas(opportunitySORecord.Id);

        // Create Account Reviews
        List<Review_Reference__c> reviewRecords = new List<Review_Reference__c>();
        List<Opportunity_Service_Area__c> locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunitySORecord.Id).all();

        for (Opportunity_Service_Area__c locationRecord: locationRecords) {
            reviewRecords.add(new Review_Reference__c(
                Account__c = accountRecord.Id,
                Email__c = 'test@test.com',
                First_Name__c = 'First Name',
                Last_Name__c = 'Last Name',
                Phone__c = '1111111111',
                Location__c = locationRecord.Id
            ));
        }

        insert reviewRecords;

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void test_getReviewData_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCReviewController.getReviewData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_getReviewData_Fail_EmptyOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        Test.startTest();
        System.runAs(u) {
            response = CCCReviewController.getReviewData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty opportunityId parameter passed.'), 'Expected message to end with: Empty opportunityId parameter passed.');
    }

    @isTest static void test_getReviewData_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCReviewController.getReviewData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(3,response.locationRecords.size(), 'locationRecords list should be of size 3');
        System.assertEquals(3,response.reviewRecords.size(), 'reviewRecords list should be of size 3');
    }

    @isTest static void test_saveReviewRecord_Fail_EmptyReviewRecord() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        Test.startTest();
        System.runAs(u) {
            response = CCCReviewController.saveReviewRecord(null, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty reviewRecord parameter passed.'), 'Expected message to end with: Empty reviewRecord parameter passed.');
    }

    @isTest static void test_saveReviewRecord_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCReviewController.saveReviewRecord(new Review_Reference__c(), null, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_saveReviewRecord_Pass_APIUpdate() {
        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        CCCReviewController.ServerResponse response2;

        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Retrieve our new Account
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Review_Reference__c reviewRecord = new Review_Reference__c();
        reviewRecord.Account__c = accountRecord.Id;
        reviewRecord.Email__c = 'test@test.com';
        reviewRecord.First_Name__c = 'First Name';
        reviewRecord.Last_Name__c = 'Last Name';
        reviewRecord.Phone__c = '1111111111';
        reviewRecord.Location__c = locationRecord.Id;
        reviewRecord.Galore_Review_uuid__c = REVIEW_ID;

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Review').one();
        String endpointURL = apiSetting.URL__c.replace(':uuid', REVIEW_ID);

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse updateReviewResponse = new CCCAPIRespUpdateReview.ServerResponse();
        updateReviewResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        updateReviewResponse.review.uuid = REVIEW_ID;
        updateReviewResponse.review.first_name = 'test';
        updateReviewResponse.review.last_name = 'test';
        updateReviewResponse.review.email = 'test@example.com';
        updateReviewResponse.review.phone = '8005551234';
        updateReviewResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(updateReviewResponse), 200, 'Success');


        Test.startTest();
        System.runAs(u) {

            Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

            response = CCCReviewController.saveReviewRecord(reviewRecord, accountRecord.Galore_Business_Id__c);

            response2 = CCCReviewController.getReviewData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);

        System.assertEquals(false, response2.hasErrors, 'response has error:' + response2.message);
        System.assertEquals(null, response2.message, 'response has error:' + response2.message);
        System.assertEquals(4, response2.reviewRecords.size(), 'reviewRecords list should be of size 4');
    }

    @isTest static void test_saveReviewRecord_Pass_APIAdd() {
        final String REVIEW_ID = '844f93d1-4922-404e-b5ab-c8bcca89ad9c';

        CCCReviewController.ServerResponse response2;

        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Retrieve our new Account
        Account accountRecord = [SELECT Id, Galore_Business_Id__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Review_Reference__c reviewRecord = new Review_Reference__c();
        reviewRecord.Account__c = accountRecord.Id;
        reviewRecord.Email__c = 'test@test.com';
        reviewRecord.First_Name__c = 'First Name';
        reviewRecord.Last_Name__c = 'Last Name';
        reviewRecord.Phone__c = '1111111111';
        reviewRecord.Location__c = locationRecord.Id;

        // Get API Setting - Update Review
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Review').one();
        String endpointURL = apiSetting.URL__c;

        // Mock Response - Update Review
        CCCAPIRespUpdateReview.ServerResponse updateReviewResponse = new CCCAPIRespUpdateReview.ServerResponse();
        updateReviewResponse.review = new CCCAPIRespUpdateReview.ReviewObject();
        updateReviewResponse.review.uuid = REVIEW_ID;
        updateReviewResponse.review.first_name = 'test';
        updateReviewResponse.review.last_name = 'test';
        updateReviewResponse.review.email = 'test@example.com';
        updateReviewResponse.review.phone = '8005551234';
        updateReviewResponse.review.location_name = 'test';

        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(updateReviewResponse), 200, 'Success');


        Test.startTest();
        System.runAs(u) {

            Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

            response = CCCReviewController.saveReviewRecord(reviewRecord, accountRecord.Galore_Business_Id__c);

            response2 = CCCReviewController.getReviewData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);

        System.assertEquals(false, response2.hasErrors, 'response has error:' + response2.message);
        System.assertEquals(null, response2.message, 'response has error:' + response2.message);
        System.assertEquals(4, response2.reviewRecords.size(), 'reviewRecords list should be of size 4');
    }

}