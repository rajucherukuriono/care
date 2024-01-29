/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/30/2020
Description: This class is used to test web services. Its created when the code being tested
             does a call out. This class will be created by the MockCallouts class and should
             never be created by the developer.
Changes:
*********************************************************************************************/
@isTest

global without sharing class CCCMockHttpRespGenerator implements System.HttpCalloutMock {
    global String sResponseBody;
    global Integer statusCode = 200;
    global String status = 'OK';

    global CCCMockHttpRespGenerator(String sBody) {
        sResponseBody = sBody;
    }

    global httpResponse respond(httpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setBody(sResponseBody);
        response.setStatusCode(statusCode);
        response.setStatus(status);

        return response;
    }
}