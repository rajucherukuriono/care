public class SeniorCareCaseCountTrigger
{
// on Case (after delete, after insert, after update) {
    List<Case> TriggerNew;
    List<Case> TriggerOld;
    Map<id,Case> TriggerNewMap;
    Map<id,Case> TriggerOldMap;
    Boolean TriggerIsInsert;
    Boolean TriggerIsUpdate;
    Boolean TriggerIsDelete;
    Boolean TriggerIsBefore;
    Boolean TriggerIsAfter;
    ID scCaseRtId = getRecordTypesStatic.recordTypeNameIdMap.get('Senior Care Consult');
public SeniorCareCaseCountTrigger(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
{
    this.TriggerOld=TriggerOld;
    this.TriggerNew=TriggerNew;
    this.TriggerNewMap=TriggerNewMap;
    this.TriggerOldMap=TriggerOldMap;
    this.TriggerIsInsert=TriggerIsInsert;
    this.TriggerIsUpdate=TriggerIsUpdate;
    this.TriggerIsDelete=TriggerIsDelete;
    this.TriggerIsBefore=TriggerIsBefore;
    this.TriggerIsAfter=TriggerIsAfter;
}
public SeniorCareCaseCountTrigger()
{
}
public void processSeniorCareCaseCountTrigger()
{
      //private static ID scCaseRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Care Consult').getRecordTypeId();
    
      Set<Case> CasesToPass = new Set<Case>();
      Set<Id> aToRemove = new Set<Id>(); 
    
      // For insert, we pass all senior care cases
      if (TriggerIsInsert){
        for (Case c: TriggerNew){
          if (c.recordtypeId == scCaseRtId) CasesToPass.add(c);
        }    
        
      // For update, we pass senior care cases whose Account Ids or RecordTypeIds have changed;
      // And we pass Account Ids that USED to have Senior Care cases, 
      // so that their counts can be recalculated
      } else if (TriggerIsUpdate){
        for (Case c: TriggerNew){
          if (c.recordtypeId == scCaseRtId && 
              (c.AccountId != TriggerOldMap.get(c.id).AccountId || c.recordtypeId != TriggerOldMap.get(c.id).recordtypeId)
              ){
            CasesToPass.add(c);
            aToRemove.add(TriggerOldMap.get(c.id).AccountId);
          }
        }    
      // For delete, we pass Account Ids that USED to have Senior Care cases, 
      // so that their counts can be recalculated
      } else if (TriggerIsDelete){
        for (Case c: TriggerOld){
          if (c.recordtypeId == scCaseRtId) aToRemove.add(c.AccountId);
        }    
      }
      SeniorCareCaseCount.caseCount(new List<Case>(CasesToPass),new List<ID>(aToRemove));
  }
}