public class OnDemandSync{
    public static boolean UseHTTPCompression = true;
	public static Map<Id,List<String>> AlternateMatches = new Map<Id,List<String>>(); // indexed by Case id; holds list of member ids
	public static final String PLATFORM_US = 'US';
    public static final String PLATFORM_INTL = 'International';
    public static final String REQ_STATUS_ERROR_PREFIX = 'Error';
    public static final String REQ_STATUS_COMPLETE_PREFIX = 'Complete';
    public static final String REQ_STATUS_QUEUED = 'Queued';
    public static final String REQ_STATUS_INPROGRESS = 'In Progress';
    public static final String REQ_STATUS_ODSBYPASS = 'Complete - ODS Bypass';
    public static final String REQ_STATUS_PREODSMATCH = 'Complete - Pre ODS Match';
    public static final String REQ_STATUS_MATCHNOUPDATE = 'Complete - Match/No Update';
    public static final String REQ_STATUS_COMPLETEMATCH = 'Complete - Match';
    public static final String REQ_STATUS_MATCHMULTIPLEACCOUNTS = 'Complete - Match/Multiple Accounts';
    public static final String REQ_STATUS_COMPLETENOMATCH = 'Complete - No Match';
    public static final String REQ_STATUS_ERROR_UNKNOWN = 'Error - Unknown';
    public static final String REQ_STATUS_ERROR_SALESFORCE = 'Error - Salesforce';
    public static final String REQ_STATUS_ERROR_USPLATFORM = 'Error - US Platform';
    public static final String REQ_STATUS_ERROR_INTLPLATFORM = 'Error - International Platform';
    public static final String REQ_ERROR_ODS_TIMEOUT = 'ODS Timeout';
    public static final String HTTP_REQUEST_BATCH_CLASS_NAME = 'OnDemandSync_Batch';
    public static final String HTTP_REQUEST_BATCH_CRON_JOB_ROOT = 'OnDemandSync - ';
    public static final String LINK_BATCH_CLASS_NAME = 'OnDemandSync_LinkAccountToCase_Batch';
    public static final String LINK_BATCH_CRON_JOB_ROOT = 'OnDemandSync_LinkAccountToCase - ';
    public static final String ORIGIN_CHAT = 'Chat';
    public static final String PROFILE_API_READ_ALL = '00e390000010DKoAAM';
    
    public static void HandleNewSyncCandidates(Case[] Cases){
    /*
        Determine if Case is candidate for OnDemandSync
        Update Case Request Status to Queued
        Call HTTP Request method  
		Invoke Error Monitor
    */
		Boolean HasUSCase = false;
        Boolean HasInternationalCase = false;

        Case[] CasesRW = new List<Case>();
        for (Case c: Cases){
			String ODSRequestPlatform = c.ODS_Request_Platform__c;
            // HACK: Jack Odell - 2018-09-25: Web-to-Case does not respect default record type values, so we're setting ODS_Request_Platform manually here.
			// If we ever stop using Web-to-Case, this logic can be retired.
            if (c.Origin == 'Web' && c.RecordTypeId == getRecordTypesStatic.StandardRecordType && c.SuppliedEmail != null && ODSRequestPlatform == null) {
                ODSRequestPlatform = PLATFORM_US;
            }

            if (c.SuppliedEmail != null && ODSRequestPlatform != null){  // Entry criteria for ODS logic is Supplied Email & ODS Request Platform 

                HasInternationalCase = (CareDotComUtil.isInternationalCase(c) && HasInternationalCase == false) ? true : HasInternationalCase;
                HasUSCase = (!CareDotComUtil.isInternationalCase(c) && HasUSCase == false) ? true : HasUSCase;
                
                Case cRW = new Case(id = c.id, ODS_Request_Platform__c = ODSRequestPlatform); // create writable Case for update
                if (OnDemandSync_Settings.getBypassODS(ODSRequestPlatform)){
                    cRW.ODS_Request_Status__c = REQ_STATUS_ODSBYPASS;
                } else if (c.AccountId != null){
                    HandlePreODSMatch(c,cRW);
            	} else {
                // If SuppliedEmail is provided & Account Id is null, then Case is candidate
                    cRW.ODS_Request_Status__c = REQ_STATUS_QUEUED;
                }
                CasesRW.add(cRW);
            }
        }

        if (!CasesRW.isEmpty()){ // we only need to invoke init, update, batch & error monitor if there are ODS candidate cases
            InitializeCases(CasesRW); // Sets initial values for all ODS Cases            
            UpdateHelper(CasesRW); // Updates cases
    
            /* Cases have already been updated; so actions below this cannot update cases */
            if (HasUSCase == true){
                InvokeHTTPRequestBatch(PLATFORM_US);
            	OnDemandSync_ErrorMonitor.InvokeErrorMonitor(PLATFORM_US);    
            } 
            
            if (HasInternationalCase == true) {
                InvokeHTTPRequestBatch(PLATFORM_INTL);  
                OnDemandSync_ErrorMonitor.InvokeErrorMonitor(PLATFORM_INTL);    
            } 
        }
    }

    public static void HandlePreODSMatch(Case c, Case cRW){
		// Pre ODS Match is fine if platforms match, otherwise:
		// 		Break relationship between Case & Account 
		// 		& allow ODS to take it's course  (by setting ODS Request Status to Queued)
        if (DoCaseAndAccountPlatformsMatch(c)){
            cRW.ODS_Request_Status__c = REQ_STATUS_PREODSMATCH;
        } else {
            cRW.AccountId = null;
            cRW.ContactId = null;
            cRW.ODS_Request_Status__c = REQ_STATUS_QUEUED;
        }
    }
    
    public static Boolean DoCaseAndAccountPlatformsMatch(Case c){
        // Use IsMemberIdInternational instead?
        
        
        if (CareDotComUtil.isInternationalCase(c)){ // is International Case
            if (c.Universal_Member_Id_Formula__c != null && c.Universal_Member_Id_Formula__c.isNumeric() == false){ // because International Member Ids contain country codes
                return true;    
            }
        } 
        else if (!CareDotComUtil.isInternationalCase(c)){ // Is US Case
            if (c.Universal_Member_Id_Formula__c != null && c.Universal_Member_Id_Formula__c.isNumeric() == true){ // because US Member Ids are numeric
                return true;    
            }
        }
        return false;
    }
        
    public static void InitializeCases(Case[] Cases){
		// Purpose: this method is used to initialize ODS values
        for (Case c : Cases){
            c.ODS_Start_Time__c = datetime.now();
            c.ODS_Number_of_Retries__c = 0; // web-to-case ignores default values
        }
    }

    public static void UpdateHelper(Case[] Cases){
    /*
        Purpose: Always use this class to handle DML updates (since it manages Is_ODS_Complete__c & ODS_End_Time__c)
	*/

        // check to see if Cases are complete
        handleIsCompleteLogic(Cases);	

        // update Cases
        List<Database.SaveResult> SaveResults = Database.update(Cases, false);
		if (CareDotComUtil.runningInASandbox()) System.debug('SaveResults.size(): ' + SaveResults.size());
        // Successful cases are handed off to HandlePostComplete; while DML Errors are flagged & handled
        if (!SaveResults.isEmpty()){
			List<Case> SucCases = new List<Case>();
            List<Case> ErrCases = new List<Case>();
			Map<ID,Database.Error[]> DMLErrorMap = new Map<ID,Database.Error[]>();
            for (Integer i = 0; i < SaveResults.size(); i++){
                Case c = Cases.get(i);				
				if (CareDotComUtil.runningInASandbox()) System.debug('c: ' + c);
                if (c != null){
                    if (SaveResults[i].isSuccess()){
                        if (CareDotComUtil.runningInASandbox()) System.debug('Update Succesful');
                        SucCases.add(c);
                    } 
                    else {
                        if (CareDotComUtil.runningInASandbox()) System.debug('Update failed');
                        if (CareDotComUtil.runningInASandbox()) System.debug('sr.getErrors(): ' + SaveResults[i].getErrors());
                        ErrCases.add(c);
                        DMLErrorMap.put(c.id,SaveResults[i].getErrors());
                    }
                }
            }
            if (!SucCases.isEmpty()) HandlePostComplete(SucCases);
            if (!ErrCases.isEmpty()) HandleDMLError(ErrCases,DMLErrorMap); // DML Errors require special handling. See HandleDMLError class for more details
        }
    }
        
