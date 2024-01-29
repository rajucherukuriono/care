/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 02/02/2021
Description: Apex class representation of an Update Review JSON response

Example response:

{
  "offering": {
    "uuid": "afbded54-65ac-4e28-b7e4-3e62ce1af7f5",
    "active": true,
    "capacity": 50,
    "open_time": null,
    "close_time": null,
    "vertical": "child_care",
    "service": "centers",
    "start_week": null,
    "end_week": null,
    "min_months": 6,
    "max_months": 24
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIRespUpdateOffering extends HttpResponseElement {

    public class OfferingObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public Boolean active { get; set; }
        @AuraEnabled public Integer capacity { get; set; }
        @AuraEnabled public String vertical { get; set; }
        @AuraEnabled public String service { get; set; }
        @AuraEnabled public Integer min_months { get; set; }
        @AuraEnabled public Integer max_months { get; set; }

        public OfferingObject() {
            this.capacity = 0;
            this.min_months = 0;
            this.max_months = 0;
        }
    }

    /**
    * @description Object holding the response data
    */
    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public OfferingObject offering { get; set; }
        @AuraEnabled public String error { get; set; }
        @AuraEnabled public String error_message { get; set; }
        @AuraEnabled public String error_code { get; set; }

        public ServerResponse() {
            super();
            this.offering = new OfferingObject();
        }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespUpdateOffering(HttpResponse httpResponse) {
        setResponse(httpResponse);
    }

    /**
    * @description Return the deserialized response JSON data
    */
    public ServerResponse getServerResponse() {
        ServerResponse response = new ServerResponse();

        try {
            response = (ServerResponse)JSON.deserialize(getBody(), ServerResponse.class);
            response.hasErrors = false;
        } catch(Exception e) {
            System.debug('******************** CCCAPIRespUpdateOffering.getServerResponse(): EXCEPTION (Line:' + e.getLineNumber() + '): ' + e.getMessage());
            response.hasErrors = true;
            response.message = getBody();
        }
        return response;
    }
}