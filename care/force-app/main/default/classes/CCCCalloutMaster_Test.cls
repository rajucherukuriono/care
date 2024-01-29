/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/01/2020
Description: Test methods for CCCCalloutMaster Apex class
Comments:

********************************************************************************************/
@isTest
private class CCCCalloutMaster_Test {
    //private static CCCCalloutMaster.ServerResponse response;

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
    }

    @isTest static void test_GetMapBoxGeocodingResultsFail_RootLevelExceptionThrown() {
        final String SEARCH = 'Example Search';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCCAPIRespMapBoxGeocoding.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.getMapBoxGeocodingResults(SEARCH, flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_GetMapBoxGeocodingResultsFail_ReturnBadStatus() {
        final String SEARCH = 'Example Search';

        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.returnBadStatus = true;

        CCCAPIRespMapBoxGeocoding.ServerResponse response;

        // Get MapBox settings
        CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
        String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(SEARCH, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

		// Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(url, '{"type":"FeatureCollection","query":["los","angeles"],"features":[{"id":"place.7397503093427640","type":"Feature","place_type":["place"],"relevance":1,"properties":{"wikidata":"Q65"},"text":"Los Angeles","place_name":"Los Angeles, California, United States","bbox":[-118.521456965901,33.9018913203336,-118.121305008073,34.161440999758],"center":[-118.2439,34.0544],"geometry":{"type":"Point","coordinates":[-118.2439,34.0544]},"context":[{"id":"region.9803118085738010","wikidata":"Q99","short_code":"US-CA","text":"California"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]},{"id":"place.10952642230180310","type":"Feature","place_type":["place"],"relevance":1,"properties":{"wikidata":"Q16910"},"text":"Los Ángeles","place_name":"Los Ángeles, Bío Bío, Chile","bbox":[-72.68248,-37.663862,-72.041277,-37.178368],"center":[-72.35,-37.46667],"geometry":{"type":"Point","coordinates":[-72.35,-37.46667]},"context":[{"id":"region.8544689811876870","wikidata":"Q2170","short_code":"CL-BI","text":"Bío Bío"},{"id":"country.10394314763731110","wikidata":"Q298","short_code":"cl","text":"Chile"}]},{"id":"poi.300647807514","type":"Feature","place_type":["poi"],"relevance":1,"properties":{"foursquare":"439ec330f964a520102c1fe3","wikidata":"Q8731","landmark":true,"address":"1 World Way","category":"airport","maki":"airport"},"text":"Los Angeles International Airport (LAX)","place_name":"Los Angeles International Airport (LAX), 1 World Way, Los Angeles, California 90045, United States","center":[-118.406829,33.942912],"geometry":{"coordinates":[-118.406829,33.942912],"type":"Point"},"context":[{"id":"neighborhood.33720","text":"Westchester"},{"id":"postcode.15395803225252730","text":"90045"},{"id":"place.7397503093427640","wikidata":"Q65","text":"Los Angeles"},{"id":"region.9803118085738010","wikidata":"Q99","short_code":"US-CA","text":"California"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]},{"id":"locality.9858218050180310","type":"Feature","place_type":["locality"],"relevance":1,"properties":{"wikidata":"Q390462"},"text":"Los Ángeles","place_name":"Los Ángeles, Madrid, Madrid, Spain","bbox":[-3.70707139897225,40.3456805018361,-3.6930253001356,40.3645357999689],"center":[-3.69917,40.35667],"geometry":{"type":"Point","coordinates":[-3.69917,40.35667]},"context":[{"id":"place.10708255346562040","wikidata":"Q2807","text":"Madrid"},{"id":"region.9368530433562040","wikidata":"Q2807","text":"Madrid"},{"id":"country.3373497261570100","wikidata":"Q29","short_code":"es","text":"Spain"}]},{"id":"neighborhood.2104633","type":"Feature","place_type":["neighborhood"],"relevance":1,"properties":{},"text":"Los Angeles Heights - Keystone","place_name":"Los Angeles Heights - Keystone, San Antonio, Texas 78201, United States","bbox":[-98.534942,29.453364,-98.514652,29.485214],"center":[-98.52,29.47],"geometry":{"type":"Point","coordinates":[-98.52,29.47]},"context":[{"id":"postcode.9559195398572850","text":"78201"},{"id":"place.7333361243253710","wikidata":"Q975","text":"San Antonio"},{"id":"region.12968715825342410","wikidata":"Q1439","short_code":"US-TX","text":"Texas"},{"id":"country.19678805456372290","wikidata":"Q30","short_code":"us","text":"United States"}]}],"attribution":"NOTICE: © 2020 Mapbox and its suppliers. All rights reserved. Use of this data is subject to the Mapbox Terms of Service (https://www.mapbox.com/about/maps/). This response and the information it contains may not be retained. POI(s) provided by Foursquare."}');
		Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        Test.startTest();
        response = CCCCalloutMaster.getMapBoxGeocodingResults(SEARCH, flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assertNotEquals(null, response.message, 'message should not be null');
    }

    @isTest static void test_CreateSalesContractFail_EmptyRequest() {
        CCCAPIRespCreateSalesContract.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.createSalesContract(null);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty request parameter passed.'), 'Expected message to end with: Empty request parameter passed.');
    }

    @isTest static void test_CreateSalesContractFail_RootLevelExceptionThrown() {
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCCAPIRespCreateSalesContract.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.createSalesContract(new CCCAPIReqCreateSalesContract(), flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_UpdateSalesContractFail_EmptyRequest() {
        CCCAPIRespUpdateSalesContract.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.updateSalesContract(null, new Map<String, String>());
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Empty request parameter passed.'), 'Expected message to end with: Empty request parameter passed.');
    }

    @isTest static void test_UpdateSalesContractFail_EmptyCustomParameters() {
        CCCAPIRespUpdateSalesContract.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.updateSalesContract(new CCCAPIReqUpdateSalesContract(), new Map<String, String>());
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Expected a non empty/non null customParemters input parameter.'), 'Expected message to end with: Expected a non empty/non null customParemters input parameter.');
    }

    @isTest static void test_UpdateSalesContractFail_RootLevelExceptionThrown() {
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCCAPIRespUpdateSalesContract.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.updateSalesContract(new CCCAPIReqUpdateSalesContract(), new Map<String, String>(), flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_MakeAPICalloutToGaloreFail_RootLevelExceptionThrown() {
        CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
        flags.throwRootExceptionFail = true;

        CCCCalloutMaster.ServerResponse response;

        Test.startTest();
        response = CCCCalloutMaster.makeAPICalloutToGalore('endpoint', new CCCAPIReqUpdateSalesContract(), new Map<String, String>(), flags);
        Test.stopTest();

        System.assertEquals(true, response.hasErrors, 'hasErrors should be true');
        System.assert(response.message.endsWith('Throw Root Exception Unit Test.'), 'Expected message to end with: Throw Root Exception Unit Test.');
    }

    @isTest static void test_UpdateSalesContract_Pass() {
        final String BUSINESS_ID = 'XYZ';
        CCCAPIRespUpdateSalesContract.ServerResponse response;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord.Agreement_Id__c = 'XYZ';
        update opportunityRecord;

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Update_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;
        endpointURL = endpointURL.replace(':salesforceOpportunityId',opportunityRecord.Id);

		// Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"'+BUSINESS_ID+'"}}',200,'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        // Custom Parameters to be used for the API call
        Map<String, String> customParameters = new Map<String, String>();
        customParameters.put('salesforceOpportunityId', opportunityRecord.Id);

        // Update Sales Contract object
        CCCAPIReqUpdateSalesContract request = new CCCAPIReqUpdateSalesContract();
        request.sales_contract = new CCCAPIReqUpdateSalesContract.SalesContract();
        request.sales_contract.contract_status = 'void_contract';

        Test.startTest();
        response = CCCCalloutMaster.updateSalesContract(request, customParameters);
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(opportunityRecord.Id, response.sales_contract.salesforce_opportunity_id, 'Expected esponse.sales_contract.salesforce_opportunity_id to be: '+opportunityRecord.Id);
        System.assertEquals(BUSINESS_ID, response.sales_contract.business_id, 'Expected esponse.sales_contract.contract_status to be: '+BUSINESS_ID);
    }

    @isTest static void test_CreateSalesContract_Pass() {
        final String BUSINESS_ID = 'XYZ';
        CCCAPIRespCreateSalesContract.ServerResponse response;

        Opportunity opportunityRecord = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity - Sales Origination' LIMIT 1];

        opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(opportunityRecord.Id).one();

        // Get API Settings
        CCC_API_Endpoint_Setting__mdt apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', 'Create_Sales_Contract').one();
        String endpointURL = apiSetting.URL__c;

		// Create mock callouts
        CCCMockCallouts mock = new CCCMockCallouts();
        mock.add(endpointURL, '{"sales_contract":{"salesforce_opportunity_id":"'+opportunityRecord.Id+'","business_id":"'+BUSINESS_ID+'"}}',200,'Success');
        Test.setMock(HttpCalloutMock.class, mock.getMockCallout());

        // Create Sales Contract object
        CCCAPIReqCreateSalesContract request = new CCCAPIReqCreateSalesContract();

        Test.startTest();
        response = CCCCalloutMaster.createSalesContract(request);
        Test.stopTest();

        System.assertEquals(false, response.hasErrors, 'Expected hasErrors to be false');
        System.assertEquals(null, response.message, 'response has error:' + response.message);
        System.assertEquals(opportunityRecord.Id, response.sales_contract.salesforce_opportunity_id, 'Expected esponse.sales_contract.salesforce_opportunity_id to be: '+opportunityRecord.Id);
        System.assertEquals(BUSINESS_ID, response.sales_contract.business_id, 'Expected esponse.sales_contract.contract_status to be: '+BUSINESS_ID);
    }
}