/*****************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 11/12/2020
Description: Creates test data for use in Contract Composer Unit Tests
Comments:

********************************************************************************************/
@isTest
public class CCCTestDataFactory {

    public static void createUserSystemAdministrator() {
        User systemAdministrator = new User (
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'lastname',
            Email = 'SystemAdministrator_Test@care_unittest.com',
            Username = 'SystemAdministrator_Test@hcare_unittest.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'System Administrator',
            Alias = 'sysadmin',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );

        insert systemAdministrator;
    }

    public static void createSalesOriginationManagerUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Origination Manager'];
        User u = new User(Alias = 'testsom', Email='test_som_profile@caredotcom.com',
            EmailEncodingKey='UTF-8', LastName='Test SOM Profile', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test_som_profile@caredotcom.com');
        insert u;
    }

    public static void createSalesOriginationRepUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Origination Rep'];
        User u = new User(Alias = 'testsop', Email='test_so_profile@caredotcom.com',
            EmailEncodingKey='UTF-8', LastName='Test SO Profile', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test_so_profile@caredotcom.com');
        insert u;
    }

    public static void createContractComposerApiUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Contract Composer API User'];
        User u = new User(Alias = 'testcca', Email='test_ccapi_profile@caredotcom.com',
            EmailEncodingKey='UTF-8', LastName='Test CCAPI Profile', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test_ccapi_profile@caredotcom.com');
        insert u;
    }

    public static void createAccount(String name) {
        Account account = new Account();
        account.Name = name;

        insert account;
    }

    public static void createOpportunity_SalesOrigination(String accountId, String composerServiceId) {
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Origination').getRecordTypeId();

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = 'Test Opportunity - Sales Origination';
        opportunityRecord.AccountId = accountId;
        opportunityRecord.CloseDate = System.today().addMonths(1);
        opportunityRecord.RecordTypeId = recTypeId;
        opportunityRecord.StageName = 'Prospecting';
        opportunityRecord.LeadSource = 'Care.com Lead';
        opportunityRecord.Composer_Service__c = composerServiceId;

        insert opportunityRecord;
    }

    public static void createContact(String accountId, String lastName) {
        Contact contactRecord = new Contact();
        contactRecord.AccountId = accountId;
        contactRecord.LastName = lastName;
        contactRecord.Phone = '5555555555';
        contactRecord.Email = System.currentTimeMillis()+'@salesforce.com';

        insert contactRecord;
    }

