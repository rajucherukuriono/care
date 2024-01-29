/*
test Class for AvoidRecursion
Description:  Created for AvoidRecursion
CreatedBy : Md Ashwaq
CreatedDate: 25/12/2022
LastModifiedBy: Md Ashwaq
ModifiedDate: 07-20-2023
*/
@IsTest
public class Test_AvoidRecursion {
	@isTest
    public static void testCaseTriageInappropriateActivity(){
        Test.startTest();
        Boolean run1 = AvoidRecursion.runOnce();
        system.assertEquals(true, run1, 'Avoid recursion');
        
        Boolean run2 = AvoidRecursion.runOnceRequestData1();
        system.assertEquals(true, run2, 'Avoid recursion');
        
        Boolean run3 = AvoidRecursion.runOnceRetention1();
        system.assertEquals(true, run3, 'Avoid recursion');
        
        Boolean run4 = AvoidRecursion.runOnceGdpr1();  
        system.assertEquals(true, run4, 'Avoid recursion');
        
        Boolean run5 = AvoidRecursion.runOnceTask1();
        system.assertEquals(true, run5, 'Avoid recursion');
        
        Boolean run6 = AvoidRecursion.runOnceEvent1();
        system.assertEquals(true, run6, 'Avoid recursion');
        
        Boolean run7 = AvoidRecursion.runOnceEmailMessage1();
        system.assertEquals(true, run7, 'Avoid recursion');
        
        Boolean run8 = AvoidRecursion.runOnceCase3();
        system.assertEquals(true, run8, 'Avoid recursion');
        
        Boolean run9 = AvoidRecursion.runOnceCase1();
        system.assertEquals(true, run9, 'Avoid recursion');
        
        Boolean run10 = AvoidRecursion.runOnceCaseComment1();
        system.assertEquals(true, run10, 'Avoid recursion');
        
        Boolean run11 = AvoidRecursion.runOnceRecentLMD();
        system.assertEquals(true, run11, 'Avoid recursion');
        
        Boolean run12 = AvoidRecursion.runOnceCCPADeletion1();
        system.assertEquals(true, run12, 'Avoid recursion');
        
        Boolean run13 = AvoidRecursion.runOnceCaseTriage();
        system.assertEquals(true, run13, 'Avoid recursion');
        
        Boolean run14 = AvoidRecursion.runOnceSafetyCaseTriage();
        system.assertEquals(true, run14, 'Avoid recursion');
        
        Boolean run15 = AvoidRecursion.runOnceOpenTask();
        system.assertEquals(true, run15, 'Avoid recursion');
        
        Boolean run16 = AvoidRecursion.runOnceSafetyCaseTriageUpdt();
        system.assertEquals(true, run16, 'Avoid recursion');
        
        Boolean run17 = AvoidRecursion.runOncesmCaseTriage();
        system.assertEquals(true, run17, 'Avoid recursion');
        
        @TestVisible
        Boolean run18 = AvoidRecursion.runOnceMCCaseTriage();
        system.assertEquals(true, run18, 'Avoid recursion');
        
        @TestVisible
        Boolean run19 = AvoidRecursion.runOnceBlockedAppeal();
        system.assertEquals(true, run19, 'Avoid recursion');
    }
}