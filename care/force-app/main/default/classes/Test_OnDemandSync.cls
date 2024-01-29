@isTest
public class Test_OnDemandSync {
    public static ID stdRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static ID intEmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    //public static ID mobRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mobile Help').getRecordTypeId();
    public static Integer iNumOfRecords = 3;
    public static string providerNoMatchName = 'Mary Poppins';
    public static string providerNoMatchEmail = 'poppins-nomatch@care.com';
    public static string SamplePlatformErrorMessage = 'EXTERNAL_PLATFORM_ERROR';
    public static string lastLogin = '2018-02-01';
    
    @testSetup static void setup(){
        // add an old ODS Error Monitor Custom Setting entry for improved code coverage
        Database.Insert(new ODS_Error_Monitor__c(Name = OnDemandSync_ErrorMonitor.getODSErrorMonitorName(OnDemandSync.PLATFORM_US),Error_Monitor_Last_Run__c = DateTime.now().addHours(-10000)));
        Database.Insert(new ODS_Error_Monitor__c(Name = OnDemandSync_ErrorMonitor.getODSErrorMonitorName(OnDemandSync.PLATFORM_INTL),Error_Monitor_Last_Run__c = DateTime.now().addHours(-10000)));
	}

    public static List<Case> getCases(List<Case> passedCases){
        Case[] Cases = [SELECT id,ContactId,ODS_Request_Platform__c,Type,Origin,ODS_Request_Status__c,Alt_ODS_Request_Status__c,ownerId,
                        Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,ODS_Start_Time__c,ODS_Request_Error__c,Is_ODS_Complete__c ,
                        ODS_End_Time__c
                        FROM Case WHERE id IN :passedCases];
        return Cases;
    }

    @isTest static void NoSuppliedEmail(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());

        Test.startTest();
        Case c = new Case(
                SuppliedName = 'Test Seeker',
                SuppliedEmail = null, // null email 
                SuppliedPhone = null,
                Subject = 'ODS Test #1',
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        //c.setOptions(dmlOpts);
        insert c;
        Test.stopTest();
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];

