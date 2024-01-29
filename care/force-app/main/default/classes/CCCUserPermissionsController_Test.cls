/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 06/25/2021
Description: Test methods for CCCUserPermissionsController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCUserPermissionsController_Test {
    private static CCCUserPermissionsController.ServerResponse response;

    @testSetup static void setup() {
        // Create Composer Service records
        CCCTestDataFactory.createComposerServiceRecords();

        // Create Sales Origination Manager user for testing
        CCCTestDataFactory.createSalesOriginationManagerUser();

        // Create Sales Origination Rep user for testing
        CCCTestDataFactory.createSalesOriginationRepUser();
    }

    @isTest static void test_getUserPermissionsData() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_som_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCUserPermissionsController.getUserPermissionsData();
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assert(response.composerServiceRecords != null && response.composerServiceRecords.size() > 0, 'Expected Composer Service records to be returned.');
        System.assert(response.userRecords != null && response.userRecords.size() > 0, 'Expected User records to be returned.');
    }

    @isTest static void test_getUserPermissionsData_fail() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_som_profile@caredotcom.com'];
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Test.startTest();
        System.runAs(u) {
            response = CCCUserPermissionsController.getUserPermissionsData(flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_updateUserPermittedVerticals() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_som_profile@caredotcom.com'];
        String userId;
        String permittedVerticals;

        Test.startTest();
        System.runAs(u) {
            response = CCCUserPermissionsController.getUserPermissionsData();
            userId = response.userRecords[0].Id;
            permittedVerticals = response.composerServiceRecords[0].Vertical__c;
            response = CCCUserPermissionsController.updateUserPermittedVerticals(userId, permittedVerticals);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        User u2 = [SELECT Contract_Composer_Permitted_Verticals__c FROM User WHERE Id = :userId];
        System.assertEquals(permittedVerticals, u2.Contract_Composer_Permitted_Verticals__c, 'Expected u2.Contract_Composer_Permitted_Verticals__c to equal ' + permittedVerticals);
    }


    @isTest static void test_updateUserPermittedVerticals_fail() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_som_profile@caredotcom.com'];
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        String userId;
        String permittedVerticals;

        Test.startTest();
        System.runAs(u) {
            response = CCCUserPermissionsController.getUserPermissionsData();
            userId = response.userRecords[0].Id;
            permittedVerticals = response.composerServiceRecords[0].Vertical__c;
            response = CCCUserPermissionsController.updateUserPermittedVerticals(userId, permittedVerticals, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

}