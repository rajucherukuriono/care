/*
** _________________________________________________________________________________
** Created by:    Mohammed Ashwaq
** Developer:     Mohammed Ashwaq[mohammed.ashwaq@care.com]
** Modified Date:  30.10.2020
** =================================================================================
** Description: 
**             Utility Class which access Sterling Service integration data
** _______________________________________________________________________________
*/
public class PlatformServicing_Setting {
    
    private static List<Platform_Servicing_Setting__mdt> platformservices = [SELECT Platform__c,
                                                                              Staging_API_Key__c,
                                                                              Production_Access_Token__c,
                                                                              Production_API_Key__c,
                                                                              Staging_Access_Token__c,
																			  Is_Staging__c, Description__c
                                                                  			  FROM Platform_Servicing_Setting__mdt]; 

	
    public static Platform_Servicing_Setting__mdt  getSetting(String Platform){
        for (Platform_Servicing_Setting__mdt anyPlatform : platformservices){
            if (anyPlatform.Platform__c == Platform) return anyPlatform;
        }
        return null;
    }
    
    public static String getProductionAccessToken(String Platform){
        String ProductionAccessToken = (getSetting(Platform).Production_Access_Token__c != null) ? getSetting(Platform).Production_Access_Token__c : '';
        return ProductionAccessToken;
    }

    public static String getStagingAccessToken(String Platform){
        String StagingAccessToken = (getSetting(Platform).Staging_Access_Token__c != null) ? getSetting(Platform).Staging_Access_Token__c : '';
        return StagingAccessToken;
    }
    
    public static String getProductionAPIKey(String Platform){
        String ProductionAPIKey = (getSetting(Platform).Production_API_Key__c != null) ? getSetting(Platform).Production_API_Key__c : '';
        return ProductionAPIKey;
    }
    
    public static String getStagingAPIKey(String Platform){
        String StagingAPIKey = (getSetting(Platform).Staging_API_Key__c != null) ? getSetting(Platform).Staging_API_Key__c : '';
        return StagingAPIKey;
    }
        
    public static Boolean isStagingEnabled(String Platform){
        Boolean isStaging = getSetting(Platform).Is_Staging__c;
        return isStaging;
    }
    
}