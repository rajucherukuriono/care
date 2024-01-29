global with sharing class StripeBalanceTransaction {
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer amount;
        @AuraEnabled
        @InvocableVariable(label='available_on' required=true)
        global Integer available_on;
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer created;
        @AuraEnabled
        @InvocableVariable( required=true)
        global String description;
        @AuraEnabled
        @InvocableVariable(label='exchange_rate' required=true)
        global Double exchangeRate;
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer fee;
        @AuraEnabled
        @InvocableVariable(label='fee_details (List<stripeGC__Fee>)' required=true)
        global List<stripeGC.Fee> feeDetails;
        @AuraEnabled
        @InvocableVariable( required=true)
        global String id;
        @AuraEnabled
        @InvocableVariable( required=true)
        global Integer net;
        @AuraEnabled
        @InvocableVariable(label='currency' required=true)
        global String r_currency;
        @AuraEnabled
        @InvocableVariable(label='object' required=true)
        global String r_object;
        @AuraEnabled
        @InvocableVariable(label='reporting_category' required=true)
        global String reportingCategory;
        @AuraEnabled
        @InvocableVariable(label='source' required=true)
        global String source;
        @AuraEnabled
        @InvocableVariable( required=true)
        global String status;
        @AuraEnabled
        @InvocableVariable( required=true)
        global String type;
}