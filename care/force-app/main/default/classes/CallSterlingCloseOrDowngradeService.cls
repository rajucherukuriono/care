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

public class CallSterlingCloseOrDowngradeService {
    private static String QAEmail = '';
    public static Integer testException{get;set;}
    @future (callout=true)
    public static void sendRequest(ID CaseOwnerId, ID MemberContactId, ID CaseId, String caseReason, String secCaseReason,String ActionTime,String MemberEmail, String AgentEmail, String MemberLocale, String MemberCountry, Boolean SendCancellationEmail, String MemberId) {

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        // Define request body
        String RequestBody = '';
        RequestBody += 'actionPerformed=';
        if (caseReason == 'Cancel') RequestBody += 'Close';
        else if (caseReason == 'Downgrade') RequestBody += 'Downgrade';
        
        // handle seccasereason/actionReason here
        RequestBody += '&actionReason=';
        RequestBody += secCaseReason;
        RequestBody += '&whenAction=' + EncodingUtil.urlEncode((ActionTime != null) ? ActionTime : '', 'UTF-8');
        //RequestBody += '&memberEmail=' + EncodingUtil.urlEncode((MemberEmail != null) ? MemberEmail : '', 'UTF-8');
        RequestBody += '&saleForceId=' + EncodingUtil.urlEncode((AgentEmail != null) ? AgentEmail : '', 'UTF-8');
        RequestBody += '&country=' + EncodingUtil.urlEncode((MemberCountry != null) ? MemberCountry : '', 'UTF-8');        
        RequestBody += '&sendEmail='+ SendCancellationEmail;        
        RequestBody += '&memberId='+ EncodingUtil.urlEncode((MemberId != null) ? MemberId : '', 'UTF-8');
		RequestBody += '&accessToken='+(PlatformServicing_Setting.isStagingEnabled('International')==true ? PlatformServicing_Setting.getStagingAccessToken('International'): PlatformServicing_Setting.getProductionAccessToken('International'));
       
        system.debug('RequestBody: ' + RequestBody);
        req.setCompressed(true); // otherwise we hit a limit of 32000  
        
        // Get Sterling Country Settings (custom metadata settings)
        // 2018-05-22: As part of the ODS project, this code was transitioned from a query on settings to the use of this helper method
        Sterling_Country_Setting__mdt ScsMdt = CountryLocaleMapHelper.getSettingByCountry(MemberCountry);

        // handle error if no values are returned
        if (ScsMdt == null){
            notifyCaseOwner(CaseOwnerId, MemberContactId, CaseId);
            notifySalesforceAdmin(null,'NoMatchingSterlingCountrySetting');
        } else {
            QAEmail = ScsMdt.QA_Email__c;
            
            String URLRoot = ''; 
            if (CareDotComUtil.runningInASandbox()){ // setup connection when connecting to stage environments
                String username = ScsMdt.User_Name__c;
                String password = ScsMdt.Password__c;
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);            
            
                URLRoot = ScsMdt.Staging_URL_Root__c;
    
            } else {
                URLRoot = ScsMdt.Production_URL_Root__c;
            }
            system.debug('URLRoot: ' + URLRoot);
            req.setHeader('Care-Apikey',(PlatformServicing_Setting.isStagingEnabled('International')==true ? PlatformServicing_Setting.getStagingAPIKey('International'): PlatformServicing_Setting.getProductionAPIKey('International')));
            req.setMethod('GET');
            req.setEndpoint('https://' + URLRoot + '/api/account/closeOrDowngrade?' + RequestBody);
                    if(CareDotComUtil.runningInASandbox())
            system.debug('End Point URL ====>:'+'https://' + URLRoot + '/api/account/closeOrDowngrade?' + RequestBody);
          
            if (Limits.getCallouts() == Limits.getLimitCallouts()){
                notifyCaseOwner(CaseOwnerId, MemberContactId, CaseId);
                notifySalesforceAdmin(null,'TooManyCallOuts');
            } else {
                try {
                    if(Test.isRunningTest())
                    {
                    ExceptionExample.testCustomException(testException);
                    }
                    // Send request// commented out during testing
                    res = http.send(req);
                    System.Debug('HTTP Status Code: ' + res.getStatusCode());
                    System.Debug('HTTP Status Massage: ' + res.getStatus());
                    
                    if (res.getStatusCode() == 200){ // success
                        // On success, post chatter message to indicate the account has been closed
                        postMessageToFeed(CaseOwnerId, MemberContactId, CaseId);    
                    } else {
                        handleAPIError(res,req); // handle API error
                        notifyCaseOwner(CaseOwnerId, MemberContactId, CaseId);
                    }
                    
                } catch(Exception e) {
                    System.debug('Callout error: '+ e);
                    notifyCaseOwner(CaseOwnerId, MemberContactId, CaseId);
                    notifySalesforceAdmin(e,'');
                }
            }
        }
    }

    public static void postMessageToFeed(ID CaseOwnerId, ID MemberContactId, ID CaseId){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Account successfully downgraded or closed.  ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        // Mention case owner (or case closer)
        mentionSegmentInput.id = (String.valueof(CaseOwnerId).left(3) != '00G') ? CaseOwnerId : UserInfo.getUserId();
        messageBodyInput.messageSegments.add(mentionSegmentInput);
 
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
 
        // Use a record ID for the subject ID.
        feedItemInput.subjectId = CaseId;
 
        // I'm not running on test because chatter requires that tests see all data
        if (!Test.isRunningTest()) ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
    }

    public static void notifyCaseOwner(ID CaseOwnerId, ID MemberContactId, ID CaseId){
        Task t = new Task();
        t.Subject = 'Automated Downgrade (or Close) failed';
        t.Description = 'Account Downgrade (or Close) of Case for member failed, please check on this manually in Smithers!';
        t.ReminderDateTime = Date.today() + 1;
        t.ActivityDate = Date.today() + 1;
        t.WhoId = MemberContactId;
        t.WhatId = CaseId;
        // if the case is owned by a queue, assign the task to user who closed the case
        t.ownerId = (String.valueof(CaseOwnerId).left(3) != '00G') ? CaseOwnerId : UserInfo.getUserId(); 
        t.Status = 'Open';
        insert t;
        
    }

    public static void notifySalesforceAdmin(Exception e, String ErrorCause){
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
        }
