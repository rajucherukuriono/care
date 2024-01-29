global with sharing class StripeCharge {
    
    global class StripeChargeInput {
        @InvocableVariable(
            Label='Stripe Charge Response' 
            Description='Stripe Charge Response' 
            Required=true)
        global List<stripeGC.Charge> stripeChargeResponse;
    }

    global class StripeChargeOutput {
        @InvocableVariable(
            Label='Stripe Charge as SObject' 
            Description='Stripe Charge as SObject' 
            Required=true)
        global List<StripeChargeResponse__c> stripeChargeSObjects;
    }
    
    @InvocableMethod(
        Label='Stripe convert charge response to SObject'
        Description='Stripe convert charge response to SObject')
    public static List<StripeChargeOutput> ConvertStripeChargeResponseToSObject(List<StripeChargeInput> responses) {

        List<StripeChargeOutput> stripeChargesOutput = new List<StripeChargeOutput>();
        for(StripeChargeInput each : responses){
            System.debug(each);

            List<StripeChargeResponse__c> stripeChargeSObjects = new List<StripeChargeResponse__c>();

            for(StripeGC.Charge eachCharge : each.stripeChargeResponse){
                
                String typeOfTransaction = '';

                for(stripeGC.AdditionalString eachString : eachCharge?.metadata?.listAdditionalStringField){
                    if(eachString.key == 'Category'){
                        typeOfTransaction = eachString?.value;
                        break;
                    }
                }

                StripeChargeResponse__c chargeSObject = new StripeChargeResponse__c();
                chargeSObject.Category__c = typeOfTransaction;
                chargeSObject.Amount__c = eachCharge.amount;
                chargeSObject.Amount_Formatted__c = Double.valueOf(eachCharge.amount) / 100;
                chargeSObject.Amount_Captured_Formatted__c = Double.valueOf(eachCharge.amountCaptured) / 100;
                chargeSObject.Amount_Refunded_Formatted__c = Double.valueOf(eachCharge.amountRefunded) / 100;
                chargeSObject.BalanceTransaction__c = eachCharge.balanceTransaction;
                chargeSObject.CalculatedStatementDescriptor__c = eachCharge.calculatedStatementDescriptor;
                chargeSObject.AmountCaptured__c = eachCharge.amountCaptured;
                chargeSObject.AmountRefunded__c = eachCharge.amountRefunded;
                chargeSObject.Status__c = eachCharge.status;
                chargeSObject.ChargeId__c = eachCharge.id;
                chargeSObject.Payment_Intent__c = eachCharge.paymentIntent;
                chargeSObject.Destination__c = eachCharge.destination;
                chargeSObject.Date_Charged__c = Datetime.newInstance(0).addSeconds(eachCharge.created);

                chargeSObject.Available_For_Refund__c = ((Double.valueOf(eachCharge.amountCaptured) - Double.valueOf(eachCharge.amountRefunded)) > 0) ? (Double.valueOf(eachCharge.amountCaptured) - Double.valueOf(eachCharge.amountRefunded)) / 100 : 0;

                stripeChargeSObjects.add(chargeSObject);
            }

            StripeChargeOutput chargeOutput = new StripeChargeOutput();
            chargeOutput.stripeChargeSObjects = stripeChargeSObjects;
            stripeChargesOutput.add(chargeOutput);

        }

        return stripeChargesOutput;
    }
}