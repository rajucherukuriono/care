@IsTest
public class AppealCallBackCallout_Test {
     Public static Id Caseret = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    @IsTest
    public static void testbatch(){
        Test.startTest();
        Case cesRec = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Origin = 'Chat',
                recordTypeId =Caseret
                
            );
        insert cesRec;
        cesRec.Contact_Theme__c='Blocklist Appeal';
        cesRec.Appeal_Decision__c='Reject';
         Test.setMock(HttpCalloutMock.class, new AppealcallMockHttpservices());
        update cesRec;
         Test.stopTest();
    }
}