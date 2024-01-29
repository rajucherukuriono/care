global class OnDemandSync_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{

    global final String query;
    global final String Platform;
	global String[] AccountsWaitingForSync = new List<String>();

    global OnDemandSync_Batch(String ODSPlatform){
		Platform = ODSPlatform;
        
        // changes to this field list need to be replicated in the query in OnDemandSync.HandleSucces & OnDemandSync.InvokeODSTimeoutError method
        query = 'SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,ContactId,SuppliedEmail,ODS_Number_of_Retries__c,Is_ODS_Max_Retries_Reached__c,Is_ODS_Complete__c,ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin,ODS_Request_Error__c,Orig_Web_Member_Id__c,Member_Locale__c,Web_External_Member_Id__c,Web_Member_UUID__c FROM Case WHERE ODS_Request_Status__c = \'' + OnDemandSync.REQ_STATUS_INPROGRESS + '\' AND ODS_Request_Platform__c = \'' + Platform + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        // select records to by synced
        Case[] Cases = new List<Case>();
        try {
            // Lock records for update (so that only one version of the process can make this update)
            // limit to 10k to not exceed DML limits; but logic in finish method should daisy chain until no queued cases remain;
            Cases = [SELECT id FROM Case WHERE ODS_Request_Status__c = :OnDemandSync.REQ_STATUS_QUEUED AND ODS_Request_Platform__c = :Platform LIMIT 10000 FOR UPDATE]; 
            OnDemandSync.SetCasesToInProgress(Cases);
        } catch (System.Exception e){ 
            // If we can't lock these records, then another version of this process is working on them, we don't need to do anything else
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, Case[] Cases){
        OnDemandSync.HTTPRequest(Cases,Platform,this);
    }

    global void finish(Database.BatchableContext BC){
		// Reset platform on Custom Setting for OnDemandSync_Batch
		OnDemandSync_Settings.setNextPlatform(OnDemandSync.HTTP_REQUEST_BATCH_CLASS_NAME,null);

        // Invoke Account/Case batch job
        // Usually the link batch is invoked via the Account trigger, but there have been edge cases where the Accounts got inserted before
        // HandleSuccess finished, which ended up leaving Cases In Progress indefinitely.  
        // A Negative drawback to this approach is that we could end up running the Link Batch when there are no records to link, 
        // but that's safer than leaving records hanging indefinitely.
        if (!AccountsWaitingForSync.isEmpty()){
            OnDemandSync.InvokeLinkBatch(Platform);
        } else {
        // Check to see if any queued cases remain
        // But only do so if we didn't invoke the Link Batch.  I'm adding this caveat
        // because I've seen edge cases than can occur when the batches take a long time to run
        // that may be caused by invoking botch batches in the same transaction
            OnDemandSync.ScheduleHTTPBatchIfQueuedCasesRemain(Platform);
        }

    }
    
    
}