/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revtech360.com
Created: 5/24/2022
Description: Test methods for BUCCaseTriggerHandler Apex class
Comments:

********************************************************************************************/
@isTest
public with sharing class BUCCaseTriggerHandler_Test {

    @testSetup static void setup() {
        Account a = new Account(Name = 'Test');
        insert a;

        Case c = new Case(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId());
        insert c;
    }

    @isTest static void test_case_closed_trigger() {
        Case c = [SELECT Status FROM Case LIMIT 1];
        c.Status = 'Closed';
        update c;
    }

}