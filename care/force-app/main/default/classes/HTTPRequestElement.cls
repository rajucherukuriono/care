/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/14/2020
Description: Extend this class with the request data to call the web service framework.

Changes:

*********************************************************************************************/
public abstract class HTTPRequestElement {

    private String endPoint = '';
    private String method = '';
    private String body = '';
    private Integer timeout = 120000;
    private Map<String, String> headers = new Map<String, String>();

    /**
    * @description Get the endpoint to be called
    */
    public String getEndPoint() {
        return endPoint;
    }

    /**
    * @description The endpoint to be called
    */
    public void setEndPoint(String value) {
        endPoint = value;
    }

    /**
    * @description Get the HTTP timeout for the callout
    */
    public Integer getTimeout() {
        return timeout;
    }

    /**
    * @description Set the timeout for the callout. Default is 120000
    */
    public void setTimeout(Integer value) {
        timeout = value;
    }

    /**
    * @description Get the HTTP method to be used for the callout
    */
    public String getMethod() {
        return method;
    }

    /**
    * @description Set the HTTP method to be used for the callout
    */
    public void setMethod(String value) {
        method = value;
    }

    /**
    * @description Get the request body to be used for the callout
    */
    public String getBody() {
        return body;
    }

    /**
    * @description Set the request body to be used for the callout
    * @param String - value body
    */
    public void setBody(String value) {
        body = value;
    }

    /**
    * @description Set a header for the request
    * @param String - Header key (example: Content-Type )
    * @param String - Header value (example: application/json)
    */
    public void setHeader(String key, String value) {
        headers.put(key, value);
    }

    /**
    * @description Returns the defined key value pair Headers
    */
    public Map<String, String> getHeaders() {
        return headers;
    }

    /**
    * @description Build and return the HTTPRequst object to be used for the callout
    * @return HTTPRequest to be used for the callout
    */
    public HTTPRequest getRequest() {

        // Create the HTTP Request object
        HttpRequest httpRequest = new HttpRequest();

        // Loop through the headers in cache
        if (headers != null && !headers.isEmpty()) {

            for (String key : headers.keySet()) {

                // Create a header on the Request object for each one in cache
                httpRequest.setHeader(key, headers.get(key));
            }
        }

        // Set the HTTP method on the Request object
        httpRequest.setMethod(method);

        // Check to see if the body has been set
        if (String.isNotBlank(body)) {

            // Set the body on the Request object
            httpRequest.setBody(body);
        }

        // Set the Timeout on the request object
        httpRequest.setTimeout(timeout);

        // return the Request object
        return httpRequest;
    }
}