/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 02/02/2021
Description: Apex class representation of an Update Offering JSON request

Example Request:

{
  "offering": {
    "active": true
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqUpdateOffering extends HTTPRequestElement {

    @AuraEnabled public OfferingObject offering { get; set; }

    public class OfferingObject {
        @AuraEnabled public Boolean active { get; set; }

        public OfferingObject() {
        }
    }

    /**
    * @description Constructor
    */
    public CCCAPIReqUpdateOffering() {
    }
}