/*
Helper Class for Case Trigger
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
ModifiedDate: 22/09/2023
*/
public class TriggerDispatcher {
    public static void run(ITriggerHandlerInf handler){
        if(Trigger.isBefore){    
            if(Trigger.isInsert){
                handler.beforeInsert((list<case>)Trigger.new, (list<case>)Trigger.new, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)Trigger.newMap, Trigger.isInsert, false,false,Trigger.isBefore, false);
            }
            if(Trigger.isUpdate){
                handler.beforeUpdate((list<case>)Trigger.new, (list<case>)Trigger.old, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)(Map<Id, case>)Trigger.oldMap, false,Trigger.isUpdate, false, Trigger.isBefore, false);
            }
            if(Trigger.isDelete){
                handler.beforeDelete((list<case>)Trigger.new, (list<case>)Trigger.old, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)Trigger.oldMap, false,false, Trigger.isDelete, Trigger.isBefore, false);
            }
        }
        if(Trigger.isAfter){    
            if(Trigger.isInsert){
                handler.afterInsert((list<case>)Trigger.new, (list<case>)Trigger.new, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)Trigger.newMap, Trigger.isInsert,false,false,false,Trigger.isAfter);
            } 
            if(Trigger.isUpdate){
                handler.afterUpdate((list<case>)Trigger.new, (list<case>)Trigger.old, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)Trigger.oldMap, false,Trigger.isUpdate,false, false,Trigger.isAfter);
            }
            if(Trigger.isDelete){
                handler.afterDelete((list<case>)Trigger.new, (list<case>)Trigger.old, (Map<Id, case>)Trigger.newMap, (Map<Id, case>)Trigger.oldMap, false,false,Trigger.isDelete,false,Trigger.isAfter);
            }
        }
        
    }
}