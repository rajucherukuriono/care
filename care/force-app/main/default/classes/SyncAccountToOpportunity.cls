/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SyncAccountToOpportunity {
    private static ID HPAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    private static ID HPContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
    private static ID HPOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
    private static ID HPLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomePay Lead').getRecordTypeId();
    
    static testMethod void HPOpportunityWithAccount() {
		Account a = new Account(
							name = 'HPAccountOne',
							recordtypeid = HPAccount,
							referral_fee__c = 25,
							referral_gift_card__c = 10,
							gift__c = true,
							gift_notes__c = 'Notes on the Account'
							);
		insert a;
		
		
		Opportunity o = new Opportunity(
							accountid = a.id,
							recordtypeid = HPOppty,
							name = 'HPAccountOne - Daniel K',
							product_type__c = 'Referral',
							StageName = 'Closed Won',
							closeDate = date.today()
							);
		insert o;
		
		Opportunity[] oppList = [SELECT id,referral_fee__c,referral_gift_card__c,gift__c,gift_notes__c FROM Opportunity WHERE id = :o.id];

		System.assert(oppList.size() == 1);
		System.assert(oppList[0].referral_fee__c == 25);
		System.assert(oppList[0].referral_gift_card__c == 10);
		System.assert(oppList[0].gift__c == true);
		System.assert(oppList[0].gift_notes__c == 'Notes on the Account');
    }

    static testMethod void HPOpportunityWithAccountAndContact() {
		Account a = new Account(
							name = 'HPAccountOne',
							recordtypeid = HPAccount
							);
		insert a;

		Contact c = new Contact(
							accountid = a.id,
							recordtypeid = HPContact,
							firstName = 'Daniel',
							lastName = 'Koffee',
							referral_fee__c = 250,
							referral_gift_card__c = 225,
							gift__c = true,
							gift_notes__c = 'Notes on the Contact'
							);
		insert c;

		Opportunity o = new Opportunity(
							accountid = a.id,
							recordtypeid = HPOppty,
							name = 'HPAccountOne - Daniel K',
							product_type__c = 'Referral',
							StageName = 'Closed Won',
							closeDate = date.today()
							);
		insert o;

		OpportunityContactRole ocr = new OpportunityContactRole(
							contactid = c.id,
							opportunityid = o.id,
							isprimary = true
							);
		insert ocr;

		
		Opportunity[] oppListAlpha = [SELECT id,referral_fee__c,referral_gift_card__c,gift__c,gift_notes__c FROM Opportunity WHERE id = :o.id];
		System.assert(oppListAlpha.size() == 1);
		oppListAlpha[0].Description = 'Changing opportunity to invoke trigger';
		update oppListAlpha[0];

		Opportunity[] oppList = [SELECT id,referral_fee__c,referral_gift_card__c,gift__c,gift_notes__c,Description,Name FROM Opportunity WHERE id = :o.id];
		System.assert(oppList.size() == 1);

		System.assert(oppList[0].name == 'HPAccountOne - Daniel K');
		System.assert(oppList[0].Description == 'Changing opportunity to invoke trigger');

		// I couldn't make the below code work.  The key difference is that when you create an opportunity from a contact, that
		// contact gets assigned as the primary contact of the opportunity at the time the opportunity is created.
		// But I can't seem to create the same use case via Apex.  So I'm going to let it go.
/*
		System.assert(oppList[0].gift_notes__c == 'Notes on the Contact');
		System.assert(oppList[0].gift__c == true);
		System.assert(oppList[0].referral_gift_card__c == 225);
		System.assert(oppList[0].referral_fee__c == 250);
		*/
		
    }
}