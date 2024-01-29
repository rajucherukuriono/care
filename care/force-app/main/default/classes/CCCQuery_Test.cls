@isTest
private class CCCQuery_Test {
    @testSetup static void setup() {
        CCCTestDataFactory.createAccount('Test Account');
    }

    @isTest static void testCoverage() {
        String errorMessage = null;
        Integer errorLineNumber = null;
        try {
            CCCQuery query = CCCQuery.get('Account');
            query.fields(new List<String>{ 'Id', 'Name' });
            query.equals('AnnualRevenue', 123.45);
            query.equals('NumberOfEmployees', 123);
            query.notEquals('PersonDoNotCall', true);
            query.notEquals('AnnualRevenue', 123.45);
            query.notEquals('NumberOfEmployees', 123);
            query.notIncludes('Name', new Set<String>{ 'value1', 'value2' });
            query.descending();
            query.limitTo(1);
            query.some(1);
        } catch(Exception e) {
            errorMessage = e.getMessage();
            errorLineNumber = e.getLineNumber();
        }

        System.assertEquals(null, errorMessage);
        System.assertEquals(null, errorLineNumber);
    }
}