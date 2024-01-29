global with sharing class StripeBalanceResponse {

    @AuraEnabled
    @InvocableVariable( required=false)
    global List<balanceAmount> available;

    @AuraEnabled
    @InvocableVariable( required=false)
    global List<balanceAmount> connect_reserved;

    @AuraEnabled
    @InvocableVariable( required=false)
    global List<balanceAmount> instant_available;

    @AuraEnabled
    @InvocableVariable( required=true)
    global Boolean livemode;

    @AuraEnabled
    @InvocableVariable( required=false)
    global List<balanceAmount> pending;
       
    
    global class balanceAmount{
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer amount;
        
        @AuraEnabled
        @InvocableVariable( required=true)
        global Source_Types source_types;
    }
    
    global class Source_Types{
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer card;
    }
}