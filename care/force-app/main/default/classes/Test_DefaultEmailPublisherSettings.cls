@isTest
public class Test_DefaultEmailPublisherSettings {

    public static ID IsRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID IeRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static ID scRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static string suppliedEmailAddress = 'suppliedemail@care.com';

    @testSetup static void createUkPremiumSeekerWithCase(){
		Test.startTest();
        Account a = new Account();
        a.RecordTypeId = IsRtId;
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
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = a.PersonEmail;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.Subject = 'Test Open Premium';
        c.ContactId = pc.id;
        insert c;
        Test.stopTest();
    }

    @testSetup static void createUkPremiumSeekerWithCase_DiffSuppliedEmail(){
        // Testing use case where Case.SuppliedEmail is different than in Account.PersonEmail
		Test.startTest();
        Account a = new Account();
        a.RecordTypeId = IsRtId;
        a.FirstName = 'OpenPremium';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998006';
        a.Language__pc = 'English';
        a.Locale__pc = 'en_GB';
        a.Status__pc = 'Open';
        a.Type__pc = 'Premium';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'uk';
        a.PersonEmail = 'openpremiumukdifemail@care.com';        
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        insert a;

        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = suppliedEmailAddress;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.Subject = 'Test Open Premium';
        c.ContactId = pc.id;
        insert c;
        Test.stopTest();
    }

    @testSetup static void createUkPremiumSeekerWithCase_ClosedNoSuppliedEmail(){
        // Setting up a closed member (closed members get member ids appended to their email); 
        // I'm also setting up the Case to not use a SuppliedEmail to force the code to use PersonEmail
        
		Test.startTest();
        Account a = new Account();
        a.RecordTypeId = IsRtId;
        a.FirstName = 'ClosedPremium';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998005';
        a.Language__pc = 'English';
        a.Locale__pc = 'en_GB';
        a.Status__pc = 'Closed';
        a.Type__pc = 'Premium';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'uk';
        a.PersonEmail = 'closedpremiumuk@care.com.999998005'; 
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        insert a;

        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = null;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.Subject = 'Test Open Premium';
        c.ContactId = pc.id;
        insert c;
        Test.stopTest();
    }    
    
    @testSetup static void createCaBasicSeekerWithCase(){
		Test.startTest();
 		Account a = new Account();
        a.RecordTypeId = IsRtId;
        a.FirstName = 'OpenBasic';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998002';
        a.Language__pc = 'English';
        a.Locale__pc = 'en_CA';
        a.Status__pc = 'Open';
        a.Type__pc = 'Basic';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'ca';
        a.PersonEmail = 'openbasicca@care.com';        
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        a.MembershipCreationDate__pc = date.today();

        insert a;

        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = a.PersonEmail;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.ContactId = pc.id;
        c.Subject = 'Test Open Basic';
        insert c;
        Test.stopTest();
    }

	@testSetup static void createDeBasicSeekerWithCase(){
		Test.startTest();
        Account a = new Account();
        a.RecordTypeId = IsRtId;
        a.FirstName = 'OpenBasic';
        a.LastName = 'TestOne';
        a.Global_Member_Id__c = '999998003';
        a.Language__pc = 'German';
        a.Locale__pc = 'de_DE';
        a.Status__pc = 'Open';
        a.Type__pc = 'Basic';
        a.MemberType__pc = 'Seeker';
        a.PersonMailingCountry = 'de';
        a.PersonEmail = 'openbasicde@care.com';        
        a.PersonHomePhone = '+44 20 7828 2840';
        a.Gender__pc = 'Male';
        a.MembershipCreationDate__pc = date.today();

        insert a;

        Contact pc = [SELECT id FROM Contact where AccountId = :a.id];
        
        Case c = new Case();
        c.SuppliedName = a.FirstName + ' ' + a.LastName;
        c.SuppliedEmail = a.PersonEmail;
        c.SuppliedPhone = a.PersonHomePhone;
        c.RecordTypeId = IeRtId;
        c.Status = 'New';
        c.ContactId = pc.id;
        c.Subject = 'Test Open Basic';
        c.Origin = 'Web';            
        insert c;
        Test.stopTest();
    }    

    @testSetup static void createUsBasicSeekerWithCase(){
		Test.startTest();
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
            	Origin = 'Web',
                RecordTypeId = scRtId              
            
            );
        
        insert c;
        Test.stopTest();

    }

    @testSetup static void createVoicemailCaseWithoutMember(){
		Test.startTest();
        
        Case c = new Case(
                Subject = 'Test Voicemail #1',
                Description = 'Test Description #1',
            	Origin = 'Voicemail',
                RecordTypeId = scRtId              
            );
        
        insert c;
        Test.stopTest();
    }

    @isTest static void TestVoicemailCaseWithoutMember() {
        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
                  	FROM Case WHERE Subject = 'Test Voicemail #1'];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
        System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
            

        
    }    
    
    @isTest static void TestOpenPremiumUk() {
        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c 
                  	FROM Case WHERE SuppliedEmail = 'openpremiumuk@care.com'];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
		System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
    }

    @isTest static void TestClosedPremiumUkWithBlankSuppliedEmail() {
        // Default TO logic dictates that when supplied email is blank, we should use Contact.Email
        // But if the member is closed, the member id should be stripped off the email address
        // This unit test tests this scenario

        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
	                  FROM Case WHERE Contact.Email = 'closedpremiumuk@care.com.999998005'];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
		System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
        System.AssertEquals(emailMessage.ToAddress,'closedpremiumuk@care.com');
    }

    @isTest static void TestOpenPremiumUk_DiffSuppliedEmail() {
		// Default TO should be set to Supplied Email
		// In this test, the Case.SuppliedEmail is different from Account.PersonEmail; 
		// the test confirms that Case.SuppliedEmail was used

        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
                  	FROM Case WHERE SuppliedEmail = :suppliedEmailAddress];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
		System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
        System.AssertEquals(emailMessage.ToAddress,suppliedEmailAddress); // confirm the suppliedemail address was used
    }    

    @isTest static void TestOpenBasicCa() {
        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
                  	FROM Case WHERE SuppliedEmail = 'openbasicca@care.com'];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
		System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
            

        
    }    

    @isTest static void TestOpenBasicDe() {
        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
                  	FROM Case WHERE SuppliedEmail = 'openbasicde@care.com'];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
		System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
            

        
    }    

    @isTest static void TestOpenPremiumUs() {
        Case c = [SELECT id,RecordTypeId,Member_Country__c,Status,Member_Account_Type__c,Member_Status__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c
                  	FROM Case WHERE SuppliedEmail = :TestUtil.NthDayPremiumSeekerEmail];

        //Create test data here
        Exception failureDuringExecution = null;
    
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => c.id, // Case Id here!!!
                'actionType' => 'SendEmail',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };
        
        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
    
        Test.startTest();
        try { (new DefaultEmailPublisherSettings()).onInitDefaults(defaultsSettings); }
        catch(Exception failure) { failureDuringExecution = failure; }
    
        Test.stopTest();
    
        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');
        
        // Inspect defaultsSettings object
       	QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = DefaultEmailPublisherSettings.getSendEmailDefaults(defaultsSettings);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

		Default_Email_Publisher_Setting__mdt mdt = DefaultEmailPublisherSettings.getMdt(c);
        
        System.assertNotEquals(null, mdt, 'Case did not match a MDT');
        System.AssertEquals(emailMessage.FromAddress,mdt.Default_From__c);
            

        
    }    

}