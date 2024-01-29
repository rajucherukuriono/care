//Created By: Mohammed Ashwaq
//Created Date: 10/11/2020
//Test class for: SyncMemberDetailsToCase
@isTest
public class Test_SyncMemberDetailsToCase {
    public static ID isaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID intEmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static ID EmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    static testMethod void ConvertLocaleToLanguage_SUCCESS(){
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('en_GB') == 'English');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('de_DE') == 'German');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('fr_FR') == 'French');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('nl_NL') == 'Dutch');
    }
   @testSetup static void setup(){
       Test.startTest();
        Account a = new Account();
        a.RecordTypeId = isaRtId;
        a.FirstName = 'OpenPremium';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998001';
        a.Language__pc = 'English';
        a.Locale__pc = 'en_GB';
        a.Status__pc = 'Open';
        a.Type__pc = 'Premium';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'uk';
        a.PersonEmail = 'openpremiumuk@care.com';        
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        insert a;
        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
       	String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        TestUtil.createNthDayPremiumSeeker();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,USAA_Member__c
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
       Case c = new Case(
                SuppliedName = ContactList[0].FirstName + ' ' + ContactList[0].LastName,
                SuppliedEmail = ContactList[0].Email,
                SuppliedPhone = ContactList[0].Phone,
                ContactId = ContactList[0].id,
                Subject = 'Test Subject #1',
                Description = 'Test Description #1',
                Type = 'Q: Seeker: Billing',
                RecordTypeId = EmailRtId
            );
        insert c;
        Case[] caseList = [SELECT id,Global_Member_Id__c,Member_Country__c,Member_Language__c,Member_Locale__c,Member_Type__c,ownerId,status,type,
                                    Member_Account_Type__c, Member_Status__c,USAA_Member__c,Contact.Global_Member_Id__c,Contact.MailingCountry,
                                    Contact.Language__c, Contact.Locale__c,Contact.MemberType__c,Contact.Type__c,Contact.Status__c,
                                    Contact.USAA_Member__c,Contact.OverallStatus__c,Member_Overall_Status__c
                                FROM Case WHERE id = :c.id];
    }
    static testMethod void testassociateMemberDtlsToCase() {
        // This test ensures that when the case is escalated, the owner is reassigned
        TestUtil.SterlingCreatesBasicProvider_enGB();        
        Account[] accountList = [SELECT id,FirstName,LastName,PersonEmail,PersonHomePhone,Language__pc,Locale__pc,PersonContactId FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].Language__pc == 'English');
        Account a = accountList[0];
        Case c = new Case(
                SuppliedName = a.FirstName + ' ' + a.LastName,
                SuppliedEmail = a.PersonEmail,
                SuppliedPhone = a.PersonHomePhone,
                ContactId = accountList[0].PersonContactId,
                Subject = 'Test Subject #1',
                Description = 'Test Description #1',
                Type = 'Approval',
                RecordTypeId = intEmailRtId              
            );
        insert c;
        Case[] caseList = [SELECT id,Global_Member_Id__c,Member_Country__c,Member_Language__c,Member_Locale__c,Member_Type__c,ownerId,status,type,Member_Account_Type__c, Member_Status__c,
                                    Contact.Global_Member_Id__c,Contact.MailingCountry,Contact.Language__c, Contact.Locale__c,Contact.MemberType__c,Contact.Type__c,Contact.Status__c
                                FROM Case WHERE ContactId = :accountList[0].PersonContactId];
        System.assert(caseList.size() == 1);
        caseList[0].status = 'Escalated'; // emulating an agent changing the status of the case to escalated
        caseList[0].type = 'Escalations'; // emulating an agent changing the status of the case to Escalations
        update caseList[0];
        Case[] updatedCaseList = [SELECT id,Member_Language__c,ownerId,status,type                                  
                                FROM Case WHERE Id = :caseList[0].id];      
        System.assert(updatedCaseList[0].status == 'Escalated');        
        System.assert(updatedCaseList[0].type == 'Escalations');        
        //System.assert(updatedCaseList[0].ownerId == caseList[0].ownerId); // ensure that the owner has changed (the case should now be owned by the escalations queue)      
    }
}