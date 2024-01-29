public without sharing class OnDemandSync_Instant {
    public static ID saRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seeker').getRecordTypeId();
    public static ID paRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    public static ID smbpaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SMB_Provider').getRecordTypeId();
    public static ID isaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID ipaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    public static ID CaseAndAccountCreator = '005700000012X5uAAE'; //Care.com Salesforce Admin

    
    public static Account getAccountViaInstantODS(Case c, String MemberType){
        return getAccountViaInstantODS(c, MemberType, 'en_US');
    }
    
    public static Account getAccountViaInstantODS(Case c, String MemberType, String locale){
        /*
                Make HTTP Request
                Process Response
                    If Account Exists, return it
                    Else insert Account & return it

                On Error, return null account & error in Case.ODS_Request_Status__c (user should be prompted to retry)
        */        
        List<Case> Cases = new List<Case>();
        Cases.add(c);

        String Platform = getUserPlatform(locale);
        if (CareDotComUtil.runningInASandbox()) System.debug('Platform: ' + Platform);

        Account a = HTTPRequest(Cases, Platform);

        // Catch Response errors in Case.  Calling class will need to look in c.ODS_Request_Status__c to figure out what the error is
        if (c.ODS_Request_Status__c == null){
            if (a.id == null){ // if a.id is null, then this accounts needs to be created
                a.RecordTypeId = getAccountRecordType(MemberType, Platform);
                a.ownerId = CaseAndAccountCreator; //Care.com Salesforce Admin
                try {
                    insert a;
                } catch (Exception e) { // on all errors we return a null account (so that user may be prompted to retry)
                    a = null;
                    c.ODS_Request_Status__c = OnDemandSync.REQ_STATUS_ERROR_SALESFORCE;
                    c.ODS_Request_Error__c = 'Unable to create Account';
                }
            }
        }

      if (CareDotComUtil.runningInASandbox()) System.debug('Instant ODS Account: ' + a);
        return a;

    }
    
    public static string getUserPlatform(String locale){
        Sterling_Country_Setting__mdt CountryLocaleMap = CountryLocaleMapHelper.getSettingByCountry('us');
        if (locale == CountryLocaleMap.Locale__c){ // if User's locale matches the US Locale in CMD, then its a US request
            return OnDemandSync.PLATFORM_US;
        }
        return OnDemandSync.PLATFORM_INTL; // else return international
    }


    public static ID getAccountRecordType(String MemberType, String Patform){
        ID returnId;
        String memberTypeLower = memberType.toLowerCase();
        if (Patform == OnDemandSync.PLATFORM_INTL){
            if (memberTypeLower == 'provider') returnId = ipaRtId;
            else returnId = isaRtId;    
        } else {
            if (memberTypeLower == 'provider') returnId = paRtId;
            else if (memberTypeLower == 'company' || memberTypeLower == 'smb provider') returnId = smbpaRtId;
            else returnId = saRtId; // default to seeker
        }
        return returnId;
    }

    public static Account HTTPRequest(Case[] Cases, String Platform){
        if (Platform == OnDemandSync.PLATFORM_US){
            return HTTPRequestUS(Cases);
        }
        return HTTPRequestInternational(Cases); // otherwise, it's an international request
    }

    public static Account HTTPRequestInternational(Case[] Cases){
        // Send HTTP Request
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 

        OnDemandSync.SetupHTTPRequestInternational(Cases, req, res);

        if (Limits.getCallouts() == Limits.getLimitCallouts()){
            HandleError('TOO_MANY_CALLOUTS',Cases,req,res,null,null);
            return null;            
         }

        try {
            // Send request
            res = http.send(req);
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Code: ' + res.getStatusCode());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Massage: ' + res.getStatus());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Res: ' + res.getBody());
            
            if (res.getStatusCode() == 200){ // HTTP success code
                if (OnDemandSync.DoesResponseHaveError(res)){ // evaluate response for existence of error node
                    HandleError('EXTERNAL_PLATFORM_ERROR',Cases,req,res,null,null);
                } else {
                    Map<String, Object> responseMap = OnDemandSync.BuildResponseMapInternational(res); // process & ensure response is proper JSON
                    if (responseMap == null){
                        HandleError('JSON_FORMAT_ERROR',Cases,req,res,null,null);
                    } else {
                        return HandleSuccess(Cases,res,responseMap,OnDemandSync.PLATFORM_INTL);    // Handle Success
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

        return null;
    }

    public static Account HTTPRequestUS(Case[] Cases){
        // Send HTTP Request
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        
        OnDemandSync.SetupHTTPRequest(Cases, req, res);
        
        if (Limits.getCallouts() == Limits.getLimitCallouts()){
            HandleError('TOO_MANY_CALLOUTS',Cases,req,res,null,null);
            return null;            
         }

        try {
            // Send request
            res = http.send(req);
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Code: ' + res.getStatusCode());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Status Massage: ' + res.getStatus());
            if (CareDotComUtil.runningInASandbox()) System.Debug('HTTP Res: ' + res.getBody());
            
            if (res.getStatusCode() == 200){ // HTTP success code
                if (OnDemandSync.DoesResponseHaveError(res)){ // evaluate response for existence of error node
                    HandleError('EXTERNAL_PLATFORM_ERROR',Cases,req,res,null,null);
                } else {
                    Map<String, Object> responseMap = OnDemandSync.BuildResponseMap(res); // process & ensure response is proper JSON
                    if (responseMap == null){
                        HandleError('JSON_FORMAT_ERROR',Cases,req,res,null,null);
                    } else {
                        return HandleSuccess(Cases,res,responseMap,OnDemandSync.PLATFORM_US);    // Handle Success
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

        return null;
    }

    public static Account HandleSuccess(Case[] Cases, HttpResponse res, Map<String, Object> responseMap, String Platform){
        /*
                Get Details from Response
            
        */
        Account FoundAccount = new Account();

        Case[] uCases = Cases;

        String[] MatchingMemberIds = OnDemandSync.GetMemberIdsFromResponse(responseMap);
        Account[] MatchingAccounts = OnDemandSync.GetMatchingAccounts(MatchingMemberIds, Platform);

        Map<String, Object> batchMap = (Map<String, Object>) responseMap.get('batch');
        for (String SuppliedEmail : batchMap.keySet()){
            List<Object> resultsList = (List<Object>) batchMap.get(SuppliedEmail);
            for (Object resultsItem : resultsList){
                Map<String, Object> memberMap = (Map<String, Object>) resultsItem;
                String memberid = (String) memberMap.get('memberId');
                String salesforceId = (String) memberMap.get('salesforceId');
                String firstName = (String) memberMap.get('firstName');
                String lastName = (String) memberMap.get('lastName');
                String email = (String) memberMap.get('email');
                String memberuuid=(String) memberMap.get('memberUUID' ); // added memberuuid
                Boolean blackListed = (Boolean) memberMap.get('blackListed');
                String countryCode = (String) memberMap.get('countryCode');
                String locale = (String) memberMap.get('locale');
                
                if (memberid != null){
                    if (MatchingMemberIds.contains(memberid)){ // handle match but only for matching member ids
                        Account a = OnDemandSync.GetAccountByMemberId(MatchingAccounts,memberid,Platform); // query for account in Salesforce
                        if (a != null) FoundAccount.id = a.id; // If Account exists in Salesforce, capture its id here; FoundAccount with null id will require insert later
                        if (Platform == OnDemandSync.PLATFORM_US){ // member id varies per platform
                            FoundAccount.MemberID__pc = Integer.valueOf(memberid);
                            FoundAccount.MemberID__c = memberId;
                            FoundAccount.memberUUID__c = memberUUID; //added memberuuid
                        } else {
                            FoundAccount.Global_Member_Id__c = memberId;
                        }
                        FoundAccount.PersonEmail = email.unescapeHtml4().replace('|','.');
                        // supplied email is a dummy value, so we're using email from Care.com DB
                        // Care.com emails for closed members have pipe delimiter (which results in invalid email for Saleforce); replacing w/ dot
                        FoundAccount.FirstName = (firstName != null) ? firstName : 'Unknown';
                        FoundAccount.LastName = (lastName != null) ? lastName : 'Unknown';
                        FoundAccount.Blacklisted__pc = (blackListed != null) ? blackListed : false;
                        FoundAccount.PersonMailingCountry = (countryCode != null) ? countryCode : null;
                        FoundAccount.Locale__pc = (locale != null) ? locale : null;
                    }
                }
            }
        }
        return FoundAccount;
    }

    public static void HandleError(String ErrorCode, Case[] Cases, HttpRequest req, HttpResponse res, System.Exception e, Map<ID,Database.Error[]> DMLErrorMap){
        for (Case c : Cases){
            HandleError(ErrorCode,c,req,res,e,DMLErrorMap);
        }
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
            HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,e.getMessage(),true);
        } else if (ErrorCode == 'EXTERNAL_PLATFORM_HTTP_ERROR'){ // Review response to get error code
            if (res.getStatusCode() == 401 && res.getBody().contains('INVALID_API_KEY')){ // invalid API Key
                HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,'Invalid API Key',false);
            } else if (res.getStatusCode() == 401){ // unauthorized endpoint
                HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,'Unauthorized Endpoint',false);
            } else {
                HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,res.getStatusCode() + ': ' + res.getStatus(),true);    
            }
        } else if (ErrorCode == 'NO_MATCHING_COUNTRY_SETTINGS'){
            HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,'No matching country in Custom Settings',false);
        } else if (ErrorCode == 'ODS_TIMEOUT'){ // ODS was unable to complete transaction, so we're timing out
            HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,OnDemandSync.REQ_ERROR_ODS_TIMEOUT,false);
        } else if (ErrorCode == 'PA_DOESNT_EXIST_BUT_PLATFORM_THINKS_IT_DOES'){
            HandleRetryLogic(c,OnDemandSync.getPlatformErrorStatus(c),'PA doesn\'t exist but Platform thinks it does.',false); 
        } else if (ErrorCode == 'TOO_MANY_CALLOUTS'){
            HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,'Too many callouts',true);
        } else if (ErrorCode == 'EXTERNAL_PLATFORM_ERROR'){ // Review JSON body to get error
            // When US platform returns an error via JSON, it means something is wrong with the request; Which means its a SFDC error/no retry
            // When Sterling platform returns an error via JSON, it could mean anything.  Tag as Sterling error/retry
            if (c.ODS_Request_Platform__c == OnDemandSync.PLATFORM_US) HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_SALESFORCE,'Malformed Request: ' + OnDemandSync.GetResponseError(res),false);
            else HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_INTLPLATFORM,'Unknown internal error: ' + OnDemandSync.GetResponseError(res),true);

        } else if (ErrorCode == 'JSON_FORMAT_ERROR'){ // Something is wrong with the format of the JSON response
            HandleRetryLogic(c,OnDemandSync.getPlatformErrorStatus(c),'JSON Format Error',true); 
        } else {
            HandleRetryLogic(c,OnDemandSync.REQ_STATUS_ERROR_UNKNOWN,'Unknown internal error',true);
        }
    }

    public static void HandleRetryLogic(Case c, String RequestStatus, String ErrorMessage, Boolean Retry){
        // Instant ODS doesn't really support retry; errors are sent back to user & they should be allowed to retry
        
        if (CareDotComUtil.runningInASandbox()) System.Debug('ErrorMessage: ' + ErrorMessage);
        c.ODS_Request_Error__c = ErrorMessage.left(100);
        c.ODS_Request_Status__c = RequestStatus;    
        c.Is_ODS_Max_Retries_Reached__c = true;
    }

}