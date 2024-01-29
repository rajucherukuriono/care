/**
The TestOrgNotesController class is a helper class for tests.  It contains utility methods for
creating a OrgNote.
Last Modified By: Mohammed Ashwaq
Last modified Date: 10/11/2020
**/
@isTest
private class TestOrgNotesController{
    @testSetup static void setup() {
        // Test the get and set of the Object : First copy record type Info from OrgNotes__c
        // get the Sysadmin - record Type Id and insert test-record, then test against that record.
        // 
        Schema.DescribeSObjectResult testSchema = Schema.SObjectType.OrgNotes__c; 
        Map<String,Schema.RecordTypeInfo> OrgNotesRecordTypeInfo = testSchema.getRecordTypeInfosByName();
        Id rtTestId = OrgNotesRecordTypeInfo.get('SysAdmins').getRecordTypeId(); 
        String strTestId = Id.valueOf(rtTestId);
        System.debug('Current strTestId'+ strTestId);   
        OrgNotes__c Note = new OrgNotes__c(grouplabel__c='testgroup', message__c='testmessage', RecordTypeId = rtTestId);
        insert Note; 
        System.assertNotEquals(null, Note.grouplabel__c);
        System.assertEquals('testgroup', Note.grouplabel__c);
        System.assertNotEquals(null, Note.message__c);
        System.assertEquals('testmessage', Note.message__c); 
    }
    static testMethod void TestOrgNotes() { 
        System.debug('Current User: ' + UserInfo.getUserName());
        // Run some code that checks record sharing
        OrgNotesController controller = new OrgNotesController() ;
        controller.getLabel();
        controller.getMessage();
        System.assertNotEquals(controller.orgnoteslist.message__c,'testmessage');
        //System.assertEquals(controller.text,'testmessage');
        //System.assertEquals(controller.label,'testgroup');
    }
}