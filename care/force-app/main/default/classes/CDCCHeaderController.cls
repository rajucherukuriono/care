public without sharing class CDCCHeaderController {
    public class CommunitySettings {
        @AuraEnabled public String communityName { get; set; }
        @AuraEnabled public Boolean showForFamiliesLink { get; set; }
        @AuraEnabled public Boolean showForCaregiversLink { get; set; }
        @AuraEnabled public Boolean showForBusinessesLink { get; set; }
        @AuraEnabled public Boolean showForMarketingSolutionsLink { get; set; }
        @AuraEnabled public Boolean showForRecruitingSolutionsLink { get; set; }
        @AuraEnabled public String forFamiliesLinkUrl { get; set; }
        @AuraEnabled public String forCaregiversLinkUrl { get; set; }
        @AuraEnabled public String forBusinessesLinkUrl { get; set; }
        @AuraEnabled public String forMarketingSolutionsLinkUrl { get; set; }
        @AuraEnabled public String forRecruitingSolutionsLinkUrl { get; set; }
        @AuraEnabled public String logInLinkUrl { get; set; }
        @AuraEnabled public String joinNowLinkUrl { get; set; }
        @AuraEnabled public String upgradeLinkUrl { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static CommunitySettings getCommunitySettings() {
        Id networkId = Test.isRunningTest() ? [SELECT Id FROM Network WHERE UrlPathPrefix = 'families' LIMIT 1].Id : Network.getNetworkId();
        List<Community_Setting__mdt> results = [
            SELECT DeveloperName, Show_For_Families_Link__c, Show_For_Caregivers_Link__c,             Show_For_Businesses_Link__c, Show_For_Marketing_Solutions_Link__c, Show_For_Recruiting_Solutions_Link__c, For_Families_Link_Url__c, For_Caregivers_Link_Url__c, For_Businesses_Link_Url__c, For_Marketing_Solutions_Link__c, For_Recruiting_Solutions_Link__c,Log_In_Link_Url__c, Join_Now_Link_Url__c, Upgrade_Link_Url__c
            FROM Community_Setting__mdt
            WHERE Community_ID__c = :networkId
        ];
        CommunitySettings settings = new CommunitySettings();
        if (results.size() > 0) {
            settings.communityName = results[0].DeveloperName;
            settings.showForFamiliesLink = results[0].Show_For_Families_Link__c;
            settings.showForCaregiversLink = results[0].Show_For_Caregivers_Link__c;
            settings.showForBusinessesLink = results[0].Show_For_Businesses_Link__c;
            settings.showForMarketingSolutionsLink = results[0].Show_For_Marketing_Solutions_Link__c;
            settings.showForRecruitingSolutionsLink = results[0].Show_For_Recruiting_Solutions_Link__c;
            settings.forFamiliesLinkUrl = results[0].For_Families_Link_Url__c;
            settings.forCaregiversLinkUrl = results[0].For_Caregivers_Link_Url__c;
            settings.forBusinessesLinkUrl = results[0].For_Businesses_Link_Url__c;
            settings.forMarketingSolutionsLinkUrl = results[0].For_Marketing_Solutions_Link__c;
            settings.forRecruitingSolutionsLinkUrl = results[0].For_Recruiting_Solutions_Link__c;
            settings.logInLinkUrl = results[0].Log_In_Link_Url__c;
            settings.joinNowLinkUrl = results[0].Join_Now_Link_Url__c;
            settings.upgradeLinkUrl = results[0].Upgrade_Link_Url__c;
        }
        return settings;
    }
}