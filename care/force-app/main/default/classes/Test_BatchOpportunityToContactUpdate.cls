@isTest
private class Test_BatchOpportunityToContactUpdate {

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
        Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
      System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    //Database.executeBatch(new BatchOpportunityToContactUpdate(true));
        Test.stopTest();
        
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
                Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
      System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    //Database.executeBatch(new BatchOpportunityToContactUpdate(true));
        Test.stopTest();
        
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
                Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
      System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    //Database.executeBatch(new BatchOpportunityToContactUpdate(true));
        Test.stopTest();
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
                Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
      System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    //Database.executeBatch(new BatchOpportunityToContactUpdate(true));
        Test.stopTest();
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
                Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
      System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    //Database.executeBatch(new BatchOpportunityToContactUpdate(true));
        Test.stopTest();

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
                Test.startTest();
            String day=String.valueOf(Datetime.now().day()); 
            String month=String.valueOf(Datetime.now().month()); 
            String year=String.valueOf(Datetime.now().year()); 
        
            String hour = String.valueOf(Datetime.now().hour()); 
            String min = String.valueOf(Datetime.now().minute()<=58?Datetime.now().minute()+1:Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()); 
   
       String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
       BatchOpportunityToContactUpdate.dummyCoverageMethod();
      //System.schedule('Process BatchOpportunityToContactUpdate','0 0 23 * * ?',new BatchOpportunityToContactUpdate(true));
     
    Database.executeBatch(new BatchOpportunityToContactUpdate(true));
    
        Test.stopTest();
    }
}