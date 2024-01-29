// Created by: Eustace Consulting [Developer: Jennifer Blair]
// Description: This class will go through Person Accounts and transforms them back into Contacts under specific 
//  Business Account records based on Record Type.
global class BatchUnconvertPersonAccts implements Schedulable, Database.Batchable<sObject>{
	public String query;
	
	global void execute(SchedulableContext SC) {
		BatchUnconvertPersonAccts b = new BatchUnconvertPersonAccts();
	   	b.query = 'SELECT id, RecordTypeId FROM Account where MemberId__pc < 49000 and IsPersonAccount = true and (RecordTypeId = \'' + getRecordTypesStatic.persAcctRecTypes[0].id + '\' or RecordTypeId = \'' + getRecordTypesStatic.persAcctRecTypes[1].id + '\' or RecordTypeId = \'' + getRecordTypesStatic.persAcctRecTypes[2].id + '\' or RecordTypeId = \'' + getRecordTypesStatic.persAcctRecTypes[3].id + '\')';
	   	ID batchprocessid = Database.executeBatch(b, 100);   
	}
    
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	//create maps to match up record types between contact and account
		Map<Id, String> paRTMap = new Map<Id, String>();
		for (RecordType rt : getRecordTypesStatic.persAcctRecTypes) {
			paRTMap.put(rt.id, rt.DeveloperName);
		}
		Map<String, Id> conRTMap = new Map<String, Id>();
		for (RecordType rt : getRecordTypesStatic.conRecordTypes) {
			conRTMap.put(rt.DeveloperName, rt.id);
		}

    	//collect all Accounts into a map
    	Map<id, Account> acctMap = new Map<id, Account>();
    	Map<Id, Id> acctToRTMap = new Map<Id, Id>();
    	system.debug('###Num Accounts in this batch: ' + scope.size());
    	
    	for(sObject s : scope){
            Account a = (Account)s;
            acctMap.put(a.id, a);
            acctToRTMap.put(a.id, a.RecordTypeId);
    	}
    	
    	//get Contacts related to Accounts
    	Map<Id, Contact> conMap = new Map<Id, Contact>([select id, RecordTypeId, AccountId from Contact where AccountId in: acctMap.keySet()]);
    	
    	//update Account record type to business account
    	List<Account> acctUpdateList = new List<Account>();
		for (Account a : acctMap.values()){
			a.RecordTypeId = getRecordTypesStatic.busAcctRecType;
			acctUpdateList.add(a);
		}
		if (acctUpdateList.size() > 0) update acctUpdateList;
		
		
		//get preset Accounts
		Map<String, Id> presetMap = new Map<String, Id>();
		for (Account a : [Select Id, Name from Account where isPersonAccount = false and (AccountId__c = 1 or AccountId__c = 2 or AccountId__c = 5 or AccountId__c = 6)]) {
			presetMap.put(a.Name, a.id);
		}
		
		//go through Contacts, reset the RecordType and move it under the appropriate preset Account
		List<Contact> conUpdateList = new List<Contact>();
		for (Contact c : conMap.values()) {
			 c.RecordTypeId = conRTMap.get(paRTMap.get(acctToRTMap.get(c.AccountId)));
			 c.AccountId = presetMap.get(paRTMap.get(acctToRTMap.get(c.AccountId)));
			 conUpdateList.add(c);
		}
		if (conUpdateList.size() > 0) update conUpdateList;
		
		//delete useless stub Accounts
		if (acctUpdateList.size() > 0) delete acctUpdateList;
    	
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.  
        // Query the AsyncApexJob object to retrieve the current job's information.  
    
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus, 
            TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
    
        // Send an email to the Apex job's submitter notifying of job completion (only if error) 
        if (a.NumberOfErrors > 0) {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {a.CreatedBy.Email, 'jen@eustaceconsulting.com'};
	        mail.setToAddresses(toAddresses);
	        mail.setSubject('Unconvert Person Accounts Batch Job Results: ' + a.Status);
	        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n' + a.ExtendedStatus);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}