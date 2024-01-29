//Created By: Mohammed Ashwaq
//Test class for CountryLocaleMapHelper
//Created Date: 10/11/2020
@isTest
global class Test_MockHTTPResponse_USPlatform implements HttpCalloutMock {
    static testMethod void testCallout(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}