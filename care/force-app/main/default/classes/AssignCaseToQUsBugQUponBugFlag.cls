public class AssignCaseToQUsBugQUponBugFlag
{
// on Case (before insert,before update) {
List<Case> TriggerNew;
List<Case> TriggerOld;
Map<id,Case> TriggerNewMap;
Map<id,Case> TriggerOldMap;
Boolean TriggerIsInsert;
Boolean TriggerIsUpdate;
Boolean TriggerIsDelete;
Boolean TriggerIsBefore;
Boolean TriggerIsAfter;
//Group qUsBug=[select id,name from Group where name='Q: US: Bugs'];
Id qUSBugId=getRecordTypesStatic.groupNameIdMap.get('Q: US: Bugs');
//ID IWpsServiceRtId = getRecordTypesStatic.recordTypeNameIdMap.get('International WPS Service');

public AssignCaseToQUsBugQUponBugFlag(){
}
public AssignCaseToQUsBugQUponBugFlag(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
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
public void processAssignCaseToQUsBugQUponBugFlag()
{

        for(Case caseObj: TriggerNew)
        {
            if((caseObj.Bug__c==true && ((TriggerIsUpdate && TriggerOldMap.get(caseObj.id).Bug__c==false) || TriggerIsInsert) && caseObj.ownerId!=qUSBugId)
            ||
            (caseObj.Bug__c==true && caseObj.status=='Reopened' && (TriggerIsUpdate && TriggerOldMap.get(caseObj.id).status=='Closed')))
            {
                caseObj.ownerId=qUSBugId;
            }
        }

/*
if(runOnce())
{
        // Set DML Options to invoke assignment rules
        AssignmentRule AR = [select id from AssignmentRule where Name = 'Care.com Membercare Case Assignment' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        List<Case> caseList=[select id,Bug__c,status,ownerId from case where id =:TriggerNewMap.keySet()];     
        for(Case caseObj: caseList)
        {
            if((caseObj.Bug__c==true && TriggerOldMap.get(caseObj.id).Bug__c==false && caseObj.ownerId!=qUsBug.id)
            ||
            (caseObj.Bug__c==true && caseObj.status=='Reopened' && TriggerOldMap.get(caseObj.id).status=='Closed'))
            {
            //caseObj.ownerId=qUsBug.id;
                caseObj.setOptions(dmlOpts);
            
            }
        }
        if(!caseList.isEmpty())
        update caseList;
    }
*/
}

/*
private static boolean runOnlyOnceLocalBug = true;
    public boolean runOnce(){
    if(runOnlyOnceLocalBug){
     runOnlyOnceLocalBug=false;
     return true;
    }else{
        return runOnlyOnceLocalBug;
        }
    }
    */
}