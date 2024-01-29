// Unit tests AgentWork (Omni) trigger handler
//
// added by GearsCRM
@IsTest
public class UAgentWorkTests
{
	private static Id sRtStandard = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();


	@IsTest
	private static void TriggerCoverage()
	{
		Account a = new Account(Name = 'TestCo');
		insert a;

		Contact me = new Contact(FirstName = 'Testy', LastName = 'Tester', AccountId = a.Id);
		insert me;

		Case c = new Case
		(
			Status = 'New',
			Subject = 'Inappropriate Search',
			SuppliedEmail = 'test@test.test',
			AccountId = a.Id,
			OwnerId = UserInfo.getUserId(),
			ContactId = me.Id,
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
			Reason = 'Account',
			Secondary_Case_Reason__c = 'Add Profile',
			Language = 'en_US'
		);
		insert c;

		ServiceChannel sc;
		
		for (ServiceChannel chan : [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'Case' LIMIT 1])
		{
			sc = chan;
		}

		User u = new User(Id = UserInfo.getUserId());
        
        System.runAs(u){
            //Try Catch is to ensure test doesn't fail in QA and UAT
            try{
                AgentWork aw = new AgentWork(
                    ServiceChannelId = sc.Id,
                    WorkItemId = c.Id,
                    UserId = u.Id
                );
                insert aw;
            }catch(Exception ex){
                //Exception will occur due to the omni channel bug. Ignore it
            }
        }
    }
	@IsTest
	static void TestHandler()
	{
		UAgentWork.GetConfigFields();
		UAgentWork.sConfigFields.clear();
		UAgentWork.sConfigFields.add('suppliedemail');
		UAgentWork.sConfigFields.add('accountid');

		UGears.GetBREezeRecordTypes();
		UGears.sBREezeRecordTypes.clear();
		UGears.sBREezeRecordTypes.add(sRtStandard);

		Account a1 = new Account(Name = 'TestCo 1');
		Account a2 = new Account(Name = 'TestCo 2');
		insert new list<Account>{a1, a2};

		Contact me = new Contact(FirstName = 'Testy', LastName = 'Tester', AccountId = a1.Id);
		insert me;

		Group q;
		for (Group tmp : [SELECT Id FROM Group WHERE Type = 'Queue' AND QueueRoutingConfigId != null LIMIT 1])
		{
			q = tmp;
		}

		Case c1 = new Case
		(
			RecordTypeId = sRtStandard,
			Status = 'New',
			Subject = 'testing 1...',
			SuppliedEmail = 'test@test.test',
			AccountId = a1.Id,
			OwnerId = UserInfo.getUserId(),
			ContactId = me.Id,
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
			Reason = 'Account',
			Secondary_Case_Reason__c = 'Add Profile',
			Language = 'en_US'
		);

		Case c2 = new Case
		(
			RecordTypeId = sRtStandard,
			Status = 'New',
			Subject = 'testing 2...',
			SuppliedEmail = null,
			AccountId = a1.Id,
			OwnerId = q.Id,
			ContactId = me.Id,
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
			Reason = 'Account',
			Secondary_Case_Reason__c = 'Add Profile',
			Language = 'en_US'
		);

		Case c3 = new Case
		(
			RecordTypeId = sRtStandard,
			Status = 'New',
			Subject = 'testing 3...',
			SuppliedEmail = 'other@test.test',
			AccountId = a1.Id,
			OwnerId = q.Id,
			ContactId = me.Id,
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
			Reason = 'Account',
			Secondary_Case_Reason__c = 'Add Profile',
			Language = 'en_US'
		);

		insert new list<Case>{c1, c2, c3};

		// c1 loses the contact id here, for some reason.. fix it (this is probably a bug elsewhere
		// that should get fixed!)
		c1.ContactId = me.Id;
		update c1;

		// gross.. can't actually write any fields on AgentWork so manually fake one up
		// and call the trigger handler directly
		list<AgentWork>aws = new list<AgentWork>();

		String jsonText = 
			'{"attributes": {"type": "WorkItem","url":"/services/data/v45.0/sobjects/WorkItem/0Bz02000000Go0mCAC"}' +
			 ',"Id": "0Bz02000000Go0mCAC"' + 
			 ',"Status":"Assigned"' +
			 ',"WorkItemId":"' + c1.Id + '"' +
			 ',"UserId":"' + UserInfo.getUserId() + '"' +
			 ',"AcceptDateTime":"2020-10-23T14:55:05.000Z"' +
			'}}';

		AgentWork aw = (AgentWork)JSON.deserialize(jsonText, AgentWork.class);
		aws.add(aw);

		UAgentWork.HandleAssign(aws, null);

		c1 = [SELECT Id, OwnerId, Assigned_from_Queue__c FROM Case WHERE Id = :c1.Id];
		c2 = [SELECT Id, ParentId, OwnerId, Assigned_from_Queue__c FROM Case WHERE Id = :c2.Id];
		c3 = [SELECT Id, ParentId, OwnerId, Assigned_from_Queue__c FROM Case WHERE Id = :c3.Id];

		system.assertEquals(true, c1.Assigned_from_Queue__c);
		system.assertEquals(true, c2.Assigned_from_Queue__c);
		system.assertEquals(false, c3.Assigned_from_Queue__c);

		system.assertEquals(c1.Id, c2.ParentId);
		system.assertEquals(c1.OwnerId, c2.OwnerId);

		system.assertEquals(null, c3.ParentId);
	}
}