/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/16/2020
Description: Apex class representation of an Create Sales Contract JSON response

Example Response:

{
    "sales_contract": {
        "uuid": "a84ac300-eaa4-4d7c-93b2-f35a416cfdaa",
        "salesforce_opportunity_id": "006f000000PLZqwAAH",
        "contract_status": "published",
        "business_id": "32f8450d-973c-4dbf-8286-0e4b0e4b18bd",
        "contract_status_updated_at": 0,
        "business": {
            "business_id": "32f8450d-973c-4dbf-8286-0e4b0e4b18bd",
            "locations": [{
                    "uuid": "0900d1d5-23c7-4276-b16f-c28df63e6ed1",
                    "salesforce_id": null,
                    "name": "XYZ",
                    "budget_currency": "USD",
                    "run_ads": false,
                    "advertising_areas": ["46033", "46062", "46032", "46074"],
                    "monthly_advertising_budget_cents": 0,
                    "monthly_advertising_budget": "0.0",
                    "rate_per_lead_cents": 0,
                    "rate_per_lead": "0.00",
                    "offerings": [{
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
                        }, {
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
                        "state": "Indiana",
                        "postal_code": "11111"
                    }
                }
            ],
            "reviews": [{
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
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIRespCreateSalesContract extends HttpResponseElement {

    public class SalesforceContractObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String salesforce_opportunity_id { get; set; }
        @AuraEnabled public String contract_status { get; set; }
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public BusinessObject business { get; set; }
    }

    public class BusinessObject {
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public List<LocationObject> locations {get; set; }
        @AuraEnabled public List<ReviewObject> reviews {get; set; }
    }

    public class LocationObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String salesforce_id { get; set; }
        @AuraEnabled public String budget_currency { get; set; }
        @AuraEnabled public List<String> advertising_areas { get; set; }
        @AuraEnabled public Decimal monthly_advertising_budget { get; set; }
        @AuraEnabled public List<OfferingObject> offerings { get; set; }
        @AuraEnabled public AddressObject address { get; set; }

        public LocationObject() {
            this.monthly_advertising_budget = 0.0;
            this.budget_currency = 'USD';
        }
    }

    public class AddressObject {
        @AuraEnabled public String line1 { get; set; }
        @AuraEnabled public String line2 { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postal_code { get; set; }
    }

    public class OfferingObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public Boolean active { get; set; }
        @AuraEnabled public String vertical { get; set; }
        @AuraEnabled public String service { get; set; }
        @AuraEnabled public Integer capacity { get; set; }
        @AuraEnabled public Integer min_months { get; set; }
        @AuraEnabled public Integer max_months { get; set; }

        public OfferingObject() {
            this.capacity = 0;
            this.min_months = 0;
            this.max_months = 0;
        }
    }

    public class ReviewObject {
        @AuraEnabled public String uuid { get; set; }
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespCreateSalesContract(HttpResponse response) {
        setResponse(response);
    }

    /**
    * @description Object holding the response data
    */
    public class ServerResponse extends CCCServerResponse {
        public SalesforceContractObject sales_contract { get; set; }

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