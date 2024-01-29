/*
 In the After insert and Before update if the lead record types are WPS Lead or International B2B and Lead Status is Future Opportunity.
 This trigger is creating a task. 
 IF the Lead recort types are WPS Lead or International B2B Lead status is not Future Opportunity. Setting null values to Lead fields 
 'Subject', 'Due Date' and 'Comments to Task'.
 */

 trigger CreateTaskUponFutureOpp on Lead (after insert,before update) {
    boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
    if(!bypassLeadTriggers)
    { 
        ID taskDefaultRecId= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        ID leadWpsRecId= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WPS Lead').getRecordTypeId();
        ID leadB2BRecId= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('International B2B').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        for(Lead leadObj:Trigger.new)
        {
            if((LeadObj.recordTypeId==leadWpsRecId || LeadObj.recordTypeId==leadB2BRecId ) && leadObj.status=='Future Opportunity'&&  
               ((trigger.isAfter && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate && trigger.OldMap.get(leadObj.id).status!='Future Opportunity')))
                //if(leadObj.recordTypeId==leadWpsRecId && leadObj.status=='Future Opportunity')
            {
                Task t= new Task();
                t.whoId=leadObj.id;
                t.recordTypeId=taskDefaultRecId;
                //t.subject='Future Opportunity is awaiting for action';
                t.ownerId=UserInfo.getUserId();
                t.Description = leadobj.Comments_To_Task__c;
                t.Subject = leadobj.Subject__c;
                t.ActivityDate = leadobj.Due_Date__c;
                taskList.add(t);
            }
            if((leadObj.recordTypeId==leadWpsRecId || LeadObj.recordTypeId==leadB2BRecId ) && leadObj.status!='Future Opportunity')
            {
                if(Trigger.isBefore && Trigger.isUpdate)
                {
                    leadobj.Subject__c = null;
                    leadobj.Due_Date__c = null;
                    leadobj.Comments_To_Task__c = null;
                }
            }
        }
        if(Trigger.isAfter && Trigger.isInsert)
        {
            List<Lead> afterInsertLeadList=[select id,status,Subject__c,Due_Date__c,Comments_To_Task__c,recordTypeId from Lead where id=:Trigger.new LIMIT 50000];
            for(Lead leadObj:afterInsertLeadList)
            {
                if((leadObj.recordTypeId==leadWpsRecId || LeadObj.recordTypeId==leadB2BRecId ) && leadObj.status!='Future Opportunity')
                {
                    leadobj.Subject__c = null;
                    leadobj.Due_Date__c = null;
                    leadobj.Comments_To_Task__c = null;
                }
            }
            if(!afterInsertLeadList.isEmpty())
            {
                update afterInsertLeadList;
            }
        }
        
        
        if(!taskList.isEmpty())
            insert taskList;
        
    }
}