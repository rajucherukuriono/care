/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/09/2020
Description: Apex class to support the Pricing Tab in HomeStars Contract Composer
Changes:

*****************************************************************************/
public without sharing class CCCPricingController {
    static private final String CLASS_NAME = 'ContractComposerPriceController';

    static private final List<String> PRICING_TIER_NAMES = new List<String>{ 'Tier 1', 'Tier 2', 'Tier 3', 'Tier 4', 'Tier 5', 'Flat Rate' };

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Decimal customPricingIndividualMinAmount { get; set; }
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public List<Location> locations { get; set; }
        @AuraEnabled public List<OpportunityContactRole> opportunityContactRoleRecords { get; set; }
        @AuraEnabled public List<Contact> contactRecords { get; set; }
        @AuraEnabled public String primaryContactId { get; set; }
        @AuraEnabled public Boolean userCanWaivePlatformFee { get; set; }
        @AuraEnabled public List<String> provinceOptions { get; set; }
        @AuraEnabled public Decimal maxPlatformFeeWaived { get; set; }
        @AuraEnabled public Composer_Service__c composerServiceRecord { get; set; }

        public ServerResponse() {
            super();
            this.locations = new List<Location>();
            this.opportunityContactRoleRecords = new List<OpportunityContactRole>();
            this.contactRecords = new List<Contact>();
        }
    }

    public class Location {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public Service primaryService { get; set; }
        @AuraEnabled public List<Service> additionalServices { get; set; }
        @AuraEnabled public String pricingTierName { get; set; }
        @AuraEnabled public Decimal bonusPoints { get; set; }

        public Location() {}

        public Location(Opportunity_Service_Area__c locationRecord) {
            this.bonusPoints = 0;
            this.id = locationRecord.Id;
            this.name = locationRecord.Name;
            this.amount = locationRecord.Advertising_Spend__c;
            this.pricingTierName = locationRecord.Pricing_Tier__c;
        }
    }

    // Abstraction to encompass pricing tier fields on Opportunity_Service_Area__c and Opportunity_Location_Service__c
    public class Service {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public List<PricingTier> pricingTiers { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String pricingTierName { get; set; }
        @AuraEnabled public Decimal bonusPoints { get; set; }
        @AuraEnabled public Decimal tierCustomThreshold { get; set; }
        @AuraEnabled public Boolean isFlatRate { get; set; }
        @AuraEnabled public FlatRateTier flatRate { get; set; }

        public Service() {}

        public Service(Composer_Service__c composerServiceRecord, Location loc) {
            this.pricingTiers = new List<PricingTier>();
            this.name = composerServiceRecord.License_Level__c;
            this.tierCustomThreshold = composerServiceRecord.Tier_Custom_Threshold__c;
            this.id = loc.Id;
            this.pricingTierName = loc.pricingTierName;
            this.amount = loc.amount;
            this.isFlatRate = false;
        }

        public Service(Composer_Service__c composerServiceRecord, Opportunity_Location_Service__c locServ) {
            this.pricingTiers = new List<PricingTier>();
            this.name = composerServiceRecord.License_Level__c;
            this.tierCustomThreshold = composerServiceRecord.Tier_Custom_Threshold__c;
            this.id = locServ.Id;
            this.pricingTierName = locServ.Pricing_Tier__c;
            this.amount = locServ.Advertising_Spend__c;
            this.isFlatRate = false;
        }

        public Opportunity_Service_Area__c getLocationRecord() {
             Opportunity_Service_Area__c oppServiceArea = new Opportunity_Service_Area__c(
                Id = this.id,
                Pricing_Tier__c = this.pricingTierName,
                Advertising_Spend__c = this.amount
            );

            if(this.isFlatRate){
                oppServiceArea.Flat_Rate_Billing_Cadence__c = this.flatRate.flatRateCadence;
                if(oppServiceArea.Flat_Rate_Billing_Cadence__c == 'Monthly'){
                    oppServiceArea.Pricing_Tier__c = 'Tier 1';
                } else if(oppServiceArea.Flat_Rate_Billing_Cadence__c == 'Quarterly'){
                    oppServiceArea.Pricing_Tier__c = 'Tier 2';
                } else if(oppServiceArea.Flat_Rate_Billing_Cadence__c == 'Annually'){
                    oppServiceArea.Pricing_Tier__c = 'Tier 3';
                }
            }

            return oppServiceArea;
        }

        public Opportunity_Location_Service__c getLocationServiceRecord() {
            return new Opportunity_Location_Service__c(
                Id = this.id,
                Pricing_Tier__c = this.pricingTierName,
                Advertising_Spend__c = this.amount
            );
        }
    }

    public class PricingTier {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String costPerLead { get; set; }
        @AuraEnabled public Decimal bonusPoints { get; set; }

        public PricingTier() {}

        public PricingTier(String name, Decimal amount, String costPerLead, Decimal bonusPoints) {
            this.name = name;
            this.amount = amount;
            this.costPerLead = costPerLead;
            this.bonusPoints = bonusPoints;
        }
    }

    public class FlatRateTier {
        @AuraEnabled public Decimal flatRateMonthlyBudget { get; set; }
        @AuraEnabled public String flatRateCadence { get; set; }

        public FlatRateTier() {}

        public FlatRateTier(Decimal flatRateMonthlyBudget, String flatRateCadence) {
            this.flatRateMonthlyBudget = flatRateMonthlyBudget;
            this.flatRateCadence = flatRateCadence;
        }
    }


    /**
    * @description Retrieves the Opportunity Category Groups related to the Opportunity to adjust Tiers/Amounts
    * @param recordId (String) - The Opportunity record Id
    * @return (ServerResponse)
    */
    @AuraEnabled
    public static ServerResponse getPricingData(String opportunityId) { return getPricingData(opportunityId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getPricingData(String opportunityId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getPricingData';

        CCC_Global_Setting__mdt globalSettings;
        ServerResponse response = new ServerResponse();

        try {
            // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) throw new CCCException('Empty opportunityId parameter passed.');

            // Get Opportunity Info
            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(opportunityId).one();

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

            // Return Assembled Locations
            response.locations = buildLocations(opportunityId);

            // Get Global Custom Metadata settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            response.customPricingIndividualMinAmount = globalSettings.Custom_Pricing_Individual_Minimum_Amount__c;

            // determine if user can waive platform fee
            response.userCanWaivePlatformFee = CCCUtils.userHasProfileIn(globalSettings.Waive_Platform_Fee_Profiles__c);

            // The maximum platform fee waived cannot be higher than the patform fees
            Decimal initialPlatformFee = globalSettings.Admin_Initial_Platform_Fee__c;
            Decimal additionalLocationPlatformFee = globalSettings.Admin_Additional_Location_Platform_Fee__c * (response.locations.size() > 0 ? response.locations.size() -1 : 0);
            response.maxPlatformFeeWaived = initialPlatformFee + additionalLocationPlatformFee;

            // Get Location province options
            response.provinceOptions = CCCUtils.getLocationProvinceOptions();
            
            //Get ComposerService record/Vertical
            response.composerServiceRecord = [SELECT Id, Vertical__c From Composer_Service__c WHERE Id =: response.opportunityRecord.Composer_Service__c][0];

        } catch(Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        //ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');
        System.debug('Pricing data response:');
        System.debug(response);
        return response;
    }


    /**
    * @description Builds out the locations and addition services structures w/pricing information
    * @param opportunityId (String) - The Opportunity record Id
    * @return (List<Location>)
    */
    @TestVisible private static List<Location> buildLocations(String opportunityId) {
        List<Location> locations = new List<Location>();

        // Get the Opportunity record
        Opportunity opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(opportunityId).one();

        // Get a map of locations keyed on Id
        Map<String, sObject> locationRecordMap = CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityId).toMap();

        // Get a map of opportunity location services keyed on location Id
        Map<String, List<sObject>> locationServiceMap =
            CCCQuery.get('Opportunity_Location_Service__c')
                    .includes('Opportunity_Service_Area__c', locationRecordMap.keySet())
                    .toMapMultiple('Opportunity_Service_Area__c');

        // Get a map of all active Composer Services
        Map<String, sObject> composerServiceMap = CCCQuery.get('Composer_Service__c').equals('Active__c', true).toMap();

        // Loop through the locations and add the primary service as well as any additional services
        System.debug('Build Locations');
        System.debug(locationRecordMap.keySet());
        for (String locationId : locationRecordMap.keySet()) {
            Opportunity_Service_Area__c locationRecord = (Opportunity_Service_Area__c) locationRecordMap.get(locationId);
            Location loc = new Location(locationRecord);

            // Create primary service
            Composer_Service__c composerServiceRecord = (Composer_Service__c) composerServiceMap.get(opportunityRecord.Composer_Service__c);
            System.debug('Flat Rate?');
            System.debug(composerServiceRecord.Vertical__c.contains('Flat Rate'));
            if(!composerServiceRecord.Vertical__c.contains('Flat Rate')){
                loc.primaryService = buildService(composerServiceRecord, loc);
            } else {
                System.debug('Setting flat rate');
                System.debug(composerServiceRecord);
                System.debug(locationRecord);
                
                Service serv = buildService(composerServiceRecord, loc);
                serv.isFlatRate = true;
                serv.flatRate = new FlatRateTier(locationRecord.Advertising_Spend__c, locationRecord.Flat_Rate_Billing_Cadence__c);

                if(locationRecord.Flat_Rate_Billing_Cadence__c == 'Monthly'){
                    serv.tierCustomThreshold = composerServiceRecord.Tier_1_Amount__c;
                } else if(locationRecord.Flat_Rate_Billing_Cadence__c == 'Quarterly'){
                    serv.tierCustomThreshold = composerServiceRecord.Tier_2_Amount__c;
                } else if(locationRecord.Flat_Rate_Billing_Cadence__c == 'Annually'){
                    serv.tierCustomThreshold = composerServiceRecord.Tier_3_Amount__c;
                }

                loc.primaryService = serv;
                System.debug(loc.primaryService);
            }
            

            // If there are any additional services, create additional service objects
            if (locationServiceMap.containsKey(locationId)) {

                loc.additionalServices = new List<Service>();

                for (Opportunity_Location_Service__c locationServiceRecord : (List<Opportunity_Location_Service__c>) locationServiceMap.get(locationId)) {

                    // Get the Composer_Service__c related to the location service
                    composerServiceRecord = (Composer_Service__c) composerServiceMap.get(locationServiceRecord.Composer_Service__c);
                    Service serv = buildService(composerServiceRecord, locationServiceRecord);
                    loc.additionalServices.add(serv);
                }
            }
            locations.add(loc);
        }
        System.debug(locations);
        return locations;
    }


    /**
    * @description Builds out a Service object wrapper containing pricing data for a Location
    * @param composerService (Composer_Service__c) - The Composer_Service__c related to the opportunity
    * @param loc (Location) - The wrapper Location object for an Opportunity_Service_Area__c
    * @return (Service)
    */
    @TestVisible private static Service buildService(Composer_Service__c composerServiceRecord, Location loc) {
        Service serv = new Service(composerServiceRecord, loc);
        return buildService(composerServiceRecord, serv);
    }

    /**
    * @description Builds out a Service object wrapper containing pricing data for a Location Service
    * @param composerService (Composer_Service__c) - The Composer_Service__c related to the Opportunity_Location_Service__c
    * @param locationServiceRecord (Opportunity_Location_Service__c) - The Opportunity_Location_Service__c
    * @return (Service)
    */
    @TestVisible private static Service buildService(Composer_Service__c composerServiceRecord, Opportunity_Location_Service__c locationServiceRecord) {
        Service serv = new Service(composerServiceRecord, locationServiceRecord);
        return buildService(composerServiceRecord, serv);
    }

    @TestVisible private static Service buildService(Composer_Service__c composerServiceRecord, Service serv) {
        for (String pricingTierName : PRICING_TIER_NAMES) {
			System.debug('buildService');
            // Build amount and bonus points field name based on the name of the tier
            String bonusPointsFieldName = pricingTierName.replaceAll(' ', '_') + '_Bonus_Points__c'; // i.e. Tier_1_Bonus_Points__c
            String amountFieldName = pricingTierName.replaceAll(' ', '_') + '_Amount__c'; // i.e. Tier_1_Amount__c
			System.debug('Amount Field name');
            System.debug(amountFieldName);
            // Some tiers may not be defined on a Composer_Service__c so skip those
            System.debug(composerServiceRecord.get(bonusPointsFieldName) != null);
            if (composerServiceRecord.get(bonusPointsFieldName) != null) {

                PricingTier pt = new PricingTier(
                    pricingTierName,
                    // Use the custom amount if it's custom...otherwise use the metadata setting
                    pricingTierName == 'Custom' ? serv.amount : (Decimal) composerServiceRecord.get(amountFieldName),
                    (String) composerServiceRecord.get('Cost_per_Lead_Info__c'),
                    // Use the bonus points configured on the Composer_Service__c
                    (Decimal) composerServiceRecord.get(bonusPointsFieldName)
                );
                System.debug('Pricing tier');
                System.debug(pt);
                serv.pricingTiers.add(pt);
                // If the current tier name is the same as the selected tier name for this serv/loc,
                // set the bonusPoints on the Service.
                if (serv.pricingTierName == pricingTierName) serv.bonusPoints = pt.bonusPoints;
            }
        }

        // Add custom pricing tier
        PricingTier pt = new PricingTier(
            'Custom',
            // If the current tier selected on the service is not custom use a null value
            serv.pricingTierName == 'Custom' ? serv.amount : null,
            (String) composerServiceRecord.get('Cost_per_Lead_Info__c'),
            // Use the bonus points configured on the Composer_Service__c
            (Decimal) composerServiceRecord.get('Custom_Bonus_Points__c')
        );
        // If the current tier name is the same as the selected tier name for this serv/loc,
        // set the bonusPoints on the Service.
        if (serv.pricingTierName == 'Custom') serv.bonusPoints = pt.bonusPoints;
        serv.pricingTiers.add(pt);

        return serv;
    }




    /**
    * @description Saves/Updates an Opportunity Category Group
    * @param recordId (String) - The Opportunity record Id
    * @param locationRecordJSON (String) - JSON representation of the Opportunity Service Area record
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse savePricingData(String opportunityId, String locationRecordJSON) { return savePricingData(opportunityId, locationRecordJSON, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse savePricingData(String opportunityId, String locationRecordJSON, CCCUtils.UnitTestFlags flags) {
        System.debug('Save pricing data');
        System.debug(locationRecordJSON);
        final String METHOD_NAME = 'savePricingData';

        Location loc;
        ServerResponse response = new ServerResponse();

        try {
            // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) throw new CCCException('Empty opportunityId parameter passed.');
            if (locationRecordJSON == null) throw new CCCException('Empty locationRecordJSON parameter passed.');

            try { loc = (Location) JSON.deserialize(locationRecordJSON, Location.class); }
            catch (Exception e) { throw new CCCException('Invalid locationRecordJSON parameter passed.'); }

            System.debug('loc.primaryService');
            System.debug(loc.primaryService);

            // Build out location record from the incoming JSON
            if (loc.primaryService != null) {
                update loc.primaryService.getLocationRecord();
            }

            // Build out location service records from the incoming JSON
            if (loc.additionalServices != null) {
                List<Opportunity_Location_Service__c> updatedLocationServiceRecords = new List<Opportunity_Location_Service__c>();
                for (Service serv : loc.additionalServices) {
                    updatedLocationServiceRecords.add(serv.getLocationServiceRecord());
                }
                update updatedLocationServiceRecords;
            }

            // Return fresh data
            response.locations = buildLocations(opportunityId);

        } catch(Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        //ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');

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
    * @param setAsPrimary (Boolean) - If this is true, set the contact as the primary
    * @param flags (CCCUtils.UnitTestFlags) - For Unit Tests only, set this to an instance of CCCUtils.UnitTestFlags
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static ServerResponse saveContact(String recordId, String contactRecordJSON, Boolean setAsPrimary) { return saveContact(recordId, contactRecordJSON, setAsPrimary, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse saveContact(String recordId, String contactRecordJSON, Boolean setAsPrimary, CCCUtils.UnitTestFlags flags) {
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

            if (setAsPrimary) {
                return savePrimaryContact(recordId, contactRecord.Id);
            } else {
                // Get Fresh data to return back to the component
                response = getPricingData(recordId);
            }

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
            response = getPricingData(recordId);
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