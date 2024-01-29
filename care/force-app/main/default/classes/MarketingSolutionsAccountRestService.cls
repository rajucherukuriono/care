/***************************************************************************************************
   Name        : MarketingSolutionsAccountRestService
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: 01/14/2022
   Description : REST Service for creating new Marketing Solutions Accounts

   Changes     : 01/14/2022 - John Wrightsman (Class Created)
               : 02/24/2022 - John Wrightsman  Moved most logic to a @TestVisible internal method. Added UnitTestFlags so I could get 100% code
                                               coverage to workaround code coverage issues that exist in production.
               : 26/04/2022 - NESS             Creating logic for inserting or updating opportunities

*****************************************************************************************************/
@RestResource(urlMapping='/MarketingSolutionsAccount/*')
global class MarketingSolutionsAccountRestService {

    static private Map<String, String> primaryVerticalMap { get; set; } 
    
    global class PostAccountRequest {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String businessName { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String zipCode { get; set; }
        public String leadSource { get; set; }
        public String sourceCampaign { get; set; }
        public String careType { get; set; }
		public String source { get; set; }
        public String gclid { get; set; }
    }

    public class CustomException extends Exception {}

    public class AccountResult {
        public Id accountId { get; set; }
        public Boolean isDuplicate { get; set; }

        public AccountResult(Id accountId, Boolean isDuplicate) {
            this.accountId = accountId;
            this.isDuplicate = isDuplicate;
        }
    }

    public class UnitTestFlags {
        public Boolean throwNoUsersException { get; set; }
        public Boolean throwHttp500Status { get; set; }
        public Boolean throwUnableToCreateAccount { get; set; }

        public UnitTestFlags() {
            this.throwNoUsersException = false;
            this.throwHttp500Status = false;
            this.throwUnableToCreateAccount = false;
        }
    }

    @HttpPost
    global static void postAccount(PostAccountRequest account) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        postAccountInternal(account, req, res, new UnitTestFlags());
         System.debug('$$$ Account $$' +account);
         System.debug('### Request ##' +req);
         System.debug('*** Account **' +res);
        
    }

    @TestVisible
    private static void postAccountInternal(PostAccountRequest account, RestRequest req, RestResponse res, UnitTestFlags utFlags) {
        String url;
        Integer httpStatus;
        String responseBody;
        String requestBody;
        try {
            if (utFlags.throwHttp500Status) {
                throw new CustomException('Unit Test 500 Status exception');
            }

            // Variables used for logging
            url = req.requestURI;
            httpStatus = 200;
            responseBody = '';
            requestBody = JSON.serialize(account);

            // Retrieve custom settings
            //List<User> users;
            //Marketing_Solutions_Lead_Intake_Setting__mdt setting = [SELECT Owner_Username__c, Task_Subject__c, Email_Intro__c FROM Marketing_Solutions_Lead_Intake_Setting__mdt LIMIT 1];
            //String configuredOwnerUsername = Test.isRunningTest() ? 'test_ms_configowner@caredotcom.com' : setting.Owner_Username__c;
            //if (configuredOwnerUsername != null) {
            //    users = [SELECT Id FROM User WHERE username = :configuredOwnerUsername];
            //}
            Id managerId;
            Id opportunityId;
            String vertical= getVerticalValue(account.careType);
            Round_robin__c roundRobin=getRoundRobinsWithRoundRobinMembers(vertical);
            Id configuredOwnerId = roundRobin.Round_Robin_Members__r.isEmpty() ? roundRobin.Default_User__c : roundRobin.Round_Robin_Members__r[0].User__c;
            Boolean doCount=true;

            // Create or get account (if it's found by the duplicate rule)
            AccountResult result = createOrGetExistingAccount(account, configuredOwnerId, utFlags);
            if (result != null) {
                if (result.isDuplicate) {
                    Boolean updateAccount=false;
                    Boolean updateopp=false;
                    Boolean accountRole=false;
                    Account accountRecord = [SELECT OwnerId, Owner.UserRole.Name, Owner.isActive FROM Account WHERE Id = :result.accountId];
                    List<Task> futureTasks = [SELECT Id FROM Task WHERE WhatId = :result.accountId AND ActivityDate > :Date.today()];
                    List<Task> recentOutboundCallTasks = [SELECT Id FROM Task WHERE WhatId = :result.accountId AND CreatedDate = LAST_N_DAYS:7 AND (Subject LIKE '%Outbound to%' OR Subject = 'Call')];
                    List<Opportunity> foundOpps = new List<Opportunity>([SELECT Id, Primary_Vertical__c, OwnerID, Owner.UserRole.Name, Owner.isActive FROM Opportunity WHERE AccountId =:result.accountId AND isClosed != true]);
                    List<RoundRobinRoles__c> lstRoundRobinRoles = RoundRobinRoles__c.getall().values();

                    // Determine who should be assigned the task and be notified:
                    // The default is to send the task/notification/email to the configured owner id unless
                    // the account owner is a Marketing Solutions Rep and the account either has future task
                    // or recent outbound call tasks.
                    for (RoundRobinRoles__c setting : lstRoundRobinRoles) {
                        if(accountRecord.Owner.UserRole.Name != null &&
                           accountRecord.Owner.UserRole.Name.startsWith(setting.Role_Name_Phrase__c)) accountRole=true;
                    }
                    if (accountRole) {
                        if (futureTasks.size() > 0 || recentOutboundCallTasks.size() > 0) {
                            managerId = getManagerId(accountRecord.Owner.UserRole.Name);
                        }
                        if(roundRobin.Is_Primary_Vertical__c){
                            if (foundOpps.isEmpty()){
                                configuredOwnerId = accountRecord.OwnerId;
                                doCount=false;
                            }else {
                                Boolean oppRole=false;
                                for (RoundRobinRoles__c setting : lstRoundRobinRoles) {
                                    if(foundOpps[0].Owner.UserRole.Name.startsWith(setting.Role_Name_Phrase__c)) oppRole=true;
                                }
                                if(oppRole){
                                    configuredOwnerId = accountRecord.OwnerId;
                                    doCount=false;
                                }
                            }
                        }
                    }else{
                        accountRecord.OwnerId= configuredOwnerId;
                        updateAccount=true;
                    }
                    if (foundOpps.isEmpty()) {
                        // Opportunity doesn't exist or it is closed 
                        opportunityId=createOpportunity(result.accountId, account, configuredOwnerId, roundRobin);

                    } else if(roundRobin.Is_Primary_Vertical__c){
                        // Opportunity exists
                        Opportunity opp = foundOpps[0];
                        if( opp.OwnerId != accountRecord.OwnerId && opp.Owner.isActive){
                            Boolean oppRole=false;
                            for (RoundRobinRoles__c setting : lstRoundRobinRoles) {
                                if(opp.Owner.UserRole.Name.startsWith(setting.Role_Name_Phrase__c)) oppRole=true;
                            }
                            if(oppRole){
                                accountRecord.OwnerId=opp.OwnerId;
                                configuredOwnerId=opp.OwnerId;
                                doCount=false;
                                updateAccount=true;
                            }
                            else {
                                accountRecord.OwnerId =configuredOwnerId;
                                updateAccount=true;
                                opp.OwnerId= configuredOwnerId;
                                updateopp=true;
                            }
                        }
                        if( vertical != null &&
                            opp.Primary_Vertical__c != vertical){
                            opp.Primary_Vertical__c = vertical;
                            opp.Name= account.businessName + ' - ' +vertical;
                            opp.OwnerId= opp.OwnerId != configuredOwnerId ? configuredOwnerId : opp.OwnerId;
                            updateopp=true;
                        }
                        opportunityId=opp.Id;
                        if(updateopp) update opp;
                    }
                    if(updateAccount) update accountRecord;
                }else{
                    opportunityId=createOpportunity(result.accountId, account, configuredOwnerId, roundRobin);
                    User tempOwner=[SELECT ID, UserRole.Name FROM User WHERE ID =: configuredOwnerId];
                    managerId = getManagerId(tempOwner.UserRole.Name);
                }
                createTask(result.accountId, account, configuredOwnerId, opportunityId, roundRobin);
                createNotification(result.accountId, configuredOwnerId, roundRobin.Task_Subject__c);
                if(doCount) updateRoundRobinMember(roundRobin);
                if (roundRobin.Is_Primary_Vertical__c) sendEmailAlert(configuredOwnerId, managerId, result.accountId, roundRobin.Task_Subject__c, roundRobin.Email_Intro__c);
            }
        } catch(Exception e) {
            httpStatus = 500;
            responseBody = e.getMessage() + '; ' + e.getStackTraceString();
            res.statusCode = httpStatus;
            res.responseBody = Blob.valueOf(responseBody);
        }

        logRestServiceCall(url, requestBody, responseBody, httpStatus);
    }

    @TestVisible
    private static Id getManagerId(String roleName) {
        Id managerId = null;
        if(roleName == null) roleName = '';

        List<User> managers = [SELECT Id FROM User WHERE UserRole.Name = :roleName.replace('Rep', 'Manager')];
        if (managers.size() > 0) {
            managerId = managers[0].Id;
        }

        return managerId;
    }

    @TestVisible
    private static AccountResult createOrGetExistingAccount(PostAccountRequest accountRequest, Id ownerUserId, UnitTestFlags utFlags) {
        Id MarketingSolutionsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
        // Check to see if the incoming value already exists as a valid picklist value
        Set<String> primaryVertical= new Set<String>();
        for(Schema.PicklistEntry entry : Account.Primary_Vertical__c.getDescribe().getPicklistValues()) {
            if(entry.isActive()){
                primaryVertical.add(entry.getValue());
            }
        }
        // Try inserting account.

        Database.SaveResult saveResult = Database.insert(new Account(
            OwnerId = ownerUserId,
            RecordTypeId = MarketingSolutionsRecordTypeId,
            MS_Account_Type__c = 'Inbound',
            Name = accountRequest.businessName,
            phone = accountRequest.phone,
            BillingPostalCode = accountRequest.zipCode,
            MS_Primary_Contact_Name__c = accountRequest.firstName + ' ' + accountRequest.lastName,
            Alternate_Email__c = accountRequest.email,
            AccountSource = (accountRequest.leadSource=='claim_profile')?'Claimed Profile':'Form Submission',
            MS_Care_Type__c = accountRequest.careType,
            Primary_Vertical__c = primaryVertical.contains(getVerticalValue(accountRequest.careType)) ? getVerticalValue(accountRequest.careType) : null
        ), false);

        // If it's not successful due to duplicate, get the duplicate record and return the id
        if (saveResult.isSuccess()) {
            return new AccountResult(saveResult.getId(), false);
        } else {            
            for (Database.Error error : saveResult.getErrors()) {
                System.debug('DATABASE::The following error has occurred during database update.');                    
                System.debug(error.getStatusCode() + ': ' + error.getMessage());
                System.debug('Fields that affected this error: ' + error.getFields()); 
                Boolean isDupError = error instanceof Database.DuplicateError;
                if (utFlags.throwUnableToCreateAccount == false && isDupError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    Datacloud.MatchResult matchResult = duplicateResult.getMatchResults()[0];
                    Datacloud.MatchRecord matchRecord = matchResult.getMatchRecords()[0];
                    Account accountRecord = (Account) matchRecord.getRecord();
                    return new AccountResult(accountRecord.Id, true);
                }
            }
        }

        throw new CustomException('Unable to find existing account or create new account.');
    }
    
    @TestVisible
    private static ID createOpportunity(Id accountId, PostAccountRequest account, Id Owner, Round_Robin__c roundRobin) {
        Id createdOppId;
        if (roundRobin.Is_Primary_Vertical__c) {
            Id oppRT;
            if(roundRobin.Opportunity_Record_Type__c != null){
                oppRT=  SObjectType.Opportunity.getRecordTypeInfosByName().get(roundRobin.Opportunity_Record_Type__c).getRecordTypeId();
            }else   throw new CustomException('Missing record Type on Round Robin object');
            String vertical= getVerticalValue(account.careType);
            Integer numOfDays = roundRobin.Number_of_Days_to_Close__c == null ? 7 :Integer.valueOf(roundRobin.Number_of_Days_to_Close__c);
            Database.SaveResult saveResult = Database.insert(new Opportunity(   Name =  account.businessName + ' - ' +vertical,
                                                                                StageName = roundRobin.Opportunity_StageName__c == null ? 'Qualified' : roundRobin.Opportunity_StageName__c,
                                                                                Priority__c = roundRobin.Opportunity_Priority__c == null ? 'High' : roundRobin.Opportunity_Priority__c,
                                                                                RecordTypeId = oppRT,
                                                                                CloseDate = Date.today().addDays(numOfDays),
                                                                                Primary_Vertical__c=vertical,
                                                                                AccountId= accountId,
                                                                                GCLID__c= account.gclid,
                                                                                LeadSource= 'Form Submission',
                                                                                OwnerId= Owner));
            createdOppId = saveResult.getId();
            return createdOppId;
        }
        return createdOppId;
    }

    @TestVisible
    private static void createTask(Id accountId, 
                                   PostAccountRequest accountRequest, 
                                   Id ownerId, 
                                   Id opportunityId, 
                                   Round_Robin__c roundRobin) {
        if (roundRobin.Create_Task__c) {
            insert new Task(
                OwnerId = ownerId,
                Subject = roundRobin.Task_Subject__c,
                Status = 'Open',
                Priority = 'High',
                ActivityDate = Date.today() + Integer.valueOf(roundRobin.Due_in_Number_of_Days__c),
                WhatId = roundRobin.Create_Opportunity__c ? opportunityId : accountId,
                MS_SEM_Campaign__c = accountRequest.sourceCampaign,
                MS_Lead_Source__c = accountRequest.leadSource
            );
        }
    }

    @TestVisible
    private static void createNotification(Id accountId, Id userId, String subject) {
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Marketing_Solutions_Inbound_Account_Notification'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(subject);
        notification.setBody(subject);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(accountId);

        // Send notification
        notification.send(new Set<String>{ userId });
    }

    @TestVisible
    public static void sendEmailAlert(Id ownerId, Id managerId, Id accountId, String subject, String emailIntro) {
        String accountLink = URL.getOrgDomainUrl().toExternalForm() + '/' + accountId;

        String htmlBody = emailIntro + '<br/><br/><a href="' + accountLink + '">' + accountLink + '</a>';
        String plainTextBody = emailIntro + '\n\n' + accountLink;

        List<String> emailAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        List<Id> userIds = new List<Id>{ ownerId };
        if (managerId != null) {
            userIds.add(managerId);
            
        }               
        for (User u : [SELECT email FROM User WHERE Id IN :userIds]) {          
            if (u.Id == managerId) {
                ccAddresses.add(u.email);
                
            } else {
                emailAddresses.add(u.email);
            }
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject(subject);
        message.setHtmlBody(htmlBody);
        message.setPlainTextBody(plainTextBody);
        message.setToAddresses(emailAddresses);
        message.setCcAddresses(ccAddresses);
        message.setOptOutPolicy('SEND');
        System.debug('******'+ message);
        Messaging.SendEmailResult[] results;
        results = Test.isRunningTest() ? null : Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message });
    }

    @TestVisible
    private static String getVerticalValue(String careType) {
        // Skip the rest of the logic if careType is null
        if (careType == null) {
            return null;
        }

        // Populate primaryVerticalMap if it's currently null
        if (primaryVerticalMap == null) {
            primaryVerticalMap = new Map<String, String>();
            for (Marketing_Solutions_Account_Mapping__mdt mapping : [
                SELECT Incoming_Value__c, Salesforce_Value__c
                FROM Marketing_Solutions_Account_Mapping__mdt
                WHERE Field_API_Name__c = 'Primary_Vertical__c'
            ]) {
                primaryVerticalMap.put(mapping.Incoming_Value__c.toLowerCase(), mapping.Salesforce_Value__c);
            }
        }

        // Check to see if the incoming value is mapped to a valid picklist value
        if (primaryVerticalMap.containsKey(careType.toLowerCase())) {
            return primaryVerticalMap.get(careType.toLowerCase());
        }

        // Return null if value is not mapped
        return null;
    }
    
    /**
    * @description Logs the service call to MS_Account_Rest_Service_Log__c
    * @param url (String) - The url
    * @param requestBody (String) - The request JSON body
    * @param responseBody (String) - The response
    * @param httpStatus (Integer) - The http status returned in the response
    */
    private static void logRestServiceCall(String url, String requestBody, String responseBody, Integer httpStatus) {
        insert new MS_Account_Rest_Service_Log__c(
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }
    
    @TestVisible
    private static Round_Robin__c getRoundRobinsWithRoundRobinMembers(String vertical) {
        List<Round_Robin__c> lstRoundRobins = new List<Round_Robin__c>([SELECT  Id, 
                                                                        		Create_Task__c,
                                                                        		Create_Opportunity__c,
                                                                                Vertical__c, 
                                                                                Opportunity_Priority__c, 
                                                                                Opportunity_StageName__c, 
                                                                                Opportunity_Record_Type__c,
                                                                                Default_User__c,
                                                                                Default_Round_Robin__c,
                                                                                Number_of_Days_to_Close__c,
                                                                                Task_Subject__c,
                                                                                Email_Intro__c,
                                                                                Due_in_Number_of_Days__c,
                                                                                Is_Primary_Vertical__c,
                                                                                (   SELECT  Id,
                                                                                            User__c,
                                                                                            Task_Counter__c
                                                                                    FROM    Round_Robin_Members__r
                                                                                 	WHERE	Active__c = true AND User__r.IsActive = true
                                                                                    ORDER BY Task_Counter__c asc   ) 
                                                                        FROM    Round_Robin__c 
                                                                        WHERE   (Vertical__c includes(:vertical) OR Default_Round_Robin__c = true) 
                                                                        AND     Active__c = true]);
        
        if (lstRoundRobins.isEmpty()) {
            throw new CustomException('No Round Robin record found, please create default Round Robin or Round Robin for specific careType');
        } else {
            Round_Robin__c defaultRR;
            List<Round_Robin__c> lstSpecRoundRobins= new List<Round_Robin__c>();
            for(Round_Robin__c rr : lstRoundRobins){
                if(rr.Default_Round_Robin__c == true) defaultRR = rr;
                else lstSpecRoundRobins.add(rr);
            }
            if(lstSpecRoundRobins.isEmpty()) return defaultRR;
            if(lstSpecRoundRobins.size() > 1) throw new CustomException('Multiple Round Robins found for this CareType');
            else return lstSpecRoundRobins[0];
        }
    }

    @TestVisible
    private static void updateRoundRobinMember(Round_Robin__c roundRobin) {
        if(roundRobin != null &&
           !roundRobin.Round_Robin_Members__r.isEmpty()){
            Round_Robin_Member__c member= roundRobin.Round_Robin_Members__r[0];
            member.Task_Counter__c++;
            update member;
        }
    }
}