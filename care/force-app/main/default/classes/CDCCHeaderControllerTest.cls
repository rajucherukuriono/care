@IsTest
private without sharing class CDCCHeaderControllerTest {
    @IsTest
    public static void getCommunitySettingsTest() {
        User siteGuestUser = [SELECT Id FROM User WHERE Name = 'FAQ for Families Site Guest User'];
        System.runAs(siteGuestUser) {
            Test.startTest();
            CDCCHeaderController.CommunitySettings settings = CDCCHeaderController.getCommunitySettings();
            Test.stopTest();
            System.assert(String.isNotBlank(settings.logInLinkUrl));
            System.assert(String.isNotBlank(settings.joinNowLinkUrl));
        }
    }
}