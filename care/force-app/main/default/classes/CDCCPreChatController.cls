public without sharing class CDCCPreChatController {
    public class CommunitySettings {
        @AuraEnabled public String logInLinkUrl { get; set; }
        @AuraEnabled public String joinNowLinkUrl { get; set; }
        @AuraEnabled public String showEmail { get; set; }
        @AuraEnabled public String showChat { get; set; }
        @AuraEnabled public String showChatLang { get; set; }
        @AuraEnabled public String memberType { get; set; }
        @AuraEnabled public String useArticleWhitelistForWebCases { get; set; }
        @AuraEnabled public String communtiyName { get; set; }
        @AuraEnabled public String communityLabel { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static CommunitySettings getCommunitySettings() {
        // getCommunitySettings is to be shared with the outside world, so it only retuns limited info.
        Id networkId = getNetworkId();
        List<Community_Setting__mdt> results = [
            SELECT Log_In_Link_Url__c, Join_Now_Link_Url__c, Show_Email__c, Show_Chat__c, Show_Chat_Lang__c, Member_Type__c, Use_Article_Whitelist_for_Web_Cases__c, DeveloperName, MasterLabel		
            FROM Community_Setting__mdt
            WHERE Community_ID__c = :networkId
        ];
        CommunitySettings settings = new CommunitySettings();
        if (results.size() > 0) {
            settings.logInLinkUrl = results[0].Log_In_Link_Url__c;
            settings.joinNowLinkUrl = results[0].Join_Now_Link_Url__c;
            settings.showEmail = results[0].Show_Email__c;
            settings.showChat = results[0].Show_Chat__c;
            settings.showChatLang = results[0].Show_Chat_Lang__c;
            settings.memberType = results[0].Member_Type__c;
            settings.useArticleWhitelistForWebCases = results[0].Use_Article_Whitelist_for_Web_Cases__c;
            settings.communtiyName = results[0].DeveloperName;
            settings.communityLabel = results[0].MasterLabel;
        }
        return settings;
    }

    public static Id getNetworkId(){
        Id networkId = Test.isRunningTest() ? [SELECT Community_ID__c FROM Community_Setting__mdt WHERE DeveloperName = 'Marketing_Solutions' LIMIT 1].Community_ID__c : Network.getNetworkId();
        return networkId;
    }

    public static Community_Setting__mdt getCommunitySettingsForInternalUse() {
        // getCommunitySettings is to be shared with the outside world, so it only retuns limited info.
        // This class is intended for internal use, so it returns everything in the CMD.
        Id networkId = getNetworkId();
        List<Community_Setting__mdt> results = [
            SELECT Log_In_Link_Url__c, Join_Now_Link_Url__c, DeveloperName, MasterLabel
            FROM Community_Setting__mdt
            WHERE Community_ID__c = :networkId
        ];
        
        return results[0];
    }

    @AuraEnabled
    public static void createCase(String name, String email, string phone,  String topic, String message, String externalMemberId, String memberUUID, String memberAccountType, String memberType, String articleId, String subject, String locale) {
        try {
            Case c = new Case(
                SuppliedName = name,
                SuppliedEmail = email,
                SuppliedPhone = phone,
                Article_Topic__c = topic,
                Description = message,
                Web_External_Member_ID__c = externalMemberId,
                Web_Member_UUID__c = memberUUID,
                Member_Account_Type__c = memberAccountType,
                Member_Type__c = memberType,
                Article_ID__c = articleId,
                Subject = subject,
                Origin = 'Web'
            );

            // Sends the Case to modifyCase, a helper method designed to make changes for different teams/use cases
            modifyCase(c, locale);

            insert c;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Case modifyCase(Case c, String locale){
        // this method allows us to modify the case with different logic for different teams
        Community_Setting__mdt cmd = getCommunitySettingsForInternalUse();

        // For Marketing SOlutions, we do a couple of things:
        // First: Search for Contacts related to Accounts w/Marketing Solutions Account RTs 
        // Second: Invoke Assignment Rules for the Case (so that admins can control who the owner will be)
        if (cmd.DeveloperName == 'Marketing_Solutions'){
            List<Contact> contacts = [SELECT id,AccountId From Contact WHERE Email =:c.SuppliedEmail AND Account.RecordTypeId = '0125Y0000023W3uQAE' Order By LastModifiedDate DESC LIMIT 1];
            if (!contacts.isEmpty()){
                c.ContactId = contacts[0].id;
                c.AccountId = contacts[0].AccountId;
            }
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.UseDefaultRule = true;
            c.setOptions(dmlOpts);

        }

        if (!locale.endsWithIgnoreCase('us')){ // International Cases get a different record type & pass locale & country
            c.recordTypeId = Test_OnDemandSync.intEmailRtId;
            Sterling_Country_Setting__mdt scscmd = CountryLocaleMapHelper.getSettingByLocale(locale);
            if (scscmd != null){
                c.Member_Country__c	= scscmd.Country_Code__c;
                c.Member_Locale__c = scscmd.Locale__c;
            }
        }
        return c;
    }

    public class ArticleTopic {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String topicName { get; set; }
        @AuraEnabled public Boolean whitelistArticleForWebCases { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static ArticleTopic getArticleTopic(String kavUrlName, String language){
        // Map<String, String> topicInfo = new Map<String, String>{'id' => '','title' => 'Home Page Case','topicName' => 'Using Your Account'};
               
        ArticleTopic topicInfo = new ArticleTopic();
        topicInfo.id = '';
        topicInfo.title = 'Home Page Case';
        topicInfo.topicName = 'Using Your Account';
        topicInfo.whitelistArticleForWebCases = false;

        List<US_Knowledge__DataCategorySelection> dcs = new List<US_Knowledge__DataCategorySelection>();
        if (language == null ) language = 'en_US';
        
        if(String.isBlank(kavUrlName)){
            return topicInfo;
        }

        List<US_Knowledge__kav> kavs = [
            SELECT Id, Title, MasterVersionId, isMasterLanguage, Whitelist_Article_for_Web_Cases__c,
                (
                    SELECT Id, ParentId, DataCategoryGroupName, DataCategoryName
                    FROM DataCategorySelections
                )
            FROM US_Knowledge__kav WHERE UrlName = :kavUrlName AND Language = :language
        ];  

        Map<String,String> dataCategoryNameToLabelMap = DataCategoryGroupStructureHelper.generateDataCategoryNameToLabelMap('KnowledgeArticleVersion');	

        if (!kavs.isEmpty()) {
            topicInfo.id = kavs[0].Id;
            topicInfo.title = kavs[0].Title;
            topicInfo.whitelistArticleForWebCases = kavs[0].Whitelist_Article_for_Web_Cases__c;
            dcs = kavs[0].DataCategorySelections;

            // Data Categories live in the Master Article, so I'll query them from Master Article
            if (!kavs[0].isMasterLanguage){
                US_Knowledge__kav masterArticle = [SELECT Id, (SELECT Id,DataCategoryGroupName, DataCategoryName FROM DataCategorySelections) FROM US_Knowledge__kav WHERE id = :kavs[0].MasterVersionId ];
                dcs = masterArticle.DataCategorySelections;
            }

           if (!dcs.isEmpty()) {
                for (US_Knowledge__DataCategorySelection dc : dcs) {
                    if (dc.DataCategoryGroupName == 'Topic') {
                        topicInfo.topicName = dataCategoryNameToLabelMap.get(dc.DataCategoryName);
                    }
                }
            }
        }

        return topicInfo;
    }

    @AuraEnabled
    public static Map<String, String> sendMemberInfoToODS(String externalMemberId, String memberUUID, String memberType, String locale) {
        if (String.isBlank(memberType) ||  (String.isBlank(externalMemberId) && String.isBlank(memberUUID))) {
            return null;
        }

        String localMemberId = (externalMemberId != null) ? externalMemberId : memberUUID;

        Map<String, String> responseMap = new Map<String, String>();
        String Error;
        try { 
            // This is not the real chat case that gets assigned to the member
            // It is a dummy case used to trigger ODS (becuause ODS requires Cases to work)
            Case dummyCase = new Case(
                SuppliedName = 'Unknown Name',
                SuppliedEmail = getDummyEmail(localMemberId),
                //SuppliedEmail = 'jack@kivosolutions.com',
                Subject = 'User Initiated Chat from Care.com',
                Origin = 'Chat',
                Status = 'New',
                Web_External_Member_Id__c = externalMemberId,
                Web_Member_UUID__c = memberUUID,
                ownerId = OnDemandSync_Instant.CaseAndAccountCreator
            );
            if (locale.endsWithIgnoreCase('us')){
                dummyCase.RecordTypeId = TestUtil.EmailRtId;
                dummyCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_US; // these values are usually set a default values, but dummyCase is never inserted
            } else {
                dummyCase.RecordTypeId = TestUtil.intEmailRtId;
                dummyCase.ODS_Request_Platform__c = OnDemandSync.PLATFORM_INTL;
            }

            Account a = OnDemandSync_Instant.getAccountViaInstantODS(dummyCase, memberType, locale);
            if (a != null){
                dummyCase.AccountId = a.id;
            } else { // we were unable to create account; echo error from passed case object
                Error = dummyCase.ODS_Request_Error__c;
            }

            responseMap.put('AccountId', dummyCase.AccountId);
            responseMap.put('DummyEmail', getDummyEmail(localMemberId));
            responseMap.put('Error', Error);

            return responseMap;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String DummyEmailPrefix = 'dummy';
    public static String DummyEmailSuffix = '@care.com';

    public static String getDummyEmail(String ExternalMemberId){
        String DummyEmail = DummyEmailPrefix + DummyEmailSuffix;
        if (ExternalMemberId != null){
            DummyEmail = DummyEmailPrefix + ExternalMemberId + DummyEmailSuffix;
        }
        return DummyEmail;
    }

    public static Boolean isDummyEmail(String Email){
        if (Email != null && Email.left(5) == DummyEmailPrefix && Email.right(9) == DummyEmailSuffix){
            return true;
        }
        return false;
    }

    

}