/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/30/2020
Description: This class is used to test web services. Its responsible for returning the correct
             instance of the HttpCalloutMock class mapped to an endpoint. The endpoint must be
             the exact same that the code will call or the "Endpoint not found" error will occur.
Changes:
*********************************************************************************************/
public without sharing class CCCMultiMockHttpRespGenerator implements System.HttpCalloutMock {
    Map<String, HttpCalloutMock> mRequests;

    public CCCMultiMockHttpRespGenerator(Map<String, HttpCalloutMock> mRequests) {
        System.debug('---- MREQUESTS: ' + mRequests);
        this.mRequests = mRequests;
    }

    public HTTPResponse respond(HTTPRequest oHTTPRequest) {
        System.HttpCalloutMock oHttpCalloutMock = mRequests.get(oHTTPRequest.getEndpoint());

        if (oHttpCalloutMock == null) throw new CCCUtils.CallOutException('Endpoint not found: ' + oHTTPRequest.getEndpoint());

        System.debug('---- response: ' + oHttpCalloutMock.respond(oHTTPRequest));
        return oHttpCalloutMock.respond(oHTTPRequest);
    }
}