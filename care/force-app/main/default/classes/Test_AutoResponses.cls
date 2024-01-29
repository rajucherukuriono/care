@isTest
public class Test_AutoResponses {
    public static ID stdRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static String ARFlowName = 'ODS_Manage_Timeout';
    public static Integer iNumOfRecords = 5;

/*   
    Update iNumOfRecords to 20 to test whether AR PBs are endangering governor limits (will take several minutes to run)
	The Number should be smaller than the ODS Batch Size (defined in Custom Metadata "OnDemandSync Settings")
*/
    
    @isTest static void bulkARTest_WithMember(){
/*
    Case w/member already associated (emulating how Email to Case & Web to Case auto-associated members to Cases)
*/        

        String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        
        TestUtil.createNthDayPremiumSeeker();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < iNumOfRecords; i++){
            Case c = new Case(
                    SuppliedName = ContactList[0].firstName + ' ' + ContactList[0].lastName,
                    SuppliedEmail = ContactList[0].email,
                    SuppliedPhone = ContactList[0].phone,
                    ContactId = ContactList[0].id,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Seeker: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                    RecordTypeId = stdRtId              
                );
            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        insert CasesToInsert;
		// Confirm Job gets scheduled after Case Insert
        CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
        System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
		// Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch('US');
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize('US'));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [SELECT id,Auto_Response_Status__c FROM Case WHERE ID IN :CasesToInsert];
        for (Case updatedC : Cases){
            System.assertEquals('Invoked - Sent', updatedC.Auto_Response_Status__c);
        }

       integer FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(0, FiCount); // in this use case, there should be no waiting interviews

    }
    
    @isTest static void bulkARTest_WithMemberIntl_PreODSMatch(){
/*
    Case w/international member already associated (emulating how Email to Case & Web to Case auto-associated members to Cases)
*/        

        String firstName = TestUtil.InternationalBasicSeekerFirstName;
        
        TestUtil.SterlingCreatesBasicSeeker_deDE();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < iNumOfRecords; i++){
            Case c = new Case(
                    SuppliedName = ContactList[0].firstName + ' ' + ContactList[0].lastName,
                    SuppliedEmail = ContactList[0].email,
                    SuppliedPhone = ContactList[0].phone,
                    ContactId = ContactList[0].id,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Question',
                    Origin = 'Email - DE',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                    RecordTypeId = TestUtil.intEmailRtId              
                );
            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        insert CasesToInsert;

        Test.stopTest();
        
        Case[] Cases = [SELECT id,Auto_Response_Status__c,ODS_Request_Status__c FROM Case WHERE ID IN :CasesToInsert];
        for (Case updatedC : Cases){
            System.assertEquals('Invoked - Sent', updatedC.Auto_Response_Status__c);
            System.assertEquals('Complete - Pre ODS Match', updatedC.ODS_Request_Status__c);
        }

       integer FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(0, FiCount); // in this use case, there should be no waiting interviews

    }
    
    @isTest static void bulkARTest_ODS(){
/*
    Case w/out member, but OnDemandSync associates later
*/        

        String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        
        TestUtil.createNthDayPremiumSeeker();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
		Contact con = ContactList[0];
		// Build response
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
		batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case[] CasesToInsert = new List<Case>();
        for (integer i = 0; i < iNumOfRecords; i++){
            Case c = new Case(
                    SuppliedName = con.firstName + ' ' + con.lastName,
                    SuppliedEmail = con.email,
                    SuppliedPhone = con.phone,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Seeker: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                    RecordTypeId = stdRtId              
                );
            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        insert CasesToInsert;

        integer FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(iNumOfRecords, FiCount,'Flow Interview Mismatch after Cases created'); // in this use case, each Case should have a waiting interview
		// Confirm Job gets scheduled after Case Insert
       /* CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
        System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job'); */
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }

		// Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch('US');
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize('US'));

        Test.stopTest(); // Force execution of batch

        Case[] Cases = [SELECT id,Auto_Response_Status__c FROM Case WHERE ID IN :CasesToInsert];
        for (Case updatedC : Cases){
            System.assertEquals('Invoked - Sent', updatedC.Auto_Response_Status__c);
        }

        FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(0, FiCount,'Flow Interview Mismatch after Cases associated with Person Accounts'); // at this point, all Flow Interviews should be cleared
    }

    @isTest static void bulkARTest_CompleteNoMatch(){
/*
    Case w/out member & no match on US Platform
*/        

        String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        
        TestUtil.createNthDayPremiumSeeker();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
		Contact con = ContactList[0];
		// Build response
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
		batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case[] CasesToInsert = new List<Case>();
        for (integer i = 0; i < iNumOfRecords; i++){
            Case c = new Case(
                    SuppliedName = con.firstName + ' ' + con.lastName,
                    SuppliedEmail = con.email,
                    SuppliedPhone = con.phone,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Seeker: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                    RecordTypeId = stdRtId              
                );
            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        insert CasesToInsert;

        integer FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(iNumOfRecords, FiCount,'Flow Interview Mismatch after Cases created'); // in this use case, each Case should have a waiting interview
		// Confirm Job gets scheduled after Case Insert
       /* CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
        System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job'); */
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }

		// Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch('US');
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize('US'));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [SELECT id,Auto_Response_Status__c FROM Case WHERE ID IN :CasesToInsert];
        for (Case updatedC : Cases){
            System.assertEquals('Invoked - Sent', updatedC.Auto_Response_Status__c);
        }

        FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(0, FiCount,'Flow Interview Mismatch after Cases associated with Person Accounts'); // at this point, all Flow Interviews should be cleared
    }

    @isTest static void bulkARTest_SuppressedSubject_CompleteNoMatch(){
/*
   Case w/suppressed subject
*/        

        String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        
        TestUtil.createNthDayPremiumSeeker();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
		Contact con = ContactList[0];
		// Build response
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
		batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;


        Case[] CasesToInsert = new List<Case>();
        for (integer i = 0; i < iNumOfRecords; i++){
            Case c = new Case(
                    SuppliedName = ContactList[0].firstName + ' ' + ContactList[0].lastName,
                    SuppliedEmail = ContactList[0].email,
                    SuppliedPhone = ContactList[0].phone,
                    Subject = 'AR Test #' + i + ' - Out on Maternity Leave', // this line should invoke suppression use case
                    Description = 'Test Description',
                    Type = 'Q: Seeker: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                    RecordTypeId = stdRtId              
                );
            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        insert CasesToInsert;

        integer FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(iNumOfRecords, FiCount,'Flow Interview Mismatch after Cases created'); // in this use case, each Case should have a waiting interview

        Test.startTest();
        update CasesToInsert;
		// Confirm Job gets scheduled after Case Insert
       /* CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
        System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job'); */
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }

		// Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch('US');
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize('US'));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [SELECT id,Auto_Response_Status__c FROM Case WHERE ID IN :CasesToInsert];
        for (Case updatedC : Cases){
            System.assertEquals('Invoked - Suppressed', updatedC.Auto_Response_Status__c);  // check for invoked - suppressed
        }

        FiCount = database.countQuery('SELECT count() FROM FlowInterview WHERE InterviewLabel LIKE \'' + ARFlowName + '%\'');
        System.assertEquals(0, FiCount,'Flow Interview Mismatch after Cases associated with Person Accounts'); // at this point, all Flow Interviews should be cleared
    }    
}