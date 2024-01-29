/****************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 03/28/2022
Description: Base ServerResponse class to be extend by other Apex classes that
             wish to return complex data along with a basic error boolean and message
Comments:

*****************************************************************************/
public virtual class ServerResponse {

    @AuraEnabled public Boolean hasErrors { get; set; }
    @AuraEnabled public String message { get; set; }

    public ServerResponse() {
        this.hasErrors = false;
        this.message = null;
    }

    // Helper method to return a formatted error result based on an exception
    public static ServerResponse setErrorResponse(String CLASS_NAME, String METHOD_NAME, Exception e, ServerResponse response) {
        response.message = CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage();
        response.hasErrors = true;
        return response;
    }

}