trigger assignSeekerAccountToHomeBaseOpportunities on Opportunity (before insert) {
	// This trigger looks for Home Base Opportunities not linked to an acccount and links them to the Seeker account 
	try {
		for (Opportunity o: Trigger.new){
			if ((o.RecordTypeId == '01270000000HlmbAAC' 				// Home Base Opportunity Record Types 
					|| o.RecordTypeId == '01270000000HlmaAAC' 
					|| o.RecordTypeId == '01270000000HlmZAAS' 
					|| o.RecordTypeId == '01270000000HlmYAAS'
					)	 
				&& o.AccountId == null){			  					// Seeker Member Type
				Account a = [Select Id from Account where AccountId__c = 2 LIMIT 1];
				o.AccountId = a.Id;
/*
				OpportunityContactRole cr = [SELECT id,contactId from OpportunityContactRole where OpportunityId = :o.Id and IsPrimary=true];
				if (cr != null && cr.contactId != null){
					Contact c = [Select id,AccountId from Contact where id = :cr.contactId];
					if (c != null){
						if (a.Id == c.AccountId){ 
							o.AccountId = a.Id;
						}
					}
				}
*/
			}
		}
	} catch (Exception e){	
		System.debug('Generic exception caught when assigning account to opportunity: ' + e.getMessage()); 
	}
}