    public static void createComposerServiceRecords() {
        List<Composer_Service__c> composerServiceRecords;
        Composer_Service__c composerServiceRecord;
        List<String> composerServiceList;
        String[] composerServiceRecordParts;

        // ############################## Create Composer Service Records ##############################
        // List of Composer Service Records in the following format: vertical:license level:base points:active:tier 1 amount:tier 1 bonus points:tier 2 amount:tier 2 bonus points:tier 3 amount:tier 3 bonus points:tier 4 amount:tier 4 bonus points:tier 5 amount:tier 5 bonus points:tier custom threshold:tuition discount bonus points
        composerServiceList = new List<String>();
        composerServiceList.add('Senior Care:Housing:6.0:true:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Senior Care:Home Care:5.0:true:300:2:400:3:500:4:600:5:700:6:800:4');
        composerServiceList.add('Senior Care:Adult Day Care:7.0:true:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Senior Care:Adult Day Care:7.0:false:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Childcare:Activities:4.0:true:300:1:400:6:500:9:600:12:700:12:800:4');
        composerServiceList.add('Childcare:Camps:5.0:true:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Childcare:Centers:4.0:true:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Childcare:FCCs:7.0:true:350:2:450:2:550:2:650:2:750:2:850:4');
        composerServiceList.add('Childcare:Nanny Agencies:3.0:true:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceList.add('Childcare:Nanny Agencies:3.0:false:300:1:400:2:500:3:600:4:700:5:800:4');
        composerServiceRecords = new List<Composer_Service__c>();

        for (String composerService: composerServiceList) {
            composerServiceRecordParts = composerService.split(':');

            composerServiceRecord = new Composer_Service__c();
            composerServiceRecord.Vertical__c = composerServiceRecordParts[0];
            composerServiceRecord.License_Level__c = composerServiceRecordParts[1];
            composerServiceRecord.Base_Points__c = Decimal.valueOf(composerServiceRecordParts[2]);
            composerServiceRecord.Active__c = (composerServiceRecordParts[3] == 'true');
            composerServiceRecord.Tier_1_Amount__c = Decimal.valueOf(composerServiceRecordParts[4]);
            composerServiceRecord.Tier_1_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[5]);
            composerServiceRecord.Tier_2_Amount__c = Decimal.valueOf(composerServiceRecordParts[6]);
            composerServiceRecord.Tier_2_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[7]);
            composerServiceRecord.Tier_3_Amount__c = Decimal.valueOf(composerServiceRecordParts[8]);
            composerServiceRecord.Tier_3_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[9]);
            composerServiceRecord.Tier_4_Amount__c = Decimal.valueOf(composerServiceRecordParts[10]);
            composerServiceRecord.Tier_4_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[11]);
            composerServiceRecord.Tier_5_Amount__c = Decimal.valueOf(composerServiceRecordParts[12]);
            composerServiceRecord.Tier_5_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[13]);
            composerServiceRecord.Tier_Custom_Threshold__c = Decimal.valueOf(composerServiceRecordParts[14]);
            composerServiceRecord.Tuition_Discount_Bonus_Points__c = Decimal.valueOf(composerServiceRecordParts[15]);

            composerServiceRecords.add(composerServiceRecord);
        }

        insert composerServiceRecords;
    }

    public static void createOpportunityServiceAreas(String opportunityId) {
        List<Opportunity_Service_Area__c> opportunityServiceAreaRecords;
        List<String> serviceAreaList;
        Opportunity_Service_Area__c opportunityServiceAreaRecord;
        String[] serviceAreaParts;

        // ############################## Create Opportunity Service Areas ##############################
        // List of Service Area data in the following format: name:amount:pricingTier:phone:street:city:state:postalCode:postalCodesCSV
        serviceAreaList = new List<String>();
        serviceAreaList.add('Service Area 1 - Marion County:300:Tier 1:3175079497:5875 Castle Creek Pkwy N Dr #300:Indianpolis:IN:46250:46107,46183,46201,46202,46203,46204,46205,46208,46214,46216,46217,46218,46219,46220,46221,46222,46224,46225,46226,46227,46228,46229,46231,46234,46235,46236,46237,46239,46240,46241,46250,46254,46256,46259,46260,46268,46278');
        serviceAreaList.add('Service Area 2 - Hamilton County:400:Tier 2:3175712400:1 Civic Square:Carmel:IN:46032:46030,46031,46032,46033,46034,46037,46038,46060,46062,46069,46079,46280,46290');
        serviceAreaList.add('Service Area 3 - Johnson County:900:Custom:3177365000:5 E Jefferson St.:Franklin:IN:46131:46106,46124,46131,46142,46143,46162,46164,46181,46184');

        opportunityServiceAreaRecords = new List<Opportunity_Service_Area__c>();
        for (String serviceArea: serviceAreaList) {
            serviceAreaParts = serviceArea.split(':');

            opportunityServiceAreaRecord = new Opportunity_Service_Area__c();
            opportunityServiceAreaRecord.Opportunity__c = opportunityId;
            opportunityServiceAreaRecord.Name = serviceAreaParts[0];
            opportunityServiceAreaRecord.Advertising_Spend__c = Decimal.valueOf(serviceAreaParts[1]);
            opportunityServiceAreaRecord.Pricing_Tier__c = serviceAreaParts[2];
            opportunityServiceAreaRecord.Phone__c = serviceAreaParts[3];
            opportunityServiceAreaRecord.Street__c = serviceAreaParts[4];
            opportunityServiceAreaRecord.City__c = serviceAreaParts[5];
            opportunityServiceAreaRecord.State__c = serviceAreaParts[6];
            opportunityServiceAreaRecord.Postal_Code__c = serviceAreaParts[7];
            opportunityServiceAreaRecord.Postal_Codes__c = serviceAreaParts[8];

            opportunityServiceAreaRecords.add(opportunityServiceAreaRecord);
        }

        insert opportunityServiceAreaRecords;
    }

    public static void createOpportunityLocationService(String locationId, String composerServiceId, String tier, Decimal spend) {

        Opportunity_Location_Service__c locationService = new Opportunity_Location_Service__c();
        locationService.Opportunity_Service_Area__c = locationId;
        locationService.Composer_Service__c = composerServiceId;
        locationService.Pricing_Tier__c = tier;
        locationService.Advertising_Spend__c = spend;

        insert locationService;
    }

	public static void createOpportunityContactRole(String contactId, String opportunityId) {
		OpportunityContactRole opportunityContactRoleRecord = new OpportunityContactRole();
		opportunityContactRoleRecord.ContactId = contactId;
		opportunityContactRoleRecord.OpportunityId = opportunityId;

		insert opportunityContactRoleRecord;
	}

}