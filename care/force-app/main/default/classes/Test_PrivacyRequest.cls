@isTest
public class Test_PrivacyRequest {
    
	public static ID hpRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HomePay Privacy').getRecordTypeId();
    public static String HomePayName = 'TestHomePay Name';
    public static String HomePayEmail = 'testhomepayemail@care.com';
	public static String SuppliedName = 'TestSupplied Name';
    public static String SuppliedEmail = 'testsuppliedemail@care.com';
    public static String SuppliedMemberId = '999999872';
    public static String CSRName = 'Test CSR Rep Name';
    public static String CSREmail = 'testcsremail@care.com';
	public static String CSRName_Update = 'Test CSR Rep Name For Update';
    public static String CSREmail_Update = 'testcsremailforupdate@care.com';
	public static String RequestWithoutCaseName = 'RequestWithoutCase Name';
    public static String RequestWithoutCaseEmail = 'requestwithoutcaseemail@care.com';

    public static Privacy_Audit_Log__c getPal(Privacy_Request__c pr){
        Privacy_Audit_Log__c pal = [SELECT Id,Name__c,Email__c,Request_Date__c,Request_Status__c,CSR_Name__c,CSR_Email__c FROM Privacy_Audit_Log__c WHERE PR_Name__c = :pr.id];
        System.assertEquals(pr.Name__c,pal.Name__c, 'Name value is not correct. PR & PAL values should be the same.');
        System.assertEquals(pr.Email__c, pal.Email__c, 'Email value is not correct. PR & PAL values should be the same.');
		System.assertEquals(pr.Request_Date__c, pal.Request_Date__c, 'Date value is not correct. PR & PAL values should be the same.');
        System.assertEquals(pr.Request_Status__c, pal.Request_Status__c, 'Status value is not correct. PR & PAL values should be the same.');
        System.assertEquals(pr.CSR_Name__c, pal.CSR_Name__c, 'CSR Name value is not correct. PR & PAL values should be the same.');
        System.assertEquals(pr.CSR_Email__c, pal.CSR_Email__c, 'CSR Email value is not correct. PR & PAL values should be the same.');
		return pal;
    }
    
    public static Privacy_Request__c getPr(ID prId){
        Privacy_Request__c pr = [SELECT id,Name__c,Email__c,Universal_Member_Id__c,Request_Date__c,Request_Status__c,CSR_Name__c,CSR_Email__c,Data_Categories_Display_Friendly__c FROM Privacy_Request__c WHERE id=:prId];
		return pr;
    }

    @isTest static void Case_M_Fields() {
		// Sanity check that Case M fields get copied to PR record on PR Insert & Update.
		// Sanity check that PR fields get copied to PAL on PR Insert & Update
        
        Case c = new Case();
        c.recordTypeId = hpRtId;
        c.Name_m__c = HomePayName;
        c.Email_m__c = HomePayEmail;
        insert c;
        
        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Source_System__c = 'HomePay';
        pr.Case__c = c.id;
        insert pr;
        
        pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Name,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals(HomePayName,pr.Name__c, 'Name value is not correct. It should have inherited value from C.Name_m__c.');
        System.assertEquals(HomePayEmail, pr.Email__c, 'Email value is not correct. It should have inherited value from C.Email_m__c.');
        
        Privacy_Audit_Log__c pal = getPal(pr);
        
        Case c2 = new Case();
        c2.recordTypeId = hpRtId;
        c2.Name_m__c = 'Foo Foo';
        c2.Email_m__c = 'foo@care.com';
        insert c2;
        
        pr.Case__c = c2.id;
        update pr;
        
		pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertNotEquals(HomePayName,pr.Name__c, 'Name value is not correct. It should have inherited value from C.Name_m__c.');
        System.assertNotEquals(HomePayEmail, pr.Email__c, 'Email value is not correct. It should have inherited value from C.Email_m__c.');

        pal = getPal(pr);
    }

