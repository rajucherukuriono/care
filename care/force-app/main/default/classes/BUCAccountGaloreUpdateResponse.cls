/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 03/28/2022
Description: Apex class representation of an Update Account JSON response

Example Response:

{
    "???": {
    }
}

Changes:

*********************************************************************************************/
public without sharing class BUCAccountGaloreUpdateResponse extends HttpResponseElement {

    public class AccountResultObject {
    }

    /**
    * @description Set the response object
    */
    public BUCAccountGaloreUpdateResponse(HttpResponse response) {
        setResponse(response);
    }


    public class BUCAccountResponse extends ServerResponse {
        public AccountResultObject accountResult { get; set; }

        public BUCAccountResponse() {
            super();
        }
    }

    /**
    * @description Return the deserialized response JSON data
    */
    public BUCAccountResponse getServerResponse() {
        BUCAccountResponse response = new BUCAccountResponse();

        try {
            response = (BUCAccountResponse) JSON.deserialize(getBody(), BUCAccountResponse.class);
            response.hasErrors = false;
        } catch(Exception e) {
            response.hasErrors = true;
            response.message = getBody();
        }

        return response;
    }
}