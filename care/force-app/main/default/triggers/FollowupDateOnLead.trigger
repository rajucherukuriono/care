trigger FollowupDateOnLead on Task (after insert, after update) {
    
    public Set<Id> LeadIDs = new Set<Id>();
    
    Id leadRecordTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay B2C Lead');
    
    // Build the list of Leads to update
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        for(Task t: Trigger.isInsert?Trigger.new:Trigger.old){
            if(
                (Trigger.isAfter && Trigger.isUpdate && trigger.oldMap.get(t.id).whoId!=null && string.valueOf(trigger.oldMap.get(t.id).whoId).startsWith('00Q'))
                ||
                (Trigger.isAfter && Trigger.isInsert && trigger.newMap.get(t.id).whoId!=null && string.valueOf(trigger.newMap.get(t.id).whoId).startsWith('00Q'))
            )
                
            {
                system.debug('trigger new activity date >>>>'+ t.ActivityDate);
                
                LeadIDs.add(t.WhoId);
                System.debug('Lead Ids >>>> '+LeadIDs) ;
            }
        }
    }
    
    List<Lead> LeadsToUpdate=new List<Lead>([SELECT Id, Due_Date__c, RecordtypeId, (SELECT Id, Subject, ActivityDate FROM Tasks ORDER BY ActivityDate ASC) FROM Lead WHERE Id in :LeadIDs and recordTypeId=:leadRecordTypeId]);
    
    for(Lead leadObj:LeadsToUpdate)
    {
        Boolean found = false;
            for(Integer i=0;i<LeadObj.Tasks.size();i++)
            {
                
                Task tsk=LeadObj.Tasks[i];
                
                if( LeadObj.Tasks[i].ActivityDate >= System.today())
                {
                    System.debug('Updating Leadobj.id >>>> '+leadObj.tasks[i].ActivityDate);
                    leadObj.due_date__c=leadObj.tasks[i].ActivityDate;
                    found = true;
                    break;
                }
            }
            if (!found )
                leadObj.due_date__c = null;

    }
    
    
    try{
        if(!LeadsToUpdate.isEmpty()) update LeadsToUpdate;
    } catch (Exception ex) {
    }
    
}