/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/21/2020
Description: Apex class representation of an Update Sales Contract JSON response

Example Response:

{
    "salesforce_contract": {
        "salesforce_opportunity_id": "006f000000P0eNJAAZ",
        "business_id": "482e7eaf-04fa-4e84-b1e6-939c5a5e798a"
    }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIRespUpdateSalesContract extends HttpResponseElement {

    public class SalesforceContract {
        @AuraEnabled public String salesforce_opportunity_id { get; set; }
        @AuraEnabled public String business_id { get; set; }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespUpdateSalesContract(HttpResponse response) {
        setResponse(response);
    }

    /**
    * @description Object holding the response data
    */
    public class ServerResponse extends CCCServerResponse {
        public SalesforceContract sales_contract { get; set; }

        public ServerResponse() {
            super();
        }
    }

    /**
    * @description Return the deserialized response JSON data
    */
    public ServerResponse getServerResponse() {
        ServerResponse response = new ServerResponse();

        try {
            response = (ServerResponse) JSON.deserialize(getBody(), ServerResponse.class);
            response.hasErrors = false;
        } catch(Exception e) {
            response.hasErrors = true;
            response.message = getBody();
        }

        return response;
    }
}