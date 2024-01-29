@isTest
global class SyncCaseMockHttpservices implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Create__CompIntfc__LC_SFCASE_CIResponse":{"notification":1,"detail":{"LC_SFCASE_CI":{"LC_SFCASE_ID":168,"BUSINESS_UNIT":"LCARE", "CASE_ID":"2607731", "ERROR_CODE":"210", "ERROR_MESSAGE":"Service Type Name is blank. Cannot create Case."}}}}');
        res.setStatusCode(200);
        return res;
    }
}