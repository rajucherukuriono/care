/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 02/15/2021
Description: Apex class representation of an Update Provider JSON request

Example Request:

{
  "provider": {
    "ads_status": "unknown|active|paused|canceled"
  }
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqUpdateProvider extends HTTPRequestElement {

    @AuraEnabled public ProviderObject provider { get; set; }

    public class ProviderObject {
        @AuraEnabled public String ads_status { get; set; }
    }

    /**
    * @description Constructor
    */
    public CCCAPIReqUpdateProvider() {
    }
}