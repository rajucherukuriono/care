/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 10/05/2020
Description: Apex controller for CCCActiveAgreement Aura Component

Comments:

*****************************************************************************/
public without sharing class CCCActiveAgreementController {
    private static String CLASS_NAME = 'CCCActiveAgreementController';

    // Response class used to serialize data to be returned to the lightning component
    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Account accountRecord { get; set; }
        @AuraEnabled public CCCAPIRespFetchABusiness.BusinessObject businessRecord { get; set; }
        // @AuraEnabled public String businessRecordJSONText { get; set; }
        @AuraEnabled public CCCAPIRespUpdateOffering.OfferingObject offeringRecord { get; set; }
        @AuraEnabled public CCCAPIRespUpdateProvider.ProviderObject providerRecord { get; set; }
        @AuraEnabled public CCCActiveAgreementController.ReviewObject reviewRecord { get; set; }
        @AuraEnabled public Boolean showCancelAgreementButton { get; set; }
        @AuraEnabled public Boolean showModifyLocationButton { get; set; }

        public ServerResponse() {
            super();
            this.showCancelAgreementButton = false;
            this.showModifyLocationButton = false;
        }
    }

    public class ReviewObject {
        @AuraEnabled public Boolean verified { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String location_name { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String uuid { get; set; }

        public ReviewObject(CCCAPIRespCreateReview.ReviewObject reviewObject) {
            this.email = reviewObject.email;
            this.first_name = reviewObject.first_name;
            this.last_name = reviewObject.last_name;
            this.location_name = reviewObject.location_name;
            this.phone = reviewObject.phone;
            this.uuid = reviewObject.uuid;
            this.verified = reviewObject.verified;
        }

        public ReviewObject(CCCAPIRespUpdateReview.ReviewObject reviewObject) {
            this.email = reviewObject.email;
            this.first_name = reviewObject.first_name;
            this.last_name = reviewObject.last_name;
            this.location_name = reviewObject.location_name;
            this.phone = reviewObject.phone;
            this.uuid = reviewObject.uuid;
            this.verified = reviewObject.verified;
        }
    }


    /**
    * @description: Retireves Active Agreement data
    * @param accountId (String) - The Id of the Account record
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse getActiveAgreementData(String accountId) { return getActiveAgreementData(accountId, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse getActiveAgreementData(String accountId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getActiveAgreementData';

        Account oAccount;
        CCCAPIReqFetchABusiness request;
        CCCAPIRespFetchABusiness.ServerResponse rFetchABusiness;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();
        CCC_Global_Setting__mdt globalSettings;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (accountId == null) throw new CCCUtils.CCCException('Empty accountId parameter passed.');


            // Get Account Information
            response.accountRecord = (Account) CCCQuery.get('Account').equalsId(accountId).one();

            // Get Contract Composer Global Custom Metadata Settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            // Fail out early if the Account doesn't have the Galore Business Id set
            if (response.accountRecord.Galore_Business_Id__c == null) throw new CCCUtils.CCCException('Account does not have the Galore Business Id');

            // Determine if the Cancel Agreement button is displayed
            Boolean inCancelAgreementProfiles = CCCUtils.userHasProfileIn(globalSettings.Cancel_Agreement_Profiles__c);
            response.showCancelAgreementButton = inCancelAgreementProfiles;
            response.showModifyLocationButton = inCancelAgreementProfiles;

            // Custom Parameters for API call
            customParameters = new Map<String, String>();
            customParameters.put('businessId', response.accountRecord.Galore_Business_Id__c);

            // Create API Request
            request = new CCCAPIReqFetchABusiness();

            // API Call - Fetch a Business
            rFetchABusiness = (CCCAPIRespFetchABusiness.ServerResponse) CCCCalloutMaster.fetchABusiness(request, customParameters);
            if (rFetchABusiness.hasErrors) throw new CCCUtils.CCCException(rFetchABusiness.message);

            response.businessRecord = rFetchABusiness.business;
            // response.businessRecordJSONText = rFetchABusiness.jsonText;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Updates the Offering to the Galore API
    * @param offeringId (String) - The Offering UUID of the record record
    * @param offeringRecordJSON (String) - The JSON representation of the Offering record
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse updateOffering(String offeringId, String offeringRecordJSON) { return updateOffering(offeringId, offeringRecordJSON, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse updateOffering(String offeringId, String offeringRecordJSON, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateOffering';

        CCCAPIReqUpdateOffering request;
        CCCAPIReqUpdateOffering.OfferingObject offeringRecord;
        CCCAPIRespUpdateOffering.ServerResponse rUpdateOffering;
        CCCActiveAgreementController.ServerResponse rActiveAgreements;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (offeringId == null) throw new CCCUtils.CCCException('Empty offeringId parameter passed.');
            if (offeringRecordJSON == null) throw new CCCUtils.CCCException('Empty offeringRecordJSON parameter passed.');

            try { offeringRecord = (CCCAPIReqUpdateOffering.OfferingObject) JSON.deserialize(offeringRecordJSON, CCCAPIReqUpdateOffering.OfferingObject.class); }
            catch (Exception e) { throw new CCCException('Invalid offeringRecordJSON parameter passed.'); }


            // Custom Parameters for API call
            customParameters = new Map<String, String>();
            customParameters.put('uuid', offeringId);

            // Create API Request
            request = new CCCAPIReqUpdateOffering();
            request.offering = new CCCAPIReqUpdateOffering.OfferingObject();
            request.offering.active = offeringRecord.active;

            // API Call - Update Offering
            rUpdateOffering = (CCCAPIRespUpdateOffering.ServerResponse) CCCCalloutMaster.updateOffering(request, customParameters);
            if (rUpdateOffering.hasErrors) throw new CCCUtils.CCCException(rUpdateOffering.message);

            response.offeringRecord = rUpdateOffering.offering;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Updates the Location/Provider to the Galore API
    * @param providerId (String) - The Provider UUID of the record record
    * @param providerRecordJSON (String) - The JSON representation of the Provider record
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse updateProvider(String providerId, String providerRecordJSON) { return updateProvider(providerId, providerRecordJSON, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse updateProvider(String providerId, String providerRecordJSON, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateProvider';

        CCCAPIReqUpdateProvider request;
        CCCAPIReqUpdateProvider.ProviderObject providerRecord;
        CCCAPIRespUpdateProvider.ServerResponse rUpdateProvider;
        CCCActiveAgreementController.ServerResponse rActiveAgreements;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (providerId == null) throw new CCCUtils.CCCException('Empty providerId parameter passed.');
            if (providerRecordJSON == null) throw new CCCUtils.CCCException('Empty providerRecordJSON parameter passed.');

            try { providerRecord = (CCCAPIReqUpdateProvider.ProviderObject) JSON.deserialize(providerRecordJSON, CCCAPIReqUpdateProvider.ProviderObject.class); }
            catch (Exception e) { throw new CCCException('Invalid providerRecordJSON parameter passed.'); }


            // Custom Parameters for API call
            customParameters = new Map<String, String>();
            customParameters.put('uuid', providerId);

            // Create API Request
            request = new CCCAPIReqUpdateProvider();
            request.provider = new CCCAPIReqUpdateProvider.ProviderObject();
            request.provider.ads_status = providerRecord.ads_status;

            // API Call - Update Provider
            rUpdateProvider = (CCCAPIRespUpdateProvider.ServerResponse) CCCCalloutMaster.updateProvider(request, customParameters);
            if (rUpdateProvider.hasErrors) throw new CCCUtils.CCCException(rUpdateProvider.message);

            response.providerRecord = rUpdateProvider.provider;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Creates the Review thru the Galore API
    * @param reviewRecordJSON (String) - The JSON representation of the Review record
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse createReview(String reviewRecordJSON) { return createReview(reviewRecordJSON, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse createReview(String reviewRecordJSON, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'createReview';

        CCCAPIReqCreateReview request;
        CCCAPIReqCreateReview.ReviewObject reviewRecord;
        CCCAPIRespCreateReview.ServerResponse rCreateReview;
        CCCActiveAgreementController.ServerResponse rActiveAgreements;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (reviewRecordJSON == null) throw new CCCUtils.CCCException('Empty reviewRecordJSON parameter passed.');

            try { reviewRecord = (CCCAPIReqCreateReview.ReviewObject) JSON.deserialize(reviewRecordJSON, CCCAPIReqCreateReview.ReviewObject.class); }
            catch (Exception e) { throw new CCCException('Invalid reviewRecordJSON parameter passed.'); }

            // Create API Request
            request = new CCCAPIReqCreateReview();
            request.review = reviewRecord;

            // API Call - Create Review
            rCreateReview = (CCCAPIRespCreateReview.ServerResponse) CCCCalloutMaster.createReview(request);
            if (rCreateReview.hasErrors) throw new CCCUtils.CCCException(rCreateReview.message);

            response.reviewRecord = new ReviewObject(rCreateReview.review);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Updates the Review to the Galore API
    * @param reviewRecordJSON (String) - The JSON representation of the Review record
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse updateReview(String reviewId, String reviewRecordJSON) { return updateReview(reviewId, reviewRecordJSON, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse updateReview(String reviewId, String reviewRecordJSON, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateReview';

        CCCAPIReqUpdateReview request;
        CCCAPIReqUpdateReview.ReviewObject reviewRecord;
        CCCAPIRespUpdateReview.ServerResponse rUpdateReview;
        CCCActiveAgreementController.ServerResponse rActiveAgreements;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (reviewId == null) throw new CCCUtils.CCCException('Empty reviewId parameter passed.');
            if (reviewRecordJSON == null) throw new CCCUtils.CCCException('Empty reviewRecordJSON parameter passed.');

            try { reviewRecord = (CCCAPIReqUpdateReview.ReviewObject) JSON.deserialize(reviewRecordJSON, CCCAPIReqUpdateReview.ReviewObject.class); }
            catch (Exception e) { throw new CCCException('Invalid reviewRecordJSON parameter passed.'); }

            // Custom Parameters for API call
            customParameters = new Map<String, String>();
            customParameters.put('uuid', reviewId);

            // Create API Request
            request = new CCCAPIReqUpdateReview();
            request.review = reviewRecord;

            // API Call - Update Review
            rUpdateReview = (CCCAPIRespUpdateReview.ServerResponse) CCCCalloutMaster.updateReview(request, customParameters);
            if (rUpdateReview.hasErrors) throw new CCCUtils.CCCException(rUpdateReview.message);

            response.reviewRecord = new ReviewObject(rUpdateReview.review);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description: Calls the Update Sales Contract API to cancel the agreement
    * @param accountId (String) - The Salesforce Account Id
    * @param salesContractId (String) - The Galore UUID for the Sales Contract
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlags
    * @return (ServerResponse)
    **/

    // public method
    @AuraEnabled
    public static ServerResponse cancelAgreement(String accountId, String salesContractId) { return cancelAgreement(accountId, salesContractId, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse cancelAgreement(String accountId, String salesContractId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'cancelAgreement';

        Account oAccount;
        CCCAPIReqUpdateSalesContract request;
        CCCAPIRespUpdateSalesContract.ServerResponse rUpdateSalesContract;
        CCCActiveAgreementController.ServerResponse rActiveAgreements;
        CCCUtils.ServerResponse rUtils;
        Map<String, String> customParameters;
        ServerResponse response = new ServerResponse();

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (accountId == null) throw new CCCUtils.CCCException('Empty accountId parameter passed.');
            if (salesContractId == null) throw new CCCUtils.CCCException('Empty salesContractId parameter passed.');


            // Custom Parameters for API call
            customParameters = new Map<String, String>();
            customParameters.put('uuid', salesContractId);

            // Create API Request
            request = new CCCAPIReqUpdateSalesContract();
            request.sales_contract = new CCCAPIReqUpdateSalesContract.SalesContract();
            request.sales_contract.contract_status = 'canceled';

            // API Call - Update Sales Contract
            rUpdateSalesContract = (CCCAPIRespUpdateSalesContract.ServerResponse) CCCCalloutMaster.updateSalesContract(request, customParameters);
            if (rUpdateSalesContract.hasErrors) throw new CCCUtils.CCCException(rUpdateSalesContract.message);

            // Return fresh data
            rActiveAgreements = getActiveAgreementData(accountId);
            if (rActiveAgreements.hasErrors) throw new CCCUtils.CCCException(rActiveAgreements.message);

            response.businessRecord = rActiveAgreements.businessRecord;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }
}