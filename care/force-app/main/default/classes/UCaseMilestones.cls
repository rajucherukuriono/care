// Apex trigger handler methods that deal with Case milestones
//
// added by GearsCRM
public with sharing class UCaseMilestones
{
	@TestVisible 
	private static set<Id>sGoodProfiles;

	@TestVisible
	private static map<Id, MilestoneandEntitlementSettings__c>sMilestoneSettings;

	@TestVisible 
	private static map<string, Case_Statuses_to_Pause_and_Unpause__mdt>sPauseSettings;

	@TestVisible
	private static map<string, map<Id, Entitlement_and_Milestone_Activity_Types__mdt>>sEntitlementConfig;

	public static void CheckPauseUnpause(list<Case>records, map<Id, Case>oldMap) // before insert/update
	{
		set<Id>wantTypes = UGears.GetBREezeRecordTypes();
		list<Case>cases = new list<Case>();
		set<string>stats = new set<string>();

		for (Case c : records)
		{
			if (wantTypes.contains(c.RecordTypeId))
			{
				if (UGears.HasChanged('UCaseMilestones.CheckPauseUnpause', 'Status', c, oldMap))
				{
					stats.add(c.Status.toLowerCase());
					cases.add(c);
				}
			}
		}

		if (stats.size() > 0)
		{
			GetPauseSettings();

			for (Case c : cases)
			{
				string status = c.Status.toLowerCase();

				Case_Statuses_to_Pause_and_Unpause__mdt cmdt = sPauseSettings.get(status);
				if (cmdt != null)
				{
					if (cmdt.Pause__c)
					{
						c.IsStopped = true;
					}
					else
					if (cmdt.Unpause__c)
					{
						c.IsStopped = false;
					}
				}
			}
		}
	}

	@TestVisible
	private static map<Id, Entitlement_and_Milestone_Activity_Types__mdt>GetEntitlementConfig(string soType)
	{
		if (sEntitlementConfig == null)
			sEntitlementConfig = new map<string, map<Id, Entitlement_and_Milestone_Activity_Types__mdt>>();

		soType = soType.toLowerCase();

		map<Id, Entitlement_and_Milestone_Activity_Types__mdt>ret = sEntitlementConfig.get(soType);
		if (ret == null)
		{
			ret = new map<Id, Entitlement_and_Milestone_Activity_Types__mdt>
			([
				SELECT Id, Activity_Type_Value__c, Is_Completed_Required__c, Close_First_Response__c, Close_Response_Time__c
				FROM Entitlement_and_Milestone_Activity_Types__mdt
				WHERE Object__c = :soType
			]);

			sEntitlementConfig.put(soType, ret);
		}

		return ret;
	}

	public static void AutoCloseOnRelatedObject(string soType, string caseField, string typeField, list<sObject>records, map<Id, sObject>oldMap) // after insert/update
	{
		system.debug('+UCaseMilestones.AutoCloseOnRelatedObject');

		if (GetGoodProfiles().contains(UserInfo.getProfileId()))
		{
			map<Id, Entitlement_and_Milestone_Activity_Types__mdt>cmdts = GetEntitlementConfig(soType);

			if (cmdts.size() > 0)
			{
				boolean wantClosedTypes = false;

				map<string, Entitlement_and_Milestone_Activity_Types__mdt>typeMap
					= new map<string, Entitlement_and_Milestone_Activity_Types__mdt>();

				for (Entitlement_and_Milestone_Activity_Types__mdt cmdt : cmdts.values())
				{
					string type = cmdt.Activity_Type_Value__c;
					if (string.isBlank(type))
						type = '(default)';

					typeMap.put(type.toLowerCase(), cmdt);

					wantClosedTypes |= cmdt.Is_Completed_Required__c;
				}

				set<string>closedTypes;
				if (wantClosedTypes)
				{
					switch on (soType.toLowerCase())
					{
						when 'task'
						{
							closedTypes = UGears.GetClosedStatuses('TaskStatus');
						}
					}
				}

				string casePrefix = Case.sObjectType.getDescribe().getKeyPrefix();

				map<Id, Id>caseToCmdt = new map<Id, Id>();

				for (sObject so : records)
				{
					string idStr = string.valueOf(so.get(caseField));
					if (idStr != null && idStr.startsWith(casePrefix))
					{
						Id caseId = Id.valueOf(idStr);
						if (caseId != null)
						{
							Entitlement_and_Milestone_Activity_Types__mdt cmdt;
							if (typeField != null)
							{
								// try to find the cmdt for this specific type..
								object t = so.get(typeField);
								if (t != null)
								{
									string type = string.valueOf(t).toLowerCase();

									//system.debug('looking for "' + type + '" cmdt');
									cmdt = typeMap.get(type);
								}
							}

							// no match for this specific type? check for a default cmdt
							if (cmdt == null)
							{
								//system.debug('looking for default cmdt');
								cmdt = typeMap.get('(default)');
							}

							if (cmdt != null)
							{
								if (cmdt.Is_Completed_Required__c && closedTypes != null)
								{
									string status = (string)so.get('Status');

									if (status == null || !closedTypes.contains(status.toLowerCase()))
									{
										cmdt = null;
										//system.debug('clearing cmdt - not in a closed state: ' + status);
									}
								}

								if (cmdt != null)
								{
									caseToCmdt.put(caseId, cmdt.Id);
								}
							}
							else
							{
								//system.debug('no cmdt found');
							}
						}
						else
						{
							//system.debug('not a valid Case id');
						}
					}
				}

				if (caseToCmdt.size() > 0)
				{
					map<Id, Id>caseToFirst = new map<Id, Id>();
					map<Id, Id>caseToRtime = new map<Id, Id>();
					map<Id, CaseMilestone>allUpdates = new map<Id, CaseMilestone>();

					for (CaseMilestone stone : [
							SELECT Id, MilestoneType.Name, CaseId, Case.Status
							FROM CaseMilestone
							WHERE 
								CaseId IN :caseToCmdt.keySet() AND 
								Case.IsClosed = false AND
								IsCompleted = false AND 
								CompletionDate = null AND
								(MilestoneType.Name = 'First Response' OR MilestoneType.Name = 'Response Time')])
					{
						Id cmdtId = caseToCmdt.get(stone.CaseId);

						Entitlement_and_Milestone_Activity_Types__mdt cmdt = cmdts.get(cmdtId);

						//system.debug('found: ' + stone.MilestoneType.Name + ': ' + stone + ' for ' + cmdt);

						if (cmdt.Close_First_Response__c == true && stone.MilestoneType.Name == 'First Response')
						{
							system.debug('closing: ' + stone.MilestoneType.Name + ': ' + stone);
							caseToFirst.put(stone.CaseId, stone.Id);
							allUpdates.put(stone.Id, stone);
						}

						if (cmdt.Close_Response_Time__c == true && stone.MilestoneType.Name == 'Response Time')
						{
							system.debug('closing: ' + stone.MilestoneType.Name + ': ' + stone);
							caseToRtime.put(stone.CaseId, stone.Id);
							allUpdates.put(stone.Id, stone);
						}
					}

					// requirement removed: do close both types now (code left in, in case it comes back)
					//
					// we don't close Response Time if the case has a First Response active - go back thru the 
					// list and weed those out
					//for (Id first : caseToFirst.keySet())
					//{
					//	system.debug('skipping response time ms ' + caseToRtime.get(first));
					//	caseToRtime.remove(first);
					//}

					map<Id, CaseMilestone>updates = new map<Id, CaseMilestone>();
					map<Id, Case>cases = new map<Id, Case>();

					for (Id ms : caseToFirst.values())
					{
						CaseMilestone u = new CaseMilestone(Id = ms, CompletionDate = Datetime.now());
						updates.put(u.Id, u);
					}

					for (Id ms : caseToRtime.values())
					{
						CaseMilestone u = new CaseMilestone(Id = ms, CompletionDate = Datetime.now());
						updates.put(u.Id, u);
					}

					for (Id cId : caseToFirst.keySet())
					{
						Case c = new Case(Id = cId, Outgoing_Activity__c = Datetime.now(), Incoming_Activity__c = null);
						cases.put(cId, c);
					}

					for (Id cId : caseToRtime.keySet())
					{
						Case c = new Case(Id = cId, Outgoing_Activity__c = Datetime.now(), Incoming_Activity__c = null);
						cases.put(cId, c);
					}

					if (updates.size() > 0)
					{
						CompleteChildMilestones(allUpdates, updates);

						update updates.values();

						update cases.values();
					}
				}
			}
		}
		else
		{
			//system.debug('ignoring trigger - wrong profile');
		}

		system.debug('-UCaseMilestones.AutoCloseOnRelatedObject');
	}

	public static void HandleIncomingMessages(list<sObject>records, map<Id, sObject>oldMap)
	{
		system.debug('+UCaseMilestones.HandleIncomingMessages');

		set<Id>caseIds = new set<Id>();

		string emPrefix = EmailMessage.sObjectType.getDescribe().getKeyPrefix();

		for (sObject so : records)
		{
			Id caseId;

			string soId = so.Id;

			if (!soId.startsWith(emPrefix) || ((EmailMessage)so).Incoming == true)
			{
				caseId = (Id)so.get('ParentId');
			}

			if (caseId != null)
				caseIds.add(caseId);
		}

		if (caseIds != null)
		{
			list<Case>updates = new list<Case>();

			set<Id>wantTypes = UGears.GetBREezeRecordTypes();

			for (Case c : [SELECT Id, RecordTypeId FROM Case WHERE Id IN :caseIds AND IsClosed = false AND RecordTypeId IN :wantTypes])
			{
				Case u = new Case
				(
					Id = c.Id, 
					Incoming_Activity__c = DateTime.now(),
					Outgoing_Activity__c = null
				);

				updates.add(u);
			}

			if (updates.size() > 0)
			{
				update updates;
			}
		}

		system.debug('-UCaseMilestones.HandleIncomingMessages');
		
	}

	public static void CheckAutoCloseMilestones(list<Case>records, map<Id, Case>oldMap) // before insert/update
	{
		system.debug('+UCaseMilestones.CheckAutoCloseMilestones');

		map<Id, Case>cases = new map<Id, Case>();

		// can't rely on IsClosed here since we're a before trigger
		set<string>closeds = UGears.GetClosedStatuses('CaseStatus'); // nb: all lowercase

		for (Case c : records)
		{
			if (closeds.contains(c.Status.toLowerCase()))
			{
				if (UGears.HasChanged('UCaseMilestones.CheckAutoCloseMilestones', 'Status', c, oldMap))
				{
					cases.put(c.Id, c);
				}
			}
		}

		if (cases.size() > 0)
		{
			map<Id, CaseMilestone>stones = new map<Id, CaseMilestone>();

			list<string>types = new list<string>{'First Response', 'Final Resolution', 'Agent Working'};

			for (CaseMilestone stone : 
					[SELECT Id, CaseId, MilestoneType.Name
					FROM CaseMilestone
					WHERE CaseId IN :cases.keySet() AND MilestoneType.Name IN :types AND IsCompleted = false])
			{
				stone.CompletionDate = Datetime.now();
				stones.put(stone.Id, stone);

				if (stone.MilestoneType.Name == 'Agent Working')
				{
					Case c = cases.get(stone.CaseId);
					if (c != null)
					{
						c.Assigned_from_Queue__c = false;
					}
				}
			}

			if (stones.size() > 0)
			{
				CompleteChildMilestones(stones, stones);

				update stones.values();
			}
		}

		system.debug('-UCaseMilestones.CheckAutoCloseMilestones');
	}

	public static void AssignFirstResponse(list<Case>records, map<Id, Case>oldMap) // before insert
	{
		system.debug('+UCaseMilestones.AssignFirstResponse');

		// this functionality is going to be moved to BREeze but we want to keep the code 
		// around in case it needs to come back. commented out to not mess with coverage.. 

		/*
		set<Id>wantTypes = UGears.GetBREezeRecordTypes();

		list<Case>rightTypes = new list<Case>();

		for (Case c : records)
		{
			if (wantTypes.contains(c.RecordTypeId))
			{
				rightTypes.add(c);
			}
		}

		if (rightTypes.size() > 0)
		{
			map<Id, MilestoneandEntitlementSettings__c>settings = GetSettings();

			map<Id, set<string>>wrongOrigins = new map<Id, set<string>>();
			map<Id, set<string>>rightStatuses = new map<Id, set<string>>();

			for (MilestoneandEntitlementSettings__c setting : settings.values())
			{
				set<string>statuses = new set<string>();
				set<string>excludes = new set<string>();

				rightStatuses.put(setting.Id, statuses);
				wrongOrigins.put(setting.Id, excludes);

				if (setting.Case_Origin_to_Exclude__c != null)
				{
					for (string exclude : setting.Case_Origin_to_Exclude__c.split(','))
					{
						excludes.add(exclude.trim().toLowerCase());
					}
				}

				if (setting.First_Response_Milestone_Statuses__c != null)
				{
					for (string status : setting.First_Response_Milestone_Statuses__c.split(','))
					{
						statuses.add(status.trim().toLowerCase());
					}
				}
			}

			map<string, list<Case>>entToCases = new map<string, list<Case>>();

			for (Case c : rightTypes)
			{
				string status = c.Status == null ? '' : c.Status.toLowerCase();
				string origin = c.Origin == null ? '' : c.Origin.toLowerCase();

				for (MilestoneandEntitlementSettings__c setting : settings.values())
				{
					set<string>statuses = rightStatuses.get(setting.Id);
					set<string>origins = wrongOrigins.get(setting.Id);

					if (statuses.contains(status) && !origins.contains(origin))
					{
						string entName = setting.Global_Entitlement_Name__c.toLowerCase();

						list<Case>prev = entToCases.get(entName);
						if (prev == null)
						{
							prev = new list<Case>();
							entToCases.put(entName, prev);
						}

						prev.add(c);
						break;
					}
				}
			}

			if (entToCases.size() > 0)
			{
				for (Entitlement e : [SELECT Id, Name FROM Entitlement WHERE Name IN :entToCases.keySet()])
				{
					string entName = e.Name.toLowerCase();
					for (Case c : entToCases.get(entName))
					{
						system.debug('assigning ' + c.CaseNumber + ' ' + e.Name);
						c.EntitlementId = e.Id;
					}
				}
			}
		}
		*/
		system.debug('-UCaseMilestones.AssignFirstResponse');
	}

/*	only used by AssignFirstResponse above

	@TestVisible
	private static map<Id, MilestoneandEntitlementSettings__c>GetSettings()
	{
		if (sMilestoneSettings == null)
		{
			sMilestoneSettings = new map<Id, MilestoneandEntitlementSettings__c>
			([
				SELECT
					Id,
					Name,
					Case_Origin_to_Exclude__c,
					Final_Resolution_Milestone__c,
					Final_Resolution_Milestone_Statuses__c,
					First_Response_Milestone_Statuses__c,
					Global_Entitlement_Name__c,
					Repeating_First_Milestone__c,
					Violation_Approaching_Threshold__c
				FROM MilestoneandEntitlementSettings__c
			]);
		}

		return sMilestoneSettings;
	}
*/

	private static void CompleteChildMilestones(map<Id, CaseMilestone>updates, map<Id, CaseMilestone>milestones)
	{
		system.debug('+CompleteChildMilestones');

		string msPrefix = CaseMilestone.sObjectType.getDescribe().getKeyPrefix();

		map<Id, list<CaseMilestone>>parentMilestones = new map<Id, list<CaseMilestone>>();

		for (CaseMilestone stone : updates.values())
		{
			list<CaseMilestone>prev = parentMilestones.get(stone.CaseId);
			if (prev == null)
			{
				prev = new list<CaseMilestone>();
				parentMilestones.put(stone.CaseId, prev);
			}

			prev.add(stone);
		}

		if (parentMilestones.size() > 0)
		{
			for (Case child : [
				SELECT Id, ParentId, (SELECT Id, MilestoneType.Name FROM CaseMilestones WHERE IsCompleted = false)
				FROM Case
				WHERE ParentId IN :parentMilestones.keySet()])
			{
				list<CaseMilestone>prevs = parentMilestones.get(child.ParentId);

				for (CaseMilestone ms : child.CaseMilestones)
				{
					for (CaseMilestone prev : prevs)
					{
						if (ms.MilestoneType.Name == prev.MilestoneType.Name)
						{
							CaseMilestone u = new CaseMilestone(Id = ms.Id, CompletionDate = Datetime.now());

							system.debug('closing child: ' + u);

							milestones.put(u.Id, u);
						}
					}
				}
			}
		}

		system.debug('-CompleteChildMilestones');
	}

	@TestVisible
	private static map<string, Case_Statuses_to_Pause_and_Unpause__mdt>GetPauseSettings()
	{
		if (sPauseSettings == null)
		{
			sPauseSettings = new map<string, Case_Statuses_to_Pause_and_Unpause__mdt>();

			for (Case_Statuses_to_Pause_and_Unpause__mdt cmdt : [
					SELECT Id, Label, Pause__c, Unpause__c
					FROM Case_Statuses_to_Pause_and_Unpause__mdt])
			{
				sPauseSettings.put(cmdt.Label.toLowerCase(), cmdt);
			}
		}

		return sPauseSettings;
	}

	@TestVisible
	private static set<Id>GetGoodProfiles()
	{
		if (sGoodProfiles == null)
		{
			sGoodProfiles = new set<Id>();

			set<string>profNames = new set<string>();
			for (Entitlement_and_Milestone_Profiles__mdt p : [SELECT Id, Label FROM Entitlement_and_Milestone_Profiles__mdt])
			{
				profNames.add(p.Label.toLowerCase());
			}

			for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN :profNames])
			{
				sGoodProfiles.add(p.Id);
			}
		}

		return sGoodProfiles;
	}	
    
    public static void AutoCloseTaskforOpenCase(list<Task> records){
        Set<Id> WhatIdSet = new Set<Id>();
        for (Task t : records){
      		if (t.type == 'eMail' && t.WhatId != null && Schema.Case.SObjectType == t.WhatId.getSobjectType() ){            	
            	WhatIdSet.add(t.WhatId);
            }
        }
        
        Map<id, Case> mapClosedCase = new Map<Id, Case>();
        if (!WhatIdSet.isEmpty()){
            for (Case c : [SELECT id,ownerId, RecordType.Name, RecordTypeId FROM Case WHERE id IN :WhatIdSet and (RecordType.Name='Standard' or RecordType.Name='International Email') and isClosed=true]){
                mapClosedCase.put(c.Id, c);
            }
        }	
        
        if(!mapClosedCase.isEmpty()){
            for (Task t : records){
                if(mapClosedCase.containsKey(t.WhatId) && mapClosedCase.get(t.WhatId).Id == t.WhatId){
                    t.Status='Completed';
                }
            }
        }
    }
}