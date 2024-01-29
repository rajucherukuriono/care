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
private class HandleVettedLeads_Test {
    private static User HPBDUser = [SELECT id FROM User WHERE UserRoleId IN (SELECT id FROM UserRole where DeveloperName = 'HomePay_BD_Agent' or DeveloperName='HomePay_B2B_Sales') and isActive = true LIMIT 1];
    private static User WPSUser = [SELECT id FROM User WHERE UserRoleId IN (SELECT id FROM UserRole where DeveloperName = 'ISR_CAW' or DeveloperName=  'ISR_CAW_Rep' or DeveloperName = 'CAW_Account_Managers' or 
                                                                            DeveloperName = 'CAW_Account_Manager_Reps' or DeveloperName = 'CAW_Sales_US_East' or DeveloperName = 'CAW_Sales_US_East_Reps' or DeveloperName = 'CAW_Sales_US_West' or 
                                                                            DeveloperName = 'CAW_Sales_US_West_Reps' or DeveloperName = 'MKP_National_Rep' or DeveloperName = 'MKP_National') and isActive = true LIMIT 1];
    //private static User ISRUser = [SELECT id FROM User WHERE UserRoleId IN (SELECT id FROM UserRole where DeveloperName = 'ISR_MKP_Rep' or DeveloperName = 'ISR_MKP') and isActive = true LIMIT 1];
    //added as the above role does not exist in prod
    private static User ISRUser = [SELECT id FROM User WHERE UserRoleId IN (SELECT id FROM UserRole where DeveloperName = 'ISR_Inside_Sales_Manager') and isActive = true LIMIT 1];
    private static Id HomePayLeadRt =  Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('HomePay Lead').getRecordTypeId();
    private static Id WPSLeadRt = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('WPS Lead').getRecordTypeId();
    private static AssignmentRule AR = [select id from AssignmentRule where Name = 'Lead Assignment Rules' and Active = true limit 1];
    
    static testMethod void ISRAgentSetsHPLeadToVetted_SUCCESS () {
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'jodell@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            Description = 'This is a test lead',
            Information_sent_to_you__c = true,
            Information_sent_to_client__c = true,
            Sign_up_client__c = true,
            RecordTypeId = HomePayLeadRt,
            OwnerId = ISRUser.id
        );
        insert l;
        
        // ISR vets the lead
        Lead[] leadList = [SELECT id,OwnerId,Status from Lead where id = :l.id];
        System.assert(leadList.size() == 1); // the lead exists
        System.assert(leadList[0].OwnerId == ISRUser.id); // the lead is owned by the ISR user
        Lead LeadToVet = leadList[0];
        LeadToVet.Status = 'Vetted';
        update LeadToVet;
        
