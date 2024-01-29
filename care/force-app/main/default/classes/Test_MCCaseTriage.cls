/*
test Class for MCCaseTriage
Description:  Created for case triaging through case assignment rules for membercare cases by disabling breeze rules for member care
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
modified: 20/07/2023
*/
@IsTest
public class Test_MCCaseTriage {
    Public static Id IntlCall = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    Public static Id IntlEmail = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    Public static Id Strd = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    Public static Id Safety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
    Public static Id CallCent = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();
    public static User automatedUser = [Select id , name from user where name  = 'Care.com Salesforce Admin' and isActive=true];
    public static List<Group> MCGroups = [Select Id, DeveloperName FROM Group WHERE DeveloperName IN ('MC_Temporary','Member_Care_EN_Tier_1', 'Member_Care_EN_Tier_2', 'Member_Care_ROW_Tier_1', 'Member_Care_ROW_Tier_2', 'S_Safety_Email')]; 
    //MC Email ROW
    @testSetup
    public static void setupdata(){
        Test.startTest();
        system.runAs(automatedUser){
            List<Case> insertCaseList  = new List<Case>();
            Case c1 = new Case(
                subject='basicSeeker',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Seeker',
                Status='New',
                origin='Chat',
                recordTypeId =Strd,
                OwnerId =automatedUser.Id
            );
            insertCaseList.add(c1);
            Case c2 = new Case(
                subject='NullMember',
                Member_Language__c = 'English',
                Member_Account_Type__c = '',
                Member_Type__c = '',
                Status='New',
                origin='Email',
                recordTypeId =strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(c2);
            Case c3 = new Case(
                subject='NullMemberROW',
                Member_Language__c = 'German',
                Member_Account_Type__c = '',
                Member_Type__c = '',
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(c3);
            Case c4 = new Case(
                subject='BasicSeekerCaseIntl',
                Member_Language__c = 'German',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Seeker',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(c4);
            Case c5 = new Case(
                subject='BasicSeekerCaseEngIntl',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Seeker',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(c5);
            Case c6 = new Case(
                subject='BasicSeekerCaseUS',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Seeker',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(c6);
            Case mcEmailCaseEN = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Description = 'testDescription',
                Subject ='mcemailCaseEnglish',
                status = 'New',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c = 'English',
                recordTypeId =Strd,   
                Origin = 'Web',
                MC_Email__c = false,
                OwnerId = MCGroups[0].Id
            );
            insertCaseList.add(mcEmailCaseEN);
            Case mcEmailCaseROW = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Description = 'testDescription',
                Subject ='mcemailCaseROW',
                status = 'New',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c = 'German',
                recordTypeId =Strd,   
                Origin = 'Web',
                MC_Email__c = false,
                OwnerId = MCGroups[0].Id
            );
            insertCaseList.add( mcEmailCaseROW);
            Case safetyEmailCase = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Description = 'testDescription',
                Subject ='safetyEmailCase',
                status = 'New',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c = 'English',
                recordTypeId =Strd,   
                Origin = 'Web',
                Safety_Email__c = false,
                OwnerId = MCGroups[0].Id
            );
            insertCaseList.add(safetyEmailCase);
            Case privacyCaseROW = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Origin ='Email - Privacy',
                Member_Language__c = 'German',
                Subject ='privacyCaseROW',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(privacyCaseROW);
            Case privacyCaseENG = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Origin ='Email - Privacy',
                Member_Language__c = 'English',
                Subject ='privacyCaseENG',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(privacyCaseENG);
            Case CCPAPrivacy = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Account_Type__c = 'Basic',
                Member_Language__c = 'German',
                Member_Type__c = 'Seeker',
                origin='CCPA-Privacy',
                Subject ='CCPAPrivacy',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(CCPAPrivacy);
            Case TransactionCase = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Subject ='Transaction',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c = 'English',
                origin='Web',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(TransactionCase);
            Case careforceCase = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c ='English',
                Member_Type__c ='Seeker',
                Origin='Web',
                Member_Overall_Status__c = 'Premium',
                recordTypeId =Strd,
                Subject= 'careforce',
                Employer_Program__c = 'careforce',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(careforceCase);
            Case careforceCaseIntlEng = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c ='English',
                Member_Type__c ='Seeker',
                Origin='Web',
                Subject ='careforceIntlEng',
                Member_Overall_Status__c = 'Premium',
                recordTypeId =IntlEmail,
                Employer_Program__c = 'careforce',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(careforceCaseIntlEng);
            Case careforceCaseIntlGer = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Language__c ='German',
                Member_Type__c ='Seeker',
                Origin='Web',
                Subject ='careforceIntlGer',
                Member_Overall_Status__c = 'Premium',
                recordTypeId =IntlEmail,
                Employer_Program__c = 'careforce',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(careforceCaseIntlGer);
            Case ExtraordinaryDowngradeRequestUS = new Case(
                subject='Extraordinary Downgrade Request',
                Member_Language__c = 'English',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(ExtraordinaryDowngradeRequestUS);   
            Case ExtrDowneReqestIntlEng = new Case(
                subject='Extraordinary Downgrade Request',
                Member_Language__c = 'English',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(ExtrDowneReqestIntlEng);
            Case ExtrDowneReqestIntlGer = new Case(
                subject='Extraordinary Downgrade Request',
                Member_Language__c = 'German',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(ExtrDowneReqestIntlGer);
            Case VistDowneReqestUS = new Case(
                subject='Visitor Downgrade Request',
                Member_Language__c = 'English',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(VistDowneReqestUS);   
            Case VistDowneReqestIntlEng = new Case(
                subject='Visitor Downgrade Request',
                Member_Language__c = 'English',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(VistDowneReqestIntlEng);
            Case VistDowneReqestIntlGer = new Case(
                subject='Visitor Downgrade Request',
                Member_Language__c = 'German',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(VistDowneReqestIntlGer);
            Case intlImprintEng = new Case(
                subject='InternationalImprintEnglish',
                Member_Language__c = 'English',
                Safety_Email__c =false,
                Status='New',
                Type ='International Imprint',
                origin='Email - Imprint',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(intlImprintEng);
            Case intlImprintGer = new Case(
                subject='InternationalImprintGerman',
                Member_Language__c = 'German',
                Safety_Email__c =false,
                Status='New',
                origin='Email - DE - Imprint',
                recordTypeId =IntlEmail,
                Type ='International Imprint',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(intlImprintGer);
            Case premiumSeekerUS = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Origin = 'Web',
                Member_Language__c ='English',
                Member_Type__c ='Seeker',
                Member_Overall_Status__c = 'Premium',
                recordTypeId =Strd,
                Subject='PremiumSeekerUS',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(premiumSeekerUS);
            Case PremiumSeekerIntlEng = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Origin = 'Web',
                Member_Language__c ='English',
                Member_Type__c ='Seeker',
                Member_Overall_Status__c = 'Premium',
                recordTypeId =IntlEmail,
                Subject='PremiumSeekerIntlEng',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(PremiumSeekerIntlEng);
            Case PremiumSeekerIntlGer = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail32@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Origin = 'Web',
                Member_Language__c ='German',
                Member_Type__c ='Seeker',
                Member_Account_Type__c = 'Premium',
                recordTypeId =IntlEmail,
                Subject='PremiumSeekerIntlGer',
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(PremiumSeekerIntlGer);
            Case premiumProviderUS = new Case(
                subject='premiumProviderUS',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Premium',
                Member_Type__c = 'Provider',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(premiumProviderUS);
            Case premiumProviderIntlEng = new Case(
                subject='premiumProviderIntlEng',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Premium',
                Member_Type__c = 'Provider',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(premiumProviderIntlEng);
            Case premiumProviderIntlGer = new Case(
                subject='premiumProviderIntlGer',
                Member_Language__c = 'German',
                Member_Account_Type__c = 'Premium',
                Member_Type__c = 'Provider',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(premiumProviderIntlGer);
            Case featuredSMB_ProviderUS = new Case(
                subject='featuredSMB_Provider',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Featured',
                Member_Type__c = 'SMB_Provider',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(featuredSMB_ProviderUS);
            Case featuredSMB_ProviderIntl = new Case(
                subject='featuredSMB_ProviderIntl',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Featured',
                Member_Type__c = 'SMB_Provider',
                Safety_Email__c =false,
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(featuredSMB_ProviderIntl);
            Case basicProviderUS = new Case(
                subject='basicProviderUS',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Provider',
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(basicProviderUS);
            Case basicProviderIntlEng = new Case(
                subject='basicProviderIntlEng',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Provider',
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(basicProviderIntlEng);
            Case basicProviderIntlGer = new Case(
                subject='basicProviderIntlGer',
                Member_Language__c = 'German',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Provider',
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(basicProviderIntlGer);
            Case basicSMBProviderUS = new Case(
                subject='basicSMBProvider',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'SMB_Provider',
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(basicSMBProviderUS);
            Case basicSMBProviderIntl = new Case(
                subject='basicSMBProviderIntl',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'SMB_Provider',
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(basicSMBProviderIntl);
            Case caseLite = new Case(
                subject='LiteUS',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Lite',
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(caseLite);
            Case caseLiteIntl = new Case(
                subject='LiteIntl',
                Member_Language__c = 'English',
                Member_Account_Type__c = 'Basic',
                Member_Type__c = 'Lite',
                Status='New',
                origin='Email',
                recordTypeId =IntlEmail,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(caseLiteIntl);
            Case caseAnyProvider = new Case(
                subject='caseAnyProvider',
                Member_Language__c = 'English',
                Member_Type__c = 'Provider',
                Status='New',
                origin='Email',
                recordTypeId =Strd,
                OwnerId= MCGroups[0].Id
            );
            insertCaseList.add(caseAnyProvider);
            insert insertCaseList;
        }
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageMCEmailEnglish(){
        Test.startTest();
        case insCases = [SELECT Id,Origin,MC_Email__c, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='mcemailCaseEnglish' limit 1];
        insCases.MC_Email__c = true;        
        update insCases;
        Case updatedCase = [SELECT Id,CaseTriage__c,Member_Language__c,MC_Email__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status,Subject FROM Case WHERE Id =:insCases.Id ];
        system.assertEquals(updatedCase.OwnerId,MCGroups[2].Id);
        system.assertEquals(updatedCase.MC_Email__c,true);
        system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 2');
        system.assertEquals(updatedCase.Priority, '6');        
        Test.stopTest();
    }
    @IsTest
    public static void testCaseTriageMCEmailROW(){
        Test.startTest();
        case insCases = [SELECT Id,Origin,MC_Email__c, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='mcemailCaseROW' limit 1];
        insCases.MC_Email__c = true;        
        update insCases;
        Case updatedCase = [SELECT Id,CaseTriage__c,Member_Language__c,MC_Email__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status,Subject FROM Case WHERE Id =:insCases.Id ];
        system.assertEquals(updatedCase.OwnerId,MCGroups[4].Id);
        system.assertEquals(updatedCase.MC_Email__c,true);
        system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 2');
        system.assertEquals(updatedCase.Priority, '6');        
        Test.stopTest();
    }
    //Safety_email=true
    @IsTest
    public static void testCaseTriageSafetyEmail(){
        Test.startTest(); 
        Case insCase = [SELECT Id,Origin,EntitlementId, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='safetyEmailCase' limit 1 ];
        insCase.Safety_Email__c =  true;
        update insCase;
        Case updatedCase = [SELECT Id,Origin,EntitlementId, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
        system.assertEquals(updatedCase.OwnerId, MCGroups[5].id);
        system.assertEquals(updatedCase.Support_skill__c, 'Safety Email');
        system.assertEquals(updatedCase.Priority, '7');
        Test.stopTest();
    }    
    //Email - Privacy ROW
    @IsTest
    public static void testCaseTriageEmailPrivacyRow(){
        Test.startTest();
        system.runAs(automatedUser){
            List<Id> requests = new List<Id>();
            List<Case> lstCase= new List<Case>();
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='privacyCaseROW' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[4].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 2');           
            system.assertEquals(updatedCase.Priority, '6');
        }
        Test.stopTest();
    }
    //Email - Privacy Eng
    @IsTest
    public static void testCaseTriageEmailPrivacyEng(){
        Test.startTest();
        system.runAs(automatedUser){
            List<Id> requests = new List<Id>();
            List<Case> lstCase= new List<Case>();
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='privacyCaseENG' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[2].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 2');           
            system.assertEquals(updatedCase.Priority, '6');
        }
        Test.stopTest();
    }
    //Email - CCPA Privacy Intl
    @IsTest
    public static void testCaseTriagePrivacy(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject ='CCPAPrivacy' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[4].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 2');
            system.assertEquals(updatedCase.Priority, '6');
        }
        Test.stopTest();
    } 
    //Instant Book
    @IsTest
    public static void testCaseTriageInstantBook(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject ='Transaction'];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            insCase.Subject = 'Booking';
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '1');
        }
        Test.stopTest();
    }
    //Care@Work US
    @IsTest
    public static void testCaseTriageCareWork(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='careforce' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');           
            system.assertEquals(updatedCase.Priority, '2');
        }
        Test.stopTest();
    }
    //Care@Work ENGLISH Intl
    @IsTest
    public static void testCaseTriageCareWorkIntlEng(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='careforceIntlEng' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');           
            system.assertEquals(updatedCase.Priority, '2');
        }
        Test.stopTest();
    }
    //Care@Work Intl German
    @IsTest
    public static void testCaseTriageCareWorkIntlGerman(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='careforceIntlGer' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');           
            system.assertEquals(updatedCase.Priority, '1');
        }
        Test.stopTest();
    }
    //Extraordinary Downgrade Request US
    @IsTest
    public static void testCaseTriageExtrDwnReqUS(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Extraordinary Downgrade Request' and Member_language__c='English' and RecordTypeId=:Strd];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[2].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - EN Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //Extraordinary Downgrade Request Intl Eng
    @IsTest
    public static void testCaseTriageExtrDwnReqIntlEng(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Extraordinary Downgrade Request' and Member_language__c='English' and RecordTypeId=:IntlEmail];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[2].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - EN Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //Extraordinary Downgrade Request Intl Ger
    @IsTest
    public static void testCaseTriageExtrDwnReqIntlGer(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Extraordinary Downgrade Request' and Member_language__c='German' and RecordTypeId=:IntlEmail];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[4].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - ROW Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //Visitor Downgrade Request US
    @IsTest
    public static void testCaseTriageVisitorDwnReqUS(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Visitor Downgrade Request' and Member_language__c='English' and RecordTypeId=:Strd];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[2].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - EN Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //Visitor Downgrade Request Intl Eng
    @IsTest
    public static void testCaseTriageVisitorDwnReqIntlEng(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Visitor Downgrade Request' and Member_language__c='English' and RecordTypeId=:IntlEmail];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[2].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - EN Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //Extraordinary Downgrade Request US
    @IsTest
    public static void testCaseTriageVisitorDwnReqIntlGer(){
        Test.startTest(); 
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='Visitor Downgrade Request' and Member_language__c='German' and RecordTypeId=:IntlEmail];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase1.OwnerId, MCGroups[4].id);
            system.assertEquals(updatedCase1.Support_skill__c, 'Member Care - ROW Tier 2');
            system.assertEquals(updatedCase1.Priority, '6');
        }
        Test.stopTest();
    }
    //International Imprint Intl Eng
    @IsTest
    public static void testCaseTriageIntlImprintEN(){
        Test.startTest(); 
        system.runAs(automatedUser){            
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='InternationalImprintEnglish' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[1].id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();        
    }
    //International Imprint Intl German
    @IsTest
    public static void testCaseTriageIntlImprintROW(){
        Test.startTest(); 
        system.runAs(automatedUser){            
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='InternationalImprintGerman' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[3].id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Premium Seeker AND Pending Active Seeker US
    @IsTest
    public static void testCaseTriagePremiumSeekerUS(){
        Test.startTest();
        system.runAs(automatedUser){            
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='PremiumSeekerUS' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');           
            system.assertEquals(updatedCase.Priority, '3');
        }
        Test.stopTest();
    }
    //Premium Seeker AND Pending Active Seeker Intl Eng
    @IsTest
    public static void testCaseTriagePremiumSeekerIntlEng(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='PremiumSeekerIntlEng' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');           
            system.assertEquals(updatedCase.Priority, '3');
        }
        Test.stopTest();
    }
    //Premium Seeker AND Pending Active Seeker Intl Ger
    @IsTest
    public static void testCaseTriagePremiumSeekerIntlGer(){
        Test.startTest();
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='PremiumSeekerIntlGer' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId, MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');           
            system.assertEquals(updatedCase.Priority, '2');
        }
        Test.stopTest();
    }
    //Premium Provider US
    @IsTest
    public static void testCaseTriagePremiumProviderUS(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='premiumProviderUS' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Premium Provider Intl Eng
    @IsTest
    public static void testCaseTriagePremiumProviderIntlEng(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='premiumProviderIntlEng' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Premium Provider Intl Ger
    @IsTest
    public static void testCaseTriagePremiumProviderIntlGer(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='premiumProviderIntlGer' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');
            system.assertEquals(updatedCase.Priority, '3');
        }
        Test.stopTest();
    }
    //Premium (Featured) SMB Provider US
    @IsTest
    public static void testCaseTriagePremiumSMBProviderUS(){
        Test.startTest();   
        system.runAs(automatedUser){            
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='featuredSMB_Provider'];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Premium (Featured) SMB Provider Intl
    @IsTest
    public static void testCaseTriagePremiumSMBProviderIntl(){
        Test.startTest();   
        system.runAs(automatedUser){            
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='featuredSMB_ProviderIntl'];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Basic (Individual) Provider- Paid Basic US
    @IsTest
    public static void testCaseTriageBasicProviderUS(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='basicProviderUS' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic (Individual) Provider- Paid Basic Intl Eng
    @IsTest
    public static void testCaseTriageBasicProviderIntlEng(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='basicProviderIntlEng' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic (Individual) Provider- Paid Basic Intl Ger
    @IsTest
    public static void testCaseTriageBasicProviderIntlGer(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='basicProviderIntlGer' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Basic SMB Provider US
    @IsTest
    public static void testCaseTriageBasicSMBProvider(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='basicSMBProvider' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic SMB Provider Intl
    @IsTest
    public static void testCaseTriageBasicSMBProviderIntl(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='basicSMBProviderIntl' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Lite US
    @IsTest
    public static void testCaseTriageLiteUS(){
        Test.startTest();   
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='LiteUS' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '6');
        }
        Test.stopTest();
    }
    //Lite Intl
    @IsTest
    public static void testCaseTriageLiteIntl(){
        Test.startTest();   
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='LiteIntl' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '6');
        }
        Test.stopTest();
    }
    //Any Provider
    @IsTest
    public static void testCaseTriagecaseAnyProvider(){
        Test.startTest();   
        system.runAs(automatedUser){
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Subject='caseAnyProvider' ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic Seeker - English US
    @IsTest
    public static void testCaseTriageBasicSeekerEngUS(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE subject='BasicSeekerCaseUS' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic Seeker - Intl Eng
    @IsTest
    public static void testCaseTriageBasicSeekerIntlEng(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE subject='BasicSeekerCaseEngIntl' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Basic Seeker - English ROW
    @IsTest
    public static void testCaseTriageBasicSeekerEngROW(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE subject='BasicSeekerCaseIntl' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');
            system.assertEquals(updatedCase.Priority, '4');
        }
        Test.stopTest();
    }
    //Member null English
    @IsTest
    public static void testCaseTriageMemberNullEnglish(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE subject='NullMember' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Member null ROW
    @IsTest
    public static void testCaseTriageMemberNullEnglishROW(){
        Test.startTest();   
        system.runAs(automatedUser){  
            Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE subject='NullMemberROW' limit 1 ];
            insCase.is_ods_complete__c = true;
            insCase.Casetriage__c = true;
            update insCase;
            Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase.id ];
            system.assertEquals(updatedCase.OwnerId,MCGroups[3].Id);
            system.assertEquals(updatedCase.Support_skill__c, 'Member Care - ROW Tier 1');
            system.assertEquals(updatedCase.Priority, '5');
        }
        Test.stopTest();
    }
    //Chat Case 
    @IsTest
    public static void testChatCaseOwnerchange(){
        Test.startTest();  
        Case insCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE origin='Chat' limit 1 ];
        insCase.is_ods_complete__c = true;
        insCase.OwnerId= MCGroups[1].Id; 
        update insCase;
        Case insCase1 = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id =:insCase.Id limit 1 ];
        insCase1.Support_skill__c = 'Member Care - EN Tier 1';
        update insCase1;
        Case updatedCase = [SELECT Id,Origin, CaseTriage__c,Member_Language__c, Owner.Name, Support_Skill__c,Priority, recordTypeId, Status FROM Case WHERE Id=:insCase1.id ];
        system.assertEquals(updatedCase.OwnerId,MCGroups[1].Id);
        system.assertEquals(updatedCase.Support_skill__c, 'Member Care - EN Tier 1');
        Test.stopTest();
    }
}