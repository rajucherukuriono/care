public with sharing class CasesForAccountHierarchyController {

    @AuraEnabled(cacheable=true)
    public static String getCasesRelatedToAccountHierarchy(Id recordId,
                                                           String fieldSetAPIName,
                                                           String objectComponentIsOn,
                                                           String caseFilterField,
                                                           String caseFilterValue){
        
        Account currentAccount = getRelatedAccount(recordId, objectComponentIsOn);
        Set<Id> allAccountIds = getRelatedAccountIds(currentAccount);
        List<Schema.FieldSetMember> fieldSetMembers = getFieldSetMembers(fieldSetAPIName);
        String query = generateQuery(fieldSetMembers, caseFilterField, caseFilterValue);

        List<SObject> lstRecords = Database.query(query);
        System.debug(lstRecords);

        Map<String, String> returnMap = new Map<String,String>();
        returnMap.put('FIELD_LIST', JSON.serialize(fieldSetMembers));
	    returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
	    return JSON.serialize(returnMap);
    }

    private static Account getRelatedAccount(Id recordId, String objectComponentIsOn){
        Account currentAccount;

        if(objectComponentIsOn.toLowerCase() == 'account'){
            currentAccount = [SELECT Id, Hierarchy_Parent__c FROM Account WHERE Id =: recordId LIMIT 1];
        }else {
            Case currentCase = [SELECT Id, AccountId FROM Case WHERE Id =: recordId];

            currentAccount = [SELECT Id, Hierarchy_Parent__c FROM Account WHERE Id =: currentCase.AccountId LIMIT 1];
        }

        return currentAccount;
    }

    /**
     * Need to get account Ids for all accounts in hierarchy. Hierarchy should
     * only be two levels, so any account related to the Id or Hierarchy_Parent__c.
     */
    private static Set<Id> getRelatedAccountIds(Account currentAccount){
        List<Account> allAccounts = [SELECT Id, Name, Hierarchy_Parent__c
                                    FROM Account 
                                    WHERE (Hierarchy_Parent__c =: currentAccount.Hierarchy_Parent__c AND Hierarchy_Parent__c != null) //if passed in is child, this gets any siblings
                                    OR Id =: currentAccount.Hierarchy_Parent__c //If passed in is child, gets parents
                                    OR (Hierarchy_Parent__c =: currentAccount.Id AND Hierarchy_Parent__c != null) //If passed in is parent, this gets children
                                    OR Id =: currentAccount.Id]; //If passed in is parent, gets parent

        return (new Map<Id,SObject>(allAccounts)).keySet();

    }

    private static List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetAPIName){
        SObject salesforceObject = (SObject)(Type.forName('Schema.'+ 'Case').newInstance());
        return salesforceObject.getSObjectType().getDescribe().fieldSets.getMap().get(fieldSetAPIName).getFields();
    }

    private static String generateQuery(List<Schema.FieldSetMember> fieldSetMembers,
                                        String caseFilterField,
                                        String caseFilterValue){

        String query = 'SELECT ';
	    for(Schema.FieldSetMember f : fieldSetMembers) {
	        query += f.getFieldPath() + ', ';
        }

        Boolean hasIdField = false;

        for(Schema.FieldSetMember each : fieldSetMembers){
            if(each.getFieldPath() == 'Id') hasIdField = true;
        }

        if(hasIdField){
            query = query.Substring(0, query.length()-2);
            query += ' FROM Case';
        } else {
            query += 'Id FROM Case';
        }

        query += ' WHERE AccountId In :allAccountIds ';

        if(caseFilterField != null && caseFilterValue != null){
            query += ' AND ' + caseFilterField + ' = :caseFilterValue';
        } 

        System.debug('Query');
        System.debug(query);

        return query;
    }
}