/*
Description:  Copies Account data of a case to a contact of same case
ModifiedBy : md Ashwaq
ModifiedDate: 02/07/2023
*/
public class CopyPersonAccountToContactOnCase
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
    
    public CopyPersonAccountToContactOnCase(){
    }
    public CopyPersonAccountToContactOnCase(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
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
    public void processCopyPersonAccountToContactOnCase()
    {
        System.debug('1:   Limits.getQueries======>:'+Limits.getQueries());
        System.debug('1:   Limits.getLimitQueries======>:'+Limits.getLimitQueries());
        
        List<Id> NewAccounts=new List<Id>();
        List<Case> CasesWithNullAccounts=new List<Case>();
        Map<Id,Case> accIdvsCaseObjMap=new Map<Id,Case>();
        
        List<String> recNameList = new List<String>{'Standard','Call Center','International Email','International Call Center','International BUC','Chargeback','External Feedback','Social Media US', 'Social Media International'};
        Map<String,Id> RecordTypeIdMap = getRecordTypesStatic.getFilteredRecNameIdMap(recNameList);
        
        System.debug('2:   Limits.getQueries======>:'+Limits.getQueries());
        System.debug('2:   Limits.getLimitQueries======>:'+Limits.getLimitQueries());
        for(Case caseObj:TriggerNew)
        {
            // 2018-10-23: Jack Odell: Logic update:
            // This trigger is now being filtered based on Case record type
            
            if ( IsValidRecordTypeId(RecordTypeIdMap,caseObj.RecordTypeId)
               )
            {
                // 2018-10-23: Jack Odell: Logic update:
                // On Insert: if Account exists & Contact is null, then propagate Account to Contact
                // On Update: if Account has changed, then propagate Account to Contact.  This means that if Account is changed, Contact will be changed to match Account (even if null)
                if(
                    (TriggerIsInsert && caseObj.accountId!=null && caseObj.contactId==null) || 
                    (TriggerIsUpdate && caseObj.accountId!=TriggerOldMap.get(caseObj.id).accountId)
                ){
                    if (caseObj.accountId!=null){ // handle accounts that have been added/updated
                        NewAccounts.add(caseObj.accountId);
                        accIdvsCaseObjMap.put(caseObj.accountId,caseObj);
                    } else { // handle Accounts that have been removed
                        CasesWithNullAccounts.add(caseObj);
                    }
                }
            }
        }

        if((TriggerIsInsert || TriggerIsUpdate) && TriggerIsBefore)
        {
            if (!NewAccounts.isEmpty()){ // 2018-10-23: Jack Odell: prevent query if Account List is empty
                for(Account accObj:[select id,personContactId,recordTypeId from Account where isPersonAccount=true and id=:NewAccounts]){
                    accIdvsCaseObjMap.get(accObj.id).contactId=accObj.personContactId ;
                }
            }
            if (!CasesWithNullAccounts.isEmpty()){ // Handle Null Accounts
                for (Case c : CasesWithNullAccounts){
                    c.ContactId = null;
                }
            }

            System.debug('3:   Limits.getQueries======>:'+Limits.getQueries());
            System.debug('3:   Limits.getLimitQueries======>:'+Limits.getLimitQueries());
        }
    }

    public Boolean IsValidRecordTypeId(Map<String,Id> RecordTypeIdMap, Id CaseRecordTypeId){
        for (Id RecordTypeId : RecordTypeIdMap.values()){
            if (RecordTypeId == CaseRecordTypeId) return true;
        }
        return false;
    }
}