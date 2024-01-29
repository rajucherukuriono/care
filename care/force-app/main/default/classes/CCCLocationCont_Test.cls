/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/30/2020
Description: Test methods for CCCLocationController Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCLocationCont_Test {
    private static CCCLocationController.ServerResponse response;

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

    @isTest static void testDeleteLocationRecordFail_EmptyLocationRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.deleteLocationRecord(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationRecordId parameter passed.'), 'Expected message to end with: Empty locationRecordId parameter passed.');
    }

    @isTest static void testDeleteLocationRecordFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);
        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.deleteLocationRecord(locationRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testDeleteLocationRecordPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);
        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.deleteLocationRecord(locationRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void testFindGeolocationFail_NoResults() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String SEARCH = 'TEST ADDRESS';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(url, '{"type":"FeatureCollection","query":["los","angeles"],"features":[],"attribution":"NOTICE: © 2020 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained. POI(s) provided by Foursquare."}');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.findGeolocation(SEARCH);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasError should be true');
        System.assert(response.message.endsWith('Unable to find coordinates for this location\'s address'), 'Expected message to end with: Unable to find coordinates for this location\'s address');
        System.assertEquals(null, response.coordinates, 'coordinates should not be null');
    }

    @isTest static void testFindGeolocationFail_EndpointNotFound() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String SEARCH = 'TEST ADDRESS';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

        // Create mock callouts
        // CCCMockCallouts mock = new CCCMockCallouts();
        // mock.add(url, '{"type":"FeatureCollection","query":["los","angeles"],"features":[],"attribution":"NOTICE: © 2020 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained. POI(s) provided by Foursquare."}');
        // Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.findGeolocation(SEARCH);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasError should be true');
        System.assert(response.message.endsWith('Unable to find coordinates for this location\'s address'), 'Expected message to end with: Unable to find coordinates for this location\'s address');
        System.assertEquals(null, response.coordinates, 'coordinates should not be null');
    }

    @isTest static void testFindGeolocationFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String SEARCH = 'TEST ADDRESS';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(url, '{"type":"FeatureCollection","query":["los","angeles"],"features":[],"attribution":"NOTICE: © 2020 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained. POI(s) provided by Foursquare."}');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.findGeolocation(SEARCH, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testFindGeolocationFailBadJSON() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String SEARCH = 'TEST ADDRESS';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(url, '{BAD JSON');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.findGeolocation(SEARCH);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'Expected hasErrors to be true');
        System.assertNotEquals(null, response.message, 'response has error:' + response.message);
    }

    @isTest static void testFindGeolocationPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String SEARCH = 'TEST ADDRESS';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

        // Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(url, '{"type":"FeatureCollection","query":["los","angeles"],"features":[{"id":"place.7397503093427640","type":"Feature","place_type":["place"],"relevance":1,"properties":{"wikidata":"Q65"},"text":"Los Angeles","place_name":"Los Angeles, California, United States","bbox":[-118.521456965901,33.9018913203336,-118.121305008073,34.161440999758],"center":[-118.2439,34.0544],"geometry":{"type":"Point","coordinates":[-118.2439,34.0544]},"context":[{"id":"region.9803118085738010","wikidata":"Q99","short_code":"US-CA","text":"California"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]},{"id":"place.10952642230180310","type":"Feature","place_type":["place"],"relevance":1,"properties":{"wikidata":"Q16910"},"text":"Los Ángeles","place_name":"Los Ángeles, Bío Bío, Chile","bbox":[-72.68248,-37.663862,-72.041277,-37.178368],"center":[-72.35,-37.46667],"geometry":{"type":"Point","coordinates":[-72.35,-37.46667]},"context":[{"id":"region.8544689811876870","wikidata":"Q2170","short_code":"CL-BI","text":"Bío Bío"},{"id":"country.10394314763731110","wikidata":"Q298","short_code":"cl","text":"Chile"}]},{"id":"poi.300647807514","type":"Feature","place_type":["poi"],"relevance":1,"properties":{"foursquare":"439ec330f964a520102c1fe3","wikidata":"Q8731","landmark":true,"address":"1 World Way","category":"airport","maki":"airport"},"text":"Los Angeles International Airport (LAX)","place_name":"Los Angeles International Airport (LAX), 1 World Way, Los Angeles, California 90045, United States","center":[-118.406829,33.942912],"geometry":{"coordinates":[-118.406829,33.942912],"type":"Point"},"context":[{"id":"neighborhood.33720","text":"Westchester"},{"id":"postcode.15395803225252730","text":"90045"},{"id":"place.7397503093427640","wikidata":"Q65","text":"Los Angeles"},{"id":"region.9803118085738010","wikidata":"Q99","short_code":"US-CA","text":"California"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]},{"id":"locality.9858218050180310","type":"Feature","place_type":["locality"],"relevance":1,"properties":{"wikidata":"Q390462"},"text":"Los Ángeles","place_name":"Los Ángeles, Madrid, Madrid, Spain","bbox":[-3.70707139897225,40.3456805018361,-3.6930253001356,40.3645357999689],"center":[-3.69917,40.35667],"geometry":{"type":"Point","coordinates":[-3.69917,40.35667]},"context":[{"id":"place.10708255346562040","wikidata":"Q2807","text":"Madrid"},{"id":"region.9368530433562040","wikidata":"Q2807","text":"Madrid"},{"id":"country.3373497261570100","wikidata":"Q29","short_code":"es","text":"Spain"}]},{"id":"neighborhood.2104633","type":"Feature","place_type":["neighborhood"],"relevance":1,"properties":{},"text":"Los Angeles Heights - Keystone","place_name":"Los Angeles Heights - Keystone, San Antonio, Texas 78201, United States","bbox":[-98.534942,29.453364,-98.514652,29.485214],"center":[-98.52,29.47],"geometry":{"type":"Point","coordinates":[-98.52,29.47]},"context":[{"id":"postcode.9559195398572850","text":"78201"},{"id":"place.7333361243253710","wikidata":"Q975","text":"San Antonio"},{"id":"region.12968715825342410","wikidata":"Q1439","short_code":"US-TX","text":"Texas"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]}],"attribution":"NOTICE: © 2020 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained. POI(s) provided by Foursquare."}');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.findGeolocation(SEARCH);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.coordinates, 'locationRecord should not be null');
    }

    @isTest static void testGetLocationDataFail_EmptyRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationData(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty opportunityId parameter passed.'), 'Expected message to end with: Empty opportunityId parameter passed.');
    }

    @isTest static void testGetLocationDataFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationData(opportunityRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetLocationDataPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.mapBoxApiKey, 'mapBoxApiKey should not be null');
        System.assertNotEquals(null, response.maxLocations, 'maxLocations should not be null');
        System.assertEquals(3,response.locationRecords.size(), 'locationRecords list should be of size 3');
        System.assertNotEquals(0,response.provinceOptions.size(), 'provinceOptions list should not be empty');
    }

    @isTest static void testGetLocationRecordFail_EmptyOpportunityServiceAreaRecordId() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationRecord(null);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationRecordId parameter passed.'), 'Expected message to end with: Empty locationRecordId parameter passed.');
    }

    @isTest static void testGetLocationRecordFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationRecord(locationRecord.Id, flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testGetLocationRecordPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.getLocationRecord(locationRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertNotEquals(null, response.locationRecord, 'locationRecord should not be null');
    }

    @isTest static void testSaveLocationRecordFail_EmptyLocationRecord() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];


        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.saveLocationRecord(null, false, new List<String>());
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty locationRecord parameter passed.'), 'Expected message to end with: Empty locationRecord parameter passed.');
    }

    @isTest static void testSaveLocationRecordFail_EmptyCopyServiceSpecificFields() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String NAME = 'UPDATED NAME';

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        locationRecord.Name = NAME;

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.saveLocationRecord(locationRecord, null, new List<String>());
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty copyServiceSpecificFields parameter passed.'), 'Expected message to end with: Empty copyServiceSpecificFields parameter passed.');
    }

    @isTest static void testSaveLocationRecordFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String NAME = 'UPDATED NAME';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        locationRecord.Name = NAME;

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.saveLocationRecord(locationRecord, false, new List<String>(), flags);
        }
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void testSaveLocationRecordPass() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String NAME = 'UPDATED NAME';
        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];

        locationRecord.Name = NAME;

        CCCLocationController.ServerResponse response2;

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.saveLocationRecord(locationRecord, false, new List<String>());

            response2 = CCCLocationController.getLocationData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(NAME, response2.locationRecords[0].Name, 'locationRecords[0].Name should be ' + NAME);
    }

    @isTest static void testSaveLocationRecordPass_WithCopyServiceSpecificFields() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String NAME = 'UPDATED NAME';
        final String AGE_RANGE = '0-1 (infant);1-2 (toddler)';
        final Decimal CAPACITY = 5;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];
        locationRecord.Age_Range__c = AGE_RANGE;
        locationRecord.Capacity__c = CAPACITY;
        locationRecord.Name = NAME;

        CCCLocationController.ServerResponse response2;

        Test.startTest();
        System.runAs(u) {
            response = CCCLocationController.saveLocationRecord(locationRecord, true, new List<String>());

            response2 = CCCLocationController.getLocationData(opportunityRecord.Id);
        }
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'response has error:' + response.message);
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(NAME, response2.locationRecords[0].Name, 'locationRecords[0].Name should be ' + NAME);
        System.assertEquals(AGE_RANGE, response2.locationRecords[0].Age_Range__c, 'locationRecords[0].Age_Range__c should be ' + AGE_RANGE);
        System.assertEquals(AGE_RANGE, response2.locationRecords[1].Age_Range__c, 'locationRecords[1].Age_Range__c should be ' + AGE_RANGE);
        System.assertEquals(AGE_RANGE, response2.locationRecords[2].Age_Range__c, 'locationRecords[2].Age_Range__c should be ' + AGE_RANGE);
        System.assertEquals(CAPACITY, response2.locationRecords[0].Capacity__c, 'locationRecords[0].Capacity__c should be ' + CAPACITY);
        System.assertEquals(CAPACITY, response2.locationRecords[1].Capacity__c, 'locationRecords[1].Capacity__c should be ' + CAPACITY);
        System.assertEquals(CAPACITY, response2.locationRecords[2].Capacity__c, 'locationRecords[2].Capacity__c should be ' + CAPACITY);
    }

    @isTest static void testCopyServiceSpecificFieldsFail_RootExceptionThrown() {
        User u = [SELECT Id FROM User WHERE UserName = 'test_so_profile@caredotcom.com'];

        final String AGE_RANGE = '0-1 (infant);1-2 (toddler)';
        final Decimal CAPACITY = 5;

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];
        response = CCCLocationController.getLocationData(opportunityRecord.Id);

        Opportunity_Service_Area__c locationRecord = response.locationRecords[0];
        locationRecord.Age_Range__c = AGE_RANGE;
        locationRecord.Capacity__c = CAPACITY;

        Boolean exceptionThrown = false;

        Test.startTest();
        System.runAs(u) {
            try {
                CCCLocationController.copyServiceSpecificFields(locationRecord, flags);
            } catch(Exception e) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Expected exception to be thrown');
    }
}