trigger HandleVettedLeads on Lead (before insert, before update, after insert, after update) {
// JHO 2014-006-12
// This is a general purpose trigger that is designed to handle leades handed offs between teams
// When leads are set to the "Vetted" status, it will:
// 1) record Vetted By & Vetted Date, Vetted Date Time
// 2) apply the assignment rules on the lead (causing its ownership to be re-evaluated)
//      Admins should assign the lead to the appropriate queue for the receiving team

System.debug('1====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
    private static AssignmentRule LeadAR = [select id from AssignmentRule where Name = 'Lead Assignment Rules' and Active = true limit 1];
    System.debug('2====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
    Set<sObject> objectsToUpdate = new Set<sObject>();
    Set<Id> VettedLeadSet = new Set<Id>(); // a set to hold a list of all the leads that need to be updated
    boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
if(!bypassLeadTriggers)
{
    for (Lead l : trigger.new){
        
        if (isLeadStatusChanged(l) && l.Status == 'Vetted' && !l.isConverted){ // has the status changed? Is it "vetted"? Is it getting converted?
            VettedLeadSet.add(l.id);
            System.debug('3====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
        }
    }
    Map<Id, Lead> VettedLeadMap = new Map<Id, Lead>([SELECT id FROM Lead WHERE id IN :VettedLeadSet]);
System.debug('4====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        for (ID lId : VettedLeadMap.keySet()){
            Lead l = Trigger.newMap.get(lId);
            l.Vetted_By__c = userInfo.getUserId();
            l.Vetted_Date__c = System.Today();
            l.Vetted_Date_Time__c = System.Now();
        }
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        for (Lead l : VettedLeadMap.values()){
        System.debug('5====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = LeadAR.id;
            l.setOptions(dmlOpts);              
            objectsToUpdate.add(l);
            System.debug('6====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
        }
        System.debug('7====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());

        List<sObject> ObjectsToUpdateList = new List<sObject>();
        ObjectsToUpdateList.addAll(ObjectsToUpdate); // convert set to list to pass to insert statement;
        update ObjectsToUpdateList;
        System.debug('8====>: Number of queries issued'+Limits.getQueries()+' Soql limit ===>:'+Limits.getLimitQueries());
    }

}
    private static boolean isLeadStatusChanged(Lead l){
        if (Trigger.isInsert) return true;
        else if (Trigger.isUpdate){
            Lead oldL = Trigger.oldMap.get(l.id);
            if (l.Status != oldL.Status) return true;
        }
    return false;
    }
          
}