    @isTest static void Case_Account_Fields() {
		// Sanity check that Case Account Fields get copied from Case.Account to PR
		// Sanity check that PR fields get copied to PAL on PR Insert & Update
		// Update 2020-01-14: Add logic to check newly added phase 2 fields (CSR Name, CSR Rep, Fulfillment Date Rationale)

        TestUtil.createBasicProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
		Contact con = ContactList[0];
        Case c = new Case(
			ContactId = con.id,
            Subject = 'CCPA Test',
            Description = 'Test Description',
            Type = 'CCPA',
            Origin = 'Email',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            RecordTypeId = Test_OnDemandSync.stdRtId
        );
        insert c;
        
        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Source_System__c = 'US Platform';
        pr.Case__c = c.id;
        pr.CSR_Name__c = CSRName;
        pr.CSR_Email__c = CSREmail;
        insert pr;

        pr = getPr(pr.id);// pr = [SELECT id,Name__c,Email__c,Universal_Member_Id__c,Request_Date__c,Request_Status__c,CSR_Name__c,CSR_Email__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals(con.FirstName + ' ' + con.LastName,pr.Name__c, 'Name value is not correct. It should have inherited value from Contact.');
        System.assertEquals(con.Email, pr.Email__c, 'Email value is not correct. It should have inherited value from Contact.');
        System.assertEquals(con.Account.MemberID__c, pr.Universal_Member_Id__c, 'Member Id value is not correct. It should have inherited value from Contact.');

        Privacy_Audit_Log__c pal = getPal(pr);
        
        Case c2 = new Case();
        c2.recordTypeId = hpRtId;
        c2.Name_m__c = 'Foo Foo';
        c2.Email_m__c = 'foo@care.com';
        insert c2;
        
        pr.Case__c = c2.id;
        pr.CSR_Name__c = CSRName_Update;
        pr.CSR_Email__c = CSREmail_Update;
        update pr;
        
        pr = getPr(pr.id); //pr = [SELECT id,Name__c,Email__c,Universal_Member_Id__c,Request_Date__c,Request_Status__c,CSR_Name__c,CSR_Email__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertNotEquals(con.FirstName + ' ' + con.LastName,pr.Name__c, 'Name value is not correct. It should have inherited value from Case.');
        System.assertNotEquals(con.Email, pr.Email__c, 'Email value is not correct. It should have inherited value from Case.');
        System.assertNotEquals(con.Account.MemberID__c, pr.Universal_Member_Id__c, 'Member Id value is not correct. It should have inherited value from Case.');

		pal = getPal(pr);
    }

    @isTest static void Case_Supplied_Fields() {
		// Sanity check that Case Supplied Fields get copied from Case to PR
		// Sanity check that PR fields get copied to PAL on PR Insert & Update

        Case c = new Case(
            SuppliedName = SuppliedName,
            SuppliedEmail = SuppliedEmail,
			Web_Member_Id__c = SuppliedMemberId,
            Subject = 'CCPA Test',
            Description = 'Test Description',
            Type = 'CCPA',
            Origin = 'Email',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            RecordTypeId = Test_OnDemandSync.stdRtId
        );
        insert c;
        
        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Case__c = c.id;
        pr.Source_System__c = 'Galore';
        insert pr;

        pr = getPr(pr.id); //pr = [SELECT id,Name__c,Email__c,Universal_Member_Id__c,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals(SuppliedName,pr.Name__c, 'Name value is not correct. It should have inherited value from Case.');
        System.assertEquals(SuppliedEmail, pr.Email__c, 'Email value is not correct. It should have inherited value from Case.');
        System.assertEquals(SuppliedMemberId, pr.Universal_Member_Id__c, 'Member Id value is not correct. It should have inherited value from Case.');

        Privacy_Audit_Log__c pal = getPal(pr);

        Case c2 = new Case();
        c2.recordTypeId = hpRtId;
        c2.Name_m__c = 'Foo Foo';
        c2.Email_m__c = 'foo@care.com';
        insert c2;
        
        pr.Case__c = c2.id;
        update pr;
        
        pr = getPr(pr.id);//pr = [SELECT id,Name__c,Email__c,Universal_Member_Id__c,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertNotEquals(SuppliedName,pr.Name__c, 'Name value is not correct. It should have inherited value from Case.');
        System.assertNotEquals(SuppliedEmail, pr.Email__c, 'Email value is not correct. It should have inherited value from Case.');
        System.assertNotEquals(SuppliedMemberId, pr.Universal_Member_Id__c, 'Member Id value is not correct. It should have inherited value from Case.');

        pal = getPal(pr);
        
    }

