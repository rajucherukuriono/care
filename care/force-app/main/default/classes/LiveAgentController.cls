public without sharing class LiveAgentController {
	// This method is invoked by the liveagent Lightning Web Component
	// The method creates an Account via Instant ODS & also creates a chat case
    
    @AuraEnabled(cacheable=false) // methods that use DML statements cannot be cached
    public static Map<String, String> insertChatCase(String ExternalMemberId, String MemberType){
        Map<String, String> responseMap = new Map<String, String>();
        String Error;

        // Standard ODS requires an email address, but we don't know the user's email yet, 
        // so we supply a dummy one here and then update it once we get the user's account record
        String DummyEmailPrefix = (ExternalMemberId != null) ? ExternalMemberId : 'dummy';
        String DummyEmail = DummyEmailPrefix + '@care.com';  
        Case c = new Case(
            SuppliedName = 'Unknown Name',
            SuppliedEmail = DummyEmail,
            Subject = 'User Initiated Chat from Care.com',
            Origin = 'Chat',
            Status = 'New',
            //Web_Member_Id__c = MemberId,
            Web_External_Member_Id__c = ExternalMemberId,
            ODS_Request_Platform__c = OnDemandSync.PLATFORM_US,
            ownerId = OnDemandSync_Instant.CaseAndAccountCreator,
            RecordTypeId = TestUtil.EmailRtId
        );

		if (CareDotComUtil.runningInASandbox()) System.debug('Instant ODS Case (pre-ODS): ' + c);

        Account a = OnDemandSync_Instant.getAccountViaInstantODS(c, MemberType);
        if (a != null){
            c.AccountId = a.id;
            try {
                // now that we have member details from ODS, add them to Case
                c.SuppliedEmail = a.PersonEmail;
                c.SuppliedName = a.FirstName + ' ' + a.LastName;
                insert c;
            } catch (Exception e) { // we were unable to create the case; echo error to user
                Error = e.getMessage();
            }
        } else { // we were unable to create account; echo error from passed case object
            Error = c.ODS_Request_Error__c;
        }

		if (CareDotComUtil.runningInASandbox()) System.debug('Instant ODS Case (post-ODS): ' + c);

        // Get PersonContactId 
        String ContactId = null;
        if (a != null){
            Contact con = [SELECT Id FROM Contact WHERE AccountId=:a.id];
            if (con != null) ContactId = con.id;
        }


        responseMap.put('AccountId', c.AccountId);
        responseMap.put('CaseId', c.id);
        responseMap.put('ContactId', ContactId);
        responseMap.put('Error', Error);
        return responseMap;
    }
}