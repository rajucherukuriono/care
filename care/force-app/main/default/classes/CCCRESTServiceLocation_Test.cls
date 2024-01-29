/***************************************************************************************************
   Name        : CCCRESTServiceLocation_Test
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: February 3rd, 2021
   Description : Unit test class for CCCRESTServiceLocation

   Changes     : 02/03/2021 - John Wrightsman (Class Created)
******************************************************************************************************/
@isTest
private class CCCRESTServiceLocation_Test {

    @testSetup static void setup() {
        Opportunity opp = new Opportunity(Name = 'Test', CloseDate = Date.today(), StageName = 'Prospecting');
        insert opp;

        List<Opportunity_Service_Area__c> locations = new List<Opportunity_Service_Area__c>();
        locations.add(new Opportunity_Service_Area__c(Opportunity__c = opp.Id, Name = 'Location 1'));
        locations.add(new Opportunity_Service_Area__c(Opportunity__c = opp.Id, Name = 'Location 2'));
        insert locations;

        CCCTestDataFactory.createContractComposerApiUser();
    }

    @isTest static void postLocation_successful() {
        Id locationId = [SELECT Id FROM Opportunity_Service_Area__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.active = true;
        locationRequest.name = 'Loc Name';
        locationRequest.run_ads = true;
        locationRequest.phone = '8005882300';
        locationRequest.email = 'testloc@example.com';
        locationRequest.status = 'teststatus';
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = true;
        locationRequest.license.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest);
        }
        Test.stopTest();

        // Should be successful
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(null, RestContext.response.responseBody);

        // Check Location to see that the field values are correct
        Opportunity_Service_Area__c location = [SELECT License_Status__c, License_Details__c, Galore_Status__c FROM Opportunity_Service_Area__c WHERE Id = :locationId];
        System.assertEquals('Approved', location.License_Status__c, 'Expected:Approved Received:' + location.License_Status__c);
        System.assertEquals(locationRequest.license.status, location.License_Details__c, 'Expected:' + locationRequest.license.status + ' Received:' + location.License_Details__c);
        System.assertEquals(locationRequest.status, location.Galore_Status__c, 'Expected:' + locationRequest.status + ' Received:' + location.Galore_Status__c);
    }

    @isTest static void postLocation_long_status_string() {
        Id locationId = [SELECT Id FROM Opportunity_Service_Area__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values; make status longer than 255 chars
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = true;
        locationRequest.license.status = '';
        for (Integer i = 0; i < 10; i++) {
            locationRequest.license.status += 'abcdefghijklmnopqrstuvwxyz';
        }

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest);
        }
        Test.stopTest();

        // Should be successful
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(null, RestContext.response.responseBody);

        // Check Location to see that the field values are correct
        Opportunity_Service_Area__c location = [SELECT License_Status__c, License_Details__c FROM Opportunity_Service_Area__c WHERE Id = :locationId];
        System.assertEquals('Approved', location.License_Status__c, 'Expected:Approved Received:' + location.License_Status__c);
        System.assertEquals(locationRequest.license.status.substring(0, 255), location.License_Details__c, 'Expected:' + locationRequest.license.status.substring(0, 255) + ' Received:' + location.License_Details__c);
    }

    @isTest static void postLocation_invalid_location_id() {
        String locationId = 'InvalidLocationId';

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = true;
        locationRequest.license.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest);
        }
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf('Invalid Location Id'), RestContext.response.responseBody, 'Received:' + String.valueOf(RestContext.response.responseBody));
    }

    @isTest static void postContract_location_not_found() {
        String locationId = [SELECT Id FROM Opportunity_Service_Area__c LIMIT 1].Id;

        // Replace last 8 chars with 'X' so that it is still a valid Opportunity_Service_Area__c id format
        locationId = locationId.substring(0, 10) + 'XXXXXXXX';

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = true;
        locationRequest.license.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest);
        }
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf('Location not found'), RestContext.response.responseBody, 'Received:' + String.valueOf(RestContext.response.responseBody));
    }

    @isTest static void postLocation_reject_location() {
        Id locationId = [SELECT Id FROM Opportunity_Service_Area__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = false;
        locationRequest.license.status = 'test';

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest);
        }
        Test.stopTest();

        // Should be successful
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(null, RestContext.response.responseBody);

        // Check Location to see that the field values are correct
        Opportunity_Service_Area__c location = [SELECT License_Status__c, License_Details__c FROM Opportunity_Service_Area__c WHERE Id = :locationId];
        System.assertEquals('Rejected', location.License_Status__c, 'Expected:Rejected Received:' + location.License_Status__c);
        System.assertEquals(locationRequest.license.status, location.License_Details__c, 'Expected:' + locationRequest.license.status + ' Received:' + location.License_Details__c);
    }

    @isTest static void postLocation_approve_all_locations() {
        List<Opportunity_Service_Area__c> locations = [SELECT Id FROM Opportunity_Service_Area__c];

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        RestRequest req;
        for (Opportunity_Service_Area__c location : [SELECT Id FROM Opportunity_Service_Area__c]) {
            req = new RestRequest();
            req.requestUri = '/' + location.Id;
            req.httpMethod = 'PATCH';
            req.addHeader('Content-Type', 'application/json');
            RestContext.request = req;

            RestResponse res = new RestResponse();
            RestContext.response = res;

            // Set request values
            CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
            locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
            locationRequest.license.approved = true;
            locationRequest.license.status = 'test';

            System.runAs(u) {
                CCCRESTServiceLocation.postLocation(locationRequest);
            }
        }
        Test.stopTest();

        // Check Location to see that the field values are correct
        for (Opportunity_Service_Area__c location : [SELECT License_Status__c, License_Details__c FROM Opportunity_Service_Area__c]) {
            System.assertEquals('Approved', location.License_Status__c, 'Expected:Approved Received:' + location.License_Status__c);
        }
    }

    @isTest static void postLocation_throwRootExceptionFail() {
        Id locationId = [SELECT Id FROM Opportunity_Service_Area__c LIMIT 1].Id;

        RestRequest req = new RestRequest();
        req.requestUri = '/' + locationId;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        CCCRESTServiceLocation.PostLocationRequest locationRequest = new CCCRESTServiceLocation.PostLocationRequest();
        locationRequest.license = new CCCRESTServiceLocation.LicenseObject();
        locationRequest.license.approved = true;
        locationRequest.license.status = 'test';

        // Set flag to throw root exception
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            CCCRESTServiceLocation.postLocation(locationRequest, flags);
        }
        Test.stopTest();

        // Should receive status 500 and error message
        System.assertEquals(500, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().startsWith('Throw Root Exception Unit Test.'));
    }

}