/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/12/2020
Description: Test methods for CCCPricingController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCPricingCont_Test {
    private static CCCPricingController.ServerResponse response;

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

        // Create Opportunity Service Area Records
        CCCTestDataFactory.createOpportunityServiceAreas(opportunitySORecord.Id);

        // Create Opportunity Location Service
        Id locationId = [SELECT Id FROM Opportunity_Service_Area__c WHERE Opportunity__c = :opportunitySORecord.Id LIMIT 1].Id;
        Id composerServiceId = [SELECT Id FROM Composer_Service__c LIMIT 1].Id;
        insert new Opportunity_Location_Service__c(
            Opportunity_Service_Area__c = locationId,
            Composer_Service__c = composerServiceId,
            Pricing_Tier__c = 'Tier 1',
            Advertising_Spend__c = 300.00
        );

        // Create Primary Contact
        CCCTestDataFactory.createContact(accountRecord.Id, 'Test Primary Contact');

        Contact contactRecordPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test Primary Contact'];

        // Create Non Primary Contact
        CCCTestDataFactory.createContact(accountRecord.Id, 'Test NonPrimary Contact');

        Contact contactRecordNonPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test NonPrimary Contact'];

        // Create New Contact
        CCCTestDataFactory.createContact(accountRecord.Id, 'Test New Contact');

        // Create Opportunity Contact Role - Primary
        CCCTestDataFactory.createOpportunityContactRole(contactRecordPrimary.Id, opportunitySORecord.Id);

        OpportunityContactRole opportunityContactRolePrimaryRecord = [SELECT Id FROM OpportunityContactRole WHERE ContactId = :contactRecordPrimary.Id];
        opportunityContactRolePrimaryRecord.IsPrimary = true;

        update opportunityContactRolePrimaryRecord;

        // Create Opportunity Contact Role - Non Primary
        CCCTestDataFactory.createOpportunityContactRole(contactRecordNonPrimary.Id, opportunitySORecord.Id);

        OpportunityContactRole opportunityContactRoleNonPrimaryRecord = [SELECT Id FROM OpportunityContactRole WHERE ContactId = :contactRecordNonPrimary.Id];

        update opportunityContactRoleNonPrimaryRecord;

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void testGetPricingDataFail_EmptyOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.getPricingData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty opportunityId parameter passed.'), 'Expected message to end with: Empty opportunityId parameter passed.');
    }

    @isTest static void testGetPricingDataFail_InvalidOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String invalidRecordId = 'XXXXXXXXXXXXXXXX';

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.getPricingData(invalidRecordId);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('invalid ID field'), 'Expected message to contain: invalid ID field');
    }

    @isTest static void testGetPricingDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.getPricingData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetPricingDataPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.getPricingData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.customPricingIndividualMinAmount, 'customPricingIndividualMinAmount should not be null');
        System.assertEquals(3,response.locations.size(), 'locationRecords list should be of size 3');
    }

    @isTest static void testSavePricingDataFail_BadLocationRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(opportunityRecord.Id, 'INVALID JSON');
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Invalid locationRecordJSON parameter passed.'), 'Expected message to end with: Invalid locationRecordJSON parameter passed.');
    }

    @isTest static void testSavePricingDataFail_EmptyLocationRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(opportunityRecord.Id, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationRecordJSON parameter passed.'), 'Expected message to end with: Empty locationRecordJSON parameter passed.');
    }

    @isTest static void testSavePricingDataFail_EmptyOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PRICING_TIER = 'Tier 2';
        final Decimal AMOUNT = 400.00;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        response = CCCPricingController.getPricingData(opportunityRecord.Id);

        CCCPricingController.Location locationRecord = response.locations[0];
        locationRecord.primaryService.pricingTierName = PRICING_TIER;
        locationRecord.amount = AMOUNT;

        String locationRecordJSON = JSON.serialize(locationRecord);

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(null, locationRecordJSON);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty opportunityId parameter passed.'), 'Expected message to end with: Empty opportunityId parameter passed.');
    }

    @isTest static void testSavePricingDataFail_InvalidOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String INVALID_RECORD_ID = 'XXXXXXXXXXXXXXXX';
        final String PRICING_TIER = 'Tier 2';
        final Decimal AMOUNT = 400.00;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        response = CCCPricingController.getPricingData(opportunityRecord.Id);

        CCCPricingController.Location locationRecord = response.locations[0];
        locationRecord.primaryService.pricingTierName = PRICING_TIER;
        locationRecord.amount = AMOUNT;

        String locationRecordJSON = JSON.serialize(locationRecord);

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(INVALID_RECORD_ID, locationRecordJSON);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('invalid ID field'), 'Expected message to contain: invalid ID field');
    }

    @isTest static void testSavePricingDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        final String PRICING_TIER = 'Tier 2';
        final Decimal AMOUNT = 400.00;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        response = CCCPricingController.getPricingData(opportunityRecord.Id);

        CCCPricingController.Location locationRecord = response.locations[0];
        locationRecord.primaryService.pricingTierName = PRICING_TIER;
        locationRecord.amount = AMOUNT;

        String locationRecordJSON = JSON.serialize(locationRecord);

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(opportunityRecord.Id, locationRecordJSON, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testSavePricingDataPass_SO() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String PRICING_TIER = 'Tier 2';
        final Decimal AMOUNT = 300.00;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        response = CCCPricingController.getPricingData(opportunityRecord.Id);

        CCCPricingController.Location locationRecord = response.locations[0];
        locationRecord.primaryService.pricingTierName = PRICING_TIER;
        locationRecord.amount = AMOUNT;

        String locationRecordJSON = JSON.serialize(locationRecord);

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePricingData(opportunityRecord.Id, locationRecordJSON);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(PRICING_TIER, response.locations[0].primaryService.pricingTierName, 'Expected locationRecords[0].pricingTier to be '+PRICING_TIER);
        System.assertEquals(AMOUNT, response.locations[0].amount, 'Expected locationRecords[0].amount to be '+AMOUNT);
        System.assertEquals(3,response.locations.size(), 'locationRecords list should be of size 3');
    }

    @isTest static void test_SaveCouponCode_NullOpportunityId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveCouponCode(null, locationRecord.Id, 'COUPON CODE', '', false);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty opportunityId parameter passed.'), 'Expected message to end with: Empty opportunityId parameter passed.');
    }

    @isTest static void test_SaveCouponCode_NullLocationId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveCouponCode(opportunityRecord.Id, null, 'COUPON CODE', '', false);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationId parameter passed.'), 'Expected message to end with: Empty locationId parameter passed.');
    }

    @isTest static void test_SaveCouponCode_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveCouponCode(opportunityRecord.Id, locationRecord.Id, 'COUPON CODE', '', false, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_SaveCouponCode_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveCouponCode(opportunityRecord.Id, locationRecord.Id, 'COUPON CODE', '', false);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_SaveCouponCode_Pass_CopyToAllLocations() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).one();

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveCouponCode(opportunityRecord.Id, locationRecord.Id, 'COUPON CODE', '', true);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void test_SaveContactFail_EmptyContactRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveContact(opportunityRecord.Id, null, false);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Empty contactRecordJSON parameter passed'), 'Expected message to contain: Empty contactRecordJSON parameter passed');
    }

    @isTest static void test_SaveContactFail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Contact contactRecord = new Contact();
        contactRecord.AccountId = opportunityRecord.AccountId;
        contactRecord.LastName = 'New Contact';

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveContact(null, JSON.serialize(contactRecord), false);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Empty recordId parameter passed'), 'Expected message to contain: Empty recordId parameter passed');
    }

    @isTest static void test_SaveContactFail_InvalidContactRecordJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Contact contactRecord = new Contact();
        contactRecord.AccountId = opportunityRecord.AccountId;
        contactRecord.LastName = 'New Contact';

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveContact(opportunityRecord.Id, '{BAD JSON', false);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Invalid contactRecordJSON parameter passed'), 'Expected message to contain: Invalid contactRecordJSON parameter passed');
    }

    @isTest static void test_SaveContactFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Contact contactRecord = new Contact();
        contactRecord.AccountId = opportunityRecord.AccountId;
        contactRecord.LastName = 'New Contact';

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.saveContact(opportunityRecord.Id, JSON.serialize(contactRecord), false, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Throw Root Exception Unit Test'), 'Expected message to contain: Throw Root Exception Unit Test');
    }

    @isTest static void test_SaveContactPass_ExistingContact() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'Test Primary Contact' LIMIT 1];
        CCCUtils.ServerResponse rUtils;
        Contact updatedContactRecord;

        contactRecord.MailingStreet = 'Updated MailingStreet';

        Test.startTest();
        System.runAs(u) {

        }
        response = CCCPricingController.saveContact(opportunityRecord.Id, JSON.serialize(contactRecord), false);

        // Fetch updated Contact record
        updatedContactRecord = (Contact) CCCQuery.get('Contact').equalsId(contactRecord.Id).one();
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'Expected message to be null, actual: '+response.message);
        System.assert(response.contactRecords.size() > 0, 'contactRecords list should not be empty');
        System.assertNotEquals(null, response.primaryContactId, 'primaryContactId should not be null');
        System.assertEquals('Updated MailingStreet', updatedContactRecord.MailingStreet, 'MailingStreet did not get updated.');
    }

    @isTest static void test_SaveContactPass_NewContact() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        List<Contact> contactRecords = (List<Contact>) CCCQuery.get('Contact').equals('AccountId', opportunityRecord.AccountId).all();

        CCCUtils.ServerResponse rUtils;
        Contact updatedContactRecord;

        Contact contactRecord = new Contact();
        contactRecord.AccountId = opportunityRecord.AccountId;
        contactRecord.LastName = 'New Contact';

        Test.startTest();
        System.runAs(u) {
            System.assertEquals(3, contactRecords.size(), 'contactRecords list should be of size 3');

            response = CCCPricingController.saveContact(opportunityRecord.Id, JSON.serialize(contactRecord), false);
    
            contactRecord = [SELECT Id FROM Contact WHERE LastName = 'New Contact' LIMIT 1];
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'Expected message to be null, actual: '+response.message);
        System.assertEquals(4, response.contactRecords.size(), 'contactRecords list should be of size 4');
        System.assertNotEquals(null, response.primaryContactId, 'primaryContactId should not be null');
        System.assertNotEquals(null, contactRecord, 'New contact did not get inserted.');
    }

    @isTest static void test_SavePrimaryContactFail_EmptyContactId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePrimaryContact(opportunityRecord.Id, null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Empty contactId parameter passed'), 'Expected message to contain: Empty contactId parameter passed');
    }

    @isTest static void test_SavePrimaryContactFail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Contact contactRecordNonPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test NonPrimary Contact'];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePrimaryContact(null, contactRecordNonPrimary.Id);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Empty recordId parameter passed'), 'Expected message to contain: Empty recordId parameter passed');
    }

    @isTest static void test_SavePrimaryContactFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Contact contactRecordNonPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test NonPrimary Contact'];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePrimaryContact(opportunityRecord.Id, contactRecordNonPrimary.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Throw Root Exception Unit Test'), 'Expected message to contain: Throw Root Exception Unit Test');
    }

    @isTest static void test_SavePrimaryContact_Pass_ExistingOpportunityContactRole() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Contact contactRecordNonPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test NonPrimary Contact'];
        Contact contactRecordPrimary = [SELECT Id FROM Contact WHERE LastName = 'Test Primary Contact'];
        OpportunityContactRole primaryOppContactRole = [SELECT ContactId FROM OpportunityContactRole WHERE IsPrimary = TRUE LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            System.assertEquals(primaryOppContactRole.ContactId, contactRecordPrimary.Id, 'The Primary Contact is not set correctly prior to saving the new Primary Contact');

            response = CCCPricingController.savePrimaryContact(opportunityRecord.Id, contactRecordNonPrimary.Id);
        }

        Test.stopTest();

        System.assertEquals(null, response.message, 'Expected message to be null, actual: '+response.message);
        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assert(response.contactRecords.size() > 0, 'contactRecords list should not be empty');
        System.assertNotEquals(null, response.primaryContactId, 'primaryContactId should not be null');
        System.assertEquals(response.primaryContactId, contactRecordNonPrimary.Id, 'primaryContactId did not change');
    }

    @isTest static void test_SavePrimaryContact_Pass_NewOpportunityContactRole() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        Contact contactRecordNew = [SELECT Id FROM Contact WHERE LastName = 'Test New Contact'];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.savePrimaryContact(opportunityRecord.Id, contactRecordNew.Id);
        }
        Test.stopTest();

        System.assertEquals(null, response.message, 'Expected message to be null, actual: '+response.message);
        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assert(response.contactRecords.size() > 0, 'contactRecords list should not be empty');
        System.assertNotEquals(null, response.primaryContactId, 'primaryContactId should not be null');
        System.assertEquals(response.primaryContactId, contactRecordNew.Id, 'primaryContactId did not change');
    }

    @isTest static void test_updatePlatformFeeWaived_Pass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.updatePlatformFeeWaived(opportunityRecord.Id, 1.00);
        }
        Test.stopTest();

        opportunityRecord = [SELECT Platform_Fee_Waived__c FROM Opportunity WHERE Id = :opportunityRecord.Id];

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'Expected message to be null, actual: ' + response.message);
        System.assertEquals(1.00, opportunityRecord.Platform_Fee_Waived__c, 'Expected Platform_Fee_Waived__c to be 1.00');
    }

    @isTest static void test_updatePlatformFeeWaived_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCPricingController.updatePlatformFeeWaived(opportunityRecord.Id, 1.00, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.contains('Throw Root Exception Unit Test'), 'Expected message to contain: Throw Root Exception Unit Test');
   }

}