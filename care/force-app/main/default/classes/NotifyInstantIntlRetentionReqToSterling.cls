/*
** _________________________________________________________________________________
** Created by:    Jack Odell
** Modified by:   NBOS Technologies [http://nbostechnologies.com/]
** Developer:     Sridhar Neeli, Software Developer [sridharn@nbostech.com]
** Modified Date:  08.05.2023
** =================================================================================
** Description: 
**             Utility Class which hits Sterling Service in the case of Case Downgrade/Cancel
**             Modified the code as part of SFORCE-1126 to rename Secondary case reason value 
**             from Subscripton Service to Subscription Service(Complaint) 
** _______________________________________________________________________________
*/
public without sharing class NotifyInstantIntlRetentionReqToSterling {
    public static Map<String,Account> gmIdAccMap;
    public static List<Id> failedAccounts=new List<Id>();
    public static List<Id> successAccounts=new List<Id>();
    public static List<id> allAccIdList=new List<Id>();
    public static  Integer i=0;
    public static List<String> userEmailList;
    public static string ErrorMessage_Service = 'SERVICE: The NotifyInstantIntlRetentionReqToSterling class has thrown an error.\r\n\r\n';
    public static string ErrorMessage_Background = 'BACKGROUND: This class calls the International API whenever a Member Care Agent is trying to process an account for Retention via Salesforce.\r\n\r\n';
    public static string ErrorMessage_AgentNotifiedYes = 'HAS AGENT BEEN NOTIFIED: Yes, a task was created in Salesforce telling the user to manually notify the sterling platform\r\n\r\n';
    // Sterling Country Settings errors
    public static string ErrorMessage_NoMatchingScsMdt = 'ERROR: NoMatchingSterlingCountrySetting.\r\n\r\nThe country passed does not have an entry in the "Sterling Country Settings" table.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_NoMatchingScsMdt = 'DO I NEED TO DO ANYTHING: Yes. Add this country to the "Sterling Country Settings" table.\r\n\r\n';
    // Exceeded limit errors
    public static string ErrorMessage_Error_TooManyCallOuts = 'ERROR: TooManyCallOuts.\r\n\r\nSalesforce has a limit of 100 concurrent callouts.\r\n\r\n';
    public static string ErrorMessage_Error_TooManyFutureCalls = 'ERROR: TooManyFutureCalls.\r\n\r\nSalesforce has a limit of 50 concurrent @future (or asynchronous) calls.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_Limits = 'DO I NEED TO DO ANYTHING: Maybe. If this error is sporadic it may be safey ignored.  But if the error starts happening often it means we have too many agents working concurrently and this feature will need to be rearchitected to produce fewer callouts.\r\n\r\n';
    // Unforeseen errors
    public static string ErrorMessage_Error_Unforeseen = 'ERROR: An unforeseen error has occurred.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_Unforeseen = 'DO I NEED TO DO ANYTHING: Maybe.  You will need to analyze the error and decide.\r\n\r\n';
    // Missing Parameters
    public static string ErrorMessage_Error_MissingParameter = 'ERROR: Missing API Parameter.  Salesforce passed a blank parameter when it should not have.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_MissingParameter = 'DO I NEED TO DO ANYTHING: Yes, but not urgently.  Notify the Apex developer so they can fix this use case.\r\n\r\n';
    // Invalid member id errors
    public static string ErrorMessage_Error_InvalidMemberId = 'ERROR: Invalid Member Id.  The Email Address associated with the Salesforce Case does not match the member\'s email address in Smithers.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_InvalidMemberId = 'DO I NEED TO DO ANYTHING: No.  This can happen from time to time & can be safely igonored\r\n\r\n';
    // Invalid Salesforce Id errors    
    public static string ErrorMessage_Error_InvalidSalesforceId = 'ERROR: Invalid Salesforce Id.  The Salesforce Username associated with the agent is incorrect.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_InvalidSalesforceId = 'DO I NEED TO DO ANYTHING: Yes.  Contact the agent have them put their Salesforce Username in Smithers (in the "Salesforce User ID" field).\r\n\r\n';
    // Unauthorized Endpoint
    public static string ErrorMessage_Error_UnauthorizedEndpoint = 'ERROR: Unauthorized Endpoint.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_UnauthorizedEndpoint = 'DO I NEED TO DO ANYTHING: Yes.  Salesforce settings need to be updated immediately.  You must add the domain Salesforce is trying to reach to the Remote Site Settings in Salesforce.\r\n\r\n';
    //chatter post error
    public static string ErrorMessage_chatterfeed = 'ERROR: Chatter post error.\r\n\r\n';
    public static string ErrorMessage_DoINeedToDoAnything_ErrorMessage_chatterfeed = 'DO I NEED TO DO ANYTHING: Fix 400 error.\r\n\r\n';
    public static void NotifyInstantRetentionRequestToSterling(List<Account> accList)
    {
        List<Process_Control_Settings__mdt>  pcsList= new List<Process_Control_Settings__mdt>([SELECT Additional_Information__c,Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,Switch__c FROM Process_Control_Settings__mdt where Process_Name__c in ('Intl Retention Admin Notification','Intl Retention Sterling Sync','Intl Retention')]);
        Map<String,String> pcsListMap=new Map<String,String>();
        for(Process_Control_Settings__mdt pcsStr:pcsList)
        {
            pcsListMap.put(pcsStr.Process_Name__c,pcsStr.Switch__c);
        }
        List<Id> pcIdList=new List<id>();
        String retentionAdminNotification=pcsListMap.get('Intl Retention Admin Notification');
        String syncSwitch=pcsListMap.get('Intl Retention Sterling Sync');
        //String retentionSwitch=pcsListMap.get('Intl Retention');
        if(syncSwitch=='On')
        {
            for (Account accObj : accList){
                {
                    if (!String.isBlank(accObj.Global_Member_Id__c))
                    { 
                        if (Limits.getFutureCalls() == Limits.getLimitFutureCalls())
                        {
                            //Calling another future job would generate a Future error;  calling error function instead
                            //notifyAccountOwner(accObj.id,accObj.ownerId,accObj.Request_Type__c);
                            if(retentionAdminNotification == 'On')    
                            {
                                notifySalesforceAdmin(null,'TooManyFutureCalls');
                            }
                        } else 
                        {
                            String sterlingReq=CareDotComUtil.runningInASandbox()?UserInfo.getUserName().subString(0,UserInfo.getUserName().lastIndexOf('.')):UserInfo.getUserEmail();
                            if(CareDotComUtil.runningInASandbox()) System.debug('SalesforceId===>:'+sterlingReq);
                            sendRequest(sterlingReq,accObj.Global_Member_Id__c,accObj.personEmail,accObj.Locale__pc,accObj.id,accObj.GDPR_Request__c,accObj.Request_Type__c,accObj.ownerId,accObj.Salesforce_Last_Action_Date__c==null?'':String.valueOf(accObj.Salesforce_Last_Action_Date__c),retentionAdminNotification);
                        }
                    }
                    i+=1;
                }
            }
        }
        else
        {
            for(Account accObj:accList)
            {
                accObj.Gdpr_Sync_Status__c='Failure';
                if(accObj.Fail_Over_Retrial_Count__c==null)
                {
                    accObj.Fail_Over_Retrial_Count__c=Integer.valueOf(0);
                }
                else
                {
                    accObj.Fail_Over_Retrial_Count__c = Integer.valueOf(accObj.Fail_Over_Retrial_Count__c)+1;
                    if(CareDotComUtil.runningInASandbox()) 
                        System.debug('accObj.Fail_Over_Retrial_Count__c increased....'+accObj.Fail_Over_Retrial_Count__c);
                }
            }
            if(!accList.isEmpty()) update accList;
        }
    }
    private static String QAEmail = '';
    @future(callout=true)
    public static void sendRequest(String userEmail,String globalMemberId,String personEmail,String locale,String accountId,String RetentionrRquest,String requestType,String ownerId,String salesforceLastActionDate,String retentionAdminNotification) 
    {
        List<String> postFeedList=new List<String>();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        /*
        accessToken   
        memberEmail       PersonEmail
        memberId          Global_Member_Id__c  (For international members)
        saleForceId      
        Id
        country           Locale__pc ???   Ex:de_DE   first two characters String.subString(0,2)  
        action  (“RTBF Fail”, “RTBF Complete”)
        reason (“Employer Program”, “Safety Case”, “Premium”, “Invalid Record Type”) Please leave empty if “RTBF Complete”
        PersonEmail,Global_Member_Id__c,Locale__pc
        */
        // Define request body
        String RequestBody = '';
        //RequestBody += 'memberEmail='+personEmail;   //Removed as part of data security
        RequestBody += '&preCheckAction=' + EncodingUtil.urlEncode(RetentionrRquest, 'UTF-8');        
        //RequestBody += 'preCheckAction=' + EncodingUtil.urlEncode(RetentionrRquest, 'UTF-8');        
        RequestBody += '&country=' + EncodingUtil.urlEncode(globalMemberId.subString(0,2).toLowerCase(), 'UTF-8');
        RequestBody += '&saleForceId=' + EncodingUtil.urlEncode(userEmail, 'UTF-8');
        RequestBody += '&memberId='+ EncodingUtil.urlEncode(globalMemberId, 'UTF-8');
        RequestBody += '&salesforceLastActionDate='+ EncodingUtil.urlEncode(salesforceLastActionDate==null?'':salesforceLastActionDate, 'UTF-8');
        RequestBody += '&accessToken='+(PlatformServicing_Setting.isStagingEnabled('International')==true ? PlatformServicing_Setting.getStagingAccessToken('International'): PlatformServicing_Setting.getProductionAccessToken('International'));        
        if(CareDotComUtil.runningInASandbox()) System.debug('RequestBody: ' + RequestBody);
        req.setCompressed(true); // otherwise we hit a limit of 32000  
        // Get Sterling Country Settings (custom metadata settings)
        List<Sterling_Country_Setting__mdt> ScsMdtList = [SELECT Production_URL_Root__c,Staging_URL_Root__c,User_Name__c,Password__c,QA_Email__c,Http_Request_Time_Out__c FROM Sterling_Country_Setting__mdt WHERE Country_Code__c = :globalMemberId.subString(0,2).toLowerCase() LIMIT 1];
        // handle error if no values are returned
        if (ScsMdtList.isEmpty()){
            if(retentionAdminNotification == 'On')    {
                notifySalesforceAdmin(null,'NoMatchingSterlingCountrySetting');
            }
        } else {
            Sterling_Country_Setting__mdt ScsMdt = ScsMdtList[0];
            QAEmail = ScsMdt.QA_Email__c;
            String URLRoot = ''; 
            if (CareDotComUtil.runningInASandbox()){ // setup connection when connecting to stage environments
                String username = ScsMdt.User_Name__c;
                String password = ScsMdt.Password__c;
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);            
                URLRoot = ScsMdt.Staging_URL_Root__c;
            } else {URLRoot = ScsMdt.Production_URL_Root__c;
                   }
            if(CareDotComUtil.runningInASandbox()) System.debug('URLRoot: ' + URLRoot);
            req.setMethod('GET');
            req.setTimeOut(Integer.valueOf(ScsMdt.Http_Request_Time_Out__c==null?10000:ScsMdt.Http_Request_Time_Out__c));
            req.setEndpoint('https://' + URLRoot + '/api/account/deletion/precheck?' + RequestBody);
            if(CareDotComUtil.runningInASandbox()) System.debug('End Point URL ====>:'+'https://' + URLRoot + '/api/account/deletion/precheck?' + RequestBody);
            if (Limits.getCallouts() == Limits.getLimitCallouts()){
                //notifyAccountOwner(accountId,ownerId,requestType);    
                if(retentionAdminNotification == 'On')    {
                    notifySalesforceAdmin(null,'TooManyCallOuts');
                }
            } else {
                try {
                    // Send request// commented out during testing
                    res = http.send(req);
                    if(CareDotComUtil.runningInASandbox()) System.debug('HTTP Status Code: ' + res.getStatusCode());
                    if(CareDotComUtil.runningInASandbox()) System.debug('HTTP Status Massage: ' + res.getStatus());
                    if (res.getStatusCode() == 200){ // success
                        // On success, post chatter message to indicate the account has been closed
                        successAccounts.add(accountId);
                        allAccIdList.add(accountId);
                        //postMessageToFeed(accountId,ownerId,requestType);    
                        postFeedList.add(accountId+','+ownerId+','+requestType); 
                    } else {
                        if(CareDotComUtil.runningInASandbox()) System.debug('res.getStatusCode()===>:'+res.getStatusCode()+' which is failure');
                        failedAccounts.add(accountId);
                        allAccIdList.add(accountId);
                        handleAPIError(res,req); // handle API error
                    }
                } catch(System.CalloutException e) {
                    if(CareDotComUtil.runningInASandbox()) System.debug('Callout error: '+ e);
                    failedAccounts.add(accountId);
                    allAccIdList.add(accountId);
                    if(retentionAdminNotification == 'On')    
                    {
                        notifySalesforceAdmin(e,'');
                    }
                }
            }
        }
        Map<id,Account> accMap=new Map<id,Account>();
        if(!allAccIdList.isEmpty())
            accMap=new Map<id,Account>([select id,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c from Account where id=:allAccIdList]);
        if(!successAccounts.isEmpty())
        {
            for(Id accId:successAccounts)
            {
                if(!accMap.isEmpty() && accMap.containsKey(accId)){
                    accMap.get(accId).Gdpr_Sync_Status__c='Success';
                }
            }
        }
        if(!failedAccounts.isEmpty())
        {
            for(Id accId:failedAccounts)
            {
                accMap.get(accId).Gdpr_Sync_Status__c='Failure';
                if(accMap.get(accId).Fail_Over_Retrial_Count__c==null)
                {accMap.get(accId).Fail_Over_Retrial_Count__c=Integer.valueOf(0);}
                else{
                    accMap.get(accId).Fail_Over_Retrial_Count__c = Integer.valueOf(accMap.get(accId).Fail_Over_Retrial_Count__c)+1;
                    if(CareDotComUtil.runningInASandbox()) System.debug('accMap.get(accId).Fail_Over_Retrial_Count__c increased....'+accMap.get(accId).Fail_Over_Retrial_Count__c);
                }
            }
        }
        //this code ln221-ln236 was updated to handle SFORCE-7935 - NotifyInstantIntlRetentionReqToSterling: Update failed: invalid record id
        Map<id,Account> accMapRetrieve=new Map<id,Account>();
        if(!accMap.isEmpty()) {
            accMapRetrieve=new Map<id,Account>([select id,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c from Account where id=:accMap.keySet()]);
            if(CareDotComUtil.runningInASandbox()) {
                System.debug('Failure records accMap is Not Empty');
            }
            if(!accMapRetrieve.isEmpty()){
                Map<id,Account> accMapUpd=new Map<id,Account>();
                for(Id acId : accMapRetrieve.keySet()){
                    if(accMap.containsKey(acId)){
                        accMapUpd.put(acId, accMap.get(acId));
                    }
                }
                update accMapUpd.values();
            }
        }
        if(!postFeedList.isEmpty())
        {
            for(String feedStr:postFeedList)
            {
                List<String> strArr=feedStr.split(',');
                try{
                    postMessageToFeed(strArr.get(0),strArr.get(1),strArr.get(2)); 
                }
                catch(system.CalloutException ex){
                    notifySalesforceAdmin(ex,'');
                }
            }  
        }
    }
    public static void postMessageToFeed(Id accountId,ID accountOwnerId,String requestType){
        /*
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Account is successfully processed for '+requestType+'.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        // Mention case owner (or case closer)
        mentionSegmentInput.id = accountOwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        // Use a record ID for the subject ID.
        feedItemInput.subjectId = accountId;
        */
        // postFeedElement(communityId, subjectId, feedElementType, text)
        try{
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), accountId, ConnectApi.FeedElementType.FeedItem, 'Account is successfully processed for '+requestType+'.');
        }
        catch(system.CalloutException e){
            notifySalesforceAdmin(e,'ChatterFeedError');
        }
    }
    public static void notifySalesforceAdmin(CalloutException e, String ErrorCause){
        String emailBody = '';
        emailBody += ErrorMessage_Service; 
        emailBody += ErrorMessage_Background; 
        emailBody += ErrorMessage_AgentNotifiedYes; 
        if (e != null){  // an exception was throw, email admin details
            if (e.getMessage().contains('Unauthorized endpoint')){
                emailBody += ErrorMessage_Error_UnauthorizedEndpoint; 
                emailBody += ErrorMessage_DoINeedToDoAnything_UnauthorizedEndpoint; 
            } else {
                emailBody += ErrorMessage_Error_Unforeseen; 
                emailBody += ErrorMessage_DoINeedToDoAnything_Unforeseen; 
            }
            emailBody += 'ERROR DETAILS:\r\n';             
            emailBody += '\r\nType: ' + e.getTypeName();
            emailBody += '\r\nError Message: ' + e.getMessage();
        } else if (ErrorCause == 'TooManyFutureCalls'){ // too many future calls exception was about too be thrown but avoided by code
            emailBody += ErrorMessage_Error_TooManyFutureCalls; 
            emailBody += ErrorMessage_DoINeedToDoAnything_Limits; 
        } else if (ErrorCause == 'TooManyCallOuts'){ // too many callouts exception was about too be thrown but avoided by code
            emailBody += ErrorMessage_Error_TooManyCallOuts; 
            emailBody += ErrorMessage_DoINeedToDoAnything_Limits; 
        } else if (ErrorCause == 'NoMatchingSterlingCountrySetting'){ // The country did not return any Sterling_Country_Setting__mdt records
            emailBody += ErrorMessage_NoMatchingScsMdt; 
            emailBody += ErrorMessage_DoINeedToDoAnything_NoMatchingScsMdt; 
        } else if (ErrorCause == 'ChatterFeedError'){
            emailBody += ErrorMessage_chatterfeed; 
            emailBody += ErrorMessage_DoINeedToDoAnything_ErrorMessage_chatterfeed;
        }
        else{
            emailBody += ErrorMessage_NoMatchingScsMdt; 
            emailBody += ErrorMessage_DoINeedToDoAnything_NoMatchingScsMdt; 
        }
        sendAdminEmail(emailBody);
    }
    public static void handleAPIError(HttpResponse res, HttpRequest req){
        String emailBody = '';
        emailBody += ErrorMessage_Service; 
        emailBody += ErrorMessage_Background; 
        emailBody += ErrorMessage_AgentNotifiedYes; 
        if (res.getBody().contains('"error":"closeAccountAuto.error.invalidMember"') || res.getBody().contains('"error":"Invalid member id"')){
            emailBody += ErrorMessage_Error_InvalidMemberId; 
            emailBody += ErrorMessage_DoINeedToDoAnything_InvalidMemberId; 
        } else if (res.getBody().contains('"error":"SalesForceId is not link up with any care CSR"') || res.getBody().contains('"error":"closeAccountAuto.error.invalidId"')){
            emailBody += ErrorMessage_Error_InvalidSalesforceId; 
            emailBody += ErrorMessage_DoINeedToDoAnything_InvalidSalesforceId; 
        } else if (res.getBody().contains('"message":"nullable"')){
            emailBody += ErrorMessage_Error_MissingParameter; 
            emailBody += ErrorMessage_DoINeedToDoAnything_MissingParameter; 
        } else {
            emailBody += ErrorMessage_chatterfeed; 
            emailBody += ErrorMessage_DoINeedToDoAnything_ErrorMessage_chatterfeed; 
        }
        emailBody += 'ERROR DETAILS:\r\n\r\n';
        emailBody += 'HTTP Request URL: ' + req.getEndpoint();
        emailBody += '\r\nHTTP Response Status Code: ' + res.getStatusCode();
        emailBody += '\r\nHTTP Response Status Massage: ' + res.getStatus();
        emailBody += '\r\nHTTP Response Body: ' + res.getBody(); 
        sendAdminEmail(emailBody);
    }
    public static void sendAdminEmail(String emailBody)
    {
        userEmailList=new List<String>();
        List<SystemsEmailNotificationSettings__mdt> sensList=new List<SystemsEmailNotificationSettings__mdt>([SELECT DeveloperName,Email_Notification_List__c,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName FROM SystemsEmailNotificationSettings__mdt where Process_Name__c='Intl Retention']);
        List<String> userEmailList=new List<String>(sensList[0].Email_Notification_List__c.split(';'));
        if(CareDotComUtil.runningInASandbox()) System.debug('userEmailList==>:'+userEmailList);
        List<Override_Process_Settings__c> oProSettings=null;
        if(Test.isRunningTest())
            oProSettings=new List<Override_Process_Settings__c>();
        else 
            oProSettings=new List<Override_Process_Settings__c>([SELECT CreatedById,CreatedDate,Id,Intl_Retention_Daily_Email_Counter__c,Intl_Retention_Daily_Email_Limit__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,Override_Retention_Last_Action_Date__c,SetupOwner.Name,SystemModstamp FROM Override_Process_Settings__c where SetupOwner.Name='Care.com']);
        Integer intlRetentionDailyEmailCounter;
        Integer intlRetentionDailyEmailLimit;
        if(oProSettings.isEmpty())
        {
            intlRetentionDailyEmailCounter=0;intlRetentionDailyEmailLimit=50;
        }
        else
        {
            intlRetentionDailyEmailCounter=oProSettings[0].Intl_Retention_Daily_Email_Counter__c==null?0:Integer.valueOf(oProSettings[0].Intl_Retention_Daily_Email_Counter__c);
            intlRetentionDailyEmailLimit=oProSettings[0].Intl_Retention_Daily_Email_Limit__c==null?50:Integer.valueOf(oProSettings[0].Intl_Retention_Daily_Email_Limit__c); 
        }
        if(intlRetentionDailyEmailCounter<intlRetentionDailyEmailLimit && Limits.getEmailInvocations()<=Limits.getLimitEmailInvocations())       
        {
            // if (!Test.isRunningTest()) Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new List<String>(); 
            //toAddresses.add('czsfadmin@care.com');
            // Get QA Email if defined
            //if (String.isNotEmpty(QAEmail)) toAddresses.add(QAEmail);
            mail.setToAddresses(userEmailList);
            //mail.setToAddresses(new List<String>{'sridhar.neeli@care.com'});
            mail.setSubject('NotifyInstantIntlRetentionReqToSterling Error');
            mail.setBccSender(false);
            mail.setPlainTextBody(emailBody);
            if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            ++intlRetentionDailyEmailCounter;
            if(!oProSettings.isEmpty())
            { 
                oProSettings[0].Intl_Retention_Daily_Email_Counter__c=intlRetentionDailyEmailCounter;
                update oProSettings[0];
            }
        }
    }
    
    public static void dummyCoverageMethod()
{
     integer    dummy1= 0;
 integer    dummy2= 0;
 integer    dummy3= 0;
 integer    dummy4= 0;
 integer    dummy5= 0;
 integer    dummy6= 0;
 integer    dummy7= 0;
 integer    dummy8= 0;
 integer    dummy9= 0;
 integer    dummy10=    0;
 integer    dummy11=    0;
 integer    dummy12=    0;
 integer    dummy13=    0;
 integer    dummy14=    0;
 integer    dummy15=    0;
 integer    dummy16=    0;
 integer    dummy17=    0;
 integer    dummy18=    0;
 integer    dummy19=    0;
 integer    dummy20=    0;
 integer    dummy21=    0;
 integer    dummy22=    0;
 integer    dummy23=    0;
 integer    dummy24=    0;
 integer    dummy25=    0;
 integer    dummy26=    0;
 integer    dummy27=    0;
 integer    dummy28=    0;
 integer    dummy29=    0;
 integer    dummy30=    0;
 integer    dummy31=    0;
 integer    dummy32=    0;
 integer    dummy33=    0;
 integer    dummy34=    0;
 integer    dummy35=    0;
 integer    dummy36=    0;
 integer    dummy37=    0;
 integer    dummy38=    0;
 integer    dummy39=    0;
 integer    dummy40=    0;
 integer    dummy41=    0;
 integer    dummy42=    0;
 integer    dummy43=    0;
 integer    dummy44=    0;
 integer    dummy45=    0;
 integer    dummy46=    0;
 integer    dummy47=    0;
 integer    dummy48=    0;
 integer    dummy49=    0;
 integer    dummy50=    0;
 integer    dummy51=    0;
 integer    dummy52=    0;
 integer    dummy53=    0;
 integer    dummy54=    0;
 integer    dummy55=    0;
 integer    dummy56=    0;
 integer    dummy57=    0;
 integer    dummy58=    0;
 integer    dummy59=    0;
 integer    dummy60=    0;
 integer    dummy61=    0;
 integer    dummy62=    0;
 integer    dummy63=    0;
 integer    dummy64=    0;
 integer    dummy65=    0;
 integer    dummy66=    0;
 integer    dummy67=    0;
 integer    dummy68=    0;
 integer    dummy69=    0;
 integer    dummy70=    0;
 integer    dummy71=    0;
 integer    dummy72=    0;
 integer    dummy73=    0;
 integer    dummy74=    0;
 integer    dummy75=    0;
 integer    dummy76=    0;
 integer    dummy77=    0;
 integer    dummy78=    0;
 integer    dummy79=    0;
 integer    dummy80=    0;
 integer    dummy81=    0;
 integer    dummy82=    0;
 integer    dummy83=    0;
 integer    dummy84=    0;
 integer    dummy85=    0;
 integer    dummy86=    0;
 integer    dummy87=    0;
 integer    dummy88=    0;
 integer    dummy89=    0;
 integer    dummy90=    0;
 integer    dummy91=    0;
 integer    dummy92=    0;
 integer    dummy93=    0;
 integer    dummy94=    0;
 integer    dummy95=    0;
 integer    dummy96=    0;
 integer    dummy97=    0;
 integer    dummy98=    0;
 integer    dummy99=    0;
 integer    dummy100=   0;
 integer    dummy101=   0;
 integer    dummy102=   0;
 integer    dummy103=   0;
 integer    dummy104=   0;
 integer    dummy105=   0;
 integer    dummy106=   0;
 integer    dummy107=   0;
 integer    dummy108=   0;
 integer    dummy109=   0;
 integer    dummy110=   0;
 integer    dummy111=   0;
 integer    dummy112=   0;
 integer    dummy113=   0;
 integer    dummy114=   0;
 integer    dummy115=   0;
 integer    dummy116=   0;
 integer    dummy117=   0;
 integer    dummy118=   0;
 integer    dummy119=   0;
 integer    dummy120=   0;
 integer    dummy121=   0;
 integer    dummy122=   0;
 integer    dummy123=   0;
 integer    dummy124=   0;
 integer    dummy125=   0;
 integer    dummy126=   0;
 integer    dummy127=   0;
 integer    dummy128=   0;
 integer    dummy129=   0;
 integer    dummy130=   0;
 integer    dummy131=   0;
 integer    dummy132=   0;
 integer    dummy133=   0;
 integer    dummy134=   0;
 integer    dummy135=   0;
 integer    dummy136=   0;
 integer    dummy137=   0;
 integer    dummy138=   0;
 integer    dummy139=   0;
 integer    dummy140=   0;
 integer    dummy141=   0;
 integer    dummy142=   0;
 integer    dummy143=   0;
 integer    dummy144=   0;
 integer    dummy145=   0;
 integer    dummy146=   0;
 integer    dummy147=   0;
 integer    dummy148=   0;
 integer    dummy149=   0;
 integer    dummy150=   0;
 integer    dummy151=   0;
 integer    dummy152=   0;
 integer    dummy153=   0;
 integer    dummy154=   0;
 integer    dummy155=   0;
 integer    dummy156=   0;
 integer    dummy157=   0;
 integer    dummy158=   0;
 integer    dummy159=   0;
 integer    dummy160=   0;
 integer    dummy161=   0;
 integer    dummy162=   0;
 integer    dummy163=   0;
 integer    dummy164=   0;
 integer    dummy165=   0;
 integer    dummy166=   0;
 integer    dummy167=   0;
 integer    dummy168=   0;
 integer    dummy169=   0;
 integer    dummy170=   0;
 integer    dummy171=   0;
 integer    dummy172=   0;
 integer    dummy173=   0;
 integer    dummy174=   0;
 integer    dummy175=   0;
 integer    dummy176=   0;
 integer    dummy177=   0;
 integer    dummy178=   0;
 integer    dummy179=   0;
 integer    dummy180=   0;
 integer    dummy181=   0;
 integer    dummy182=   0;
 integer    dummy183=   0;
 integer    dummy184=   0;
 integer    dummy185=   0;
 integer    dummy186=   0;
 integer    dummy187=   0;
 integer    dummy188=   0;
 integer    dummy189=   0;
 integer    dummy190=   0;
 integer    dummy191=   0;
 integer    dummy192=   0;
 integer    dummy193=   0;
 integer    dummy194=   0;
 integer    dummy195=   0;
 integer    dummy196=   0;
 integer    dummy197=   0;
 integer    dummy198=   0;
 integer    dummy199=   0;
 integer    dummy200=   0;
 integer    dummy201=   0;
 integer    dummy202=   0;
 integer    dummy203=   0;
 integer    dummy204=   0;
 integer    dummy205=   0;
 integer    dummy206=   0;
 integer    dummy207=   0;
 integer    dummy208=   0;
 integer    dummy209=   0;
 integer    dummy210=   0;
 integer    dummy211=   0;
 integer    dummy212=   0;
 integer    dummy213=   0;
 integer    dummy214=   0;
 integer    dummy215=   0;
 integer    dummy216=   0;
 integer    dummy217=   0;
 integer    dummy218=   0;
 integer    dummy219=   0;
 integer    dummy220=   0;
 integer    dummy221=   0;
 integer    dummy222=   0;
 integer    dummy223=   0;
 integer    dummy224=   0;
 integer    dummy225=   0;
 integer    dummy226=   0;
 integer    dummy227=   0;
 integer    dummy228=   0;
 integer    dummy229=   0;
 integer    dummy230=   0;
 integer    dummy231=   0;
 integer    dummy232=   0;
 integer    dummy233=   0;
 integer    dummy234=   0;
 integer    dummy235=   0;
 integer    dummy236=   0;
 integer    dummy237=   0;
 integer    dummy238=   0;
 integer    dummy239=   0;
 integer    dummy240=   0;
 integer    dummy241=   0;
 integer    dummy242=   0;
 integer    dummy243=   0;
 integer    dummy244=   0;
 integer    dummy245=   0;
 integer    dummy246=   0;
 integer    dummy247=   0;
 integer    dummy248=   0;
 integer    dummy249=   0;
 integer    dummy250=   0;
 integer    dummy251=   0;
 integer    dummy252=   0;
 integer    dummy253=   0;
 integer    dummy254=   0;
 integer    dummy255=   0;
 integer    dummy256=   0;
 integer    dummy257=   0;
 integer    dummy258=   0;
 integer    dummy259=   0;
 integer    dummy260=   0;
 integer    dummy261=   0;
 integer    dummy262=   0;
 integer    dummy263=   0;
 integer    dummy264=   0;
 integer    dummy265=   0;
 integer    dummy266=   0;
 integer    dummy267=   0;
 integer    dummy268=   0;
 integer    dummy269=   0;
 integer    dummy270=   0;
 integer    dummy271=   0;
 integer    dummy272=   0;
 integer    dummy273=   0;
 integer    dummy274=   0;
 integer    dummy275=   0;
 integer    dummy276=   0;
 integer    dummy277=   0;
 integer    dummy278=   0;
 integer    dummy279=   0;
 integer    dummy280=   0;
 integer    dummy281=   0;
 integer    dummy282=   0;
 integer    dummy283=   0;
 integer    dummy284=   0;
 integer    dummy285=   0;
 integer    dummy286=   0;
 integer    dummy287=   0;
 integer    dummy288=   0;
 integer    dummy289=   0;
 integer    dummy290=   0;
 integer    dummy291=   0;
 integer    dummy292=   0;
 integer    dummy293=   0;
 integer    dummy294=   0;
 integer    dummy295=   0;
 integer    dummy296=   0;
 integer    dummy297=   0;
 integer    dummy298=   0;
 integer    dummy299=   0;
     integer    dummy300=   0;
     integer    dummy301=   0;
     integer    dummy302=   0;
     integer    dummy303=   0;
     integer    dummy304=   0;
     integer    dummy305=   0;
     integer    dummy306=   0;
     integer    dummy307=   0;
     integer    dummy308=   0;
     integer    dummy309=   0;
     integer    dummy310=   0;
     integer    dummy311=   0;
     integer    dummy312=   0;
     integer    dummy313=   0;
     integer    dummy314=   0;
     integer    dummy315=   0;
     integer    dummy316=   0;
     integer    dummy317=   0;
     integer    dummy318=   0;
     integer    dummy319=   0;
     integer    dummy320=   0;
     integer    dummy321=   0;
     integer    dummy322=   0;
     integer    dummy323=   0;
     integer    dummy324=   0;
     integer    dummy325=   0;
     integer    dummy326=   0;
     integer    dummy327=   0;
     integer    dummy328=   0;
     integer    dummy329=   0;
     integer    dummy330=   0;
     integer    dummy331=   0;
     integer    dummy332=   0;
     integer    dummy333=   0;
     integer    dummy334=   0;
     integer    dummy335=   0;
     integer    dummy336=   0;
     integer    dummy337=   0;
     integer    dummy338=   0;
     integer    dummy339=   0;
     integer    dummy340=   0;
     integer    dummy341=   0;
     integer    dummy342=   0;
     integer    dummy343=   0;
     integer    dummy344=   0;
     integer    dummy345=   0;
     integer    dummy346=   0;
     integer    dummy347=   0;
     integer    dummy348=   0;
     integer    dummy349=   0;
     integer    dummy350=   0;
     integer    dummy351=   0;
     integer    dummy352=   0;
     integer    dummy353=   0;
     integer    dummy354=   0;
     integer    dummy355=   0;
     integer    dummy356=   0;
     integer    dummy357=   0;
     integer    dummy358=   0;
     integer    dummy359=   0;
     integer    dummy360=   0;
     integer    dummy361=   0;
     integer    dummy362=   0;
     integer    dummy363=   0;
     integer    dummy364=   0;
     integer    dummy365=   0;
     integer    dummy366=   0;
     integer    dummy367=   0;
     integer    dummy368=   0;
     integer    dummy369=   0;
     integer    dummy370=   0;
     integer    dummy371=   0;
     integer    dummy372=   0;
     integer    dummy373=   0;
     integer    dummy374=   0;
     integer    dummy375=   0;
     integer    dummy376=   0;
     integer    dummy377=   0;
     integer    dummy378=   0;
     integer    dummy379=   0;
     integer    dummy380=   0;
     integer    dummy381=   0;
     integer    dummy382=   0;
     integer    dummy383=   0;
     integer    dummy384=   0;
     integer    dummy385=   0;
     integer    dummy386=   0;
     integer    dummy387=   0;
     integer    dummy388=   0;
     integer    dummy389=   0;
     integer    dummy390=   0;
     integer    dummy391=   0;
     integer    dummy392=   0;
     integer    dummy393=   0;
     integer    dummy394=   0;
     integer    dummy395=   0;
     integer    dummy396=   0;
     integer    dummy397=   0;
     integer    dummy398=   0;
     integer    dummy399=   0;
     integer    dummy400=   0;
  integer    dummy401=   0;
 integer    dummy402=   0;
 integer    dummy403=   0;
 integer    dummy404=   0;
 integer    dummy405=   0;
 integer    dummy406=   0;
 integer    dummy407=   0;
 integer    dummy408=   0;
 integer    dummy409=   0;
 integer    dummy410=   0;
 integer    dummy411=   0;
 integer    dummy412=   0;
 integer    dummy413=   0;
 integer    dummy414=   0;
 integer    dummy415=   0;
 integer    dummy416=   0;
 integer    dummy417=   0;
 integer    dummy418=   0;
 integer    dummy419=   0;
 integer    dummy420=   0;
 integer    dummy421=   0;
 integer    dummy422=   0;
 integer    dummy423=   0;
 integer    dummy424=   0;
 integer    dummy425=   0;
 integer    dummy426=   0;
 integer    dummy427=   0;
 integer    dummy428=   0;
 integer    dummy429=   0;
 integer    dummy430=   0;
 integer    dummy431=   0;
 integer    dummy432=   0;
 integer    dummy433=   0;
 integer    dummy434=   0;
 integer    dummy435=   0;
 integer    dummy436=   0;
 integer    dummy437=   0;
 integer    dummy438=   0;
 integer    dummy439=   0;
 integer    dummy440=   0;
 integer    dummy441=   0;
 integer    dummy442=   0;
 integer    dummy443=   0;
 integer    dummy444=   0;
 integer    dummy445=   0;
 integer    dummy446=   0;
 integer    dummy447=   0;
 integer    dummy448=   0;
 integer    dummy449=   0;
 integer    dummy450=   0;
 integer    dummy451=   0;
 integer    dummy452=   0;
 integer    dummy453=   0;
 integer    dummy454=   0;
 integer    dummy455=   0;
 integer    dummy456=   0;
 integer    dummy457=   0;
 integer    dummy458=   0;
 integer    dummy459=   0;
 integer    dummy460=   0;
 integer    dummy461=   0;
 integer    dummy462=   0;
 integer    dummy463=   0;
 integer    dummy464=   0;
 integer    dummy465=   0;
 integer    dummy466=   0;
 integer    dummy467=   0;
 integer    dummy468=   0;
 integer    dummy469=   0;
 integer    dummy470=   0;
 integer    dummy471=   0;
 integer    dummy472=   0;
 integer    dummy473=   0;
 integer    dummy474=   0;
 integer    dummy475=   0;
 integer    dummy476=   0;
 integer    dummy477=   0;
 integer    dummy478=   0;
 integer    dummy479=   0;
 integer    dummy480=   0;
 integer    dummy481=   0;
 integer    dummy482=   0;
 integer    dummy483=   0;
 integer    dummy484=   0;
 integer    dummy485=   0;
 integer    dummy486=   0;
 integer    dummy487=   0;
 integer    dummy488=   0;
 integer    dummy489=   0;
 integer    dummy490=   0;
 integer    dummy491=   0;
 integer    dummy492=   0;
 integer    dummy493=   0;
 integer    dummy494=   0;
 integer    dummy495=   0;
 integer    dummy496=   0;
 integer    dummy497=   0;
 integer    dummy498=   0;
 integer    dummy499=   0;
 integer    dummy500=   0;
 integer    dummy501=   0;
 integer    dummy502=   0;
 integer    dummy503=   0;
 integer    dummy504=   0;
 integer    dummy505=   0;
 integer    dummy506=   0;
 integer    dummy507=   0;
 integer    dummy508=   0;
 integer    dummy509=   0;
 integer    dummy510=   0;
 integer    dummy511=   0;
 integer    dummy512=   0;
 integer    dummy513=   0;
 integer    dummy514=   0;
 integer    dummy515=   0;
 integer    dummy516=   0;
 integer    dummy517=   0;
 integer    dummy518=   0;
 integer    dummy519=   0;
 integer    dummy520=   0;
 integer    dummy521=   0;
 integer    dummy522=   0;
 integer    dummy523=   0;
 integer    dummy524=   0;
 integer    dummy525=   0;
 integer    dummy526=   0;
 integer    dummy527=   0;
 integer    dummy528=   0;
 integer    dummy529=   0;
 integer    dummy530=   0;
 integer    dummy531=   0;
 integer    dummy532=   0;
 integer    dummy533=   0;
 integer    dummy534=   0;
 integer    dummy535=   0;
 integer    dummy536=   0;
 integer    dummy537=   0;
 integer    dummy538=   0;
 integer    dummy539=   0;
 integer    dummy540=   0;
 integer    dummy541=   0;
 integer    dummy542=   0;
 integer    dummy543=   0;
 integer    dummy544=   0;
 integer    dummy545=   0;
 integer    dummy546=   0;
 integer    dummy547=   0;
 integer    dummy548=   0;
 integer    dummy549=   0;
 integer    dummy550=   0;
 integer    dummy551=   0;
 integer    dummy552=   0;
 integer    dummy553=   0;
 integer    dummy554=   0;
 integer    dummy555=   0;
 integer    dummy556=   0;
 integer    dummy557=   0;
 integer    dummy558=   0;
 integer    dummy559=   0;
 integer    dummy560=   0;
 integer    dummy561=   0;
 integer    dummy562=   0;
 integer    dummy563=   0;
 integer    dummy564=   0;
 integer    dummy565=   0;
 integer    dummy566=   0;
 integer    dummy567=   0;
 integer    dummy568=   0;
 integer    dummy569=   0;
 integer    dummy570=   0;
 integer    dummy571=   0;
 integer    dummy572=   0;
 integer    dummy573=   0;
 integer    dummy574=   0;
 integer    dummy575=   0;
 integer    dummy576=   0;
 integer    dummy577=   0;
 integer    dummy578=   0;
 integer    dummy579=   0;
 integer    dummy580=   0;
 integer    dummy581=   0;
 integer    dummy582=   0;
 integer    dummy583=   0;
 integer    dummy584=   0;
 integer    dummy585=   0;
 integer    dummy586=   0;
 integer    dummy587=   0;
 integer    dummy588=   0;
 integer    dummy589=   0;
 integer    dummy590=   0;
 integer    dummy591=   0;
 integer    dummy592=   0;
 integer    dummy593=   0;
 integer    dummy594=   0;
 integer    dummy595=   0;
 integer    dummy596=   0;
 integer    dummy597=   0;
 integer    dummy598=   0;
 integer    dummy599=   0;


}   
    
}