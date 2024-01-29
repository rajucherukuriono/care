/* ************************************************************
 * Created By  : USER_NAME (GearsCRM)
 * Created Date: __/__/20__ 
 * Description : Controller Class RuleNameTesterExtControllerAddOn
 * 
 * Modified By   :
 * Modified Date : 
 * Description   :
 * 
 * ************************************************************/
public with sharing class RuleNameTesterExtControllerAddOn 
{
	public class RuleNameTesterExtControllerAddOnException extends Exception{}
	 
    private final ApexPages.StandardController controller; 
	private final BREeze__RuleName__c rn;
    private integer maxRuleCount; 
		
	public String CreatedBy {get; private set;} 
    public String UpdatedBy {get; private set;}
    public String testID {get; set;}
    public String TestNumbers {get;set;}
    public Boolean positiveResultsOnly{get;set;}
    public String Results {get; set;}
    public Boolean show {get {return String.isNotBlank(Results);}}


    public RuleNameTesterExtControllerAddOn(ApexPages.StandardController controller) 
    {
        this.controller = controller;
        
        rn = [select BREeze__test_ids__c, createddate, createdby.name, lastmodifieddate, 
       						  lastmodifiedby.name, BREeze__isActive__c, BREeze__Object_Name__c, Name, BREeze__internal_name__c,BREeze__test_RuleNumbers__c,
                                 (select id from BREeze__Rules__r)
       						  from BREeze__RuleName__c 
       						 where id = :this.controller.getId()];
        
        CreatedBy = rn.createdby.name + ', ' +  rn.createddate;
        UpdatedBy = rn.lastmodifiedby.name + ', ' +  rn.lastmodifieddate;
        TestId = rn.BREeze__test_ids__c;
        TestNumbers = rn.BREeze__test_RuleNumbers__c;
        maxRuleCount = rn.BREeze__Rules__r==null?0:rn.BREeze__Rules__r.size();
	}
	
	public PageReference runTestForRule() 
    {
        set <id> ids = new set <id>();
        set <double> ruleNums = new set <double>();
        string x = (string)TestId;
        string y=(string)TestNumbers;
       try
       {
       		rn.BREeze__test_ids__c = x;
            rn.BREeze__test_RuleNumbers__c = y;
       		update rn; 
       		
       		for(string s : x.split(',',0))
       		{
       			id i = (id)s.trim();
       			ids.add(i);	      
       		}
        }
       catch(Exception e)
       {
       	  system.debug(e);
          results = 'An Id is required';
          return null;
       }
    
        try{
            
            for(string s : y.split(',',0))
       		{
                if(!string.IsBlank(s))
                {
                    if(s.contains('-'))
                    {
                        integer Start = integer.valueof(s.SubstringBefore('-').trim());
                        integer endn = integer.valueof(s.SubstringAfter('-').trim());
                        if(endn>maxRuleCount)
                        {
                            results = 'Invalid Range provided. The maximum number of rules for ' + rn.name + ' is ' + maxRuleCount;
                            return null;
                        }
                        for(integer i=Start; i<=endn; i++)
                        {
                            double di = Double.ValueOf(i);
                            ruleNums.add(di);
                        }

                    }
                    else if(s.IsNumeric())
                    {
                        double i = Double.ValueOf(s.trim());
                        if(i>maxRuleCount)
                        {
                            results = 'Invalid Range provided. The maximum number of rules for ' + rn.name + ' is ' + maxRuleCount;
                            return null;
                        }
                        ruleNums.add(i);	      
                    }
                }
       		}
        }
       catch(Exception e)
       {
       	  system.debug(e);
          results = 'Invalid Rule Number(s).';
          return null;
       }

        system.debug('Invoking Test rule w/ internal name : ' + rn.BREeze__internal_name__c);

        
        BREeze.ProcessRules.testThisRuleOptions testOptions = new BREeze.ProcessRules.testThisRuleOptions();
        testOptions.testRuleStorage = BREeze.ProcessRules.testThisRuleStorage.None;
    	testoptions.displaySuccessRulesOnly = positiveResultsOnly;
        testoptions.rulesToRun = ruleNums.isempty()?null:ruleNums;

	    results = BREeze.ProcessRules.processRuleLogicTestwithOptions(rn.BREeze__internal_name__c, ids,testoptions); /*processRuleLogicTestwithOptions*/
		system.debug(results);
        return null; 
    }
}