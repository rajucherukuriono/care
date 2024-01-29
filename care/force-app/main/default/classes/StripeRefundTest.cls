@isTest
public with sharing class StripeRefundTest {
    
    @isTest
    static void StripeRefundIsConverted() {
        List<StripeRefund.StripeRefundInput> inputs = new List<StripeRefund.StripeRefundInput>();
        StripeRefund.StripeRefundInput input = new StripeRefund.StripeRefundInput();
        List<StripeGC.Refund> stripeRefunds = new List<StripeGC.Refund>();
        StripeGC.Refund refund = new StripeGC.Refund();
        refund.amount = 22180;
        refund.charge = 'ch_3NCmwoLpw5ZaWGur16kVjrCh';
        refund.paymentIntent = 'pi_3NCmwoLpw5ZaWGur16kVjrCh';
        refund.Id = 're_3NCmwoLpw5ZaWGur16kVjrCh';
        refund.created = 1685206801;

        stripeRefunds.add(refund);
        input.stripeRefundResponse = stripeRefunds;
        inputs.add(input);

        List<StripeRefund.StripeRefundOutput> output = StripeRefund.ConvertStripeRefundResponseToSObject(inputs);

        System.AssertEquals(output.size(), 1, 'One record should be returned');
    }
}