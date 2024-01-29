/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/30/2020
Description: The base class used to test API call outs. It contains a map of endpoints associated
             to a corresponding instance of the HttpCalloutMock class.
Changes:
*********************************************************************************************/

public without sharing class CCCMockCallouts {
    private final Map<String, System.HttpCalloutMock> mCallouts;

    public CCCMockCallouts() {
        mCallouts = new Map<String, HttpCalloutMock>();
    }

    public void add(String sEndPoint, String sResponse) {
        add(sEndPoint, sResponse, null, null);
    }

    public void add(String sEndPoint, String sResponse, Integer iStatusCode, String sStatus) {
        CCCMockHttpRespGenerator oMockHttpResponseGenerator = new CCCMockHttpRespGenerator(sResponse);

        if (iStatusCode != null) oMockHttpResponseGenerator.statusCode = iStatusCode;
        if (sStatus != null) oMockHttpResponseGenerator.status = sStatus;

        mCallouts.put(sEndPoint, oMockHttpResponseGenerator);
    }

    public System.HttpCalloutMock getMockCallout() {
        return new CCCMultiMockHttpRespGenerator(mCallouts);
    }
}