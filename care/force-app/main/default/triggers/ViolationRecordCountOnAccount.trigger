trigger ViolationRecordCountOnAccount on Infraction__c (before insert,after insert,before update,after delete) { 
    List<id> vetIds=new List<id>();
    for(Infraction__c violationObj:Trigger.isDelete?Trigger.Old:Trigger.new){
        vetIds.add(violationObj.Vetting_Object__c);
    }
    Map<id,Vetting__c> vetIdAccMap=new Map<id,Vetting__c>([SELECT ID,BUC_Center_Name__c FROM Vetting__c where Id in :vetIds and Recordtype.Name = 'US BUC Network Vetting']);
    List<Id> accIdsList=new List<Id>();
    for(Vetting__c violationObj:vetIdAccMap.values()){
        accIdsList.add(violationObj.BUC_Center_Name__c);
    }    
    if(Trigger.isBefore && Trigger.isInsert) {
        if(!vetIdAccMap.isEmpty()){
            for(Infraction__c violationObj:Trigger.new)  {
                violationObj.BUC_Center_Name__c=vetIdAccMap.get(violationObj.Vetting_Object__c).BUC_Center_Name__c;
            }
        }
        List<Account> accList=[select id,Violation_Records_Present__c,Violation_Record_Count__c from Account where id in:accIdsList];
        for(Account accObj:accList){
            if(accObj.Violation_Record_Count__c!=null && accObj.Violation_Record_Count__c >= 1)  {
                accObj.Violation_Record_Count__c=accObj.Violation_Record_Count__c+1;
                //accObj.Violation_Records_Present__c=accObj.Violation_Records_Present__c+1;
            }
            else{
                accObj.Violation_Record_Count__c=1;
                //accObj.Violation_Records_Present__c=1;
            }
        }        
        update accList;  
    }    
    else if(Trigger.isBefore && Trigger.isUpdate){
            if(!vetIdAccMap.isEmpty()){
                for(Infraction__c violationObj:Trigger.new)
                {
                    violationObj.BUC_Center_Name__c=vetIdAccMap.get(violationObj.Vetting_Object__c).BUC_Center_Name__c;
                }
            }
        }
    else if(Trigger.isAfter && Trigger.isInsert)
    {
        List<Account> accList=[select id,Violation_Records_Present__c,Violation_Record_Count__c,(select id from Infractions__r) from Account where id in:accIdsList];          
        for(Account accObj:accList){            
            accObj.Violation_Records_Present__c=accObj.Infractions__r.size();
            /*
            if(accObj.Violation_Record_Count__c!=null && accObj.Violation_Record_Count__c >= 1){
                accObj.Violation_Record_Count__c=accObj.Violation_Record_Count__c+1;           
            }
            else{
                accObj.Violation_Record_Count__c=1;
            }
            */
        }        
        update accList;  
    }
    else if(Trigger.isAfter && Trigger.isDelete)
    {
        for(Infraction__c violationObj:Trigger.old) {            
            accIdsList.add(violationObj.BUC_Center_Name__c);
        }
        List<Account> accList=[select id,Violation_Record_Count__c,Violation_Records_Present__c,(select id from Infractions__r) from Account where id in:accIdsList];
        for(Account accObj:accList){
            /*
            if(accObj.Violation_Records_Present__c!=null && accObj.Violation_Records_Present__c>= 1){
                accObj.Violation_Records_Present__c=accObj.Violation_Records_Present__c-1;
            }
            else{
                accObj.Violation_Records_Present__c=0;
            }
            */
            accObj.Violation_Records_Present__c=accObj.Infractions__r.size();
        }        
        update accList;         
    }
}