@isTest
public with sharing class StripeCastToBalanceResponseTest {
    
    @isTest
    static void parseAndCastJsonTest(){
        string balanceTransactionJSON = '{ "object": "balance", "available": [ { "amount": 13950, "currency": "usd", "source_types": { "card": 13950 } } ], "livemode": true, "pending": [ { "amount": 0, "currency": "usd", "source_types": { "card": 0 } } ] }';
    
        List<StripeCastToBalanceResponse.InvokeInput> inputs = new List<StripeCastToBalanceResponse.InvokeInput>();
        StripeCastToBalanceResponse.InvokeInput input = new StripeCastToBalanceResponse.InvokeInput();
        input.jsonString = balanceTransactionJSON;
        inputs.add(input);

        List<StripeCastToBalanceResponse.InvokeOutput> parsedJSON = StripeCastToBalanceResponse.parseAndCastJson(inputs);

        System.AssertEquals(1, parsedJSON.size(), 'There should be one record returned');
    }
}