/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 01/26/2021
Description: Apex class representation of a Fetch a Business JSON response

Example JSON response:

{
    "business": {
        "business_id": "32f8450d-973c-4dbf-8286-0e4b0e4b18bd",
        "locations": [
            {
                "uuid": "0900d1d5-23c7-4276-b16f-c28df63e6ed1",
                "salesforce_id": null,
                "ads_active": "unknown",
                "active": true,
                "name": "XYZ",
                "budget_currency": "USD",
                "run_ads": false,
                "ads_status": "unknown",
                "advertising_areas": [
                    "46033",
                    "46062",
                    "46032",
                    "46074"
                ],
                "monthly_advertising_budget_cents": 0,
                "monthly_advertising_budget": "0.0",
                "rate_per_lead_cents": 0,
                "rate_per_lead": "0.00",
                "offerings": [
                    {
                        "uuid": "3f69c7d1-41e1-4114-8642-49e14200eb81",
                        "active": true,
                        "capacity": 60,
                        "open_time": null,
                        "close_time": null,
                        "vertical": "child_care",
                        "service": "centers",
                        "start_week": null,
                        "end_week": null,
                        "min_months": 12,
                        "max_months": 204
                    },
                    {
                        "uuid": "500d8e6d-f218-4d2a-96c6-cd0697cb40ec",
                        "active": true,
                        "capacity": 50,
                        "open_time": null,
                        "close_time": null,
                        "vertical": "child_care",
                        "service": "centers",
                        "start_week": null,
                        "end_week": null,
                        "min_months": 12,
                        "max_months": 36
                    }
                ],
                "address": {
                    "line1": "123 Street",
                    "line2": null,
                    "city": "City",
                    "state": "Idaho",
                    "postal_code": "47123"
                }
            }
        ],
        "reviews": [
            {
                "uuid": "96208710-751f-459f-bede-9976eecc7c8d",
                "business_id": "32f8450d-973c-4dbf-8286-0e4b0e4b18bd",
                "first_name": "asdf",
                "last_name": "asdf",
                "email": "asdf@asdf.com",
                "phone": "1111111111"
            }
        ]
    }
}


*********************************************************************************************/
public without sharing class CCCAPIRespFetchABusiness extends HttpResponseElement {

    public class BusinessObject {
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public String sales_contract_uuid { get; set; }
        @AuraEnabled public List<LocationObject> locations { get; set; }
        @AuraEnabled public List<ReviewObject> reviews { get; set; }
    }

    public class LocationObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String ads_status { get; set; }
        @AuraEnabled public Boolean run_ads { get; set; }
        @AuraEnabled public Boolean active { get; set; }
        @AuraEnabled public String salesforce_id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String budget_currency { get; set; }
        @AuraEnabled public Integer monthly_advertising_budget_cents { get; set; }
        @AuraEnabled public Decimal monthly_advertising_budget { get; set; }
        @AuraEnabled public List<String> advertising_areas { get; set; }
        @AuraEnabled public List<OfferingObject> offerings { get; set; }
        @AuraEnabled public AddressObject address { get; set; }

        public LocationObject() {
            this.monthly_advertising_budget_cents = 0;
            this.monthly_advertising_budget = 0.0;
        }
    }

    public class ReviewObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String location_name { get; set; }
        @AuraEnabled public Boolean verified { get; set; }
    }

    public class OfferingObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public Boolean active { get; set; }
        @AuraEnabled public String vertical { get; set; }
        @AuraEnabled public String service { get; set; }
        @AuraEnabled public String care_type { get; set; }
    }

    public class AddressObject {
        @AuraEnabled public String line1 { get; set; }
        @AuraEnabled public String line2 { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postal_code { get; set; }
    }


    /**
    * @description Object holding the response data
    */
    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public BusinessObject business { get; set; }
        @AuraEnabled public String error { get; set; }
        @AuraEnabled public String error_message { get; set; }
        @AuraEnabled public String error_code { get; set; }

        public ServerResponse() {
            super();
            this.business = new BusinessObject();
        }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespFetchABusiness(HttpResponse httpResponse) {
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
            System.debug('******************** CCCAPIRespFetchABusiness.getServerResponse(): EXCEPTION (Line:' + e.getLineNumber() + '): ' + e.getMessage());
            response.hasErrors = true;
            response.message = getBody();
        }
        return response;
    }
}