public class PrivacyAuditLogController {

    static public void addLogs(List<Privacy_Request__c> requests){
		List<Privacy_Audit_Log__c> logsToInsert = new List<Privacy_Audit_Log__c>();

        for (Privacy_Request__c request : requests){
            Privacy_Audit_Log__c log = new Privacy_Audit_Log__c();
            log.PR_Name__c = request.Id;
            log.Name__c = request.Name__c;
            log.Email__c = request.Email__c;
            log.Request_Date__c	= request.Request_Date__c;
            log.Fulfillment_Date__c	= request.Fulfillment_Date__c;
            log.State_Province__c = request.State_Province__c;
            log.Country__c = request.Country__c;
            log.Request_Status__c = request.Request_Status__c;
            log.Fail_Decline_Reason__c = request.Fail_Decline_Reason__c;
            log.Request_Type__c	= request.Request_Type__c;
            log.Source_System__c = request.Source_System__c;
            log.Requestor_Name__c = request.Requestor_Name__c;
            log.Requestor_Email__c = request.Requestor_Email__c;
            log.Requestor_Relationship_to_Member__c = request.Requestor_Relationship_to_Member__c;
			// Update 2020-01-14: Add Phase 2 fields
            log.CSR_Name__c = request.CSR_Name__c;
			log.CSR_Email__c = request.CSR_Email__c;
            log.Fulfillment_Date_Rationale__c = request.Fulfillment_Date_Rationale__c;
            log.Universal_Member_Id__c=request.Universal_Member_Id__c;
            logsToInsert.add(log);
        }
        insert logsToInsert;
        
    }

