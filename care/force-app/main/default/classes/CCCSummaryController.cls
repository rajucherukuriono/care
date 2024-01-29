/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/21/2020
Description: Provides methods to display contract Summary information and to publish
Changes:

*****************************************************************************/
public without sharing class CCCSummaryController {
    static private final String CLASS_NAME = 'CCCSummaryController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Boolean showPublishAgreementButton { get; set; }
        @AuraEnabled public Boolean showVoidAgreementButton { get; set; }
        @AuraEnabled public Decimal additionalLocationPlatformFee { get; set; }
        @AuraEnabled public Decimal advertisingBudgetTotalAmount { get; set; }
        @AuraEnabled public Decimal agreementTotalAmount { get; set; }
        @AuraEnabled public Decimal initialPlatformFee { get; set; }
        @AuraEnabled public Decimal platformFeeWaived { get; set; }
        @AuraEnabled public Decimal totalPlatformFee { get; set; }
        @AuraEnabled public List<Opportunity_Service_Area__c> locationRecords { get; set; }
        @AuraEnabled public Map<String, List<sObject>> locationServiceRecordsMap { get; set; }
        @AuraEnabled public List<String> publishAgreementDisablementReasons { get; set; }
        @AuraEnabled public List<String> voidAgreementDisablementReasons { get; set; }
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public Contact primaryContactRecord { get; set; }

        public ServerResponse() {
            super();
            this.advertisingBudgetTotalAmount = 0.00;
            this.agreementTotalAmount = 0.00;
            this.locationRecords = new List<Opportunity_Service_Area__c>();
            this.publishAgreementDisablementReasons = new List<String>();
            this.showPublishAgreementButton = false;
            this.showVoidAgreementButton = false;
            this.voidAgreementDisablementReasons = new List<String>();
        }
    }


    /**
    * @description Determines if the Void button is visible, and if so, determines if it is disabled/enabled
    * @param opportunityRecord (Opportunity) - The Salesforce Opportunity record
    * @return (ServerResponse)
    */
    @TestVisible private static ServerResponse getVoidEnablement(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings) { return getVoidEnablement(opportunityRecord, globalSettings, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getVoidEnablement(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getVoidEnablement';

        ServerResponse response = new ServerResponse();
        List<String> voidOpportunityStageNames;
        List<String> publishableOpportunityStageNames;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            voidOpportunityStageNames = globalSettings.Valid_Stages_for_Void__c.split(',');
            publishableOpportunityStageNames = globalSettings.Valid_Stages_for_Publish__c.split(',');

            // Determine if Activate Button is shown to the user based upon the Oppotunity Stage
            if (voidOpportunityStageNames.contains(opportunityRecord.StageName)) {
                response.showVoidAgreementButton = true;
            } else if (publishableOpportunityStageNames.contains(opportunityRecord.StageName)) {

                // Check for Active Agreement Id field on the Opportunity Record, if found, but in a Publishable stage, we need to allow the user to void
                if (opportunityRecord.Agreement_Id__c != null) response.showVoidAgreementButton = true;

            }

            // If we are showing the Void button, determine if it's enabled/disabled
            if (response.showVoidAgreementButton) {

                // No Disablement Reasons currently
            }

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Determines if the Publish button is visible, and if so, determines if it is disabled/enabled
    * @param opportunityRecord (Opportunity) - The Salesforce Opportunity record
    * @return (ServerResponse)
    */
    @TestVisible private static ServerResponse getPublishEnablement(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings) { return getPublishEnablement(opportunityRecord, globalSettings, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getPublishEnablement(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getPublishEnablement';

        ServerResponse response = new ServerResponse();
        List<String> publishableOpportunityStageNames;
        Contact primaryContact;
        List<Opportunity_Service_Area__c> locationRecords;
        Composer_Service__c composerServiceRecord;
        List<String> serviceSpecificFieldsList = new List<String>();
        OpportunityContactRole oppContactRole;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            publishableOpportunityStageNames = globalSettings.Valid_Stages_for_Publish__c.split(',');

            // Get Composer Service record
            if (opportunityRecord.Composer_Service__c != null) composerServiceRecord = opportunityRecord.Composer_Service__r;

            // Location Records
            locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).all();

            // Determine if Publish Button is shown to the user based upon the Oppotunity Stage
            if (publishableOpportunityStageNames.contains(opportunityRecord.StageName)) response.showPublishAgreementButton = true;

            // If we are showing the Publish button, determine if it's enabled/disabled
            if (response.showPublishAgreementButton) {

                // Disablement Reason - Verify Opportunity has the Composer Service field populated
                if (composerServiceRecord == null) response.publishAgreementDisablementReasons.add('A Service must be selected in order to publish.');
                else {

                    if (composerServiceRecord.Service_Specific_Fields__c != null) {
                        serviceSpecificFieldsList = composerServiceRecord.Service_Specific_Fields__c.split(',');

                        // Trim off any leading/trailing whitespace
                        for (Integer counter = 0; counter < serviceSpecificFieldsList.size(); counter++) {
                            serviceSpecificFieldsList[counter] = serviceSpecificFieldsList[counter].trim();
                        }
                    }

                    // Validations for location records
                    for (Opportunity_Service_Area__c locationRecord: locationRecords) {

                        if (String.isEmpty(locationRecord.City__c) || String.isEmpty(locationRecord.State__c) || String.isEmpty(locationRecord.Street__c) || String.isEmpty(locationRecord.Postal_Code__c)) {
                            response.publishAgreementDisablementReasons.add('The Location "' + locationRecord.Name + '" is missing Address fields.');
                        }

                        if (String.isEmpty(locationRecord.Registered_Entity_Name__c) || String.isEmpty(locationRecord.Registered_Entity_City__c) || String.isEmpty(locationRecord.Registered_Entity_State__c) || String.isEmpty(locationRecord.Registered_Entity_Street__c) || String.isEmpty(locationRecord.Registered_Entity_Postal_Code__c)) {
                            response.publishAgreementDisablementReasons.add('The Location "' + locationRecord.Name + '" is missing Registered Entity Name/Address fields.');
                        }

                        // Make sure Background Check fields are populated
                        if (composerServiceRecord.Vetting_Type__c == 'Background Check' || composerServiceRecord.Vetting_Type__c == 'Both') {
                            if (String.isEmpty(locationRecord.BGC_First_Name__c) || String.isEmpty(locationRecord.BGC_Last_Name__c) || String.isEmpty(locationRecord.BGC_Street__c) || String.isEmpty(locationRecord.BGC_City__c) || String.isEmpty(locationRecord.BGC_State__c) || String.isEmpty(locationRecord.BGC_Postal_Code__c)) {
                                response.publishAgreementDisablementReasons.add('The Location "' + locationRecord.Name + '" is missing Background Check information on the Vetting tab.');
                            }
                        }

                        // Make sure min/max age are populated
                        if (composerServiceRecord.Vertical__c == 'Childcare' || composerServiceRecord.Vertical__c == 'Childcare Flat Rate') {
                            if (locationRecord.Minimum_Age__c == null || locationRecord.Maximum_Age__c == null) {
                                response.publishAgreementDisablementReasons.add('The Location "' + locationRecord.Name + '" is missing either Minimum or Maximum age.');
                            }
                            
                            //Make sure selected at least one type card 
                            
                            if(locationRecord.Child_Care_Infant__c || locationRecord.Child_Care_Toddler__c
                               || locationRecord.Child_Care_Pre_School__c || locationRecord.Child_Care_School_Aged__c || locationRecord.Child_Care_Pre_Teens_Teens__c){
                              
                               }else{response.publishAgreementDisablementReasons.add('You must have at least one Care Type must be selected on Vetting tab to order to publish.');}
                        }

                        // Check to see if we have Service Specific fields to check, if we do, then check the location to make sure those fields are populated
                        if (serviceSpecificFieldsList.size() > 0) {
                            Boolean missingRequiredFields = false;

                            for (String serviceSpecificField: serviceSpecificFieldsList) {

                                if (locationRecord.get(serviceSpecificField) == null) {
                                    missingRequiredFields = true;
                                    break;
                                }
                            }

                            if (missingRequiredFields) {
                                response.publishAgreementDisablementReasons.add('The Location "' + locationRecord.Name + '" is missing information from required fields on the Vetting tab.');
                            }
                        }
                    }
                }

                // Disablement Reason - Verify the Opportunity has the Agreement Id field NOT populated
                // if (opportunityRecord.Agreement_Id__c != null) response.publishAgreementDisablementReasons.add('The Agreement has an active agreement Id, and must be voided before it can be published.');

                // Disablement Reason - Verify Opportunity Locations (Opportunity_Service_Area) records are not empty
                if (locationRecords.size() == 0) response.publishAgreementDisablementReasons.add('You must have at least one Location defined in order to publish.');
                
                //system.assert(false);
                // Disablement Reason - Opportunity must be in one of the publishable stages
                // if (opportunityRecord.StageName == 'Contract Sent') response.publishAgreementDisablementReasons.add('The Agreement has already been published.');

                // Disablement Reason - Opportunity must have a Primary Contact selected
                for (OpportunityContactRole record: (List<OpportunityContactRole>) CCCQuery.get('OpportunityContactRole').equals('OpportunityId', opportunityRecord.Id).all()) {
                    if (record.IsPrimary == true) {
                        oppContactRole = record;
                        break;
                    }
                }

                if (oppContactRole == null) response.publishAgreementDisablementReasons.add('A Primary Contact must be selected in order to publish.');
            }

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Retrieves various metrics from Contract Composer to display at a high level summary view
    * @param recordId (String) - The Id of the Opportunity record that is being viewed
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getSummaryData(String recordId) { return getSummaryData(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getSummaryData(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getSummaryData';

        ServerResponse response = new ServerResponse();
        ServerResponse rSummary;
        CCCScoreboardController.ServerResponse rScoreboard;
        Map<String, sObject> locationRecordMap;

        CCC_Global_Setting__mdt globalSettings;
        Date today = System.today();
        Id primaryContactId;


        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Opportunity info
            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(recordId).one();
            if (response.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            // Get Contract Composer Global Custom Metadata Settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            locationRecordMap = CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', recordId).toMap();
            response.locationRecords = (List<Opportunity_Service_Area__c>) locationRecordMap.values();

            // Get a map of a list of location service records keyed on location id
            response.locationServiceRecordsMap =
                CCCQuery.get('Opportunity_Location_Service__c')
                        .add('Composer_Service__c')
                        .includes('Opportunity_Service_Area__c', locationRecordMap.keySet())
                        .toMapMultiple('Opportunity_Service_Area__c');

            // Get many different calculations that Scoreboard does
            rScoreboard = CCCScoreboardController.getScoreboardData(recordId, true);
            if (rScoreboard.hasErrors) throw new CCCException(rScoreboard.message);

            response.additionalLocationPlatformFee = rScoreboard.additionalLocationPlatformFee;
            response.advertisingBudgetTotalAmount = rScoreboard.advertisingBudgetTotalAmount;
            response.agreementTotalAmount = rScoreboard.agreementTotalAmount;
            response.initialPlatformFee = rScoreboard.initialPlatformFee;
            response.totalPlatformFee = rScoreboard.totalPlatformFee;
            response.platformFeeWaived = rScoreboard.platformFeeWaived;

            // Find the first Opportunity Contact Role that has IsPrimary checked
            for (OpportunityContactRole oppContactRole: (List<OpportunityContactRole>) CCCQuery.get('OpportunityContactRole').equals('OpportunityId', response.opportunityRecord.Id).all()) {
                if (oppContactRole.IsPrimary == true) {

                    // Retrieve the primary Contact record
                    response.primaryContactRecord = (Contact) CCCQuery.get('Contact').equals('Id', oppContactRole.ContactId).one();
                    break;
                }
            }

            // Publish button logic
            rSummary = getPublishEnablement(response.opportunityRecord, globalSettings);
            if (rSummary.hasErrors) throw new CCCException(rSummary.message);

            response.showPublishAgreementButton = rSummary.showPublishAgreementButton;
            response.publishAgreementDisablementReasons = rSummary.publishAgreementDisablementReasons;

            // See if Platform Fee Waived is valid
            // It would be nicer to have this logic in getPublishEnablement() but that would require
            // an extra call to getScoreBoardData()
            if (response.platformFeeWaived > (response.additionalLocationPlatformFee + response.initialPlatformFee)) {
                response.publishAgreementDisablementReasons.add('The Platform Fee Waived cannot be greater than the Total Platform Fee.');
            }

            // Void button logic
            rSummary = getVoidEnablement(response.opportunityRecord, globalSettings);
            if (rSummary.hasErrors) throw new CCCException(rSummary.message);

            response.showVoidAgreementButton = rSummary.showVoidAgreementButton;
            response.voidAgreementDisablementReasons = rSummary.voidAgreementDisablementReasons;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Performs the necessary Salesforce logic and API calls to publish the Agreement
    * @param recordId (String) - The Id of the Opportunity record
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static ServerResponse publishAgreement(String recordId) { return publishAgreement(recordId, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse publishAgreement(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'publishAgreement';

        Account accountRecord;
        CCCAPIReqCreateSalesContract request;
        CCCAPIReqCreateSalesContract.LocationObject location;
        CCCAPIReqCreateSalesContract.OfferingObject offering;
        CCCAPIReqCreateSalesContract.ReviewObject review;
        CCCAPIReqCreateSalesContract.SalesContractObject salesContract;
        CCCAPIRespCreateSalesContract.ServerResponse rCalloutMaster;
        CCCScoreboardController.ServerResponse rScoreboard;
        CCCSummaryController.ServerResponse response = new CCCSummaryController.ServerResponse();
        CCCUtils.ServerResponse rUtils;
        CCC_Global_Setting__mdt globalSettings;
        Composer_Service__c composerServiceRecord;
        Contact contactRecord;
        List<CCCAPIReqCreateSalesContract.ReviewObject> reviews;
        List<Opportunity_Location_Service__c> locationServiceRecords;
        List<Opportunity_Service_Area__c> locationRecords;
        Map<Id, List<Opportunity_Location_Service__c>> locationToServicesMap = new Map<Id, List<Opportunity_Location_Service__c>>();
        Opportunity opportunityRecord;
        Opportunity updatedOpportunity;
        OpportunityContactRole oppContactRole;
        ServerResponse rSummary;
        Set<String> locationRecordIds;
        String recordType;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');
            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Contract Composer Global Custom Metadata Settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();


            // Get Opportunity Record - Need the recordType as well as the opportunity record
            rUtils = CCCUtils.getOpportunityRecord(recordId);
            if (rUtils.hasErrors) throw new CCCException(rUtils.message);
            if (rUtils.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            opportunityRecord = rUtils.opportunityRecord;
            recordType = rUtils.recordType;

            // Get Composer Service Record
            composerServiceRecord = (Composer_Service__c) CCCQuery.get('Composer_Service__c').equalsId(opportunityRecord.Composer_Service__c).one();

            // Check to see if this Opportunity has an Active Agreement Id, if so need to fail out
            if (opportunityRecord.Agreement_Id__c != null) throw new CCCException('This Agreement has already been published.');


            // Get Account Record
            accountRecord = (Account) CCCQuery.get('Account').equalsId(opportunityRecord.AccountId).one();


            // Get Scoreboard calculations
            rScoreboard = CCCScoreboardController.getScoreboardData(recordId, true);
            if (rScoreboard.hasErrors) throw new CCCException(rScoreboard.message);


            // Get Location records
            locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityRecord.Id).all();


            // Build out Map of Location to Location Services
            locationRecordIds = new Set<String>();
            for (Opportunity_Service_Area__c record: locationRecords) {
                locationRecordIds.add(record.Id);
                locationToServicesMap.put(record.Id, new List<Opportunity_Location_Service__c>());
            }

            // Get all Location Service records matching these Location Ids
            for (Opportunity_Location_Service__c locationServiceRecord: (List<Opportunity_Location_Service__c>) CCCQuery.get('Opportunity_Location_Service__c').add('Composer_Service__c').includes('Opportunity_Service_Area__c', locationRecordIds).all()) {
                locationToServicesMap.get(locationServiceRecord.Opportunity_Service_Area__c).add(locationServiceRecord);
            }

            // Primary Contact Role
            for (OpportunityContactRole record: (List<OpportunityContactRole>) CCCQuery.get('OpportunityContactRole').equals('OpportunityId', recordId).all()) {
                if (record.IsPrimary == true) {
                    oppContactRole = record;
                    break;
                }
            }

            // Get Contact Record for Opportunity Contact Role
            contactRecord = (Contact) CCCQuery.get('Contact').equalsId(oppContactRole.ContactId).one();


            // Create Sales Contract object
            request = new CCCAPIReqCreateSalesContract();
            request.sales_contract = new CCCAPIReqCreateSalesContract.SalesContractObject();
            request.sales_contract.salesforce_opportunity_id = opportunityRecord.Id;
            request.sales_contract.contract_status = 'published';
            request.sales_contract.platform_fee = globalSettings.Admin_Initial_Platform_Fee__c; // @jmw: changed from calculated amount to just sending the base platform fee
            request.sales_contract.per_location_fee = globalSettings.Admin_Additional_Location_Platform_Fee__c; // @jmw: new field to send the additional location fee
            request.sales_contract.platform_fee_discount = rScoreboard.platformFeeWaived;

            // Vertical
            if (composerServiceRecord.Vertical__c == 'Childcare') request.sales_contract.vertical = 'child_care';
            if (composerServiceRecord.Vertical__c == 'Senior Care') request.sales_contract.vertical = 'senior_care';
            if (composerServiceRecord.Vertical__c == 'Childcare Flat Rate') request.sales_contract.vertical = 'child_care_flat_rate';

            // Service
            if (composerServiceRecord.License_Level__c == 'Centers') request.sales_contract.service = 'centers';
            if (composerServiceRecord.License_Level__c == 'Nanny Agencies') request.sales_contract.service = 'nanny_agencies';
            if (composerServiceRecord.License_Level__c == 'FCCs') request.sales_contract.service = 'fccs';
            if (composerServiceRecord.License_Level__c == 'Camps') request.sales_contract.service = 'camps';
            if (composerServiceRecord.License_Level__c == 'Activities') request.sales_contract.service = 'activities';
            if (composerServiceRecord.License_Level__c == 'Home Care') request.sales_contract.service = 'home_care';
            if (composerServiceRecord.License_Level__c == 'Housing') request.sales_contract.service = 'housing';
            if (composerServiceRecord.License_Level__c == 'Special Needs') request.sales_contract.service = 'special_needs';
            if (composerServiceRecord.License_Level__c == 'Adult Day Care') request.sales_contract.service = 'adult_day_care';

            // If our account already has a Galore Business Id, be sure to send it so we don't create a new one on the API side
            if (accountRecord.Galore_Business_Id__c != null) request.sales_contract.business_id = accountRecord.Galore_Business_Id__c;

            // Business
            request.sales_contract.business = new CCCAPIReqCreateSalesContract.BusinessObject();
            request.sales_contract.business.name = accountRecord.Name;
            request.sales_contract.business.address = new CCCAPIReqCreateSalesContract.AddressObject();
            request.sales_contract.business.address.line1 = locationRecords[0].Street__c;
            request.sales_contract.business.address.line2 = null;
            request.sales_contract.business.address.city = locationRecords[0].City__c;
            request.sales_contract.business.address.state = locationRecords[0].State__c;
            request.sales_contract.business.address.postal_code = locationRecords[0].Postal_Code__c;

            // Business Owner
            request.sales_contract.business_owner = new CCCAPIReqCreateSalesContract.BusinessOwnerObject();
            request.sales_contract.business_owner.first_name = contactRecord.FirstName;
            request.sales_contract.business_owner.last_name = contactRecord.LastName;
            request.sales_contract.business_owner.email = contactRecord.Email;
            request.sales_contract.business_owner.phone = contactRecord.Phone;

            // Add primary (and potentially secondary) Sales Rep Information
            request.sales_contract.sales_reps = new List<CCCAPIReqCreateSalesContract.SalesRepObject>();
            // Add the current user
            List<String> salesRepUserIds = new List<String>{ UserInfo.getUserId() };
            // Add secondary user
            if (opportunityRecord.Secondary_Rep__c != null) {
                salesRepUserIds.add(opportunityRecord.Secondary_Rep__c);
            }

            CCCAPIReqCreateSalesContract.SalesRepObject salesRep;
            for (User u : [SELECT Email, FirstName, LastName FROM User WHERE Id IN :salesRepUserIds]) {
                salesRep = new CCCAPIReqCreateSalesContract.SalesRepObject();
                salesRep.salesforce_id = u.Id;
                salesRep.email = u.Email;
                salesRep.first_name = u.FirstName;
                salesRep.last_name = u.LastName;
                request.sales_contract.sales_reps.add(salesRep);
            }

            // Locations
            request.sales_contract.locations = new List<CCCAPIReqCreateSalesContract.LocationObject>();

            for (Opportunity_Service_Area__c locationRecord: locationRecords) {

                location = new CCCAPIReqCreateSalesContract.LocationObject();
                location.name = locationRecord.Name;
                location.salesforce_id = locationRecord.Id;
                location.monthly_advertising_budget = locationRecord.Advertising_Spend__c;
                location.advertising_areas = locationRecord.Postal_Codes__c.split(',+ *'); // split on comma and possible space, may need to revisit
                location.phone = locationRecord.Phone__c;
                location.email = locationRecord.Email__c;
                if(request.sales_contract.vertical == 'child_care_flat_rate'){
                    location.flat_rate_amount = locationRecord.Advertising_Spend__c;
                    location.contract_length = Integer.valueOf(locationRecord.Flat_Rate_Billing_In_Months__c);
                } 
                
                // Age Range (if applicable to vertical)
                if (composerServiceRecord.Show_Age_Range_Field__c) {
                    location.min_months = locationRecord.Minimum_Age__c;
                    location.max_months = locationRecord.Maximum_Age__c;
                }

                // Address
                location.address = new CCCAPIReqCreateSalesContract.AddressObject();
                location.address.line1 = locationRecord.Street__c;
                location.address.line2 = null;
                location.address.city = locationRecord.City__c;
                location.address.state = locationRecord.State__c;
                location.address.postal_code = locationRecord.Postal_Code__c;

                // License
                location.license = new CCCAPIReqCreateSalesContract.LicenseObject();
                location.license.license_number = locationRecord.License_Number__c;
                location.license.business_name = locationRecord.Registered_Entity_Name__c;

                // License Address
                location.license.address = new CCCAPIReqCreateSalesContract.AddressObject();
                location.license.address.line1 = locationRecord.Registered_Entity_Street__c;
                location.license.address.line2 = null;
                location.license.address.city = locationRecord.Registered_Entity_City__c;
                location.license.address.state = locationRecord.Registered_Entity_State__c;
                location.license.address.postal_code = locationRecord.Registered_Entity_Postal_Code__c;

                // Offerings
                location.offerings = createOfferingObjects(locationRecord);

                // Discounts
                if (locationRecord.Tuition_Discount_Text__c != null) {
                    location.discounts = new List<CCCAPIReqCreateSalesContract.DiscountObject>();
                    CCCAPIReqCreateSalesContract.DiscountObject discount = new CCCAPIReqCreateSalesContract.DiscountObject();

                    // Check if discount is dollar amount or percent
                    if (locationRecord.Tuition_Discount_Text__c.contains('$')) {
                        discount.type = 'money';
                        discount.amount_cents = parseCouponValue(locationRecord.Tuition_Discount_Text__c) * 100;
                    } else {
                        discount.type = 'percentage';
                        discount.percent = parseCouponValue(locationRecord.Tuition_Discount_Text__c);
                    }
                    discount.exclusions = locationRecord.Tuition_Discount_Exclusions__c;
                    discount.available = true;
                    discount.audience = null; // No option for this on the Salesforce side
                    location.discounts.add(discount);
                }

                request.sales_contract.locations.add(location);
            }

            // Reviews
            reviews = new List<CCCAPIReqCreateSalesContract.ReviewObject>();
            for (Review_Reference__c reviewRecord : (List<Review_Reference__c>) CCCQuery.get('Review_Reference__c').field('Location__r.Name').equals('Account__c', opportunityRecord.AccountId).all()) {
                review = new CCCAPIReqCreateSalesContract.ReviewObject();
                review.first_name = reviewRecord.First_Name__c;
                review.last_name = reviewRecord.Last_Name__c;
                review.email = reviewRecord.Email__c;
                review.phone = reviewRecord.Phone__c;
                review.location_name = reviewRecord.Location__r.Name;

                reviews.add(review);
            }

            request.sales_contract.reviews = reviews;


            // Invoke the Callout Master to execute the request and return the response
            rCalloutMaster = (CCCAPIRespCreateSalesContract.ServerResponse) CCCCalloutMaster.createSalesContract(request);
            if (rCalloutMaster.hasErrors) throw new CCCException(rCalloutMaster.message);

            // API Call was Successfull

            // Update Opportunity to reflect the published state
            updatedOpportunity = new Opportunity();
            updatedOpportunity.Id = recordId;
            updatedOpportunity.StageName = 'Contract Sent';
            updatedOpportunity.Amount = rScoreboard.agreementTotalAmount;
            updatedOpportunity.Agreement_Id__c = rCalloutMaster.sales_contract.uuid;

            // Sales Origination specific logic
            if (recordType == 'SO') {

                // Points
                updatedOpportunity.Base_Points__c = rScoreboard.basePoints;
                updatedOpportunity.Bonus_Points__c = rScoreboard.bonusPoints;
            }

            update updatedOpportunity;

            // Update Galore business_id on the Account (only if it's different)
            if (accountRecord.Galore_Business_Id__c != rCalloutMaster.sales_contract.business_id) {
                update new Account(Id = accountRecord.Id, Galore_Business_Id__c = rCalloutMaster.sales_contract.business_id);
            }

            // Updates to Location (Opportunity_Service_Area) records
            for (Opportunity_Service_Area__c locationRecord: locationRecords) {

                // Reset the License info so we get fresh license data back
                locationRecord.License_Details__c = null;
                locationRecord.License_Status__c = null;

                // Update the location records with Galore Ids
                for (CCCAPIRespCreateSalesContract.LocationObject loc: rCalloutMaster.sales_contract.business.locations) {
                    if (locationRecord.Id == loc.salesforce_id) {
                        locationRecord.Galore_uuid__c = loc.uuid;
                        break;
                    }
                }
            }

            update locationRecords;

            // Fail out if we have any errors before getting fresh data;
            if (response.hasErrors) return response;


            // Get fresh data
            return getSummaryData(recordId);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }
    }


    /**
    * @description Creates and returns a list of CCCAPIReqCreateSalesContract.OfferingObject
    * @param locationRecord (Opportunity_Service_Area__c) - The Opportunity Service Area
    * @return (List<CCCAPIReqCreateSalesContract.OfferingObject>)
    */
    private static List<CCCAPIReqCreateSalesContract.OfferingObject> createOfferingObjects(Opportunity_Service_Area__c locationRecord) {
        List<CCCAPIReqCreateSalesContract.OfferingObject> offeringObjects = new List<CCCAPIReqCreateSalesContract.OfferingObject>();

        if (locationRecord.Child_Care_Infant__c == true) {
            offeringObjects.add(createOfferingObject('child_care_infant', locationRecord.Child_Care_Infant_Capacity__c, locationRecord.Child_Care_Infant_Starting_Rent__c));
        }

        if (locationRecord.Child_Care_Pre_School__c == true) {
            offeringObjects.add(createOfferingObject('child_care_pre_school', locationRecord.Child_Care_Pre_School_Capacity__c, locationRecord.Child_Care_Pre_School_Starting_Rent__c));
        }

        if (locationRecord.Child_Care_School_Aged__c == true) {
            offeringObjects.add(createOfferingObject('child_care_school_aged', locationRecord.Child_Care_School_Aged_Capacity__c, locationRecord.Child_Care_School_Aged_Starting_Rent__c));
        }

        if (locationRecord.Child_Care_Toddler__c == true) {
            offeringObjects.add(createOfferingObject('child_care_toddler', locationRecord.Child_Care_Toddler_Capacity__c, locationRecord.Child_Care_Toddler_Starting_Rent__c));
        }

        if (locationRecord.Child_Care_Pre_Teens_Teens__c == true) {
            offeringObjects.add(createOfferingObject('child_care_pre_teens_and_teens', locationRecord.Child_Care_Pre_Teens_Teens_Capacity__c, locationRecord.Child_Care_Pre_Teens_Teens_Starting_Rent__c));
        }

        if (locationRecord.Senior_Care_Assisted_Living__c == true) {
            offeringObjects.add(createOfferingObject('senior_care_assisted_living', locationRecord.Senior_Care_Assisted_Liv_Capacity__c, locationRecord.Senior_Care_Assisted_Liv_Starting_Rent__c));
        }

        if (locationRecord.Senior_Care_Independent_Living__c == true) {
            offeringObjects.add(createOfferingObject('senior_care_independent_living', locationRecord.Senior_Care_Indep_Living_Capacity__c, locationRecord.Senior_Care_Indep_Living_Starting_Rent__c));
        }

        if (locationRecord.Senior_Care_Memory_Care__c == true) {
            offeringObjects.add(createOfferingObject('senior_care_memory_care', locationRecord.Senior_Care_Memory_Care_Capacity__c, locationRecord.Senior_Care_Memory_Care_Starting_Rent__c));
        }

        return offeringObjects;
    }


    /**
    * @description Creates and returns an instance of CCCAPIReqCreateSalesContract.OfferingObject
    * @param careType (String) - The value used to populate offering.care_type
    * @param capacity (Decimal) - The value used to populate offering.capacity
    * @param price (Decimal) - The value used to populate offering.price
    * @return (CCCAPIReqCreateSalesContract.OfferingObject)
    */
    private static CCCAPIReqCreateSalesContract.OfferingObject createOfferingObject(String careType, Decimal capacity, Decimal price) {
        CCCAPIReqCreateSalesContract.OfferingObject offering = new CCCAPIReqCreateSalesContract.OfferingObject();
        offering.care_type = careType;
        offering.capacity = capacity;
        offering.price = price;
        return offering;
    }


    /**
    * @description Strips out the text of a coupon code and returns the Integer value
    * @param couponText (String) - The coupon code text
    * @return (ServerResponse)
    */
    @TestVisible
    private static Integer parseCouponValue(String couponText) {
        Pattern p = Pattern.compile('[^0-9]*');
        return Integer.valueOf(p.matcher(couponText).replaceAll(''));
    }


    /**
    * @description Performs the necessary Salesforce logic and API calls to void the Agreement
    * @param recordId (String) - The Id of the Opportunity record
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static ServerResponse voidAgreement(String recordId) { return voidAgreement(recordId, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse voidAgreement(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'voidAgreement';

        CCCAPIReqUpdateSalesContract request;
        CCCAPIRespUpdateSalesContract.ServerResponse rCalloutMaster;
        Map<String, String> customParameters;
        Opportunity opportunityRecord;
        Opportunity updatedOpportunity;
        ServerResponse response = new ServerResponse();

        try {
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');
            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Opportunity Record
            opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(recordId).one();

            // Before making API call, make sure the Opportunity has been successfully published first
            if (opportunityRecord.Agreement_Id__c == null) throw new CCCException('The Agreement Id has not been set for this Opportunity, has it been successfully Published?');

            // Custom Parameters to be used for the API call
            customParameters = new Map<String, String>();
            customParameters.put('uuid', opportunityRecord.Agreement_Id__c);

            // Update Sales Contract object
            request = new CCCAPIReqUpdateSalesContract();
            request.sales_contract = new CCCAPIReqUpdateSalesContract.SalesContract();
            request.sales_contract.contract_status = 'void';

            // Invoke the Callout Master to execute the request and return the response
            rCalloutMaster = (CCCAPIRespUpdateSalesContract.ServerResponse) CCCCalloutMaster.updateSalesContract(request, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCException(rCalloutMaster.message);

            // API Call was Successfull, update the Opportunity and Opportunity_Category_Exclusions
            updatedOpportunity = new Opportunity ();
            updatedOpportunity.Id = recordId;
            updatedOpportunity.StageName = 'In Progress';
            updatedOpportunity.Agreement_Id__c = null;
            updatedOpportunity.Base_Points__c = null;
            updatedOpportunity.Bonus_Points__c = null;
            updatedOpportunity.Composer_Coupon_Text__c = null;

            update updatedOpportunity;

            // Fail out if we have any errors before getting fresh data;
            if (response.hasErrors) return response;

            // Get fresh data
            return getSummaryData(recordId);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }
    }
}