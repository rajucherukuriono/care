/* 
* Created by: Eustace Consulting [www.eustaceconsulting.com][Developer: Jen Blair] 
* Description: Class that populates static lists with Contact and Account Record Types
*/
public with sharing class getRecordTypesStatic {
  
    public static List<RecordType> persAcctRecTypes;
    public static List<RecordType> conRecordTypes;
    
    public static Id busAcctRecType;
    public static Id mktplcLeadRecType;
    public static Id mktplcContactRecType;
    public static Id mktplcOppRecType;
    public static Id wpsOppRecType;
    public static Id wpsContactRecType;
    public static Id WPSLeadRecType;
    
    public static Id InternationalCallCenterRecordType;
    public static Id InternationalEmailRecordType;
    public static Id InternationalSafetyRecordType;
    public static Id StandardRecordType;
    public static Id CallCenterRecordType;
    public static Id HomePayLeadRecType;
    public static Id chargebackRecordType;
  
    static {
        persAcctRecTypes = [SELECT id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND ispersontype = true AND isActive = true AND (DeveloperName = 'Seeker' or  DeveloperName = 'Provider' or DeveloperName = 'SMB_Provider' or DeveloperName = 'Lite')];
        //system.assertEquals(persAcctRecTypes.size(), 4);
        conRecordTypes = [SELECT id, DeveloperName FROM RecordType WHERE sObjectType = 'Contact' and (DeveloperName = 'Seeker' or DeveloperName = 'Provider' or DeveloperName = 'SMB_Provider' or DeveloperName = 'Lite')];
        //system.assertEquals(conRecordTypes.size(), 4);
        
        busAcctRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        
        mktplcLeadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Marketplace ISR Lead').getRecordTypeId();
        
        mktplcContactRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Marketplace ISR Contact').getRecordTypeId();
        
        mktplcOppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Marketplace ISR Opportunity').getRecordTypeId();
		
        wpsOppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('WPS Opportunity').getRecordTypeId();
        
        wpsContactRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WPS Contact').getRecordTypeId();
        
        WPSLeadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WPS Lead').getRecordTypeId();
		
        InternationalCallCenterRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
        
        InternationalEmailRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
        
        InternationalSafetyRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
        
        StandardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        chargebackRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chargeback').getRecordTypeId();
            
        CallCenterRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();
        
        HomePayLeadRecType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('HomePay Lead').getRecordTypeId();


    } 
    public static Map<id,RecordType> recordTypeIdObjMap;
    public static Map<String,id> recordTypeNameIdMap;
    public static Map<String,id> filteredRecNameIdMap;
    //public static Map<id,RecordType> getRecordTypeMap()
    static
    {
        
            
        
        
        recordTypeIdObjMap=new Map<id,RecordType>([SELECT Description,DeveloperName,Id,IsActive,IsPersonType,Name,SobjectType FROM RecordType]);
        
        for(RecordType recObj:recordTypeIdObjMap.values())
        {
            if(recordTypeNameIdMap==null) recordTypeNameIdMap=new Map<String,Id>();
            recordTypeNameIdMap.put(recObj.Name,recObj.id);
        }
        
    }
    public static Map<String,id> getFilteredRecNameIdMap(List<String> recNameList)
    {
        for(String recName:recNameList)
        {
            if(filteredRecNameIdMap==null) filteredRecNameIdMap=new Map<String,Id>();
            filteredRecNameIdMap.put(recName,recordTypeNameIdMap.get(recName));
        }
        return filteredRecNameIdMap;
    }
    public static Map<id,Group> groupIdObjMap;
    public static Map<String,id> groupNameIdMap;
    static
    {
        groupIdObjMap=new Map<id,Group>([SELECT DeveloperName,Id,Name,OwnerId,RelatedId,Type FROM Group]);
        
        for(Group grpObj:groupIdObjMap.values())
        {
            if(groupNameIdMap==null) groupNameIdMap=new Map<String,Id>();
            groupNameIdMap.put(grpObj.Name,grpObj.id);
        }
    }    
    Public static String getRecordTypeFromSObject(String obj, String RecordTypeName){
    	Map<String, Schema.SObjectType> sobjTypeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sobjectType = sobjTypeMap.get(obj);
        Id recordTypeId = sobjectType.getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        system.debug('**recordTypeId*'+recordTypeId);
        return recordTypeId; 
    }
}