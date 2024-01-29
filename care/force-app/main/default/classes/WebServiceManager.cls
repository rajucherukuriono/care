/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 10/21/2020
Description: Class repsonsible for calling web services. Takes in a HTTP Request object and returns a HTTP Response object.

Changes:

*********************************************************************************************/
public without sharing class WebServiceManager {

    public static HttpResponse processRequest(HTTPRequestElement httpRequestElement) {
        System.Http http;
        System.HttpRequest httpRequest;
        System.HttpResponse httpResponse;

        if (httpRequestElement == null) throw new CCCUtils.InvalidParameterException('Invalid Parameter Exception');

        httpRequest = httpRequestElement.getRequest();

        if (httpRequest == null) throw new CCCUtils.NullPointerException('There was a problem building the request.');

        http = new System.Http();
        System.debug('Set Endpoint' + httpRequestElement.getEndPoint());
        httpRequest.setEndPoint(httpRequestElement.getEndPoint());

        System.debug('WebServiceManager.processRequest(): Endpoint - ' + httpRequestElement.getEndPoint());
        System.debug('WebServiceManager.processRequest(): Request ====> ');
        System.debug('WebServiceManager.processRequest(): ' + httpRequest.getBody());

        httpResponse = http.send(httpRequest);

        system.debug('WebServiceManager.processRequest(): Response <==== ');
        system.debug('WebServiceManager.processRequest(): Status - ' + httpResponse.getStatus());
        system.debug('WebServiceManager.processRequest(): Status Code - ' + httpResponse.getStatusCode());
        system.debug('WebServiceManager.processRequest(): ' + httpResponse.getBody());

        if (httpResponse == null) throw new CCCUtils.CallOutException('There was a problem performing the callout.');

        return httpResponse;
    }
}