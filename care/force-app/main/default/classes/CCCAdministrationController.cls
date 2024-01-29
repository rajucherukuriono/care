/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 08/26/2020
Description: Supports the CCCAdministrationModule Lightning Component
Changes:

*********************************************************************************************/
public without sharing class CCCAdministrationController {
    static private final String CLASS_NAME = 'CCCAdministrationController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public List<Opportunity_Service_Area__c> locationRecords { get; set; }
        @AuraEnabled public Decimal minTuitionDiscountDollar { get; set; }
        @AuraEnabled public Decimal minTuitionDiscountPercent { get; set; }
        @AuraEnabled public List<OpportunityContactRole> opportunityContactRoleRecords { get; set; }
        @AuraEnabled public List<Contact> contactRecords { get; set; }
        @AuraEnabled public String primaryContactId { get; set; }
        @AuraEnabled public Boolean userCanWaivePlatformFee { get; set; }
        @AuraEnabled public List<String> provinceOptions { get; set; }
        @AuraEnabled public Decimal maxPlatformFeeWaived { get; set; }

        public ServerResponse() {
            super();
            this.opportunityContactRoleRecords = new List<OpportunityContactRole>();
            this.contactRecords = new List<Contact>();
        }
    }

    /**
    * @description: Retrieves administration data
    * @param recordId (String) - The Id of the Opportunity
    * @return (ServerResponse)
    **/
    @AuraEnabled public static ServerResponse getAdministrationData(String recordId) { return getAdministrationData(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getAdministrationData(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getAdministrationData';

        CCCUtils.ServerResponse rUtils;
        ServerResponse response = new ServerResponse();
        CCC_Global_Setting__mdt globalSettings;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Opportunity Info
            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(recordId).one();

            // Get Locations
            response.locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', recordId).all();

            if (response.opportunityRecord != null && response.opportunityRecord.AccountId != null) {

                // Find the first Opportunity Contact Role that has IsPrimary checked
                for (OpportunityContactRole oppContactRole: (List<OpportunityContactRole>) CCCQuery.get('OpportunityContactRole').equals('OpportunityId', response.opportunityRecord.Id).all()) {
                    if (oppContactRole.IsPrimary == true) {
                        response.primaryContactId = oppContactRole.ContactId;
                        break;
                    }
                }

                if (response.opportunityRecord.AccountId != null) {

                    // Retrieve all contacts associated with this Opportunity's Account
                    response.contactRecords = (List<Contact>) CCCQuery.get('Contact').equals('AccountId', response.opportunityRecord.AccountId).all();
                }
            }

            // Get Tuition settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();
            response.minTuitionDiscountDollar = globalSettings.Min_Tuition_Discount_Dollar__c;
            response.minTuitionDiscountPercent = globalSettings.Min_Tuition_Discount_Percent__c;

            // Is the user system admin?
            response.userCanWaivePlatformFee = CCCUtils.userHasProfileIn(globalSettings.Waive_Platform_Fee_Profiles__c);

            // The maximum platform fee waived cannot be higher than the patform fees
            Decimal initialPlatformFee = globalSettings.Admin_Initial_Platform_Fee__c;
            Decimal additionalLocationPlatformFee = globalSettings.Admin_Additional_Location_Platform_Fee__c * (response.locationRecords.size() > 0 ? response.locationRecords.size() -1 : 0);
            response.maxPlatformFeeWaived = initialPlatformFee + additionalLocationPlatformFee;

            // Get Location province options
            response.provinceOptions = CCCUtils.getLocationProvinceOptions();

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Saves the coupon code to the opportunity record
    * @param opportunityId (String) - The Id of the Opportunity record
    * @param locationId (String) - The Id of the Location record
    * @param couponCode (String) - The coupon code
    * @param copyToAllLocations (Boolean) - Indicates to copy this coupon code to all the other locations on the Opportunity
    * @return (ServerResponse)
    **/
    @AuraEnabled public static ServerResponse saveCouponCode(String opportunityId, String locationId, String couponCode, String exclusions, Boolean copyToAllLocations) { return saveCouponCode(opportunityId, locationId, couponCode, exclusions, copyToAllLocations, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse saveCouponCode(String opportunityId, String locationId, String couponCode, String exclusions, Boolean copyToAllLocations, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveCouponCode';
        ServerResponse response = new ServerResponse();
        List<Opportunity_Service_Area__c> locationRecordsToUpdate;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) throw new CCCException('Empty opportunityId parameter passed.');
            if (locationId == null) throw new CCCException('Empty locationId parameter passed.');

            locationRecordsToUpdate = new List<Opportunity_Service_Area__c>();
            if (copyToAllLocations) {
                for (Opportunity_Service_Area__c locationRecord : (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityId).all()) {
                    locationRecordsToUpdate.add(new Opportunity_Service_Area__c(Id = locationRecord.Id, Tuition_Discount_Text__c = couponCode, Tuition_Discount_Exclusions__c = exclusions));
                }
            } else {
                locationRecordsToUpdate.add(new Opportunity_Service_Area__c(Id = locationId, Tuition_Discount_Text__c = couponCode, Tuition_Discount_Exclusions__c = exclusions));
            }
            update locationRecordsToUpdate;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Persists a new Contact, or updates an existing Contact
    * @param recordId (String) - The Id for this Opportunity
    * @param contactRecordJSON (String) - JSON representation of the Contact record
    * @param flags (CCCUtils.UnitTestFlags) - For Unit Tests only, set this to an instance of CCCUtils.UnitTestFlags
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static ServerResponse saveContact(String recordId, String contactRecordJSON) { return saveContact(recordId, contactRecordJSON, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse saveContact(String recordId, String contactRecordJSON, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveContact';

        Boolean matchedRecord = false;
        CCCAdministrationController.ServerResponse rAdministration;
        CCCUtils.ServerResponse rUtils;
        Contact contactRecord;
        List<OpportunityContactRole> oppContactRoles;
        Opportunity opportunityRecord;
        OpportunityContactRole oppContactRole;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCUtils.CCCException('Empty recordId parameter passed.');
            if (contactRecordJSON == null) throw new CCCUtils.CCCException('Empty contactRecordJSON parameter passed.');

            try { contactRecord = (Contact) JSON.deserialize(contactRecordJSON, Contact.class); }
            catch (Exception e) { throw new CCCUtils.CCCException('Invalid contactRecordJSON parameter passed.'); }

            // Insert/Update our Contact Record
            upsert contactRecord;

            // Get Fresh data to return back to the component

            // Get Opportunity Record
            rAdministration = getAdministrationData(recordId);
            if (rAdministration.hasErrors) throw new CCCUtils.CCCException(rAdministration.message);

            response.contactRecords = rAdministration.contactRecords;
            response.primaryContactId = rAdministration.primaryContactId;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }

    /**
    * @description Updates the Primary Contact for an Opportunity
    * @param recordId (String) - The Id of the Opportunity record
    * @param contactId (String) - The Id of the Contact record
    * @param flags (CCHSUtils.UnitTestFlags) - For Unit Tests only, set this to an instance of CCHSUtils.UnitTestFlags
    * @return String (JSON) - Serialized Server Response object
    */

    // public method
    @AuraEnabled
    public static ServerResponse savePrimaryContact(String recordId, String contactId) { return savePrimaryContact(recordId, contactId, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse savePrimaryContact(String recordId, String contactId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'savePrimaryContact';

        CCCAdministrationController.ServerResponse rAdministration;
        CCCUtils.ServerResponse rUtils;
        Contact contactRecord;
        List<OpportunityContactRole> opportunityContactRoleRecords;
        Opportunity opportunityRecord;
        OpportunityContactRole oppContactRole;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Empty recordId parameter passed.', (CCCServerResponse) response);
            if (contactId == null) return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Empty contactId parameter passed.', (CCCServerResponse) response);

            // Get Opportunity Record
            opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(recordId).one();

            // Get Contract Record
            contactRecord = (Contact) CCCQuery.get('Contact').equalsId(contactId).one();

            // Get Opportunity Contact Role records
            opportunityContactRoleRecords = (List<OpportunityContactRole>) CCCQuery.get('OpportunityContactRole').equals('OpportunityId', recordId).all();

            // Attempt to find the Opportunity Contact Role that matches the contactId
            for (OpportunityContactRole record: opportunityContactRoleRecords) {
                if (record.ContactId == contactId) {
                    oppContactRole = record;
                    break;
                }
            }

            // If we didn't find our Opportunity Contact Role, create one
            if (oppContactRole == null) {

                // Insert a Opportunity Contact Role record, make it Primary
                oppContactRole = new OpportunityContactRole();
                oppContactRole.ContactId = contactRecord.Id;
                oppContactRole.OpportunityId = opportunityRecord.Id;

                insert oppContactRole;

                // Add this new Opportunity Contact Role to the list
                opportunityContactRoleRecords.add(oppContactRole);
            }


            // Iterate through our Opportunity Contact Role records, set isPrimary to true for our existing/new oppContactRole, all others set isPrimary to false
            for (OpportunityContactRole record: opportunityContactRoleRecords) {
                record.IsPrimary = false;

                // Make sure our existing/new oppContactRole has isPrimary to true
                if (record.ContactId == oppContactRole.ContactId) {
                    record.isPrimary = true;
                }
            }

            update opportunityContactRoleRecords;

            // Successfull save, retrieve fresh data to return back to the component
            rAdministration = getAdministrationData(recordId);
            if (rAdministration.hasErrors) throw new CCCUtils.CCCException(rAdministration.message);

            response.contactRecords = rAdministration.contactRecords;
            response.primaryContactId = rAdministration.primaryContactId;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Updates Opportunity.Platform_Fee_Waived value
    * @param opportunityId (String) - The Id of the Opportunity record
    * @param platformFeeWaived (String) - The value to use for opportunity.Platform_Fee_Waived
    * @param flags (CCHSUtils.UnitTestFlags) - For Unit Tests only, set this to an instance of CCHSUtils.UnitTestFlags
    * @return String (JSON) - Serialized Server Response object
    */

    // public method
    @AuraEnabled
    public static ServerResponse updatePlatformFeeWaived(String opportunityId, Decimal platformFeeWaived) { return updatePlatformFeeWaived(opportunityId, platformFeeWaived, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse updatePlatformFeeWaived(String opportunityId, Decimal platformFeeWaived, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updatePlatformFeeWaived';

        ServerResponse response = new ServerResponse();

        try {
            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Empty opportunityId parameter passed.', (CCCServerResponse) response);

            update new Opportunity(Id = opportunityId, Platform_Fee_Waived__c = platformFeeWaived);
        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }
}