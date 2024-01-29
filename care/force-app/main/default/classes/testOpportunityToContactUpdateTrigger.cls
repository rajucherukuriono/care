@isTest
private class testOpportunityToContactUpdateTrigger {

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
        
    }
    static testMethod void testMethod2() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        ID accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Homepay Business Account').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
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
        
    }
     static testMethod void testMethod3() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId2;
        opp.Name = 'home pay test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Probability = 0;
        opp.How_did_you_hear_about_Care_com__c = 'Agency';
        opp.Product_Type__c = 'Referrer' ;
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
    }
     static testMethod void testMethod4() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId2;
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
        delete opp;
    }
 static testMethod void testMethod5() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId1;
        opp.Name = 'home pay test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Probability = 0;
        opp.How_did_you_hear_about_Care_com__c = 'Agency';
        opp.Product_Type__c = 'Authorized Contact' ;
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
        delete opp;

   }
 static testMethod void testMethod6() {
       // Create test records
        ID oppRtId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID oppRtId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId1;
        opp.Name = 'home pay test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Probability = 0;
        opp.How_did_you_hear_about_Care_com__c = 'Agency';
        opp.Product_Type__c = 'Refferal' ;
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
        delete opp;
    }
}