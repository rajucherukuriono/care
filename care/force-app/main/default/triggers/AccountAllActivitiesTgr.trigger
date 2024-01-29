trigger AccountAllActivitiesTgr on Task (before insert,before update) 
//trigger AccountAllActivitiesTgr on Task (after insert,before insert,before update,after update) 
{
Map<Id,Task> leadTasksMap=new Map<Id,Task>();
Map<Id,Task> contactTasksMap=new Map<Id,Task>();
//Map<Id,Task> accTasksMap=new Map<Id,Task>();
Map<Id,Task> oppTasksMap=new Map<Id,Task>();
//List<Task> leadTasks=[SELECT Id,AccountId,Business_Account__c,Type,WhatId,WhoId,ActivityDate,CallObject,CallType,Comment_Summary__c,CreatedById,CreatedDate,Description,IsClosed,IsDeleted,LastModifiedById,LastModifiedDate,OwnerId,Priority,RecordTypeId,Status,Subject,TaskSubtype FROM Task where whoId=:leadList order by createddate desc];
Set<Id> leadSet=new Set<Id>();
Set<Id> contSet=new Set<Id>();
Set<Id> oppSet=new Set<Id>();
    //if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    //if(Trigger.isBefore && Trigger.isInsert)
    //{
        for(Task tObj:Trigger.new)
        {
            //if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            if(Trigger.isBefore && Trigger.isInsert)
            {
                    tObj.Activity_Type__c=tObj.Type;
                    if(tObj.whoId!=null && (String.valueOf(tobJ.whoId)).startsWith('00Q'))
                    {
                        leadTasksMap.put(tObj.whoId,tObj);
                        leadSet.add(tObj.whoId);
                        //tObj.Business_Account__c=tobj.whoId;
                    }
                    else if(tObj.whoId!=null && (String.valueOf(tobJ.whoId)).startsWith('003'))
                    {
                        contactTasksMap.put(tObj.whoId,tObj);
                        contSet.add(tObj.whoId);
                    }
                    else if(tObj.whatId!=null && (String.valueOf(tobJ.whatId)).startsWith('001'))
                    {
                        //accTasksMap.put(tObj.id,tObj);
                        tObj.Business_Account__c=tobj.whatId;
                    }
                    else if(tObj.whatId!=null && (String.valueOf(tobJ.whatId)).startsWith('006'))
                    {
                        oppTasksMap.put(tObj.whatId,tObj);
                        oppSet.add(tObj.whatId);
                    }
            }
        }
        
        List<id> contListIds=new List<id>(); contListIds.addAll(contSet);
        Map<Id,Contact> contMap=new Map<Id,Contact>([select id,name,accountId from Contact where id=:contListIds]);
        /*
        Map<Id,List<Id>> accIdContListMap=new Map<Id,List<Id>>();
        for(Contact contObj:contMap)
        {
            if(accIdContListMap.get(contObj.accountId)==null) accIdContListMap.put(contObj.accountId,new List<Id>(contObj.Id));
            else
            accIdContListMap.get(contObj.accountId).add(contObj.id);
        }
        */
        for(Task t:contactTasksMap.values()){
            if(contMap.get(t.whoId)!=null)   
            {
            t.Business_Account__c=contMap.get(t.whoId).accountId;
            t.contact_name__c=contMap.get(t.whoId).name;
            }
        }
        
        
        
                List<id> oppListIds=new List<id>(); oppListIds.addAll(oppSet);
        Map<Id,Opportunity> oppMap=new Map<Id,Opportunity>([select id,name,accountId from Opportunity where id=:oppListIds]);
        for(Task t:oppTasksMap.values()){
            if(oppMap.get(t.whatId)!=null)   {
            t.opportunity_name__c=oppMap.get(t.whatId).name;
            t.Business_Account__c=oppMap.get(t.whatId).accountId;
            }
        }
        
        List<id> leadListIds=new List<id>(); leadListIds.addAll(leadSet);
        Map<Id,Lead> leadMap=new Map<Id,Lead>([select id,name,Business_Account__c from Lead where id=:leadListIds]);
        for(Task t:leadTasksMap.values()){
            if(leadMap.get(t.whoId)!=null) { 
            t.Lead_Name__c=leadMap.get(t.whoId).name;
             t.Business_Account__c=leadMap.get(t.whoId).Business_Account__c;
            }
        }
        
   // }
}