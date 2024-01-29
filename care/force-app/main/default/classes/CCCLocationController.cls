/****************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 11/06/2020
Description: Apex controller for CCCLocationModule lightning component.
Changes:

*****************************************************************************/
public without sharing class CCCLocationController {
    static private String CLASS_NAME = 'CCCLocationController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public Account accountRecord { get; set; }
        @AuraEnabled public List<Opportunity_Service_Area__c> locationRecords { get; set; }
        @AuraEnabled public Opportunity_Service_Area__c locationRecord { get; set; }
        @AuraEnabled public List<Composer_Service__c> composerServiceRecords { get; set; }
        @AuraEnabled public List<Opportunity_Location_Service__c> locationServiceRecords { get; set; }
        @AuraEnabled public String primaryServiceVerticalName { get; set; }
        @AuraEnabled public String mapBoxApiKey { get; set; }
        @AuraEnabled public Decimal maxLocations { get; set; }
        @AuraEnabled public List<Decimal> coordinates { get; set; }
        @AuraEnabled public List<String> provinceOptions { get; set; }
        @AuraEnabled public Boolean enableAdditionalServices { get; set; }
        @AuraEnabled public List<CCC_State_Abbreviation_Map__mdt> stateAbbreviations { get; set; }

        public ServerResponse() {
            super();
            this.locationRecords = new List<Opportunity_Service_Area__c>();
            this.composerServiceRecords = new List<Composer_Service__c>();
            this.stateAbbreviations = new List<CCC_State_Abbreviation_Map__mdt>();
            this.maxLocations = 9999999;
        }
    }


    /**
    * @description Retrieves the Service Area data for an Opportunity
    * @param opportunityId (String) - The Opportunity record Id
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getLocationData(String opportunityId) { return getLocationData(opportunityId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getLocationData(String opportunityId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getLocationData';

        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) throw new CCCException('Empty opportunityId parameter passed.');

            CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            // Get Opportunity_Service_Area__c records
            response.locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityId).all();

            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').field('Composer_Service__r.Vertical__c, Composer_Service__r.License_Level__c').equalsId(opportunityId).one();

            response.accountRecord = (Account) CCCQuery.get('Account').equalsId(response.opportunityRecord.AccountId).one();

            // Get the primary service's vertical name
            response.primaryServiceVerticalName = response.opportunityRecord.Composer_Service__r.Vertical__c;

            // Get all possible active Composer Service records except for the one selected as the primary service on the opportunity
            if (response.opportunityRecord.Composer_Service__c != null) {
                response.composerServiceRecords = (List<Composer_Service__c>)
                    CCCQuery.get('Composer_Service__c')
                            .equals('Active__c', true)
                            .notEquals('Id', response.opportunityRecord.Composer_Service__c)
                            .order('License_Level__c ASC')
                            .all();
            }

            // Get all the Opportunity_Location_Service__c records for the location record ids on this opportunity
            List<String> locationRecordIds = new List<String>();
            for (Opportunity_Service_Area__c locationRecord : response.locationRecords) {
                locationRecordIds.add(locationRecord.Id);
            }
            response.locationServiceRecords = (List<Opportunity_Location_Service__c>) CCCQuery.get('Opportunity_Location_Service__c').includes('Opportunity_Service_Area__c', locationRecordIds).all();

            // Get MapBox api key from custom metadata setting
            response.mapBoxApiKey = ((CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one()).MapBox_API_Key__c;

            // Get max locations allowed from custom metadata setting
            response.maxLocations = ((CCC_Location_Base_Point__mdt) CCCQuery.get('CCC_Location_Base_Point__mdt').one()).Location_Number__c;

            // Get all state options
            response.provinceOptions = CCCUtils.getLocationProvinceOptions();

            // Get State Abbreviation metadata
            response.stateAbbreviations = (List<CCC_State_Abbreviation_Map__mdt>) CCCQuery.get('CCC_State_Abbreviation_Map__mdt').all();

            // Get Enable Additional Services metadata setting
            response.enableAdditionalServices = globalSettings.Enable_Additional_Services__c;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Returns an Opportunity Service Area and it's associated postal codes
    * @param locationRecordId (String) - The Opportunity Service Area record Id
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getLocationRecord(String locationRecordId) { return getLocationRecord(locationRecordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getLocationRecord(String locationRecordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getLocationRecord';

        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (locationRecordId == null) throw new CCCException('Empty locationRecordId parameter passed.');

            response.locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equalsId(locationRecordId).one();

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Saves an Opportunity_Service_Area__c and optionally copies the Service Specific Fields to all other locations
    *              on the Opportunity
    * @param locationRecord (Opportunity_Service_Area__c) - The Opportunity Service Area wrapper record
    * @param copyServiceSpecificFields (Boolean) - Indicates to copy this the Service Specific fields to all the other locations on the Opportunity
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse saveLocationRecord(Opportunity_Service_Area__c locationRecord, Boolean copyServiceSpecificFields, List<String> selectedComposerServiceRecordIds) { return saveLocationRecord(locationRecord, copyServiceSpecificFields, selectedComposerServiceRecordIds, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse saveLocationRecord(Opportunity_Service_Area__c locationRecord, Boolean copyServiceSpecificFields, List<String> selectedComposerServiceRecordIds, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveLocationRecord';
        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (locationRecord == null) throw new CCCException('Empty locationRecord parameter passed.');
            if (copyServiceSpecificFields == null) throw new CCCException('Empty copyServiceSpecificFields parameter passed.');

            // Populate the Registered Entity fields from the name/address fields
            // if this is a new location
            if (locationRecord.Id == null) {

                // Populate the Registered Entity fields from the name/address fields
                locationRecord.Registered_Entity_Name__c = locationRecord.Name;
                locationRecord.Registered_Entity_City__c = locationRecord.City__c;
                locationRecord.Registered_Entity_State__c = locationRecord.State__c;
                locationRecord.Registered_Entity_Street__c = locationRecord.Street__c;
                locationRecord.Registered_Entity_Postal_Code__c = locationRecord.Postal_Code__c;

                // Update the location's default advertising spend based on the current composer service on the opportunity
                Opportunity opportunityRecord = [SELECT Composer_Service__r.Tier_1_Amount__c, Composer_Service__r.Vertical__c,
                                                        Composer_Service__r.Tier_2_Amount__c
                                                 FROM Opportunity 
                                                 WHERE Id = :locationRecord.Opportunity__c];
                
                locationRecord.Advertising_Spend__c =  opportunityRecord.Composer_Service__r.Tier_1_Amount__c;
                locationRecord.Pricing_Tier__c = 'Tier 1';

                if(opportunityRecord.Composer_Service__r.Vertical__c.toLowerCase().contains('flat rate')){
                    locationRecord.Advertising_Spend__c =  opportunityRecord.Composer_Service__r.Tier_2_Amount__c;
                    locationRecord.Pricing_Tier__c = 'Tier 2';
                }
            }

            upsert locationRecord;

            if (copyServiceSpecificFields) {
                copyServiceSpecificFields(locationRecord);
            }

            if (selectedComposerServiceRecordIds != null) {
                updateLocationServices(locationRecord.Id, selectedComposerServiceRecordIds);
            }

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Deletes an Opportunity_Service_Area__c record
    * @param locationRecordId (String) - The Opportunity Service Area Id
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse deleteLocationRecord(String locationRecordId) { return deleteLocationRecord(locationRecordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse deleteLocationRecord(String locationRecordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'deleteLocationRecord';
        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (locationRecordId == null) throw new CCCException('Empty locationRecordId parameter passed.');

            delete new Opportunity_Service_Area__c(Id = locationRecordId);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    @TestVisible private static void updateLocationServices(String locationRecordId, List<String> selectedComposerServiceRecordIds) {
        // Delete any Opportunity_Location_Service__c records related to the location if the Composer_Service__c
        // is not in the selectedComposerServiceRecordIds list
        List<Opportunity_Location_Service__c> locationServiceRecordsToDelete = (List<Opportunity_Location_Service__c>)
            CCCQuery.get('Opportunity_Location_Service__c')
                    .equals('Opportunity_Service_Area__c', locationRecordId)
                    .notIncludes('Composer_Service__c', selectedComposerServiceRecordIds)
                    .all();

        delete locationServiceRecordsToDelete;



        // Insert a new Opportunity_Location_Service__c for any new composer service ids selected
        List<Opportunity_Location_Service__c> newLocationServiceRecords = new List<Opportunity_Location_Service__c>();

        Map<String, sObject> locationServiceRecordsMap =
            CCCQuery.get('Opportunity_Location_Service__c')
                    .equals('Opportunity_Service_Area__c', locationRecordId)
                    .toMap('Composer_Service__c');

        for (String composerServiceRecordId : selectedComposerServiceRecordIds) {
            if (!locationServiceRecordsMap.containsKey(composerServiceRecordId)) {
                newLocationServiceRecords.add(new Opportunity_Location_Service__c(
                    Opportunity_Service_Area__c = locationRecordId,
                    Composer_Service__c = composerServiceRecordId
                ));
            }
        }

        insert newLocationServiceRecords;

    }


    /**
    * @description Finds the geolocation coordinates for an address
    * @param search (String) - The address search string to pass to the MapBox geocoding API
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse findGeolocation(String search) { return findGeolocation(search, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse findGeolocation(String search, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'findGeolocation';

        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (search == null) throw new CCCException('Empty search parameter passed.');

            CCCAPIRespMapBoxGeocoding.ServerResponse apiResponse = CCCCalloutMaster.getMapBoxGeocodingResults(search);
            if (apiResponse.features != null && apiResponse.features.size() > 0) {
                List<Decimal> coordinates;

                // Find first 'Point' feature and use its coordinates
                for (CCCAPIRespMapBoxGeocoding.FeatureData feature : apiResponse.features) {
                    if (feature.geometry != null) {
                        if (feature.geometry.type.equalsIgnoreCase('Point')) {
                            coordinates = feature.geometry.coordinates;
                            break;
                        }
                    }
                }

                if (coordinates != null) {
                    response.coordinates = coordinates;
                }
            }

            if (response.coordinates == null) throw new CCCException('Unable to find coordinates for this location\'s address');

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Copies the values in the Service Specific Fields from one location to all other locations on the related Opportunity
    * @param locationRecord (Opportunity_Service_Area__c) - The Opportunity Service Area
    * @return void
    */
    @TestVisible private static void copyServiceSpecificFields(Opportunity_Service_Area__c locationRecord) { copyServiceSpecificFields(locationRecord, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static void copyServiceSpecificFields(Opportunity_Service_Area__c locationRecord, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'copyServiceSpecificFields';

        if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

        if (locationRecord == null) throw new CCCException('Empty locationRecord parameter passed.');

        // Get original location record, all location records
        locationRecord = (Opportunity_Service_Area__c) CCCQuery.get('Opportunity_Service_Area__c').equalsId(locationRecord.Id).one();
        String opportunityId = locationRecord.Opportunity__c;
        List<Opportunity_Service_Area__c> locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityId).all();

        // Get the Opportunity so we can get the related Composer Service which has the service specific fields
        Opportunity oppty = (Opportunity) CCCQuery.get('Opportunity').equalsId(opportunityId).one();

        // Build list of Service Specific field names
        List<String> fields = new List<String>();
        if (oppty.Composer_Service__c != null) {
            // Get the Service Specific fields from the Composer Service
            Composer_Service__c cs = (Composer_Service__c) CCCQuery.get('Composer_Service__c').equalsId(oppty.Composer_Service__c).one();
            if (cs.Service_Specific_Fields__c != null) {
                for (String field : cs.Service_Specific_Fields__c.split(',')) {
                    fields.add(field.trim());
                }
            }
        }

        // Loop through location records and copy service specific
        // field values from main location
        for (Opportunity_Service_Area__c loc : locationRecords) {
            if (loc.Id != locationRecord.Id) {
                for (String field : fields) {
                    loc.put(field, locationRecord.get(field));
                }
            }
        }

        update locationRecords;
    }

}