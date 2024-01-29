public with sharing class SeniorCareCaseCount {
    
    //private static ID scCaseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Care Consult').getRecordTypeId();
       private static ID scCaseRtId = getRecordTypesStatic.recordTypeNameIdMap.get('Senior Care Consult');

    public static void caseCount(Case[] cList, Id[] aToRemoveList){
        // cList: class expects a list of Senior Care Cases
        // aToRemoveList: class expects a list of Accounts that USED to have Senior Care Cases (to reset their counts)

        Set<Account> AccountsToUpdateSet = new Set<Account>();

        // Build a set of Accounts associated with the passed Senior Care Cases
        Set<Id> SeniorCareCaseAccountsSet = new Set<Id>();
        for (Case c : cList){
            SeniorCareCaseAccountsSet.add(c.AccountId);
        }

        // To handle update use case, incorporate the list of Accounts that USED to have Senior Care cases too
        for (Id aId : aToRemoveList){
            SeniorCareCaseAccountsSet.add(aId);
        }
        
        // Query for the Accounts associated with the passed Cases and query for ALL Senior Care Cases associated with the Accounts
        // For UPDATE use case, these accounts will not get back any Cases and hence their counts should be set to 0
        for (Account a: [SELECT id,(SELECT id,CreatedDate FROM Cases where recordtypeid = : scCaseRtId) FROM Account WHERE isPersonAccount = true AND id IN : SeniorCareCaseAccountsSet]){
            Integer caseCount = 0;
            Date oldestCase = null;
            for (Case c : a.Cases){
                caseCount++;
                Date createdDateAsDate = date.newinstance(c.createdDate.year(), c.createdDate.month(), c.createdDate.day());
                if (oldestCase == null) oldestCase =  createdDateAsDate; // initializes oldest Date
                if (createdDateAsDate < oldestCase) oldestCase = createdDateAsDate; // ensures oldest Date is set to oldest date in the set
            }
            AccountsToUpdateSet.add(new Account(id = a.id,Senior_Care_Case_Count__c = caseCount,First_Senior_Care_Case__c = oldestCase));
        }
        
        update new List<Account>(AccountsToUpdateSet);
    }


}