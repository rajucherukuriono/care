@isTest
public with sharing class StripeChargeTest {
    
    @isTest
    static void StripeChargeIsConverted() {
        List<StripeCharge.StripeChargeInput> inputs = new List<StripeCharge.StripeChargeInput>();
        StripeCharge.StripeChargeInput input = new StripeCharge.StripeChargeInput();
        List<StripeGC.Charge> stripeCharges = new List<StripeGC.Charge>();
        StripeGC.Charge charge = new StripeGC.Charge();
        charge.amount = 22180;
        charge.amountCaptured = 22180;
        charge.amountRefunded = 0;
        charge.calculatedStatementDescriptor = 'Statement Description';
        charge.status = 'succeeded';
        charge.id = 'ch_3NCmwoLpw5ZaWGur16kVjrCh';
        charge.paymentIntent = null;
        charge.created = 1685206801;
        StripeGC.AdditionalString stringField = new StripeGC.AdditionalString();
        stringfield.key = 'Category';
        stringfield.value = 'INSTANT_BOOK';
        charge.metadata = new StripeGC.metadata();
        charge.metadata.listAdditionalStringField = new List<StripeGC.AdditionalString>{stringField};        

        stripeCharges.add(charge);
        input.stripeChargeResponse = stripeCharges;
        inputs.add(input);

        List<StripeCharge.StripeChargeOutput> output = StripeCharge.ConvertStripeChargeResponseToSObject(inputs);

        System.AssertEquals(output.size(), 1, 'One record should be returned');
    }
}