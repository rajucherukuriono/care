/* ************************************************************
 
 * Description : Test Class for RuleNameTesterExtControllerTests
 
 * ************************************************************/
@isTest
private class RuleNameTesterExtControllerTests 
{
	    
    @isTest
	private static void test1()
	{
        // create new RuleName__c
		BREeze__RuleName__c rn = new BREeze__RuleName__c();
        //rn.Field_Name__c = 'LastName';
        rn.BREeze__isActive__c = true;
        rn.Name = 'TestClass';
        rn.BREeze__Object_Name__c = 'Lead';
        rn.BREeze__test_ids__c = '01ri0000000SKj1,01ri0000000SKj1,01ri0000000SKj1';
        rn.BREeze__internal_Name__c = 'Test22';
        insert rn;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rn);
        RuleNameTesterExtControllerAddOn testRuleNameTester = new RuleNameTesterExtControllerAddOn(sc);

        System.assertEquals(testRuleNameTester.TestId,'01ri0000000SKj1,01ri0000000SKj1,01ri0000000SKj1');
        testRuleNameTester.runTestForRule();
        
        System.assert(testRuleNameTester.results != 'An Id is required');
  
	}
    
     @isTest
	private static void test2()
	{
        // create new RuleName__c
		BREeze__RuleName__c rn = new BREeze__RuleName__c();
        //rn.Field_Name__c = 'LastName';
        rn.BREeze__isActive__c = true;
        rn.Name = 'TestClass';
        rn.BREeze__Object_Name__c = 'Lead';
        rn.BREeze__test_ids__c = '01ri0000000SKj1,01ri0000000SKj1,01ri0000000SKj1';
        rn.BREeze__test_RuleNumbers__c = '1,apple';
        rn.BREeze__internal_Name__c = 'Test22';
        insert rn;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rn);
        RuleNameTesterExtControllerAddOn testRuleNameTester = new RuleNameTesterExtControllerAddOn(sc);

        System.assertEquals(testRuleNameTester.TestId,'01ri0000000SKj1,01ri0000000SKj1,01ri0000000SKj1');
        testRuleNameTester.runTestForRule();
        
        System.assert(testRuleNameTester.results != 'An Id is required');
	}

     @isTest
	private static void test3()
	{
        Lead l = new Lead();
        l.lastname = 'Smith';
        l.company = 'Smith Company';
        insert l;

        // create new RuleName__c
		BREeze__RuleName__c rn = new BREeze__RuleName__c();
        //rn.Field_Name__c = 'LastName';
        rn.BREeze__isActive__c = true;
        rn.Name = 'TestClass';
        rn.BREeze__Object_Name__c = 'Lead';
        rn.BREeze__test_ids__c = l.id;
        rn.BREeze__test_RuleNumbers__c = '1';
        rn.BREeze__internal_Name__c = 'Test22';
        insert rn;
        
        BREeze__Rule__c r = new BREeze__Rule__c();
        r.BREeze__rulename__c = rn.id;
        r.BREeze__isActive__c = true;
        r.BREeze__order__c = 1;
        r.name = 'Test';
        r.BREeze__field_value_assignment__c = '1234';
        
        insert r;
        
        List<BREeze__Rule_Detail__c> lstRD = new List<BREeze__Rule_Detail__c>();
        BREeze__Rule_Detail__c rd = new BREeze__Rule_Detail__c();
        rd.BREeze__isActive__c = true;
        rd.BREeze__type__c = 'Criteria';
        rd.BREeze__rule__c = r.id;
        rd.BREeze__rule_detail_number__c = 1;
        rd.name = 'Testit';
        rd.BREeze__Field__c = 'Email';
        rd.BREeze__Field_Value__c = 'test@test.com';
        rd.BREeze__Field_Api_Soap_Type__c = 'STRING';
        rd.BREeze__FieldIsPickList__c = false;
        rd.BREeze__Criteria__c = '=';
        insert rd;


        ApexPages.StandardController sc = new ApexPages.StandardController(rn);
        RuleNameTesterExtControllerAddOn testRuleNameTester = new RuleNameTesterExtControllerAddOn(sc);

        System.assertEquals(testRuleNameTester.TestId,l.id);
        testRuleNameTester.runTestForRule();
        boolean temp = testRuleNameTester.positiveResultsOnly;
        boolean temp2 = testRuleNameTester.show;
        
        System.assert(testRuleNameTester.results != 'An Id is required');
	}
		
}