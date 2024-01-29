/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 01/07/2021
Description: Apex controller for CCCReviewModule lightning component.
Changes:

*****************************************************************************/
public without sharing class CCCReviewController {
    static private String CLASS_NAME = 'CCCReviewController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public List<Opportunity_Service_Area__c> locationRecords { get; set; }
        @AuraEnabled public List<Review_Reference__c> reviewRecords { get; set; }
        @AuraEnabled public Opportunity opportunityRecord { get; set; }

        public ServerResponse() {
            super();
            this.locationRecords = new List<Opportunity_Service_Area__c>();
            this.reviewRecords = new List<Review_Reference__c>();
        }
    }

    /**
    * @description Retrieves the Reference Review record for the Opportunity's related Account
    * @param opportunityId (String) - The Opportunity record Id
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getReviewData(String opportunityId) { return getReviewData(opportunityId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getReviewData(String opportunityId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getReviewData';

        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (opportunityId == null) throw new CCCException('Empty opportunityId parameter passed.');

            // Get Opportunity record
            response.opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').field('Account.Galore_Business_Id__c').equalsId(opportunityId).one();

            // Get Location records
            response.locationRecords = (List<Opportunity_Service_Area__c>) CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', opportunityId).all();

            // Get Review records
            response.reviewRecords = (List<Review_Reference__c>) CCCQuery.get('Review_Reference__c').field('Location__r.Name').equals('Account__c', response.opportunityRecord.AccountId).all();

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Saves an Review record
    * @param reviewRecord (Review_Reference__c) - The Review_Reference__c record to save
    * @param businessId (String) - The Business Id for the Account
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse saveReviewRecord(Review_Reference__c reviewRecord, String businessId) { return saveReviewRecord(reviewRecord, businessId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse saveReviewRecord(Review_Reference__c reviewRecord, String businessId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveReviewRecord';
        ServerResponse response = new ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');
            if (reviewRecord == null) throw new CCCException('Empty reviewRecord parameter passed.');

            if (String.isNotBlank(businessId)) {
                // First update/create review in Galore
                // If this fails then we won't update the review in Salesforce
                reviewRecord = upsertGaloreReview(reviewRecord, businessId);
            }

            upsert reviewRecord;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    private static Review_Reference__c upsertGaloreReview(Review_Reference__c reviewRecord, String businessId) {
        if (String.isNotBlank(reviewRecord.Galore_Review_uuid__c)) {

            CCCAPIReqUpdateReview request = new CCCAPIReqUpdateReview();
            request.review = new CCCAPIReqUpdateReview.ReviewObject();
            request.review.first_name = reviewRecord.First_Name__c;
            request.review.last_name = reviewRecord.Last_Name__c;
            request.review.email = reviewRecord.Email__c;
            request.review.phone = reviewRecord.Phone__c;
            request.review.location_name = reviewRecord.Location__r.Name;

            // Callout to Galore to update review
            Map<String, String> customParameters = new Map<String, String>();
            customParameters.put('uuid', reviewRecord.Galore_Review_uuid__c);
            CCCAPIRespUpdateReview.ServerResponse rCalloutMaster = (CCCAPIRespUpdateReview.ServerResponse) CCCCalloutMaster.updateReview(request, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCException(rCalloutMaster.message);

        } else {

            CCCAPIReqCreateReview request = new CCCAPIReqCreateReview();
            request.review = new CCCAPIReqCreateReview.ReviewObject();
            request.review.business_id = businessId;
            request.review.first_name = reviewRecord.First_Name__c;
            request.review.last_name = reviewRecord.Last_Name__c;
            request.review.email = reviewRecord.Email__c;
            request.review.phone = reviewRecord.Phone__c;
            request.review.location_name = reviewRecord.Location__r.Name;

            // Callout to Galore to create review
            CCCAPIRespCreateReview.ServerResponse rCalloutMaster = (CCCAPIRespCreateReview.ServerResponse) CCCCalloutMaster.createReview(request);
            if (rCalloutMaster.hasErrors) throw new CCCException(rCalloutMaster.message);

            // Update uuid on review record
            reviewRecord.Galore_Review_uuid__c = rCalloutMaster.review.uuid;
        }

        return reviewRecord;
    }
}