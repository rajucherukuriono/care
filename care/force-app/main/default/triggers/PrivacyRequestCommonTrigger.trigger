//modified: 16/01/2023
trigger PrivacyRequestCommonTrigger on Privacy_Request__c (before insert, before update, after insert, after update,before delete) {
    List<Process_Control_Settings__mdt>  pcsList= new List<Process_Control_Settings__mdt>([SELECT Additional_Information__c,Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,Switch__c FROM Process_Control_Settings__mdt where Process_Name__c in ('CCPA Deletion','CCPA Access Data')]);
    Map<String,String> pcsListMap=new Map<String,String>();
    for(Process_Control_Settings__mdt pcsStr:pcsList)
    {
        pcsListMap.put(pcsStr.Process_Name__c,pcsStr.Switch__c);
    }
    String ccpaDelProcessSwitch=pcsListMap.get('CCPA Deletion');
    String ccpaAccessDataProcessSwitch=pcsListMap.get('CCPA Access Data');
    boolean bypassPrivacyRequestTriggers=Override_Validation_Rules__c.getInstance().Override_Privacy_Request_Triggers__c;
    if(!bypassPrivacyRequestTriggers)
    {   
        // This code handles before insert/updates to Privacy Request object
        if (Trigger.isBefore && Trigger.isInsert){
            PrivacyRequestController.handleInsert(Trigger.new);
        } else if (Trigger.isBefore && Trigger.isUpdate){
            PrivacyRequestController.handleUpdate(Trigger.new, Trigger.old, Trigger.NewMap, Trigger.OldMap);
        }
        // This code handles after insert/update events.  
        // The code is responsible for porpagating changes from Privacy_Request__c records to Privacy_Audit_Log__c records.
        if (Trigger.isAfter && Trigger.isInsert){
            PrivacyAuditLogController.addLogs(Trigger.new);
        } else if (Trigger.isAfter && Trigger.isUpdate){
            PrivacyAuditLogController.updateLogs(Trigger.new, Trigger.old, Trigger.NewMap, Trigger.OldMap);
        }
        if(((Trigger.isAfter && Trigger.isInsert) ||(Trigger.isAfter && Trigger.isUpdate)) && ccpaDelProcessSwitch=='On')
        {
            if(AvoidRecursion.runOnceCCPADeletion1()) 
            {
                System.debug('1 =====> Inside PR trigger');
                Map<id,Privacy_Request__c> prRAMap=new Map<id,Privacy_Request__c>();
                Map<id,Privacy_Request__c> prQSPMap=new Map<id,Privacy_Request__c>();
                for(Privacy_Request__c prObj:Trigger.new)
                {
                    if(prObj.Request_Status__c=='Request Accepted'
                       && prObj.Source_System__c=='US Platform' 
                       && prObj.Request_Type__c=='Delete Data')
                    {
                        prRAMap.put(prObj.id,prObj);
                        System.debug('2 =====> Inside Requested Accepted criteria in PR trigger');
                    }
                    else if(prObj.Request_Status__c == 'Queued - Salesforce Platform'
                            && prObj.Source_System__c=='US Platform' 
                            && prObj.Request_Type__c=='Delete Data')
                    {
                        prQSPMap.put(prObj.id,prObj);
                        System.debug('2 =====> Inside Queued - Salesforce Platform criteria in PR trigger');
                    }
                }
                if(!prQSPMap.isEmpty())
                {
                    ProcessCCPADeletionInstantRequest updateProcessCCPADeletionInstantRequestObj=new ProcessCCPADeletionInstantRequest(prQSPMap.values(),Trigger.old,prQSPMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isBefore,Trigger.isAfter);
                    updateProcessCCPADeletionInstantRequestObj.ProcessCCPADeletionInstantRequest();
                }
                if(!prRAMap.isEmpty())
                {
                       Datetime workTime = System.now().addMinutes(15);
                	   String nextFireTime = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()  + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
                       ProcessCCPADeletionInstantRequest updateProcessCCPADeletionInstantRequestObj=new ProcessCCPADeletionInstantRequest(prRAMap.values(),Trigger.old,prRAMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isBefore,Trigger.isAfter);  //uncomment : ashfaq
                       String cronID = System.schedule('BatchProcessCCPADeletionRequestPRData'+prRAMap.values()[0].name+system.now(), nextFireTime,updateProcessCCPADeletionInstantRequestObj);
                      // String cronID = System.schedule('BatchProcessCCPADeletionRequestPRData', a,updateProcessCCPADeletionInstantRequestObj);  //uncomment : ashfaq
                    
                }
            }
        }
        if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isDelete) && ccpaAccessDataProcessSwitch=='On')
        {
            CCPAAccessDataDeleteFiles CCPAAccessDataDeleteFilesObj=new CCPAAccessDataDeleteFiles(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isBefore,Trigger.isAfter);
            CCPAAccessDataDeleteFilesObj.ProcessCCPAAccessDataDeleteFilesInstantRequest();
        }
    }
}