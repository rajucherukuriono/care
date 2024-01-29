global class MockHTTPResponse_USPlatform implements HttpCalloutMock {
    global static Map<String, Object> responseMap = new Map<String, Object>();
    
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');

        String endPoint = req.getEndpoint();
        // If endpoint contains the special email 'generateapierror@care.com', we throw a fake error (for testing)
        res.setBody(JSON.serializePretty(responseMap));
        res.setStatusCode(200);
        return res;
    }
/* Code to build response maps
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
		batchMap.put('rabbit@mail.mail',new Map<String, Object>{'memberId'=>'1234','salesforceId'=>'abcd','email'=>'rabbit@mail.mail'});
        batchMap.put('eeyore@gmail.com',new Map<String, Object>{'memberId'=>'1235','salesforceId'=>null,'email'=>'eeyore@gmail.com'});
        responseMap.put('batch', batchMap);
        String deseralizedResponse = JSON.serializePretty(responseMap);
        System.debug('deseralizedResponse: ' + deseralizedResponse);
*/

}