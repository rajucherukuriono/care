global class OnDemandSync_LinkAccountToCase_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global final String query;
    global final String Platform;

    global OnDemandSync_LinkAccountToCase_Batch(String ODSPlatform){
        Platform = ODSPlatform;

        // changes to this field list need to be replicated in the query in OnDemandSync.HandleSucces & OnDemandSync.InvokeODSTimeoutError method
        query = 'SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,ContactId,SuppliedEmail,ODS_Number_of_Retries__c,Is_ODS_Max_Retries_Reached__c,Is_ODS_Complete__c,ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin,ODS_Request_Error__c,Orig_Web_Member_Id__c,Member_Locale__c,Web_External_Member_Id__c,Web_Member_UUID__c From Case WHERE Web_Member_Id__c != NULL AND (Is_ODS_Complete__c = false OR ODS_Request_Error__c = \'' + OnDemandSync.REQ_ERROR_ODS_TIMEOUT + '\') AND (IsClosed = false OR Origin = \'' + OnDemandSync.ORIGIN_CHAT + '\')'; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
    }    

    global void execute(Database.BatchableContext BC, Case[] Cases){
    	OnDemandSync.LinkAccountToCase(Cases,Platform);
    }

    global void finish(Database.BatchableContext BC){
		// Reset platform on Custom Setting for OnDemandSync_Batch
		OnDemandSync_Settings.setNextPlatform(OnDemandSync.LINK_BATCH_CLASS_NAME,null);
        
        // This method is invoked here to kick off alternate platform search after Account is linked to Case
        OnDemandSync.ScheduleHTTPBatchIfQueuedCasesRemain(Platform);
    }
}