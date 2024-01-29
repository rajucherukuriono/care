/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revtech360.com
Created: 5/24/2022
Description: Test methods for BUCCaseCalloutMaster Apex class
Comments:

********************************************************************************************/
@isTest
private class BUCCaseCalloutMaster_Test {
    @testSetup static void setup() {
        Account a = new Account(Name = 'Test', Insurance_Status__c = 'Compliant', Insurance_Expires__c = DateTime.now());
        insert a;

        Case c = new Case(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId());
        insert c;
    }

    @isTest static void test_UpdateAccountOnGaloreByAccountId() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        BUCCaseCalloutMaster.UpdateAccountOnGaloreByAccountId(accountId);
    }

    @isTest static void test_UpdateAccountsOnGaloreByCaseId() {
        List<Id> caseIds = new List<Id>();
        for (Case c : [SELECT Id FROM Case]) {
            caseIds.add(c.Id);
        }

        BUCCaseCalloutMaster.UpdateAccountsOnGaloreByCaseId(caseIds);
    }

    @isTest static void testcoverage() {
        HttpResponse httpResp = new HttpResponse();
        BUCAccountGaloreUpdateResponse resp = new BUCAccountGaloreUpdateResponse(httpResp);
        resp.getServerResponse();
    }

    // Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId();
    // Schema.SObjectType.Case.getRecordTypeInfosByName().get('Infraction or License Changes').getRecordTypeId();
    // Schema.SObjectType.Case.getRecordTypeInfosByName().get('COI expiration').getRecordTypeId();

}