    public static void handleIsCompleteLogic(List<Case> Cases){
    /*
            New Is Complete logic
            If Error & Is_ODS_Max_Retries_Reached__c, then allow HandleIsComplete (we won't try another platform if there is a final error)
            If begins with Complete & Alt ODS Request Status is not null, then HandleIsComplete (both platforms have now  finished)
            If Complete - Match/No Update & Alt ODS Request Status is null, then HandleIsComplete (because Case is owned by user & ODS should stop)
			If Complete - ODS Bypass & Alt ODS Request Status is null, then HandleIsComplete (because bypass is on for current platform & ODS should not send request to other platform)

			If begins with Complete & Alt ODS Request Status is null (in other words, all remaining complete statuses), then kick off alt platform search
			Unless alt platform has ODS bypass

			Bypass logic:
				if original platform has bypass on, don't send request to other platform.
				If original platform has finished and other platform has bypass on, don't send request to other platform.

*/
        for (Case c : Cases){
            // handle is complete use cases
            if (c.ODS_Request_Status__c != null && (
                (c.ODS_Request_Status__c.left(5) == REQ_STATUS_ERROR_PREFIX && c.Is_ODS_Max_Retries_Reached__c == true) // no alt platform search on error
                || (c.ODS_Request_Status__c.left(8) == REQ_STATUS_COMPLETE_PREFIX && c.Alt_ODS_Request_Status__c != null) // both platforms have finished
                || (c.ODS_Request_Status__c == REQ_STATUS_MATCHNOUPDATE && c.Alt_ODS_Request_Status__c == null) // no alt platform search on Match/No Update
                || (c.ODS_Request_Status__c == REQ_STATUS_ODSBYPASS && c.Alt_ODS_Request_Status__c == null) // no alt platform search on Bypass
            )){
                HandleIsComplete(c);
            } else if (c.ODS_Request_Status__c.left(8) == REQ_STATUS_COMPLETE_PREFIX && c.Alt_ODS_Request_Status__c == null){// we've got a complete on first platform; kick off alt platform search                   
                // Test framework can't handle alt platform search because it requires multiple batches to be processed
                String AltPlatform = (c.ODS_Request_Platform__c == PLATFORM_US) ? PLATFORM_INTL : PLATFORM_US;
				if (Test.isRunningTest() || OnDemandSync_Settings.getBypassODS(AltPlatform)) HandleIsComplete(c);
                else HandleAltPlatformSearch(c);
            }
        }
    }
    
    public static void HandleIsComplete(Case c){
        // it's possible for handleiscomplete to be called twice when an Account is created manually via CSR; 
        // this check prevents the values from being overwritten in that scenario
        if (c.Is_ODS_Complete__c != true){ // handle null or false
	        c.Is_ODS_Complete__c = true;
            c.ODS_End_Time__c = Datetime.now(); 
            
            // handle final ODS Request Status (compare new & old)
            c.ODS_Request_Status__c = GetFinalODSRequestStatus(c);
            
            // Revert Logic: logic that gets invoked after both platforms have completed if original platform was selected
            // Revert to original ODS Platform & Web Member Id
            if (c.ODS_Request_Status__c != null && 
                // If both platforms have the same status
                (c.ODS_Request_Status__c == c.Alt_ODS_Request_Status__c || 
                 	// Or If we ended up with multiple matches which effectively means both platforms have matched (see GetFinalODSRequestStatus)
                 	(c.ODS_Request_Status__c == REQ_STATUS_MATCHMULTIPLEACCOUNTS && c.Alt_ODS_Request_Status__c != null))
               ){ 
                   c.ODS_Request_Platform__c = (c.ODS_Request_Platform__c == PLATFORM_US) ? PLATFORM_INTL : PLATFORM_US;
                   c.Web_Member_Id__c = c.Orig_Web_Member_Id__c;
                   
                   // if second platform generated an ODS Timeout, we're going to ignore it & return the first platform.
                   // Allow self-healing for an ODS Timeout on the second platform is complex & would need to be handled
                   // explicltly.  Until that time, I am going to null out the field here to prevent
                   // the Case from being return to the Link Batch past this point.
                   if (c.ODS_Request_Error__c == REQ_ERROR_ODS_TIMEOUT) c.ODS_Request_Error__c = null;
            }
        }
    }
    
    public static String GetFinalODSRequestStatus(Case c){
        if (c.Alt_ODS_Request_Status__c == null) return c.ODS_Request_Status__c;
        if (c.Alt_ODS_Request_Status__c == REQ_STATUS_COMPLETEMATCH || c.Alt_ODS_Request_Status__c == REQ_STATUS_PREODSMATCH){
            if (c.ODS_Request_Status__c == REQ_STATUS_COMPLETEMATCH) return REQ_STATUS_MATCHMULTIPLEACCOUNTS; // both platforms matched
            else if (c.ODS_Request_Status__c == REQ_STATUS_COMPLETENOMATCH || c.ODS_Request_Status__c == REQ_STATUS_ODSBYPASS || c.ODS_Request_Status__c.left(5) == REQ_STATUS_ERROR_PREFIX){
                return c.Alt_ODS_Request_Status__c; // because alt platform should take precedence
            }
        } else if (c.Alt_ODS_Request_Status__c == REQ_STATUS_MATCHNOUPDATE){
            return c.Alt_ODS_Request_Status__c; // because alt platform should take precedence
        } else if (c.Alt_ODS_Request_Status__c == REQ_STATUS_COMPLETENOMATCH || c.Alt_ODS_Request_Status__c == REQ_STATUS_ODSBYPASS || c.Alt_ODS_Request_Status__c.left(5) == REQ_STATUS_ERROR_PREFIX){
            if (c.ODS_Request_Status__c.left(5) == REQ_STATUS_ERROR_PREFIX) return c.Alt_ODS_Request_Status__c; // because if both platforms return non matches, then original platform's response may make more sense to the rep
            else return c.ODS_Request_Status__c; // because current platform should take precendence
        }
        return c.Alt_ODS_Request_Status__c; // as a default, restore original status; but conditions above should always match
    }
    
    public static void HandleAltPlatformSearch(Case c){
		c.Alt_ODS_Request_Status__c = c.ODS_Request_Status__c;
        c.ODS_Request_Status__c = REQ_STATUS_QUEUED;
		c.Orig_Web_Member_Id__c = c.Web_Member_Id__c;
        c.Web_Member_Id__c = null;
        // External Member Id is only used on first request;  once we get a regular Web Member Id from response, we use Web Member from that point on.
        // So it is important to null out Web External Member id here (so it is not sent to alt platform); but we don't need to restore it later (like we do with Orig_Web_Member_Id__c)
        // The above is also true for Web Member UUID
        c.Web_External_Member_Id__c = null;
        c.Web_Member_UUID__c = null;
        c.Is_ODS_Complete__c = false;
        c.ODS_Request_Error__c = '';
        c.ODS_Number_of_Retries__c = 0;
        c.Is_ODS_Max_Retries_Reached__c = false;
        if (CareDotComUtil.runningInASandbox()) System.AssertNotEquals(null,c.ODS_Request_Platform__c,'ODS Request Platform should never be null');
        if (CareDotComUtil.runningInASandbox()) System.Debug('c.ODS_Request_Platform__c (before): ' + c.ODS_Request_Platform__c);
        c.ODS_Request_Platform__c = (c.ODS_Request_Platform__c == PLATFORM_US) ? PLATFORM_INTL : PLATFORM_US;
        if (CareDotComUtil.runningInASandbox()) System.Debug('c.ODS_Request_Platform__c (after): ' + c.ODS_Request_Platform__c);
    }

