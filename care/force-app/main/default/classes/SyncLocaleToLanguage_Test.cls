@isTest

public class SyncLocaleToLanguage_Test {
    public static ID isaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID ipaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Provider').getRecordTypeId();

    public static ID intEmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static ID intCallCenterRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    public static ID EmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static ID CallCenterRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();

    private static AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

    static testMethod void ConvertLocaleToLanguage_SUCCESS(){
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('en_GB') == 'English');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('de_DE') == 'German');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('fr_FR') == 'French');
        System.Assert(CareDotComUtil.ConvertLocaleToLanguage('nl_NL') == 'Dutch');
    }

    public static testmethod void TestPrivacyEmailOrigin(){
        Case caseObj1=new Case(subject='Test Subject',Origin='Email - DE - Privacy');
        insert caseObj1;
        SetLocaleAndCountryInCase.main(caseObj1);
    }
    
    public static testmethod void TestImprintEmailOrigin(){
        Case caseObj1=new Case(subject='Test Subject',Origin='Email - DE - Imprint');
        insert caseObj1;
        SetLocaleAndCountryInCase.main(caseObj1);
    }

    public static testMethod void TestLanguageIsSet_BasicProvider_English() {
        TestUtil.SterlingCreatesBasicProvider_enGB();

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];

        System.assert(accountList[0].Language__pc == 'English');
    }

    public static testMethod void TestLanguageIsSet_PremiumSeeker_English() {

        TestUtil.SterlingCreatesPremiumSeeker_enGB();
        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalPremiumSeekerMemberId];

        System.assert(accountList[0].Language__pc == 'English');
    }

    public static testMethod void TestLanguageIsSet_BasicSeeker_German() {

        TestUtil.SterlingCreatesBasicSeeker_deDE();

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalBasicSeekerMemberId];

        System.assertEquals(accountList[0].Language__pc, 'German','Contact Language is not German');
    }

    static testMethod void SterlingCreatesMemberAccountThenChangesLocale_Provider_FAIL() {

        TestUtil.SterlingCreatesBasicProvider_enGB();

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];

        System.assert(accountList.size() == 1);
        System.assert(accountList[0].Language__pc == 'English');

        accountList[0].Locale__pc = 'de_GB';
        update accountList[0];

        Account[] updatedAccountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];
        System.assert(updatedAccountList.size() == 1);
        //System.assert(updatedAccountList[0].Language__pc == 'English'); // Language had already been set, so changing Locale should not change langauge any more

    }

    static testMethod void SterlingCreatesMemberAccountThenCreatesACase_Provider_SUCCESS() {

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

        Case[] caseList = [SELECT id,Global_Member_Id__c,Member_Country__c,Member_Language__c,Member_Locale__c,Member_Type__c,Member_Account_Type__c, Member_Status__c,
                Contact.Global_Member_Id__c,Contact.MailingCountry,Contact.Language__c, Contact.Locale__c,Contact.MemberType__c,Contact.Type__c,Contact.Status__c
        FROM Case WHERE ContactId = :accountList[0].PersonContactId];

        System.assert(caseList.size() == 1);

        System.assert(caseList[0].Contact.Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Member_Country__c == caseList[0].Contact.MailingCountry);
        System.assert(caseList[0].Member_Language__c == caseList[0].Contact.Language__c);
        System.assert(caseList[0].Member_Locale__c == caseList[0].Contact.Locale__c);
        System.assert(caseList[0].Member_Type__c == caseList[0].Contact.MemberType__c);
        System.assert(caseList[0].Member_Account_Type__c == caseList[0].Contact.Type__c);
        System.assert(caseList[0].Member_Status__c == caseList[0].Contact.Status__c);

    }

    static testMethod void SterlingCreatesMemberAccountThenCreatesACaseThenUpdatesLocale_Provider_FAIL() {

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

        Case[] caseList = [SELECT id,Global_Member_Id__c,Member_Country__c,Member_Language__c,Member_Locale__c,Member_Type__c,Member_Account_Type__c, Member_Status__c,
                Contact.Global_Member_Id__c,Contact.MailingCountry,Contact.Language__c, Contact.Locale__c,Contact.MemberType__c,Contact.Type__c,Contact.Status__c
        FROM Case WHERE ContactId = :accountList[0].PersonContactId];

        System.assert(caseList.size() == 1);

        System.assert(caseList[0].Contact.Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Member_Country__c == caseList[0].Contact.MailingCountry);
        System.assert(caseList[0].Member_Language__c == caseList[0].Contact.Language__c);
        System.assert(caseList[0].Member_Locale__c == caseList[0].Contact.Locale__c);
        System.assert(caseList[0].Member_Type__c == caseList[0].Contact.MemberType__c);
        System.assert(caseList[0].Member_Account_Type__c == caseList[0].Contact.Type__c);
        System.assert(caseList[0].Member_Status__c == caseList[0].Contact.Status__c);

        caseList[0].Member_Locale__c = 'de_GB'; // this change should not propagate to Case.Member Language
        update caseList[0];

        Case[] updatedCaseList = [SELECT id,Global_Member_Id__c,Member_Country__c,Member_Language__c,Member_Locale__c,Member_Type__c,Member_Account_Type__c, Member_Status__c,
                Contact.Global_Member_Id__c,Contact.MailingCountry,Contact.Language__c, Contact.Locale__c,Contact.MemberType__c,Contact.Type__c,Contact.Status__c
        FROM Case WHERE ContactId = :accountList[0].PersonContactId];

        System.assert(updatedCaseList.size() == 1);
        System.assert(updatedCaseList[0].Member_Locale__c == caseList[0].Member_Locale__c);
        //System.assert(updatedCaseList[0].Member_Language__c == caseList[0].Member_Language__c);


    }

    static testMethod void EscalateCaseAndReassign_Provider_SUCCESS() {
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

        System.assert(caseList[0].Contact.Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Global_Member_Id__c == TestUtil.InternationalProviderMemberId);
        System.assert(caseList[0].Member_Country__c == caseList[0].Contact.MailingCountry);
        System.assert(caseList[0].Member_Language__c == caseList[0].Contact.Language__c);
        System.assert(caseList[0].Member_Locale__c == caseList[0].Contact.Locale__c);
        System.assert(caseList[0].Member_Type__c == caseList[0].Contact.MemberType__c);
        System.assert(caseList[0].Member_Account_Type__c == caseList[0].Contact.Type__c);
        System.assert(caseList[0].Member_Status__c == caseList[0].Contact.Status__c);
        System.assert(caseList[0].status != 'Escalated');
        System.assert(caseList[0].type != 'Escalations');

        caseList[0].status = 'Escalated'; // emulating an agent changing the status of the case to escalated
        caseList[0].type = 'Escalations'; // emulating an agent changing the status of the case to Escalations
        update caseList[0];

        Case[] updatedCaseList = [SELECT id,Member_Language__c,ownerId,status,type
        FROM Case WHERE Id = :caseList[0].id];
        System.assert(updatedCaseList[0].status == 'Escalated');
        System.assert(updatedCaseList[0].type == 'Escalations');

        // commented out - this looks like Next Case stuff being replaced by BREeze/Omni
        //System.assert(updatedCaseList[0].ownerId != caseList[0].ownerId); // ensure that the owner has changed (the case should now be owned by the escalations queue)

    }

    static testMethod void NthDayPremiumSeekerUSAA_SUCCESS() {
        // Creates a case for an NthDay Premium Seeker who is also a USAA member and checks that the USAA_Member__c flag gets copied from Contact to Case

        String firstName = TestUtil.NthDayPremiumSeekerUSAAFirstName;

        TestUtil.createNthDayPremiumSeekerUSAA();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,USAA_Member__c
        FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
        System.assert(ContactList[0].USAA_Member__c == true);  // Sanity check that the premium seeker is actually a USAA Member

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

        System.assert(caseList.size() == 1);

        System.assert(caseList[0].Member_Type__c == caseList[0].Contact.MemberType__c);
        System.assert(caseList[0].Member_Account_Type__c == caseList[0].Contact.Type__c);
        System.assert(caseList[0].Member_Status__c == caseList[0].Contact.Status__c);
        System.assert(caseList[0].USAA_Member__c == caseList[0].Contact.USAA_Member__c);
        System.assert(caseList[0].Member_Overall_Status__c == caseList[0].Contact.OverallStatus__c);


    }

    static testMethod void testMethodAccountLocaleNull() {
        // This test ensures that when the language is changed and the assignemnt rules are NOT invoked, that the owner is NOT changed.

        TestUtil.SterlingCreatesBasicProvider_enGB();

        Account[] accountList = [SELECT id,FirstName,LastName,PersonEmail,PersonHomePhone,Language__pc,Locale__pc,PersonContactId FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];

        System.assert(accountList.size() == 1);
        System.assert(accountList[0].Language__pc == 'English');
        Account a = accountList[0];
        a.Locale__pc=null;update a;

        accountList = [SELECT id,Language__pc,Locale__pc,PersonContactId FROM Account WHERE Global_Member_Id__c = :TestUtil.InternationalProviderMemberId];

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
        //c.member_locale__c='fr_CA';
        //update c;
        c.member_Locale__c=null;
        update c;
    }

    static testMethod void createCaseFromCommunityUser(){
        // Creates a community user (profile doesn't matter as long as it has a guest license) & then creates a case & ensures assignment rules got invoked
        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE UserType = 'Guest' LIMIT 1];
        System.assertEquals(1, profileList.size(),'This unit test requires a profile of usertype Guest & it cannot find it.');

        // Create new user with community profile
        User u = new User(alias = 'tscomusr', email='test@care.com',
                emailencodingkey='UTF-8', lastname='testLastName',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileList[0].id, userroleid = null,
                timezonesidkey='America/Los_Angeles',
                username='test@care.com.communityuser'
        );
        insert u;

        Test.startTest();
        Case c = new Case(
                SuppliedName = 'Test Community',
                SuppliedEmail = null, // null email
                SuppliedPhone = null,
                Subject = 'Reviewed-Safety',
                Description = 'Test Description',
                Type = 'Q: Safety/Fraud',
                Origin = 'Web',
                Status = 'New',
                OwnerId = u.id,
                Reason = 'Safety Alert',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                Article_Topic__c = 'Trust & Safety',
                Member_Type__c = 'SMB Provider',
                Member_Overall_Status__c = 'Active',
                Member_Account_Type__c = 'Premium',
                Support_Skill__c = 'Safety',
                Member_Language__c = 'English',
                Member_Locale__c = 'en_US',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId()
        );
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        c.setOptions(dmlOpts);*/
        insert c;
        Test.stopTest();

        Case updatedCase = [SELECT id,Member_Language__c,ownerId,status,type  FROM Case WHERE Id = :c.id];
        //commenting out as we are not checking owner change as per call with Jack
        //System.assert(updatedCase.ownerId != c.ownerId); // ensure that the owner has changed (the case should now be owned by some queue)
    }

    @isTest static void WaitForCreationChat(){
        /*  NOTE: this class is a clone of OnDemandSync.WaitForCreationChat, but with added tests to confirm 
            that the logic that replaces dummy email on the SyncMemberDetailsToCase class.
        
        WaitForCreation Chat
            * Request
                * 2 Cases with same email; member needs to be created
            * Response 
                * 1 with member id & null salesforce id
            * Create PersonAccount with member id
            
            For chat cases, ODS will often kick in after the case in progress or closed.
            To account for that, these Cases are created closed & have users (rather than Queues) as their owners
        */
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(TestUtil.BasicChildCareSeekerEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicChildCareSeekerEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 2; i++){
            Case c = new Case(
                SuppliedName = TestUtil.BasicChildCareSeekerFirstName,
                //SuppliedEmail = TestUtil.BasicChildCareSeekerEmail,
                SuppliedEmail = CDCCPreChatController.getDummyEmail(null),
                Subject = 'AR Test #' + i,
                Description = 'Test Description',
                Origin = 'Chat',
                Status = 'Closed',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Contact_Reason__c = 'Payments',
                Contact_Secondary_Reason__c = 'Cancellation',
                Current_Member_Type__c = 'Basic',
                Web_Member_Id__c = String.valueOf(TestUtil.BasicChildCareSeekerMemberId), // Chat cases always pass Web Member Id
                RecordTypeId = Test_OnDemandSync.stdRtId              
            );

            //Gears Case:00042482
            //Moved to Breeze
            /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
            
            c.setOptions(dmlOpts);*/
            CasesToInsert.add(c);
        }
        
        insert CasesToInsert;

        CasesToInsert = [
            SELECT id,ownerid,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
            FROM Case 
            WHERE id IN :CasesToInsert];
        for (Case c: CasesToInsert){
            String sOwnerId = String.valueOf(c.ownerid);
            //system.assertEquals('00G', sOwnerId.left(3),'Case is not owned by Queue');
            c.OwnerId = UserInfo.getUserId(); // remove from queue
        }
        update CasesToInsert;

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            String CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_US);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_US));
        
        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = Test_OnDemandSync.getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
            system.assertEquals(null, updatedC.AccountId,'Account is not null');
            system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
        }
        
        TestUtil.createBasicChildCareSeeker(); // invoke Account trigger
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
            
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_US); // Invoke batch logic manually
        
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                    FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName];
        Contact con = ContactList[0];
        
        Cases = [SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Start_Time__c,ODS_End_Time__c,OwnerId//,Tier__c
                    FROM Case WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertEquals(UserInfo.getUserId(), updatedC.ownerid,'Case is not owned by Running User');
            System.assertNotEquals(CDCCPreChatController.getDummyEmail(null), updatedC.SuppliedEmail, 'Supplied Email should not be a Dummy Email');
            System.assertNotEquals(true, CDCCPreChatController.isDummyEmail(updatedC.SuppliedEmail), 'Supplied Email should not be a Dummy Email');
        }
    }                

}