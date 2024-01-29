public class CallSterlingCloseOrDowngradeServiceTgr
{
    // Looks for closed international cases with Reason of Cancel or Downgrade
    // And calls the Sterling platform to execute a Close or Downgrade for the associated member
   // on Case (after update)
    List<Case> TriggerNew;
    List<Case> TriggerOld;
    Map<id,Case> TriggerNewMap;
    Map<id,Case> TriggerOldMap;
    Boolean TriggerIsInsert;
    Boolean TriggerIsUpdate;
    Boolean TriggerIsDelete;
    Boolean TriggerIsBefore;
    Boolean TriggerIsAfter;
    
    ID IeRtId = getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
    ID IcRtId = getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center');
      
   public CallSterlingCloseOrDowngradeServiceTgr(){}  
   public CallSterlingCloseOrDowngradeServiceTgr(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
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
   public void processCallSterlingCloseOrDowngradeService()
   {
        //public static ID IeRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
        //public static ID IcRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
        
        for (Case c : TriggerNew){
            if (c.RecordTypeId == IeRtId || c.RecordTypeId == IcRtId){ // international email or call center record type
                if (c.isClosed && !TriggerOldMap.get(c.id).isClosed)
                { // case has just been closed
                    if (c.Cancel__c == true || c.Downgrade__c == true)
                    { // case reason is cancel or downgrade
                        if (c.Action_Time__c != null && c.Action_Time__c != 'No action')
                        { // Agent has indicated a downgrade with a Time Action
                            if (c.Member_Country__c != null){ // without country we don't know what server to hit, so preventing it here
                                if (Limits.getFutureCalls() == Limits.getLimitFutureCalls()){
                                     //Calling another future job would generate a Future error;  calling error function instead
                                       CallSterlingCloseOrDowngradeService.notifyCaseOwner(c.ownerId, c.ContactId, c.Id);
                                       CallSterlingCloseOrDowngradeService.notifySalesforceAdmin(null,'TooManyFutureCalls');
                                } else {
                                String cancelOrDowngrade = (c.Cancel__c?'Cancel':(c.Downgrade__c?'Downgrade':null));
                                if(cancelOrDowngrade!=null)
                                       CallSterlingCloseOrDowngradeService.sendRequest(c.ownerId, c.ContactId, c.Id,cancelOrDowngrade,'Other',c.Action_Time__c,c.SuppliedEmail, UserInfo.getUserEmail(),c.Member_Locale__c, c.Member_Country__c,c.Send_Cancellation_Email__c, c.Global_Member_Id__c);
                                }
                            }
                        } 
                    }
                }
            }
        }
      }
}