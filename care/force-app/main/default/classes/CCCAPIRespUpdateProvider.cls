/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 02/15/2021
Description: Apex class representation of an Update Provider JSON response

Example response:

{
  "provider": {
    "name": "Stepping Stone South Park Meadows",
    "uuid": "afbded54-65ac-4e28-b7e4-3e62ce1af7f5",
    "salesforce_id": "123abc-saleforce-id",
    "address": {},
    "offerings": [],
    "license": {},
    "monthly_advertising_budget": 30000,
    "budget_currency": "USD",
    "advertising_areas": [ "78748", "77801", "93849" ],
    "phone": "555-555-5555"
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIRespUpdateProvider extends HttpResponseElement {

    public class ProviderObject {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String salesforce_id { get; set; }
        @AuraEnabled public Decimal monthly_advertising_budget { get; set; }
        @AuraEnabled public String budget_currency { get; set; }
        @AuraEnabled public List<String> advertising_areas { get; set; }
        @AuraEnabled public String phone { get; set; }

        public ProviderObject() {
        }
    }

    /**
    * @description Object holding the response data
    */
    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public ProviderObject provider { get; set; }
        @AuraEnabled public String error { get; set; }
        @AuraEnabled public String error_message { get; set; }
        @AuraEnabled public String error_code { get; set; }

        public ServerResponse() {
            super();
            this.provider = new ProviderObject();
        }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespUpdateProvider(HttpResponse httpResponse) {
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
            System.debug('******************** CCCAPIRespUpdateProvider.getServerResponse(): EXCEPTION (Line:' + e.getLineNumber() + '): ' + e.getMessage());
            response.hasErrors = true;
            response.message = getBody();
        }
        return response;
    }
}