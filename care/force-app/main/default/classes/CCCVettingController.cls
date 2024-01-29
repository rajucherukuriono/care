/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/01/2020
Description: Supports the CCCVettingModule Lightning Component
Changes:

*********************************************************************************************/
public without sharing class CCCVettingController {
    static private final String CLASS_NAME = 'CCCVettingController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        // @AuraEnabled public List<Contact> contactRecords { get; set; }
        // @AuraEnabled public String primaryContactId { get; set; }
        @AuraEnabled public List<Opportunity_Service_Area__c> locationRecords { get; set; }
        @AuraEnabled public Composer_Service__c composerServiceRecord { get; set; }
        @AuraEnabled public List<String> provinceOptions { get; set; }
        @AuraEnabled public Boolean displayLocationSpecificContactInfo { get; set; }
        @AuraEnabled public Decimal minTuitionDiscountDollar { get; set; }
        @AuraEnabled public Decimal minTuitionDiscountPercent { get; set; }

        public ServerResponse() {
            super();
            // this.contactRecords = new List<Contact>();
            this.locationRecords = new List<Opportunity_Service_Area__c>();
            this.displayLocationSpecificContactInfo = false;
        }
    }


    /**
    * @description Retrieves The Contacts associated with this Opportunity's Account, as well as the current Primary Contact selection
    * @param recordId (String) - The Id of the Opportunity
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getVettingData(String recordId) { return getVettingData(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getVettingData(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getVettingData';

        CCCUtils.ServerResponse rUtils;
        ServerResponse response = new ServerResponse();

        try {
            // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Opportunity Record
            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('Composer_Service__c').equalsId(recordId).one();
            if (response.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            if (response.opportunityRecord.Composer_Service__c != null) {
                response.composerServiceRecord = response.opportunityRecord.Composer_Service__r;
            }

            // Get Opportunity Service Area Records
            response.locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', response.opportunityRecord.Id).all();

            response.provinceOptions = CCCUtils.getLocationProvinceOptions();

            // Determine whether to show location specific Contact Info
            CCC_Global_Setting__mdt globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();
            response.displayLocationSpecificContactInfo = globalSettings.Display_Location_Specific_Contact_Info__c;

            // Get Tuition settings
            response.minTuitionDiscountDollar = globalSettings.Min_Tuition_Discount_Dollar__c;
            response.minTuitionDiscountPercent = globalSettings.Min_Tuition_Discount_Percent__c;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }


    /**
    * @description Returns an Opportunity Service Area and it's associated postal codes
    * @param locationRecord (Opportunity_Service_Area__c) - The Opportunity Service Area record
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse saveLocationRecord(Opportunity_Service_Area__c locationRecord) { return saveLocationRecord(locationRecord, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse saveLocationRecord(Opportunity_Service_Area__c locationRecord, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveLocationRecord';
        ServerResponse response = new ServerResponse();

        try {
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (locationRecord == null) throw new CCCException('Empty locationRecord parameter passed.');

            upsert locationRecord;
        } catch(Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }

}