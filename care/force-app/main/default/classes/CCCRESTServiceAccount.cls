/***************************************************************************************************
   Name        : CCCRESTServiceAccount
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: 08/20/2021
   Description : This is a REST Service that will be called by Galore to update the Account

   Changes     : 08/20/2021 - John Wrightsman (Class Created)

******************************************************************************************************/
@RestResource(urlMapping='/Account/*')
global class CCCRESTServiceAccount {

    global class PostAccountRequest {
        public String status { get; set; }
        public String franchise_id { get; set; }
    }

    @HttpPost
    global static void postAccount(PostAccountRequest account) {
       postAccount(account, new CCCUtils.UnitTestFlags());
    }

    @TestVisible
    private static void postAccount(PostAccountRequest account, CCCUtils.UnitTestFlags flags) {
        if (flags == null) flags = new CCCUtils.UnitTestFlags();

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;

        // Variables used for logging
        String url;
        Integer httpStatus = 200;
        String requestBody = '';
        String responseBody = '';

        try {
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            // Capture request body and url for logging
            requestBody = JSON.serialize(account);
            url = req.requestURI;

            // Grab the Galore Business Id from the request URI
            String galoreBusId = url.substring(url.lastIndexOf('/') + 1);

            // Check if galoreBusId is blank
            if (String.isBlank(galoreBusId)) {
                httpStatus = 404;
                responseBody = 'Blank Galore Business Id';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            // Get Account to validate it exists (Use List in case Account doesn't exist and throws error)
            List<Account> accountRecords = [SELECT Id FROM Account WHERE Galore_Business_Id__c = :galoreBusId];
            if (accountRecords == null || accountRecords.size() == 0) {
                httpStatus = 404;
                responseBody = 'Account not found';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            update new Account(
                Id = accountRecords[0].Id,
                Galore_Status__c = account.status,
                Galore_Franchise_Id__c = account.franchise_id
            );
                
        } catch(Exception e) {
            httpStatus = 500;
            responseBody = e.getMessage() + '; ' + e.getStackTraceString();
            res.statusCode = httpStatus;
            res.responseBody = Blob.valueOf(responseBody);
        }

        logRestServiceCall(url, requestBody, responseBody, httpStatus);
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
            Service_Name__c = 'Account',
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }

}