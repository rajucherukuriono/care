/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 01/22/2020
Description: Apex class representation of an Update Review JSON request

Example request:

{
  "review": {
    "first_name": "John",
    "last_name": "Smith",
    "email": "jsmith@gmail.con",
    "phone": "555-555-5555"
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqUpdateReview extends HttpRequestElement {

    @AuraEnabled public ReviewObject review { get; set; }

    public class ReviewObject {
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String location_name { get; set; }
    }

    public CCCAPIReqUpdateReview() {}
}