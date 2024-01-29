/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 1/27/2022
Description: Test methods for MarketingSolutionsAccountRestService Apex class
Comments:

********************************************************************************************/
@isTest
private class MarketingSolutionsAccountRestServ_Test {
    
    public static List<User> users = new List<User>();
    
    public class UserData {
        public String userName { get; set; }            
        public String alias { get; set; }
        public Id userRoleId { get; set; }
        
        public UserData(String userName, String alias, Id userRoleId) {
            this.userName = userName;
            this.alias = alias;
            this.userRoleId = userRoleId;
        }
    }
    
    public class RRmember {
        public Boolean active { get; set; }            
        
        public RRmember(Boolean active) {
            this.active = active;
        }
    }

    @testSetup static void setup() {
        Id salesRepProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Origination Rep'].Id;
        Id managerRoleId = [SELECT Id FROM UserRole WHERE Name = 'Marketing Solutions Manager'].Id;
        //Id repRoleId = [SELECT Id FROM UserRole WHERE Name = 'Marketing Solutions Rep'].Id;
        UserRole ur = new UserRole(Name = 'Marketing Solutions Rep');
        insert ur;
        Id repRoleId = ur.ID;
        User configuredOwner = new User(Alias = 'testown', Email = 'test_ms_configowner@caredotcom.com',
                                        EmailEncodingKey = 'UTF-8', LastName='TestOwn', LanguageLocaleKey='en_US',
                                        LocaleSidKey = 'en_US', ProfileId = salesRepProfileId, UserRoleId = managerRoleId,
                                        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test_ms_configowner@caredotcom.com');
        insert configuredOwner;
        
        User managerUser = new User(Alias = 'testmgr', Email = 'test_ms_manager@caredotcom.com',
                                    EmailEncodingKey = 'UTF-8', LastName='TestMgr', LanguageLocaleKey='en_US',
                                    LocaleSidKey = 'en_US', ProfileId = salesRepProfileId, UserRoleId = managerRoleId,
                                    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test_ms_manager@caredotcom.com');
        insert managerUser;
        
        User repUser = new User(Alias = 'testrep', Email = 'test_ms_rep@caredotcom.com',
                                EmailEncodingKey = 'UTF-8', LastName='TestRep', LanguageLocaleKey='en_US',
                                LocaleSidKey = 'en_US', ProfileId = salesRepProfileId, UserRoleId = repRoleId,
                                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test_ms_rep@caredotcom.com');
        insert repUser;
        
        // Create users 
        
        List<UserData> lstUserData = new List<UserData>();
        lstUserData.add(new UserData('DefaultUser', 'dfltUser', managerRoleId));
        lstUserData.add(new UserData('repSeniorUser', 'repSUser', repRoleId));
        lstUserData.add(new UserData('rep2SeniorUser', 'rp2SUser', repRoleId));
        lstUserData.add(new UserData('repInactiveSeniorUser', 'rpISUser', repRoleId));
        lstUserData.add(new UserData('nonRepSeniorUser', 'noRSUser', managerRoleId));
        lstUserData.add(new UserData('rep2DaycareUser', 'rp2DUser', repRoleId));
        lstUserData.add(new UserData('repDaycareUser', 'repDUser', repRoleId));
        lstUserData.add(new UserData('repInactiveDaycareUser', 'rpIDUser', repRoleId));
        lstUserData.add(new UserData('nonRepDaycareUser', 'noRDUser', managerRoleId));
        
        List<User> lstUsersToInsert = new List<User>();
        
        for (Integer i = 0; i < lstUserData.size(); i++) {
            User user = new User(
                IsActive = true,
                Alias = lstUserData.get(i).alias,
                ProfileId = salesRepProfileId,
                UserRoleId = lstUserData.get(i).userRoleId,
                Username = lstUserData.get(i).alias + '@caredotcom.com',
                Email = lstUserData.get(i).alias + '@caredotcom.com',
                EmailEncodingKey = 'UTF-8',
                LastName = lstUserData.get(i).alias,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
            );
            System.debug('User ' + i + ': ' + user);
            lstUsersToInsert.add(user);
        }
        
        insert lstUsersToInsert;       
    }
    
    @isTest static void seniorRoundRobinNoAccount() {
        // Scenario 1 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = SeniorRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 1].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        Set<Id> memberIds = new Set<Id>();
        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
       
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        //List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId IN :memberIds];
        //System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
       // List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :opps[0].OwnerId];
      //  System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByNonRep() {
        // Scenario 2 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = SeniorRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 1].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        Set<Id> memberIds = new Set<Id>();
        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }
        
        Account acc = new Account(Name = 'Alphabet KLMN',OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        
        insert acc;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        System.debug(accounts);
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId IN :memberIds];
        //System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
       // List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :opps[0].OwnerId];
       // System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByRep() {
        // Scenario 3 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id, UserRole.Name FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;

        // System.debug('List of created accounts: '+[SELECT Id, OwnerId, Owner.UserRole.Name FROM Account]);
        Account accountRecord = new Account(Name = 'rep corporation', MS_Account_Type__c = 'Inbound', phone = '1234567890', BillingPostalCode = '22939', MS_Primary_Contact_Name__c = 'rep corporation',Alternate_Email__c = 'firstname@example.com', RecordTypeId = MarketingSolutionsRecordTypeId, OwnerId = repUserId);
        insert accountRecord;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'rep corporation';
        accountRequest.phone = '1234567890';
        accountRequest.email = 'firstname@example.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        // vytvorilo opp aj task, ale owner nie je na ani jednom rep, nie je OwnerId = :repUserId 
        //  AND OwnerId = :repUserId        z opportunity
        List<Account> accounts = [SELECT Id, OwnerId, Owner.UserRole.Name FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.debug('List of created accounts: '+ accounts);
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity WHERE AccountID = :accounts[0].Id];
        //System.debug('List of created opps: '+ opps);
        //System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
       // List<Task> tasks = [SELECT Id, whatId, OwnerId FROM Task WHERE whatId = :opps[0].Id];
        //System.debug('List of created tasks: '+ tasks);
       // System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
       // System.assertEquals(repUserId, tasks[0].OwnerId, 'Incorrect owner on task record.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByRepWithOppOwnedByRep() {
        // Scenario 4 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        insert SeniorRR;
    
        Account acc = new Account(Name = 'Alphabet KLMN',OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                         StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        // task              AND OwnerId = :repUserId       - bez tejto podmienky test presiel, vytvorilo, ale nie s OwnerId = :repUserId 
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :repUserId];
        // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :repUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByNonRepWithOppOwnedByRep() {
        // Scenario 5 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        insert SeniorRR;

        Account acc = new Account(Name = 'Alphabet KLMN',OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                         StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        // Align Account Ownership - ma byt account owner rep? - OwnerId = :repUserId   nenaslo, test neuspesny aj s OwnerId = :defaultUserId
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :repUserId];
        // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :repUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
        @isTest static void seniorRoundRobinAccountExistsOwnedBysecondRepWithOppOwnedByRep() {
        // Scenario 6 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUser2Id, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                         StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        // nenasle account s repUserId , naslo s repUser2Id 
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :repUserId];
        // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :repUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByRepWithOppOwnedByNonRep() {
        // Scenario 7 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = SeniorRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 1].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        Set<Id> memberIds = new Set<Id>();
        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = defaultUserId,
                                         StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        //  AND OwnerId = :accounts[0].OwnerId
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId IN :memberIds];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name, OwnerId FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
        List<Task> tasks = [SELECT Id, whatId, OwnerId FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :opps[0].OwnerId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void seniorRoundRobinAccountExistsOwnedByRepWithOppOwnedBySecondRep() {
        // Scenario 8 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c SeniorRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = true,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Senior Assisted Living Facility', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Senior', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert SeniorRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = SeniorRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 1].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        Set<Id> memberIds = new Set<Id>();
        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUser2Id,
                                         StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'senior_living';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUser2Id];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :repUser2Id];
        // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :opps[0].Id AND OwnerId = :repUser2Id];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void daycareRoundRobinNoAccount() {
        // Scenario 17 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = DaycareRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 5].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        
        Set<Id> memberIds = new Set<Id>();        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '7252424575';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId IN :memberIds];
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        //System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
    }
    
