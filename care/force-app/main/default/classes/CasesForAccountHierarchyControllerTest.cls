@isTest
public with sharing class CasesForAccountHierarchyControllerTest {
    
    private static Account createData(){
        Account testAccount = createAccount('test@test.com', true);
        createCase(testAccount, true);

        return testAccount;
    }

    private static Account createAccount(String email, boolean doInsert){
        Account testAccount = new Account(lastname = 'Tester',
                                         personEmail= email);
        if(doInsert) insert testAccount;

        return testAccount;
    }

    private static Case createCase(Account testAccount, boolean doInsert){
        Case testCase = new Case(accountid = testAccount.id,
                                 Subject='Test Case');
        
        if(doInsert) insert testCase;

        return testCase;
    }

    @isTest
    static void filteredCasesAreReturned(){
        Account testAccount = createAccount('test@test.com', true);
        Case testCase = createCase(testAccount, true);

        Account testAccount2 = createAccount('test@test.com', true);
        Case testCase2 = createCase(testAccount2, false);
        testCase2.subject = 'Not Filtered';
        insert testCase2;

        CasesForAccountHierarchyController.getCasesRelatedToAccountHierarchy(testAccount.Id,
                                                                              'Account_Hierarchy',
                                                                              'Account',
                                                                              'subject',
                                                                              'Not Filtered');


    }

    @IsTest
    static void calledFromAccount(){
        Account testAccount = createData();


        CasesForAccountHierarchyController.getCasesRelatedToAccountHierarchy(testAccount.Id,
                                                                              'Account_Hierarchy',
                                                                              'Account',
                                                                              null,
                                                                              null);
    }

    @isTest
    static void calledFromCase(){
        Account testAccount = createAccount('test@test.com', true);
        Case testCase = createCase(testAccount, true);

        String cases = CasesForAccountHierarchyController.getCasesRelatedToAccountHierarchy(testCase.Id,
                                                                              'Account_Hierarchy',
                                                                              'Case',
                                                                              null,
                                                                              null);
    }
}