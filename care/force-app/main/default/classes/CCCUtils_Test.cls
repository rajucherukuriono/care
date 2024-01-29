/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 12/02/2020
Description: Test methods for CCCUtils Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCUtils_Test {
    private static CCCUtils.ServerResponse response;
    private static String className = 'CCCUtils';

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
    }


    // @isTest static void testCalculateMonthDifferenceFail_EmptyEndDate() {
    //     Date endDate = System.today();

    //     Test.startTest();
    //     response = CCCUtils.calculateMonthDifference(endDate, null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty endDate parameter passed.', response.message, 'Expected message: Empty endDate parameter passed.');
    // }

    // @isTest static void testCalculateMonthDifferenceFail_EmptyStartDate() {
    //     Date startDate = System.today();

    //     Test.startTest();
    //     response = CCCUtils.calculateMonthDifference(null, startDate);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty startDate parameter passed.', response.message, 'Expected message: Empty startDate parameter passed.');
    // }

    // @isTest static void testCalculateMonthDifferenceFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Date startDate = System.today();
    //     Date endDate = System.today();

    //     Test.startTest();
    //     response = CCCUtils.calculateMonthDifference(startDate, endDate, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testCalculateMonthDifferencePass() {
    //     Date startDate = System.today();
    //     Date endDate = System.today().addMonths(2);

    //     Test.startTest();
    //     response = CCCUtils.calculateMonthDifference(startDate, endDate);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
    //     System.assertEquals(null, response.message, 'Expected message to be null');
    //     System.assertEquals(2, response.monthDifference);
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     final Date today = System.today();
    //     final String oppType = 'Remaining Month Supersede';
    //     final Date referenceDate = Date.newInstance(today.year(),12,31);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, referenceDate, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_EmptyReferenceDate() {
    //     final Date today = System.today();
    //     final String oppType = 'Remaining Month Supersede';
    //     //final Date referenceDate = Date.newInstance(today.year(),12,31);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty referenceDate parameter passed.', response.message, 'Expected message: Empty referenceDate parameter passed.');
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_EmptyOppType() {
    //     final Date today = System.today();
    //     //final String oppType = 'Remaining Month Supersede';
    //     final Date referenceDate = Date.newInstance(today.year(),12,31);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(null, todaysDate, referenceDate);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty oppType parameter passed.', response.message, 'Expected message: Empty oppType parameter passed.');
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_RemainingMonthSupersede() {
    //     final Date today = System.today();
    //     final String oppType = 'Remaining Month Supersede';
    //     final Date referenceDate = Date.newInstance(today.year(),12,31);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, referenceDate);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(expectedStartDate, response.calculatedDate, 'Expected calculatedDate to be '+expectedStartDate);
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_RemainingMonthSupersede1stOfTheMonth() {
    //     final Date today = System.today();
    //     final String oppType = 'Remaining Month Supersede';
    //     final Date referenceDate = Date.newInstance(today.year(),12,1);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, referenceDate);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(expectedStartDate, response.calculatedDate, 'Expected calculatedDate to be '+expectedStartDate);
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_12MonthSupersede() {
    //     final Date today = System.today();
    //     final String oppType = '12 Month Supersede';
    //     final Date referenceDate = Date.newInstance(today.year(),1,1);
    //     final Date todaysDate = Date.newInstance(today.year(),7,23);
    //     final Date expectedStartDate = Date.newInstance(today.year(),8,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, referenceDate);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(expectedStartDate, response.calculatedDate, 'Expected calculatedDate to be '+expectedStartDate);
    // }

    // @isTest static void testCalculateCSAgreementNextAvailableWebAdStartDatePass_Renewal() {
    //     final Date today = System.today();
    //     final String oppType = 'Renewal';
    //     final Date referenceDate = Date.newInstance(today.year(),12,31);
    //     final Date todaysDate = Date.newInstance(today.year(),3,31);
    //     final Date expectedStartDate = Date.newInstance(today.year()+1,1,1);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementNextAvailableWebAdStartDate(oppType, todaysDate, referenceDate);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(expectedStartDate, response.calculatedDate, 'Expected calculatedDate to be '+expectedStartDate);
    // }

    // @isTest static void testCalculateCSAgreementWebAdEndDateFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     final Date today = System.today();
    //     final Date startDate = Date.newInstance(today.year(),1,15);
    //     final String oppType = '12 Month Supersede';

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementWebAdEndDate(startDate, oppType, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testCalculateCSAgreementWebAdEndDateFail_EmptyOppType() {
    //     final Date today = System.today();
    //     final Date startDate = Date.newInstance(today.year(),1,15);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementWebAdEndDate(startDate, null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty oppType parameter passed.', response.message, 'Expected message: Empty oppType parameter passed.');
    // }

    // @isTest static void testCalculateCSAgreementWebAdEndDateFail_EmptyWebAdStartDate() {
    //     final Date today = System.today();
    //     final String oppType = '12 Month Supersede';

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementWebAdEndDate(null, oppType);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty webAdStartDate parameter passed.', response.message, 'Expected message: Empty webAdStartDate parameter passed.');
    // }

    // @isTest static void testCalculateCSAgreementWebAdEndDatePass() {
    //     final Date today = System.today();
    //     final String oppType = '12 Month Supersede';
    //     final Date startDate = Date.newInstance(today.year(),1,15);

    //     Test.startTest();
    //     response = CCCUtils.calculateCSAgreementWebAdEndDate(startDate, oppType);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(startDate.addMonths(12).addDays(-1), response.calculatedDate);
    // }

    // @isTest static void testGetActiveCategoryGroupDiscountRecordsFail_EmptyRecordId() {

    //     Test.startTest();
    //     response = CCCUtils.getActiveCategoryGroupDiscountRecords(null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty recordId parameter passed.', response.message, 'Expected message: Empty recordId parameter passed.');
    // }

    // @isTest static void testGetActiveCategoryGroupDiscountRecordsFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getActiveCategoryGroupDiscountRecords(accountRecord.Id, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetActiveCategoryGroupDiscountRecordsPass() {

    //     Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getActiveCategoryGroupDiscountRecords(accountRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertEquals(5, response.discountRecords.size(), 'Expected discountRecords to be of size 5');
    // }

    // @isTest static void testGetActiveOpportunityDiscountRecordsFail_EmptyRecordId() {

    //     Test.startTest();
    //     response = CCCUtils.getActiveOpportunityDiscountRecords(null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty recordId parameter passed.', response.message, 'Expected message: Empty recordId parameter passed.');
    // }

    // @isTest static void testGetActiveOpportunityDiscountRecordsFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getActiveOpportunityDiscountRecords(accountRecord.Id, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetActiveOpportunityDiscountRecordsPass() {

    //     Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getActiveOpportunityDiscountRecords(accountRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertEquals(5, response.discountRecords.size(), 'Expected discountRecords to be of size 5');
    // }

    // @isTest static void testGetOpportunityCategoryGroupRecordsFail_EmptyRecordId() {

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryGroupRecords(null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty recordId parameter passed.', response.message, 'Expected message: Empty recordId parameter passed.');
    // }

    // @isTest static void testGetOpportunityCategoryGroupRecordsFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryGroupRecords(opportunityRecord.Id, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetOpportunityCategoryGroupRecordsPass() {
    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryGroupRecords(opportunityRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertEquals(2, response.opportunityCategoryGroupRecords.size(), 'opportunityCategoryGroupRecords.size() should be 2.');
    // }

    // @isTest static void testGetOpportunityCategoryRecordsFail_EmptyRecordId() {

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryRecords(null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty recordId parameter passed.', response.message, 'Expected message: Empty recordId parameter passed.');
    // }

    // @isTest static void testGetOpportunityCategoryRecordsFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryRecords(opportunityRecord.Id, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetOpportunityCategoryRecordsPass() {
    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityCategoryRecords(opportunityRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertEquals(12, response.categoryRecords.size(), 'categoryRecords.size() should be 12.');
    // }

    // @isTest static void testGetOpportunityPaymentPlanFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityPaymentPlan(opportunityRecord.Id, flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetOpportunityPaymentPlanFail_EmptyAccountId() {

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityPaymentPlan(null);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertEquals('Empty recordId parameter passed.', response.message, 'Expected message: Empty recordId parameter passed.');
    // }

    // @isTest static void testGetOpportunityPaymentPlanPass_CS_RemainingMonthSupersede() {
    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Client Success - Remaining Month Supersede' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityPaymentPlan(opportunityRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertNotEquals(null, response.opportunityWebAdPaymentPlan, 'opportunityWebAdPaymentPlan should not be null.');
    // }

    // @isTest static void testGetOpportunityPaymentPlanPass_SO() {
    //     Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

    //     Test.startTest();
    //     response = CCCUtils.getOpportunityPaymentPlan(opportunityRecord.Id);
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assertNotEquals(null, response.opportunityWebAdPaymentPlan, 'opportunityWebAdPaymentPlan should not be null.');
    // }

    @isTest static void testSetErrorResponsePass_StringMessage() {
        final String methodName = 'testSetErrorResponsePass_StringMessage';
        final String errorMessage = 'test error message';

        CCCServerResponse serverResponse;

        Test.startTest();

        serverResponse = CCCUtils.setErrorResponse(className, methodName, errorMessage, new CCCServerResponse());
        System.assertEquals(errorMessage, serverResponse.message);
        System.assertEquals(true, serverResponse.hasErrors);

        Test.stopTest();
    }

    @isTest static void testSetErrorResponsePass_Exception() {
        final String methodName = 'testSetErrorResponsePass_StringMessage';
        final String errorMessage = 'test error message';

        CCCServerResponse serverResponse;

        Test.startTest();

        StringException e = new StringException();
        e.setMessage(errorMessage);

        serverResponse = CCCUtils.setErrorResponse(className, methodName, e, new CCCServerResponse());
        System.assert(serverResponse.message.contains(errorMessage), 'Invalid message returned:' + serverResponse.message);
        System.assertEquals(true, serverResponse.hasErrors);

        Test.stopTest();
    }

    @isTest static void testGetAllowEditFail_RootExceptionThrown() {
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        response = CCCUtils.getAllowEdit(opportunityRecord.Id, flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetAllowEditFail_EmptyRecordId() {

        Test.startTest();
        response = CCCUtils.getAllowEdit(null);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void testGetAllowEditPass_True() {

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        response = CCCUtils.getAllowEdit(opportunityRecord.Id);
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(true, response.allowEdit, 'Expected allowEdit to be true');
    }

    @isTest static void testGetAllowEditPass_False() {
        Opportunity opportunityRecord = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        opportunityRecord.StageName = 'Closed Won';

        update opportunityRecord;

        Test.startTest();

        response = CCCUtils.getAllowEdit(opportunityRecord.Id);
        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(false, response.allowEdit);

        Test.stopTest();
    }

    @isTest static void testGetOpportunityRecordFail_EmptyAccountId() {

        Test.startTest();
        response = CCCUtils.getOpportunityRecord(null);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Empty recordId parameter passed.'), 'Expected message to end with: Empty recordId parameter passed.');
    }

    @isTest static void testGetOpportunityRecordFail_RootExceptionThrown() {
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        response = CCCUtils.getOpportunityRecord(opportunityRecord.Id, flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetOpportunityRecordPass() {
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        response = CCCUtils.getOpportunityRecord(opportunityRecord.Id);
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.opportunityRecord, 'opportunityRecord is null when it should be populated.');
    }

    // @isTest static void testGetPricingTierCustomMetadataSettingsFail_RootExceptionThrown() {
    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Test.startTest();
    //     response = CCCUtils.getPricingTierCustomMetadataSettings(flags);
    //     Test.stopTest();

    //     System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
    //     System.assertNotEquals(null, response.message, 'Expected message to be not null');
    // }

    // @isTest static void testGetPricingTierCustomMetadataSettingsPass() {

    //     Test.startTest();
    //     response = CCCUtils.getPricingTierCustomMetadataSettings();
    //     Test.stopTest();

    //     System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
    //     System.assertEquals(null, response.message, 'response has error:' + response.message);
    //     System.assert(response.pricingTierSettingsMap.size() > 0, 'pricingTierSettingsMap.size() should be greater than 0.');
    // }

    @isTest static void testGetLocationProvinceOptionsPass() {
        List<String> response;

        Test.startTest();
        response = CCCUtils.getLocationProvinceOptions();
        Test.stopTest();

        System.assertNotEquals(0, response.size(), 'Expected response.size to not be0');
    }

    @isTest static void testUserHasProfilePass() {

        Boolean response;

        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User (
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );

        System.runAs(u) {

            Test.startTest();
            response = CCCUtils.userHasProfileIn('System Administrator');
            Test.stopTest();

            System.assertEquals(true, response, 'Expected response to be true');
        }
    }

}