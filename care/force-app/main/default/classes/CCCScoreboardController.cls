/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/18/2020
Description: Provides methods to calculate and retrieve Scoreboard Metrics
Changes:

*****************************************************************************/
public without sharing class CCCScoreboardController {
    static private final String CLASS_NAME = 'CCCScoreboardController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public Decimal advertisingBudgetTotalAmount { get; set; }
        @AuraEnabled public Decimal agreementTotalAmount { get; set; }
        @AuraEnabled public Integer numLocations { get; set; }
        @AuraEnabled public Integer ofLocations { get; set; }
        @AuraEnabled public Decimal initialPlatformFee { get; set; }
        @AuraEnabled public Decimal additionalLocationPlatformFee { get; set; }
        @AuraEnabled public Decimal platformFeeWaived { get; set; }
        @AuraEnabled public Decimal totalPlatformFee { get; set; }

        // SO RecordType fields
        @AuraEnabled public Decimal basePoints { get; set; }
        @AuraEnabled public Decimal bonusPoints { get; set; }

        public ServerResponse() {
            super();
            this.advertisingBudgetTotalAmount = 0.00;
            this.agreementTotalAmount = 0.00;
            this.basePoints = null;
            this.bonusPoints = null;
            this.numLocations = 0;
            this.initialPlatformFee = 0.00;
            this.additionalLocationPlatformFee = 0.00;
            this.platformFeeWaived = 0.00;
            this.totalPlatformFee = 0.00;
        }
    }


    /**
    * @description Calculates and returns Scoreboard Metrics
    * @param recordId (String) - The Id of the Opportunity record that is being viewed
    * @param forcePointsRecalculate (String) - A boolean indicator if Points need to be recalculated
    * @return String (JSON) - Serialized Server Response object
    */
    @AuraEnabled public static ServerResponse getScoreboardData(String recordId, Boolean forcePointsRecalculate) { return getScoreboardData(recordId, forcePointsRecalculate, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getScoreboardData(String recordId, Boolean forcePointsRecalculate, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getScoreboardData';

        CCCUtils.ServerResponse rUtils;
        CCC_Global_Setting__mdt globalSettings;
        Decimal activeWebAgreementPrice = 0;
        Opportunity opportunityRecord;
        Account accountRecord;
        ServerResponse response = new ServerResponse();
        String recordType;

        try {
            // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Recalculate Points info later, even if the values exist on the Opp
            if (forcePointsRecalculate == null) forcePointsRecalculate = false;

            // Get Opportunity info
            opportunityRecord = (Opportunity) CCCQuery.get('Opportunity').add('RecordType').add('Composer_Service__c').equalsId(recordId).one();

            // Get related account
            accountRecord = (Account) CCCQuery.get('Account').equalsId(opportunityRecord.AccountId).one();

            // Get Locations
            Map<String, sObject> locationRecordMap = CCCQuery.get('Opportunity_Service_Area__c').equals('Opportunity__c', recordId).toMap();
            List<Opportunity_Service_Area__c> locationRecords = (List<Opportunity_Service_Area__c>) locationRecordMap.values();
            //resetLocationRecordsAdSpend(locationRecords);

            // Get Location Service records
            List<Opportunity_Location_Service__c> locationServiceRecords = (List<Opportunity_Location_Service__c>)
                CCCQuery.get('Opportunity_Location_Service__c')
                        .includes('Opportunity_Service_Area__c', locationRecordMap.keySet())
                        .all();

            /*****************************************
            * Begin Number of Opportunity Service Area Calculations
            *****************************************/
            response.numLocations = locationRecords.size();
            response.ofLocations = Integer.valueOf(accountRecord.of_locations__c); // total locations on the account (for display only)

            // Gather Category Group count for Agreement Price, default to 1 for Agreement Price calculations if none have been selected so far.
            // Ad Budget - Sum of the Opportunity Service Area - Advertising Spend
            for (Opportunity_Service_Area__c locationRecord : locationRecords) {
                response.advertisingBudgetTotalAmount += locationRecord.Advertising_Spend__c;
            }

            for (Opportunity_Location_Service__c locationServiceRecord : locationServiceRecords) {
                response.advertisingBudgetTotalAmount += locationServiceRecord.Advertising_Spend__c;
            }


            /*****************************************
            * Begin Platform Fee Calculations
            *****************************************/

            // Get Global Custom Metadata settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            // Fees
            response.initialPlatformFee = globalSettings.Admin_Initial_Platform_Fee__c;
            response.additionalLocationPlatformFee = globalSettings.Admin_Additional_Location_Platform_Fee__c * (response.numLocations > 0 ? response.numLocations -1 : 0);
            response.totalPlatformFee = response.initialPlatformFee + response.additionalLocationPlatformFee;
            response.platformFeeWaived = opportunityRecord.Platform_Fee_Waived__c;

            /*****************************************
            * Begin Agreement Price Calculations
            *****************************************/
            response.agreementTotalAmount = response.advertisingBudgetTotalAmount + response.totalPlatformFee;


            // ********************************/
            // Calculate Discounts
            // ********************************/


            // TBD


            // Agreement Price cannot be less than 0
            if (response.agreementTotalAmount < 0) response.agreementTotalAmount = 0;


            /*****************************************
            * Begin Base Points Calculations
            *****************************************/
            if (CCCUtils.getOpportunityRecordTypeCategory(opportunityRecord, globalSettings) == 'SO') {
                response.basePoints = opportunityRecord.Base_Points__c;
                response.bonusPoints = opportunityRecord.Bonus_Points__c;

                // Base/Bonus points are saved to the Opportunity during "Publish Agreement". Usually we would not recalculate these if they are not null on the Opp
                // however, we would need to recalculate in certain situations, like when Publishing the agreement again
                if (forcePointsRecalculate || (response.basePoints == null && response.bonusPoints == null)) {
                    response.basePoints = calculateBasePoints(opportunityRecord.Composer_Service__r, response.numLocations);
                    response.bonusPoints = calculateBonusPoints(opportunityRecord, globalSettings, locationRecords, locationServiceRecords);
                }
            }

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        // ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }
    
    private static void resetLocationRecordsAdSpend(List<Opportunity_Service_Area__c> locationRecords){
       Opportunity opportunityRecord = [SELECT Composer_Service__r.Tier_1_Amount__c, Composer_Service__r.Vertical__c
                                        FROM Opportunity 
                                        WHERE Id = :locationRecords[0].Opportunity__c];
        
        for(Opportunity_Service_Area__c each : locationRecords){
            each.Advertising_Spend__c = opportunityRecord.Composer_Service__r.Tier_1_Amount__c;
            each.Pricing_Tier__c = 'Tier 1';
        }
            
        update locationRecords;
    }

    private static Integer calculateBasePoints(Composer_Service__c composerServiceRecord, Integer locationCount) {
        Integer basePoints = 0;

        // Add Base Points for Composer Service record related to the Opportunity
        if (composerServiceRecord != null) {
            Integer composerServiceBasePoints = composerServiceRecord.Base_Points__c == null ? 0 : Integer.valueOf(composerServiceRecord.Base_Points__c);
            basePoints += composerServiceBasePoints;

            // Add to base points for each extra location beyond the first location
            if (locationCount > 1) {
                Integer extraLocationCount = locationCount - 1;
                Integer extraLocationBasePoints = composerServiceRecord.Extra_Location_Base_Points__c == null ? 0 : Integer.valueOf(composerServiceRecord.Extra_Location_Base_Points__c);

                // Cap the number of extra locations to Extra_Location_Base_Cap__c
                Integer extraLocationBaseCap = composerServiceRecord.Extra_Location_Base_Cap__c == null ? 0 : Integer.valueOf(composerServiceRecord.Extra_Location_Base_Cap__c);
                if (extraLocationBaseCap > 0 && extraLocationCount > extraLocationBaseCap) {
                    extraLocationCount = extraLocationBaseCap;
                }

                basePoints += (extraLocationCount * extraLocationBasePoints);
            }
        }

        return basePoints;
    }

    private static Integer calculateBonusPoints(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings, List<Opportunity_Service_Area__c> locationRecords, List<Opportunity_Location_Service__c> locationServiceRecords) {
        Integer bonusPoints = 0;

        Composer_Service__c composerServiceRecord = opportunityRecord.Composer_Service__r;

        // Calculate bonus points for each location for the primary service
        // Get starting bonus points from the Composer_Service__c related to the Opportunity
        if (composerServiceRecord != null) {
            Integer composerServiceBonusPoints = composerServiceRecord.Bonus_Points__c == null ? 0 : Integer.valueOf(composerServiceRecord.Bonus_Points__c);
            bonusPoints += composerServiceBonusPoints;


            // Add to bonus points for each extra location beyond the first location
            if (locationRecords != null && locationRecords.size() > 1) {
                Integer extraLocationCount = locationRecords.size() - 1;
                Integer extraLocationBonusPoints = composerServiceRecord.Extra_Location_Bonus_Points__c == null ? 0 : Integer.valueOf(composerServiceRecord.Extra_Location_Bonus_Points__c);

                bonusPoints += (extraLocationCount * extraLocationBonusPoints);
            }

            // Add to bonus points for each location based on the location's pricing tier
            if (locationRecords != null) {
                for (Opportunity_Service_Area__c locationRecord : locationRecords) {
                    String bonusFieldName = locationRecord.Pricing_Tier__c.replace(' ', '_') + '_Bonus_Points__c';
                    Integer bonusPointsValue = Integer.valueOf(composerServiceRecord.get(bonusFieldName));
                    bonusPoints += (bonusPointsValue != null) ? bonusPointsValue : 0;
                }
            
                // Add bonus points for each location that has a tuition discount code if spend > $400
                Integer tuitionDiscountBonusPoints = composerServiceRecord.Tuition_Discount_Bonus_Points__c != null ? Integer.valueOf(composerServiceRecord.Tuition_Discount_Bonus_Points__c) : 4;
                for (Opportunity_Service_Area__c locationRecord : locationRecords) {
                    if (String.isNotBlank(locationRecord.Tuition_Discount_Text__c) && locationRecord.Advertising_Spend__c != null && (locationRecord.Advertising_Spend__c >= 400 || composerServiceRecord.Vertical__c.contains('Flat Rate'))) {
                        bonusPoints += tuitionDiscountBonusPoints;
                    }
                }
            }

            // Add to bonus points for each location Service based on the location Service's pricing tier
            if (locationServiceRecords != null) {
                Map<String, sObject> composerServiceMap = CCCQuery.get('Composer_Service__c').equals('Active__c', true).order('Vertical__c ASC, License_Level__c ASC').toMap();
                for (Opportunity_Location_Service__c locationServiceRecord : locationServiceRecords) {
                    // Get the Composer_Service__c related to the location service record
                    Composer_Service__c compServRec = (Composer_Service__c) composerServiceMap.get(locationServiceRecord.Composer_Service__c);
    
                    String bonusFieldName = locationServiceRecord.Pricing_Tier__c.replace(' ', '_') + '_Bonus_Points__c';
                    Integer bonusPointsValue = Integer.valueOf(compServRec.get(bonusFieldName));
                    bonusPoints += (bonusPointsValue != null) ? bonusPointsValue : 0;
                }
            }

        }

        return bonusPoints;
    }

}