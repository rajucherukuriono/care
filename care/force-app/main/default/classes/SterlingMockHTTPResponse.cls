global class SterlingMockHTTPResponse implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');

        String endPoint = req.getEndpoint();
        // If endpoint contains the special email 'generateapierror@care.com', we throw a fake error (for testing)
        if (endPoint.contains(EncodingUtil.urlEncode('generateapierror@care.com', 'UTF-8'))){
			// Fake Error response
            res.setBody('{"error":"Fake error message here"}');
            res.setStatusCode(400);
        } else {
			// Fake succesful response
            res.setBody('{"success":"Member successfully Close"}');
            res.setStatusCode(200);
        }
        return res;
    }

}