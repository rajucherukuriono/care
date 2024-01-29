trigger SyncAccountToOpportunity on Opportunity (after insert,before update) {
	// This trigger is responsible for copying items from the Account or Contact to the Opportunity when the Opportunity is first created or updated.
	// The trigger was originally created in 2013.12.16 as part of the HomePay project.
	// Use Cases Covered:
	//		* Gift__c, Referral_Fee__c, Referral_Gift_Card__c,Gift_Notes__c
				
	// For future consideration: if it becomes critical to identify whether the Contact associated with the opportunity has changed, 
	// I'll need to build an OppConMap from trigger.oldMap 

	// Context: after insert and before update.  Since this trigger aims to update the opportunity, ideally
	// 		it should run on the before contexts.  However, since the trigger also aims to copy fields from 
	//		related objects, it is critical that we have the Id of the opportunity available (those ids are not available in beforeinsert).
	// 		Therefore, the trigger is defined to run on afterinsert and beforeupdate.
	//		Some logic is provided to execute "update" statements on the afterinsert context.

    Map<Id, Account> AccountsMap = new Map<Id, Account>([SELECT id,AccountSource,Gift__c,Referral_Fee__c,Referral_Gift_Card__c,Gift_Notes__c FROM Account WHERE id IN (SELECT AccountId from Opportunity WHERE id IN :trigger.newMap.keyset())]);
    Map<Id, Opportunity> OpportunitiesMap = new Map<Id, Opportunity>([SELECT id,AccountId,Gift__c,Referral_Fee__c,Referral_Gift_Card__c,Gift_Notes__c,Description FROM Opportunity WHERE id IN :trigger.newMap.keyset()]);

	// The following code sets up a Map called OppConMap which will return the primaryContact of an opportunity given the opportunity Id
    Map<Id, OpportunityContactRole> OppConRolesMap = new Map<Id, OpportunityContactRole>([SELECT id,ContactId,OpportunityId FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId IN :trigger.newMap.keyset()]);
    Set<Id> ContactIdsSet = new Set<Id>();
	for (OpportunityContactRole ocr : OppConRolesMap.values()){
		ContactIdsSet.add(ocr.ContactId);
	}
	Map<Id, Contact> ContactsMap = new Map<Id,Contact>([SELECT id,Gift__c,Referral_Fee__c,Referral_Gift_Card__c,Gift_Notes__c FROM Contact WHERE id IN :ContactIdsSet]);
	Map<Id, Contact> OppConMap = new Map<Id,Contact>();
	for (OpportunityContactRole ocr : OppConRolesMap.values()){
		OppConMap.put(ocr.opportunityId,ContactsMap.get(ocr.ContactId));
	}
	Set<sObject> objectsToUpdateTrigger = new Set<sObject>(); 
	
	for (Opportunity o: OpportunitiesMap.values()){

		Account a = AccountsMap.get(o.AccountId); // account associated with the opportunity
		Contact c = OppConMap.get(o.id); // primary contact associated with the opportunity
		
		if (!o.Gift__c){
			if (c != null && c.Gift__c) o.Gift__c = c.Gift__c;
			else if (a != null && a.Gift__c) o.Gift__c = a.Gift__c;
		}

		if (null == o.Referral_Fee__c){
			if (c != null && null != c.Referral_Fee__c) o.Referral_Fee__c = c.Referral_Fee__c;
			else if (a != null && null != a.Referral_Fee__c) o.Referral_Fee__c = a.Referral_Fee__c;
		}

		if (null == o.Referral_Gift_Card__c){
			if (c != null && null != c.Referral_Gift_Card__c) o.Referral_Gift_Card__c = c.Referral_Gift_Card__c;
			else if (a != null && null != a.Referral_Gift_Card__c) o.Referral_Gift_Card__c = a.Referral_Gift_Card__c;
		}
		
	
		if (String.isBlank(o.Gift_Notes__c)){
			if (c != null && !String.isBlank(c.Gift_Notes__c)) o.Gift_Notes__c = c.Gift_Notes__c;
			else if (a != null && !String.isBlank(a.Gift_Notes__c)) o.Gift_Notes__c = a.Gift_Notes__c;
		}

		if (Trigger.isAfter && Trigger.isInsert) objectsToUpdateTrigger.add(o);
	}

	List<sObject> objectsToUpdateList = new List<sObject>();
	objectsToUpdateList.addAll(objectsToUpdateTrigger); // convert set to list to pass to update statement;
	update objectsToUpdateList;
}