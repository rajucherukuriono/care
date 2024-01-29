public with sharing class ReviewModerationController {
    
    @AuraEnabled
    public static Case getCaseInformation(String recordId){
        Case currentCase = [SELECT Id, Status, Member_ID__c, MemberUUID__c, Review_UUID__c, 
                            Member_Type__c, Contact_Reason__c
                            FROM Case
                            WHERE Id =: recordId];

        return currentCase;
    }

    @AuraEnabled
    public static String closeCase(string recordId, String contactReason){
        
        Case currentCase = [SELECT Id, Status
                            FROM Case
                            WHERE Id =: recordId];

        currentCase.Status = 'Closed';
        currentCase.Contact_Theme__c = 'Safety';
        currentCase.Contact_Reason__c = contactReason;
        currentCase.Contact_Secondary_Reason__c = 'Reviews';

        reviewDataResponse results = new reviewDataResponse();
        
        try{
            update currentCase;
            results.isSuccessful = true;
        } catch(exception e){
            results.isSuccessful = false;
            results.message = e.getMessage();
        }

        return JSON.serialize(results);
    }

    @AuraEnabled
    public static String createCaseComment(string recordId, String caseComment){
        CaseComment cc = new CaseComment(ParentId = recordId,CommentBody = caseComment);

        reviewDataResponse results = new reviewDataResponse();
        try{
            insert cc;
            results.isSuccessful = true;
        } catch (exception e){
            results.isSuccessful = false;
            results.message = e.getMessage();
        }

        return JSON.serialize(results);
    }

    @AuraEnabled
    public static String getReviewInformation(String reviewUUId){
        reviewDataResponse reviewData = new reviewDataResponse();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(getURL() + reviewUUId);
        req.setMethod('GET');
        Http http = new Http();

        try{
            HTTPResponse response = http.send(req);
            ReviewData data = (ReviewData) JSON.deserialize(response.getBody(), ReviewData.class);
            System.debug('Review Data');
            System.debug(data);
            System.debug(response.getStatus());
            System.debug(response.getStatusCode());
            reviewData.reviewData = data;
            reviewData.isSuccessful = true;
        } catch(exception e){
            reviewData.isSuccessful = false;
            reviewData.message = e.getMessage();
        }

        return JSON.serialize(reviewData);
    }

    /*
    * Reviews: Always send username and Id
    *          If approval only do nothing (this isn't called, case is just closed)
    *          If edit then send edited text and/or rating (update both text fields)
    *          If rejection send only rejection (no rating or text changes)
    */
    @AuraEnabled
    public static string editReviewValues(String reviewUUId, 
                                          Boolean textFieldEdited,
                                          String textEdited, 
                                          Boolean isRatingUpdated,
                                          Decimal updatedRatingValue){

        reviewDataResponse results = new reviewDataResponse();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(getURL() + reviewUUId);
        req.setMethod('PATCH');
        Http http = new Http();

        List<reviewChanges> requestBody = new List<reviewChanges>();
        requestBody.addAll(getUserFields());

        if(textFieldEdited){
            requestBody.add(new reviewChanges('/description/display_text', textEdited));
            requestBody.add(new reviewChanges('/description/original_text', textEdited));
        }
        
        if(isRatingUpdated){
            String ratingText2 = '[{"rating_type":1, "value":' + String.valueOf(updatedRatingValue) + '}]';
            requestBody.add(new reviewChanges('/ratings', ratingText2));
        }

        req.setBody(JSON.serialize(requestBody));
        try{
            HTTPResponse res = http.send(req);
            results.isSuccessful = true;
        } catch (exception e){
            results.isSuccessful = false;
            results.message = e.getMessage();
        }
        

        return JSON.serialize(results);
                                    
    }

    @AuraEnabled
    public static String rejectReview(String reviewUUId){
        reviewDataResponse results = new reviewDataResponse();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(getURL() + reviewUUId);
        req.setMethod('PATCH');
        Http http = new Http();

        List<reviewChanges> requestBody = new List<reviewChanges>();
        requestBody.addAll(getUserFields());
        requestBody.add(new reviewChanges('/review_status', 'REVIEW_STATUS_REJECTED_OTHER'));

        req.setBody(JSON.serialize(requestBody));
        
        try{
            HTTPResponse res = http.send(req);
            results.isSuccessful = true;
        } catch(exception e){
            results.isSuccessful = false;
            results.message = e.getMessage();
        }

        return JSON.serialize(results);
    }

    private static List<reviewChanges> getUserFields(){
        List<reviewChanges> userInformation = new List<reviewChanges>();

        userInformation.add(new reviewChanges('/edited_state/employee/salesforce_id', UserInfo.getUserId()));
        userInformation.add(new reviewChanges('/edited_state/employee/salesforce_username', UserInfo.getUserName()));

        return userInformation;
    }

    private static String getURL(){
        Endpoint__mdt endpoint = Endpoint__mdt.getInstance('Review_Moderation');

        return ([Select IsSandbox FROM Organization].IsSandbox) ? endpoint.Sandbox_URL__c : endpoint.Production_URL__c;
    }

    public class reviewDataResponse{
        public ReviewData reviewData;
        public boolean isSuccessful;
        public string message;
    }

    public class ReviewData{
        public Description description;
        public List<Ratings> ratings;
    }

    public class Description{
        public String original_text;
        public String display_text;
    }

    public class Ratings{
        public String rating_type;
        public Decimal value;
    }

    public class reviewChanges{
        String op;
        String path;
        String value;

        public reviewChanges(String path, String value){
            this.op = 'replace';
            this.path = path;
            this.value = value;
        }
    }
}