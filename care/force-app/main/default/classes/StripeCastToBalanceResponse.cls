global with sharing class StripeCastToBalanceResponse {

    public class InvokeInput {
        @InvocableVariable(label='JSON String' required=true)
        public String jsonString;
    }

	public class InvokeOutput {
        @InvocableVariable( required=false)
        public Integer availableAmount = 0;

        @InvocableVariable( required=false)
        public Integer connect_reservedAmount = 0;

        @InvocableVariable( required=false)
        public Integer instant_availableAmount = 0;

        @InvocableVariable( required=false)
        public Integer pendingAmount = 0;
	}

    @InvocableMethod(label='Parse JSON and Cast to Balance Response' description='Parses a JSON string into individual Balance Response')
    public static List<InvokeOutput> parseAndCastJson(List<InvokeInput> inputs) {
        List<InvokeOutput> outputs = new List<InvokeOutput>();
        
        for(InvokeInput input : inputs) {
            StripeBalanceResponse balance = (StripeBalanceResponse)JSON.deserialize(input.jsonString, StripeBalanceResponse.Class);

            System.debug('Cast Balance');
            System.debug(balance);

            InvokeOutput output = new InvokeOutput();

            if(balance.available != null){
                for(StripeBalanceResponse.balanceAmount each : balance.available){
                    output.availableAmount += each.amount;
                }
            }

            if(balance.connect_reserved != null){
                for(StripeBalanceResponse.balanceAmount each : balance.connect_reserved){
                    output.connect_reservedAmount += each.amount;
                }
            }

            if(balance.instant_available != null){
                for(StripeBalanceResponse.balanceAmount each : balance.instant_available){
                    output.instant_availableAmount += each.amount;
                }
            }

            if(balance.pending != null){
                for(StripeBalanceResponse.balanceAmount each : balance.pending){
                    output.pendingAmount += each.amount;
                }
            }

            outputs.add(output);
        }
        System.debug(outputs);
        return outputs;
    } 
}