/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 12/02/2020
Description: Test methods for CCCVettingController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCVettingCont_Test {
    private static CCCVettingController.ServerResponse response;

    @testSetup static void setup() {
        // Create Composer Service records
        CCCTestDataFactory.createComposerServiceRecords();

        // Create Account
        CCCTestDataFactory.createAccount('Test Account');

        // Retrieve our new Account
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

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

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void testGetVettingDataFail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.getVettingData(null);
            System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
            System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
        }
        Test.stopTest();
    }

    @isTest static void testGetVettingDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.getVettingData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assertNotEquals(null, response.message, 'message should be populated');
    }

    @isTest static void testGetVettingDataPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.getVettingData(opportunityRecord.Id);
            System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
            System.assertEquals(null, response.message, 'response has error:' + response.message);
            System.assertNotEquals(null, response.opportunityRecord, 'opportunityRecord should not be null');
            System.assertNotEquals(null, response.opportunityRecord.Composer_Service__c, 'opportunityRecord.Composer_Service__c should not be null');
            System.assertNotEquals(null, response.locationRecords, 'response.locationRecords should not be null');
            System.assertNotEquals(null, response.provinceOptions, 'response.provinceOptions should not be null');
        }
        Test.stopTest();
    }

    @isTest static void testSaveLocationRecordFail_EmptyLocation() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.saveLocationRecord(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationRecord parameter passed.'), 'Expected message to end with: Empty locationRecord parameter passed.');
    }

    @isTest static void testSaveLocationRecordFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        // Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery('Opportunity_Service_Area__c').one();
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Opportunity_Service_Area__c locationRecord = new Opportunity_Service_Area__c(Opportunity__c = opportunityRecord.Id);

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.saveLocationRecord(locationRecord, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assertNotEquals(null, response.message, 'message should be populated');
    }

    @isTest static void testSaveLocation_NewLocation() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Opportunity_Service_Area__c locationRecord = new Opportunity_Service_Area__c(Opportunity__c = opportunityRecord.Id);

        response = CCCVettingController.getVettingData(opportunityRecord.Id);
        Integer initialLocationsSize = response.locationRecords.size();

        Test.startTest();
        System.runAs(u) {
            response = CCCVettingController.saveLocationRecord(locationRecord);
            System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
            System.assertEquals(null, response.message, 'response has error:' + response.message);

            // Confirm that one location was added to the Opportunity
            response = CCCVettingController.getVettingData(opportunityRecord.Id);
            System.assert(response.locationRecords.size() == initialLocationsSize + 1);
        }
        Test.stopTest();
    }

}