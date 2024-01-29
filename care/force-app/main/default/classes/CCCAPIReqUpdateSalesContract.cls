/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 12/21/2020
Description: Apex class representation of an Update Sales Contract JSON request

Example Request:

{
  "sales_contract": {
    "contract_status": "cancel" ex: canceled, active
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqUpdateSalesContract extends HTTPRequestElement {

    @AuraEnabled public SalesContract sales_contract { get; set; }

    public class SalesContract {
        @AuraEnabled public String contract_status { get; set; }

        public SalesContract() {
        }
    }

    /**
    * @description Constructor
    */
    public CCCAPIReqUpdateSalesContract() {
    }

}