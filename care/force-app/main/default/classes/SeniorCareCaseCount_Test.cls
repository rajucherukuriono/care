@isTest
private class SeniorCareCaseCount_Test {

    private static ID scCaseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Care Consult').getRecordTypeId();

    @testSetup static void setupData() {
        TestUtil.createNthDayPremiumSeeker();
        TestUtil.createPremiumSeeker();
        }

    static testMethod void SeniorCareCase_InsertUpdateAndDelete() {
        // This test creates an SC Case to confirm it gets counted on its account.
        // Then it moves the case to another account and confirms the new account has the case, but not the old one
        // Then it deletes the case to confirm parent accounts has its count updated

        Account a = [SELECT id FROM Account WHERE FirstName = :TestUtil.NthDayPremiumSeekerFirstName];

        Case c = new Case();
        c.recordtypeid = scCaseRtId;
        c.AccountId = a.id;
        insert c; 

        a = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a.id];
        //System.Assert(a.Senior_Care_Case_Count__c == 1);
        //System.Assert(a.First_Senior_Care_Case__c == Date.today());     

        Account a2 = [SELECT id FROM Account WHERE FirstName = :TestUtil.PremiumSeekerFirstName];
        c.accountId = a2.id;
        update c;
        
        a = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a.id];
        //System.Assert(a.Senior_Care_Case_Count__c == 0);
        System.Assert(a.First_Senior_Care_Case__c == null);     

        a2 = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a2.id];
        //System.Assert(a2.Senior_Care_Case_Count__c == 1);
        //System.Assert(a2.First_Senior_Care_Case__c == Date.today());
        
        delete c;
        a2 = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a2.id];
        //System.Assert(a2.Senior_Care_Case_Count__c == 0);
        //System.Assert(a2.First_Senior_Care_Case__c == null);
                

    }

    static testMethod void TwoSeniorCareCases() {
        // This unit test creates 2 SC cases and assigns them to the same account to ensure both cases are counted
        
        Account a = [SELECT id FROM Account WHERE FirstName = :TestUtil.NthDayPremiumSeekerFirstName];

        Case c = new Case();
        c.recordtypeid = scCaseRtId;
        c.AccountId = a.id;
        insert c; 

        Case c2 = new Case();
        c2.recordtypeid = scCaseRtId;
        c2.AccountId = a.id;
        insert c2; 

        a = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a.id];
        //System.Assert(a.Senior_Care_Case_Count__c == 2);
        //System.Assert(a.First_Senior_Care_Case__c == Date.today());     
    }

    static testMethod void TestBatch() {
        Account a = [SELECT id FROM Account WHERE FirstName = :TestUtil.NthDayPremiumSeekerFirstName];

        List<Case> Cases = new List<Case>();
        Case c = new Case();
        c.recordtypeid = scCaseRtId;
        c.AccountId = a.id;
        Cases.add(c);

        Case c2 = new Case();
        c2.recordtypeid = scCaseRtId;
        c2.AccountId = a.id;
        Cases.add(c2);

        Account a2 = [SELECT id FROM Account WHERE FirstName = :TestUtil.PremiumSeekerFirstName];
        Case c3 = new Case();
        c3.recordtypeid = scCaseRtId;
        c3.AccountId = a2.id;
        Cases.add(c3);

        Case c4 = new Case();
        c4.recordtypeid = scCaseRtId;
        c4.AccountId = a2.id;
        Cases.add(c4);

        Case c5 = new Case();
        c5.recordtypeid = scCaseRtId;
        c5.AccountId = a2.id;
        Cases.add(c5);
        
        insert Cases;        
        
        Test.StartTest();
    
        SeniorCareCaseCount_Batch bSeniorCareBatch = new SeniorCareCaseCount_Batch();
        ID batchprocessid = Database.executeBatch(bSeniorCareBatch);
    
        Test.StopTest();    

        a = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a.id];
        System.Assert(a.Senior_Care_Case_Count__c == 2);
        System.Assert(a.First_Senior_Care_Case__c == Date.today());     

        a2 = [SELECT id,Senior_Care_Case_Count__c,First_Senior_Care_Case__c FROM Account WHERE id = :a2.id];
        System.Assert(a2.Senior_Care_Case_Count__c == 3);
        System.Assert(a2.First_Senior_Care_Case__c == Date.today());        

    }
}