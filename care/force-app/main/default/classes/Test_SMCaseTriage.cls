/*
test Class for SMCaseTriage
Description:  Created for case triaging  for SocialMedia Case
CreatedBy : md Ashwaq
CreatedDate: 19/07/2023
*/
@IsTest
public class Test_SMCaseTriage {
    Public static Id SocialMediaUS =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId();
    Public static Id SocialMediaIntl =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
    public static User automatedUser = [Select id , name from user where name  = 'Sprinklr User' and isActive=true];
    
    @testSetup static void setupData(){
        Case  c0 = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media US0',
            	Initial_Message_Privacy_Sprinklr__c ='Private',
                recordTypeId = SocialMediaUS
            );        
            insert c0;
        
         Case  c01 = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media US0',
            	Initial_Message_Privacy_Sprinklr__c ='Public',
                recordTypeId = SocialMediaUS
            );        
            insert c01;
        Case  c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media US2',
                recordTypeId = SocialMediaUS
            );        
            insert c;
         case c1 = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media intl 2',
                recordTypeId = SocialMediaIntl
            );            
            insert c1;
    }
    @IsTest
    public static void testCaseTriageSocialMediaInsert(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Member_Care_EN_SM' LIMIT 1];  
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media US',
                recordTypeId = SocialMediaUS
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN SM');
        }
        Test.stopTest();
    }
    
    
    @IsTest
    public static void testCaseTriageSocialMediaUpdate(){
        Test.startTest();        
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Member_Care_EN_SM' LIMIT 1];   
        system.runAs(automatedUser){
            Case C = [SELECT Id,CaseTriage__c,ownerId, Support_skill__c, Status FROM Case WHERE Subject ='Socil Media US2' ];
            C.CaseTriage__c = true;
            update C;
            
            Case updatedCase2 = [SELECT Id,CaseTriage__c,ownerId, Support_skill__c, Status FROM Case WHERE Id = :C.Id ];
            system.assertEquals(updatedCase2.OwnerId, G.id);
            system.assertEquals(updatedCase2.Support_skill__c, 'Member Care - EN SM'); 
        }
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testCaseTriageSocialMediaIntlUpdate(){
        Test.startTest();        
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Member_Care_ROW_SM' LIMIT 1];  
        system.runAs(automatedUser){
            Case C = [SELECT Id,CaseTriage__c,ownerId, Support_skill__c, Status FROM Case WHERE Subject ='Socil Media intl 2' ];            
            c.CaseTriage__c = true;
            update c;
            
            Case updatedCase2 = [SELECT Id,CaseTriage__c,ownerId, Support_skill__c, Status FROM Case WHERE Id = :c.Id ];
            //system.assertEquals(updatedCase2.OwnerId, G.id);
            system.assertEquals(updatedCase2.Support_skill__c, 'Member Care - ROW SM');  
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void testCaseTriageSocialMediaiNTL(){
        Test.startTest();
        Group G = [Select Id, Name FROM Group WHERE DeveloperName = 'Member_Care_ROW_SM' LIMIT 1];  
        system.runAs(automatedUser){
            Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                status ='New',
                Web_External_Member_ID__c = 'testMemberId',
                Subject ='Socil Media Intl',
                Member_language__c = 'German',
                recordTypeId = SocialMediaIntl
            );
            insert c;
            Case updatedCase = [SELECT Id,CaseTriage__c,EntitlementId,BusinessHoursId,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id = :c.Id ];
            system.assertEquals(updatedCase.OwnerId, G.id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW SM');
        }
        Test.stopTest();
    }
}