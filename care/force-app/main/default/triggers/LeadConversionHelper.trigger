trigger LeadConversionHelper on Lead (before update, after update) {
    // JHO - 2014-06-11
    // This trigger is designed to make generic changes to leads upon conversion.  As such, 
    // it is intended to be shared across all Leads in org.  It supports the following use cases:
    // 1) When a lead is about to be converted, its sets the ConvertedDateTime field
    // 2) After a lead is converted
    //      a) Set Contact.Converted_By__c to the current user
    //      b) If Lead.Vetted_By__c is blank, set Contact.Vetted_By__c to the current user 
    boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
    if(!bypassLeadTriggers)
    {
        // Use Case 1 - when the lead is about to be converted
        if (Trigger.isBefore && Trigger.isUpdate){
            // get my hands on the lead statuses of all the leads and figure out whether they are converted types
            LeadStatus[] ConvertedStatuses = [SELECT MasterLabel FROM LeadStatus WHERE isConverted = true];
            for (Lead l : trigger.newMap.values()){
                if (l.Status != trigger.oldmap.get(l.id).Status){ // has the status changed?
                    for (LeadStatus ls : ConvertedStatuses){
                        if (l.Status == ls.MasterLabel){ // Is the status a convertedStatus?
                            // INSERT THINGS YOU WANT TO DO TO A LEAD ABOUT TO BE CONVERTED HERE
                            l.Converted_Date_Time__c = System.now();
                        }
                    }
                }
            }
        }
        
        // Use Case 2 - after lead is converted
        if (Trigger.isAfter && Trigger.isUpdate){
            Set<sObject> ObjectsToUpdate = new Set<sObject>();
            Set<Id> ConvertedContactIdsSet = new Set<Id>(); // a set to hold a list of all the converted contact ids
            Map<Id, Lead> LeadsMap = new Map<Id, Lead>(); // map convertedContactIds back to the converted lead
            for (Lead l : trigger.newMap.values()){
                if (l.IsConverted && !trigger.oldmap.get(l.id).IsConverted){ // is the lead converted? has the value just changed?
                    ConvertedContactIdsSet.add(l.convertedContactId);
                    LeadsMap.put(l.convertedContactId,l);
                }
            }
            Map<Id, Contact> ContactsMap = new Map<Id, Contact>([SELECT id,Converted_By__c FROM Contact WHERE id IN :ConvertedContactIdsSet]);
            
            for (Contact c : ContactsMap.values()){
                c.Converted_By__c = userInfo.getUserId();           
                if (null == LeadsMap.get(c.id).Vetted_By__c) c.Vetted_By__c = userInfo.getUserId();
                
                ObjectsToUpdate.add(c);
            }
            
            List<sObject> ObjectsToUpdateList = new List<sObject>();
            ObjectsToUpdateList.addAll(ObjectsToUpdate); // convert set to list to pass to insert statement;
            update ObjectsToUpdateList;
        }
    }
}