    @isTest static void RequestWithoutCase(){
 		// Sanity check that fields manually entered in PR record are kept on PR Insert & Update.
		// Sanity check that PR fields get copied to PAL on PR Insert & Update
        
        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Source_System__c = 'HomePay';
        pr.Name__c = RequestWithoutCaseName;
        pr.Email__c = RequestWithoutCaseEmail;
        insert pr;
        
        pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Name,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals(RequestWithoutCaseName,pr.Name__c, 'Name value is not correct. It should have kept the values that were added manually.');
        System.assertEquals(RequestWithoutCaseEmail, pr.Email__c, 'Email value is not correct. It should have kept the values that were added manually.');
        
        Privacy_Audit_Log__c pal = getPal(pr);
        
        pr.Name__c = 'Foo Foo';
        pr.Email__c = 'foo@care.com';
        update pr;
        
		pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertNotEquals(RequestWithoutCaseName,pr.Name__c, 'Name value is not correct. It should have kept the values that were added manually.');
        System.assertNotEquals(RequestWithoutCaseEmail, pr.Email__c, 'Email value is not correct. It should have kept the values that were added manually.');

        pal = getPal(pr);       
    }

    @isTest static void RequestWithValuesAndCase(){
 		// Sanity check that fields manually entered in PR record are kept on PR Insert & Update.
		// Sanity check that PR fields get copied to PAL on PR Insert & Update
		// Sanity check that Case values get inherited if they change
        
        TestUtil.createBasicProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
		Contact con = ContactList[0];
        Case c = new Case(
			ContactId = con.id,
            Subject = 'CCPA Test',
            Description = 'Test Description',
            Type = 'CCPA',
            Origin = 'Email',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            RecordTypeId = Test_OnDemandSync.stdRtId
        );
        insert c;


        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Source_System__c = 'HomePay';
        pr.Name__c = RequestWithoutCaseName;
        pr.Email__c = RequestWithoutCaseEmail;
        pr.Case__c = c.id;
        insert pr;
        
        pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Name,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals(RequestWithoutCaseName,pr.Name__c, 'Name value is not correct. It should have kept the values that were added manually.');
        System.assertEquals(RequestWithoutCaseEmail, pr.Email__c, 'Email value is not correct. It should have kept the values that were added manually.');
        
        Privacy_Audit_Log__c pal = getPal(pr);
        
        pr.Name__c = 'Foo Foo';
        pr.Email__c = 'foo@care.com';
        update pr;
        
		pr = getPr(pr.id); //        pr = [SELECT id,Name__c,Email__c,Request_Date__c,Request_Status__c FROM Privacy_Request__c WHERE id=:pr.id];
        System.assertEquals('Foo Foo',pr.Name__c, 'Name value is not correct. It should have kept the values that were added manually.');
        System.assertEquals('foo@care.com', pr.Email__c, 'Email value is not correct. It should have kept the values that were added manually.');

        pal = getPal(pr);       
    }

    @isTest static void RequestWithDataCategories(){
 		// Sanity check that fields manually entered in PR record are kept on PR Insert & Update.
		// Sanity check that PR fields get copied to PAL on PR Insert & Update
        
        Privacy_Request__c pr = new Privacy_Request__c();
        pr.Request_Date__c = DateTime.now();
        pr.Request_Status__c = 'Requested';
        pr.Source_System__c = 'HomePay';
        pr.Name__c = RequestWithoutCaseName;
        pr.Email__c = RequestWithoutCaseEmail;
        pr.Data_Categories__c = 'other';
        insert pr;
        
        pr = getPr(pr.id);
        System.assertNotEquals(null,pr.Data_Categories_Display_Friendly__c, 'Display Friendly Data Categories should not be null.');
        
        pr.Name__c = 'Foo Foo';
        pr.Email__c = 'foo@care.com';
        pr.Data_Categories__c = '';
        update pr;
        
		pr = getPr(pr.id);
        System.assertEquals(null,pr.Data_Categories_Display_Friendly__c, 'Display Friendly Data Categories should be null.');

    }

    
}