    public static void HandlePostComplete(Case[] Cases){
		// Function: a helper method that gets called after all cases have been sucessfully updated
        PostCompletedStatusToChatter(Cases);        
    }
    
    public static void PostCompletedStatusToChatter(Case[] Cases){
        List<FeedItem> FeedItems = new List<FeedItem>();
        for (Case c : Cases){
            if (c.Is_ODS_Complete__c){
                FeedItem fi = new FeedItem();
                fi.IsRichText = true;
                fi.Body = '<p>OnDemandSync is complete with status of <b>' + c.ODS_Request_Status__c + '</b>.</p>';
                if (AlternateMatches.containsKey(c.id)) fi.Body += '<p><b>Alternate Matches:</b> ' + String.join(AlternateMatches.get(c.id),' ,') + '</p>';
                fi.ParentId = c.id;
                fi.type = 'TextPost';
                FeedItems.add(fi);
            } else if (AlternateMatches.containsKey(c.id)) {
                FeedItem fi = new FeedItem();
                fi.IsRichText = true;
                fi.Body = '<b>Alternate Matches:</b> ' + String.join(AlternateMatches.get(c.id),',');
                fi.ParentId = c.id;
                fi.type = 'TextPost';
                FeedItems.add(fi);
            }
        }
        if (!FeedItems.isEmpty()) {
 			List<Database.SaveResult> SaveResults = Database.insert(FeedItems, false);
            // If Insert fails, I'm letting it go (as this is not super critical)
            if (CareDotComUtil.runningInASandbox()){
            	for (Integer i = 0; i < SaveResults.size(); i++){
                    System.debug('Feed Items insert failed');
                    System.debug('sr.getErrors(): ' + SaveResults[i].getErrors());
                }
            }
        }
    }

    public static void InvokeHTTPRequestBatch(String Platform){
        // Invoke Batch Request (as long as there isn't already a batch ongoing)
        // Note: when Batches end, they run themselves again if they find any queued cases.  See OnDemandSync_Batch.
        String CronJobName = HTTP_REQUEST_BATCH_CRON_JOB_ROOT + Platform;
        if (isItSafeToInvokeBatch(Platform,CronJobName,HTTP_REQUEST_BATCH_CLASS_NAME)){
            OnDemandSync_Batch ODSSync = new OnDemandSync_Batch(Platform);
            try {
                String cronID = System.scheduleBatch(ODSSync, CronJobName, (integer) OnDemandSync_Settings.getGapBetweenBatchesInMinutes(Platform), (integer) OnDemandSync_Settings.getODSBatchSize(Platform));    
                OnDemandSync_Settings.setNextPlatform(HTTP_REQUEST_BATCH_CLASS_NAME,Platform);
            } catch (System.Exception e){ // catch all exceptions
            	// Sometimes this error can be thrown if two triggers try to schedule the batch at the same time.
            	// We should error gracefully and let the other trigger schedule the batch.
            }
        }
    }

    public static void InvokeLinkBatch(String Platform){
        // Invoke LinkAccountToContact_Batch Request (as long as there isn't already a batch ongoing)
        String CronJobName = LINK_BATCH_CRON_JOB_ROOT + Platform;
        if (isItSafeToInvokeBatch(Platform,CronJobName,LINK_BATCH_CLASS_NAME)){
            OnDemandSync_LinkAccountToCase_Batch ODSLink = new OnDemandSync_LinkAccountToCase_Batch(Platform);
            try {
                String cronID = System.scheduleBatch(ODSLink, CronJobName, (integer) OnDemandSync_Settings.getGapBetweenBatchesInMinutesForLinkJob(Platform), (integer) OnDemandSync_Settings.getODSBatchSizeForLinkJob(Platform));    
                OnDemandSync_Settings.setNextPlatform(LINK_BATCH_CLASS_NAME,Platform);
            } catch (System.Exception e){ // catch all exceptions
            	// Sometimes this error can be thrown if two triggers try to schedule the batch at the same time.
            	// We should error gracefully and let the other trigger schedule the batch.
            }
        }
    }

    public static boolean isItSafeToInvokeBatch(String Platform,String CronJobName,String ApexClassName){
		// Only API Users with API Real All Profile or Guest Users are allowed to invoke batches.  So first check profile.
		// Then check if the current platform is slated to go next
        // Then check to see if there are any scheduled jobs in progress
		// If there aren't, then check to see if there are any batches in progress.
		// If not, then its safe to invoke batch
        
		if (!IsAppropriateUser()) return false;
        else if (!IsAppropriateNextPlatform(Platform,CronJobName,ApexClassName)) return false;
        else if (!FreeOfPendingScheduledJobs(Platform,CronJobName,ApexClassName)) return false;
        else if (!FreeOfApexBatches(Platform,CronJobName,ApexClassName)) return false;
        return true;
    }

    public static boolean IsAppropriateNextPlatform(String Platform,String CronJobName,String ApexClassName){
    	String NextPlatform = OnDemandSync_Settings.getNextPlatform(ApexClassName);
		// Null indicates no platform is waiting, so we should return true on null
        if (Platform != NextPlatform && NextPlatform != Null){
            return false;
        } 
        return true;            
    }
    
    public static boolean IsAppropriateUser(){
        if (!Test.isRunningTest() && !CareDotComUtil.runningInASandbox()){  // only test profile if not a test & in production
            if (Userinfo.getProfileId() == PROFILE_API_READ_ALL || Userinfo.getUserType() == 'Guest') return true;            
            return false;
        }
        return true;
    }

    public static boolean FreeOfPendingScheduledJobs(String Platform,String CronJobName,String ApexClassName){
        try{
            CronTrigger[] ScheduledJobs = [SELECT id,NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = :CronJobName AND (State='WAITING' OR State='ACQUIRED')];
            if (!ScheduledJobs.isEmpty()){
                Integer AbortedJobs = 0;
                for (CronTrigger ct : ScheduledJobs){
                    Long NextFireTime = ct.NextFireTime.getTime();
                    Long Now = DateTime.now().getTime();
                    Long GapInMinutes = ((Now - NextFireTime) / 1000 ) / 60;
                    if (GapInMinutes > 3){ // if scheduled job is overdue for more than 3 minutes, abort it
                        System.abortJob(ct.id);
                        AbortedJobs++;
                    } 
                }
                
                // If not all jobs were aborted; then we return false because there are some jobs scheduled
                if (AbortedJobs < ScheduledJobs.size()) return false; 
            }
        } catch (System.Exception e){
            return false;  // return false on error; known errors: row lock not allowed
        }
        return true;
    }

