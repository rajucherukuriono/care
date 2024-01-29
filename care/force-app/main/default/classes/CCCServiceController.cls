/****************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 11/06/2020
Description: Apex controller for CCCServiceModule lightning component.
Changes:

*****************************************************************************/
public without sharing class CCCServiceController {
    static private String CLASS_NAME = 'CCCServiceController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String profileName { get; set; }
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public List<Composer_Service__c> composerServiceRecords { get; set; }
        @AuraEnabled public List<String> permittedVerticals { get; set; }

        public ServerResponse() {
            super();
            this.composerServiceRecords = new List<Composer_Service__c>();
        }
    }


    /**
    * @description Retrieves the Service data for an Opportunity
    * @param recordId (String) - The Opportunity record Id
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getServiceData(String recordId) { return getServiceData(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getServiceData(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getServiceData';

        ServerResponse response = new ServerResponse();
        CCCUtils.ServerResponse rUtils = new CCCUtils.ServerResponse();

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Return the Opportunity Record
            rUtils = CCCUtils.getOpportunityRecord(recordId);
            if (rUtils.hasErrors) throw new CCCException(rUtils.message);
            if (rUtils.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            response.opportunityRecord = rUtils.opportunityRecord;

            // Return the active Composer Service records
            response.composerServiceRecords = (List<Composer_Service__c>) CCCQuery.get('Composer_Service__c').equals('Active__c', true).order('Vertical__c ASC, License_Level__c ASC').all();

            // Return user permissions for composer services
            User u = (User) CCCQuery.get('User').field('Profile.Name').equalsId(UserInfo.getUserId()).one();
            response.profileName = u.Profile.Name;
            if (u.Profile.Name == 'Sales Origination Rep') {
                response.permittedVerticals = new List<String>();
                String permittedVerticals = u.Contract_Composer_Permitted_Verticals__c;
                if (permittedVerticals != null) {
                    for (String vertical : permittedVerticals.split(',')) {
                        response.permittedVerticals.add(vertical.trim());
                    }
                }
            }

        } catch(Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Updates the selected Composer Service for an Opportunity
    * @param recordId (String) - The Id of the Opportunity record
    * @param composerServiceRecordId (String) - The Id of the Composer Service record
    * @return ServerResponse
    */
    @AuraEnabled public static ServerResponse saveComposerServiceData(String recordId, String composerServiceRecordId) { return saveComposerServiceData(recordId, composerServiceRecordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse saveComposerServiceData(String recordId, String composerServiceRecordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'saveComposerServiceData';

        CCCServiceController.ServerResponse rService;
        Opportunity opportunityRecord;
        Opportunity updatedOpportunityRecord;
        Composer_Service__c composerServiceRecord;
        ServerResponse response = new ServerResponse();

        try {
            // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');
            if (composerServiceRecordId == null) throw new CCCException('Empty composerServiceRecordId parameter passed.');

            // Get Opportunity Record - Make sure it exists in Salesforce
            opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').equalsId(recordId).one();
            if (opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            // Get Composer Service Record - Make sure it exists in Salesforce
            composerServiceRecord = (Composer_Service__c) CCCQuery.get('Composer_Service__c').equalsId(composerServiceRecordId).one();
            if (composerServiceRecord == null) throw new CCCException('Unable to locate the Composer Service record specified.');

            // Update Opportunity
            update new Opportunity(
                Id =  opportunityRecord.Id,
                Composer_Service__c = composerServiceRecord.Id
            );

            // If the primary service is changing, remove additional services
            // not related to the primary service.
            removeLocationServices(recordId, composerServiceRecordId);
            
            //Recalculate Monthly Ad Budget
            resetLocationRecordsAdSpend(opportunityRecord);

            // Successfull save, retrieve fresh data to return back to the component

            // Get Fresh Data
            rService = getServiceData(recordId);
            if (rService.hasErrors) throw new CCCException(rService.message);

            response.opportunityRecord = rService.opportunityRecord;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        // ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }
    
    /**
    * @description resets the Ad Spend to default values when a new service is selected
    * @param oppRecord (Opportunity) - The opportunity record related to opportunity service areas
    */
    private static void resetLocationRecordsAdSpend(Opportunity oppRecord){
        
        List<Opportunity_Service_Area__c> locationRecords = [SELECT Id, Advertising_Spend__c
                                                       		 FROM Opportunity_Service_Area__c
                                                       		 WHERE Opportunity__c =: oppRecord.Id];
        
    	Opportunity opportunityRecord = [SELECT Composer_Service__r.Tier_1_Amount__c, Composer_Service__r.Vertical__c,
                                                Composer_Service__r.Tier_2_Amount__c
                                        FROM Opportunity
                                        WHERE Id =: oppRecord.Id];

        Boolean isFlatRate = opportunityRecord.Composer_Service__r.Vertical__c.toLowerCase().contains('flat rate');
        
        for(Opportunity_Service_Area__c each : locationRecords){
            if(isFlatRate){
                each.Advertising_Spend__c =  opportunityRecord.Composer_Service__r.Tier_2_Amount__c;
                each.Pricing_Tier__c = 'Tier 2';
                each.Flat_Rate_Billing_Cadence__c = 'Quarterly';
            } else {
                each.Advertising_Spend__c =  opportunityRecord.Composer_Service__r.Tier_1_Amount__c;
                each.Pricing_Tier__c = 'Tier 1';
                each.Flat_Rate_Billing_Cadence__c = '';
            }
        }
        
        update locationRecords;
    }


     /**
    * @description Removes any Opportunity_Location_Service__c records that either
    *              1) do not match the vertical on the selected composer service
    *              2) or that matches the composer service
    * @param opportunityId (String) - The Id of the Opportunity record
    * @param composerServiceId (String) - The Id of the Composer Service record
    */
    @TestVisible private static void removeLocationServices(String opportunityId, String composerServiceId) {

        // Get all location ids on the opportunity
        Set<String> locationIds =
            CCCQuery.get('Opportunity_Service_Area__c')
                    .equals('Opportunity__c', opportunityId)
                    .toMap()
                    ?.keySet();

        if (locationIds != null) {
            // Get the Composer Service record
            Composer_Service__c composerService = (Composer_Service__c)
                CCCQuery.get('Composer_Service__c')
                        .equalsId(composerServiceId)
                        .one();

            // Get all Location Services related to any location on the opportunity
            List<Opportunity_Location_Service__c> locationServices = (List<Opportunity_Location_Service__c>)
                CCCQuery.get('Opportunity_Location_Service__c')
                        .field('Composer_Service__r.Vertical__c')
                        .includes('Opportunity_Service_Area__c', locationIds)
                        .all();

            // Loop through location services and add to a 'delete' list any record that
            // 1) doesn't match the vertical on the composer service record or
            // 2) matches the composer service record
            List<Opportunity_Location_Service__c> locationServicesToDelete = new List<Opportunity_Location_Service__c>();
            for (Opportunity_Location_Service__c ls : locationServices) {
                if (ls.Composer_Service__c == composerService.Id || ls.Composer_Service__r.Vertical__c != composerService.Vertical__c) {
                    locationServicesToDelete.add(ls);
                }
            }

            delete locationServicesToDelete;
        }

    }

}