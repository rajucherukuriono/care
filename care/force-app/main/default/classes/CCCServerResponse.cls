/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 08/25/2020
Description: Base ServerResponse class for other CCC Apex classes to extend from
Comments:

*****************************************************************************/
public virtual class CCCServerResponse {
	@AuraEnabled public Boolean hasErrors { get; set; }
	@AuraEnabled public String message { get; set; }

	public CCCServerResponse() {
		this.hasErrors = false;
		this.message = null;
	}
}