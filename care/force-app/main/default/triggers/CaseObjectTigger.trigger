trigger CaseObjectTigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    boolean bypassCaseTriggers=Override_Validation_Rules__c.getInstance().Override_Case_Triggers__c;
    if(!bypassCaseTriggers)
    {
        system.debug('into CaseObjectTigger***************'+Trigger.isInsert+'**'+ Trigger.isUpdate+'**'+Trigger.isDelete+'**'+Trigger.isBefore+'**'+ Trigger.isAfter);
        TriggerDispatcher.run(new CaseTriggerHandler()); 
    }
}