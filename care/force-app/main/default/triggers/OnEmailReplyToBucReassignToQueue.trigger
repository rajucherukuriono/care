trigger OnEmailReplyToBucReassignToQueue on Task (after insert,before insert,before update,after update) 
{
List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
if(Trigger.isAfter && Trigger.isInsert)
{
    // When a user replies to a BUC case and a Task is created via email-to-case, 
    // we reassign the case to the queue (by reopening it & invoking the assignment rules).
    // This use case is required because the BUC team has a LOT of part time agents
    // (if we allows the default behavior, the customer's response would not be replied to
    // until the part time agent came back to work)
  
    //commented by kiran
    //ID bucRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BUC').getRecordTypeId();
    //added by kiran

    Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType
                                            where name IN ('BUC', 'International BUC','International CAW','International CAW Agency','International Personal Network')]);
    //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType
                                          //where name IN ('BUC', 'International BUC')]);
    Map<String, Id> recNameIdMap = new Map<String, Id>();

    Set<Id> notSatisfiedTaskCaseIdSet=new Set<Id>();

    for(Id recId:recTypeIds.keySet()){
        recNameIdMap.put(recTypeIds.get(recId).Name,recTypeIds.get(recId).id);
    }
    //Set<Id> recordTypesToExclude = UCase.getCaseCreationFirstResMappings();
    //recTypeIds.keySet().removeAll(recordTypesToExclude); //remove RecordTypes which is handled by Breeze

    //System.debug('Record type ids'+recTypeIds.keySet());
    Map<Id,Task> notSatisfiedTaskMap=new Map<id,Task>([SELECT CallType,CreatedBy.Name,Description,Id,OwnerId,Priority,
            RecordTypeId,Status,Subject,TaskSubtype,Type,WhatId,WhoId FROM Task
            where (subject like '%Respond to Not Satisfied Feedback%' or subject like '%Response to Not Satisfied Feedback%')
            and createdById=:userList[1].id and id in:Trigger.newMap.keySet()]);
    system.debug('notSatisfiedTaskMap query==>:'+notSatisfiedTaskMap);

    // Get all the Cases related to the Tasks passed to the Trigger (via WhatId)
    Set<Id> WhatIdSet = new Set<Id>();
    for (Task t : trigger.new){
    /*
        if (t.type == 'eMail' && t.WhatId != null && Schema.Case.SObjectType == t.WhatId.getSobjectType() ){
            WhatIdSet.add(t.WhatId);
        }
      */
      if (t.WhatId != null && Schema.Case.SObjectType == t.WhatId.getSobjectType() ){
            //if(t.type == 'eMail' && t.owner.name=='Care.com Salesforce Admin')
            //if(t.type == 'eMail')
            if(t.type == 'eMail' && t.ownerId==userList[0].id){
                 WhatIdSet.add(t.WhatId);
            }

            if (notSatisfiedTaskMap.get(t.id)!=null){
                 notSatisfiedTaskCaseIdSet.add(String.valueOf(t.WhatId).length()==18?String.valueOf(t.WhatId).subString(0,15):String.valueOf(t.WhatId));
            }
        }
    }

    System.debug('WhatIdSet==================>:'+WhatIdSet);
    // Ensure we have Cases to work with
    if (!WhatIdSet.isEmpty()){
        Set<Case> CasesToUpdateSet = new Set<Case>();

        // Set DML Options to invoke assignment rules
        AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        // Query for cases identified before (in the WhatIdSet) and BUC Record Type and which are closed (only closed cases can be reopened)
        for (Case c : [SELECT id,ownerId, RecordTypeId FROM Case WHERE id = :WhatIdSet AND RecordTypeId IN :recTypeIds.keySet() AND (status ='On Hold' or isClosed = true)]){
        //for (Case c : [SELECT id,ownerId FROM Case WHERE id = :WhatIdSet AND RecordTypeId IN :recordTypesToExclude AND isClosed = true]){
            // Owner is not being set here; the update will invoke assignment rules & 
            // they will be responsible for setting the new case owner.
            // This will allow admins to control which queue BUC cases get assigned to without having to update the apex code

            //if(recordTypesToExclude.contains(c.RecordTypeId)) // These recordtypes will be handled by Breeze rules
                //continue;

            String caseId=String.valueOf(c.id).length()==18?String.valueOf(c.id).subString(0,15):String.valueOf(c.id);

            if(!notSatisfiedTaskCaseIdSet.contains(caseId))
                        {
                c.Status = 'Reopened';
                c.setOptions(dmlOpts);
                CasesToUpdateSet.add(c);
            }
        }
        System.debug('VM CasesToUpdateSet '+CasesToUpdateSet);
        if(AvoidRecursion.runOnceCase3())
        {
        update new List<Case>(CasesToUpdateSet);
        }
    }
    }
    /*
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
    new CopyActivityTypeToActivityTypeBucket().CopyActivityTypeToActivityTypeBucket(Trigger.new);
    }
    */
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            if(AvoidRecursion.runOnce())
            {

                List<Task> taskList=[select id,type,CreatedById,CreatedBy.Name,activity_type_bucket__c from Task where id =:Trigger.newMap.keySet()];
                List<Task> tasksToUpdate=new List<Task>();
                for (Task t : taskList)
                {
                    if(t.createdBy.Name=='ClearSlide API' && t.type!='Remote Meeting (Scheduled)')
                    {
                        t.type='Remote Meeting (Scheduled)';
                        tasksToUpdate.add(t);
                    }
                }
                if(!taskList.isEmpty())
                update tasksToUpdate;
            }
        }
}