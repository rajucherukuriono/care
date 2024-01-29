/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/13/2020
Description: Test methods for CCCServiceController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCServiceCont_Test {
    private static CCCServiceController.ServerResponse response;

    @testSetup static void setup() {

        // Create Composer Service records
        CCCTestDataFactory.createComposerServiceRecords();

        // Create Account
        CCCTestDataFactory.createAccount('Test Account');

        // Retrieve our new Account
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Retrieve our active Senior Care, Housing Composer Service record to assign to the Opportunity
        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Housing' AND Active__c = TRUE LIMIT 1];

        // Create Opportunity
        CCCTestDataFactory.createOpportunity_SalesOrigination(accountRecord.Id, composerServiceRecord.Id);

        // Retrieve our new Opportunity
        Opportunity opportunitySORecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Create Opportunity Service Area records
        CCCTestDataFactory.createOpportunityServiceAreas(opportunitySORecord.Id);

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void testGetServiceDataFail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.getServiceData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void testGetServiceDataFail_InvalidOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String invalidRecordId = 'XXXXXXXXXXXXXXXX';

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.getServiceData(invalidRecordId);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Unable to locate the Opportunity record specified.'), 'Expected message to end with: Unable to locate the Opportunity record specified.');
    }

    @isTest static void testGetServiceDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.getServiceData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetServiceDataPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.getServiceData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.opportunityRecord, 'opportunityRecord should not be null');
        System.assertEquals(8, response.composerServiceRecords.size(), 'composerServiceRecords list should be of size 8');
    }

    @isTest static void testSaveComposerServiceDataFail_EmptyComposerServiceRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Adult Day Care' AND Active__c = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(opportunityRecord.Id, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty composerServiceRecordId parameter passed.'), 'Expected message to end with: Empty composerServiceRecordId parameter passed.');
    }

    @isTest static void testSaveComposerServiceDataFail_EmptyOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Adult Day Care' AND Active__c = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(null, composerServiceRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void testSaveComposerServiceDataFail_InvalidComposerServiceRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String invalidRecordId = 'XXXXXXXXXXXXXXXX';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(opportunityRecord.Id, invalidRecordId);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('invalid ID field'), 'Expected message to contain: invalid ID field');
    }

    @isTest static void testSaveComposerServiceDataFail_InvalidOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String invalidRecordId = 'XXXXXXXXXXXXXXXX';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Adult Day Care' AND Active__c = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(invalidRecordId, composerServiceRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('invalid ID field'), 'Expected message to contain: invalid ID field');
    }

    @isTest static void testSaveComposerServiceDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Adult Day Care' AND Active__c = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(opportunityRecord.Id, composerServiceRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testSaveComposerServiceDataPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.Composer_Service__c = null;
        update opportunityRecord;

        Composer_Service__c composerServiceRecord = [SELECT Id FROM Composer_Service__c WHERE Vertical__c = 'Senior Care' AND License_Level__c = 'Adult Day Care' AND Active__c = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCServiceController.saveComposerServiceData(opportunityRecord.Id, composerServiceRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.opportunityRecord, 'opportunityRecord should not be null');
        System.assertEquals(composerServiceRecord.Id, response.opportunityRecord.Composer_Service__c, 'opportunityRecord.Composer_Service__c should be '+composerServiceRecord.Id);
    }
}