public class OnDemandSync_Settings {
    private static List<OnDemandSync_Setting__mdt> OdsSettings = [SELECT Batch_Size__c, Bypass_OnDemand_Sync__c,Production_API_Key__c,
                                                                  Retry_Limit__c,Staging_API_Key__c,Gap_Between_Batches__c, DeveloperName, Platform__c,
                                                                  Bypass_Error_Monitor__c,Error_Threshold__c,Min_Case_For_Error_Notification__c,
                                                                  Error_Notification_Gap__c,Error_Notification_Email__c,Error_Notification_CC__c,
                                                                  Batch_Size_Link_Job__c,Gap_Between_Batches_Link_Job__c
                                                                  FROM OnDemandSync_Setting__mdt]; 

    private static List<ODS_Next_Platform__c> OdsNPSettings = [SELECT Name,Platform__c FROM ODS_Next_Platform__c];

    public static ODS_Next_Platform__c getOdsNPSettings(String ApexClassName){
		if (OdsNPSettings.isEmpty()) InitializeOdsNPSettings();

        for (ODS_Next_Platform__c OdsNextPlatform : OdsNPSettings){
            if (OdsNextPlatform.Name == ApexClassName) return OdsNextPlatform;
        }
    	return null;
    }
    
    public static void InitializeOdsNPSettings(){
		List<ODS_Next_Platform__c> OdsNPSettingsLocal = new List<ODS_Next_Platform__c>();
        ODS_Next_Platform__c OdsNextPlatformHttpBatch = new ODS_Next_Platform__c(Name=OnDemandSync.HTTP_REQUEST_BATCH_CLASS_NAME,Platform__c=Null);
        ODS_Next_Platform__c OdsNextPlatformLinkBatch = new ODS_Next_Platform__c(Name=OnDemandSync.LINK_BATCH_CLASS_NAME,Platform__c=Null);

        OdsNPSettingsLocal.add(OdsNextPlatformHttpBatch);
        OdsNPSettingsLocal.add(OdsNextPlatformLinkBatch);
        insert OdsNPSettingsLocal;  
        OdsNPSettings = OdsNPSettingsLocal;
    }

    public static String getNextPlatform(String ApexClassName){
        String NextPlatform = getOdsNPSettings(ApexClassName).Platform__c;
        return NextPlatform;
    }

    public static void setNextPlatform(String ApexClassName,String Platform){
        ODS_Next_Platform__c OdsNextPlatform = getOdsNPSettings(ApexClassName);
		OdsNextPlatform.Platform__c = Platform;
        update OdsNextPlatform;  
    }
    
    public static void resetNextPlatform(String ApexClassName){
		// when each platform is done, we reset the next platform flag to null; this allows new cases to set the setting as needed
        ODS_Next_Platform__c OdsNextPlatform = getOdsNPSettings(ApexClassName);
		OdsNextPlatform.Platform__c = Null;
        update OdsNextPlatform;  
    }
    
    public static OnDemandSync_Setting__mdt getSetting(String Platform){
        for (OnDemandSync_Setting__mdt OdsSetting : OdsSettings){
            if (OdsSetting.Platform__c == Platform) return OdsSetting;
        }

		// if there is no match, return US Settings
        for (OnDemandSync_Setting__mdt OdsSetting : OdsSettings){
            if (OdsSetting.Platform__c == OnDemandSync.PLATFORM_US) return OdsSetting;
        }
        return null;
    }

    public static boolean getBypassODS(String Platform){
    	// BypassODS is always false during unit tests to allow us to deploy with the Bypass on but also for better test coverage
        boolean BypassODS = (getSetting(Platform).Bypass_OnDemand_Sync__c == null || Test.isRunningTest()) ? false : getSetting(Platform).Bypass_OnDemand_Sync__c;        
        return  BypassODS;
    }

    public static Decimal getRetryLimit(String Platform){
	    Decimal RetryLimit = (getSetting(Platform).Retry_Limit__c != null) ? getSetting(Platform).Retry_Limit__c : 9;
        return RetryLimit;
    }
    
    public static String getStagingAPIKey(String Platform){
        String StagingAPIKey = (getSetting(Platform).Staging_API_Key__c != null) ? getSetting(Platform).Staging_API_Key__c : '';
        return StagingAPIKey;
    }

    public static String getProductionAPIKey(String Platform){
        String ProductionAPIKey = (getSetting(Platform).Production_API_Key__c != null) ? getSetting(Platform).Production_API_Key__c : '';
        return ProductionAPIKey;
    }

    public static Decimal getODSBatchSize(String Platform){
        Decimal ODSBatchSize = (getSetting(Platform).Batch_Size__c != null) ? getSetting(Platform).Batch_Size__c : 75;
        return ODSBatchSize;
    }

    public static Decimal getODSBatchSizeForLinkJob(String Platform){
        Decimal ODSBatchSizeForLinkJob = (getSetting(Platform).Batch_Size_Link_Job__c != null) ? getSetting(Platform).Batch_Size_Link_Job__c : 20;
        return ODSBatchSizeForLinkJob;
    }

    public static Decimal getGapBetweenBatchesInMinutes(String Platform){
        Decimal GapBetweenBatchesInMinutes = (getSetting(Platform).Gap_Between_Batches__c != null) ? getSetting(Platform).Gap_Between_Batches__c : 3;
        return GapBetweenBatchesInMinutes;
    }

    public static Decimal getGapBetweenBatchesInMinutesForLinkJob(String Platform){
        Decimal GapBetweenBatchesInMinutesForLinkJob = (getSetting(Platform).Gap_Between_Batches_Link_Job__c != null) ? getSetting(Platform).Gap_Between_Batches_Link_Job__c : 3;
        return GapBetweenBatchesInMinutesForLinkJob;
    }

    public static boolean getBypassErrorMonitor(string Platform){
    	// BypassErrorMonitor is always false during unit tests to allow us to deploy with the Bypass on but also for better test coverage
        boolean BypassErrorMonitor = (getSetting(Platform).Bypass_Error_Monitor__c == null || Test.isRunningTest()) ? false : getSetting(Platform).Bypass_Error_Monitor__c;
        return BypassErrorMonitor;
    }

    public static Decimal getErrorThreshold(String Platform){
        Decimal ErrorThreshold = (getSetting(Platform).Error_Threshold__c != null) ? getSetting(Platform).Error_Threshold__c : 30;    
        return ErrorThreshold;
    }

    public static Decimal getMinCaseForError(String Platform){
    	// return 0 during tests to get better code coverage
        Decimal MinCaseForError = (getSetting(Platform).Min_Case_For_Error_Notification__c == null || Test.isRunningTest()) ? 0 : getSetting(Platform).Min_Case_For_Error_Notification__c; 
        return MinCaseForError;
    }

    public static Long getErrorNotificationGap(String Platform){
        Long ErrorNotificationGap = (getSetting(Platform).Error_Notification_Gap__c != null) ? Math.roundToLong(getSetting(Platform).Error_Notification_Gap__c) : 24;
        return ErrorNotificationGap;
    }
        
    public static String getErrorNotificationEmail(String Platform){
        String ErrorNotificationEmail = (getSetting(Platform).Error_Notification_Email__c != null) ? getSetting(Platform).Error_Notification_Email__c : 'czsfadmin@care.com';
        return ErrorNotificationEmail;
    }


    public static String getErrorNotificationCC(String Platform){
        String ErrorNotificationCC = (getSetting(Platform).Error_Notification_CC__c != null) ? getSetting(Platform).Error_Notification_CC__c : '';
        return ErrorNotificationCC;
    }
    
}