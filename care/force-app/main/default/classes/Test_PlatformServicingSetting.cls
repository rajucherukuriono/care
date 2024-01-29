/*
** _________________________________________________________________________________
** Created by:    Mohammed Ashwaq
** Developer:     Mohammed Ashwaq[mohammed.ashwaq@care.com]
** Modified Date:  05.11.2020
** =================================================================================
** Description: 
**             test class for PlatformServicing_Setting
** _______________________________________________________________________________
*/
@isTest
public class Test_PlatformServicingSetting {
    Public static string PLATFORM_INTERNATIONAL = 'International';
    Public static string PLATFORM_US = 'US';
    
	@testSetup static void setup(){
        List<Platform_Servicing_Setting__mdt> ddrList= new List<Platform_Servicing_Setting__mdt>();
        
        Platform_Servicing_Setting__mdt pss1 = new Platform_Servicing_Setting__mdt();
        pss1.Platform__c ='International';
        pss1.Staging_API_Key__c='testAPItaging';
        pss1.Production_Access_Token__c='testTokenProduction';
        pss1.Production_API_Key__c='testApiKeyProduction';
        pss1.Staging_Access_Token__c='testTokenStaging';
        pss1.Is_Staging__c =true;
        pss1.Description__c ='Test description';
        //if(pss1!=null)
        //insert pss1;
	}
    

    @isTest 
    Public static void testgetplatformservcing(){
        List<Platform_Servicing_Setting__mdt> pltSrvcLst=[SELECT Platform__c,
                                                Staging_API_Key__c,
                                                Production_Access_Token__c,
                                                Production_API_Key__c,
                                                Staging_Access_Token__c,
                                                Is_Staging__c, Description__c
                                                FROM Platform_Servicing_Setting__mdt];
        
        pltSrvcLst[0].Platform__c ='International';
        pltSrvcLst[0].Staging_API_Key__c ='testStagingAPIkeyInternational';
        Test.startTest();
        PlatformServicing_Setting.getSetting(PLATFORM_INTERNATIONAL);
        PlatformServicing_Setting.getProductionAccessToken(PLATFORM_INTERNATIONAL);
        PlatformServicing_Setting.getStagingAccessToken(PLATFORM_INTERNATIONAL);
        PlatformServicing_Setting.getProductionAPIKey(PLATFORM_INTERNATIONAL);
        PlatformServicing_Setting.getStagingAPIKey(PLATFORM_INTERNATIONAL);
        PlatformServicing_Setting.isStagingEnabled(PLATFORM_INTERNATIONAL);
        Test.stopTest();
    
        System.assertEquals(PLATFORM_INTERNATIONAL, pltSrvcLst[0].Platform__c, 'No Match Found');
    }
}