// Unit tests for UCaseMilestones apex class
//
// added by GearsCRM
@IsTest 
private class UCaseMilestonesTests
{
    private static Id sRtStandard = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();

    @IsTest
    static void TestBulk()
    {
        Account a = new Account(Name = 'TestCo');
        insert a;

        Id recType;
        for (Id rt :UGears.GetBREezeRecordTypes())
        {
            recType = rt;
            break;
        }

        list<Case>cases = new list<Case>();

        integer count = 10;

        for (integer i = 0; i < 10; i++)
        {
            Case c = new Case
            (
                Subject = 'Inappropriate Search',
                Description = string.valueOf(i),
                RecordTypeId = recType,
                AccountID = a.Id, 
                Reason = 'Account', 
                Secondary_Case_Reason__c = 'Add Profile',
                Language = 'en_US'
            );

            cases.add(c);
        }

        insert cases;

        Test.startTest();

        for (Case c : cases)
            c.Comments = c.Description;

        update cases;

        Test.stopTest();
    }

    @IsTest
    static void TestPause()
    {
        UGears.GetBREezeRecordTypes();
        UGears.sBREezeRecordTypes.clear();
        UGears.sBREezeRecordTypes.add(sRtStandard);

        UCaseMilestones.GetPauseSettings();
        UCaseMilestones.sPauseSettings.clear();
        UCaseMilestones.sPauseSettings.put('on hold', new Case_Statuses_to_Pause_and_Unpause__mdt(Label = 'On Hold', Pause__c = true));
        UCaseMilestones.sPauseSettings.put('escalated', new Case_Statuses_to_Pause_and_Unpause__mdt(Label = 'Escalated', Unpause__c = true));

        Account a = new Account(Name = 'TestCo');
        insert a;

        Datetime now = Datetime.now();

        Case c = new Case(Subject = 'incoming', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile');
        insert c;

        for (Case tmp : [SELECT Id, IsStopped FROM Case])
        {
            system.assertEquals(false, tmp.IsStopped);
        }

        c.Status = 'On Hold';
        update c;

        for (Case tmp : [SELECT Id, IsStopped FROM Case])
        {
            system.assertEquals(true, tmp.IsStopped);
        }

        c.Status = 'Escalated';
        update c;

        for (Case tmp : [SELECT Id, IsStopped FROM Case])
        {
            system.assertEquals(false, tmp.IsStopped);
        }
    }

    @IsTest
    static void TestIncomingEmail()
    {
        UGears.GetBREezeRecordTypes();
        UGears.sBREezeRecordTypes.clear();
        UGears.sBREezeRecordTypes.add(sRtStandard);

        Account a = new Account(Name = 'TestCo');
        insert a;

        Datetime now = Datetime.now();

        Case c1 = new Case(Subject = 'incoming', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile');
        Case c2 = new Case(Subject = 'outgoing', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile');
        insert new list<Case>{c1, c2};

        EmailMessage e1 = new EmailMessage(FromAddress = 'test@test.org', Incoming = true, ToAddress= 'test@test.org', Subject = 'incoming1', ParentId = c1.Id);
        EmailMessage e2 = new EmailMessage(FromAddress = 'test@test.org', Incoming = true, ToAddress= 'test@test.org', Subject = 'incoming2', ParentId = c1.Id);
        EmailMessage e3 = new EmailMessage(FromAddress = 'test@test.org', Incoming = true, ToAddress= 'test@test.org', Subject = 'incoming3', ParentId = c1.Id);
        EmailMessage e4 = new EmailMessage(FromAddress = 'test@test.org', Incoming = false, ToAddress= 'test@test.org', Subject = 'outgoing1', ParentId = c2.Id);
        EmailMessage e5 = new EmailMessage(FromAddress = 'test@test.org', Incoming = false, ToAddress= 'test@test.org', Subject = 'outgoing2', ParentId = c2.Id);
        insert new list<EmailMessage>{e1, e2, e3, e4, e5};

        integer count = 0;
        for (Case c : [SELECT Id, Incoming_Activity__c FROM Case])
        {
            count++;

            //if (c.Id == c1.Id)
              //  system.assert(c.Incoming_Activity__c >= now);

            if (c.Id == c2.ID)
                system.assert(c.InComing_Activity__c == null);
        }

        system.assertEquals(2, count);
    }

    @IsTest
    static void TestIncomingSocials()
    {
        UGears.GetBREezeRecordTypes();
        UGears.sBREezeRecordTypes.clear();
        UGears.sBREezeRecordTypes.add(sRtStandard);

        Account a = new Account(Name = 'TestCo');
        insert a;

        Datetime now = Datetime.now();

        Case c1 = new Case(Subject = 'incoming', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile');
        Case c2 = new Case(Subject = 'outgoing', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile');
        insert new list<Case>{c1, c2};

        SocialPost sp1 = new SocialPost(ParentId = c1.Id, Name = 'Test1', Content = 'yo');
        SocialPost sp2 = new SocialPost(ParentId = c2.Id, Name = 'Test2', Content = 'hi');

        insert new list<SocialPost>{sp1, sp2};

        integer count = 0;
        for (Case c : [SELECT Id, Incoming_Activity__c FROM Case])
        {
            count++;
            system.assert(c.Incoming_Activity__c >= now);
        }

        system.assertEquals(2, count);
    }

    /* moved to BREeze.. 
    @IsTest
    static void TestAssignFirstResponse()
    {
        UGears.GetBREezeRecordTypes();
        UGears.sBREezeRecordTypes.clear();
        UGears.sBREezeRecordTypes.add(sRtStandard);

        MilestoneandEntitlementSettings__c s = new MilestoneandEntitlementSettings__c
        (
            Name = 'Test',
            Case_Origin_to_Exclude__c = 'Email, CHAT',
            First_Response_Milestone_Statuses__c = 'New',
            Global_Entitlement_Name__c = 'Test Entitlement'
        );

        insert s;

        SlaProcess slap = [SELECT Id FROM SlaProcess WHERE sObjectType = 'Case' AND IsActive = true LIMIT 1];

        Account a = new Account(Name = 'TestCo');
        insert a;

        Entitlement e = new Entitlement(Name = 'Test Entitlement', AccountId = a.Id, SlaProcessId = slap.Id);
        insert e;

        Case c1 = new Case
        (
            Subject = 'Entitled',
            Origin = 'Web',
            AccountID = a.Id,
            Reason = 'Account',
            Secondary_Case_Reason__c = 'Add Profile'
        );

        Case c2 = new Case
        (
            Subject = 'Not Entitled',
            Origin = 'Chat',
            AccountID = a.Id,
            Reason = 'Account',
            Secondary_Case_Reason__c = 'Add Profile'
        );

        insert new list<Case>{c1, c2};

        for (Case c : [SELECT Id, CaseNumber, EntitlementId FROM Case])
        {
            if (c.Id == c1.Id)
                system.assertEquals(e.Id, c.EntitlementId);

            if (c.Id == c2.Id)
                system.assertEquals(null, c.EntitlementId);
        }
    }
*/
    @IsTest
    static void TestCloseStoneOnCaseClose() 
    {
        Account a = new Account(Name = 'TestCo');
        insert a;

        SlaProcess slap = [SELECT Id FROM SlaProcess WHERE sObjectType = 'Case' AND IsActive = true LIMIT 1];

        Entitlement e = new Entitlement(Name = 'Test Entitlement', AccountId = a.Id, SlaProcessId = slap.Id);
        insert e;

        Case c = new Case(Subject = 'Test Case', AccountId = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile', EntitlementId = e.Id);
        insert c;

        Case k = new Case(Subject = 'Child Case', AccountId = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile', EntitlementId = e.Id, ParentId = c.Id);
        insert k;

        c.Status = 'Closed';
        c.Contact_Theme__c  = 'Other';
        c.Contact_Reason__c = 'Other';
        c.Contact_Secondary_Reason__c = 'Other';
        c.Sentiment__c = 'Neutral';
        update c;

        boolean foundAny = false;
        for (CaseMilestone stone : [SELECT Id, CaseId, IsCompleted FROM CaseMilestone WHERE MilestoneType.Name = 'Final Resolution'])
        {
            foundAny = true;
            system.assertEquals(true, stone.IsCompleted);
        }

        system.assertEquals(true, foundAny);
    }

    @IsTest
    static void TestRelatedClose()
    {
        UCaseMilestones.GetEntitlementConfig('Task'); // coverage..

        map<Id, Entitlement_and_Milestone_Activity_Types__mdt>cmdts
            = new map<Id, Entitlement_and_Milestone_Activity_Types__mdt>();

        UCaseMilestones.sEntitlementConfig.put('task', cmdts);

        string cmdtPrefix = Entitlement_and_Milestone_Activity_Types__mdt.sObjectType.getDescribe().getKeyPrefix();

        Entitlement_and_Milestone_Activity_Types__mdt cmdt = new Entitlement_and_Milestone_Activity_Types__mdt
        (
            Id = cmdtPrefix + '0200000000yLEAQ', // value doesn't matter - just need something
            Object__c = 'Task',
            Activity_Type_Value__c = 'eMail',
            Close_First_Response__c = true,
            Close_Response_Time__c = true,
            Is_Completed_Required__c = true
        );

        cmdts.put(cmdt.Id, cmdt);

        Account a = new Account(Name = 'TestCo');
        insert a;

        SlaProcess slap = [SELECT Id FROM SlaProcess WHERE sObjectType = 'Case' AND IsActive = true LIMIT 1];

        Entitlement e = new Entitlement(Name = 'Test Entitlement', AccountId = a.Id, SlaProcessId = slap.Id);
        insert e;

        Case c = new Case(Subject = 'Test Case', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile', EntitlementId = e.Id);
        insert c;

        Case kid = new Case(Subject = 'Child Case', AccountID = a.Id, Reason = 'Account', Secondary_Case_Reason__c = 'Add Profile', EntitlementId = e.Id, ParentId = c.Id);
        insert kid;

        Datetime now = Datetime.now().addSeconds(-1);

        Task t = new Task(WhatId = c.Id);
        insert t;

        for (CaseMilestone stone : [
                SELECT 
                    Id, CaseId, IsCompleted, MilestoneType.Name,
                    Case.Outgoing_Activity__c, Case.Incoming_Activity__c
                FROM CaseMilestone])
        {
            if (stone.MilestoneType.Name == 'First Response' || stone.MilestoneType.Name == 'Response Time')
            {
                system.assertEquals(false, stone.IsCompleted);
            }
        }

        string closedType;
        for (string ct : UGears.GetClosedStatuses('TaskStatus'))
        {
            closedType = ct;
            break;
        }

        t.Status = closedType;
        update t;

        for (CaseMilestone stone : [
                SELECT 
                    Id, CaseId, IsCompleted, CompletionDate, MilestoneType.Name,
                    Case.Outgoing_Activity__c, Case.Incoming_Activity__c
                    FROM CaseMilestone])
        {
            if (stone.MilestoneType.Name == 'First Response' || stone.MilestoneType.Name == 'Response Time')
            {
                system.assertEquals(true, stone.IsCompleted);

                if (stone.CaseId == c.Id)
                {
                    system.assertEquals(null, stone.Case.Incoming_Activity__c);
                    system.assert(stone.Case.Outgoing_Activity__c >= now);
                }
            }
        }
    }
}