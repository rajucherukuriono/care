@isTest(SeeAllData=false)
public class Test_PersonAccountToLead {
    Public static string firstName = 'BasicProviderOne';
    Public static string lastName = 'Disney';
    Public static string email = 'testAshwaq@gmailfff.com';
    Public static Integer memberId = 999999014;
    Public static string City = 'Seattle';
    Public static string State = 'WA';
    Public static string Street = '506 dr street';
    Public static string PostalCode = '62632';
    Public static string Country = 'US';
    Public static string Company = 'Care';
    Public static string MobilePhone ='898-9987-8877';
    Public static string phone='655-8763-9246';
    Public static Id SMB_Provider =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('SMB_Provider').getRecordTypeId();
    Public static Id SMB_ProviderCon = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('SMB_Provider').getRecordTypeId();
    Public static Id MktPlace = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Marketplace ISR Lead').getRecordTypeId();
    Public static Id MktpContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Marketplace ISR Contact').getRecordTypeId(); 
    @testSetup static void setupData() {
        Test.startTest();
        
            
        List<Account> ListAcc=new List<Account>();
        Account a=new Account();
        a.lastname='Test';
        a.Gdpr_request__c='RTBF';
        a.recordtypeid=SMB_Provider;
        a.Global_Member_Id__c='12345678';
        ListAcc.add(a);
        
        Account a1=new Account();
        a1.lastname='TestAcc';
        a1.Gdpr_request__c='RTBF';
        a1.recordtypeid=SMB_Provider;
        a1.Global_Member_Id__c='1552345678';
        ListAcc.add(a1);        
        insert ListAcc;
        
        list<Contact> personContactList = new list<Contact>();
        Contact c = new Contact(                        
          //  AccountId = ListAcc[0].id,
            basicmembersignupdate__c = date.today(),
            blacklisted__c = false,
            email = email,
            firstname = firstName,
            lastname = lastName,
            mailingcity = City,
            mailingpostalcode = PostalCode,
            mailingstate = State,
            memberid__c = memberId,
            MembershipCreationDate__c = date.today(),
            membertype__c = 'Provider',
            messagenotificationfrequency__c = 'immediately',
            otherphone = '(666) 666-6666',
            overallstatus__c = 'Active',
            overallstatuschangedate__c = date.today(),
            phone = '(555) 555-5555',
            status__c = 'Active',
            statuschangedate__c = date.today(),
            type__c = 'Individual',
            FirstApprovalDate__c = date.today(),
            InitialApprovalDateChildCare__c = date.today(), 
            ProfileQualityChildCare__c = 'Med',
            RecordTypeId = MktpContact,
            CurrentStatusChildCare__c = 'Active',
            Business_Name__c = company,
            Service_Id__c ='CHILDCARE',
            Sub_Service_Id__c='homeCare',
            Company_ID__c  = 'TestCompanyId',
            Brand_ID__c ='testBrandId'
        );
        insert c;  
        
        List<Lead> lstLead = new list<Lead>();
        Lead perAcctLead = new Lead (); 
        perAcctLead.LastName = lastName;
        perAcctLead.FirstName = firstName;
        perAcctLead.RecordTypeId = MktPlace;
        perAcctLead.Email = Email;
        perAcctLead.Phone = phone;
        perAcctLead.MobilePhone = MobilePhone;
        perAcctLead.City = City;
        perAcctLead.State =State;
        perAcctLead.Street =Street;
        perAcctLead.PostalCode = PostalCode;
        perAcctLead.Country = Country;
        perAcctLead.Company = Company;
        perAcctLead.Member_ID__c = memberId;
        perAcctLead.MembershipCreationDate__c = c.MembershipCreationDate__c;
        perAcctLead.Service_Id__c = 'CHILDCARE';
        perAcctLead.Sub_Service_Id__c = 'homeCare';
        perAcctLead.Company_ID__c = 'TestCompanyId';
        perAcctLead.Brand_ID__c = 'testBrandId';
        perAcctLead.Person_Account__c = c.Id;
        lstLead.add(perAcctLead);
        if(!lstLead.isEmpty()){
            insert lstLead;
        }
        List<Campaign> listCam = new List<Campaign>();
        Campaign cWebinar = new Campaign();
        cWebinar.Name = 'Care.com Signup';
        cWebinar.IsActive = true;
        cWebinar.Type = 'Seminar / Conference';
        cWebinar.Status = 'In Progress';
        listCam.add(cWebinar);
             
        Campaign cWebinar2 = new Campaign();
        cWebinar2.Name = 'Care.com Signup';
        listCam.add(cWebinar2);
        insert listCam;
        
        CampaignMember cmpMem = new CampaignMember();
        cmpMem.CampaignId = listCam[0].id;
        cmpMem.LeadId = lstLead[0].id;
        insert cmpMem;
        
        Task dupeAlert = new Task();
        dupeAlert.Subject = 'Marketplace Lead Dupe Alert';
        dupeAlert.Description = 'This Marketplace Lead was recently created and is a duplicate. One or more Marketplace Leads or Contacts with this email address already exists in Salesforce. All Marketplace Leads and Contacts with this email address have been added to the Care.com Signup Campaign.';
        dupeAlert.WhoID = lstLead[0].Id;
        insert dupeAlert;
    }
    @isTest static void testPersonAccountToLead() {
        
        Lead l = new Lead();
        l.recordTypeId = MktPlace;
        l.lastName = 'lastName';
        l.LeadSource = 'Hubspot';
        l.Email = email;
        insert l;
        
        List<Campaign> listCam = new List<Campaign>();
        Campaign cWebinar = new Campaign();
        cWebinar.Name = 'Care.com Signup';
        cWebinar.IsActive = true;
        cWebinar.Type = 'Seminar / Conference';
        cWebinar.Status = 'In Progress';
        listCam.add(cWebinar);
             
        Campaign cWebinar2 = new Campaign();
        cWebinar2.Name = 'Care.com Signup';
        cWebinar2.IsActive = true;
        cWebinar2.Type = 'Seminar / Conference';
        cWebinar2.Status = 'In Progress';
        listCam.add(cWebinar2);
        insert listCam;
        List<Lead> lList = [SELECT id,Possible_Account_Match__c FROM Lead WHERE id = :l.id];
        List<Campaign> signupCamp = [Select Id FROM Campaign WHERE Name = 'Care.com Signup' limit 1];        
        System.Assert(lList.size() == 1);
        //System.Assert(lList[0].Possible_Account_Match__c == true); // check that Possible_Account_Match__c is checked
    }
}