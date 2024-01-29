public class OnDemandSync_ErrorMonitor {
    private static Integer HoursToQueryForCases = -24; // kept as a negative for use with addhours()
    private static final String ODS_ERROR_MONITOR_ROOT = 'ODS Error Monitor';

	public static void InvokeErrorMonitor(String Platform){
		ODS_Error_Monitor__c OdsEMSetting = InitializeCustomSettings(Platform);
		
        if (isItSafeToInvokeErrorMonitor(Platform,OdsEMSetting)) ErrorMonitor(Platform);
    }

    @future 
    public static void ErrorMonitor(String Platform){
		ODS_Error_Monitor__c OdsEMSetting = InitializeCustomSettings(Platform);

        String CompletedCaseQuery = 'SELECT count() FROM Case WHERE Is_ODS_Complete__c = true';
        CompletedCaseQuery +=	    ' AND ODS_Request_Platform__c = \'' + Platform + '\'';
        CompletedCaseQuery += 		' AND ODS_Request_Status__c NOT IN (\'' + OnDemandSync.REQ_STATUS_ERROR_SALESFORCE + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_USPLATFORM + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_INTLPLATFORM + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_UNKNOWN + '\')';
        CompletedCaseQuery += 		' AND CreatedDate > ' + DateTime.now().addHours(HoursToQueryForCases).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if (CareDotComUtil.runningInASandbox()) System.Debug('CompletedCaseQuery: ' + CompletedCaseQuery);
        Decimal CompletedCaseCount = database.countQuery(CompletedCaseQuery);
        
        String ErrorCaseQuery = 'SELECT count() FROM Case WHERE Is_ODS_Complete__c = true';
        ErrorCaseQuery +=	    ' AND ODS_Request_Platform__c = \'' + Platform + '\'';
        ErrorCaseQuery += 		' AND ODS_Request_Status__c IN (\'' + OnDemandSync.REQ_STATUS_ERROR_SALESFORCE + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_USPLATFORM + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_INTLPLATFORM + '\', \'' + OnDemandSync.REQ_STATUS_ERROR_UNKNOWN + '\')';
        ErrorCaseQuery += 		' AND CreatedDate > ' + DateTime.now().addHours(HoursToQueryForCases).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        if (CareDotComUtil.runningInASandbox()) System.Debug('ErrorCaseQuery: ' + ErrorCaseQuery);
        Decimal ErrorCaseCount = database.countQuery(ErrorCaseQuery);
        
        Decimal TotalCaseCount = CompletedCaseCount + ErrorCaseCount;
        Decimal MinCaseForError = OnDemandSync_Settings.getMinCaseForError(Platform);
        Decimal ErrorThreshold = OnDemandSync_Settings.getErrorThreshold(Platform);
        
        if (TotalCaseCount > 0){
            Decimal ErrDivByTotal = ErrorCaseCount / TotalCaseCount;
            Decimal ErrDivByTotalPercent = ErrDivByTotal * 100;
            
            if (CareDotComUtil.runningInASandbox()) System.Debug('MinCaseForError: ' + MinCaseForError);
            if (CareDotComUtil.runningInASandbox()) System.Debug('ErrorThreshold: ' + ErrorThreshold);
            if (CareDotComUtil.runningInASandbox()) System.Debug('ErrorCaseCount: ' + ErrorCaseCount);
            if (CareDotComUtil.runningInASandbox()) System.Debug('TotalCaseCount: ' + TotalCaseCount);
            if (CareDotComUtil.runningInASandbox()) System.Debug('ErrDivByTotal: ' + ErrDivByTotal);
            if (CareDotComUtil.runningInASandbox()) System.Debug('ErrDivByTotalPercent: ' + ErrDivByTotalPercent);
            
            if ((TotalCaseCount > OnDemandSync_Settings.getMinCaseForError(Platform)) && (ErrDivByTotalPercent > ErrorThreshold)){
                SendErrorNotificationEmail(Platform); // Send Notification email
                OdsEMSetting.Last_Error_Notification__c = DateTime.now(); // record last error notification timestamp
            }
        }
        
        OdsEMSetting.Error_Monitor_Last_Run__c = DateTime.now();
        update OdsEMSetting;
    }
    
    public static boolean isItSafeToInvokeErrorMonitor(String Platform, ODS_Error_Monitor__c OdsEMSetting){
        if (OnDemandSync_Settings.getBypassErrorMonitor(Platform) == true) return false;  // because it's been bypassed
		
        if (Limits.getFutureCalls() == Limits.getLimitFutureCalls()) return false; // because future limit is about to be exceeded
        
        if (OdsEMSetting.Error_Monitor_Last_Run__c == null) return true;  // because it's never been run before  

        if (OdsEMSetting.Last_Error_Notification__c != null){ 
            // if an error has been sent, ensure 24h have passed before monitoring again
			Long LastRun = OdsEMSetting.Last_Error_Notification__c.getTime();
            Long Now = DateTime.now().getTime();
            Long GapInHours = (((Now - LastRun) / 1000 ) / 60 / 60);
            if (CareDotComUtil.runningInASandbox()) System.Debug('GapInHours: ' + GapInHours);
            if (GapInHours > OnDemandSync_Settings.getErrorNotificationGap(Platform)) return true;

        } else if (OdsEMSetting.Error_Monitor_Last_Run__c != null){ 
            // if no notifications have been sent, but monitor's been run before, ensure 3 minutes pass before monitoring again
			Long LastRun = OdsEMSetting.Error_Monitor_Last_Run__c.getTime();
            Long Now = DateTime.now().getTime();
            Long GapInMinutes = ((Now - LastRun) / 1000 ) / 60;
            if (CareDotComUtil.runningInASandbox()) System.Debug('GapInMinutes: ' + GapInMinutes);
            if (GapInMinutes > OnDemandSync_Settings.getGapBetweenBatchesInMinutes(Platform)) return true;
        }
        return false;
    }

    public static ODS_Error_Monitor__c InitializeCustomSettings(String Platform){
        String ODS_Error_Monitor_Name = getODSErrorMonitorName(Platform);
        List<ODS_Error_Monitor__c> OdsEMSettings = [SELECT Last_Error_Notification__c,Error_Monitor_Last_Run__c FROM ODS_Error_Monitor__c WHERE NAME = :ODS_Error_Monitor_Name LIMIT 1];
		
		if (CareDotComUtil.runningInASandbox()) System.Debug('OdsEMSettings.isEmpty(): ' + OdsEMSettings.isEmpty());
        if (OdsEMSettings.isEmpty()){
            Database.Insert(new ODS_Error_Monitor__c(Name = ODS_Error_Monitor_Name));	 
            OdsEMSettings = [SELECT Last_Error_Notification__c,Error_Monitor_Last_Run__c FROM ODS_Error_Monitor__c WHERE NAME = :ODS_Error_Monitor_Name LIMIT 1];        
        }
        return OdsEMSettings[0];
    }

    public static String getODSErrorMonitorName(String Platform){
        return ODS_ERROR_MONITOR_ROOT + ' - ' + Platform;
    }

    public static void SendErrorNotificationEmail(String Platform){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>(); 
        toAddresses.add(OnDemandSync_Settings.getErrorNotificationEmail(Platform));
        if (String.isNotEmpty(OnDemandSync_Settings.getErrorNotificationCC(Platform))) toAddresses.add(OnDemandSync_Settings.getErrorNotificationCC(Platform));
        if (CareDotComUtil.runningInASandbox()) System.Debug('toAddresses: ' + toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setBccSender(false);
        String Subject = 'OnDemandSync Error: Error Threshold Exceeded';
        mail.setSubject(Subject);
		String Body = 'OnDemandSync has generated more than '+ OnDemandSync_Settings.getErrorThreshold(Platform) + '% errors in the last ' + String.valueOf( OnDemandSync_Settings.getErrorNotificationGap(Platform)) + ' hours.  Please review the OnDemandSync dashboard for more context.';
        mail.setPlainTextBody(Body);

        if (!Test.isRunningTest()){  // Unit tests can skip these checks
            try {
                Messaging.reserveSingleEmailCapacity(1);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
            } catch (System.Exception e){ // catch all exceptions
 				// Fail gracefully without sending email if we can't send email.
 				// Most likely this error is caused because email deliverability is turned off.
 				// If it's critical to be sure, add more logic.
 				return;
            }
        }
    }
}