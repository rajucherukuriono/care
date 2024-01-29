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
private class AssignMiniSiteCampaignToHomePayLeads {

	private static Id HomePayLeadRt =  Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomePay Lead').getRecordTypeId();
    private static Id WPSLeadRt =  Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WPS Lead').getRecordTypeId(); 
    
	private static AssignmentRule AR = [select id from AssignmentRule where Name = 'Lead Assignment Rules' and Active = true limit 1];


    static testMethod void HomePayLeadFromMiniSite_SUCCESS() {
		Campaign c = new Campaign(
				Name = 'HomePay Mini Site',
				IsActive = true,
				Type = 'Advertisement',
				Status = 'In Progress'
			);
		insert c;

        Lead l = new Lead(
        		FirstName = 'First',
        		LastName = 'Last',
        		Company = 'CareCo',
        		Title = 'TestTitle',
        		Phone = '781-642-5984',
        		Email = 'jodell@care.com',
        		Industry = 'Estate Manager',
        		LeadSource = 'Web',
        		Description = 'This is a test lead',
        		Information_sent_to_you__c = true,
        		Information_sent_to_client__c = true,
        		Sign_up_client__c = true,
        		RecordTypeId = HomePayLeadRt
        	);

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		l.setOptions(dmlOpts);				

		insert l;

		Lead[] leadList = [SELECT id from Lead where id = :l.id];
		System.assert(leadList.size() == 1); // the lead exists

		CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
		System.assert(memList.size() == 1); // the lead has been attached to a campaign
		System.assert(memList[0].campaignId == c.id); // the lead has been attached to the HomePayMiniSiteCampaign

    }

    static testMethod void WPSLeadFromMiniSite_FAIL() {
		Campaign c = new Campaign(
				Name = 'HomePay Mini Site',
				IsActive = true,
				Type = 'Advertisement',
				Status = 'In Progress'
			);
		insert c;

        Lead l = new Lead(
        		FirstName = 'First',
        		LastName = 'Last',
        		Company = 'CareCo',
        		Title = 'TestTitle',
        		Phone = '781-642-5984',
        		Email = 'jodell@care.com',
        		Industry = 'Estate Manager',
        		LeadSource = 'Web',
        		Description = 'This is a test lead',
        		Information_sent_to_you__c = true,
        		Information_sent_to_client__c = true,
        		Sign_up_client__c = true,
        		RecordTypeId = WPSLeadRt
        	);

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		l.setOptions(dmlOpts);				

		insert l;

		Lead[] leadList = [SELECT id from Lead where id = :l.id];
		System.assert(leadList.size() == 1); // the lead exists

		CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
		System.assert(memList.size() != 1); // the lead has been attached to a campaign
    }


    static testMethod void HomePayLeadFromTradeShow_FAIL() {
		Campaign c = new Campaign(
				Name = 'HomePay Mini Site',
				IsActive = true,
				Type = 'Advertisement',
				Status = 'In Progress'
			);
		insert c;

        Lead l = new Lead(
        		FirstName = 'First',
        		LastName = 'Last',
        		Company = 'CareCo',
        		Title = 'TestTitle',
        		Phone = '781-642-5984',
        		Email = 'jodell@care.com',
        		Industry = 'Estate Manager',
        		LeadSource = 'Trade Show',
        		Description = 'This is a test lead',
        		Information_sent_to_you__c = true,
        		Information_sent_to_client__c = true,
        		Sign_up_client__c = true,
        		RecordTypeId = HomePayLeadRt
        	);

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		l.setOptions(dmlOpts);				

		insert l;

		Lead[] leadList = [SELECT id from Lead where id = :l.id];
		System.assert(leadList.size() == 1); // the lead exists

		CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
		System.assert(memList.size() != 1); // the lead should NOT be attached to a campaign

    }

    static testMethod void HomePayLeadNotInQueue_FAIL() {
		Campaign c = new Campaign(
				Name = 'HomePay Mini Site',
				IsActive = true,
				Type = 'Advertisement',
				Status = 'In Progress'
			);
		insert c;

        Lead l = new Lead(
        		FirstName = 'First',
        		LastName = 'Last',
        		Company = 'CareCo',
        		Title = 'TestTitle',
        		Phone = '781-642-5984',
        		Email = 'jodell@care.com',
        		Industry = 'Estate Manager',
        		LeadSource = 'Trade Show',
        		Description = 'This is a test lead',
        		Information_sent_to_you__c = true,
        		Information_sent_to_client__c = true,
        		Sign_up_client__c = true,
        		RecordTypeId = HomePayLeadRt
        	);

		insert l;

		Lead[] leadList = [SELECT id from Lead where id = :l.id];
		System.assert(leadList.size() == 1); // the lead exists

		CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
		System.assert(memList.size() != 1); // the lead should NOT be attached to a campaign

    }


}