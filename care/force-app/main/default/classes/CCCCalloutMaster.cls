/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 10/05/2019
Description: Class responsible for all callouts to support Contract Composer

Changes:

*********************************************************************************************/
public without sharing class CCCCalloutMaster {
    final static private String CLASS_NAME = 'CCCCalloutMaster';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public HttpResponse httpResponse { get; set; }

        public ServerResponse() {
            super();
        }
    }


    /**
    * @description Makes the API callout with the supplied arguments
    * @param endpointName (String) - The name of the endpoint to lookup on the API Custom Metadata Settings
    * @param request (HttpRequestElement) - The populated request object to call
    * @param customParameters (Map<String,String>) - A key:value Map of parameters to use for specific endpoint settings
    * @param flags (UnitTestFlags) - For Unit Tests only, set this to an instance of CCHSUtils.UnitTestFlags
    * @return (ServerResponse)
    */

    // public method
    @TestVisible
    private static ServerResponse makeAPICalloutToGalore(String endpointName, HTTPRequestElement request) { return makeAPICalloutToGalore(endpointName, request, new Map<String, String>(), new CCCUtils.UnitTestFlags()); }

    // public method
    @TestVisible
    public static ServerResponse makeAPICalloutToGalore(String endpointName, HTTPRequestElement request, Map<String, String> customParameters) { return makeAPICalloutToGalore(endpointName, request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse makeAPICalloutToGalore(String endpointName, HTTPRequestElement request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'makeAPICalloutToGalore';

        CCCUtils.ServerResponse rUtils;
        CCC_API_Endpoint_Setting__mdt apiSetting;
        CCC_Global_Setting__mdt globalSettings;
        Integer httpRequestTimeout;
        ServerResponse response = new ServerResponse();
        String endpointURL;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (endpointName == null) throw new CCCUtils.CCCException('Empty endpointName parameter passed.');
            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');

            // Get Contract Composer Global Custom Metadata Settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            // Grab our API Endpoint settings from CustomMetadataSettings
            apiSetting = (CCC_API_Endpoint_Setting__mdt) CCCQuery.get('CCC_API_Endpoint_Setting__mdt').equals('DeveloperName', endpointName).one();

            // Valid Endpoint URL check
            if (apiSetting == null) throw new CCCUtils.CCCException('Unable to find Custom Metadata API Endpoint settings for ' + endpointName);

            // Endpoint URL - Default
            endpointURL = apiSetting.URL__c;

            // HTTP Request Timeout - Default to 30 second timeout if not specified
            httpRequestTimeout = (apiSetting.HTTP_Request_Timeout__c != null) ? apiSetting.HTTP_Request_Timeout__c.intValue(): 30000;

            // Add any custom url parameters via string replacement
            if (customParameters != null) {
                for (String key : customParameters.keySet()) {
                    endpointURL = endpointURL.replace(':' + key, customParameters.get(key));
                }
            }

            request.setHeader('api-key', globalSettings.Galore_API_Key__c);
            request.setHeader('Content-Type', 'application/json');
            request.setEndPoint(endpointURL);
            request.setTimeout(httpRequestTimeout);

            // Call the endpoint and store the response
            response.httpResponse = WebServiceManager.processRequest(request);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Create Sales Contract Galore API Endpoint
    * @param request (CCCAPIReqCreateSalesContract) - The populated CCCAPIReqCreateSalesContract request to send
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespCreateSalesContract.ServerResponse createSalesContract(CCCAPIReqCreateSalesContract request) { return createSalesContract(request, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespCreateSalesContract.ServerResponse createSalesContract(CCCAPIReqCreateSalesContract request, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'createSalesContract';
        final String API_ENDPOINT = 'Create_Sales_Contract';

        CCCAPIRespCreateSalesContract httpResponse;
        CCCAPIRespCreateSalesContract.ServerResponse response = new CCCAPIRespCreateSalesContract.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');

            httpRequest = new CCCAPIReqCreateSalesContract();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('POST');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespCreateSalesContract(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespCreateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespCreateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespCreateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Sales Contract not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespCreateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespCreateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }

    /**
    * @description Calls Fetch a Business Galore API Endpoint
    * @param request (CCCAPIReqFetchABusiness) - The populated CCCAPIReqFetchABusiness request to send
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespFetchABusiness.ServerResponse fetchABusiness(CCCAPIReqFetchABusiness request, Map<String, String> customParameters) { return fetchABusiness(request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespFetchABusiness.ServerResponse fetchABusiness(CCCAPIReqFetchABusiness request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'fetchABusiness';
        final String API_ENDPOINT = 'Fetch_A_Business';

        CCCAPIRespFetchABusiness httpResponse;
        CCCAPIRespFetchABusiness.ServerResponse response = new CCCAPIRespFetchABusiness.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');

            httpRequest = new CCCAPIReqFetchABusiness();
            //httpRequest.setBody(JSON.serialize(request, true)); // Setting a body will change this to a POST after http.send(), don't setBody
            httpRequest.setMethod('GET');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespFetchABusiness(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespFetchABusiness.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespFetchABusiness.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespFetchABusiness.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The specified Business was not found.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespFetchABusiness.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespFetchABusiness.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Update Sales Contract Galore API Endpoint
    * @param request (CCCAPIReqUpdateSalesContract) - The populated CCCAPIReqUpdateSalesContract request to send
    * @param customParameters (Map<String, String>) - Additional values that will be needed for the request, possibly in the URL, body, headers, etc.
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespUpdateSalesContract.ServerResponse updateSalesContract(CCCAPIReqUpdateSalesContract request, Map<String, String> customParameters) { return updateSalesContract(request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespUpdateSalesContract.ServerResponse updateSalesContract(CCCAPIReqUpdateSalesContract request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateSalesContract';
        final String API_ENDPOINT = 'Update_Sales_Contract';

        CCCAPIRespUpdateSalesContract httpResponse;
        CCCAPIRespUpdateSalesContract.ServerResponse response = new CCCAPIRespUpdateSalesContract.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');
            if (customParameters == null || customParameters.size() == 0) throw new CCCUtils.CCCException('Expected a non empty/non null customParemters input parameter.');

            httpRequest = new CCCAPIReqUpdateSalesContract();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('PATCH');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespUpdateSalesContract(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespUpdateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespUpdateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespUpdateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Sales Contract not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespUpdateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespUpdateSalesContract.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Create Review Galore API Endpoint
    * @param request (CCCAPIReqCreateReview) - The populated CCCAPIReqCreateReview request to send
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespCreateReview.ServerResponse createReview(CCCAPIReqCreateReview request) { return createReview(request, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespCreateReview.ServerResponse createReview(CCCAPIReqCreateReview request, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'createReview';
        final String API_ENDPOINT = 'Create_Review';

        CCCAPIRespCreateReview httpResponse;
        CCCAPIRespCreateReview.ServerResponse response = new CCCAPIRespCreateReview.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');

            httpRequest = new CCCAPIReqCreateReview();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('POST');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespCreateReview(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespCreateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespCreateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespCreateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Review not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespCreateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespCreateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Update Offering Galore API Endpoint
    * @param request (CCCAPIReqUpdateOffering) - The populated CCCAPIReqUpdateOffering request to send
    * @param customParameters (Map<String, String>) - Additional values that will be needed for the request, possibly in the URL, body, headers, etc.
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespUpdateOffering.ServerResponse updateOffering(CCCAPIReqUpdateOffering request, Map<String, String> customParameters) { return updateOffering(request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespUpdateOffering.ServerResponse updateOffering(CCCAPIReqUpdateOffering request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateOffering';
        final String API_ENDPOINT = 'Update_Offering';

        CCCAPIRespUpdateOffering httpResponse;
        CCCAPIRespUpdateOffering.ServerResponse response = new CCCAPIRespUpdateOffering.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');
            if (customParameters == null || customParameters.size() == 0) throw new CCCUtils.CCCException('Expected a non empty/non null customParemters input parameter.');

            httpRequest = new CCCAPIReqUpdateReview();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('PATCH');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespUpdateOffering(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespUpdateOffering.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespUpdateOffering.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespUpdateOffering.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Offering not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespUpdateOffering.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespUpdateOffering.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Update Provider Galore API Endpoint
    * @param request (CCCAPIReqUpdateProvider) - The populated CCCAPIReqUpdateProvider request to send
    * @param customParameters (Map<String, String>) - Additional values that will be needed for the request, possibly in the URL, body, headers, etc.
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespUpdateProvider.ServerResponse updateProvider(CCCAPIReqUpdateProvider request, Map<String, String> customParameters) { return updateProvider(request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespUpdateProvider.ServerResponse updateProvider(CCCAPIReqUpdateProvider request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateProvider';
        final String API_ENDPOINT = 'Update_Provider';

        CCCAPIRespUpdateProvider httpResponse;
        CCCAPIRespUpdateProvider.ServerResponse response = new CCCAPIRespUpdateProvider.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');
            if (customParameters == null || customParameters.size() == 0) throw new CCCUtils.CCCException('Expected a non empty/non null customParemters input parameter.');

            httpRequest = new CCCAPIReqUpdateReview();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('PATCH');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespUpdateProvider(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespUpdateProvider.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespUpdateProvider.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespUpdateProvider.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Review not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespUpdateProvider.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespUpdateProvider.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls Update Review Galore API Endpoint
    * @param request (CCCAPIReqUpdateReview) - The populated CCCAPIReqUpdateReview request to send
    * @param customParameters (Map<String, String>) - Additional values that will be needed for the request, possibly in the URL, body, headers, etc.
    * @param UnitTestFlags (UnitTestFlags) - For Unit Tests only, set this to an instance of UnitTestFlag so that testing conditions can be passed to the method.
    * @return (ServerResponse)
    */

    // public method
    @AuraEnabled
    public static CCCAPIRespUpdateReview.ServerResponse updateReview(CCCAPIReqUpdateReview request, Map<String, String> customParameters) { return updateReview(request, customParameters, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static CCCAPIRespUpdateReview.ServerResponse updateReview(CCCAPIReqUpdateReview request, Map<String, String> customParameters, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'updateReview';
        final String API_ENDPOINT = 'Update_Review';

        CCCAPIRespUpdateReview httpResponse;
        CCCAPIRespUpdateReview.ServerResponse response = new CCCAPIRespUpdateReview.ServerResponse();
        CCCCalloutMaster.ServerResponse rCalloutMaster;
        HTTPRequestElement httpRequest;

        try {

            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (request == null) throw new CCCUtils.CCCException('Empty request parameter passed.');
            if (customParameters == null || customParameters.size() == 0) throw new CCCUtils.CCCException('Expected a non empty/non null customParemters input parameter.');

            httpRequest = new CCCAPIReqUpdateReview();
            httpRequest.setBody(JSON.serialize(request, true));
            httpRequest.setMethod('PATCH');

            // Make API calls
            rCalloutMaster = CCCCalloutMaster.makeAPICalloutToGalore(API_ENDPOINT, httpRequest, customParameters);
            if (rCalloutMaster.hasErrors) throw new CCCUtils.CCCException(rCalloutMaster.message);

            httpResponse = new CCCAPIRespUpdateReview(rCalloutMaster.httpResponse);

            if (httpResponse.getStatusCode() == 200) {
                response = httpResponse.getServerResponse();
            } else if (httpResponse.getStatusCode() == 401) {
                return (CCCAPIRespUpdateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is missing.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 403) {
                return (CCCAPIRespUpdateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The API Key for the external system is invalid.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 404) {
                return (CCCAPIRespUpdateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Review not found on external system.', (CCCServerResponse) response);
            } else if (httpResponse.getStatusCode() == 422) {
                return (CCCAPIRespUpdateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'The payload for the external API is not formatted correctly.', (CCCServerResponse) response);
            } else {
                throw new CCCUtils.CCCException('Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode());
            }

        } catch (Exception e) { return (CCCAPIRespUpdateReview.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Calls the MapBox Geocoding API
    * @param search (String) - The search string for geocoding
    * @param flags (CCCUtils.UnitTestFlags) - For Unit Tests only, set this to an instance of CCCUtils.UnitTestFlags
    * @return (CCCAPIRespMapBoxGeocoding.ServerResponse)
    */

    // Public method
    @TestVisible
    public static CCCAPIRespMapBoxGeocoding.ServerResponse getMapBoxGeocodingResults(String search) { return getMapBoxGeocodingResults(search, new CCCUtils.UnitTestFlags()); }

    // Internal method
    @TestVisible
    private static CCCAPIRespMapBoxGeocoding.ServerResponse getMapBoxGeocodingResults(String search, CCCUtils.UnitTestFlags flags) {
        String METHOD_NAME = 'getMapBoxGeocodingResults';

        if (flags == null) flags = new CCCUtils.UnitTestFlags();

        CCCAPIRespMapBoxGeocoding.ServerResponse response = new CCCAPIRespMapBoxGeocoding.ServerResponse();
        CCCAPIRespMapBoxGeocoding httpResponse;
        CCCUtils.ServerResponse rUtils;

        try {

            if (Test.isRunningTest() && flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            // Get MapBox settings
            CCC_MapBox_Setting__mdt mapBoxSettings = (CCC_MapBox_Setting__mdt) CCCQuery.get('CCC_MapBox_Setting__mdt').one();
            String url = mapBoxSettings.Geocoding_Endpoint__c + System.EncodingUtil.urlEncode(search, 'UTF-8') + '.json?access_token=' + mapBoxSettings.MapBox_API_Key__c;

            //https://api.mapbox.com/geocoding/v5/mapbox.places/Los%20Angeles.json?access_token=pk.eyJ1Ijoiam9obi13cmlnaHRzbWFuLXJldmVsYW50IiwiYSI6ImNrNXJwNDdzZDBmajgzbG5uMm5qaDE0ZGIifQ.xD5GKFg4m78r-bIBI-VcvQ

            // Create the Request object
            CCCAPIReqMapBoxGeocoding request = new CCCAPIReqMapBoxGeocoding(url, 5000);
            // Send request using Web Service Framework
            httpResponse = new CCCAPIRespMapBoxGeocoding(WebServiceManager.processRequest(request));
            // Get the data from the response
            if ((httpResponse.getStatus() == 'Success' || httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) && !flags.returnBadStatus) {
                response = httpResponse.getServerResponse();
            } else {
                return (CCCAPIRespMapBoxGeocoding.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, 'Failed: Status: ' + httpResponse.getStatus() + ' StatusCode: ' + httpResponse.getStatusCode(), (CCCServerResponse) httpResponse.getServerResponse());
            }

            return response;

        } catch (Exception e) { return (CCCAPIRespMapBoxGeocoding.ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

    }
}