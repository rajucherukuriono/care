// Created by: Eustace Consulting [Developer: Jennifer Blair]
// Description: This class will go through a batch  of Contacts and transform them into Person Accounts by creating a stub Account
//  for each Contact, linking the Contact to the stub Account, then updating the Account's record type to the appropriate Person Account Record Type.
global class BatchConvertContactsToPersonAccts implements Schedulable, Database.Batchable<sObject>{
	public String query;
	
	global void execute(SchedulableContext SC) {
		BatchConvertContactsToPersonAccts b = new BatchConvertContactsToPersonAccts();
	   	b.query = 'SELECT id, accountId, recordTypeId, OwnerId, MemberID__c FROM Contact where Account.AccountId__c in (1,2,3,4,5,6) and IsPersonAccount = false and CreatedDate >= 2008-01-01T00:00:00Z and CreatedDate <= 2009-12-31T00:00:00';
	   	ID batchprocessid = Database.executeBatch(b, 100);   
	}
    
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){

    	//collect all Contacts into a map
    	Map<id, Contact> conMap = new Map<id, Contact>();
    	system.debug('###Num Contacts in this batch: ' + scope.size());
    	
    	for(sObject s : scope){
            Contact con = (Contact)s;
            for (RecordType rt : getRecordTypesStatic.conRecordTypes) {
            	if (con.RecordTypeId == rt.id) {
            		conMap.put(con.id, con);
            	}
            }
    	}
    	
    	//create & insert accounts
    	List<Account> acctInsertList = new List<Account>();
		for (Contact con : conMap.values()){
			String memID = null;
			if (con.MemberID__c != null) {
				memID = String.valueOf(con.MemberID__c);
				if (memID.contains('.0')) memID = memID.replace('.0', '');
			}
			Account a = new Account(Name = 'Temp', OwnerId = con.OwnerId, MemberID__c = memID);
			acctInsertList.add(a);
		}
		
		insert acctInsertList;
		
		Set<Id> acctIds = new Set<Id>();
		for (Account a : acctInsertList) {
			acctIds.add(a.id);
		}
		
		//set accountId of Contact record
		Integer i = 0;
		for (Contact con : conMap.values()){
			con.accountId = acctInsertList[i].id;
			i++;	
		}
		
		//use database.update() for partial processing in case of an error with one value in the list (i.e. row lock)
		Database.update(conMap.values(), false); 
		
		//create maps to match up record types between contact and account
		Map<String, Id> paRTMap = new Map<String, Id>();
		for (RecordType rt : getRecordTypesStatic.persAcctRecTypes) {
			paRTMap.put(rt.DeveloperName, rt.id);
		}
		Map<Id, String> conRTMap = new Map<Id, String>();
		for (RecordType rt : getRecordTypesStatic.conRecordTypes) {
			conRTMap.put(rt.id, rt.DeveloperName);
		}
		
		//query & update account records
		List<Account> acctUpdateList = new List<Account>();
	    Map<Id, Account> acctMap = new Map<Id, Account>([SELECT id FROM Account WHERE id in: acctIds]);
		for (Contact con : conMap.values()){
			if (acctMap.containsKey(con.AccountId)) {
				Account a = acctMap.get(con.AccountId);
				a.RecordTypeId = paRTMap.get(conRTMap.get(con.RecordTypeId));
				acctUpdateList.add(a);
			}
		}
		update acctUpdateList;
		
		//collect ids of accounts with no related Contact - they are junk and need to be deleted
		List<Account> acctsToDel = new List<Account>();
		for (Account a : acctMap.values()){
			Boolean match = false;
			for (Contact con : conMap.values()){
				if (con.AccountId == a.id) {
					match = true;
				}
			}
			if (!match) {
				acctsToDel.add(a);
			}
		}
		
		//delete junk stub Accounts
		if (acctsToDel.size() > 0) delete acctsToDel;
    	
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.  
        // Query the AsyncApexJob object to retrieve the current job's information.  
    
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus, 
            TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
    
        // Send an email to the Apex job's submitter notifying of job completion (only if error) 
        //if (a.NumberOfErrors > 0) {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {a.CreatedBy.Email, 'jen@eustaceconsulting.com'};
	        mail.setToAddresses(toAddresses);
	        mail.setSubject('Convert Contacts to Person Accounts Batch Job Results: ' + a.Status);
	        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n' + a.ExtendedStatus);
			if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
    }

}