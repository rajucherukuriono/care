/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 01/22/2020
Description: Apex class representation of an Update Review JSON response

Example response:

{
  "review": {
    "uuid": "aef3962b-37a7-4fac-8548-82ec60468e2f",
    "first_name": "John",
    "last_name": "Smith",
    "email": "jsmith@gmail.con",
    "phone": "555-555-5555"
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIRespUpdateReview extends HttpResponseElement {

    public class ReviewObject {
        @AuraEnabled public Boolean verified { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String first_name { get; set; }
        @AuraEnabled public String last_name { get; set; }
        @AuraEnabled public String location_name { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String uuid { get; set; }
    }

    /**
    * @description Set the response object
    */
    public CCCAPIRespUpdateReview(HttpResponse response) {
      setResponse(response);
  }

  /**
  * @description Object holding the response data
  */
  public class ServerResponse extends CCCServerResponse {
      public ReviewObject review { get; set; }

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