global class SeniorCareCaseCount_Batch implements Database.Batchable<sObject>{

 	global final String q;
	public static ID scCaseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Care Consult').getRecordTypeId();

    global SeniorCareCaseCount_Batch(){
		q = 'SELECT id,AccountId FROM Case WHERE RecordTypeId = : scCaseRtId AND Account.isPersonAccount = true AND AccountID != NULL Order by CaseNumber desc';		
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(q);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		SeniorCareCaseCount.caseCount(scope,new List<ID>());
    }

    global void finish(Database.BatchableContext BC){
    }
  

}