    static public void updateLogs(List<Privacy_Request__c> requests, List<Privacy_Request__c> oldRequests, Map<id,Privacy_Request__c> newMap,Map<id,Privacy_Request__c> oldMap){
		List<Privacy_Audit_Log__c> logsToUpdate = new List<Privacy_Audit_Log__c>();

        for (Privacy_Request__c request : requests){
            Privacy_Audit_Log__c log = new Privacy_Audit_Log__c();
            log.PR_Name__c = request.id;
            if (request.Name__c != oldMap.get(request.id).Name__c) log.Name__c = request.Name__c;
            if (request.Email__c != oldMap.get(request.id).Email__c) log.Email__c = request.Email__c;
            if (request.Request_Date__c != oldMap.get(request.id).Request_Date__c) log.Request_Date__c = request.Request_Date__c;
            if (request.Request_Status__c != oldMap.get(request.id).Request_Status__c) log.Request_Status__c = request.Request_Status__c;
            if (request.Fulfillment_Date__c != oldMap.get(request.id).Fulfillment_Date__c) log.Fulfillment_Date__c = request.Fulfillment_Date__c;
            if (request.State_Province__c != oldMap.get(request.id).State_Province__c) log.State_Province__c = request.State_Province__c;
            if (request.Country__c != oldMap.get(request.id).Country__c) log.Country__c = request.Country__c;
            if (request.Fail_Decline_Reason__c != oldMap.get(request.id).Fail_Decline_Reason__c) log.Fail_Decline_Reason__c = request.Fail_Decline_Reason__c;
            if (request.Request_Type__c != oldMap.get(request.id).Request_Type__c) log.Request_Type__c = request.Request_Type__c;
            if (request.Source_System__c != oldMap.get(request.id).Source_System__c) log.Source_System__c = request.Source_System__c;
            if (request.Requestor_Name__c != oldMap.get(request.id).Requestor_Name__c) log.Requestor_Name__c = request.Requestor_Name__c;
            if (request.Requestor_Email__c != oldMap.get(request.id).Requestor_Email__c) log.Requestor_Email__c = request.Requestor_Email__c;
            if (request.Requestor_Relationship_to_Member__c != oldMap.get(request.id).Requestor_Relationship_to_Member__c) log.Requestor_Relationship_to_Member__c = request.Requestor_Relationship_to_Member__c;
			// Update 2020-01-14: Add Phase 2 fields
            if (request.CSR_Name__c != oldMap.get(request.id).CSR_Name__c) log.CSR_Name__c = request.CSR_Name__c;
            if (request.CSR_Email__c != oldMap.get(request.id).CSR_Email__c) log.CSR_Email__c = request.CSR_Email__c;
            if (request.Fulfillment_Date_Rationale__c != oldMap.get(request.id).Fulfillment_Date_Rationale__c) log.Fulfillment_Date_Rationale__c = request.Fulfillment_Date_Rationale__c;
           // if (request.Universal_Member_Id__c != oldMap.get(request.id).Universal_Member_Id__c) log.Universal_Member_Id__c = request.Universal_Member_Id__c;
            if (request.Universal_Member_Id__c != '') log.Universal_Member_Id__c = request.Universal_Member_Id__c;
            logsToUpdate.add(log);
        }
        Database.upsert(logsToUpdate, Privacy_Audit_Log__c.Fields.PR_Name__c);
        
    }

    
 /*
  * This code handles asynchronous triggers
  * 
    static public void handleChangeEvent(List<Privacy_Request__ChangeEvent> requests){
		List<Privacy_Request__ChangeEvent> logsToInsert = new List<Privacy_Request__ChangeEvent>();
		List<Privacy_Request__ChangeEvent> logsToUpdate = new List<Privacy_Request__ChangeEvent>();

        for (Privacy_Request__ChangeEvent request : requests){
	        EventBus.ChangeEventHeader header = request.ChangeEventHeader;
            if (header.changetype == 'CREATE'){
                logsToInsert.add(request);
            } else if (header.changetype == 'UPDATE'){
                logsToUpdate.add(request);
            }
        }
		addLogs(logsToInsert);
        updateLogs(logsToUpdate);
        
    }

    static public void addLogs(List<Privacy_Request__ChangeEvent> requests){
		List<Privacy_Audit_Log__c> logsToInsert = new List<Privacy_Audit_Log__c>();

        for (Privacy_Request__ChangeEvent request : requests){
            EventBus.ChangeEventHeader header = request.ChangeEventHeader;


            Privacy_Audit_Log__c log = new Privacy_Audit_Log__c();
            log.PR_Name__c = header.recordids[0];
            log.Name__c = request.Name__c;
            log.Email__c = request.Email__c;
            log.Request_Date__c	= request.Request_Date__c;
            log.Fulfillment_Date__c	= request.Fulfillment_Date__c;
            log.Address__c = request.Address__c;
            log.Request_Status__c = request.Request_Status__c;
            log.Fail_Decline_Reason__c = request.Fail_Decline_Reason__c;
            log.Request_Type__c	= request.Request_Type__c;
            log.Source_System__c = request.Source_System__c;
            log.Requestor_Name__c = request.Requestor_Name__c;
            log.Requestor_Email__c = request.Requestor_Email__c;
            log.Requestor_Relationship_to_Member__c = request.Requestor_Relationship_to_Member__c;
			logsToInsert.add(log);
        }
        insert logsToInsert;
    }
    
    static public void updateLogs(List<Privacy_Request__ChangeEvent> requests){
		List<Privacy_Audit_Log__c> logsToUpdate = new List<Privacy_Audit_Log__c>();

        for (Privacy_Request__ChangeEvent request : requests){
            Privacy_Audit_Log__c log = new Privacy_Audit_Log__c();

            EventBus.ChangeEventHeader header = request.ChangeEventHeader;
            log.PR_Name__c = header.recordids[0];
            for (String field : header.changedfields){
                switch on field {
                    when 'Name__c' {log.Name__c = (String) request.get(field); }	
                    when 'Email__c' {log.Email__c = (String) request.get(field); }	
                    when 'Request_Date__c' {log.Request_Date__c = (DateTime) request.get(field); }	
                    when 'Request_Status__c' {log.Request_Status__c = (String) request.get(field); }	
                    when 'Fulfillment_Date__c' {log.Fulfillment_Date__c = (Date) request.get(field); }	
                    when 'Address__c' {log.Address__c = (String) request.get(field); }	
                    when 'Fail_Decline_Reason__c' {log.Fail_Decline_Reason__c = (String) request.get(field); }	
                    when 'Source_System__c' {log.Source_System__c = (String) request.get(field); }	
                    when 'Requestor_Name__c' {log.Requestor_Name__c = (String) request.get(field); }	
                    when 'Requestor_Email__c' {log.Requestor_Email__c = (String) request.get(field); }	
                    when 'Requestor_Relationship_to_Member__c' {log.Requestor_Relationship_to_Member__c = (String) request.get(field); }	
                }
                
            }
            logsToUpdate.add(log);
        }
        Database.upsert(logsToUpdate, Privacy_Audit_Log__c.Fields.PR_Name__c);
        
    }
*/

}