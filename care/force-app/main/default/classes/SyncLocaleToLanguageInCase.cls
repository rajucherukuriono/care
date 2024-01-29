/*
** _________________________________________________________________________________
** Created by:    NBOS Technologies [http://nbostechnologies.com/]
** Developer:     Sridhar Neeli, SFDC Lead [sridhar.neeli@care.com]
** Created Date:  12.22.2016
** Description:   This trigger is written as part of SFORCE-979 proejct.

** =================================================================================
*/

public class SyncLocaleToLanguageInCase
{
// on Case (before insert, before update, after update) 
List<Case> TriggerNew;
List<Case> TriggerOld;
Map<id,Case> TriggerNewMap;
Map<id,Case> TriggerOldMap;
Boolean TriggerIsInsert;
Boolean TriggerIsUpdate;
Boolean TriggerIsDelete;
Boolean TriggerIsBefore;
Boolean TriggerIsAfter;

   // public static AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

public SyncLocaleToLanguageInCase(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
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
public SyncLocaleToLanguageInCase()
{
}
public void processSyncLocaleToLanguageInCase()
{
    // This trigger covers the following use cases
    // A0 - Initiliazes the Country & Locale of Email Cases based on their origin.
    //      Context: before insert
    //      Outcome: Sets Member_Locale__c, Member_Country__c as per Case.Origin;
    //      NOTE: Use Case B below will eventually set the MemberLanguage based on the Locale as well.

    // A - Associate Member Details to a Case whenever a member is associated to the case
    //      Context: before insert, before update
    //      Outcome: copies Member_Locale__c, Member_Country__c, Member_Type__c, Global_Member_Id__c, Member_Type__c, 
    //                  Member_Account_Type__c, USAA_Member__c, OverallStatus__c,  from Contact to Case  
    //                  Also if Case has Dummy Web Email, it updates it with Contact's actual email & name
    
    // B - Update the Case/Contact Language whenever the Locale is updated
    //      Context: before insert, before update
    //      Outcome:  Changes Case.Member_Language__c according to the Locale
    
    // C - Set Case Tiers (commented out)
    //      Context: before insert, before update
    //      Outcome:  Changes Case.Tier__c depending on member criteria

    // D - This rule has been deprecated 
    // 		Re-evaluate a Case Ownership every time is status is set to escalated when type is either Call Backs, Escalations, Press, Jiras, Tinies 
    //      (re-run assignment rules)
    //      Context: after update
    //      Outcome: causes assignment rules to be re-run
    //      Warning: As designed, this use case makes an update to a case in the "after update" context, 
    //                  causing the case to be updated again.  If this causes trouble in the future,
    //                  consider writing an @future class to handle the update.  A rough draft is available in UpdateCasesAsync
    //                  
    // E - Allow reps to invoke Case Platform conversion by changing ODS Request Platform.
    //      Since this field is also changed during ODS, this logic will only be allowed after ODS is complete (Is ODS Complete == true).
    //      Since Case Platform Conversion causes Assignment Rules to be re-invoked, this logic must be run in "after update" context.
    //      Context: after update
    //      Outcome: Invokes CasePlatformConversion.convertViaTrigger() methods which will execute conversion & invoke assignment rules.
    
    // F - Invoke Assignment Rules whenever community users create a case (deprecated)
    //      Assignment Rules can only be invoked in "after insert" context
    //      Context: after insert
    //      Outcome: causes assignment rules to be invoked.


    Set<id> contactIdList=SyncMemberDetailsToCase.getContactIdList(TriggerNew);

    Map<id,Contact> caseContactMap = new Map<id,Contact>();
    if(!contactIdList.isEmpty()){        
        caseContactMap = SyncMemberDetailsToCase.getCaseContactMap(contactIdList);
    }
    Set<sObject> objectsToUpdateTrigger = new Set<sObject>();
    for (Case c: TriggerNew)
    {
            // Block off Use Cases A & B, which should only occur on before insert or before update
            if (TriggerIsBefore && (TriggerIsInsert || TriggerIsUpdate))
            {
                // Logic for Use Case A0
                if (TriggerIsInsert) { 
                    SetLocaleAndCountryInCase.main(c);
                }

                // Logic for Use Case A 
                if(!caseContactMap.isEmpty()){  
                    if (TriggerIsInsert || isAccountOrContactChanged(c))
                    { 
                       SyncMemberDetailsToCase.associateMemberDtlsToCase(c,caseContactMap);
                    }
                }
    
                // Logic for Use Case B
                if (String.isNotBlank(c.Member_Locale__c) && IsLocaleNewOrChanged(c)){
                    UpdateCaseLangBasedOnLocale.updateMemberLanguageToCase(c);
                } 
                else if(String.isBlank(c.Member_Locale__c)){
                //c.Member_Language__c=null;
                }
            }
            
            /* commented out in favor of BREeze/Omni
            // Use Case C: Set Case Tier
			if (TriggerIsBefore && TriggerIsUpdate && (c.Tier__c==null || c.Tier_Model__c == null))
            {
                     if(c.recordTypeId==getRecordTypesStatic.StandardRecordType 
                       || c.recordTypeId==getRecordTypesStatic.MobileHelpRecordType)
                       {
                           c.Tier_Model__c='US';
                       }
                      else if(c.recordTypeId==getRecordTypesStatic.InternationalEmailRecordType)
                       {
                           c.Tier_Model__c='International';
                       }
                  //Method to set case Tier value based on recordtype and other criteria.
                  SetCaseTier.setCaseTierValues(c);
            }
            else
            if (TriggerIsBefore && TriggerIsInsert)
            {
                  //Method to set case Tier value based on recordtype and other criteria.
                  SetCaseTier.setCaseTierValues(c);
            }
            */
              
            // Block off Use Cases D, This has been deprecated -
            // which should only occur after an update
            /*if (c.RecordTypeId == getRecordTypesStatic.InternationalCallCenterRecordType || c.RecordTypeId == getRecordTypesStatic.InternationalEmailRecordType){ // limit this to international cases only 
                if (TriggerIsAfter && TriggerIsUpdate){
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    //Gears Case:00042482
                    //Moved to Breeze
                    //Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    //dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
    
                    // Logic of Use Case D
                    if (IsEscalatedToExternalTeamAndStatusChanged(c)){
                        Case caseToUpdate = new Case(id = c.id); // create writable Case for update
                        //caseToUpdate.setOptions(dmlOpts);
                        objectsToUpdateTrigger.add(caseToUpdate);
                    }               
                }
            } */

            // Use Case E: Invoke Case Platform Conversion        
            if (TriggerIsAfter && TriggerIsUpdate){
                List<sObject> ConvertedCases = CasePlatformConversion.convertViaTrigger(TriggerNew,TriggerOldMap);
                if (!ConvertedCases.isEmpty()) objectsToUpdateTrigger.addAll(ConvertedCases);
            }

            // Use Case F: Invoke Assignment Rules for cases created in community
            // SFORCE-4131 - Moved the logic of assignmentrule to CaseTriage Process Builder
            //if (TriggerIsAfter && TriggerIsInsert){
                //if (c.Creator_License__c == 'Guest' && c.Origin != 'Chat'){
                    //Gears Case:00042482
                    //Moved to Breeze
                    //Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    //dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                    //Case cRW = new Case(id = c.id); // create writable Case for update
                    //cRW.setOptions(dmlOpts);
                    //objectsToUpdateTrigger.add(cRW);
                //}
            //}

        
    }
    
    List<sObject> objectsToUpdateList = new List<sObject>();
    objectsToUpdateList.addAll(objectsToUpdateTrigger); // convert set to list to pass to update statement;
    update objectsToUpdateList;

}

    boolean IsLocaleNewOrChanged(Case c){
        // on insert: check whether a locale is not blank; on update, check whether locale has changed
        if (TriggerIsInsert) return true;
        else if (TriggerIsUpdate){
            Case oldC = TriggerOldMap.get(c.id);
            if (c.Member_Locale__c != oldC.Member_Locale__c){
                return true;
            }           
        }
    return false;
    }       

    boolean isAccountOrContactChanged(Case c){
        if (TriggerIsInsert) return true;
        else if (TriggerIsUpdate){
            Case oldC = TriggerOldMap.get(c.id);
            if (c.ContactId != oldC.ContactId) return true;
            if (c.AccountId != oldC.AccountId) return true;
        }
    return false;
    }       

    
    // Block off Use Cases D, This has been deprecated 
 /*boolean IsEscalatedToExternalTeamAndStatusChanged(Case c){
        Case oldC = TriggerOldMap.get(c.id);
        if (c.status != oldC.status){
            if (c.status == 'Escalated'){
                if (c.type == 'Call Backs' || c.type == 'Escalations' || c.type == 'Press' || c.type == 'Jiras' || c.type == 'Tinies'){
                    return true;
                }
            }
        }
        return false;
    }  
*/
    
// Code was deprecated when we removed the logic to automatically reapply assignment rules whenever the language is changed
/*  
    boolean IsLanguageChanged(Case c){
        Case oldC = TriggerOldMap.values()Map.get(c.id);
        if (c.Member_Language__c != oldC.Member_Language__c){
            return true;
        }
    return false;
    }
    */      
}