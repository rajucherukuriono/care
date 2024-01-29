/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/16/2020
Description: Apex class representation of an Create Sales Contract JSON request

Example Request:

{
    "sales_contract": {
        "salesforce_opportunity_id": "006f000000P0eNJAAZ",
        "business_id": "32f8450d-973c-4dbf-8286-0e4b0e4b18bd",
        "contract_status": "publish",
        "platform_fee": 8000,
        "platform_fee_discount": 2000,
        "discount_offer": "5% off as Care.com benefit",
        "discount_available": true,
        "currency_code": "USD",
        "vertical": "child_care",
        "service": "centers",
        "business": {
            "name": "Stepping Stone",
            "address": {
                "line1": "5th Street",
                "line2": null,
                "city": "New York",
                "state": "New York",
                "postal_code": "10035"
            }
        },
        "business_owner": {
            "first_name": "Bob",
            "last_name": "Tester",
            "email": "bob@test.com",
            "phone": "5555555555"
        },
        "reviews": [{
                "first_name": "John",
                "last_name": "Smith",
                "email": "jsmith@gmail.com",
                "phone": "555-555-5555",
                "location_name": "Stepping Stone South Park Meadows"
            }
        ],
        "sales_reps": [
            {
                "salesforce_id": "006f0eNJAAZ",
                "email": "sales1@getgalore.com",
                "first_name": "Sales1",
                "last_name": "Test"
            }
        ],
        "locations": [{
                "name": "Stepping Stone South Park Meadows",
                "salesforce_id": "123abc-saleforce-id",
                "address": {
                    "line1": "5th Street",
                    "line2": null,
                    "city": "New York",
                    "state": "New York",
                    "postal_code": "10035"
                },
                "offerings": [{
                        "capacity": 123,
                        "care_type": "Assisted Living",
                        "price": 123.45
                    }
                ],
                "license": {
                    "business_name": "Stepping Stone South Park Meadows",
                    "address": {
                        "line1": "5th Street",
                        "line2": null,
                        "city": "New York",
                        "state": "New York",
                        "postal_code": "10035"
                    },
                    "license_number": "2091711",
                    "status": "unverified"
                },
                "monthly_advertising_budget": 30000,
                "budget_currency": "USD",
                "advertising_areas": ["78748", "77801", "93849"],
                "phone": "555-555-5555",
                "discounts": [   //only the first discount will be accepted
                    {  
                        "percent": 5, // integer: percent off as Care.com benefit. As a percentage it is a whole number in Galore.
                        "amount_cents": 500, // integer: amount off as Care.com benefit. As a penny amount or percentage it is a whole number in Galore.
                        "type": "money", // string - defines the type - either "money" or "percentage" off the value
                        "available": true, // boolean - 0 to turn off discount across the network / lifemartand 1 to turn on across the network
                        "audience": "All Members", // string - enum: The intended audience of this discount. Lowercase "all members", "premium", or 'enterprise members only'
                        "exclusions": "This offer is good with Lifemart Membership" // string: The terms and conditions of this offer on this specfic discount
                    }
                ]
            }
        ]
    }
}


Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqCreateSalesContract extends HTTPRequestElement {

    @AuraEnabled public SalesContractObject sales_contract { get; set; }

    public class SalesContractObject {
        @AuraEnabled public String salesforce_opportunity_id { get; set; }
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public String contract_status { get; set; } // published, pending_enrollment, pending_activation, active, void, cancelled
        @AuraEnabled public Decimal platform_fee { get; set; } // @jmw: This changed from being the total platform fee to being the base platform fee--no calculations
        @AuraEnabled public Decimal per_location_fee { get; set; } // @jmw: New field to send over the addition location fee
        @AuraEnabled public Decimal platform_fee_discount { get; set; }
        @AuraEnabled public String discount_offer { get; set; }
        @AuraEnabled public Boolean discount_available { get; set; }
        @AuraEnabled public String currency_code { get; set; }
        @AuraEnabled public BusinessObject business { get; set; }
        @AuraEnabled public BusinessOwnerObject business_owner { get; set; }
        @AuraEnabled public List<ReviewObject> reviews { get; set; }
        @AuraEnabled public List<LocationObject> locations { get; set; }
        @AuraEnabled public List<SalesRepObject> sales_reps { get; set; }
        @AuraEnabled public String vertical { get; set; }
        @AuraEnabled public String service { get; set; }

        public SalesContractObject() {
            this.platform_fee = 0.00;
            this.per_location_fee = 0.00;
            this.platform_fee_discount = 0.00;
            this.currency_code = 'USD';
        }
    }

    public class BusinessObject {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public AddressObject address { get; set; }
    }

    public class AddressObject {
        @AuraEnabled public String line1 { get; set; }
        @AuraEnabled public String line2 { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postal_code { get; set; }
    }

    public class BusinessOwnerObject {
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
    }

    public class SalesRepObject {
        @AuraEnabled public String salesforce_id { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
    }

    public class LocationObject {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String salesforce_id { get; set; }
        @AuraEnabled public AddressObject address { get; set; }
        @AuraEnabled public List<OfferingObject> offerings { get; set; }
        @AuraEnabled public LicenseObject license { get; set; }
        @AuraEnabled public Decimal monthly_advertising_budget { get; set; }
        @AuraEnabled public String budget_currency { get; set; }
        @AuraEnabled public List<String> advertising_areas { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public List<DiscountObject> discounts { get; set; }
        @AuraEnabled public Decimal min_months { get; set; }
        @AuraEnabled public Decimal max_months { get; set; }
        @AuraEnabled public Decimal flat_rate_amount { get; set; }
        @AuraEnabled public Integer contract_length { get; set; }

        public LocationObject() {
            this.monthly_advertising_budget = 0.00;
            this.budget_currency = 'USD';
        }
    }

    public class DiscountObject {
        @AuraEnabled public Integer percent { get; set; }
        @AuraEnabled public Integer amount_cents { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Boolean available { get; set; }
        @AuraEnabled public String audience { get; set; }
        @AuraEnabled public String exclusions { get; set; }
    }

    public class LicenseObject {
        @AuraEnabled public String business_name { get; set; }
        @AuraEnabled public AddressObject address { get; set; }
        @AuraEnabled public String license_number { get; set; }
        //@AuraEnabled public String status { get; set; } // Not used by Contract Composer on Create Sales Contract
    }

    public class ReviewObject {
        //@AuraEnabled public String uuid { get; set; } // Not used by Contract Composer on Create Sales Contract
        //@AuraEnabled public String salesforce_id { get; set; } // Not used by Contract Composer on Create Sales Contract
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String location_name { get; set; }
    }

    public class OfferingObject {
        @AuraEnabled public Decimal capacity { get; set; }
        @AuraEnabled public String care_type { get; set; }
        @AuraEnabled public Decimal price { get; set; }
    }

    /**
    * @description Constructor
    */
    public CCCAPIReqCreateSalesContract() {
    }

}