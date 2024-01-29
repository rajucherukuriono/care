/*
** _______________________________________________________________________________
** Created by:    Wavelabs [https://www.wavelabs.ai]
** Developer:     Sridhar, Salesforce Architect [sridhar.neeli@care.com]
** Created Date:  12.12.2019
** ===============================================================================
** Description: 
** This class defines logic to copy web fields on case to custom fields.
** 
** _______________________________________________________________________________
*/
public class CopyHiddenWebFieldsOnCaseToCustFields
{

List<Case> TriggerNew;
List<Case> TriggerOld;
Map<id,Case> TriggerNewMap;
Map<id,Case> TriggerOldMap;
Boolean TriggerIsInsert;
Boolean TriggerIsUpdate;
Boolean TriggerIsDelete;
Boolean TriggerIsBefore;
Boolean TriggerIsAfter;

public CopyHiddenWebFieldsOnCaseToCustFields(){
}
public CopyHiddenWebFieldsOnCaseToCustFields(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
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
public void processCopyHiddenWebFieldsOnCaseToCustFields()
{
            Id homepayPrivacyRecTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Privacy');
            Id galorePrivacyRecTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('Galore Privacy');
    for(Case caseObj:TriggerNew)
    {
        if(caseObj.recordTypeId==homepayPrivacyRecTypeId || caseObj.recordTypeId==galorePrivacyRecTypeId)
        {
            if(!String.isBlank(caseObj.SuppliedEmail))
            caseObj.Email_m__c=caseObj.SuppliedEmail;
            if(!String.isBlank(caseObj.SuppliedName))
            caseObj.Name_m__c=caseObj.SuppliedName;
        }
    }
}
 }