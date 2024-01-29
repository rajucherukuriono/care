@RestResource(urlMapping='/BUCCase/*')
global class BUCCaseRestService {
    static private final String CLASS_NAME = 'BUCCaseRestService';

    // Case record type names that are allowed to be created
    static private final Set<String> validCaseTypes = new Set<String>{ 'Enrollment', 'Infraction or License Changes', 'COI expiration' };
    
    // For these case record types, only one can be open at a time on the account. The older case will be closed.
    static private final Set<String> disallowDupeCaseTypes = new Set<String>{ 'Infraction or License Changes', 'COI expiration' };

    public class CustomException extends Exception {}

    public class UnitTestFlags {
        // public Boolean throwNoUsersException { get; set; }
        // public Boolean throwHttp500Status { get; set; }

        public UnitTestFlags() {
            // this.throwNoUsersException = false;
            // this.throwHttp500Status = false;
        }
    }

    global class PostCaseRequest {
        public String case_record_type { get; set; }
        public String account_id { get; set; }
        public String reason { get; set; }
        public String locationCount { get; set; }
        public String status { get; set; }
        public String priority { get; set; }
    }

    global class PostCaseResponse {
        public Id caseId { get; set; }
        public List<String> errors { get; set; }

        public PostCaseResponse() {
            this.errors = new List<String>();
        }
    }

    @HttpPost
    global static PostCaseResponse postCase(PostCaseRequest case_request) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
		system.debug('response*****start');
	system.debug(case_request);
         system.debug('response*****end');
        return postCaseInternal(case_request, req, res, new UnitTestFlags());
    }

    @TestVisible
    private static PostCaseResponse postCaseInternal(PostCaseRequest case_request, RestRequest req, RestResponse res, UnitTestFlags utFlags) {
        final String METHOD_NAME = 'postCaseInternal';

        PostCaseResponse response = new PostCaseResponse();
        system.debug('response*****start');
	    system.debug(case_request);
        system.debug(response);
        system.debug('response*****end');

        // Variables used for logging
        String url;
        Integer httpStatus = 200;
        String requestBody = '';
        String responseBody = '';

        try {
            // Capture request body and url for logging
            requestBody = JSON.serialize(case_request);
            url = req.requestURI;

            // Validate request
            response = validatePostRequest(case_request);

            if (response.errors.size() == 0) {
                // If case_request.case_record_type doesn't exist as a valid record type, this should throw an exception
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(case_request.case_record_type).getRecordTypeId();

                // Get the previous Case records for the current record type. Under normal circumstances, there should only be one. The duplicate case should be closed
                // and the owner from that case should be used as the owner of the new case.
                Id previousOwnerId;
                List<Case> caseRecords = new List<Case>();
                if (disallowDupeCaseTypes.contains(case_request.case_record_type)) {
                    caseRecords = [SELECT Status, OwnerId FROM Case WHERE AccountId = :case_request.account_id AND RecordTypeId = :recordTypeId AND isclosed = false ORDER BY CreatedDate DESC];
                    if (caseRecords != null && caseRecords.size() > 0) {
                        for (Case caseRecord : caseRecords) {
                            caseRecord.Status = 'Closed';
                            caseRecord.Comments = 'Automatically closed as duplicate Case by BUCCaseRestService';
                        }
                        previousOwnerId = caseRecords[0].OwnerId;
                    }
                }

                Case caseRecord = new Case(
                    RecordTypeId = recordTypeId,
                    AccountId = case_request.account_id,
                    Origin = 'Galore BUC'
                );

                if (previousOwnerId != null) {
                    // Turn off Case assignment rule for this Case
                    caseRecord.Skip_Case_Assignment__c = true;
                    // Assign this case to the owner of the case we are closing
                    caseRecord.OwnerId = previousOwnerId;
                }

                caseRecords.add(caseRecord);
    
                for (Database.UpsertResult upsertResult : Database.upsert(caseRecords, false)) {
                    if (upsertResult.isSuccess()) {
                        response.caseId = upsertResult.getId();
                    } else {
                        for (Database.Error error : upsertResult.getErrors()) {
                            response.errors.add('Error updating Case - Status Code: ' + error.getStatusCode() + ' Message: ' + error.getMessage() + ' Fields: ' + String.join(error.getFields(), ','));
                        }
                    }
                }
            }
        } catch (Exception e) {
            system.debug('response*****start catch');
            httpStatus = 500;
            responseBody = e.getMessage() + '; ' + e.getStackTraceString();
            res.statusCode = httpStatus;
            response.errors.add(CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage());
        }

        logRestServiceCall(url, requestBody, responseBody, httpStatus);

        return response;
    }

    @TestVisible
    private static PostCaseResponse validatePostRequest(PostCaseRequest case_request) {
        system.debug('response*****start');
        system.debug(case_request +'case_request');
        PostCaseResponse response = new PostCaseResponse();

        if (String.isBlank(case_request.account_id)) {
            response.errors.add('account_id is required');
        }

        if (String.isBlank(case_request.case_record_type)) {
            response.errors.add('case_record_type is required');
        }

        if (!validCaseTypes.contains(case_request.case_record_type)) {
            response.errors.add('invalid case_record_type:' + case_request.case_record_type);
        }

        return response;
    }

    /**
    * @description Logs the service call to Contract_Composer_REST_Log__c
    * @param url (String) - The url
    * @param requestBody (String) - The request JSON body
    * @param responseBody (String) - The response
    * @param httpStatus (Integer) - The http status returned in the response
    */
    private static void logRestServiceCall(String url, String requestBody, String responseBody, Integer httpStatus) {
        insert new Contract_Composer_REST_Log__c(
            Service_Name__c = 'BUCCase',
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }
}