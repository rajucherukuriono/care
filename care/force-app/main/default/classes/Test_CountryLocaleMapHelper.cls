//Created By: Mohammed Ashwaq
//Test class for CountryLocaleMapHelper
//Created Date: 10/11/2020
@isTest
private class Test_CountryLocaleMapHelper {
    Public static String  csOrigin='Email - AU';
    Public static String  countryCode='AU';
    Public static string locale = 'en_AU';
    static testMethod void CountryLocaleMapHelperTest () {
        Test.startTest();
        List<Sterling_Country_Setting__mdt> CountryLocaleMap = [SELECT Country_Code__c, Case_Origin__c, Language__c, Locale__c, Production_URL_Root__c,Staging_URL_Root__c,User_Name__c,Password__c,QA_Email__c FROM Sterling_Country_Setting__mdt];
        CountryLocaleMapHelper.getSettingByCaseOrigin(csOrigin);
        CountryLocaleMapHelper.getSettingByCaseOrigin(null);
        CountryLocaleMapHelper.getSettingByCountry(countryCode);
        CountryLocaleMapHelper.getSettingByCountry(null);
        CountryLocaleMapHelper.getLanguageFromLocale(locale);
        CountryLocaleMapHelper.getLanguageFromLocale(null);
        CountryLocaleMapHelper.getCaseOriginFromLocale(locale);
        CountryLocaleMapHelper.getCaseOriginFromLocale(null);
        CountryLocaleMapHelper.getQAEmail(locale);
        CountryLocaleMapHelper.getQAEmail(null);
        CountryLocaleMapHelper.getSettingByLocale(locale);
        CountryLocaleMapHelper.getSettingByLocale(null);
        Test.stopTest();
    }
}