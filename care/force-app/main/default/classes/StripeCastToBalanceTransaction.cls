global with sharing class StripeCastToBalanceTransaction {

    public class InvokeInput {
        @InvocableVariable(label='JSON String' required=true)
        public String jsonString;
    }

	public class InvokeOutput {
    	@InvocableVariable(label='BalanceTransaction List')
    	public StripeBalanceTransaction castBalanceTransaction;
	}

    @InvocableMethod(label='Parse JSON and Cast to BalanceTransaction' description='Parses a JSON string into individual v01_CastBalanceTransaction.BalanceTransaction.')
    public static List<InvokeOutput> parseAndCastJson(List<InvokeInput> inputs) {
        List<InvokeOutput> outputs = new List<InvokeOutput>();
        
        for(InvokeInput input : inputs) {
            StripeBalanceTransaction balance = (StripeBalanceTransaction)JSON.deserialize(input.jsonString, StripeBalanceTransaction.Class);

            InvokeOutput output = new InvokeOutput();
            output.castBalanceTransaction = new StripeBalanceTransaction();
            output.castBalanceTransaction = balance;
            outputs.add(output);
        }

        return outputs;
    }  
}