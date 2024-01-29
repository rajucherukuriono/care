global with sharing class StripeRefund {
    
    global class StripeRefundInput {
        @InvocableVariable(
            Label='Stripe Refund Response' 
            Description='Stripe Refund Response' 
            Required=true)
        global List<stripeGC.Refund> stripeRefundResponse;
    }

    global class StripeRefundOutput {
        @InvocableVariable(
            Label='Stripe refund as SObject' 
            Description='Stripe refund as SObject' 
            Required=true)
        global List<Stripe_Refund__c> stripeRefundSObjects;
    }
    
    @InvocableMethod(
        Label='Stripe convert refund response to SObject'
        Description='Stripe convert refund response to SObject')
    public static List<StripeRefundOutput> ConvertStripeRefundResponseToSObject(List<StripeRefundInput> responses) {

        List<StripeRefundOutput> stripeRefundOutput = new List<StripeRefundOutput>();
        for(StripeRefundInput each : responses){
            System.debug(each);

            List<Stripe_Refund__c> stripeRefundSObjects = new List<Stripe_Refund__c>();

            for(StripeGC.Refund eachRefund : each.stripeRefundResponse){
                Stripe_Refund__c refundSObject = new Stripe_Refund__c();
                refundSObject.AmountFromResponse__c = eachRefund.amount;
                refundSObject.Charge__c = eachRefund.charge;
                refundSObject.Payment_Intent__c = eachRefund.paymentIntent;
                refundSObject.Refund_Id__c = eachRefund.Id;
                refundSObject.Amount_Formatted__c = Double.valueOf(eachRefund.amount) / 100;
                refundSObject.Date_Refunded__c = Datetime.newInstance(0).addSeconds(eachRefund.created);

                stripeRefundSObjects.add(refundSObject);
            }
            StripeRefundOutput refundOutput = new StripeRefundOutput();
            refundOutput.stripeRefundSObjects = stripeRefundSObjects;
            stripeRefundOutput.add(refundOutput);
        }
        return stripeRefundOutput;
    }
}