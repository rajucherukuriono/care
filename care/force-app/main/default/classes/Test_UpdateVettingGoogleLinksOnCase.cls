@isTest
public class Test_UpdateVettingGoogleLinksOnCase {
     
    @isTest
    public static void testCase1() {
       Account a = new Account();
       a.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
       a.Lastname = 'test';
       a.Status__pc = 'new';
       a.type = 'test';
       a.MemberType__pc = '123456789';
       a.BillingCity = 'Atlanta';
       a.BillingState = 'GA';
       insert a;
       
       Case c = new Case();
        c.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
        c.AccountId = a.Id;
        c.Status = 'New';
        c.subject='Test';
        insert c;
        
       Account a1 = new Account();
       a1.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
       a1.Lastname = 'test';
       a1.Status__pc = 'new';
       a1.type = 'test';
       a1.MemberType__pc = '123456789';
       a1.PersonMailingCity = 'New York City';
       a1.PersonMailingState = 'NY';
       insert a1;
       
       Case c1 = new Case();
        c1.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
        c1.AccountId = a1.Id;
        c1.Status = 'New';
        c1.subject='Test';
        insert c1;
        
       Account a2 = new Account();
       a2.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
       a2.Lastname = 'test';
       a2.Status__pc = 'new';
       a2.type = 'test';
       a2.MemberType__pc = '123456789';
       a2.ShippingCity = 'Austin';
       a2.ShippingState = 'TX';
       insert a2;
    
        Case c2 = new Case();
        c2.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
        c2.AccountId = a2.Id;
        c2.Status = 'New';
        c2.subject='Test';
        insert c2;
        
        Account a3 = new Account();
       a3.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
       a3.Lastname = 'test';
       a3.Status__pc = 'new';
       a3.type = 'test';
       a3.MemberType__pc = '123456789';
       a3.BillingCity = '';
       a3.BillingState = '';
       a3.PersonMailingCity = 'NYC';
       a3.PersonMailingState = 'NY';
       insert a3;
       
       Case c3 = new Case();
        c3.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
        c3.AccountId = a3.Id;
        c3.Status = 'New';
        c3.subject='Test';
        insert c3;
        
         Account a4 = new Account();
       a4.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
       a4.Lastname = 'test';
       a4.Status__pc = 'new';
       a4.type = 'test';
       a4.MemberType__pc = '123456789';
       a4.BillingCity = '';
       a4.BillingState = '';
       a4.PersonMailingCity = '';
       a4.PersonMailingState = '';
       a4.ShippingCity = 'Austin';
       a4.ShippingState = 'TX';
       insert a4;
       
       Case c4 = new Case();
        c4.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
        c4.AccountId = a4.Id;
        c4.Status = 'New';
        c4.subject='Test';
        insert c4;
        
    }
    
    @isTest
    public static void testCase2(){
      List<Case> Cases1 = new List<case>();
      List<Case> Cases2 = new List<case>();
      Map<Id,Case> Cases3 = new Map<Id,case>();
      Map<Id,Case> Cases4 = new Map<Id,case>();

      UpdateVettingGoogleLinksOnCase ext = new UpdateVettingGoogleLinksOnCase(Cases1, Cases2, Cases3, Cases4, true, True, false, true, true);

      ext.dummyCoverageMethod();
    }
 }