public class CaseTriggerHandler implements ITriggerHandlerInf {
    public void beforeInsert(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        UCaseMilestones.AssignFirstResponse(newList, oldMap);
        UCaseMilestones.CheckPauseUnpause(newList, oldMap);
        UCaseMilestones.CheckAutoCloseMilestones(newList, oldMap);
        
        CopyPersonAccountToContactOnCase copyObj=new CopyPersonAccountToContactOnCase(newList,oldList, newMap,oldMap, isInsert,isUpdate, isDelete, isBefore, isAfter);
        copyObj.processCopyPersonAccountToContactOnCase();
        
        SyncLocaleToLanguageInCase syncObj=new SyncLocaleToLanguageInCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        syncObj.processSyncLocaleToLanguageInCase();
        
        UpdateVettingGoogleLinksOnCase updateVettingLinksObj=new UpdateVettingGoogleLinksOnCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        updateVettingLinksObj.processUpdateVettingGoogleLinksOnCase();
        
        CopyHiddenWebFieldsOnCaseToCustFields copyHiddenWebFieldsOnCaseToCustFieldsObj=new CopyHiddenWebFieldsOnCaseToCustFields(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        copyHiddenWebFieldsOnCaseToCustFieldsObj.processCopyHiddenWebFieldsOnCaseToCustFields();
        
        if(AvoidRecursion.runOncesmCaseTriage())
        {
            SMCaseTriage smTriage = new SMCaseTriage(newList, newMap,  oldMap, isInsert,isUpdate);
            smTriage.routeCasetoAgent();
        }
        if(AvoidRecursion.runOnceSafetyCaseTriage())
        {
            SafetyCaseTriage sTriage = new SafetyCaseTriage();
            sTriage.routeCasetoOmniInsert(newList);
        }
        
    }
    public void beforeUpdate(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        UCaseMilestones.CheckPauseUnpause(newList, oldMap);
        UCaseMilestones.CheckAutoCloseMilestones(newList, oldMap);
        
        CopyPersonAccountToContactOnCase copyObj=new CopyPersonAccountToContactOnCase(newList,oldList, newMap,oldMap, isInsert,isUpdate, isDelete, isBefore, isAfter);
        copyObj.processCopyPersonAccountToContactOnCase();
        
        SyncLocaleToLanguageInCase syncObj=new SyncLocaleToLanguageInCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        syncObj.processSyncLocaleToLanguageInCase();
        
        UpdateVettingGoogleLinksOnCase updateVettingLinksObj=new UpdateVettingGoogleLinksOnCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        updateVettingLinksObj.processUpdateVettingGoogleLinksOnCase();
        
        if(AvoidRecursion.runOnceOpenTask()){
            Set<Id> csids = new Set<Id>();
            String lCRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('LifeCare').getRecordTypeId();
            for(Case cs : newList){
                if(cs.status != oldMap.get(cs.id).status  && cs.status =='Closed' && cs.RecordTypeId == lCRecordTypeID){
                    csids.add(cs.Id);
                }
            }
            for(AggregateResult agg : [select count(Id), WhatId from Task where whatId in :csids and Status != 'Completed' group by WhatId]){
                if( Integer.valueof(agg.get('expr0')) > 0){
                    Case tskrcrd = newMap.get(String.valueOf(agg.get('whatId')));
                    tskrcrd.addError(' Please Complete all Open Activities');
                }
            }
        }
        
        if(AvoidRecursion.runOncesmCaseTriage())
        {
            SMCaseTriage smTriage = new SMCaseTriage(newList, newMap,  oldMap, isInsert,isUpdate);
            smTriage.routeCasetoAgent();
        }
        if(AvoidRecursion.runOnceSafetyCaseTriage())
        {
            SafetyCaseTriage sTriage = new SafetyCaseTriage();
            sTriage.routeCasetoOmniUpdate(newMap, oldMap);
        }         
        if(AvoidRecursion.runOnceMCCaseTriage())
        {
            MCCaseTriage mcTriage = new MCCaseTriage(newMap, oldMap);
            mcTriage.routeCasetoAgent();
        }
        if(AvoidRecursion.runOnce()){
            CaseAgentWorkTracking.stampAgentAssignmentTime(newList,oldList,newMap,oldMap);
        }
        
    }
    public void afterInsert(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        OnDemandSync.HandleNewSyncCandidates(newList);
        
        SyncLocaleToLanguageInCase syncObj=new SyncLocaleToLanguageInCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        syncObj.processSyncLocaleToLanguageInCase();
        
        if(AvoidRecursion.runOnce())
        {
            SeniorCareCaseCountTrigger seniorObj=new SeniorCareCaseCountTrigger(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
            seniorObj.processSeniorCareCaseCountTrigger();
        }       
        
        List<Case> caseList=new List<Case>();
        Map<id,PermissionSetAssignment> psaMap=new Map<id,PermissionSetAssignment>();
        for(PermissionSetAssignment psaObj: [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Override_Retention_LAD_For_User'])
        {
            psaMap.put(psaObj.assigneeId,psaObj);
        }
        if(AvoidRecursion.runOnceRecentLMD()) {
            for(Case caseObj:newList)
            {
                if(isUpdate && psaMap.containsKey(UserInfo.getUserId()) && !psaMap.containsKey(oldMap.get(caseObj.id).LastModifiedById))
                {
                    caseObj.Recent_LMD_By_Actual_User__c=oldMap.get(caseObj.id).LastModifiedDate;
                }
            }  
        }        
    }
    public void afterUpdate(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        BUCCaseTriggerHandler.updateGalore(newList, oldMap);
        
        SyncLocaleToLanguageInCase syncObj=new SyncLocaleToLanguageInCase(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        syncObj.processSyncLocaleToLanguageInCase();
        
        CallSterlingCloseOrDowngradeServiceTgr sterlingObj=new CallSterlingCloseOrDowngradeServiceTgr(newList,oldList, newMap, oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        sterlingObj.processCallSterlingCloseOrDowngradeService();
        
        if(AvoidRecursion.runOnce())
        {
            SeniorCareCaseCountTrigger seniorObj=new SeniorCareCaseCountTrigger(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
            seniorObj.processSeniorCareCaseCountTrigger();
        }        
        
        List<Case> caseList=new List<Case>();
        Map<id,PermissionSetAssignment> psaMap=new Map<id,PermissionSetAssignment>();
        for(PermissionSetAssignment psaObj: [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Override_Retention_LAD_For_User'])
        {
            psaMap.put(psaObj.assigneeId,psaObj);
        }
        if(AvoidRecursion.runOnceRecentLMD()) {
            for(Case caseObj:newList)
            {
                if(isUpdate && psaMap.containsKey(UserInfo.getUserId()) && !psaMap.containsKey(oldMap.get(caseObj.id).LastModifiedById))
                {
                    caseObj.Recent_LMD_By_Actual_User__c=oldMap.get(caseObj.id).LastModifiedDate;
                }
            }            
        }        
        if(AvoidRecursion.runOnce())
        {
            CloseChildCases.CloseChildCasesHelper(newList,oldList,newMap,oldMap);
        }        
        if(AvoidRecursion.runOnceBlockedAppeal()){
            list<Case> qualifiedCases=new list<case>();
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            for(case newcase:newMap.values()){
                if( newcase.recordtypeID == caseRecordTypeId && 
                   newcase.Appeal_Decision__c != oldMap.get(newcase.id).Appeal_Decision__c){
                       qualifiedCases.add(newcase);
                   }
            }
            if(qualifiedCases.size()>0){
                System.enqueueJob(new AppealCallBackCallout(qualifiedCases));
            }
        }
        if(AvoidRecursion.runOnceOpenTask()){
            Set<Id> csids = new Set<Id>();
            String lCRecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('LifeCare').getRecordTypeId();
            for(Case cs : newList){
                if(cs.status != oldMap.get(cs.id).status  && cs.status =='Closed' && cs.RecordTypeId == lCRecordTypeID){
                    csids.add(cs.Id);
                }
            }
            for(AggregateResult agg : [select count(Id), WhatId from Task where whatId in :csids and Status != 'Completed' group by WhatId]){
                if( Integer.valueof(agg.get('expr0')) > 0){
                    Case tskrcrd = newMap.get(String.valueOf(agg.get('whatId')));
                    tskrcrd.addError(' Please Complete all Open Activities');
                }
            }
        }        
    }
    public void beforeDelete(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        CaseDataDeletionAccessTrigger caseDataDeletionAccessTriggerObj=new CaseDataDeletionAccessTrigger(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
        caseDataDeletionAccessTriggerObj.processCaseDataDeletionAccessTrigger();
        
    }
    public void afterDelete(List<Case> newList, List<Case> oldList, Map<id, case> newMap, Map<id, case> oldMap, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){
        if(AvoidRecursion.runOnce())
        {
            SeniorCareCaseCountTrigger seniorObj=new SeniorCareCaseCountTrigger(newList,oldList,newMap,oldMap,isInsert,isUpdate,isDelete,isBefore,isAfter);
            seniorObj.processSeniorCareCaseCountTrigger();
        }
    }    
}