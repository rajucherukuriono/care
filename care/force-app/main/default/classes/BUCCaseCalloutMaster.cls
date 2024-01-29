public without sharing class BUCCaseCalloutMaster {
    final static private String CLASS_NAME = 'CCCCalloutMaster';

    public class CustomException extends Exception {}

    public class UnitTestFlags {
        public Boolean throwHttp500Status { get; set; }
        public Boolean throwHttp401Status { get; set; }
        public Boolean throwHttp403Status { get; set; }
        public Boolean throwHttp404Status { get; set; }
        public Boolean throwHttp422Status { get; set; }

        public UnitTestFlags() {
            this.throwHttp500Status = false;
            this.throwHttp401Status = false;
            this.throwHttp403Status = false;
            this.throwHttp404Status = false;
            this.throwHttp422Status = false;
        }
    }

    static private Map<String, String> picklistToGaloreValueMap = new Map<String, String>();

    /**
    * @description Uses the api settings and the request object to build the http request then makes the callout to Galore and returns the http response
    * @param endpointName (String) - The name of the endpoint. This is the Name stored in the BUC_Galore_API_Setting__mdt record
    * @param request (HTTPRequestElement) - The http request
    * @param customParameters (Map<String, String>) - A map of key/value parameters to pass in the url of the request
    * @return (HttpResponse)
    */
    @TestVisible
    private static HttpResponse makeAPICalloutToGalore(String endpointName, HTTPRequestElement request, Map<String, String> customParameters) {
        // Grab our API Endpoint settings from CustomMetadataSettings
        BUC_Galore_API_Setting__mdt apiSetting = (BUC_Galore_API_Setting__mdt) CCCQuery.get('BUC_Galore_API_Setting__mdt').equals('DeveloperName', endpointName).one();

        // Valid Endpoint URL check
        if (apiSetting == null) throw new CustomException('Unable to find Custom Metadata API Endpoint settings for ' + endpointName);

        // Endpoint URL - Default
        String endpointURL = apiSetting.URL__c;

        // HTTP Request Timeout - Default to 30 second timeout if not specified
        Integer httpRequestTimeout = (apiSetting.HTTP_Request_Timeout__c != null) ? apiSetting.HTTP_Request_Timeout__c.intValue(): 30000;

        // Add any custom url parameters via string replacement
        if (customParameters != null) {
            for (String key : customParameters.keySet()) {
                endpointURL = endpointURL.replace(':' + key, customParameters.get(key));
            }
        }

        request.setHeader('api-key', apiSetting.Galore_API_Key__c);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setEndPoint(endpointURL);
        request.setTimeout(httpRequestTimeout);

        // Call the endpoint and return the response
        return WebServiceManager.processRequest(request);
    }

    /**
    * @description Calls Galore to update BUC values for a single Account
    * @param accountId (Id) - The Id of the Account
    */
    public static void UpdateAccountOnGaloreByAccountId(Id accountId) {
        BUCAccountGaloreUpdateRequest request = new BUCAccountGaloreUpdateRequest();
        request.accounts = new List<BUCAccountGaloreUpdateRequest.AccountUpdateObject>();

        for (Account accountRecord : getAccountsForGalore(new Set<Id>{ accountId })) {
            request.accounts.add(createAccountUpdateObject(accountRecord, null));
        }

        if (request.accounts.size() > 0) {
            UpdateAccounts(request);
        }
    }

    /**
    * @description Calls Galore to update BUC values on the Accounts related to the Cases
    *              This is called from a Case trigger handler when the Case closes.
    * @param caseIds (List<Id>) - The Ids of the Cases
    */
    @Future(callout=true)
    public static void UpdateAccountsOnGaloreByCaseId(List<Id> caseIds) {
        BUCAccountGaloreUpdateRequest request = new BUCAccountGaloreUpdateRequest();
        request.accounts = new List<BUCAccountGaloreUpdateRequest.AccountUpdateObject>();

        Map<Id, String> accountToCaseTypeMap = new Map<Id, String>();

        for (Case caseRecord : [SELECT RecordType.Name, AccountId FROM CASE WHERE Id IN :caseIds]) {
            accountToCaseTypeMap.put(caseRecord.AccountId, caseRecord.RecordType.Name);
        }

        for (Account accountRecord : getAccountsForGalore(accountToCaseTypeMap.keySet())) {
            String caseRecordTypeName = accountToCaseTypeMap.get(accountRecord.Id);
            request.accounts.add(createAccountUpdateObject(accountRecord, caseRecordTypeName));
        }

        if (request.accounts.size() > 0) {
            UpdateAccounts(request);
        }
    }

    /**
    * @description Retrieves the necessary fields from Account to use for sending updates to Galore
    * @param accountIds (Set<Id>) - A set of Account Ids
    * @return (List<Account>)
    */
    @TestVisible
    private static List<Account> getAccountsForGalore(Set<Id> accountIds) {
        return [
            SELECT
                BUC_Status__c,
                Insurance_uuid__c,
                Insurance_Status__c,
                Insurance_Expires__c
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    /**
    * @description Retrieves the necessary fields from Account to use for sending updates to Galore
    * @param accountRecord (Account) - An Account record
    * @param caseRecordTypeName (String) - The RecordType.Name of the case. NOTE: This can be null if we're
    *                                      just pushing an update on the Account.
    * @return (BUCAccountGaloreUpdateRequest.AccountUpdateObject)
    */
    @TestVisible
    private static BUCAccountGaloreUpdateRequest.AccountUpdateObject createAccountUpdateObject(Account accountRecord, String caseRecordTypeName) {
        BUCAccountGaloreUpdateRequest.AccountUpdateObject accountObject = new BUCAccountGaloreUpdateRequest.AccountUpdateObject();
        accountObject.salesforce_account_id = accountRecord.Id;
        accountObject.buc_status = getPicklistValue('BUC_Status__c', accountRecord.BUC_Status__c);

        if (caseRecordTypeName == null || caseRecordTypeName == 'Enrollment' || caseRecordTypeName == 'COI expiration') {
            accountObject.insurance = new BUCAccountGaloreUpdateRequest.InsuranceObject();
            accountObject.insurance.uuid = accountRecord.Insurance_uuid__c;
            accountObject.insurance.status = getPicklistValue('Insurance_Status__c', accountRecord.Insurance_Status__c);
            if (accountRecord.Insurance_Expires__c != null) {
                accountObject.insurance.expires = accountRecord.Insurance_Expires__c.getTime()/1000; // convert datetime to unix timestamp
            }
        }

        if (caseRecordTypeName == 'Infraction or License Changes') {
            // tbd
        }

        return accountObject;
    }

    @TestVisible
    private static String getPicklistValue(String fieldApiName, String picklistValue) {
        // Populate the static field value map if it's empty or null
        if (picklistToGaloreValueMap == null || picklistToGaloreValueMap.size() == 0) {
            picklistToGaloreValueMap = new Map<String, String>();
            for (BUC_Galore_Picklist_Mapping__mdt mapping : [SELECT Field_Api_Name__c, Galore_Value__c, Picklist_Value__c FROM BUC_Galore_Picklist_Mapping__mdt]) {
                picklistToGaloreValueMap.put(mapping.Field_Api_Name__c + ':' + mapping.Picklist_Value__c, mapping.Galore_Value__c);
            }
        }

        String result = null;
        if (picklistValue != null) {
            if (picklistToGaloreValueMap.containsKey(fieldApiName + ':' + picklistValue)) {
                result = picklistToGaloreValueMap.get(fieldApiName + ':' + picklistValue);
            } else {
                throw new CustomException('No Galore mapping exists for Salesforce picklist field ' + fieldApiName + ' and Picklist value \'' + picklistValue + '\'');
            }
        }

        return result;
    }

    /**
    * @description Calls the Update Account Galore API Endpoint
    * @param request (BUCAccountGaloreUpdateRequest) - The populated BUCAccountGaloreUpdateRequest request to send
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */
    private static BUCAccountGaloreUpdateResponse.BUCAccountResponse updateAccounts(BUCAccountGaloreUpdateRequest request) {
        return UpdateAccounts(request, new UnitTestFlags());
    }

    @TestVisible
    private static BUCAccountGaloreUpdateResponse.BUCAccountResponse updateAccounts(BUCAccountGaloreUpdateRequest request, UnitTestFlags utFlags) {
        final String METHOD_NAME = 'UpdateAccounts';
        final String API_ENDPOINT = 'Update_Accounts';

        BUCAccountGaloreUpdateResponse.BUCAccountResponse response = new BUCAccountGaloreUpdateResponse.BUCAccountResponse();

        try {
            HTTPRequestElement httpRequest = new BUCAccountGaloreUpdateRequest();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('POST');

            // Make API calls
            HttpResponse httpResp = makeAPICalloutToGalore(API_ENDPOINT, httpRequest, null);

            if (httpResp.getStatusCode() == 200) {
                response = (new BUCAccountGaloreUpdateResponse(httpResp)).getServerResponse();
            } else if (httpResp.getStatusCode() == 401 || utFlags.throwHttp401Status) {
                throw new CustomException('The API Key for the external system is missing.');
            } else if (httpResp.getStatusCode() == 403 || utFlags.throwHttp403Status) {
                throw new CustomException('The API Key for the external system is invalid.');
            } else if (httpResp.getStatusCode() == 422 || utFlags.throwHttp422Status) {
                throw new CustomException('The payload for the external API is not formatted correctly.');
            } else {
                throw new CustomException('Failed: Status: ' + httpResp.getStatus() + ' StatusCode: ' + httpResp.getStatusCode());
            }

        } catch (Exception e) {
            return (BUCAccountGaloreUpdateResponse.BUCAccountResponse) ServerResponse.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (ServerResponse) response);
        }

        return response;
    }

}