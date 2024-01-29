@isTest
public with sharing class ReviewModerationControllerTest {

    @isTest
    static void testGetCaseInfo(){
        recordType safetyRecordType = [SELECT Id 
                                       FROM recordType 
                                       WHERE SObjectType = 'Case' 
                                       AND Name = 'Safety Alert'];

        Case testCase = new Case(Status = 'New',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60', recordTypeId = safetyRecordType.Id);
        
        insert testCase;

        test.startTest();
            Case retrievedCase =ReviewModerationController.getCaseInformation(testCase.Id);
        test.stopTest();

        System.assertEquals(retrievedCase.Id, testCase.Id);
        System.assertEquals(retrievedCase.Status, 'New');
    }

    @isTest
    static void testCloseCase(){
        recordType safetyRecordType = [SELECT Id 
                                       FROM recordType 
                                       WHERE SObjectType = 'Case' 
                                       AND Name = 'Safety Alert'];

        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60', recordTypeId = safetyRecordType.Id);
        insert testCase;

        test.startTest();
            ReviewModerationController.closeCase(testCase.Id, 'Review Approved');
        test.stopTest();

        Case testCaseUpdated = [SELECT Id, Status, Contact_Reason__c
                                FROM Case
                                WHERE Id =: testCase.Id];

        System.assertEquals(testCaseUpdated.Contact_Reason__c, 'Review Approved');
        System.assertEquals(testCaseUpdated.Status, 'Closed');
    }

    @isTest
    static void testCloseCaseException(){

        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');
        insert testCase;

        test.startTest();
            ReviewModerationController.reviewDataResponse response = 
                (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.closeCase(testCase.Id, 'Invalid selection'), ReviewModerationController.reviewDataResponse.class);
        test.stopTest();

        Case testCaseUpdated = [SELECT Id, Status, Contact_Reason__c
                                FROM Case
                                WHERE Id =: testCase.Id];

        System.assertEquals(response.isSuccessful, false);
    }

    @isTest
    static void createCaseComment(){
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');
        insert testCase;

        test.startTest();
            ReviewModerationController.createCaseComment(testCase.Id, 'Test Comment');
        test.stopTest();

        CaseComment testComment = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId =: testCase.Id];
        System.assertEquals(testComment.CommentBody, 'Test Comment');
    }

    @isTest
    static void createCaseCommentException(){
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');
        insert testCase;

        test.startTest();
        ReviewModerationController.reviewDataResponse response = 
            (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.createCaseComment(UserInfo.getUserId(), 'Test Comment'), ReviewModerationController.reviewDataResponse.class);
        test.stopTest();

        System.assertEquals(response.isSuccessful, false);
    }

    @isTest
    static void testGetReviewInformation(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');

        insert testCase;

        test.startTest();
            ReviewModerationController.reviewDataResponse response = (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.getReviewInformation(testCase.Id), ReviewModerationController.reviewDataResponse.class);
        test.stopTest();

        System.debug(response);
        System.assertEquals(response.isSuccessful, true);
    }

    @isTest
    static void testGetReviewInformationException(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');

        insert testCase;

        ReviewModerationController.reviewDataResponse response = (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.getReviewInformation(testCase.Id), ReviewModerationController.reviewDataResponse.class);

        System.debug(response);
        System.assertEquals(response.isSuccessful, false);
    }

    @isTest
    static void testReviewEdit(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');

        insert testCase;

        test.startTest();
            ReviewModerationController.reviewDataResponse response = 
                (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.editReviewValues(testCase.Review_UUID__c, true, 'Updated Review Text', true, 1), ReviewModerationController.reviewDataResponse.class);
        test.stopTest();

        System.assertEquals(response.isSuccessful, true);
    }

    @isTest
    static void testReviewEditException(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');

        insert testCase;

        ReviewModerationController.reviewDataResponse response = 
            (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.editReviewValues(testCase.Review_UUID__c, true, 'Updated Review Text', true, 1), ReviewModerationController.reviewDataResponse.class);

        System.debug(response);
        System.assertEquals(response.isSuccessful, false);
    }

    @isTest
    static void testReviewRejection(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');
        
        insert testCase;

        test.startTest();
            ReviewModerationController.reviewDataResponse response = 
                    (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.rejectReview(testCase.Review_UUID__c), ReviewModerationController.reviewDataResponse.class);
        test.stopTest();
    
        System.debug(response);
        System.assertEquals(response.isSuccessful, true);
    }

    @isTest
    static void testReviewRejectionException(){
        Test.setMock(HttpCalloutMock.class, new ReviewGetValidResponse());
        Case testCase = new Case(Status = 'new',Member_Type__c='Seeker',Origin='Web',Review_UUID__c = 'a45a9c96-42d3-40b7-b48d-0b8ec4f62e60');
        
        insert testCase;

        ReviewModerationController.reviewDataResponse response = 
                (ReviewModerationController.reviewDataResponse)JSON.deserialize(ReviewModerationController.rejectReview(testCase.Review_UUID__c), ReviewModerationController.reviewDataResponse.class);
    
        System.debug(response);
        System.assertEquals(response.isSuccessful, false);
    }

    public class ReviewGetValidResponse implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReviewPatchValidResponse implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(204);
            return res;
        }
    }


}