/*

test Class for MCCaseTriage
Description:  Created for case triaging through case assignment rules for membercare cases by disabling breeze rules for member care
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
modified: 20/07/2023
*/ 
@IsTest
public class Test_SafetyCaseTriage {
    Public static Id IntlSafety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
    Public static Id Safety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
    Public static Id PremierBGC =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premier Background Check').getRecordTypeId();
    public static User automatedUser = [Select id , name from user where name  = 'Sterling User 2' and isActive=true];
    @testSetup
    public static void setupData(){
        Account acc= new Account (Name = 'Test Account');
        insert acc;
        List<Entitlement> lstEntitlement = new list<Entitlement>();                                              
        Entitlement en1 = new Entitlement(
            Name = '10 Hour SLA',
            AccountId = acc.Id
        );
        lstEntitlement.add(en1);
        Entitlement en2 = new Entitlement(
            Name = '24 Hour SLA',
            AccountId = acc.Id
        );
        lstEntitlement.add(en2);
        Entitlement en3 = new Entitlement(
            Name = '48 Hour SLA',
            AccountId = acc.Id
        );
        lstEntitlement.add(en3);
        Entitlement en4 = new Entitlement(
            Name = '200 Hour SLA',
            AccountId = acc.Id
        );
        lstEntitlement.add(en4);
        insert lstEntitlement;
    }
    
    @IsTest
    public static void testCaseTriageInappropriateActivity(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Inappropriate_Activity' LIMIT 1];
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='10 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Inappropriate Search',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Inappropriate Activity');
            system.assertEquals(updatedCase.Priority, '1');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageReviewsPlatformEscalation(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Safety_Reviews' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='10 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Reviews Platform Escalation',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c, EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Safety Review');
            system.assertEquals(updatedCase.Priority, '1');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageFlaggedbyMember(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Member_Flags' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Flagged by Member',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Flags');
            system.assertEquals(updatedCase.Priority, '2');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageBlocklistPartialMatch(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Blocklist_Partial_Match' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Blocklist Partial Match',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Blocklist Partial Match');
            system.assertEquals(updatedCase.Priority, '2');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageBlockedMemberAppeal(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Q_Blocked_Member_Appeal' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Blocklisted',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Blocklisted Member Appeals');
            system.assertEquals(updatedCase.Priority, '5');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageApprovedSafety(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Member_Review_Escalations' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='10 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Approved-Safety',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Review Escalations');
            system.assertEquals(updatedCase.Priority, '1');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageAccusedListMatch(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Accused_List_Match' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Accused List Match',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Accused List Match');
            system.assertEquals(updatedCase.Priority, '2');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageSiftScience(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Fraud_Detection' LIMIT 1];  
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Seeker Create Account - Decline due to SiftScience fraud rules',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Fraud Detection');
            system.assertEquals(updatedCase.Priority, '3');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageNegativeMediaCheck(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Negative_Media' LIMIT 1];
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='200 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Negative Media Check Alert',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Negative Media');
            system.assertEquals(updatedCase.Priority, '4');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageIDV(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'S_Identity_Verification' LIMIT 1]; 
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='24 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='IDV Failure',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Identity Verification');
            system.assertEquals(updatedCase.Priority, '5');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageRDC(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'RDC_List_Match' LIMIT 1]; 
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='200 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='RDC List Match',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Safety');
            system.assertEquals(updatedCase.Priority, '32');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageRDCMediumRisk(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'RDC_List_Match_Medium_Risk' LIMIT 1]; 
        Entitlement ent1 = [Select id , Name FROM Entitlement where Name ='200 Hour SLA' limit 1];
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='RDC List Match - Medium Risk',
                recordTypeId =Safety
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Safety');
            system.assertEquals(updatedCase.Priority, '31');
            system.assertEquals(updatedCase.EntitlementId, ent1.Id);
            system.assertEquals(updatedCase.BusinessHoursId, bh.Id);
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriagePremierBGC(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Q_Premier_Background_Checks' LIMIT 1];  
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Premier Background Checks',
                recordTypeId = PremierBGC
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Premier Background Check');
        }
        Test.stopTest();
    }
       
    @IsTest
    public static void testCaseTriageSafetyUpdate(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Q_Premier_Background_Checks' LIMIT 1];  
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='RDC List Match - Medium Risk',
                recordTypeId = PremierBGC
            );
            insert c;
            c.Subject ='Premier Background Checks';
            update c;
            
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Premier Background Check');
        }
        Test.stopTest();
    }
}