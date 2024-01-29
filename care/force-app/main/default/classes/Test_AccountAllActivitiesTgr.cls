@isTest
public class Test_AccountAllActivitiesTgr {
@isTest static void accTasktest1(){
Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;

    
    
    
    

        Task t1 = new Task();
        t1.WhatId = a1.id;
        t1.Status = 'Not Started';
        t1.Subject = 'Test Task';
        t1.Type = 'eMail';
        t1.ActivityDate = Date.today();
        //insert t1;
        
        
        insert new List<Task>{t1};
        
        
        Test.stopTest();
        }
        @isTest static void oppTasktest1(){
Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com',
            Business_Account__c=a1.id
          );
          insert l;
          Contact contObj = new Contact();
      contObj.LastName = 'Joe';
      contObj.Email = '123@gmail.com';
      contObj.AccountId = a1.id;
      contObj.type__c = 'test';
      contObj.MemberType__c = 'test';
      insert contObj;
          Opportunity opp = new Opportunity(Name = 'Test Opp',
                        StageName = 'Unassigned',
                        CloseDate = Date.Today(),    
                       accountId=a1.id                            
                      ); 

    insert opp;
    
        Task t2 = new Task();
        t2.WhatId = opp.id;
        t2.Status = 'Not Started';
        t2.Subject = 'Test Task';
        t2.Type = 'eMail';
        t2.ActivityDate = Date.today();
        //insert t2;
        
        
        insert new List<Task>{t2};
        
        
        Test.stopTest();
        }
        @isTest static void leadTasktest1(){
Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com',
            Business_Account__c=a1.id
          );
          insert l;
          Contact contObj = new Contact();
      contObj.LastName = 'Joe';
      contObj.Email = '123@gmail.com';
      contObj.AccountId = a1.id;
      contObj.type__c = 'test';
      contObj.MemberType__c = 'test';
      insert contObj;
          Opportunity opp = new Opportunity(Name = 'Test Opp',
                        StageName = 'Unassigned',
                        CloseDate = Date.Today(),    
                       accountId=a1.id                            
                      ); 

    insert opp;
    
                Task t3 = new Task();
        t3.WhoId = l.id;
        t3.Status = 'Not Started';
        t3.Subject = 'Test Task';
        t3.Type = 'eMail';
        t3.ActivityDate = Date.today();
        //insert t3;
        
        
        insert new List<Task>{t3};
        
        
        Test.stopTest();
        }
        @isTest static void leadTasktest4(){
Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com',
            Business_Account__c=a1.id
          );
          insert l;
          Contact contObj = new Contact();
      contObj.LastName = 'Joe';
      contObj.Email = '123@gmail.com';
      contObj.AccountId = a1.id;
      contObj.type__c = 'test';
      contObj.MemberType__c = 'test';
      insert contObj;
          Opportunity opp = new Opportunity(Name = 'Test Opp',
                        StageName = 'Unassigned',
                        CloseDate = Date.Today(),    
                       accountId=a1.id                            
                      ); 

    insert opp;
    
                Task t4 = new Task();
        t4.WhoId = contObj.id;
        t4.Status = 'Not Started';
        t4.Subject = 'Test Task';
        t4.Type = 'eMail';
        t4.ActivityDate = Date.today();
        //insert t4;
        
        
        insert new List<Task>{t4};
        
        
        Test.stopTest();
        }
        @isTest static void test2(){
        Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com'
            
          );
          insert l;
          l.Business_Account__c=a1.id;update l;
          
    l.Business_Account__c=null;
    update l;
    
    
    
    
    

        Test.stopTest();
        }
        
        @isTest static void test3(){
        Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com'
            
          );
          insert l;
          l.Business_Account__c=a1.id;update l;
          Contact contObj = new Contact();
      contObj.LastName = 'Joe';
      contObj.Email = '123@gmail.com';
      contObj.AccountId = a1.id;
      contObj.type__c = 'test';
      contObj.MemberType__c = 'test';
      insert contObj;
          Opportunity opp = new Opportunity(Name = 'Test Opp',
                        StageName = 'Unassigned',
                        CloseDate = Date.Today(),    
                       accountId=a1.id                            
                      ); 

    insert opp;
    //l.Business_Account__c=null;
    //update l;
        Test.stopTest();
        }
                @isTest static void test4(){
        Test.startTest();
    Account a1 = new Account();
    a1.Name = 'NBOS';
    a1.Type = 'Customer';
    a1.Industry = 'Consulting';
    insert a1;
            Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Title = 'TestTitle',
            Phone = '781-642-5984',
            Email = 'sridhar.neeli@care.com'
            
          );
          insert l;
          l.Business_Account__c=a1.id;update l;

    l.Business_Account__c=null;
    update l;
        Test.stopTest();
        }
      }