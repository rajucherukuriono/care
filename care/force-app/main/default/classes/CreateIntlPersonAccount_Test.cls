@isTest
private class CreateIntlPersonAccount_Test {
    
    static testMethod void CreateIntlPersonAccount_Test () {
        ID stdRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International BUC').getRecordTypeId();
        ID intlPARecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Person Account').getRecordTypeId();
       
        Case cas = new Case(
            web_first_name__c = 'abc',
            web_last_name__c = 'xyz',
            SuppliedEmail = 'abc+xyz@gmail.com',
            SuppliedPhone = '1234567890',
            Subject = 'ODS Test #2',
            Description = 'Test Description',
            Type = 'Question',
            Origin = 'Email - UK - Web',
            Status = 'New',
            OwnerId = UserInfo.getUserId(),
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            Employer_Program__c = 'Google',
            RecordTypeId = stdRtId
        );
        
        insert cas;
        
        Account acct = new Account(
            RecordTypeId = intlPARecId,
            FirstName = cas.web_first_name__c,
            LastName = cas.web_last_name__c,
            Employer_Program_Pick__c = 'Google'
        );
        
        insert acct;
        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        CreateIntlPersonAccount  obj = new CreateIntlPersonAccount(sc);
        obj.fname = 'abc';
        obj.lname = 'xyz';
        obj.Eprog = 'Google';
        obj.cPhone= '1234567890';
        obj.cEmail= 'abc+xyz@gmail.com'; 
        obj.memberAlreadyLinked = true;   
        obj.acct = acct;
        obj.save();
        List<SelectOption> options = obj.getEmpProg();
        Test.StopTest();
    }
    
    
}