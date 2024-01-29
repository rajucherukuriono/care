/*********************************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 08/25/2020
Description: Supports the CCC Lightning Component
Changes:

*********************************************************************************************/
public without sharing class CCCController {
    static private final String CLASS_NAME = 'CCCController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String oppType { get; set; }
        @AuraEnabled public Boolean allowEdit { get; set; }

        public ServerResponse() {
            super();
            this.allowEdit = false;
        }
    }


    /**
    * @description Retrieves initial data related to the opportunity Id that is being used by the Lightning Component
    * @param recordId (String) - The Id of the Opportunity record
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getInitialData(String recordId) { return getInitialData(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getInitialData(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getInitialData';

        ServerResponse response = new ServerResponse();
        CCCUtils.ServerResponse rUtils;

        try {
            //ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Opportunity record
            rUtils = CCCUtils.getOpportunityRecord(recordId);
            if (rUtils.hasErrors) throw new CCCException(rUtils.message);
            if (rUtils.opportunityRecord == null) throw new CCCException('Unable to locate the Opportunity record specified.');

            response.oppType = rUtils.opportunityRecord.Type;
            response.recordType = rUtils.recordType;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        //ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }

    /**
    * @description Wrapper method for calling CCCUtils.getAllowEdit
    * @param recordId (String) - The Id of the Opportunity record
    * @return (ServerResponse)
    */
    @AuraEnabled public static ServerResponse getAllowEditWrapper(String recordId) { return getAllowEditWrapper(recordId, new CCCUtils.UnitTestFlags()); }

    @TestVisible private static ServerResponse getAllowEditWrapper(String recordId, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getAllowEditWrapper';

        ServerResponse response = new ServerResponse();
        CCCUtils.ServerResponse rUtils;

        try {
            //ContractComposerLog.logDebug(CLASS_NAME, METHOD_NAME, 'Start Method');

            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            if (recordId == null) throw new CCCException('Empty recordId parameter passed.');

            // Get Allow Edit
            rUtils = CCCUtils.getAllowEdit(recordId);
            if (rUtils.hasErrors) throw new CCCException(rUtils.message);

            response.allowEdit = rUtils.allowEdit;

        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        //ContractComposerLog.logDebugAndFlush(CLASS_NAME, METHOD_NAME, 'End Method');

        return response;
    }
}