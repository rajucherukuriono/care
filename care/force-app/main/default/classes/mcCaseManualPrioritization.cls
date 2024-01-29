public with sharing class mcCaseManualPrioritization {

@AuraEnabled(cacheable=true)
public static Map<String, List<String>> getPicklistValuesfromMap(){
    Map<String, List<String>> pickListValues = new Map<String, List<String>>();
    Map<String,String> customFields = new Map<String,String>();
    SObjectType mcReprior = Schema.getGlobalDescribe().get('MC_RePrioritization__mdt');
    Map<String, Schema.SObjectField> mfields = mcReprior.getDescribe().fields.getMap();
    List<String> pickOptions = new List<String>();
    for(SObjectField field : mfields.values()){
        pickOptions = new List<String>();
        if (field.getDescribe().isCustom()) {
            Schema.DescribeFieldResult pickList = field.getDescribe();
            system.debug(pickList);
            for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
                pickOptions.add(pickVal.getValue());                    
            }
            pickListValues.put(pickList.getName(), pickOptions);
        }               
    }
    return pickListValues;
}

@AuraEnabled
public static string updateCases( Object data ) {
    system.debug(data);
    Group mcTemp = [Select Id, DeveloperName from group where DeveloperName ='MC_Temporary'];
    List < Case > casesForUpdate = ( List < Case > ) JSON.deserialize(
        JSON.serialize( data ),
        List < Case >.class
    );
    for(case cs : casesForUpdate){
        cs.OwnerId = mcTemp.Id;       
    }
    update casesForUpdate;
    return 'Success: Case(s) updated successfully';
}

@AuraEnabled
public static string updatePriority( list<Id> caseIds, string priority ) {
    system.debug('***caseIds*'+caseIds);
    system.debug('**priority**'+priority);
   List<Case> updCaseList = [Select id, priority from case where ID IN: caseIds];
    for(case cs : updCaseList){
        cs.Priority = priority;       
    }
    update updCaseList;
    return 'Success: Case(s) updated successfully';    
}

@AuraEnabled
public static List<Case> appCustomWrapListMthd(List<Map<String, String>> mapFieldValues){ //List<wrapperCustomClass>
    Map<String, String> caseFilters = New Map<String, String>();
    system.debug('***mapFieldValues');
    system.debug(mapFieldValues);
    for(Map<String, String> flds: mapFieldValues){
        system.debug('***key*'+flds.get('key') +'***'+flds.get('value') );
        caseFilters.put(flds.get('key'), flds.get('value'));
    }
    List<Case> mcCases = new List<Case>();
    Map<Id, Group> mcGroupIdwithData = new Map<Id, Group>([Select Id,  Name, DeveloperName, QueueRoutingConfigId, Email  FROM Group where DeveloperName in : CaseTriage.mapCustomMetadata().KeySet() and QueueRoutingConfigId!=null]);
    Map<Id, User> automatedUsers = new Map<Id, User>([Select id , name from user where name  in('FAQ for Recruiting Site Guest User', 'FAQ for Caregivers Site Guest User', 'FAQ for Companies Site Guest User', 'FAQ for Families Site Guest User', 'Care.com Salesforce Admin', 'Sterling User', 'Sterling User 2', 'Social Studio User', 'Automated Process') and isActive=true ]);
    
    Set<Id> caseIds = new Set<Id>();
    List<PendingServiceRouting> listPendingServiceRoutings = [SELECT ID ,name ,  ServiceChannel.DeveloperName , RoutingPriority, WorkItemId, WorkItem.owner.Name, WorkItem.Origin,  SecondaryRoutingPriority, IsReadyForRouting, CreatedDate, WorkItem.caseNumber, WorkItem.sUPPORT_SKILL__c 
                        FROM PendingServiceRouting 
                        WHERE ServiceChannel.DeveloperName ='Case' 
                        AND WorkItem.ownerId 
                        IN: mcGroupIdwithData.keySet() order by SecondaryRoutingPriority ASC];   
    
    for(PendingServiceRouting ps:listPendingServiceRoutings ){
        caseIds.add(ps.WorkItemId);
    }
    Map<Id, Case> allCases  =new Map<Id, Case>();
	String soqlString = 'SELECT Id';
    for (Schema.FieldSetMember fieldSet : SObjectType.Case.FieldSets.Case_Repriortization.getFields()) {
        soqlString += ',' + fieldSet.getFieldPath();
    }
    soqlString += '  FROM Case WHERE Id IN:  caseIds '; 
    
    if(!caseFilters.isEmpty()){
       
        if(caseFilters.get('Member_Type__c') !=null && caseFilters.get('Member_Type__c') !=''){
                string memberType = caseFilters.get('Member_Type__c');
                system.debug('@@@'+memberType);
                soqlString += ' AND Member_Type__c = : memberType ';
        }
        if(caseFilters.get('Member_Account_Type__c') !=null && caseFilters.get('Member_Account_Type__c') !=''){
                String accountType = caseFilters.get('Member_Account_Type__c');
                soqlString += ' AND Member_Account_Type__c = : accountType ';
        }
        if(caseFilters.get('Support_Skill__c')  !=null && caseFilters.get('Support_Skill__c')  !=''){
                String supportSkill = caseFilters.get('Support_Skill__c');
                soqlString += ' AND Support_Skill__c = : supportSkill ';
        }
        if(caseFilters.get('Member_Language__c')  !=null  && caseFilters.get('Member_Language__c')  !=''){
                String memberLanguage = caseFilters.get('Member_Language__c');
                soqlString += ' AND Member_Language__c = : memberLanguage ';
        }
         if(caseFilters.get('Priority__c') !='' && caseFilters.get('Priority__c') !=null){
                string priorty =  caseFilters.get('Priority__c');
                system.debug('@@@'+priorty);
                soqlString += ' AND Priority =: priorty ';
        }
    }
    
    system.debug('****soqlString'+soqlString);
    list<Case> lstCaseSql = Database.query(soqlString);
    if(lstCaseSql!=null){
        for(Case csL : lstCaseSql){
            allCases.put(csL.id, csL);
        }
    } 
    system.debug('****allCases'+allCases);
   // List<wrapperCustomClass> custWrapObj = new  List<wrapperCustomClass>(); 
    list<Case> caseList = new List<Case>(); 
    for(PendingServiceRouting psr: listPendingServiceRoutings){
        if(allCases.containsKey(psr.WorkItemId)){
            caseList.add(allCases.get(psr.WorkItemId));
        }
    }
    return caseList; //custWrapObj;
}
    
     @AuraEnabled
   // Create Map of Label and fieldName to use this map in columns of datatable
    public static string getFieldLableAndFieldAPI(){
        List<Map<String ,String>> listOfFieldSet  = new  List<Map<String ,String>>();
        try {
            for(Schema.FieldSetMember fieldset : SObjectType.Case.FieldSets.Case_Repriortization.getFields()) {
                Map<String ,String> lableAPIMap = new Map<String ,String>();
                lableAPIMap.put(fieldset.getLabel(),fieldset.getFieldPath());
                listOfFieldSet.add(lableAPIMap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(listOfFieldSet);

    }
}