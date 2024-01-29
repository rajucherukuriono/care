//Apex trigger handler methods that deal with AgentWork (Omni)
//Modified By: Mohammed Ashwaq
//Last Modified Date: 08/01/2021
// added by GearsCRM
public class UAgentWork
{
	@TestVisible
	private static set<string>sConfigFields;

	public static void HandleAssign(list<AgentWork>records, map<Id, AgentWork>oldMap)
	{
		system.debug('+UAgentWork.HandleAssign');
        system.debug('****into Agentwork trigger');

		string casePrefix = Case.sObjectType.getDescribe().getKeyPrefix();

		set<Id>caseIds = new set<Id>();

		for (AgentWork aw : records)
		{
			//system.debug(aw);

			string caseId = aw.WorkItemId;

			if (/*aw.Status == 'Assigned' &&*/ caseId != null && caseId.startsWith(casePrefix))
			{
				if (aw.AcceptDatetime != null && aw.UserId != null)
				{
					AgentWork old = oldMap == null ? null : oldMap.get(aw.Id);

					if (old == null || aw.AcceptDateTime != old.AcceptDateTime)
					{
						caseIds.add(aw.WorkItemId);
					}
				}
			}
		}
		system.debug('****agent case parent: '+caseIds);
		if (caseIds.size() > 0) {
			map<Id, Case>updates = new map<Id, Case>();
            map<Id, Case>updateParent = new map<Id, Case>();
			set<string>cmdtFields = new set<string>();
			set<string>allFields = new set<string>();
			map<string, set<string>>cmdtValues = new map<string, set<string>>();

			for (string field : GetConfigFields())
			{
				string lc = field.toLowerCase();

				allFields.add(lc);
				cmdtFields.add(lc);
				cmdtValues.put(lc, new set<string>());
			}           
            
            //Map<Id, String> safetyRecMap =  CaseTriage.getRecordTypesforCaseTriage('Safety');
            set<Id>breezeTypes = UGears.GetBREezeRecordTypes(); //safetyRecMap.keySet(); 
			set<String> typeNames = new Set<String>{'standard'};
            for (RecordTypeInfo rt : Case.sObjectType.getDescribe().getRecordTypeInfos()){
                if (typeNames.contains(rt.getDeveloperName().toLowerCase())) {
                    breezeTypes.add(rt.getRecordTypeId());
                }
            }
			map<Id, list<Case>>contactToCases = new map<Id, list<Case>>();

			allFields.add('id');
			allFields.add('contactid');
			allFields.add('ownerid');
			allFields.add('isclosed');
			//allFields.add('Support_Skill__c');
			//allFields.add('Member_Language__c');
			list<string>fieldList = new list<string>();
			fieldList.addAll(allFields);
			system.debug('****breezeTypes recordTypes: '+breezeTypes);
			string soql;

			soql = 'SELECT ' + string.join(fieldList, ', ') + ' FROM Case ' +
				'WHERE Id IN :caseIds AND RecordTypeId IN :breezeTypes';

			system.debug('soql: ' + soql);
			
			for (Case c : Database.query(soql))
			{
				system.debug('parent: ' + c);

				updates.put(c.Id, new Case(Id = c.Id, Assigned_from_Queue__c = true));

				if (c.ContactId != null && c.IsClosed == false)
				{
					list<Case>prev = contactToCases.get(c.ContactId);
					if (prev == null)
					{
						prev = new list<Case>();
						contactToCases.put(c.ContactId, prev);
					}

					prev.add(c);

					for (string cmdt : cmdtFields)
					{
						object o = c.get(cmdt);
						if (o != null)
						{
							string val = '\'' + string.escapeSingleQuotes(string.valueOf(o)) + '\'';
							cmdtValues.get(cmdt).add(val);
						}
					}
				}
			}
			system.debug('*******contactid of case:'+contactToCases);
			if (contactToCases.size() > 0)
			{
                
				//map<string, RecordTypeInfo>rts = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

				//Id rtStandard = rts.get('Standard').getRecordTypeId();

				set<Id>contactIds = contactToCases.keySet();

				soql = 
					'SELECT ' + string.join(fieldList, ', ') + ', TYPEOF Owner WHEN Group THEN Type, QueueRoutingConfigId END ' +
					'FROM Case ' +
					'WHERE IsClosed = false AND ContactId IN :contactIds AND ' + // AND Owner.Type = \'Queue\' 
					'(Status = \'New\' OR Status = \'Reopened\') AND RecordTypeId IN :breezeTypes ';

				for (string cmdt : cmdtFields)
				{
					set<string>vals = cmdtValues.get(cmdt);
					list<string>vlist = new list<string>();
					vlist.addAll(vals);

					soql += vals.isEmpty() ? '' : 'AND (' + cmdt + ' = null OR ' + cmdt + ' IN (' + string.join(vlist, ',') + ')) ';
				}

				system.debug(soql);
				
				for (Case child : database.query(soql))
				{
                    system.debug('*******all child cases with same contact:'+child);
					if (caseIds.contains(child.Id))
					{
						system.debug('skipping parent ' + child.Id);
						continue;
					}

					if (child.Owner == null || ((Group)child.Owner).QueueRoutingConfigId == null)
					{
						system.debug('skipping non-omni queue owner ' + child.Id);
						continue;
					}

					list<Case>cases = contactToCases.get(child.ContactId);
					for (Case parent : cases)
					{
						boolean match = true;

						for (string field : cmdtFields)
						{
							object p = parent.get(field);
							object c = child.get(field);

							match &= (c == null || p == c);
							if (!match)
							{
								break;
							}
						}

						if (match)
						{                            
							Case u = updates.get(child.Id);
							if (u == null)
							{
								u = new Case(Id = child.Id);
								updates.put(child.Id, u);
							}
                           /* if(child.Support_Skill__c ==parent.Support_Skill__c && 
                               	child.Member_Language__c ==parent.Member_Language__c )
                            { */                               
                                system.debug('into child************'+u);
                            	u.OwnerId = parent.OwnerId;
                                u.ParentId = parent.Id;
                                u.Assigned_from_Queue__c = true;
							/* } */
                            
							system.debug('updating: ' + u);

							break;
						}
                        
					}
				}
			}

			if (updates.size() > 0)
			{
                system.debug('updates map: ' + updates);
				update updates.values();
			}
            
		}

		system.debug('-UAgentWork.HandleAssign');
	}

	@TestVisible
	private static set<string>GetConfigFields()
	{
		if (sConfigFields == null)
		{
			sConfigFields = new set<string>();

			for (Member_Care_Reparenting_Fields__mdt cmdt : [SELECT Label FROM Member_Care_Reparenting_Fields__mdt])
			{
				sConfigFields.add(cmdt.Label.toLowerCase());
			}
		}

		return sConfigFields;
	}
}