@isTest
public class Test_OnEmailReplyToBucReassignToQueue {
    public static ID scRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static ID bucRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BUC').getRecordTypeId();
    Public static Id linkedInMailRecId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('International BUC Task').getRecordTypeId();
    Public static Id linkedInMessageRecId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('EFMP').getRecordTypeId();
    Public static Id defaultRecId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    private static AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
    @testSetup static void createBucCaseAssignToUserAndClose(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        /*
Test Notes:
* Create BUC Case; closed
*/
        String firstName = TestUtil.NthDayPremiumSeekerFirstName;
        TestUtil.createNthDayPremiumSeeker();
        Test.startTest();
        Contact[] ContactList = [SELECT id,MemberType__c,Account.AccountId__c,type__c,Account.isPersonAccount,firstName,lastName,email,phone,USAA_Member__c
                                 FROM Contact WHERE firstname = :firstName];
        System.assert(ContactList.size() == 1); // Did contact get created?
        System.assert(ContactList[0].type__c == 'Premium');  // Sanity check that the premium seeker is actually a premium
        Case c = new Case(
            SuppliedName = ContactList[0].FirstName + ' ' + ContactList[0].LastName,
            SuppliedEmail = ContactList[0].Email,
            SuppliedPhone = ContactList[0].Phone,
            ContactId = ContactList[0].id,
            Subject = 'BUC Test Description #1',
            Description = 'BUC Test Description #1',
            Type = 'Question',
            Origin = 'Email',
            Status = 'Closed',
            OwnerId = userList[0].id,
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            contact_Theme__c='Safety',
            contact_reason__c='Safety Communication',
            contact_secondary_reason__c='Other',
            Sentiment__c='Positive',
            RecordTypeId = bucRtId
        );
        Case c1 = new Case(
            SuppliedName = ContactList[0].FirstName + ' ' + ContactList[0].LastName,
            SuppliedEmail = ContactList[0].Email,
            SuppliedPhone = ContactList[0].Phone,
            ContactId = ContactList[0].id,
            Subject = 'BUC Test Description #2',
            Description = 'BUC Test Description #2',
            Type = 'Question',
            Origin = 'Email',
            Status = 'Closed',
            OwnerId = userList[0].id,
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            contact_Theme__c='Safety',
            contact_reason__c='Safety Communication',
            contact_secondary_reason__c='Other',
            Sentiment__c='Positive',
            RecordTypeId = bucRtId
        );
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        c.setOptions(dmlOpts);
        //c1.setOptions(dmlOpts);
        // Insert case
        insert c;
        insert c1;
        c = [SELECT id,ownerId,isClosed FROM Case WHERE id =:c.id];
        System.assertEquals(true, c.IsClosed, 'Case did not get closed.');
        //System.assertEquals('00G', String.valueOf(c.ownerId).left(3), 'Case should be owned by a queue.');
        Test.stopTest();
    }
    @isTest static void BucCase_Reassign(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        /*
Unit test notes:
* Add Task (to emulate user email reply)
* Test that it is owned by a queue (most likely Q: BUC, but changeable via assignment rules)
* Test that case has been re-openend
*/
        Case c = [SELECT id,ownerId FROM Case WHERE RecordTypeId =:bucRtId AND Subject = 'BUC Test Description #1' limit 1];
        Case c1 = [SELECT id,ownerId FROM Case WHERE RecordTypeId =:bucRtId AND Subject = 'BUC Test Description #2' limit 1];
        Task t = new Task();
        t.WhatId = c.id;
        t.Status = 'Not Started';
        t.Subject = 'Respond to Not Satisfied Feedback';
        t.ownerId=userList[0].id;
        t.Type = 'eMail';
        t.ActivityDate = Date.today();
        insert t;
        Task t1 = new Task();
        t1.WhatId = c1.id;
        t1.Status = 'Not Started';
        t1.Subject = 'Respond to Not Satisfied Feedback';
        t1.ownerId=userList[1].id;
        t1.Type = 'eMail';
        t1.ActivityDate = Date.today();
        Test.startTest();
        insert t1;
        c = [SELECT id,ownerId,isClosed,Status FROM Case WHERE id = :c.id];
        System.assertEquals(false, c.IsClosed, 'Case should have been re-opened by trigger.');
        System.assertEquals('00G', String.valueOf(c.ownerId).left(3), 'Case should be owned by a queue.');
        System.assertEquals('Reopened', c.Status, 'Case Status should be set to "Reopened".');
        Test.stopTest();
    }
    @testSetup static void createStandardCaseAssignToUserAndClose(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        /*
Test Notes:
* Create standard Case; closed
*/
        Test.startTest();
        Case c = new Case(
            Subject = 'BUC Test Description #1',
            Description = 'Standard Test Description #1',
            Origin = 'Email',
            Status = 'Closed',
            OwnerId = UserInfo.getUserId(),
            Type = 'Case Type',
            Reason = 'Case Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            contact_Theme__c='Safety',
            contact_reason__c='Safety Communication',
            contact_secondary_reason__c='Other',
            Sentiment__c='Positive',
            Current_Member_Type__c = 'Premium',
            RecordTypeId = scRtId
        );
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        c.setOptions(dmlOpts);
        // Insert case
        insert c;
        c = [SELECT id,ownerId,isClosed FROM Case WHERE id =:c.id];
        System.assertEquals(true, c.IsClosed, 'Case did not get closed.');
       // System.assertEquals('00G', String.valueOf(c.ownerId).left(3), 'Case should be owned by a queue.');
        Test.stopTest();
    }
    @isTest static void StandardCase_DoNotReassign(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        /*
Unit test notes:
* Add Task (to emulate user email reply)
* Test that it is still closed (trigger should not re-open standard cases)
*/
        Case c = [SELECT id,ownerId FROM Case WHERE RecordTypeId =:scRtId AND Subject = 'BUC Test Description #1'];
        Test.startTest();
        Task t = new Task();
        t.WhatId = c.id;
        t.Status = 'Not Started';
        t.Subject = 'Respond to Not Satisfied Feedback';
        t.ownerId=userList[1].id;
        t.Type = 'eMail';
        t.ActivityDate = Date.today();
        insert t;
        Test.stopTest();
        c = [SELECT id,ownerId,isClosed FROM Case WHERE id = :c.id];
        //System.assertEquals(true, c.IsClosed, 'Case should have been remained closed.');
        //System.assertEquals('00G', String.valueOf(c.ownerId).left(3), 'Case should be owned by a queue.');
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket1(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t1 = new Task();
        t1.recordTypeId=linkedInMailRecId;
        t1.WhatId = c.id;
        t1.Status = 'Not Started';
        t1.Subject = 'Test Task';
        t1.Type = 'Client/Follow-up Event/Meeting';
        t1.ActivityDate = Date.today();
        insert t1;
        AvoidRecursion.runOnce();
        Test.stopTest();
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket2(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t2 = new Task();
        t2.recordTypeId=linkedInMessageRecId;
        t2.WhatId = c.id;
        t2.Status = 'Not Started';
        t2.Subject = 'Test Task';
        t2.Type = '--None--';
        t2.ActivityDate = Date.today();
        insert t2;
        AvoidRecursion.runOnce();
        Test.stopTest();
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket3(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t3 = new Task();
        t3.recordTypeId=linkedInMailRecId;
        t3.WhatId = c.id;
        t3.Status = 'Not Started';
        t3.Subject = 'Test Task';
        t3.Type = 'Meeting- Remote';
        t3.ActivityDate = Date.today();
        insert t3;
        AvoidRecursion.runOnce();
        Test.stopTest();
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket4(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t4 = new Task();
        t4.recordTypeId=defaultRecId;
        t4.WhatId = c.id;
        t4.Status = 'Not Started';
        t4.Subject = 'Test Task';
        t4.Type = 'Phone Call-Connect';
        t4.ActivityDate = Date.today();
        insert t4;
        AvoidRecursion.runOnce();
        Test.stopTest();
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket5(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t5 = new Task();
        t5.recordTypeId=defaultRecId;
        t5.WhatId = c.id;
        t5.Status = 'Not Started';
        t5.Subject = 'Respond to Not Satisfied Feedback';
        t5.ownerId=userList[1].id;
        t5.Type = 'Phone Call-No Connection';
        t5.ActivityDate = Date.today();
        insert t5;
        AvoidRecursion.runOnce();
        Test.stopTest();
    }
    @isTest static void testCopyActivityTypeToActivityTypeBucket6(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = [SELECT id,ownerId FROM Case WHERE Subject = 'BUC Test Description #1' LIMIT 1];
        Test.startTest();
        Task t6 = new Task();
        t6.recordTypeId=defaultRecId;
        t6.WhatId = c.id;
        t6.Status = 'Not Started';
        t6.Subject = 'Test Task';
        t6.Type = 'Email';
        t6.ActivityDate = Date.today();
        //insert t6;
        Task t8 = new Task();
        t8.recordTypeId=linkedInMailRecId;
        t8.WhatId = c.id;
        t8.Status = 'Not Started';
        t8.Subject = 'Test Task';
        t8.Type = 'LinkedIn Inmail';
        t8.ActivityDate = Date.today();
        //insert t8;
        Task t9 = new Task();
        t9.recordTypeId=defaultRecId;
        t9.WhatId = c.id;
        t9.Status = 'Not Started';
        t9.Subject = 'Test Task';
        t9.Type = ' Onsite Meeting (Scheduled)';
        t9.ActivityDate = Date.today();
        //insert t9;
        Task t10 = new Task();
        t10.recordTypeId=defaultRecId;
        t10.WhatId = c.id;
        t10.Status = 'Not Started';
        t10.Subject = 'Test Task';
        t10.Type = 'Remote Meeting (scheduled)';
        t10.ActivityDate = Date.today();
        //insert t10;
        Task t11 = new Task();
        t11.recordTypeId=defaultRecId;
        t11.WhatId = c.id;
        t11.Status = 'Not Started';
        t11.Subject = 'Test Task';
        t11.Type = 'SDR Appointment';
        t11.ActivityDate = Date.today();
        //insert t11;
        Task t12 = new Task();
        t12.recordTypeId=defaultRecId;
        t12.WhatId = c.id;
        t12.Status = 'Not Started';
        t12.Subject = 'Test Task';
        t12.Type = 'Quarterly Business Review';
        t12.ActivityDate = Date.today();
        //insert t12;
        Task t13 = new Task();
        t13.recordTypeId=defaultRecId;
        t13.WhatId = c.id;
        t13.Status = 'Not Started';
        t13.Subject = 'Test Task';
        t13.Type = 'Not Matched';
        t13.ActivityDate = Date.today();
        insert new List<Task>{t6,t8,t9,t10,t11,t12,t13};
            AvoidRecursion.runOnce();
        Test.stopTest();
    }
}