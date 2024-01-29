/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 08/25/2020
Description: A set of utility methods that other CCC Apex classes can use
Changes:

*********************************************************************************************/
public without sharing class CCCUtils {
    static private final String CLASS_NAME = 'CCCUtils';

    public class InvalidParameterException extends Exception {}

    public class NullPointerException extends Exception {}

    public class CallOutException extends Exception {}

    public class ServerResponse extends CCCServerResponse {

        @AuraEnabled public Boolean allowEdit { get; set; }
        // @AuraEnabled public Date calculatedDate { get; set; }
        @AuraEnabled public Date today { get; set; }
        @AuraEnabled public Opportunity opportunityRecord { get; set; }
        @AuraEnabled public String recordType { get; set; }

        public ServerResponse() {
            super();
            this.allowEdit = false;
            this.today = System.today();
        }
    }

    public virtual class UnitTestFlags {
        public Boolean returnBadStatus { get { return Test.isRunningTest() ? returnBadStatus : false; } set; }
        //public Boolean returnBadStatus2 { get { return Test.isRunningTest() ? returnBadStatus2 : false; } set; }
        // public Boolean throwAuthTokenFail { get { return Test.isRunningTest() ? throwAuthTokenFail : false; } set; }
        // public Boolean returnEndpointNotFound { get { return Test.isRunningTest() ? returnEndpointNotFound : false; } set; }
        // public Boolean throwExternalSystemFail { get { return Test.isRunningTest() ? throwExternalSystemFail : false; } set; }
        public Boolean throwRootExceptionFail { get { return Test.isRunningTest() ? throwRootExceptionFail : false; } set; }

        public UnitTestFlags() {
            this.returnBadStatus = false;
            //this.returnBadStatus2 = false;
            // returnEndpointNotFound = false;
            // throwAuthTokenFail = false;
            // throwExternalSystemFail = false;
            this.throwRootExceptionFail = false;
        }
    }

    public virtual class CCCException extends Exception {}

    public static List<String> getLocationProvinceOptions() {
        List<String> options = new List<String>();

        Schema.DescribeFieldResult fieldResult = Opportunity_Service_Area__c.State__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            options.add(entry.getValue());
        }

        return options;
    }


    /**
    * @description Get the various Opportunity fields used throughout ContractComposer
    * @param recordId (String) - The Opportunity record Id we are retrieving data for
    * @return (ServerResponse)
    */
    public static ServerResponse getOpportunityRecord(String recordId) { return getOpportunityRecord(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getOpportunityRecord(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getOpportunityRecord';

        ServerResponse response = new ServerResponse();
        CCCUtils.ServerResponse rUtils;
        CCC_Global_Setting__mdt globalSettings;

        String query;
        Map<String, Schema.SObjectField> fMap;
        List<Opportunity> records;
        List<String> fields = new List<String>();
        List<String> csRecordTypes;
        List<String> soRecordTypes;

        try {

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Global Custom Metadata settings
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            // Get all Object fields
            fMap = Schema.getGlobalDescribe().get('Opportunity'.toLowerCase()).getDescribe().fields.getMap();

            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                fields.add(ft.getDescribe().getName());
            }

            // Add additional fields
            fields.add('RecordType.Name');
            fields.add('RecordType.DeveloperName');
            fields.add('Account.of_locations__c');
            fields.add('Composer_Service__r.Vertical__c');
            fields.add('Composer_Service__r.License_Level__c');

            // SOQL Query
            query = 'SELECT ';
            query += String.join(fields,', ');
            query += ' FROM Opportunity';
            query += ' WHERE Id = :recordId';

            records = (List<Opportunity>) Database.query(query);

            if (records.size() == 1) response.opportunityRecord = records[0];

            // Determine the "Type" of the RecordType of this Opportunity to know what business logic to apply
            soRecordTypes = globalSettings.SO_Record_Types__c.split(',');
            csRecordTypes = globalSettings.CS_Record_Types__c.split(',');


            // RecordType logic
            if (soRecordTypes.contains(response.opportunityRecord.RecordType.DeveloperName)) response.recordType = 'SO';
            if (csRecordTypes.contains(response.opportunityRecord.RecordType.DeveloperName)) response.recordType = 'CS';

        } catch (Exception e) { return (ServerResponse) setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }


    /**
    * @description Returns the category of the Opportunity record type based on global settings designations
    * @param opportunityRecord (Opportunity) - The Opportunity object
    * @param globalSettings (CCC_Global_Setting__mdt) - The CCC_Global_Setting__mdt object
    * @return (Boolean)
    */
    public static String getOpportunityRecordTypeCategory(Opportunity opportunityRecord, CCC_Global_Setting__mdt globalSettings) {
        List<String> soRecordTypeDeveloperNames = globalSettings.SO_Record_Types__c.split(',');
        if (soRecordTypeDeveloperNames.contains(opportunityRecord.RecordType.DeveloperName)) {
            return 'SO';
        }

        List<String> csRecordTypeDeveloperNames = globalSettings.CS_Record_Types__c.split(',');
        if (csRecordTypeDeveloperNames.contains(opportunityRecord.RecordType.DeveloperName)) {
            return 'CS';
        }

        return '';
    }


    /**
    * @description Returns true if the user's profile name is in the acceptable CSV list of profile names
    * @param profileNamesCSV <String> - A CSV list of acceptable profile names
    * @return (Boolean)
    */
    public static Boolean userHasProfileIn(String profileNamesCSV) {
        if (profileNamesCSV != null && profileNamesCSV.length() > 0) {
            Set<String> profileNames = new Set<String>();
            for (String profileName : profileNamesCSV.split(',')) {
                profileName = profileName.trim();
                if (String.isNotBlank(profileName)) {
                    profileNames.add(profileName);
                }
            }
            if (profileNames.size() > 0) {
                return userHasProfileIn(profileNames);
            }
        }
        return false;
    }


    /**
    * @description Returns true if the user's profile name is in the acceptable Set of profile names
    * @param profileNames (Set<String>) - The set of acceptable profile names
    * @return (Boolean)
    */
    public static Boolean userHasProfileIn(Set<String> profileNames) {
        Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return p != null && profileNames.contains(p.Name);
    }


    /**
    * @description Sets the error response
    * @param METHOD_NAME (String) - The name of the method this was called from -- used for logging
    * @param e (Exception) - The (optional) exception
    * @param response (ServerResponse) - The ServerResponse as it existed when the Exception was thrown
    * @return (ServerResponse)
    */
    public static CCCServerResponse setErrorResponse(String CLASS_NAME, String METHOD_NAME, Exception e, CCCServerResponse response) {
        //ContractComposerLog.logException(CLASS_NAME, METHOD_NAME, e);
        response.message = CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage();
        response.hasErrors = true;
        return response;
    }

    /**
    * @description Sets the error response
    * @param METHOD_NAME (String) - The name of the method this was called from -- used for logging
    * @param errorMessage (String) - The error message to return in the response
    * @param response (ServerResponse) - The ServerResponse as it existed when the Exception was thrown
    * @return (ServerResponse)
    */
    public static CCCServerResponse setErrorResponse(String CLASS_NAME, String METHOD_NAME, String errorMessage, CCCServerResponse response) {
        //ContractComposerLog.logErrorResponse(CLASS_NAME, METHOD_NAME, errorMessage);
        response.message = errorMessage;
        response.hasErrors = true;
        return response;
    }

    /**
    * @description Determines if the Opportunity is able to be published
    * @param recordId (String) - The Id of the Opportunity record
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getAllowEdit(String recordId) { return getAllowEdit(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getAllowEdit(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getAllowEdit';

        ServerResponse response = new ServerResponse();
        CCCUtils.ServerResponse rUtils;
        Opportunity opportunityRecord;
        List<String> editableStageNamesList;
        CCC_Global_Setting__mdt globalSettings;

        try {
            //ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            response.allowEdit = false;

            // Get CCC Global Settings Custom Metadata Type
            globalSettings = (CCC_Global_Setting__mdt) CCCQuery.get('CCC_Global_Setting__mdt').equals('DeveloperName', 'Default').one();

            editableStageNamesList = globalSettings.Valid_Stages_for_Modifying_Agreement__c.split(',');


            // Get Opportunity record
            rUtils = CCCUtils.getOpportunityRecord(recordId);
            if (rUtils.hasErrors) throw new CCCException(rUtils.message);
            if (rUtils.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            opportunityRecord = rUtils.opportunityRecord;

            response.allowEdit = editableStageNamesList.contains(opportunityRecord.StageName);

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        //ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }


    /**
    * @description Returns the name of the sObject type for an Id. If the Id is invalid, 'invalid sObject Id' is returned.
    * @param sObjectIdString (String) - The Id to test
    * @return (String)
    */
    public static String getSObjectType(String sObjectIdString) {
        String sObjectType = 'invalid sObject Id';
        try {
            sObjectType = ((Id) sObjectIdString).getSObjectType().getDescribe().getName();
        } catch(Exception e) {}
        return sObjectType;
    }

}