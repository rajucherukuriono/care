public without sharing class BUCCaseTriggerHandler {

    public static void updateGalore(List<Case> newCaseRecords, Map<Id, Case> oldMap) {
        Set<Id> bucRecordTypeIds = new Set<Id>{
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('Infraction or License Changes').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('COI expiration').getRecordTypeId()
        };

        List<Id> caseIds = new List<Id>();

        for (Case caseRecord : newCaseRecords) {
            // Filter out non-BUC-related record types
            if (!bucRecordTypeIds.contains(caseRecord.RecordTypeId)) continue;
            // Filter out cases already closed
            if (oldMap.get(caseRecord.Id)?.Status == 'Closed') continue;
            // Filter out cases not changing to a closed status
            if (caseRecord.Status != 'Closed') continue;

            caseIds.add(caseRecord.Id);
        }

        if (caseIds.size() > 0) {
            BUCCaseCalloutMaster.UpdateAccountsOnGaloreByCaseId(caseIds);
        }
    }

}