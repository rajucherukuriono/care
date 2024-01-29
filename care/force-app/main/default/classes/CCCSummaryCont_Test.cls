/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 12/02/2020
Description: Test methods for CCCSummaryController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCSummaryCont_Test {
    private static CCCSummaryController.ServerResponse response;

    @testSetup static void setup() {
        // Create Composer Service records
        CCCTestDataFactory.createComposerServiceRecords();

        // Create Account
        CCCTestDataFactory.createAccount('Test Account');

        // Retrieve our new Account
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Create Primary Contact
        CCCTestDataFactory.createContact(accountRecord.Id, 'Test Primary Contact');

        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'Test Primary Contact'];

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

        // Create Opportunity Location Service record
        Opportunity_Service_Area__c locationRecord = [SELECT Id FROM Opportunity_Service_Area__c WHERE Name='Service Area 3 - Johnson County' LIMIT 1];
        Composer_Service__c composerServiceRecordTwo = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Home Care' AND Active__c = TRUE LIMIT 1];
        CCCTestDataFactory.createOpportunityLocationService(locationRecord.Id, composerServiceRecordTwo.Id, 'Tier 1', 300);

        // Create Opportunity Contact Roles for each Opportunity
        CCCTestDataFactory.createOpportunityContactRole(contactRecord.Id, opportunitySORecord.Id);

        // Make all of them Primary
        List<OpportunityContactRole> opportunityContactRoleRecords = [SELECT Id FROM OpportunityContactRole WHERE ContactId = :contactRecord.Id];

        for (OpportunityContactRole oppContactRoleRecord: opportunityContactRoleRecords) {
            oppContactRoleRecord.IsPrimary = true;
        }

        update opportunityContactRoleRecords;

        // Insert reviews
        List<Review_Reference__c> reviews = new List<Review_Reference__c>();
        Review_Reference__c review = new Review_Reference__c();
        review.First_Name__c = 'First';
        review.Last_Name__c = 'Last';
        review.Email__c = 'first.last@email.com';
        review.Phone__c = '1234567890';
        review.Account__c = accountRecord.Id;

        reviews.add(review);

        insert reviews;

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void test_getSummaryData_Fail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getSummaryData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void test_getSummaryData_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getSummaryData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_getSummaryData_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getSummaryData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_publishAgreement_Fail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void test_publishAgreement_Fail_InvalidOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String invalidRecordId = 'XXXXXXXXXXXXXXXX';

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(invalidRecordId);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Unable to locate the Opportunity record specified.'), 'Expected message to end with: Unable to locate the Opportunity record specified.');
    }

    @isTest static void test_publishAgreement_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_publishAgreement_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        accountRecord.Galore_Business_Id__c = 'XYZ';
        update accountRecord;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').field('Account.Galore_Business_Id__c').equalsId(opportunityRecord.Id).one();

        // Get API Setting - Create Sales Contract
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        List<Opportunity_Service_Area__c> locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).all();

        // Mock Response - Create Sales Contract
        CCCAPIRespCreateSalesContract.ServerResponse mockResponse = new CCCAPIRespCreateSalesContract.ServerResponse();
        mockResponse.sales_contract = new CCCAPIRespCreateSalesContract.SalesforceContractObject();
        mockResponse.sales_contract.uuid = 'a84ac300-eaa4-4d7c-93b2-f35a416cfdaa';
        mockResponse.sales_contract.salesforce_opportunity_id = opportunityRecord.Id;
        mockResponse.sales_contract.contract_status = 'published';
        mockResponse.sales_contract.business_id = 'XYZ';
        mockResponse.sales_contract.business = new CCCAPIRespCreateSalesContract.BusinessObject();
        mockResponse.sales_contract.business.business_id = 'XYZ';
        mockResponse.sales_contract.business.locations = new List<CCCAPIRespCreateSalesContract.LocationObject>();
        mockResponse.sales_contract.business.locations.add(new CCCAPIRespCreateSalesContract.LocationObject());
        mockResponse.sales_contract.business.locations[0].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.sales_contract.business.locations[0].salesforce_id = locationRecords[0].Id;
        mockResponse.sales_contract.business.locations[0].name = 'Service Area 1 - Marion County';
        mockResponse.sales_contract.business.locations[0].budget_currency = 'USD';
        mockResponse.sales_contract.business.locations[0].advertising_areas = new List<String>{'46107', '46183', '46201', '46202', '46203', '46204', '46205', '46208', '46214', '46216', '46217', '46218', '46219', '46220', '46221', '46222', '46224', '46225', '46226', '46227', '46228', '46229', '46231', '46234', '46235', '46236', '46237', '46239', '46240', '46241', '46250', '46254', '46256', '46259', '46260', '46268', '46278'};
        mockResponse.sales_contract.business.locations[0].monthly_advertising_budget = 300.00;
        mockResponse.sales_contract.business.locations[0].offerings = new List<CCCAPIRespCreateSalesContract.OfferingObject>();
        mockResponse.sales_contract.business.locations[0].offerings.add(new CCCAPIRespCreateSalesContract.OfferingObject());
        mockResponse.sales_contract.business.locations[0].offerings[0].uuid = 'XXXXXXXXXXXXXXX';
        mockResponse.sales_contract.business.locations[0].offerings[0].active = true;
        mockResponse.sales_contract.business.locations[0].offerings[0].vertical = 'senior_care';
        mockResponse.sales_contract.business.locations[0].offerings[0].service = 'housing';
        mockResponse.sales_contract.business.locations[0].offerings[0].min_months = 12;
        mockResponse.sales_contract.business.locations[0].offerings[0].max_months = 36;
        mockResponse.sales_contract.business.locations[0].address = new CCCAPIRespCreateSalesContract.AddressObject();
        mockResponse.sales_contract.business.locations[0].address.line1 = '5875 Castle Creek Pkwy N Dr #300';
        mockResponse.sales_contract.business.locations[0].address.line2 = '#300';
        mockResponse.sales_contract.business.locations[0].address.city = 'Indianpolis';
        mockResponse.sales_contract.business.locations[0].address.state = 'IN';
        mockResponse.sales_contract.business.locations[0].address.postal_code = '46250';

        mockResponse.sales_contract.business.locations.add(new CCCAPIRespCreateSalesContract.LocationObject());
        mockResponse.sales_contract.business.locations[1].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.sales_contract.business.locations[1].salesforce_id = locationRecords[1].Id;
        mockResponse.sales_contract.business.locations[1].name = 'Service Area 2 - Hamilton County';
        mockResponse.sales_contract.business.locations[1].budget_currency = 'USD';
        mockResponse.sales_contract.business.locations[1].advertising_areas = new List<String>{'46030', '46031', '46032', '46033', '46034', '46037', '46038', '46060', '46062', '46069', '46079', '46280', '46290'};
        mockResponse.sales_contract.business.locations[1].monthly_advertising_budget = 400.00;
        mockResponse.sales_contract.business.locations[1].offerings = new List<CCCAPIRespCreateSalesContract.OfferingObject>();
        mockResponse.sales_contract.business.locations[1].offerings.add(new CCCAPIRespCreateSalesContract.OfferingObject());
        mockResponse.sales_contract.business.locations[1].offerings[0].uuid = 'XXXXXXXXXXXXXXX';
        mockResponse.sales_contract.business.locations[1].offerings[0].active = true;
        mockResponse.sales_contract.business.locations[1].offerings[0].vertical = 'senior_care';
        mockResponse.sales_contract.business.locations[1].offerings[0].service = 'housing';
        mockResponse.sales_contract.business.locations[1].offerings[0].min_months = 12;
        mockResponse.sales_contract.business.locations[1].offerings[0].max_months = 36;
        mockResponse.sales_contract.business.locations[1].address = new CCCAPIRespCreateSalesContract.AddressObject();
        mockResponse.sales_contract.business.locations[1].address.line1 = '1 Civic Square';
        mockResponse.sales_contract.business.locations[1].address.line2 = '#300';
        mockResponse.sales_contract.business.locations[1].address.city = 'Carmel';
        mockResponse.sales_contract.business.locations[1].address.state = 'IN';
        mockResponse.sales_contract.business.locations[1].address.postal_code = '46032';

        mockResponse.sales_contract.business.locations.add(new CCCAPIRespCreateSalesContract.LocationObject());
        mockResponse.sales_contract.business.locations[2].uuid = '0900d1d5-23c7-4276-b16f-c28df63e6ed1';
        mockResponse.sales_contract.business.locations[2].salesforce_id = locationRecords[2].Id;
        mockResponse.sales_contract.business.locations[2].name = 'Service Area 3 - Johnson County';
        mockResponse.sales_contract.business.locations[2].budget_currency = 'USD';
        mockResponse.sales_contract.business.locations[2].advertising_areas = new List<String>{'46106', '46124', '46131', '46142', '46143', '46162', '46164', '46181', '46184'};
        mockResponse.sales_contract.business.locations[2].monthly_advertising_budget = 900.00;
        mockResponse.sales_contract.business.locations[2].offerings = new List<CCCAPIRespCreateSalesContract.OfferingObject>();
        mockResponse.sales_contract.business.locations[2].offerings.add(new CCCAPIRespCreateSalesContract.OfferingObject());
        mockResponse.sales_contract.business.locations[2].offerings[0].uuid = 'XXXXXXXXXXXXXXX';
        mockResponse.sales_contract.business.locations[2].offerings[0].active = true;
        mockResponse.sales_contract.business.locations[2].offerings[0].vertical = 'senior_care';
        mockResponse.sales_contract.business.locations[2].offerings[0].service = 'housing';
        mockResponse.sales_contract.business.locations[2].offerings[0].min_months = 12;
        mockResponse.sales_contract.business.locations[2].offerings[0].max_months = 36;
        mockResponse.sales_contract.business.locations[2].offerings.add(new CCCAPIRespCreateSalesContract.OfferingObject());
        mockResponse.sales_contract.business.locations[2].offerings[1].uuid = 'XXXXXXXXXXXXXXX';
        mockResponse.sales_contract.business.locations[2].offerings[1].active = true;
        mockResponse.sales_contract.business.locations[2].offerings[1].vertical = 'senior_care';
        mockResponse.sales_contract.business.locations[2].offerings[1].service = 'home_care';
        mockResponse.sales_contract.business.locations[2].offerings[1].min_months = 12;
        mockResponse.sales_contract.business.locations[2].offerings[1].max_months = 36;
        mockResponse.sales_contract.business.locations[2].address = new CCCAPIRespCreateSalesContract.AddressObject();
        mockResponse.sales_contract.business.locations[2].address.line1 = '5 E Jefferson St.';
        mockResponse.sales_contract.business.locations[2].address.line2 = '#300';
        mockResponse.sales_contract.business.locations[2].address.city = 'Franklin';
        mockResponse.sales_contract.business.locations[2].address.state = 'IN';
        mockResponse.sales_contract.business.locations[2].address.postal_code = '46131';

        mockResponse.sales_contract.business.reviews = new List<CCCAPIRespCreateSalesContract.ReviewObject>();
        mockResponse.sales_contract.business.reviews.add(new CCCAPIRespCreateSalesContract.ReviewObject());
        mockResponse.sales_contract.business.reviews[0].uuid = '96208710-751f-459f-bede-9976eecc7c8d';
        mockResponse.sales_contract.business.reviews[0].business_id = 'XYZ';
        mockResponse.sales_contract.business.reviews[0].first_name = 'First';
        mockResponse.sales_contract.business.reviews[0].last_name = 'Last';
        mockResponse.sales_contract.business.reviews[0].email = 'first.last@email.com';
        mockResponse.sales_contract.business.reviews[0].phone = '1234567890';

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, JSON.serialize(mockResponse), 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
    }

    @isTest static void test_publishAgreement_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',401,'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing. - Received:' + response.message);
    }

    @isTest static void test_publishAgreement_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',403,'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid. - Received:' + response.message);
    }

    @isTest static void test_publishAgreement_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',404,'Not found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Sales Contract not found on external system.'), 'Expected message to end with: Sales Contract not found on external system. - Received:' + response.message);
    }

    @isTest static void test_publishAgreement_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',422,'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly. - Received:' + response.message);
    }

    @isTest static void test_publishAgreement_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',500,'Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'Expected message to not be null');
    }

    @isTest static void test_publishAgreement_Fail_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON', 200, 'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.publishAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assert(response.message.endsWith('BAD JSON'), 'Expected message to end with: BAD JSON - Received:' + response.message);
        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    }

    @isTest static void test_voidAgreement_Fail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void test_voidAgreement_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_voidAgreement_Pass_Return200() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String BUSINESS_ID = 'XYZ';
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"'+BUSINESS_ID+'"}}',200,'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_voidAgreement_Fail_Return401() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',401,'Unauthorized');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is missing.'), 'Expected message to end with: The API Key for the external system is missing.');
    }

    @isTest static void test_voidAgreement_Fail_Return403() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',403,'Forbidden');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The API Key for the external system is invalid.'), 'Expected message to end with: The API Key for the external system is invalid.');
    }

    @isTest static void test_voidAgreement_Fail_Return404() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',404,'Not found');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Sales Contract not found on external system.'), 'Expected message to end with: Sales Contract not found on external system.');
    }

    @isTest static void test_voidAgreement_Fail_Return422() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',422,'Unprocessable Entity');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('The payload for the external API is not formatted correctly.'), 'Expected message to end with: The payload for the external API is not formatted correctly.');
    }

    @isTest static void test_voidAgreement_Fail_BadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{BAD JSON',200,'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('BAD JSON'), 'Expected message to end with: BAD JSON');
    }

    @isTest static void test_voidAgreement_Fail_Return500() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();
        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':uuid',opportunityRecord.Agreement_Id__c);

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"uuid"}}',500,'Error');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.voidAgreement(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'Expected message to not be null');
    }

    @isTest static void test_getVoidEnablement_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

        Opportunity opportunityRecord = [SELECT Id, Agreement_Id__c, StageName FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getVoidEnablement(opportunityRecord, globalSettings, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_getVoidEnablement_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

        Opportunity opportunityRecord = [SELECT Id, Agreement_Id__c, StageName FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getVoidEnablement(opportunityRecord, globalSettings);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_getPublishEnablement_Fail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

        Opportunity opportunityRecord = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getPublishEnablement(opportunityRecord, globalSettings, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_getPublishEnablement_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCSummaryController.getPublishEnablement(opportunityRecord, globalSettings);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

}