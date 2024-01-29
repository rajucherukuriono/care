/**
 * Created by VivinMathew on 10/14/2020.
 */

public without sharing class UCase {
    public List<Case> records;
    public Map<Id, Case> existingRecords;
    private static final String ORIGIN_CHAT = 'Chat';
    private static final String CASE_REOPENED = 'Reopened';
    private static Set<Id> caseCreationBreezeTypes;
    private static Map<String, BREeze_Case_Update_Fields_to_Eval__mdt> caseUpdateBreezeFields;
    private static Boolean BReeze_Update = false;
    private static final List<String> caseBreezeRules = new List<String>{'Case_Queue','Case_Entitlement','Case_Priority','Case_Skill' };

    public UCase(List<Case> records, Map<Id, Case> existingRecords){
        this.records =  records;
        this.existingRecords = existingRecords; 
    }

    public void executeBreezeRules(){
        List<Case> forProcessing = new List<Case>();

        if(Trigger.isInsert && Trigger.isBefore){
            Set<Id> validBreezeRecordTypes = getCaseCreationFirstResMappings();
            for(Case caseRec : records){
                if(validBreezeRecordTypes != null && validBreezeRecordTypes.contains(caseRec.RecordTypeId) &&
                        ((caseRec.Origin == ORIGIN_CHAT && caseRec.Status == CASE_REOPENED)
                        ||  caseRec.Origin != ORIGIN_CHAT)){
                    forProcessing.add(caseRec);
                }
            }
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            Map<String, BREeze_Case_Update_Fields_to_Eval__mdt>  caseUpdateFieldsToEval = getCaseUpdateFieldsToEvaluate();
            Set<Id> validBreezeRecordTypes = getCaseCreationFirstResMappings();

            for(Case caseRec : records){
                if(validBreezeRecordTypes != null && validBreezeRecordTypes.contains(caseRec.RecordTypeId) &&
                        ((caseRec.Origin == ORIGIN_CHAT && caseRec.Status == CASE_REOPENED)
                        || caseRec.Origin != ORIGIN_CHAT)){
                    if(caseUpdateFieldsToEval != null && hasFieldChanged(caseRec, existingRecords, caseUpdateFieldsToEval)) {
                        forProcessing.add(caseRec);
                    }
                }
            }
        }

        if(!forProcessing.isEmpty()){
            System.debug('VM forProcessing before '+forProcessing);
            runBREeze(forProcessing, existingRecords);
            System.debug('VM forProcessing after '+forProcessing);
        }
    }

    public static void runBREeze (List<Case> cases, Map<Id,Case> existingCasesMap) {

        BREeze.processRules.ruleDataSet rds = new BREeze.processRules.ruleDataSet();
        rds.records = cases;
        rds.oldMap = existingCasesMap;   //Need this if in UPDATE context and the rule check this
        //rds.retRecordsList = BREeze.processRules.returnRecordsList.Changes;

        for(string rulesToRun : caseBreezeRules){
            rds = BREeze.ProcessRules.processRuleLogic(rulesToRun, false, rds);
        }
        //System.debug('VM forProcessing rds.records '+rds.records);
        BREeze.ProcessRules.executePostProcesses(rds.postProcessExecutes);

        if(BReeze_Update && Trigger.isAfter && Trigger.isUpdate){
            update cases;
        }
    }

    private static Boolean hasFieldChanged(Case caseRecord,  Map<Id,Case> existingRecordsMap,
                                                Map<String, BREeze_Case_Update_Fields_to_Eval__mdt>  caseUpdateFieldsToEvaluate){
        Boolean isChanged = false;
        for(String caseField : caseUpdateFieldsToEvaluate.keySet()){
            isChanged |= UGears.HasChanged('Process Case Breeze Rules', caseField, caseRecord, existingRecordsMap);
        }
        return  isChanged;
    }

    public static Set<Id> getCaseCreationFirstResMappings(){
        if(caseCreationBreezeTypes == null) {
            caseCreationBreezeTypes = new Set<Id>();
            Set<String> rtNames = new Set<String>();

            for (BREeze_Case_Creation_First_Res_Mapping__mdt mdt : [SELECT Id, DeveloperName FROM BREeze_Case_Creation_First_Res_Mapping__mdt]) {
                rtNames.add(mdt.DeveloperName.toLowerCase());
            }

            for (RecordTypeInfo rt : Case.sObjectType.getDescribe().getRecordTypeInfos()) {
                if (rtNames.contains(rt.getDeveloperName().toLowerCase())) {
                    caseCreationBreezeTypes.add(rt.getRecordTypeId());
                }
            }
        }
        return caseCreationBreezeTypes;
    }

    private static Map<String, BREeze_Case_Update_Fields_to_Eval__mdt> getCaseUpdateFieldsToEvaluate(){
        if(caseUpdateBreezeFields == null) {
            caseUpdateBreezeFields = new Map<String, BREeze_Case_Update_Fields_to_Eval__mdt>();
            List<SObject> breezeRecordTypes = [SELECT Id, MasterLabel, DeveloperName FROM BREeze_Case_Update_Fields_to_Eval__mdt];

            caseUpdateBreezeFields = (Map<String, BREeze_Case_Update_Fields_to_Eval__mdt>)
                    JSON.deserialize(
                            UGears.convertListToMap(breezeRecordTypes, 'MasterLabel'),
                            Map<String, BREeze_Case_Update_Fields_to_Eval__mdt>.class
                    );
        }
        return caseUpdateBreezeFields;
    }

    public void reRunBreeze(){
        List<Case> reRunCases = new List<Case>();
        Set<Id> validBreezeRecordTypes = getCaseCreationFirstResMappings();
        for(Case caseRec : records){
            Case existingCase = existingRecords.get(caseRec.Id);
            if(validBreezeRecordTypes.contains(caseRec.RecordTypeId) && caseRec.Run_Through_BREeze__c && existingCase != null
                    && existingCase.Run_Through_BREeze__c != caseRec.Run_Through_BREeze__c
                    &&  existingCase.Run_Through_BREeze__c == false){
                reRunCases.add(caseRec.clone(true, false, false));
            }
        }

        if(!reRunCases.isEmpty()){
            BReeze_Update = true;
            runBREeze(reRunCases, existingRecords);

            List<Case> updateRerunCases = new List<Case>();
            for(Case c : reRunCases){
                updateRerunCases.add(new Case(Id = c.Id, Run_Through_BREeze__c = false, Skill_Changed_on_Case__c = false));
            }

            update updateRerunCases;
        }
    }
}