    public static boolean FreeOfApexBatches(String Platform,String CronJobName,String ApexClassName){
        try {
            // 2021-08-02 Jack Odell: was getting non-selective query errors against this query.  It's because we now
            // have a lot more AsynJobs.  So I added an ApexClassName filter to the query to make it more selective.
            // But this means we can no longer check the total job limit, so I'm going to comment out that check 
            // It's okay to comment out that error because if it happens it will be sporadic & self-healing.
            // Longer term we can try to figure a better solution, but it's not critical in the short term
            AsyncApexJob[] Jobs = [SELECT id,ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = :ApexClassName AND Status != 'Completed' AND Status != 'Aborted'  AND Status != 'Failed' AND CompletedDate = NULL]; // Batches in progress
            //if (Jobs.size() > 99) return false; // 100 batches max in our org // commented out, see comment at top of method
            for (AsyncApexJob Job : Jobs){
                if (Job.ApexClass.Name == ApexClassName) return false; // there's an ODSBatch in progress
            }
        } catch (System.Exception e){
            return false;  // return false on error; known errors: row lock not allowed
        }
        return true;
    }
    
    public static void HTTPRequest(Case[] Cases, String Platform, OnDemandSync_Batch ODS){
        if (Platform == PLATFORM_US) HTTPRequest(Cases,ODS);
        else if (Platform == PLATFORM_INTL) HTTPRequestInternational(Cases,ODS);
    }
    
