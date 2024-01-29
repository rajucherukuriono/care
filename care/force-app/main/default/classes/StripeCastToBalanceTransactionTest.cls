@isTest
public with sharing class StripeCastToBalanceTransactionTest {
    
    @isTest
    static void parseAndCastJsonTest(){
        string balanceTransactionJSON = '{ "id": "txn_3NIx37Lpw5ZaWGur1wFn3mF8", "object": "balance_transaction", "amount": 22180, "available_on": 1687305600, "created": 1687215901, "currency": "usd", "description": null, "exchange_rate": null, "fee": 0, "fee_details": [], "net": 22180, "reporting_category": "charge", "source": "ch_3NIx37Lpw5ZaWGur1m2pPVz7", "status": "available", "type": "charge" }';
    
        List<StripeCastToBalanceTransaction.InvokeInput> inputs = new List<StripeCastToBalanceTransaction.InvokeInput>();
        StripeCastToBalanceTransaction.InvokeInput input = new StripeCastToBalanceTransaction.InvokeInput();
        input.jsonString = balanceTransactionJSON;
        inputs.add(input);

        List<StripeCastToBalanceTransaction.InvokeOutput> parsedJSON = StripeCastToBalanceTransaction.parseAndCastJson(inputs);

        System.AssertEquals(1, parsedJSON.size(), 'There should be one record returned');
        System.AssertEquals(22180, parsedJSON[0].castBalanceTransaction.amount, 'Amount should be 22180');
    }
}