// 
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
            emailBody += ErrorMessage_Error_Unforeseen; 
            emailBody += ErrorMessage_DoINeedToDoAnything_Unforeseen; 
        }
        
        emailBody += 'ERROR DETAILS:\r\n\r\n';
        emailBody += 'HTTP Request URL: ' + req.getEndpoint();
        emailBody += '\r\nHTTP Response Status Code: ' + res.getStatusCode();
        emailBody += '\r\nHTTP Response Status Massage: ' + res.getStatus();
        emailBody += '\r\nHTTP Response Body: ' + res.getBody(); 
        sendAdminEmail(emailBody);
    }

    public static void sendAdminEmail(String emailBody){
        if (!Test.isRunningTest()) Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>(); 
        toAddresses.add('czsfadmin@care.com');

        // Get QA Email if defined
        if (String.isNotEmpty(QAEmail)) toAddresses.add(QAEmail);
        
        mail.setToAddresses(toAddresses);
        mail.setSubject('CallSterlingCloseorDowngradeService Error');
        mail.setBccSender(false);
        mail.setPlainTextBody(emailBody);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static string ErrorMessage_Service = 'SERVICE: The CallSterlingCloseorDowngradeService class has thrown an error.\r\n\r\n';
    public static string ErrorMessage_Background = 'BACKGROUND: This class class the International API whenever a Member Care Agent is trying to cancel a member\'s account via Salesforce.\r\n\r\n';
    public static string ErrorMessage_AgentNotifiedYes = 'HAS AGENT BEEN NOTIFIED: Yes, a task was created in Salesforce telling the user to close the case manually.\r\n\r\n';
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
    
}