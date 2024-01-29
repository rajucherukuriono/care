@isTest
private class PrimaryContactOnOpp_test {

    static testMethod void TestPrimaryContactonWPSOpp() {
        Account a = new Account(Name = 'WPS Acc',RecordTypeId = getRecordTypesStatic.busAcctRecType,NumberOfEmployees = 20);
        insert a;

        Contact c = new Contact(AccountId = a.id,RecordTypeId = getRecordTypesStatic.wpsContactRecType,firstName = 'TestPCUserOne',lastname = 'Test');
        insert c;

        Opportunity o = new Opportunity(Name = 'WPS Opportunity',
                                            AccountId = a.id,
                                            RecordTypeId = getRecordTypesStatic.wpsOppRecType,
                                            StageName = '0-Active',
                                            CloseDate = Date.Today()        
                                            ); 

        insert o;

        OpportunityContactRole ocr = new OpportunityContactRole(
                                            ContactId = c.id,
                                            IsPrimary = true,
                                            Role = 'Primary Decision Maker',
                                            OpportunityId = o.id
                                            );
        insert ocr;                 
        OpportunityContactRole[] ocrList = [SELECT id from OpportunityContactRole where ContactId = :c.id and OpportunityId = :o.id AND isPrimary = true];
        System.assert(ocrList.size() == 1); // test the ocr was added as a primary contact

        o.Description = 'Note 1';
        update o;
        
        Opportunity[] oList = [Select Id,AccountId,Primary_Contact_Associated__c from Opportunity where id=:o.id];
        System.assert(oList.size() == 1);
        Opportunity updatedO = oList[0]; 
        //System.assert(updatedO.Primary_Contact_Associated__c == c.id); // ensure Primary Contact Assocated inherited the primary contact
        //System.assert(updatedO.Number_of_Primary_Contacts__c == 1); // ensure the number of Primary Contacts is correct

        delete ocr; // to reproduce use case of removing primary contact from opp
        
        updatedO.Description = 'Note 2'; // make random edit on opp to invoke trigger
        update updatedO;

        Opportunity[] oUpdatedList = [Select Id,AccountId,Primary_Contact_Associated__c from Opportunity where id=:o.id];
        System.assert(oUpdatedList.size() == 1);
        Opportunity reupdatedO = oUpdatedList[0]; 
        System.assert(reupdatedO.Primary_Contact_Associated__c == null); // ensure Primary Contact Assocated was nulled
        //System.assert(reupdatedO.Number_of_Primary_Contacts__c == 0); // ensure the number of Primary Contacts is correct

    }

    static testMethod void TestPrimaryContactonMKTOpp() {
        Account a = new Account(Name = 'MKT Acc',RecordTypeId = getRecordTypesStatic.busAcctRecType,NumberOfEmployees = 20);
        insert a;

        Contact c = new Contact(AccountId = a.id,RecordTypeId = getRecordTypesStatic.mktplcContactRecType,firstName = 'TestPCUserOne',lastname = 'Test');
        insert c;

        Opportunity o = new Opportunity(Name = 'MKT Opportunity',
                                            AccountId = a.id,
                                            RecordTypeId = getRecordTypesStatic.wpsOppRecType,
                                            StageName = 'Follow Up',
                                            CloseDate = Date.Today()        
                                            ); 

        insert o;

        OpportunityContactRole ocr = new OpportunityContactRole(
                                            ContactId = c.id,
                                            IsPrimary = true,
                                            Role = 'Primary Decision Maker',
                                            OpportunityId = o.id
                                            );
        insert ocr;                 
        OpportunityContactRole[] ocrList = [SELECT id from OpportunityContactRole where ContactId = :c.id and OpportunityId = :o.id AND isPrimary = true];
        System.assert(ocrList.size() == 1); // test the ocr was added as a primary contact

        o.Description = 'Note 1';
        update o;
        
        Opportunity[] oList = [Select Id,AccountId,Primary_Contact_Associated__c from Opportunity where id=:o.id];
        System.assert(oList.size() == 1);
        Opportunity updatedO = oList[0]; 
        //System.assert(updatedO.Primary_Contact_Associated__c == c.id); // ensure Primary Contact Assocated inherited the primary contact
        //System.assert(updatedO.Number_of_Primary_Contacts__c == 1); // ensure the number of Primary Contacts is correct

        delete ocr; // to reproduce use case of removing primary contact from opp
        
        updatedO.Description = 'Note 2'; // make random edit on opp to invoke trigger
        update updatedO;

        Opportunity[] oUpdatedList = [Select Id,AccountId,Primary_Contact_Associated__c from Opportunity where id=:o.id];
        System.assert(oUpdatedList.size() == 1);
        Opportunity reupdatedO = oUpdatedList[0]; 
        System.assert(reupdatedO.Primary_Contact_Associated__c == null); // ensure Primary Contact Assocated was nulled
        //System.assert(reupdatedO.Number_of_Primary_Contacts__c == 0); // ensure the number of Primary Contacts is correct
    }
}