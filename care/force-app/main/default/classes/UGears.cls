// Generic apex methods that don't obviously belong elsewhere
//
// added by GearsCRM
public class UGears
{
	@testVisible
	private static map<Id, map<string, object>>sRecursionData;

	@TestVisible
	private static set<Id>sBREezeRecordTypes;

	@TestVisible 
	private static map<string, map<string, boolean>>sClosedStatuses;

	private static map<string, OpportunityStage>sOpStages;

	public static map<string, OpportunityStage>GetOpStages()
	{
		if (sOpStages == null)
		{
			sOpStages = new map<string, OpportunityStage>();
			for (OpportunityStage os : [SELECT id,masterlabel,sortorder FROM OpportunityStage WHERE isActive = true])
			{
				sOpStages.put(os.masterlabel,os);
			}
		}

		return sOpStages;
	}

	public static set<Id>GetBREezeRecordTypes()
	{
		if (sBREezeRecordTypes == null)
		{
			sBREezeRecordTypes = new set<Id>();

			set<string>typeNames = new set<string>();

			for (BREeze_Case_Creation_First_Res_Mapping__mdt mdt : [SELECT Id, DeveloperName FROM BREeze_Case_Creation_First_Res_Mapping__mdt])
			{
				typeNames.add(mdt.DeveloperName.toLowerCase());
			}

			for (RecordTypeInfo rt : Case.sObjectType.getDescribe().getRecordTypeInfos())
			{
				if (typeNames.contains(rt.getDeveloperName().toLowerCase()))
				{
					sBREezeRecordTypes.add(rt.getRecordTypeId());
				}
			}
		}

		return sBREezeRecordTypes;
	}

	public static set<string>GetClosedStatuses(string type)
	{
		map<string, boolean>all = GetStatuses(type);
		set<string>ret = new set<string>();

		for (string key : all.keySet())
		{
			if (all.get(key) == true) // IsClosed=true
			{
				ret.add(key);
			}
		}

		return ret;
	}

	public static map<string, boolean>GetStatuses(string type)
	{
		if (sClosedStatuses == null)
		{
			sClosedStatuses = new map<string, map<string, boolean>>();
		}

		type = type.toLowerCase();

		map<string, boolean>stats = sClosedStatuses.get(type);
		if (stats == null)
		{
			stats = new map<string, boolean>();
			sClosedStatuses.put(type, stats);

			string soql = 'SELECT Id, ApiName, IsClosed FROM ' + type;

			for (sObject so : Database.query(soql))
			{
				string name = ((string)so.get('ApiName')).toLowerCase();
				boolean closed = (boolean)so.get('IsClosed');

				stats.put(name, closed);
			}
		}

		return stats;
	}

	public static void ResetRecursionData()
	{
		system.debug('**** resetting UGears.HasChanged recursion data');
		sRecursionData = null;
	}

	public static boolean HasChanged(string prefix, string apiName, sObject newObj, map<Id, sObject>oldObjects)
	{
		// SEE this page for why this method is needed.. 
		//   https://salesforce.stackexchange.com/questions/46790/how-to-avoid-recursive-trigger-other-than-the-classic-class-w-static-variable

		// NOTE that if there are 2 triggers on the same object type looking for changes on the same field(s), at
		// least one of them MUST use the prefix param - this method is a destructive read so checking for changes
		// twice on the same record/field will cause the second caller to get the wrong answer

		// NOTE that if you have unit tests that do multiple things within a single method, consider calling the 
		// ResetRecursionData method above - if you're simulating what would normally be multiple, separate transactions
		// within a single transaction, call that method to reset things after each similated 'transaction'

		// NOTE that if you're checking a number of fields for changes, you're better off doing...
		//
		// bool changed = false; 
		// changed |= UGears.HasChanged('a', ...);
		// changed |= UGears.HasChanged('b', ...);
		// changed |= UGears.HasChanged('c', ...);
		//
		// ..because that will load 'old' data for all fields into the cache. if you just say 
		// something like..
		//
		// bool changed = UGears.HasChanged('a', ...) || UGears.HasChanged('b', ...) || UGears.HasChanged('c', ...) 
		//
		// ..the evaluation will probably stop on the first true - if the 'a' case is true, it 
		// won't bother doing the b & c cases and their data won't end up in the cache.

		if (sRecursionData == null)
		{
			sRecursionData = new map<Id, map<string, object>>();
		}


		// if you get an exception here like "SObjectException: Invalid field Id" and you're SURE you
		// haven't typo'ed anything, check the API version of the sobject type and field you're trying
		// to use and make sure their API version is not greater than the one of this file. If it is,
		// you need to bump this file up to a matching (or greater) API version. TL;DR: you can't use
		// an object/field in code with a version before that object/field was introduced..
		Id objectId = newObj.Id;

		string key = prefix == null ? apiName : prefix + '.' + apiName;

		sObject oldObj = oldObjects == null ? null : oldObjects.get(objectId);
		map<string, object>oldObjData = sRecursionData.get(objectId);

		// make everything lowercase - if somebody is doing soql from cmdt config or something, we don't 
		// want to mess up because of a case conflict
		apiName = apiName.toLowerCase();

		object oldVal = oldObjData == null || oldObjData.containsKey(key) == false ? (oldObj == null ? null : oldObj.get(apiName)) : oldObjData.get(key);
		object newVal = newObj.get(apiName);

		boolean changed = oldVal != newVal;

		if (changed)
		{
			system.debug('HasChanged: changed ' + newObj.Id + ' field ' + apiName);
			//system.debug(apiName + ' oldVal: ' + oldVal);
			//system.debug(apiName + ' newVal: ' + newVal);

			if (oldObjData == null)
			{
				oldObjData = new map<string, object>();
				sRecursionData.put(objectId, oldObjData);
			}

			oldObjData.put(key, newVal);
		}

		return changed;
	}

	public static String convertListToMap(List<SObject> records, String keyField)
	{
		return convertListToMap(records, keyField, null);
	}

	public static String convertListToMap(List<SObject> records, String keyField, String valueField)
	{
		Map<Object,Object> recordMap = new Map<Object,Object>();

		for(SObject rec : records)
		{
			if(rec.get(keyField) != null)
			{
				recordMap.put(rec.get(keyField), String.isNotBlank(valueField) ? rec.get(valueField) : rec);
			}
		}
		return JSON.serialize(recordMap);
	}
}