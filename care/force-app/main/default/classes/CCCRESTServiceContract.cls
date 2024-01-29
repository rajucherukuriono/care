/***************************************************************************************************
   Name        : CCCRESTServiceContract
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: February 2nd, 2021
   Description : This is a REST Service that will be called by Galore to update the Opportunity (Contract)

   Changes     : 02/02/2021 - John Wrightsman (Class Created)
******************************************************************************************************/
@RestResource(urlMapping='/Contract/*')
global class CCCRESTServiceContract {

    global class PatchContactRequest {
        public String contract_status { get; set; }
    }

    @HttpPatch
    global static void patchContract(PatchContactRequest sales_contract) {
       patchContract(sales_contract, new CCCUtils.UnitTestFlags());
    }

    @TestVisible
    private static void patchContract(PatchContactRequest sales_contract, CCCUtils.UnitTestFlags flags) {
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
            requestBody = JSON.serialize(sales_contract);
            url = req.requestURI;

            // Get contract status-to-stage name map
            Map<String, SObject> stageNameMap = CCCQuery.get('CCC_Opportunity_StageName_Map__mdt').equals('Active__c', true).toMap('Contract_Status__c');

            // Check if contract_status is mapped to an opportunity stage name
            if (!stageNameMap.containsKey(sales_contract.contract_status)) {
                httpStatus = 403;
                responseBody = 'No Opportunity stage name mapping exists for this contract_status';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            // Grab the Salesforce Id from the request URI
            String opportunityId = url.substring(url.lastIndexOf('/') + 1);
            // Validate that the Id is the valid type for an Opportunity
            if (CCCUtils.getSObjectType(opportunityId) != 'Opportunity') {
                httpStatus = 404;
                responseBody = 'Invalid Opportunity Id';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            // Get Opportunity to validate it exists (Use List in case Opportunity doesn't exist and throws error)
            List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE Id = :opportunityId];
            if (opportunities == null || opportunities.size() == 0) {
                httpStatus = 404;
                responseBody = 'Opportunity not found';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }
            Opportunity opp = opportunities[0];

            // Prevent updating the Opportunity if it is in Closed Won stage
            if (opp.StageName == 'Closed Won') {
                httpStatus = 409;
                responseBody = 'The Opportunity stage is Closed Won and cannot be updated';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            // Update Opportunity.StageName
            opp.StageName = (String) stageNameMap.get(sales_contract.contract_status).get('Opportunity_StageName__c');
           /* if (opp.StageName == 'Closed Won') {
                opp.CloseDate = Date.today();
            } */
            update opp;
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
            Service_Name__c = 'ServiceContract',
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }

}