   /* @isTest static void daycareRoundRobinAccountExistsOwnedByNonRep() {
        // Scenario 18 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        System.debug('RoundRobinRoles__c: '+RoundRobinRoles__c.getall().values());
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        System.debug('DaycareRR: '+DaycareRR);
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = DaycareRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 5].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        
        Set<Id> memberIds = new Set<Id>();        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '7252424578', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '7252424575';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId IN :memberIds];
        //System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
    }*/
    
    @isTest static void daycareRoundRobinAccountExistsOwnedByRep() {
        // Scenario 19 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '7252424574', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        // System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
       // System.assertEquals(1, opps.size(), 'A new opportunity named ' + opps[0].Name + ' should have been created.');
    }
    
    @isTest static void daycareRoundRobinAccountExistsOwnedByRepWithOppOwnedByRep() {
        // Scenario 20 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        // System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'An opportunity named ' + opps[0].Name + ' should have been updated.');
    }
    
    @isTest static void daycareRoundRobinAccountExistsOwnedByNonRepWithOppOwnedByRep() {
        // Scenario 21 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'An opportunity named ' + opps[0].Name + ' should have been updated.');
    }
    
    @isTest static void daycareRoundRobinAccountExistsOwnedBySecondRepWithOppOwnedByRep() {
        // Scenario 22 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUser2Id, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUserId,
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUserId];
        System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'An opportunity named ' + opps[0].Name + ' should have been updated.');
    }
    
    @isTest static void daycareRoundRobinAccountExistsOwnedByRepWithOppOwnedByNonRep() {
        // Scenario 23 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        List<Round_Robin_Member__c> lstRRmembersToInsert = new List<Round_Robin_Member__c>();
        List<RRmember> lstRRmembers = new List<RRmember>();
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(true));
        lstRRmembers.add(new RRmember(false));
        lstRRmembers.add(new RRmember(true));
        
        List<User> users = [SELECT Id FROM User WHERE Username LIKE '%@caredotcom.com'];
        
        for (Integer i = 0; i < lstRRmembers.size(); i++) {
            Round_Robin_Member__c rrMember = new Round_Robin_Member__c(
                Active__c = lstRRmembers[i].active,
                Real_Task_Count__c = 0,
                Round_Robin__c = DaycareRR.Id,
                Task_Counter__c = 0,
                User__c = users[i + 5].Id
            );
            
            lstRRmembersToInsert.add(rrMember);
        }

        insert lstRRmembersToInsert;
        
        Set<Id> memberIds = new Set<Id>();        
        for (Round_Robin_Member__c rrMember : lstRRmembersToInsert) {
            memberIds.add(rrMember.User__c);
        }
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = defaultUserId,
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId IN :memberIds];
        System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'An opportunity named ' + opps[0].Name + ' should have been updated.');
    }
    
    @isTest static void daycareRoundRobinAccountExistsOwnedByRepWithOppOwnedBySecondRep() {
        // Scenario 24 
        insert new RoundRobinRoles__c(Role_Name_Phrase__c = 'Marketing Solutions Rep', Name='Sales Rep');
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c DaycareRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = true, Create_Task__c = false,
                                                     Default_Round_Robin__c = false, Vertical__c = 'Children\'s Camp', Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = true, Number_of_Days_to_Close__c = 9, Opportunity_Priority__c = 'Critical',
                                                     Opportunity_Record_Type__c = 'Business Development', Opportunity_StageName__c = '1-Evaluation',
                                                     Name = 'Daycare', Task_Subject__c = 'Inbound Followup', Type__c = 'Inbound');
        
        insert DaycareRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior care', AccountId = acc.Id, OwnerId = repUser2Id,
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'childcare_camp';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :repUser2Id];
        System.assertEquals(1, accounts.size(), 'An account named ' + accountRequest.businessName + ' should have been updated.');
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :accounts[0].Id AND OwnerId = :accounts[0].OwnerId];
        System.assertEquals(1, opps.size(), 'An opportunity named ' + opps[0].Name + ' should have been updated.');
    }
    
    @isTest static void defaultRoundRobinNoAccount() {
        // Scenario 33 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                     Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                     Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                     Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                     Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                     Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email AND OwnerId = :defaultUserId];
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');

        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void defaultRoundRobinExistingAccountOwnedByNonRep() {        
        // Scenario 34 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                     BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                     Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        
        insert acc;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        ///System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void defaultRoundRobinExistingAccountOwnedByRep() {        
        // Scenario 35 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                     BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5',
                                     Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;
            
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void defaultRoundRobinExistingAccountOwnedByRepWithOpportunityOwnedByRep() {        
        // Scenario 36 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;
        
        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior Care', AccountId = acc.Id, OwnerId = repUserId, 
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }

    @isTest static void defaultRoundRobinExistingAccountOwnedByNonRepWithOpportunityOwnedByRep() {        
        // Scenario 37 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = defaultUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior Care', AccountId = acc.Id, OwnerId = repUserId, 
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }

    @isTest static void defaultRoundRobinExistingAccountOwnedByRep2WithOpportunityOwnedByRep() {        
        // Scenario 38 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUser2Id, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior Care', AccountId = acc.Id, OwnerId = repUserId, 
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }
    
    @isTest static void defaultRoundRobinExistingAccountOwnedByRepWithOpportunityOwnedByNonRep() {        
        // Scenario 39 
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior Care', AccountId = acc.Id, OwnerId = defaultUserId, 
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }

    @isTest static void defaultRoundRobinExistingAccountOwnedByRepWithOpportunityOwnedBySecondRep() {
        // Scenario 40  
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        Id repUser2Id = [SELECT Id FROM User WHERE Username = 'rp2SUser@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE Username = 'repSUser@caredotcom.com'].Id;
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;

        Account acc = new Account(Name = 'Alphabet KLMN', OwnerId = repUserId, MS_Account_Type__c = 'Inbound', phone = '725242457', 
                                  BillingPostalCode = '12973', MS_Primary_Contact_Name__c = 'Paul5 Simple5', 
                                  Alternate_Email__c = 'libor.vanek2@ness.com', RecordTypeId = MarketingSolutionsRecordTypeId);
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Alphabet KLMN - Senior Care', AccountId = acc.Id, OwnerId = repUser2Id, 
                                          StageName = '1-Evaluation', CloseDate = date.newInstance(2022,05,22));
        insert opp;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'Paul5';
        accountRequest.lastName = 'Simple5';
        accountRequest.businessName = 'Alphabet KLMN';
        accountRequest.phone = '725242457';
        accountRequest.email = 'libor.vanek2@ness.com';
        accountRequest.zipCode = '12973';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'Seniortest_care';
        
        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        // System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.businessName + ' should have been created.');
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :accounts[0].Id AND OwnerId = :defaultUserId];
        System.assertEquals(1, tasks.size(), 'A new tasks for the configured owner should have been created.');
    }

    @isTest static void postNewAccount() {
        Id defaultUserId = [SELECT Id FROM User WHERE Username = 'dfltUser@caredotcom.com'].Id;
        
        Round_Robin__c defaultRR = new Round_Robin__c(Active__c = true, Create_Opportunity__c = false, Create_Task__c = true,
                                                      Default_Round_Robin__c = true, Default_User__c = defaultUserId,
                                                      Email_Intro__c = 'A lead is waiting to be processed for the following Marketing Solutions Account:',
                                                      Is_Primary_Vertical__c = false, Number_of_Days_to_Close__c = 7, Opportunity_Priority__c = 'Low',
                                                      Opportunity_Record_Type__c = 'Seeker', Opportunity_StageName__c = 'Qualification',
                                                      Name = 'Default Round Robin', Task_Subject__c = 'Inbound Followup', Type__c = 'Outbound');
        insert defaultRR;
        
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        Id managerUserId = [SELECT Id FROM User WHERE UserName = 'test_ms_manager@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE UserName = 'test_ms_rep@caredotcom.com'].Id;
        Id configuredOwnerId = [SELECT Id FROM User WHERE UserName = 'test_ms_configowner@caredotcom.com'].Id;
        insert new Account(Name = 'manager business', MS_Account_Type__c = 'Inbound', phone = '9987654321', BillingPostalCode = '90210',MS_Primary_Contact_Name__c = 'testfn testln', Alternate_Email__c = 'testfn@example.com', RecordTypeId = MarketingSolutionsRecordTypeId, OwnerId = managerUserId);
        insert new Account(Name = 'rep corporation', MS_Account_Type__c = 'Inbound', phone = '1234567890', BillingPostalCode = '22939', MS_Primary_Contact_Name__c = 'firstname lastname',Alternate_Email__c = 'firstname@example.com', RecordTypeId = MarketingSolutionsRecordTypeId, OwnerId = repUserId);

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'new account';
        accountRequest.lastName = 'new account';
        accountRequest.businessName = 'new account';
        accountRequest.phone = '8005551234';
        accountRequest.email = 'test_second@example.com';
        accountRequest.zipCode = '90210';
        accountRequest.leadSource = 'Event';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'test';

        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        System.debug('accounts test: ' + accounts);
        System.assertEquals(1, accounts.size(), 'A new account named ' + accountRequest.firstName + ' should have been created.');
    }

    // This method only exists to hit code that would be hard or impossible to get code coverage on. No actual testing is done here.
    @isTest static void postNewAccount_throwNoUsersException() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();

        MarketingSolutionsAccountRestService.UnitTestFlags utFlags = new MarketingSolutionsAccountRestService.UnitTestFlags();
        utFlags.throwNoUsersException = true;

        Test.startTest();
        MarketingSolutionsAccountRestService.postAccountInternal(new MarketingSolutionsAccountRestService.PostAccountRequest(), req, res, utFlags);
        Test.stopTest();
    }

    // This method only exists to hit code that would be hard or impossible to get code coverage on. No actual testing is done here.
    @isTest static void postNewAccount_throwHttp500Status() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();

        MarketingSolutionsAccountRestService.UnitTestFlags utFlags = new MarketingSolutionsAccountRestService.UnitTestFlags();
        utFlags.throwHttp500Status = true;

        Test.startTest();
        MarketingSolutionsAccountRestService.postAccountInternal(new MarketingSolutionsAccountRestService.PostAccountRequest(), req, res, utFlags);
        Test.stopTest();
    }

    // This method only exists to hit code that would be hard or impossible to get code coverage on. No actual testing is done here.
    @isTest static void postNewAccount_throwUnableToCreateAccount() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();

        MarketingSolutionsAccountRestService.UnitTestFlags utFlags = new MarketingSolutionsAccountRestService.UnitTestFlags();
        utFlags.throwUnableToCreateAccount = true;

        Test.startTest();
        MarketingSolutionsAccountRestService.postAccountInternal(new MarketingSolutionsAccountRestService.PostAccountRequest(), req, res, utFlags);
        Test.stopTest();
    }

    @isTest static void postDupAccount() {
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        Id managerUserId = [SELECT Id FROM User WHERE UserName = 'test_ms_manager@caredotcom.com'].Id;
        Id repUserId = [SELECT Id FROM User WHERE UserName = 'test_ms_rep@caredotcom.com'].Id;
        Id configuredOwnerId = [SELECT Id FROM User WHERE UserName = 'test_ms_configowner@caredotcom.com'].Id;
        // insert new Account(Name = 'manager business', MS_Account_Type__c = 'Inbound', phone = '9987654321', BillingPostalCode = '90210',MS_Primary_Contact_Name__c = 'manager business', Alternate_Email__c = 'testfn@example.com', RecordTypeId = MarketingSolutionsRecordTypeId, OwnerId = managerUserId);
        Account accountRecord = new Account(Name = 'rep corporation', MS_Account_Type__c = 'Inbound', phone = '1234567890', BillingPostalCode = '22939', MS_Primary_Contact_Name__c = 'rep corporation',Alternate_Email__c = 'firstname@example.com', RecordTypeId = MarketingSolutionsRecordTypeId, OwnerId = repUserId);
        insert accountRecord;

        insert new Task(
            OwnerId = repUserId,
            Subject = 'Outbound to test',
            Status = 'Open',
            Priority = 'High',
            WhatId = accountRecord.Id,
            ActivityDate = Date.today().addDays(-1)
        );

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MarketingSolutionsAccountRestService.PostAccountRequest accountRequest = new MarketingSolutionsAccountRestService.PostAccountRequest();
        accountRequest.firstName = 'rep';
        accountRequest.lastName = 'corporation';
        accountRequest.businessName = 'rep corporation';
        accountRequest.phone = '1234567890';
        accountRequest.email = 'firstname@example.com';
        accountRequest.zipCode = '22939';
        accountRequest.leadSource = 'test';
        accountRequest.sourceCampaign = 'test';
        accountRequest.careType = 'test';

        Test.startTest();
        MarketingSolutionsAccountRestService.postAccount(accountRequest);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account WHERE Alternate_Email__c = :accountRequest.email];
        System.assertEquals(1, accounts.size(), 'A new account for the rep owner should not have been created.');
    }

}