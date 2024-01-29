/****************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 06/24/2021
Description: Provides methods the CCCUserPermissions aura component
Changes:

*****************************************************************************/
public without sharing class CCCUserPermissionsController {
    static private final String CLASS_NAME = 'CCCUserPermissionsController';

    public class ServerResponse extends CCCServerResponse {
        @AuraEnabled public List<Composer_Service__c> composerServiceRecords { get; set; }
        @AuraEnabled public List<User> userRecords { get; set; }

        public ServerResponse() {
            super();
            this.composerServiceRecords = new List<Composer_Service__c>();
            this.userRecords = new List<User>();
        }
    }

    // public method
    @AuraEnabled
    public static ServerResponse getUserPermissionsData() { return getUserPermissionsData(new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse getUserPermissionsData(CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getUserPermissionsData';
        ServerResponse response = new ServerResponse();

        try {
            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            response.composerServiceRecords = (List<Composer_Service__c>) CCCQuery.get('Composer_Service__c').all();
            response.userRecords = (List<User>) CCCQuery.get('User').equals('Profile.Name', 'Sales Origination Rep').equals('isActive', true).order('Lastname').all();
        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }

    // public method
    @AuraEnabled
    public static ServerResponse updateUserPermittedVerticals(String userId, String permittedVerticals) { return updateUserPermittedVerticals(userId, permittedVerticals, new CCCUtils.UnitTestFlags()); }

    // internal method
    @TestVisible
    private static ServerResponse updateUserPermittedVerticals(String userId, String permittedVerticals, CCCUtils.UnitTestFlags flags) {
        final String METHOD_NAME = 'getUserPermissionsData';
        ServerResponse response = new ServerResponse();

        try {
            if (flags == null) flags = new CCCUtils.UnitTestFlags();
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            update new User(Id = userId, Contract_Composer_Permitted_Verticals__c = permittedVerticals);
        } catch (Exception e) { return (ServerResponse) CCCUtils.setErrorResponse(CLASS_NAME, METHOD_NAME, e, (CCCServerResponse) response); }

        return response;
    }

}