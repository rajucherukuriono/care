/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 01/22/2020
Description: Apex class representation of an Create Review JSON request

Example request:

{
  "review": {
    "business_id": "b38ea377-bc83-4051-a2b8-29286e4a866b",
    "first_name": "John",
    "last_name": "Smith",
    "email": "jsmith@gmail.com",
    "phone": "555-555-5555",
    "location_name": "Stepping Stone South Park Meadows"
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqCreateReview extends HttpRequestElement {

    @AuraEnabled public ReviewObject review { get; set; }

    public class ReviewObject {
        @AuraEnabled public String business_id { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String location_name { get; set; }
    }

    public CCCAPIReqCreateReview() {}

}