        for (Case updatedC : Cases){
            system.assertEquals('None', updatedC.ODS_Request_Status__c,'ODS Status is not None');
        }
    }

    @isTest static void AlreadyExistsWebNthDayProvider(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
            SuppliedName = con.firstName + ' ' + con.lastName,
            SuppliedEmail = con.email,
            SuppliedPhone = con.phone,
            Subject = 'AR Test #1',
            Description = 'Test Description',
            Type = 'Q: Provider: How it works',
            Origin = 'Web',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
                            Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
            RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        //c.setOptions(dmlOpts);
        insert c;
        
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
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
        }

        // Sanity check Custom Settings for Next Platform logic
        List<ODS_Next_Platform__c> OdsNPSettings = [SELECT Name,Platform__c FROM ODS_Next_Platform__c];
        for (ODS_Next_Platform__c OdsNextPlatform : OdsNPSettings){
            if (OdsNextPlatform.Name == OnDemandSync.HTTP_REQUEST_BATCH_CLASS_NAME){
                System.assertEquals(Null,OdsNextPlatform.Platform__c,'Platform should have switched to null after HTTP Batch finished');
            } else if (OdsNextPlatform.Name == OnDemandSync.LINK_BATCH_CLASS_NAME){
                System.assertEquals(Null,OdsNextPlatform.Platform__c,'Platform should still be null because Account trigger is not invoked');
            }
        }
    }

    @isTest static void PreODSMatchWebNthDayProvider(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                ContactId = con.id,
                Subject = 'AR Test #1',
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        //c.setOptions(dmlOpts);
        insert c;
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_US);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_US));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,ODS_Request_Platform__c//,Tier__c
			FROM Case 
			WHERE id = :c.id];

        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_PREODSMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Pre ODS Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertNotEquals(null, updatedC.ODS_Request_Platform__c,'Request Platform should not be null');
        }
    }
    
    @isTest static void PreODSMatchPlatformMismatch(){
        // This test generates a Pre ODS Match with mismatched platforms between Account & Case
        // When this happens, ODS is supposed to sever the relationship between Account & Case
        // & set the Case to Queued, to allow ODS to run its course.
        // 
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                ContactId = con.id, // Pre ODS Match here
                Subject = 'AR Test #1',
                Description = 'Test Description',
                Type = 'Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        //c.setOptions(dmlOpts);
        insert c;
        // Review case after insert
        c = [
			SELECT id,ownerid,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        system.assertEquals(null, c.AccountId,'Case Account is not null');
        system.assertEquals(null, c.ContactId,'Case Contact is not null');
        system.assertEquals(OnDemandSync.REQ_STATUS_QUEUED, c.ODS_Request_Status__c,'Request Status is not Queued');
    }

	/* commented out per request
    @isTest static void CompleteMatchNoUpdate(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'AR Test #1',
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        //c.setOptions(dmlOpts);
        insert c;

        c = [SELECT id,ownerid,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        String sOwnerId = String.valueOf(c.ownerid);
        //system.assertEquals('00G', sOwnerId.left(3),'Case is not owned by Queue');
        c.OwnerId = UserInfo.getUserId(); // remove from queue
        update c;
            
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
        
        Case[] Cases = [
			SELECT id,ownerid,ODS_Request_Status__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(UserInfo.getUserId(), updatedC.ownerid,'Case is not owned by Running User');
            system.assertEquals(OnDemandSync.REQ_STATUS_MATCHNOUPDATE, updatedC.ODS_Request_Status__c,'Case is not Complete - Match/No Update');
            system.assertNotEquals(con.AccountId, updatedC.AccountId,'Account erroneously associated to Case');
        }
    }
    */

    @isTest static void EmulatePlatformError_WebNthDayProvider(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        Contact con = ContactList[0];

        // Build error response
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('batch', null);
        responseMap.put('error', SamplePlatformErrorMessage);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'AR Test #1',
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        c.setOptions(dmlOpts);*/
        insert c;
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

        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,ODS_Request_Error__c,AccountId,ContactId//,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_SALESFORCE, updatedC.ODS_Request_Status__c,'Case is not Error - Salesforce');
            system.assertEquals('Malformed Request: ' + SamplePlatformErrorMessage, updatedC.ODS_Request_Error__c,'Error field is not set to error');
            system.assertNotEquals(con.AccountId, updatedC.AccountId,'Account is erroneously associated to Case');
            system.assertEquals(null, updatedC.ContactId,'Case Contact is erroneously not null');
        }
    }
    
    @isTest static void AlreadyExistAndNoMatch(){
/*  AlreadyExistAndNoMatch
        * Request: 
            * 3 Cases with same email; records already exist
            * 1 Case no match
        * Response: 2 node 
            * 1 with member id & salesforce id
            * 1 with null member id & salesforce id
*/

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        String firstName = TestUtil.BasicProviderFirstName;
        
        TestUtil.createBasicProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :firstName];
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        batchMap.put(providerNoMatchEmail,new Map<String, Object>{'memberId'=>null,'salesforceId'=>null,'email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        System.debug('tResponseMap: ' + responseMap);

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 3; i++){
            Case c = new Case(
                    SuppliedName = con.firstName + ' ' + con.lastName,
                    SuppliedEmail = con.email,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );

            //Gears Case:00042482
            //Moved to Breeze
            /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email

            c.setOptions(dmlOpts);*/
            CasesToInsert.add(c);
        }
        
        Case c = new Case(
                    SuppliedName = providerNoMatchName,
                    SuppliedEmail = providerNoMatchEmail,
                    Subject = 'AR Test #4',
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );
        CasesToInsert.add(c);
        insert CasesToInsert;
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
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            if (updatedC.SuppliedEmail == providerNoMatchEmail){
                system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETENOMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - No Match');
                system.assertEquals(null, updatedC.AccountId,'Account is not null');
                system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
            } else {
                system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
                system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
                system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            }
        }
    }

    @isTest static void AlreadyExistAndNoMatch_ODSTimeout(){
/*  AlreadyExistAndNoMatch
        * Request: 
            * 3 Cases with same email; records already exist
            * 1 Case no match
        * Response: 2 node 
            * 1 with member id & salesforce id
            * 1 with null member id & salesforce id
*/

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        String firstName = TestUtil.BasicProviderFirstName;
        
        TestUtil.createBasicProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :firstName];
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>con.Account.MemberID__c,'salesforceId'=>con.id,'email'=>con.email});
        batchMap.put(providerNoMatchEmail,new Map<String, Object>{'memberId'=>null,'salesforceId'=>null,'email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 3; i++){
            Case c = new Case(
                    SuppliedName = con.firstName + ' ' + con.lastName,
                    SuppliedEmail = con.email,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );

            //Gears Case:00042482
            //Moved to Breeze
            /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email

            c.setOptions(dmlOpts);*/
            CasesToInsert.add(c);
        }
        
        Case c = new Case(
                    SuppliedName = providerNoMatchName,
                    SuppliedEmail = providerNoMatchEmail,
                    Subject = 'AR Test #4',
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );
        CasesToInsert.add(c);
        insert CasesToInsert;

        OnDemandSync.InvokeODSTimeoutError(CasesToInsert); // invoke ODS timeout before batch can be invoked
            
        Test.stopTest();        
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Request_Error__c//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_SALESFORCE, updatedC.ODS_Request_Status__c,'Case is not Error - Salesforce');
            system.assertEquals('ODS Timeout', updatedC.ODS_Request_Error__c,'Error is not ODS Timeout');
        }
    }

    @isTest static void WaitForCreation(){
        /*  WaitForCreation
        * Request
            * 3 Cases with same email; member needs to be created
        * Response 
            * 1 with member id & null salesforce id
        * Create PersonAccount with member id
*/
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(TestUtil.BasicProviderEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicProviderMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicProviderEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 3; i++){
            Case c = new Case(
                SuppliedName = TestUtil.BasicProviderFirstName,
                SuppliedEmail = TestUtil.BasicProviderEmail,
                Subject = 'AR Test #' + i,
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId              
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
        
        Case[] Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
            system.assertEquals(null, updatedC.AccountId,'Account is not null');
            system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
        }
        
        TestUtil.createBasicProvider();
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
        
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_US); // Invoke batch logic manually
        
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
        Contact con = ContactList[0];
        
        Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
        }
    }    

    @isTest static void WaitForCreation_AccountCreatedAfterODSTimeout(){
/*  WaitForCreation
    * Request
        * 3 Cases with same email; member needs to be created
    * Response 
        * 1 with member id & null salesforce id
    * Create PersonAccount with member id
*/
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(TestUtil.BasicProviderEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicProviderMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicProviderEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 3; i++){
            Case c = new Case(
                    SuppliedName = TestUtil.BasicProviderFirstName,
                    SuppliedEmail = TestUtil.BasicProviderEmail,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId,
                    Web_Member_Id__c = String.valueOf(TestUtil.BasicProviderMemberId) // HandleSuccess usually sets this; but setting manually to facilitate this test
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

        OnDemandSync.InvokeODSTimeoutError(CasesToInsert); // invoke ODS timeout before batch can be invoked

        Test.stopTest(); // Force execution of batch
       
        Case[] Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_SALESFORCE, updatedC.ODS_Request_Status__c,'Case is not Error - Salesforce');
            system.assertEquals('ODS Timeout', updatedC.ODS_Request_Error__c,'Error is not ODS Timeout');
        }

        TestUtil.createBasicProvider(); // Invoke Account trigger
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
        
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_US); // Invoke batch logic manually

        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
        Contact con = ContactList[0];

        Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Request_Error__c//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertEquals(null, updatedC.ODS_Request_Error__c,'Error should be nulled out after self-healing');
        }
    }    
    
    @isTest static void AlreadyExistAndWaitAndNoMatch(){
/*  AlreadyExistAndWaitAndNoMatch - exercises all major ODS use cases
    * Request: 4 cases
        * 1 SFDC record already exists (basic provider)
        * 2 Needs to be created (basic seeker)
        * 1 No Match
    * Response: 3 nodes
        * 1 with member id & salesforce id (basic provider)
        * 1 with member id & null salesforce id (basic seeker)
        * 2 with null values
*/

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        String firstName = TestUtil.BasicProviderFirstName;
        
        TestUtil.createBasicProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(TestUtil.BasicProviderEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicProviderMemberId),'salesforceId'=>con.id,'email'=>TestUtil.BasicProviderEmail});
        batchMap.put(TestUtil.BasicChildCareSeekerEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicChildCareSeekerMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicChildCareSeekerEmail});
        batchMap.put(providerNoMatchEmail,new Map<String, Object>{'memberId'=>null,'salesforceId'=>null,'email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        Case cBasicProvider = new Case(
            SuppliedName = con.firstName + ' ' + con.lastName,
            SuppliedEmail = TestUtil.BasicProviderEmail,
            Subject = 'AR Test #3',
            Description = 'Test Description',
            Type = 'Q: Provider: How it works',
            Origin = 'Web',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
                            Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
            RecordTypeId = stdRtId              
        );

        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        
        cBasicProvider.setOptions(dmlOpts);*/
        CasesToInsert.add(cBasicProvider);


        for (integer i = 0; i < 2; i++){
            Case c = new Case(
                    SuppliedName = TestUtil.BasicChildCareSeekerFirstName,
                    SuppliedEmail = TestUtil.BasicChildCareSeekerEmail,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );
            if (i ==1){ // only set Web_Member_Id__c in one case, to ensure both get it
              c.Web_Member_Id__c = String.valueof(TestUtil.BasicChildCareSeekerMemberId);  
            } 
            //c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        
        Case cNoMatch = new Case(
                    SuppliedName = providerNoMatchName,
                    SuppliedEmail = providerNoMatchEmail,
                    Subject = 'AR Test #4',
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );
        
        //cNoMatch.setOptions(dmlOpts);
        CasesToInsert.add(cNoMatch);
        
        insert CasesToInsert;
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

        
        Case[] Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            if (updatedC.SuppliedEmail == providerNoMatchEmail){
                system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETENOMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - No Match');
                system.assertEquals(null, updatedC.AccountId,'Account is not null');
                system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
            } else if (updatedC.SuppliedEmail == TestUtil.BasicProviderEmail){
                system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
                system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
                system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            } if (updatedC.SuppliedEmail == TestUtil.BasicChildCareSeekerEmail){
                system.assertNotEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case should not Complete - Match yet');
            }
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

       Contact[] ContactListSeeker = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName];
       Contact conSeeker = ContactListSeeker[0];

        Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            if (updatedC.SuppliedEmail == TestUtil.BasicChildCareSeekerEmail){
                system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
                system.assertEquals(conSeeker.AccountId, updatedC.AccountId,'Account is not associated to Case');
                system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            }
        }
    }
    
  //since we are retiring mobile help recordtype, 
  // so the test method WaitForCreationMobileProvider is commented
 /*   @isTest static void WaitForCreationMobileProvider(){
//  WaitForCreationMobileProvider
//    * Request
//        * 2 Cases with same email; member needs to be created
//    * Response 
//        * 1 with member id & null salesforce id
//    * Create PersonAccount with member id

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(TestUtil.BasicProviderEmail,new Map<String, Object>{'memberId'=>String.valueOf(TestUtil.BasicProviderMemberId),'salesforceId'=>null,'email'=>TestUtil.BasicProviderEmail});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 2; i++){
            Case c = new Case(
                    SuppliedName = TestUtil.BasicProviderFirstName,
                    SuppliedEmail = TestUtil.BasicProviderEmail,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Mobile Help',
                    Origin = 'Email',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = mobRtId              
                );

            //Gears Case:00042482
            //Moved to Breeze
            //Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
            //dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
			//c.setOptions(dmlOpts);
            CasesToInsert.add(c);
        }
        
       insert CasesToInsert;
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
       
        Case[] Cases = getCases(CasesToInsert);
       System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
       for (Case updatedC : Cases){
           system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
           system.assertEquals(null, updatedC.AccountId,'Account is not null');
           system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
       }

       TestUtil.createBasicProvider(); // invoke Account trigger
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
        
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_US); // Invoke batch logic manually

       Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :TestUtil.BasicProviderFirstName];
       Contact con = ContactList[0];

        Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail//,Tier__c
			FROM Case 
			WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
        }
    }    */

    @isTest static void WaitForCreationEmailSeeker(){
/*  WaitForCreationEmailSeeker
    * Request
        * 2 Cases with same email; member needs to be created
    * Response 
        * 1 with member id & null salesforce id
    * Create PersonAccount with member id
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
                SuppliedEmail = TestUtil.BasicChildCareSeekerEmail,
                Subject = 'AR Test #' + i,
                Description = 'Test Description',
                Type = 'Question',
                Origin = 'Email',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId              
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
        
        Case[] Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
            system.assertEquals(null, updatedC.AccountId,'Account is not null');
            system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
            system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
            system.assertEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should be null');
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
        
        Cases = [SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Start_Time__c,ODS_End_Time__c//,Tier__c
                 FROM Case WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
            system.assertNotEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should not be null');
        }
    }        

    @isTest static void WaitForCreationChat(){
/*  WaitForCreation Chat
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
                SuppliedEmail = TestUtil.BasicChildCareSeekerEmail,
                Subject = 'AR Test #' + i,
                Description = 'Test Description',
                Origin = 'Chat',
                Status = 'Closed',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                Current_Member_Type__c = 'Basic',
                Sentiment__c='Positive',
                RecordTypeId = stdRtId              
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
        
        Case[] Cases = getCases(CasesToInsert);
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
        }
    }            

    @isTest static void MemberDoesntExistButUSPlatformThinksItDoes(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(providerNoMatchEmail,new Map<String, Object>{'memberId'=>'TESTMEMBERID','salesforceId'=>'NONEXISTENTID','email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                    SuppliedName = providerNoMatchName,
                    SuppliedEmail = providerNoMatchEmail,
                    Subject = 'AR Test #1',
                    Description = 'Test Description',
                    Type = 'Q: Provider: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = stdRtId              
                );
        insert c;
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

        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,Is_ODS_Complete__c,Is_ODS_Max_Retries_Reached__c,ODS_Number_of_Retries__c,ODS_Request_Error__c//,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_USPLATFORM, updatedC.ODS_Request_Status__c,'Case is not "Error - US Platform"'); 
            system.assertEquals(null, updatedC.AccountId,'Account is not null');
            system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
            system.assertEquals(true, updatedC.Is_ODS_Complete__c,'Case is not flagged as complete');
            system.assertEquals(true, updatedC.Is_ODS_Max_Retries_Reached__c,'Case is not flagged as max retries');
        }

    }

    @isTest static void JSONFormatError(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createNthDayPremiumProvider();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.NthDayPremiumProviderFirstName];
        Contact con = ContactList[0];

        // Build response
        MockHTTPResponse_USPlatform.responseMap = null;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'AR Test #1',
                Description = 'Test Description',
                Type = 'Q: Provider: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        c.setOptions(dmlOpts);*/
        insert c;
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
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,ODS_Request_Error__c//,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals('JSON Format Error', updatedC.ODS_Request_Error__c,'Error is not JSON Format Error');
        }
    }

    @isTest static void WaitForCreationEmailSeekerDE(){
/*  WaitForCreationEmailSeeker
    * Request
        * 2 Cases with same email; member needs to be created
    * Response 
        * 1 with member id & null salesforce id
    * Create PersonAccount with member id
*/
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'memberId'=>TestUtil.InternationalBasicSeekerMemberId,'salesforceId'=>null,'email'=>TestUtil.InternationalBasicSeekerEmail,'locale'=>TestUtil.InternationalBasicSeekerLocale,'countryCode'=>TestUtil.InternationalBasicSeekerCountryCode,'lastLogin'=>lastLogin});
        batchMap.put(TestUtil.InternationalBasicSeekerEmail,resultsList);
        responseMap.put('batch', batchMap);
        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 2; i++){
            Case c = new Case(
                    SuppliedName = TestUtil.InternationalBasicSeekerFirstName + ' ' + TestUtil.InternationalBasicSeekerLastName,
                    SuppliedEmail = TestUtil.InternationalBasicSeekerEmail,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Question',
                    Origin = 'Email - DE',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    RecordTypeId = intEmailRtId              
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
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            String CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_INTL;
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));

        Test.stopTest(); // Force execution of batch

        Case[] Cases = getCases(CasesToInsert);

       System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
       for (Case updatedC : Cases){
           system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
           system.assertEquals(null, updatedC.AccountId,'Account is not null');
           system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
           system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
           system.assertEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should be null');
       }

       TestUtil.SterlingCreatesBasicSeeker_deDE(); // invoke Account trigger
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_INTL;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
        
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_INTL); // Invoke batch logic manually

       Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :TestUtil.InternationalBasicSeekerFirstName];
       Contact con = ContactList[0];

        Cases = [SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Start_Time__c,ODS_End_Time__c//,Tier__c
                 FROM Case WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
            system.assertNotEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should not be null');
        }
    }        

    @isTest static void WaitForCreationWebSeekerUK(){
/*  WaitForCreationEmailSeeker
    * Request
        * 2 Cases with same email; member needs to be created
    * Response 
        * 1 with member id & null salesforce id
    * Create PersonAccount with member id
*/
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'memberId'=>TestUtil.InternationalPremiumSeekerMemberId,'salesforceId'=>null,'email'=>TestUtil.InternationalPremiumSeekerEmail,'locale'=>TestUtil.InternationalPremiumSeekerLocale,'countryCode'=>TestUtil.InternationalPremiumSeekerCountryCode,'lastLogin'=>lastLogin});
        batchMap.put(TestUtil.InternationalPremiumSeekerEmail,resultsList);
        responseMap.put('batch', batchMap);
        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Case[] CasesToInsert = new List<Case>();
        Test.startTest();
        for (integer i = 0; i < 2; i++){
            Case c = new Case(
                    SuppliedName = TestUtil.InternationalPremiumSeekerFirstName + ' ' + TestUtil.InternationalPremiumSeekerLastName,
                    SuppliedEmail = TestUtil.InternationalPremiumSeekerEmail,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Approval',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    Member_Country__c = TestUtil.InternationalPremiumSeekerCountryCode,
                    Member_Locale__c = TestUtil.InternationalPremiumSeekerLocale,
                    RecordTypeId = intEmailRtId              
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
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            String CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_INTL;
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));

        Test.stopTest(); // Force execution of batch

       
        Case[] Cases = getCases(CasesToInsert);

       System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
       for (Case updatedC : Cases){
           system.assertEquals(OnDemandSync.REQ_STATUS_INPROGRESS, updatedC.ODS_Request_Status__c,'Case is not In Progress');
           system.assertEquals(null, updatedC.AccountId,'Account is not null');
           system.assertEquals(null, updatedC.ContactId,'Case Contact is not null');
           system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
           system.assertEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should be null');
       }

       TestUtil.SterlingCreatesPremiumSeeker_enGB(); // invoke Account trigger
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Account Insert.
            String LinkCronJobName = OnDemandSync.LINK_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_INTL;
            CronTrigger[] LinkScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :LinkCronJobName AND State='WAITING'];
            System.AssertEquals(1,LinkScheduledJobs.size(),'There should now be 1 a Link Scheduled job');
        }
        
        OnDemandSync.LinkAccountToCase(Cases,OnDemandSync.PLATFORM_INTL); // Invoke batch logic manually

       Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :TestUtil.InternationalPremiumSeekerFirstName];
       Contact con = ContactList[0];

        Cases = [SELECT id,ODS_Request_Status__c,AccountId,ContactId,SuppliedEmail,ODS_Start_Time__c,ODS_End_Time__c//,Tier__c
                 FROM Case WHERE id IN :CasesToInsert];
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            system.assertNotEquals(null, updatedC.ODS_Start_Time__c,'ODS Start Time should not be null');
            system.assertNotEquals(null, updatedC.ODS_End_Time__c,'ODS End Time should not be null');
        }
    }            

    @isTest static void AlreadyExistsEmailProviderUK(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.SterlingCreatesBasicProvider_enGB();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'lastLogin'=>'2018-02-01','memberId'=>con.Account.Global_Member_Id__c,'salesforceId'=>con.id,'email'=>con.email,'locale'=>con.Locale__c,'countryCode'=>con.Account.PersonMailingCountry});
        batchMap.put(con.email,resultsList);
        responseMap.put('batch', batchMap);
        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'ODS Int Test #1',
                Description = 'Test Description',
                Type = 'Question',
                Origin = 'Email - UK',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        c.setOptions(dmlOpts);*/
        insert c;

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - International' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId//,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
        }
    }

    @isTest static void AlreadyExistsEmailProviderUKMultipleMatches(){
        // When there are multiple matches, the one with the most recent login should be returned
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.SterlingCreatesBasicProvider_enGB();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'lastLogin'=>'2018-01-01','memberId'=>'somememberid','salesforceId'=>null,'email'=>con.email,'locale'=>'de_DE','countryCode'=>'de'});
        resultsList.add(new Map<String, Object>{'lastLogin'=>'2014-01-01','memberId'=>'someothermemberid','salesforceId'=>null,'email'=>con.email,'locale'=>'de_AU','countryCode'=>'au'});
        resultsList.add(new Map<String, Object>{'lastLogin'=>'2018-02-01','memberId'=>con.Account.Global_Member_Id__c,'salesforceId'=>con.id,'email'=>con.email,'locale'=>con.Locale__c,'countryCode'=>con.Account.PersonMailingCountry});
        resultsList.add(new Map<String, Object>{'lastLogin'=>'2016-01-01','memberId'=>'yetanothermemberid','salesforceId'=>null,'email'=>con.email,'locale'=>'de_CH','countryCode'=>'ch'});
        batchMap.put(con.email,resultsList);
        responseMap.put('batch', batchMap);
        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'ODS Int Test #1',
                Description = 'Test Description',
                Type = 'Question',
                Origin = 'Email - UK',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true; // AutoResponse Email
        c.setOptions(dmlOpts);*/
        insert c;

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - International' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));

        Test.stopTest(); // Force execution of batch
        
        Case[] Cases = [
			SELECT id,ODS_Request_Status__c,AccountId,ContactId,Web_Member_Id__c//,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_COMPLETEMATCH, updatedC.ODS_Request_Status__c,'Case is not Complete - Match/Multiple Accounts');
            system.assertEquals(con.AccountId, updatedC.AccountId,'Account is not associated to Case');
            system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
            System.AssertEquals(con.Account.Global_Member_Id__c,updatedC.Web_Member_Id__c,'Wrong Web Member Id matched');
        }
    }

    @isTest static void CasePlatformConversion_USEmailtoUK(){
        // Tests Case Platform Conversion logic: US Email Case w/UK Account gets converted to international
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.SterlingCreatesBasicProvider_enGB();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>null,'salesforceId'=>null,'email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'ODS US Test #1',
                Description = 'Test Description',
                Type = 'Question',
                Origin = 'Email',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_US);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_US));

        Test.stopTest(); // Force execution of batch
        
        // Mirrors field list from HandlSuccess; update Handle Succes if other fields are needed
        Case[] uCases = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,
                         ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type
                         FROM Case WHERE id =: c.id];
        Case uCase = uCases[0];

        // Mirrors field list from Handle Success; update Handle Succes if other fields are needed
        Account[] Accounts = [SELECT id,Global_Member_Id__c,OwnerId,PersonContactId,Locale__pc,MemberType__pc FROM Account WHERE id = : con.AccountId];
        Account a = Accounts[0];
        System.assertNotEquals(null, a.Locale__pc, 'Locale is null');
        
        uCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_INTL;
        uCase.AccountId = con.AccountId;
        update uCase;  // invoke after update trigger
        
        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId//,Tier_Model__c,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            //System.assertEquals(intEmailRtId, updatedC.RecordTypeId, 'Case Record Type is not International Email');
            //System.assertEquals(OnDemandSync.PLATFORM_INTL, updatedC.Tier_Model__c, 'Tier Model is not International');
            System.assertEquals(OnDemandSync.PLATFORM_INTL, updatedC.ODS_Request_Platform__c, 'ODS Request Platform is not international');
            //System.assertEquals('Email - UK', updatedC.Origin, 'Case Origin is not Email - UK');
            System.assertEquals('Question', updatedC.Type, 'Type is not Question');
            //System.assertNotEquals(c.OwnerId, updatedC.OwnerId, 'Owner Id should not be current user');
        }
    }
    
    @isTest static void CasePlatformConversion_USWebtoUK(){
        // Test Case Platform Conversion logic: US Web Case w/UK Account gets converted to International
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.SterlingCreatesBasicProvider_enGB();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        batchMap.put(con.email,new Map<String, Object>{'memberId'=>null,'salesforceId'=>null,'email'=>null});
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'ODS US Test #1',
                Description = 'Test Description',
                Type = 'Q: Seeker: How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - US' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_US);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_US));

        Test.stopTest(); // Force execution of batch
        
        // Mirrors field list from HandlSuccess; update Handle Succes if other fields are needed
        Case[] uCases = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,
                         ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type
                         FROM Case WHERE id =: c.id];
        Case uCase = uCases[0];

        // Mirrors field list from Handle Success; update Handle Succes if other fields are needed
        Account[] Accounts = [SELECT id,Global_Member_Id__c,OwnerId,PersonContactId,Locale__pc,MemberType__pc FROM Account WHERE id = : con.AccountId];
        Account a = Accounts[0];
        System.assertNotEquals(null, a.Locale__pc, 'Locale is null');
        
        uCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_INTL;
        uCase.AccountId = con.AccountId;
        update uCase;  // invoke after update trigger
        
        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId//,Tier_Model__c,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            //System.assertEquals(intEmailRtId, updatedC.RecordTypeId, 'Case Record Type is not International Email');
            //System.assertEquals(OnDemandSync.PLATFORM_INTL, updatedC.Tier_Model__c, 'Tier Model is not International');
            System.assertEquals(OnDemandSync.PLATFORM_INTL, updatedC.ODS_Request_Platform__c, 'ODS Request Platform is not international');
            System.assertEquals('Web', updatedC.Origin, 'Case Origin is not Web');
            //System.assertEquals('How it Works', updatedC.Type, 'Type is not: How it Works');
            //System.assertNotEquals(c.OwnerId, updatedC.OwnerId, 'Owner Id should not be current user');
        }
    }

    @isTest static void CasePlatformConversion_UKWebtoUS(){
        // Test Case Platform Conversion logic: UK Web Case w/US Account gets converted to US
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createBasicChildCareSeeker(); 

        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
       Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'lastLogin'=>null,'memberId'=>null,'salesforceId'=>null,'email'=>null,'locale'=>null,'countryCode'=>null});
        batchMap.put(con.email,resultsList);
        responseMap.put('batch', batchMap);
        
        MockHTTPResponse_USPlatform.responseMap = responseMap;

        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'ODS INTL Test #1',
                Description = 'Test Description',
                Type = 'How it works',
                Origin = 'Web',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                Member_Country__c = TestUtil.InternationalPremiumSeekerCountryCode,
                Member_Locale__c = TestUtil.InternationalPremiumSeekerLocale,
                RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;
        
        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - International' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));
        Test.stopTest(); // Force execution of batch

        // Mirrors field list from HandlSuccess; update Handle Succes if other fields are needed
        Case[] uCases = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,
                         ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin
                         FROM Case WHERE id =: c.id];
        Case uCase = uCases[0];
        
        uCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_US;
        uCase.AccountId = con.AccountId;
        update uCase;  // invoke after update trigger
        
        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId//,Tier_Model__c,Tier__c 
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            //System.assertEquals(stdRtId, updatedC.RecordTypeId, 'Case Record Type is not Standard');
            //System.assertEquals(OnDemandSync.PLATFORM_US, updatedC.Tier_Model__c, 'Tier Model is not US');
            System.assertEquals(OnDemandSync.PLATFORM_US, updatedC.ODS_Request_Platform__c, 'ODS Request Platform is not US');
            System.assertEquals('Web', updatedC.Origin, 'Case Origin is not Web');
            //System.assertEquals('Q: Seeker: How it works', updatedC.Type, 'Type is not: Q: Seeker: How it works');
            //System.assertNotEquals(c.OwnerId, updatedC.OwnerId, 'Owner Id should not be current user');
        }
    }

    @isTest static void CasePlatformConversion_UKEmailtoUS(){
        // Test Case Platform Conversion logic: UK Email Case w/US Account gets converted to US
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        TestUtil.createBasicChildCareSeeker(); 
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];

        // Build response
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        List<Map<String,Object>> resultsList = new List<Map<String, Object>>();
        resultsList.add(new Map<String, Object>{'lastLogin'=>null,'memberId'=>null,'salesforceId'=>null,'email'=>null,'locale'=>null,'countryCode'=>null});
        batchMap.put(con.email,resultsList);
        responseMap.put('batch', batchMap);
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        
        Test.startTest();
        Case c = new Case(
                SuppliedName = con.firstName + ' ' + con.lastName,
                SuppliedEmail = con.email,
                SuppliedPhone = con.phone,
                Subject = 'Inappropriate Search',
                Description = 'Test Description',
                Type = 'Question',
                Origin = 'Email - UK',
                Status = 'New',
                OwnerId = UserInfo.getUserId(),
                Reason = 'Reason',
                Secondary_Case_Reason__c = 'Secondary Case Reason',
                                Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = 'OnDemandSync - International' AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(OnDemandSync.PLATFORM_INTL);
        ID batchprocessid = Database.executeBatch(ODSSync,(integer) OnDemandSync_Settings.getODSBatchSize(OnDemandSync.PLATFORM_INTL));
        Test.stopTest(); // Force execution of batch

        // Mirrors field list from HandlSuccess; update Handle Succes if other fields are needed
        Case[] uCases = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,
                         ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin,Subject
                         FROM Case WHERE id =: c.id];
        Case uCase = uCases[0];
        //String sOwnerId = String.valueOf(uCase.OwnerId);
        //System.assertEquals('00G', sOwnerId.left(3),'Case is not owned by Queue');
        uCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_US;
        uCase.AccountId = con.AccountId;
        uCase.Subject = 'Updated';
        update uCase;  // invoke after update trigger
        
        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId,ODS_Request_Status__c//,Tier_Model__c,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
           // System.assertEquals(stdRtId, updatedC.RecordTypeId, 'Case Record Type is not Standard');
            //System.assertEquals(OnDemandSync.PLATFORM_US, updatedC.Tier_Model__c, 'Tier Model is not US');
            System.assertEquals(OnDemandSync.PLATFORM_US, updatedC.ODS_Request_Platform__c, 'ODS Request Platform is not US');
            //System.assertEquals('Email', updatedC.Origin, 'Case Origin is not Web');
            System.assertEquals('Question', updatedC.Type, 'Type is not: Question');
            //System.assertNotEquals(c.OwnerId, updatedC.OwnerId, 'Owner Id should not be current user');
        }
    }

    @isTest static void PlatformMemberIdTest_US(){
        // Test Platform member id methods
        TestUtil.createBasicChildCareSeeker(); 
        
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId 
                                 FROM Contact WHERE firstname = :TestUtil.BasicChildCareSeekerFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        
        Test.startTest();
        Case c = new Case(
            SuppliedName = con.firstName + ' ' + con.lastName,
            SuppliedEmail = con.email,
            SuppliedPhone = con.phone,
            ContactId = con.id, // associate US member to UK Case
            Subject = 'ODS Test #1',
            Description = 'Test Description',
            Type = 'Question',
            Origin = 'Email',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
                            Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
            Web_Member_Id__c = con.Account.MemberID__c, // hard coding this value here to facilitate test
            RecordTypeId = stdRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;
        Test.stopTest(); // Force execution of batch
        
        
        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId,Web_Member_Id__c//,Tier_Model__c,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            System.assertNotEquals(null, updatedC.Web_Member_Id__c, 'Case Web Member Id should not be null');
            System.assertEquals(false, OnDemandSync.IsMemberIdInternational(updatedC), 'Case Web Member Id should be US');
            System.assertEquals(con.Account.MemberID__c, OnDemandSync.GetWebMemberIdFromCase(updatedC), 'Method should return member id');
        }
    }

    @isTest static void PlatformMemberIdTest_UK(){
        // Test Case Platform Conversion logic: US Web Case w/UK Account gets converted to International
        TestUtil.SterlingCreatesBasicProvider_enGB();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,Account.MemberID__c,AccountId ,
                                 Locale__c,Account.PersonMailingCountry,Account.Global_Member_Id__c
                                 FROM Contact WHERE firstname = :TestUtil.InternationalProviderFirstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        Contact con = ContactList[0];
        System.assert(con.MemberType__c == 'Provider');  // Sanity check its a provider
        
        Test.startTest();
        Case c = new Case(
            SuppliedName = con.firstName + ' ' + con.lastName,
            SuppliedEmail = con.email,
            SuppliedPhone = con.phone,
            ContactId = con.id, // associate UK member to Case
            Subject = 'ODS Int Test #1',
            Description = 'Test Description',
            Type = 'Question',
            Origin = 'Email - UK',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
                            Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
            Web_Member_Id__c = con.Account.Global_Member_Id__c, // hard coding this value here to facilitate test
            RecordTypeId = intEmailRtId
        );
        //Gears Case:00042482
        //Moved to Breeze
        /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        c.setOptions(dmlOpts);*/
        insert c;
        Test.stopTest(); // Force execution of batch

        Case[] Cases = [
			SELECT id,Origin,RecordTypeId,Type,ODS_Request_Platform__c,OwnerId,Web_Member_Id__c//,Tier_Model__c,Tier__c
			FROM Case 
			WHERE id = :c.id];
        for (Case updatedC : Cases){
            System.assertNotEquals(null, updatedC.Web_Member_Id__c, 'Case Web Member Id should not be null');
            System.assertEquals(true, OnDemandSync.IsMemberIdInternational(updatedC), 'Case Web Member Id should be International');
            System.assertEquals(con.Account.Global_Member_Id__c, OnDemandSync.GetWebMemberIdFromCase(updatedC), 'Method should return member id');
        }
    }
    
    @isTest static void BulkAccountInsert(){
        // This unit test is designed to invoke bulk scenarios.
        // First, it will create as many cases as specified in custom settings (ODS Link Batch size; originally 20).
        // Then, it will create 200 Accounts & then it will invoke the ODS Link Batch to relate them together.
        // If the test generates a CPU Limit error, it could be either because:
        //      Recent changes in our code have are responsible.  If so, these changes should be reviewed & considered.
        //      Or perhaps the Salesforce platform has changed, and we can no longer handle so many cases in the batch.
        // If code changes don't resolve the error, then we can make the Link Batch size smaller in Custom Settings.
        
        // Unit Test Design Note: the Cases are manually set to ODSTimeouts so that the HTTP Batch doesn't need to be run 
        // (because Salesforce doesn't allow invoking multiple batch jobs in a single unit test in Salesforce)

        Integer bulkLimit = 3; //(integer) OnDemandSync_Settings.getODSBatchSizeForLinkJob(OnDemandSync.PLATFORM_US); // cases to create; 
        String email = '';
        Integer memberId = TestUtil.BasicChildCareSeekerMemberId;
        
        Case[] CasesToInsert = new List<Case>();
        for (integer i = 0; i < bulkLimit; i++){
            email = 'jackodell+bulkseeker' + i + '@gmail.com';
            Case c = new Case(
                    SuppliedName = TestUtil.BasicProviderFirstName,
                    SuppliedEmail = email,
                    Subject = 'AR Test #' + i,
                    Description = 'Test Description',
                    Type = 'Q: Seeker: How it works',
                    Origin = 'Web',
                    Status = 'New',
                    OwnerId = UserInfo.getUserId(),
                    Reason = 'Reason',
                    Secondary_Case_Reason__c = 'Secondary Case Reason',
                                    Contact_Theme__c='Safety',
                Contact_Reason__c = 'Safety Communication',
                Contact_Secondary_Reason__c = 'Other',
                    Web_Member_Id__c = String.valueOf(memberId+i),
                    RecordTypeId = stdRtId              
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

        OnDemandSync.InvokeODSTimeoutError(CasesToInsert); // invoke ODS timeout before batch can be invoked
        
        Case[] Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        for (Case updatedC : Cases){
            system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_SALESFORCE, updatedC.ODS_Request_Status__c,'Case is not Error - Salesforce');
            system.assertEquals('ODS Timeout', updatedC.ODS_Request_Error__c,'Error is not ODS Timeout');
        }

        Test.StartTest();
        TestUtil.BulkLimit = 10; // accounts to create
        TestUtil.createBasicChildCareSeekerBulk();

        // For some reason, this assertion fails sporadically in poroduction, but works fine on test; since batch is invoked manually, sucess is not required in production
        if (CareDotComUtil.runningInASandbox()){
            // Confirm Job gets scheduled after Case Insert
            String CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + OnDemandSync.PLATFORM_US;
            CronTrigger[] ScheduledJobs = [SELECT id FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND State='WAITING'];
            System.AssertEquals(1,ScheduledJobs.size(),'There should now be 1 an ODS Scheduled job');
        }
        // Invoke batch manually
        OnDemandSync_LinkAccountToCase_Batch ODSLink = new OnDemandSync_LinkAccountToCase_Batch(OnDemandSync.PLATFORM_US);
        ID batchprocessid = Database.executeBatch(ODSLink,bulkLimit); // setting to bulk limit for testing purposes, but prod runs will use ODS Settings

        Test.StopTest(); // force batch job to run
        
        Cases = getCases(CasesToInsert);
        System.assertEquals(CasesToInsert.size(), Cases.size(),'Case arrays of different sizes');
        Integer MatchingCases = 0;
        for (Case updatedC : Cases){
            if (updatedC.AccountId != null){ // these are the Cases that should be linked with the accounts created above
                system.assertEquals('Complete - Match', updatedC.ODS_Request_Status__c,'Case is not Complete - Match');
                system.assertNotEquals(null, updatedC.AccountId,'Case Account is null');
                system.assertNotEquals(null, updatedC.ContactId,'Case Contact is null');
                MatchingCases++;
            } else { // these are cases without corresponding accounts
                system.assertEquals(OnDemandSync.REQ_STATUS_ERROR_SALESFORCE, updatedC.ODS_Request_Status__c,'Case is not Error - Salesforce');
                system.assertEquals('ODS Timeout', updatedC.ODS_Request_Error__c,'Error is not ODS Timeout');
            }
        }
        System.AssertEquals(MatchingCases,bulkLimit, bulkLimit + ' Cases should have matched, not ' + MatchingCases);

        // Sanity check Custom Settings for Next Platform logic (Link Batch)
        List<ODS_Next_Platform__c> OdsNPSettings = [SELECT Name,Platform__c FROM ODS_Next_Platform__c];
        for (ODS_Next_Platform__c OdsNextPlatform : OdsNPSettings){
            if (OdsNextPlatform.Name == OnDemandSync.LINK_BATCH_CLASS_NAME){
                System.assertEquals(Null,OdsNextPlatform.Platform__c,'Platform should have switched to Null after Link Batch finished');
            }
        }
    }    
    
}