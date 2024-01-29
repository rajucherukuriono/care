@isTest
private class TestUpdateContactTypeOnContsWithNoOpps {

     static testMethod void testMethod1() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        ID accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Homepay Business Account').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'Partner', Industry = 'Telecommunications');
        acc.RecordtypeId = accRtId;
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', Contact_Type__c='Referring Partner', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId1;
        opp.Name = 'home pay test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Probability = 0;
        opp.How_did_you_hear_about_Care_com__c = 'Agency';
        opp.Product_Type__c = 'Referral' ;
        opp.stageName = 'Prospect';
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        opp.stageName = 'Closed Won';
        update opp;
                UpdateContactTypeOnContactsWithNoOpps.UpdateContactTypeOnContactsWithNoOpps();     
    } 
     static testMethod void testMethod2() {
             ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        ID accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Homepay Business Account').getRecordTypeId();
        Account acc1 = new Account(name = 'home pay test Account', type = 'Partner', Industry = 'Telecommunications');
        acc1.RecordtypeId = accRtId;
        insert acc1;
        Contact Con1 = new Contact(Firstname= 'home pay1', lastName= 'test contact1', Contact_Type__c='Referring Partner', accountId = acc1.Id, RecordTypeId = conRtId);
        insert Con1;
        UpdateContactTypeOnContactsWithNoOpps.UpdateContactTypeOnContactsWithNoOpps();     
    }       
}