/**
 * Created by VivinMathew on 10/14/2020.
 */

@IsTest
private class UCaseTest {

    @TestSetup
    static void setUpTestData(){
        setUpHelper();
    }


    @IsTest
    static void testCaseInsert() {
        Integer count = 0;
        List<Case> cases = new List<Case>();
        Id chargeBackRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chargeback').getRecordTypeId();
        while(count < 50){
            Case caseRec = new Case();
            caseRec.Status = 'New';
            caseRec.Priority = 'Medium';
            caseRec.Origin = 'Email';
            caseRec.Reason = 'Site Usage';
            caseRec.Secondary_Case_Reason__c = 'Login Trouble';
            caseRec.RecordTypeId = chargeBackRT;
            cases.add(caseRec);
            count++;
        }

        Test.startTest();
        insert cases;
        Test.stopTest();
    }

    @IsTest
    static void testCaseInsertUpdate(){
        Id chargeBackRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chargeback').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.Status = 'New';
        caseRec.Priority = 'Medium';
        caseRec.Origin = 'Email';
        caseRec.Reason = 'Site Usage';
        caseRec.Secondary_Case_Reason__c = 'Login Trouble';
        caseRec.RecordTypeId = chargeBackRT;
        insert caseRec;

        caseRec.Origin = 'Chat';
        Test.startTest();
        update caseRec;
        Test.stopTest();
    }

    static void setUpHelper(){
        //to do
    }
}