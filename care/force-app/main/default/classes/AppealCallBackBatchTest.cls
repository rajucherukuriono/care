@IsTest
public class AppealCallBackBatchTest {
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
                Syc_Status_message__c='Error',
                recordTypeId =Caseret
                
            );
        insert cesRec;
        cesRec.Contact_Theme__c='Blocklist Appeal';
        cesRec.Appeal_Decision__c='Reject';
       
        Test.setMock(HttpCalloutMock.class, new AppealcallMockHttpservices());
       // update cesRec;
        AppealCallBackBatch bc=new AppealCallBackBatch();
        database.executeBatch(bc);
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Merge Job', sch, bc);
         Test.stopTest();
    }
}