    public static void HTTPRequest(Case[] Cases, OnDemandSync_Batch HTTPBatch){
        /*
            In ODS_Batch        
                Query Cases (based on Request Status of Queued)
                Set Case Request Status to In Progress.
                Update Cases
                Call HTPP Request method (this method)
            Send HTTP Request
            If success, Call Handle Success (pass Cases, Response)
            If error, call Handle Error (timeouts passed here too)
        */
        // Send HTTP Request
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
		
        SetupHTTPRequest(Cases, req, res);

		if (Limits.getCallouts() == Limits.getLimitCallouts()){
            HandleError('TOO_MANY_CALLOUTS',Cases,req,res,null,null);
            return;            
         }

        try {
            // Send request
            res = http.send(req);
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Code: ' + res.getStatusCode());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Massage: ' + res.getStatus());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Res: ' + res.getBody());
            
            if (res.getStatusCode() == 200){ // HTTP success code
                if (DoesResponseHaveError(res)){ // evaluate response for existence of error node
                    HandleError('EXTERNAL_PLATFORM_ERROR',Cases,req,res,null,null);
                } else {
                    Map<String, Object> responseMap = BuildResponseMap(res); // process & ensure response is proper JSON
                    if (responseMap == null){
                        HandleError('JSON_FORMAT_ERROR',Cases,req,res,null,null);
                    } else {
                    	HandleSuccess(Cases,res,responseMap,PLATFORM_US,HTTPBatch);    // Handle Success
                    }
                }
            } else {
                // handle HTTP errors (404, 500, etc)
                HandleError('EXTERNAL_PLATFORM_HTTP_ERROR',Cases,req,res,null,null);
            }
            
        } catch(System.CalloutException e) { // handle callout errors
            if (CareDotComUtil.runningInASandbox()) System.debug('Callout error: '+ e);
            HandleError('HTTP_EXCEPTION_ERROR',Cases,req,res,e,null);
        } catch (System.Exception e){ // catch all exceptions
            HandleError('UNKNOWN_ERROR',Cases,req,res,e,null);
        }
    }

    public static void SetupHTTPRequest(Case[] Cases, HttpRequest req, HttpResponse res){

        String URLRoot = ''; 
        String URLPath = '/platform/spi/salesforce/lookup'; 
        if (CareDotComUtil.runningInASandbox()){ // setup connection when connecting to stage environments
            req.setHeader('x-care.com-apikey', OnDemandSync_Settings.getStagingAPIKey(PLATFORM_US));
            URLRoot = 'callout:US_Platform_Stage';
        } else {
            req.setHeader('x-care.com-apikey', OnDemandSync_Settings.getProductionAPIKey(PLATFORM_US));
            URLRoot = 'callout:US_Platform_Production';
        }
        if (CareDotComUtil.runningInASandbox()) system.debug('URLRoot: ' + URLRoot);

        String RequestBody = BuildRequestBody(Cases);
        if (CareDotComUtil.runningInASandbox()) System.debug('RequestBody: ' + RequestBody);
        req.setEndpoint(URLRoot + URLPath);
        req.setBody(RequestBody);
        req.setHeader('cache-control', 'no-cache');
        req.setHeader('content-type', 'application/json');
        req.setMethod('POST');
        req.settimeout(30000); // 30 seconds
        req.setCompressed(UseHTTPCompression); 
    }


    public static void HTTPRequestInternational(Case[] Cases, OnDemandSync_Batch HTTPBatch){
        /*
            In ODS_Batch        
                Query Cases (based on Request Status of Queued)
                Set Case Request Status to In Progress.
                Update Cases
                Call HTPP Request method (this method)
            Send HTTP Request
            If success, Call Handle Success (pass Cases, Response)
            If error, call Handle Error (timeouts passed here too)
        */
        // Send HTTP Request
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 

        SetupHTTPRequestInternational(Cases, req, res);

        if (Limits.getCallouts() == Limits.getLimitCallouts()){
            HandleError('TOO_MANY_CALLOUTS',Cases,req,res,null,null);
            return;            
         }

        try {
            // Send request
            res = http.send(req);
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Code: ' + res.getStatusCode());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Massage: ' + res.getStatus());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Res: ' + res.getBody());
            
            if (res.getStatusCode() == 200){ // HTTP success code
                if (DoesResponseHaveError(res)){ // evaluate response for existence of error node
                    HandleError('EXTERNAL_PLATFORM_ERROR',Cases,req,res,null,null);
                } else {
                    Map<String, Object> responseMap = BuildResponseMapInternational(res); // process & ensure response is proper JSON
                    if (responseMap == null){
                        HandleError('JSON_FORMAT_ERROR',Cases,req,res,null,null);
                    } else {
                    	HandleSuccess(Cases,res,responseMap,PLATFORM_INTL,HTTPBatch);    // Handle Success
                    }
                }
            } else {
                // handle HTTP errors (404, 500, etc)
                HandleError('EXTERNAL_PLATFORM_HTTP_ERROR',Cases,req,res,null,null);
            }
            
        } catch(System.CalloutException e) { // handle callout errors
            if (CareDotComUtil.runningInASandbox()) System.debug('Callout error: '+ e);
            HandleError('HTTP_EXCEPTION_ERROR',Cases,req,res,e,null);
        } catch (System.Exception e){ // catch all exceptions
            HandleError('UNKNOWN_ERROR',Cases,req,res,e,null);
        }
    }

    public static void SetupHTTPRequestInternational(Case[] Cases, HttpRequest req, HttpResponse res){
        String URLRoot = ''; 
        String URLPath = ''; 
        if (CareDotComUtil.runningInASandbox()){ // setup connection when connecting to stage environments
            req.setHeader('accessToken', OnDemandSync_Settings.getStagingAPIKey(PLATFORM_INTL));
            URLRoot = 'callout:Sterling_ODS_Stage';
        } else {
            req.setHeader('accessToken', OnDemandSync_Settings.getProductionAPIKey(PLATFORM_INTL));
            URLRoot = 'callout:Sterling_ODS_Production';
        }
        if (CareDotComUtil.runningInASandbox()) system.debug('URLRoot: ' + URLRoot);
        
        String RequestBody = BuildRequestBody(Cases);
        if (CareDotComUtil.runningInASandbox()) System.debug('RequestBody: ' + RequestBody);
        req.setEndpoint(URLRoot + URLPath);
        req.setBody(RequestBody);
        req.setHeader('cache-control', 'no-cache');
        req.setHeader('content-type', 'application/json');
        req.setMethod('POST');
        req.settimeout(30000); // 30 seconds
        req.setCompressed(UseHTTPCompression); 

    }
    
    public static void SetCasesToInProgress(Case[] Cases){
        for (Case c : Cases){
            c.ODS_Request_Status__c = REQ_STATUS_INPROGRESS;
        }
        UpdateHelper(Cases);
    }

    public static void ScheduleHTTPBatchIfQueuedCasesRemain(String Platform){
		// Alt Platform should be prioritized
        String AltPlatform = (Platform == OnDemandSync.PLATFORM_US) ? OnDemandSync.PLATFORM_INTL : OnDemandSync.PLATFORM_US;
        String CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + AltPlatform;
		if (OnDemandSync.isItSafeToInvokeBatch(AltPlatform,CronJobName,OnDemandSync.HTTP_REQUEST_BATCH_CLASS_NAME)){
            // Are there any Cases still in Queued State?
            integer QueuedCaseCount = database.countQuery('SELECT count() FROM Case WHERE ODS_Request_Status__c = \'' + OnDemandSync.REQ_STATUS_QUEUED + '\' AND ODS_Request_Platform__c = \'' + AltPlatform + '\'');
            if (QueuedCaseCount > 0) OnDemandSync.InvokeHTTPRequestBatch(AltPlatform);
        }

        CronJobName = OnDemandSync.HTTP_REQUEST_BATCH_CRON_JOB_ROOT + Platform;
        if (OnDemandSync.isItSafeToInvokeBatch(Platform,CronJobName,OnDemandSync.HTTP_REQUEST_BATCH_CLASS_NAME)){
            // Are there any Cases still in Queued State?
            integer QueuedCaseCount = database.countQuery('SELECT count() FROM Case WHERE ODS_Request_Status__c = \'' + OnDemandSync.REQ_STATUS_QUEUED + '\' AND ODS_Request_Platform__c = \'' + Platform + '\'');
            if (QueuedCaseCount > 0) OnDemandSync.InvokeHTTPRequestBatch(Platform);
        }
    }
    
    public static String BuildRequestBody(Case[] Cases){
        String RequestBody = '';
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, Object> batchMap = new Map<String, Object>();
        for (Case c : Cases){
            String WebMemberId = GetWebMemberIdFromCase(c);
            if (!batchMap.containsKey(c.SuppliedEmail)){ // if email doesn't exist add node
				batchMap.put(c.SuppliedEmail,new Map<String, Object>{
                    'memberId' => WebMemberId,
                    'memberUUID' => c.Web_Member_UUID__c,
                    'externalMemberId' => c.Web_External_Member_Id__c
                });
            } else if (batchMap.containsKey(c.SuppliedEmail)){ // if email exists but with null member id, update member id
	            Map<String, Object> memberMap = (Map<String, Object>) batchMap.get(c.SuppliedEmail);
                if (memberMap.get('memberId') == null  && WebMemberId != null){
					memberMap.put('memberId', WebMemberId);
                }
                if (memberMap.get('externalMemberId') == null  && c.Web_External_Member_Id__c != null){
					memberMap.put('externalMemberId', c.Web_External_Member_Id__c);
                }
                if (memberMap.get('memberUUID') == null  && c.Web_Member_UUID__c != null){
                    memberMap.put('memberUUID', c.Web_Member_UUID__c);
                }

            }
        }
        requestMap.put('batch', batchMap);
        return JSON.serialize(requestMap);
    }

    public static String GetWebMemberIdFromCase(Case c){
        // Web Member Id serves two purposes.  
        	// 1) Web forms pass member ids when they know it (so they're used to ID members insted of emails)
        	// 2) After a member match, the field is also used as the key for relating the Case & Account records.
        // However, with the introduction of the ability to search Multiple Platforms, we want to avoid
        // sending the alternate platform the web member id of the original platform (since they won't know what do with it)
        // The logic below ensures Web Member Id is only passed to its corresponding platform, otherwise it returns null
        if (c.Web_Member_Id__c != null){
            If (c.ODS_Request_Platform__c == PLATFORM_INTL && IsMemberIdInternational(c)){
                return c.Web_Member_Id__c;
            } else if (c.ODS_Request_Platform__c == PLATFORM_US && !IsMemberIdInternational(c)){
				return c.Web_Member_Id__c;                
            }
        }
        return null;
    }
    
    public static Boolean IsMemberIdInternational(Case c){
        if (c.Web_Member_Id__c != null && c.Web_Member_Id__c.length() > 3){
            if (c.Web_Member_Id__c.substring(2,3) == '_') return true;
        }
        return false;
    }
    
    public static Map<String, Object> BuildResponseMap(HttpResponse res){
		// 2018-05-14 - Jack Odell
		// The original version of this method would build the responseMap & examine it to confirm
		// there weren't any errors.  
		// For ODS Int, I'm updating it to instead convert the response to the int format. 
		// If any exceptions are thrown, we assume there's something wrong with the response & return null;
        Map<String, Object> responseMap = null;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // sanity check values
            Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');

            Map<String, Object> uResponseMap = new Map<String, Object>();
            Map<String, Object> uBatchMap = new Map<String, Object>();

            for (String memberMapKey : batchMap.keySet()){
                Map<String, Object> memberMap = (Map<String, Object>) batchMap.get(memberMapKey);
                String memberid = (String) memberMap.get('memberId');
                String salesforceId = (String) memberMap.get('salesforceId');
                String email = (String) memberMap.get('email');
                String firstName = (String) memberMap.get('firstName');
                String lastName = (String) memberMap.get('lastName');
                Boolean blackListed = (Boolean) memberMap.get('blackListed');
                
                List<Map<String,Object>> uResultsList = new List<Map<String, Object>>();
                uResultsList.add(new Map<String, Object>{'memberId'=>memberid,'salesforceId'=>salesforceId,'email'=>email,'firstName'=>firstName,'lastName'=>lastName,'blackListed'=>blackListed});
                uBatchMap.put(memberMapKey,uResultsList);
            }

            uResponseMap.put('batch', uBatchMap);
            responseMap = uResponseMap;
            
        /* Used to Sanity Check US Platform response in first version of ODS
                    Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');
                    for (String memberMapKey : batchMap.keySet()){
                        Map<String, Object> memberMap = (Map<String, Object>) batchMap.get(memberMapKey);
                        String memberid = (String) memberMap.get('memberId');
                        String salesforceId = (String) memberMap.get('salesforceId');
                    }
        */
        } catch (System.Exception e){ // If any errors are thrown here, there's something wrong with the JSON format of the response
            responseMap = null;
        }
        return responseMap;
    }

	public static Map<String, Object> BuildResponseMapInternational(HttpResponse res){
        Map<String, Object> responseMap = null;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // sanity check values
            Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');
            for (String memberMapKey : batchMap.keySet()){
                List<Object> resultsList = (List<Object>) batchMap.get(memberMapKey);
                for (Object resultsItem : resultsList){
                    Map<String, Object> memberMap = (Map<String, Object>) resultsItem;
                    String memberid = (String) memberMap.get('memberId');
                    String salesforceId = (String) memberMap.get('salesforceId');
                }
            }
        } catch (System.Exception e){ // If any errors are thrown here, there's something wrong with the JSON format of the response
            responseMap = null;
        }
        return responseMap;
    }
    
    public static boolean DoesResponseHaveError(HttpResponse res){
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String ErrorMessage = (String) responseMap.get('error'); // if there is an error, this node will contain messages
            String BatchContent = (String) responseMap.get('batch'); // if there is an error, this node contain a null value
            if (BatchContent == null && ErrorMessage != null) return true;
        } catch (System.Exception e){ 
            // If any errors are thrown here, then we assume there are no errors
            return false;
        }
        return false;
    }

    public static String GetResponseError(HttpResponse res){
        String ErrorMessage = '';
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            ErrorMessage = (String) responseMap.get('error'); // if there is an error, this node will contain messages
        } catch (System.Exception e){ 
            // If any errors are thrown here, then we assume there are no errors
            ErrorMessage = '';
        }
        return ErrorMessage;
    }

    public static void HandleSuccess(Case[] Cases, HttpResponse res, Map<String, Object> responseMap, String Platform, OnDemandSync_Batch HTTPBatch){
    /*
		Query Cases (to get updated versions in case there have been changes since request was sent)
		If there is no match: 
			If MemberId is null, there was no match on US platform			
				Send to HandleNoMatch
        If there is a match:
			If member id is not null we have match
			if Account exsits, handle match 
			else if Member Id & Salesforce Id are not null & account doesn't exist, fire error (PA_DOESNT_EXIST_BUT_PLATFORM_THINKS_IT_DOES)
			otherwise Account will be created by Sync soon; so do nothing else (wait for Account trigger to call this method again later)
		Update Cases
		
		Note: logic has been added to prevent multiple concurrent versions of the batch from executing the same logic multiple times.
*/
        // changes to this field list need to be replicated in the query in OnDemandSync_Batch & OnDemandSync_LinkAccountToCase_Batch & in the InvokeODSTimeoutError method
        Case[] uCases = new List<Case>();
        try {
            uCases = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,ContactId,SuppliedEmail,ODS_Number_of_Retries__c,Is_ODS_Max_Retries_Reached__c,Is_ODS_Complete__c,
                      ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin,ODS_Request_Error__c,Orig_Web_Member_Id__c,Member_Locale__c,Web_External_Member_Id__c, Web_Member_UUID__c 
                      FROM Case WHERE id IN :Cases FOR UPDATE];
        } catch (System.Exception e){ 
            return;  // If we can't lock these records, then another version of this process is working on them, so end method
        }

        String[] MatchingMemberIds = GetMemberIdsFromResponse(responseMap);
        Account[] MatchingAccounts = GetMatchingAccounts(MatchingMemberIds, Platform);

        Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');
        for (String SuppliedEmail : batchMap.keySet()){
            List<Object> resultsList = (List<Object>) batchMap.get(SuppliedEmail);
            for (Object resultsItem : resultsList){
                Map<String, Object> memberMap = (Map<String, Object>) resultsItem;
                String memberid = (String) memberMap.get('memberId');
                String salesforceId = (String) memberMap.get('salesforceId');

                Case[] MatchingCases = GetCasesBySuppliedEmail(uCases,SuppliedEmail); // one email may map to multiple cases in batch
                for (Case c : MatchingCases){
                    if (memberid == null){
                        c = HandleNoMatch(c);
                    } else { 
                        if (MatchingMemberIds.contains(memberid)){ // handle match but only for matching member ids
                            // Web Member Id is used to find related cases later (via Account trigger); 
                            // First Platform wins member id
                            if (c.Web_Member_Id__c == null) c.Web_Member_Id__c = memberid; 
                            Account a = GetAccountByMemberId(MatchingAccounts,memberid,Platform); 
                            if (a != null) c = HandleMatch(c,a,memberid);
                            else if (a == null && salesforceId != null){ 
                                HandleError('PA_DOESNT_EXIST_BUT_PLATFORM_THINKS_IT_DOES',c,null,res,null,null);
                            } else if (a == null && salesforceId == null){
                                // There is a match, but Account doesn't exist yet; wait for Sync to create Account
								if (CareDotComUtil.runningInASandbox()) System.Debug('AccountsWaitingForSync Member Id: ' + memberid);
                                HTTPBatch.AccountsWaitingForSync.add(memberid);
                            }
                        } else { // Get non matching member ids & record them in the feed
							CaptureAlternateMatchesForCaseFeed(c,memberid);
                        }
                    }
                }
            }
        }
        UpdateHelper(uCases);
	}

    public static void CaptureAlternateMatchesForCaseFeed(Case c, String MemberId){
        if (!AlternateMatches.containsKey(c.id)) AlternateMatches.put(c.id,new List<String>());
        AlternateMatches.get(c.id).add(MemberId);
    }

    public static List<Account> GetMatchingAccounts(List<String> MatchingMemberIds, String Platform){
        Account[] MatchingAccounts = new List<Account>();  // only query for Accounts if we have member id
        if (!MatchingMemberIds.isEmpty()){
            // We need to be careful with the performance of Account queries, so we're using different queries for each platform (since they use different member id fields)
          	if (Platform == PLATFORM_US) MatchingAccounts = [SELECT id,MemberId__c,Global_Member_Id__c,OwnerId,PersonContactId,MemberType__pc,Locale__pc,RecordTypeId,isPersonAccount FROM Account WHERE MemberId__c IN :MatchingMemberIds];  
            else if (Platform == PLATFORM_INTL) MatchingAccounts = [SELECT id,Global_Member_Id__c,MemberID__c,OwnerId,PersonContactId,Locale__pc,MemberType__pc,RecordTypeId,isPersonAccount FROM Account WHERE Global_Member_Id__c IN :MatchingMemberIds];
        } 
		return MatchingAccounts;
    }

    public static List<Case> GetCasesBySuppliedEmail(Case[] Cases, String SuppliedEmail){
		Case[] MatchingCases = new List<Case>();
        for (Case c : Cases){
            if (c.SuppliedEmail == SuppliedEmail) MatchingCases.add(c);
        }
        return MatchingCases;
    }

    public static Account GetAccountByMemberId(Account[] Accounts, String MemberId, String Platform){
        for (Account a : Accounts){
            if (Platform == PLATFORM_US && a.MemberId__c == MemberId) return a;
            else if (Platform == PLATFORM_INTL && a.Global_Member_Id__c == MemberId) return a;
        }
        return null;
    }

    public static List<String> GetMemberIdsFromResponse(Map<String, Object> responseMap){
		// Only return member ids if they're not null
		// If there are multiple matches, only returns the member id of the primary match
        String[] MemberIds = new List<String>();
        Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');
        for (String memberMapKey : batchMap.keySet()){
            List<Object> resultsList = (List<Object>) batchMap.get(memberMapKey);
			Date MostRecentDate = null;
            String MostRecentMemberId = null;
            for (Object resultsItem : resultsList){
                Map<String, Object> memberMap = (Map<String, Object>) resultsItem;
                String memberid = (String) memberMap.get('memberId');
                String lastLogin = (String) memberMap.get('lastLogin');
                Date lastLoginDate = null;
                if (lastLogin != null) lastLoginDate = date.newInstance(Integer.valueOf(lastLogin.left(4)), Integer.valueOf(lastLogin.mid(5, 2)), Integer.valueOf(lastLogin.right(2)));

                if (MostRecentDate == null) {
                    MostRecentDate = lastLoginDate;
                    MostRecentMemberId = memberid;
                } else {
                    if (lastLoginDate > MostRecentDate){ // if date is more recent, overwrite date & member id
                        MostRecentDate = lastLoginDate;
                        MostRecentMemberId = memberid;
                    }
                } 
            }
            if (MostRecentMemberId != null) MemberIds.add(MostRecentMemberId);
        }
        return MemberIds;
    }
    
    public static Case HandleNoMatch(Case c){
/*
  	Set Request Status to Complete - No Match.
*/
		c.ODS_Request_Status__c = REQ_STATUS_COMPLETENOMATCH;
        return c;
    }

    public static Case HandleMatch(Case c,Account a,String memberid){
/*
    If Case is owned by User, set Request Status to Complete - Match/No Update (unless it's a chat case)
    Otherwise (in other words, if case is owned by a queue or is a chat case owned by a user):
        Set Request Status to Complete - Match
        Invoke Set Case Tier Logic
		Associate Person Account to Case

		Multiple Platform search note: when searching across multiple platforms, the original platform has preference.
		Since our multiple platform search is sequential, this means that whichever platform arrives first
		gets to set the Person Account.  This is enforced by checking for a null c.ContactId.
		If the Person Account is already defined, then the member id is recorded in the Case Feed instead.
		Also, if the case platform has switched, then we will invoke Case Platform Conversion.
*/
        String cOwnerId = (String) c.OwnerId;
        System.debug('VM cOwnerId '+cOwnerId);
        //if (cOwnerId.left(3) != '00G' && c.Origin != ORIGIN_CHAT) {
        //    c.ODS_Request_Status__c = REQ_STATUS_MATCHNOUPDATE;
        //} else {
            c.ODS_Request_Status__c = REQ_STATUS_COMPLETEMATCH;
            if (c.ODS_Request_Error__c == REQ_ERROR_ODS_TIMEOUT) c.ODS_Request_Error__c = null; // null out ODS Request Error when self-healing after ODS Timeout

            if (c.ContactId == null){
                c.ContactId = a.PersonContactId;
                //c.Tier__c = null;  // null out tier so Case trigger can reevaluate it on before update trigger

            	// Case Platform conversion should occur here.  Logic:  if Alt ODS Request Status is not null & c.ContactId is null.
            	// Namely: if alt platform is done & didn't set a contact but we're doing so now, then we should invoke Case Platform Conversion
            	// Target Platform: look at the Account record type to determine which platform to convert it to
                if (c.Alt_ODS_Request_Status__c != null){
	            	String TargetPlatform = (CareDotComUtil.isInternationalAccount(a) == true) ? PLATFORM_INTL : PLATFORM_US;
                    CasePlatformConversion.convert(c, a, TargetPlatform);    
                } 
                
                // Changing Case Contact on queue-owned case should reinvoke assignment rules
                // Otherwise, it should leave the owner unchanged (like for chat cases)
                //Gears Case:00042482
                //Moved to Breeze
                /*if (cOwnerId.left(3) == '00G'){
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
                    dmlOpts.EmailHeader.triggerUserEmail  = true;
                    c.setOptions(dmlOpts);                    
                }*/

            } else {// Else record member id in case feed instead
                if (c.ContactId != a.PersonContactId){ // as long as the Case & Account are not already related
                    CaptureAlternateMatchesForCaseFeed(c,memberid);  
                } 
            }
        //}
        return c;
    }
        
    public static void HandleNewlyCreatedAccounts(Account[] Accounts){
/*
    Confirm Account is worth evaluting (is Person Account? Member Id not null?)
	Confirm batch job is worth calling by querying for Cases that match Account (via Web_Member_Id__c) with null Account Id exist
	
	Invoke Batch Job to Link Account to Cases via the following logic (OnDemandSync_LinkAccountToCase_Batch):
		Query for related Cases that are candidates for OnDemandSync
	    	Cases whose member Ids match Case.Web_Member_Id__c
			Cases that are open or chat (since chat should allow linking of closed cases)
			Cases where ODS is not yet complete OR with ODS Timeout errors
			This logic facilitates self-healing by allowing Cases to be reprocessed as long as the Case is still flagged with ODS Timeout error

		Link Cases
			Query for Accounts that match returned Cases (related via Web_Member_Id__c)
			Call HandleMatch(Case) for each Case
	    	Update Cases
*/

		Boolean HasInternationalAccount = false;
        Boolean HasUSAccount = false;

        List<String> MemberIds = new List<String>();
        for (Account a : Accounts){
            if (a.isPersonAccount)
                if (a.MemberID__c != null) MemberIds.add(a.MemberID__c);  // US member id
            	else if (a.Global_Member_Id__c != null) MemberIds.add(a.Global_Member_Id__c);  // intl member id
        }
        
        if (!MemberIds.IsEmpty()){
            Case[] Cases = [SELECT id,Web_Member_Id__c FROM Case WHERE Case.Web_Member_Id__c IN :MemberIds
                            AND (Is_ODS_Complete__c = false OR ODS_Request_Error__c = :REQ_ERROR_ODS_TIMEOUT)
                            AND (IsClosed = false OR Origin = :ORIGIN_CHAT)
                           ];
            
            for (Case c: Cases){
                if (GetAccountByMemberId(Accounts,c.Web_Member_Id__c,PLATFORM_INTL) != null){
                    HasInternationalAccount = true;
                } else if(GetAccountByMemberId(Accounts,c.Web_Member_Id__c,PLATFORM_US) != null){
                    HasUSAccount = true;
                }
            } 
        }
        
        if (HasUSAccount) InvokeLinkBatch(PLATFORM_US);
        
        if (HasInternationalAccount) InvokeLinkBatch(PLATFORM_INTL);

    }
    
    public static void LinkAccountToCase(Case[] Cases, String Platform){
        List<Case> CasesToUpdate = new List<Case>();
        List<String> MatchingMemberIds = new List<String>();

        for (Case c : Cases){
            if (!String.isBlank(c.Web_Member_Id__c)){ // ensure only valid member ids are passed
                MatchingMemberIds.add(c.Web_Member_Id__c);    
            }
        }
        
        List<Account> MatchingAccounts = GetMatchingAccounts(MatchingMemberIds, Platform);
        
        for (Case c: Cases){
            Account a = GetAccountByMemberId(MatchingAccounts,c.Web_Member_Id__c,Platform);
            if (a != null){
                HandleMatch(c,a,c.Web_Member_Id__c);
				CasesToUpdate.add(c); // we should only update Cases that have been associated with an Account; 
            } 
        }
        UpdateHelper(CasesToUpdate);
    }

    public static void HandleError(String ErrorCode, Case[] Cases, HttpRequest req, HttpResponse res, System.Exception e, Map<ID,Database.Error[]> DMLErrorMap){
/*
		Purpose: designed to handle errors to affect the whole batch. Will execute update DML against all Cases passed to it.

		Identify error & set Request Status & Request Error accordingly
		If error requires Retry & Max Retries not exceeded        
			Increment Retry Counter
        	Update Case Request Status to Queued
		Otherwise, set Request Status to error & flag Cases as Completed
		Update Cases
			Invoke AutoResponse (autoresponse is invoked by changes to Request Status)

*/
        for (Case c : Cases){
            HandleError(ErrorCode,c,req,res,e,DMLErrorMap);
        }
        UpdateHelper(Cases);
    }
    
    public static void HandleError(String ErrorCode, Case c, HttpRequest req, HttpResponse res, System.Exception e, Map<ID,Database.Error[]> DMLErrorMap){
/*
		Purpose: designed to handle errors on a Case by case basis.  Method that calls this method, will be responsible for executing
				update DML for this record.
		NOTE: To see whether errors require retry or who they should notify, review Design Doc in wiki: https://wiki.carezen.local/x/FkmkAQ
*/
        if (CareDotComUtil.runningInASandbox() && e != null){
            System.Debug('e.getMessage(): ' + e.getMessage());
        } else if (CareDotComUtil.runningInASandbox() && res != null){
            System.Debug('res.getStatusCode(): ' + res.getStatusCode());
            System.Debug('res.getStatus(): ' + res.getStatus());
        }

        // review exceptions
        if (ErrorCode == 'HTTP_EXCEPTION_ERROR'){  // an exception was throw, use e to get more details
            HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,e.getMessage(),true);
        } else if (ErrorCode == 'EXTERNAL_PLATFORM_HTTP_ERROR'){ // Review response to get error code
            if (res.getStatusCode() == 401 && res.getBody().contains('INVALID_API_KEY')){ // invalid API Key
                HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,'Invalid API Key',false);
            } else if (res.getStatusCode() == 401){ // unauthorized endpoint
                HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,'Unauthorized Endpoint',false);
                sendAdminEmail('UNAUTHORIZED_ENDPOINT', c);
            } else {
	            HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,res.getStatusCode() + ': ' + res.getStatus(),true);    
            }

        } else if (ErrorCode == 'EXTERNAL_PLATFORM_ERROR'){ // Review JSON body to get error
            // When US platform returns an error via JSON, it means something is wrong with the request; Which means its a SFDC error/no retry
            // When Sterling platform returns an error via JSON, it could mean anything.  Tag as Sterling error/retry
            if (c.ODS_Request_Platform__c == PLATFORM_US) HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,'Malformed Request: ' + GetResponseError(res),false);
            else HandleRetryLogic(c,REQ_STATUS_ERROR_INTLPLATFORM,'Unknown internal error: ' + GetResponseError(res),true);

        } else if (ErrorCode == 'JSON_FORMAT_ERROR'){ // Something is wrong with the format of the JSON response
            HandleRetryLogic(c,getPlatformErrorStatus(c),'JSON Format Error',true); 
        } else if (ErrorCode == 'NO_MATCHING_COUNTRY_SETTINGS'){
            HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,'No matching country in Custom Settings',false);
            sendAdminEmail(ErrorCode, c);
        } else if (ErrorCode == 'ODS_TIMEOUT'){ // ODS was unable to complete transaction, so we're timing out
            HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,REQ_ERROR_ODS_TIMEOUT,false);
        } else if (ErrorCode == 'PA_DOESNT_EXIST_BUT_PLATFORM_THINKS_IT_DOES'){
            HandleRetryLogic(c,getPlatformErrorStatus(c),'PA doesn\'t exist but Platform thinks it does.',false); 
            sendAdminEmail(ErrorCode, c);
        } else if (ErrorCode == 'TOO_MANY_CALLOUTS'){
            HandleRetryLogic(c,REQ_STATUS_ERROR_SALESFORCE,'Too many callouts',true);
        } else {
			HandleRetryLogic(c,REQ_STATUS_ERROR_UNKNOWN,'Unknown internal error',true);
        }
    }
    
    public static void HandleDMLError(Case[] Cases, Map<ID,Database.Error[]> DMLErrorMap){
        // DML Errors are special.  Usually errors are recorded in the Case itself.  However, we can't do with DML errors, because
        // the cause the of the DML error is preventing us from updating the Case.  Since we can't update the Case,
        // we will send an email to the admins instead, so they can try to fix the Case manually.
        for (Case c : Cases){
            if (DMLErrorMap.get(c.id)[0].getStatusCode() != StatusCode.UNABLE_TO_LOCK_ROW){  // row lock errors are self healing & don't need to be alerted
	            sendAdminEmailDMLError(DMLErrorMap.get(c.id)[0],c); // the first error should be sufficient
            }
        }
    }
    
    public static String getPlatformErrorStatus(Case c){
        String PlatformErrorStatus = REQ_STATUS_ERROR_UNKNOWN;
        if (c.ODS_Request_Platform__c == PLATFORM_US){
            PlatformErrorStatus = REQ_STATUS_ERROR_USPLATFORM;  
        } else if (c.ODS_Request_Platform__c == PLATFORM_INTL){
            PlatformErrorStatus = REQ_STATUS_ERROR_INTLPLATFORM;  
        } 
        return PlatformErrorStatus;
    }

	public static void HandleRetryLogic(Case c, String RequestStatus, String ErrorMessage, Boolean Retry){

        if (CareDotComUtil.runningInASandbox()) System.Debug('ErrorMessage: ' + ErrorMessage);
        c.ODS_Request_Error__c = ErrorMessage.left(100);
        if (Retry == true && c.ODS_Number_of_Retries__c < OnDemandSync_Settings.getRetryLimit(c.ODS_Request_Platform__c) ){
            c.ODS_Number_of_Retries__c++;
            c.ODS_Request_Status__c = REQ_STATUS_QUEUED;
        } else {
            c.ODS_Request_Status__c = RequestStatus;    
            c.Is_ODS_Max_Retries_Reached__c = true;
        }
    }

	@InvocableMethod
	public static void InvokeODSTimeoutError(Case[] Cases){
		// This method is invoked by Process Builder flow that manages ODS Timeout
		// If timeout occurs, this method will set the ODS Timeout error for all Cases passed to it
        Set<ID> CaseIds = new Set<ID>();
        for (Case c: Cases){
            CaseIds.add(c.Id);
        }

        // changes to this field list need to be replicated in the query in OnDemandSync_Batch & OnDemandSync_LinkAccountToCase_Batch & in the InvokeODSTimeoutError method
        
        Case[] CasesRW = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,ContactId,SuppliedEmail,ODS_Number_of_Retries__c,Is_ODS_Max_Retries_Reached__c,Is_ODS_Complete__c,
                      		ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin,ODS_Request_Error__c,Orig_Web_Member_Id__c,Member_Locale__c,Web_External_Member_Id__c,Web_Member_UUID__c 
                          FROM Case WHERE ID IN : CaseIds];
        handleError('ODS_TIMEOUT', CasesRW, null, null, null,null);

    }    

    public static void sendAdminEmail(String ErrorCode, Case c){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>(); 
        toAddresses.add(OnDemandSync_Settings.getErrorNotificationEmail(c.ODS_Request_Platform__c));

        // Handle QA Email
        String QAEmail = CountryLocaleMapHelper.getQAEmail(c.Member_Locale__c);
        if (String.isNotEmpty(QAEmail)) toAddresses.add(QAEmail);
        
        mail.setToAddresses(toAddresses);
        mail.setSubject('OnDemandSync Error: ' + ErrorCode);
        mail.setBccSender(false);
		String Subject = 'This case has generated an error that requires admin attention.  Refer to the wiki to review admin guidance for this error.\r\n\r\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.id;
        mail.setPlainTextBody(Subject);
        if (!Test.isRunningTest() && !CareDotComUtil.runningInASandbox()){  // only send if not a test & in production
	        Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        } 
    }

    public static void sendAdminEmailDMLError (Database.Error DbError, Case c){
        // DML Errors are sent to admin & QA email in production
        // They're only sent to QA email in sandboxes

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>(); 
        if (!CareDotComUtil.runningInASandbox()) toAddresses.add(OnDemandSync_Settings.getErrorNotificationEmail(c.ODS_Request_Platform__c));

        // Handle QA Email
        String QAEmail;
        if (c.Member_Locale__c != null) QAEmail = CountryLocaleMapHelper.getQAEmail(c.Member_Locale__c);
        else {
            Sterling_Country_Setting__mdt cmd = CountryLocaleMapHelper.getSettingByCountry('us');
            QAEmail = cmd.QA_Email__c;
        }
        if (String.isNotEmpty(QAEmail)) toAddresses.add(QAEmail);
        
        mail.setToAddresses(toAddresses);
        mail.setSubject('OnDemandSync Error: DML Error');
        mail.setBccSender(false);
		
        List<String> ErrFields = DbError.getFields();
        String Separator = ', ';
        String ErrFieldStr = String.join(ErrFields, Separator);
        
        String ErrorMessage =  DBError.getMessage() + ' (' + DbError.getStatusCode() + ')' + '\r\nFields: ' + ErrFieldStr;
        
        String Subject = 'This case has generated a DML Error.  An admin must manually edit the record ASAP.  If the DML error has a simple solution, fix the DML error.  Otherwise, set ODS Request Status to Error - Salesforce.\r\n\r\n';
		Subject += ErrorMessage + '\r\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.id;
        mail.setPlainTextBody(Subject);
        if (CareDotComUtil.runningInASandbox()) System.Debug('DML Error Subject: ' + Subject);
        if (!Test.isRunningTest()){  // only send if not a test 
	        Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        } 
    }
}