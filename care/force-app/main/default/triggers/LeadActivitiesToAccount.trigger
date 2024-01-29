/*
  If the Lead is having any associated Account(Business Account), and for that accounts if there are any contacts and Opportunities, all of these
  Account/Contact/Opportunity tasks are updated in the Lead Task related lists.
  */
  trigger LeadActivitiesToAccount on Lead (before insert,before update) {
    
    Map<id,id> leadIdvsaccIdMap=new Map<id,id>();
    Map<id,id> leadIdvsaccIdDelMap=new Map<id,id>();
    Set<Task> allTasksSet=new Set<Task>();
    Set<Task> allAccTasksSet=new Set<Task>();
    Set<Task> allContTasksSet=new Set<Task>();
    Set<Task> allOppTasksSet=new Set<Task>();
    Set<Task> allLeadTasksSet=new Set<Task>();
    Set<Id> accIdSet=new Set<Id>();
    Set<Id> accIdDelSet=new Set<Id>();
    List<Id> accIdList=new List<Id>();
    List<Id> accIdDelList=new List<Id>();
    boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
    if(!bypassLeadTriggers)
    {
        Id taskDefaultRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        for(Lead l:Trigger.new)
        {
            //system.debug('String.isBlank l.Business_Account__c in for loop================>:'+String.isBlank(l.Business_Account__c));
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            {
                if(l.Business_Account__c!=null && (Trigger.isInsert  || (Trigger.isUpdate && Trigger.oldMap.get(l.Business_Account__c)==null)))
                {
                    leadIdvsaccIdMap.put(l.id,l.Business_Account__c);
                    accIdSet.add(l.Business_Account__c);
                }
                /*
else        
if(Trigger.isBefore && Trigger.isUpdate && l.Business_Account__c!=null &&
Trigger.newMap.get(l.id).Business_Account__c!=Trigger.oldMap.get(l.id).Business_Account__c)
{
leadIdvsaccIdMap.put(l.id,l.Business_Account__c);
system.debug('2nd If l.id===>:'+l.id);
}
*/
                //if(l.Business_Account__c==null && Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && !String.isBlank(Trigger.oldMap.get(l.id).Business_Account__c))))
                if(Trigger.isBefore && Trigger.isUpdate && Trigger.oldMap.get(l.id).Business_Account__c!=null && l.Business_Account__c==null)
                {
                    leadIdvsaccIdDelMap.put(l.id,Trigger.oldMap.get(l.id).Business_Account__c);
                    accIdDelSet.add(Trigger.oldMap.get(l.id).Business_Account__c);
                    
                }
            }
        }
        //system.debug('accIdSet.size()=======>:'+accIdSet.size());
        //system.debug('accIdDelSet.size()=======>:'+accIdDelSet.size());
        //system.debug('leadIdvsaccIdDelMap.keySet()=====>:'+leadIdvsaccIdDelMap.keySet());
        if(!accIdSet.isEmpty())
            accIdList.addAll(accIdSet);
        if(!accIdDelSet.isEmpty())
            accIdDelList.addAll(accIdDelSet);
        /**************************************************************************************************************************/
        
        //System.debug('--1--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
        if(leadIdvsaccIdMap.size()>0)
        {
            List<Task> leadTasks=[SELECT Id,AccountId,whoId,whatId,Business_Account__c FROM Task where Who.type='Lead' and RecordTypeId=:taskDefaultRecTypeId and  whoId=:leadIdvsaccIdMap.keySet() order by createddate desc];
            //System.debug('--2--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:leadTasks){
                t.Business_Account__c=leadIdvsaccIdMap.get(t.whoId);
                //t.Business_Account__c='0010m00000CMPZT';
                //system.debug('In for loop leadIdvsaccIdMap.get(t.whoId)===>:'+leadIdvsaccIdMap.get(t.whoId));
            }
            
            allLeadTasksSet.addAll(leadTasks);
        }
        if(leadIdvsaccIdDelMap.size()>0)
        {
            List<Task> leadDelTasks=[SELECT Id,AccountId,whoId,whatId,Business_Account__c FROM Task where Who.type='Lead' and RecordTypeId=:taskDefaultRecTypeId and  whoId=:leadIdvsaccIdDelMap.keySet() order by createddate desc];
            //System.debug('--3--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:leadDelTasks)
            {
                t.Business_Account__c=null;
            }
            allLeadTasksSet.addAll(leadDelTasks);
        }
        
        /**************************************************************************************************************************/
        if(accIdList.size()>0)
        {
            List<Task> accTasks=[SELECT Id,AccountId,whoId,whatId,Business_Account__c FROM Task where What.type='Account' and RecordTypeId=:taskDefaultRecTypeId and  whatId=:accIdList order by createddate desc];
            //System.debug('--4--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:accTasks){
                t.Business_Account__c=t.accountId;
            }
            
            allAccTasksSet.addAll(accTasks);
        }
        
        if(accIdDelList.size()>0)
        {
            /*
String inClause='';
for(integer i=0;i<accIdDelList.size();i++){
if(i==accIdDelList.size()-1)
inClause=inClause+'\''+accIdDelList[i]+'\'';
else 
inClause=inClause+'\''+accIdDelList[i]+'\',';
}
*/
            List<Task> accDelTasks=[SELECT Id,AccountId,whoId,whatId,Business_Account__c FROM Task where What.type='Account' and RecordTypeId=:taskDefaultRecTypeId and  whatId =:accIdDelList order by createddate desc LIMIT 100];
            //System.debug('--5--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:accDelTasks)
            {
                t.Business_Account__c=null;
            }
            allAccTasksSet.addAll(accDelTasks);
            
        }
        /**************************************************************************************************************************/
        if(accIdList.size()>0)
        {
            Map<id,Contact> contMap=new Map<id,Contact>([select id,accountId from Contact where accountId=:accIdList]);
            //System.debug('--6--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            List<Task> contTasks=[SELECT Id,AccountId,Type,WhatId,WhoId,Business_Account__c FROM Task where Who.type='Contact' and RecordTypeId=:taskDefaultRecTypeId and  whoId=:contMap.keySet() order by createddate desc];
            //System.debug('--7--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:contTasks){
                t.Business_Account__c=contMap.get(t.whoId).accountId;
            }
            allContTasksSet.addAll(contTasks);
            
        } 
        
        
        
        if(accIdDelList.size()>0)
        {
            Map<id,Contact> contMap=new Map<id,Contact>([select id,accountId from Contact where accountId=:accIdDelList]);
            //System.debug('--8--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            List<Task> contTasks=[SELECT Id,AccountId,Type,WhatId,WhoId,Business_Account__c FROM Task where Who.type='Contact' and RecordTypeId=:taskDefaultRecTypeId and whoId=:contMap.keySet() order by createddate desc];
            //System.debug('--9--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:contTasks){
                t.Business_Account__c=null;
            }
            allContTasksSet.addAll(contTasks);
            
        }
        
        /**************************************************************************************************************************/
        if(accIdList.size()>0)
        {
            Map<id,Opportunity> oppMap=new Map<id,Opportunity>([select id,accountId from Opportunity where accountId=:accIdList]);
            //System.debug('--10--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            List<Task> oppTasks=[SELECT Id,AccountId,Type,WhatId,WhoId,Business_Account__c FROM Task where What.type='Opportunity' and RecordTypeId=:taskDefaultRecTypeId and  whatId=:oppMap.keySet() order by createddate desc];
            //System.debug('--11--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:oppTasks){
                t.Business_Account__c=oppMap.get(t.whatId).accountId;
            }
            allOppTasksSet.addAll(oppTasks);
            
        }
        
        
        if(accIdDelList.size()>0){
            
            Map<id,Opportunity> oppMap=new Map<id,Opportunity>([select id,accountId from Opportunity where accountId=:accIdDelList]);
            //System.debug('--12--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            
            List<Task> oppTasks=[SELECT Id,AccountId,Type,WhatId,WhoId,Business_Account__c FROM Task where What.type='Opportunity' and RecordTypeId=:taskDefaultRecTypeId and  whatId=:oppMap.keySet() order by createddate desc];
            //System.debug('--13--Limits.getQueryRows()====>:'+Limits.getQueryRows()  +'     --Limits.getLimitQueryRows()====>:'+Limits.getLimitQueryRows());
            for(Task t:oppTasks){
                t.Business_Account__c=null;
            }
            allOppTasksSet.addAll(oppTasks);
        }
        
        
        /**************************************************************************************************************************/
        //system.debug('leadTasks.isEmpty()==============>:'+leadTasks.isEmpty());
        /*
for(Task t: allAccTasksSet)    {
System.debug('Account t=============>:'+t.id);
}
for(Task t: allLeadTasksSet)    {
System.debug('Lead  t=============>:'+t.id);
}
for(Task t: allContTasksSet)    {
System.debug('Contact t=============>:'+t.id);
}
for(Task t: allOppTasksSet)    {
System.debug('Opportunity t=============>:'+t.id);
}
*/
        
        if(!allAccTasksSet.isEmpty())
        {
            //allTasksSet.addAll(allAccTasksSet);
            update new List<Task>(allAccTasksSet);
        }
        if(!allLeadTasksSet.isEmpty())
        {
            //allTasksSet.addAll(allLeadTasksSet);
            update new List<Task>(allLeadTasksSet);
        }
        if(!allContTasksSet.isEmpty())
        {
            //allTasksSet.addAll(allContTasksSet);
            update new List<Task>(allContTasksSet);
        }
        if(!allOppTasksSet.isEmpty())
        {
            //allTasksSet.addAll(allOppTasksSet);
            update new List<Task>(allOppTasksSet);
        }
        
        if(!allTasksSet.isEmpty())
        {
            //update new List<Task>(allTasksSet);
        }
    }
}