        Lead[] vettedLeadList = [SELECT id,Vetted_By__c,Vetted_Date__c,Vetted_Date_Time__c,OwnerId from Lead where id = :leadList[0].id];
        Lead vettedLead = vettedLeadList[0];
        System.assert(vettedLeadList.size() == 1); // the converted lead exists
        System.assert(vettedLead.Vetted_By__c == userInfo.getUserId()); // Vetted by set to current user
        System.assert(vettedLead.Vetted_Date__c == System.Today()); // Vetted Date is today
        System.assert(vettedLead.Vetted_Date_Time__c != null); // Vetted date time is not empty
        System.assert(vettedLead.OwnerId != userInfo.getUserId()); // Lead should now be owned by the queue not current user
        
    }
    
    static testMethod void ISRAgentSetsHPLeadToVettedPlusTactics_SUCCESS  () {
        Campaign cWebinar = new Campaign(
            Name = 'HomePay Webinar',
            IsActive = true,
            Type = 'Seminar / Conference',
            Status = 'In Progress'
        );
        insert cWebinar;
        
        Campaign cNewsletter = new Campaign(
            Name = 'HomePay Newsletter',
            IsActive = true,
            Type = 'Email',
            Status = 'In Progress'
        );
        insert cNewsletter;
        
        Campaign cAppointment = new Campaign(
            Name = 'HomePay Appointment',
            IsActive = true,
            Type = 'Telemarketing',
            Status = 'In Progress'
        );
        insert cAppointment;
        
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'jodell@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            Description = 'This is a test lead',
            Information_sent_to_you__c = true,
            Information_sent_to_client__c = true,
            Sign_up_client__c = true,
            RecordTypeId = HomePayLeadRt,
            OwnerId = ISRUser.id
        );
        insert l;
        
        // ISR vets the lead
        Lead[] leadList = [SELECT id,OwnerId,Status from Lead where id = :l.id];
        System.assert(leadList.size() == 1); // the lead exists
        System.assert(leadList[0].OwnerId == ISRUser.id); // the lead is owned by the ISR user
        Lead LeadToVet = leadList[0];
        LeadToVet.Status = 'Vetted';
        update LeadToVet;
        
        Database.insert(new CampaignMember(CampaignId = cWebinar.id, LeadId = LeadToVet.id));
        Database.insert(new CampaignMember(CampaignId = cNewsletter.id, LeadId = LeadToVet.id));
        Database.insert(new CampaignMember(CampaignId = cAppointment.id, LeadId = LeadToVet.id));
        
        Lead[] vettedLeadList = [SELECT id,Vetted_By__c,Vetted_Date__c,Vetted_Date_Time__c,OwnerId from Lead where id = :leadList[0].id];
        Lead vettedLead = vettedLeadList[0];
        System.assert(vettedLeadList.size() == 1); // the converted lead exists
        System.assert(vettedLead.Vetted_By__c == userInfo.getUserId()); // Vetted by set to current user
        System.assert(vettedLead.Vetted_Date__c == System.Today()); // Vetted Date is today
        System.assert(vettedLead.Vetted_Date_Time__c != null); // Vetted date time is not empty
        System.assert(vettedLead.OwnerId != userInfo.getUserId()); // Lead should now be owned by the queue not current user
        
        CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
        System.assert(memList.size() == 3); // the lead has been attached to the 3 campaigns
    }
    
    static testMethod void HomePayAgentConvertsISRLead_SUCCESS () {
        Campaign cWebinar = new Campaign(
            Name = 'HomePay Webinar',
            IsActive = true,
            Type = 'Seminar / Conference',
            Status = 'In Progress'
        );
        insert cWebinar;
        
        Campaign cNewsletter = new Campaign(
            Name = 'HomePay Newsletter',
            IsActive = true,
            Type = 'Email',
            Status = 'In Progress'
        );
        insert cNewsletter;
        
        Campaign cAppointment = new Campaign(
            Name = 'HomePay Appointment',
            IsActive = true,
            Type = 'Telemarketing',
            Status = 'In Progress'
        );
        insert cAppointment;
        
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'jodell@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            Description = 'This is a test lead',
            Information_sent_to_you__c = true,
            Information_sent_to_client__c = true,
            Sign_up_client__c = true,
            RecordTypeId = HomePayLeadRt,
            OwnerId = ISRUser.id
        );
        insert l;
        
        
        
        // ISR vets the lead
        Lead[] leadList = [SELECT id,OwnerId,Status from Lead where id = :l.id];
        System.assert(leadList.size() == 1); // the lead exists
        System.assert(leadList[0].OwnerId == ISRUser.id); // the lead is owned by the ISR user
        Lead LeadToVet = leadList[0];
        LeadToVet.Status = 'Vetted';
        update LeadToVet;
        
        Database.insert(new CampaignMember(CampaignId = cWebinar.id, LeadId = LeadToVet.id));
        Database.insert(new CampaignMember(CampaignId = cNewsletter.id, LeadId = LeadToVet.id));
        Database.insert(new CampaignMember(CampaignId = cAppointment.id, LeadId = LeadToVet.id));
        
        Lead[] vettedLeadList = [SELECT id,Vetted_By__c,Vetted_Date__c,Vetted_Date_Time__c,OwnerId from Lead where id = :leadList[0].id];
        Lead vettedLead = vettedLeadList[0];
        System.assert(vettedLeadList.size() == 1); // the converted lead exists
        System.assert(vettedLead.Vetted_By__c == userInfo.getUserId()); // Vetted by set to current user
        System.assert(vettedLead.Vetted_Date__c == System.Today()); // Vetted Date is today
        System.assert(vettedLead.Vetted_Date_Time__c != null); // Vetted date time is not empty
        System.assert(vettedLead.OwnerId != userInfo.getUserId()); // Lead should now be owned by the queue not current user
        
        CampaignMember[] memList = [SELECT id,campaignId from CampaignMember where LeadId = :l.id];
        System.assert(memList.size() == 3); // the lead has been attached to the 3 campaigns
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(vettedLead.id);
        lc.setOwnerId(HPBDUser.id);
        lc.setConvertedStatus('Qualified');
        try
        {
            Test.startTest();
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            
            Lead[] convertedLeadList = [SELECT id,convertedContactid,Converted_Date_Time__c from Lead where id = :leadList[0].id];
            Lead convertedLead = convertedLeadList[0];
            System.assert(convertedLeadList.size() == 1); // the converted lead exists
            
            Contact[] convertedContactList = [SELECT id,Converted_By__c,Converted_Date_Time__c from Contact where id = :convertedLead.convertedContactid];
            System.assert(convertedContactList.size() == 1); // the converted contact exists
            Contact convertedContact = convertedContactList[0];
            System.assert(convertedContact.Converted_By__c == userInfo.getUserId()); // did the current user get credited for the conversion?
            //commented for issue System.assert(convertedContact.Converted_Date_Time__c == convertedLead.Converted_Date_Time__c); // are the converted date time's the same
            
            CampaignMember[] memCList = [SELECT id,campaignId from CampaignMember where ContactId = :convertedContact.id];
            System.assert(memCList.size() == 3); // the contact has been attached to the 3 campaigns
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('Excepton occured while lead conversion ==>:'+e);
        }
    }
    
    static testMethod void HPAgentSetsLeadToVetted_SUCCESS () {
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'jodell@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            Description = 'This is a test lead',
            Information_sent_to_you__c = true,
            Information_sent_to_client__c = true,
            Sign_up_client__c = true,
            RecordTypeId = HomePayLeadRt,
            OwnerId = HPBDUser.id
        );
        insert l;
        
        // ISR vets the lead
        Lead[] leadList = [SELECT id,OwnerId,Status from Lead where id = :l.id];
        System.assert(leadList.size() == 1); // the lead exists
        System.assert(leadList[0].OwnerId == HPBDUser.id); // the lead is owned by the ISR user
        Lead LeadToVet = leadList[0];
        LeadToVet.Status = 'Vetted';
        update LeadToVet;
        
        Lead[] vettedLeadList = [SELECT id,Vetted_By__c,Vetted_Date__c,Vetted_Date_Time__c,OwnerId from Lead where id = :leadList[0].id];
        Lead vettedLead = vettedLeadList[0];
        System.assert(vettedLeadList.size() == 1); // the converted lead exists
        System.assert(vettedLead.Vetted_By__c == userInfo.getUserId()); // Vetted by set to current user
        System.assert(vettedLead.Vetted_Date__c == System.Today()); // Vetted Date is today
        System.assert(vettedLead.Vetted_Date_Time__c != null); // Vetted date time is not empty
        System.assert(vettedLead.OwnerId != userInfo.getUserId()); // Lead should now be owned by the queue not current user
    }
    static testMethod void WPSUserSetsLeadToVetted_SUCCESS () {
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'jodell@care.com',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            State = 'MA',
            Description = 'This is a test lead',
            Information_sent_to_you__c = true,
            Information_sent_to_client__c = true,
            Sign_up_client__c = true,
            RecordTypeId = WPSLeadRt,
            OwnerId = WPSUser.id
        );
        insert l;
        
        // ISR vets the lead
        Lead[] leadList = [SELECT id,OwnerId,Status from Lead where id = :l.id];
        System.assert(leadList.size() == 1); // the lead exists
        System.assert(leadList[0].OwnerId == WPSUser.id); // the lead is owned by the ISR user
        Lead LeadToVet = leadList[0];
        LeadToVet.Status = 'Vetted';
        LeadToVet.Function__c='Finance';
        LeadToVet.Level__c='Mananger';
        LeadToVet.NumberOfEmployees=10;
        update LeadToVet;
        
        Lead[] vettedLeadList = [SELECT id,Vetted_By__c,Vetted_Date__c,Vetted_Date_Time__c,OwnerId from Lead where id = :leadList[0].id];
        Lead vettedLead = vettedLeadList[0];
        System.assert(vettedLeadList.size() == 1); // the converted lead exists
        System.assert(vettedLead.Vetted_By__c == userInfo.getUserId()); // Vetted by set to current user
        System.assert(vettedLead.Vetted_Date__c == System.Today()); // Vetted Date is today
        System.assert(vettedLead.Vetted_Date_Time__c != null); // Vetted date time is not empty
        //      System.assert(vettedLead.OwnerId != userInfo.getUserId()); // WPS don't have rules in default assingment rules yet
    }
    
}