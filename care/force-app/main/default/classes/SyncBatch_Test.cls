@IsTest
public class SyncBatch_Test {
     Public static Id Caseret = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LifeCare').getRecordTypeId();
     Public static Id taskret = Schema.SObjectType.task.getRecordTypeInfosByName().get('LifeCare').getRecordTypeId();
     private static ID BAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
     private static ID PContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
@IsTest
    public static void testbatch(){
        Test.startTest();
                Override_Apex_Triggers__c ovrdeCaseTrg = new  Override_Apex_Triggers__c(
       		TriggerDisabled__c = false,
            Name ='Case'
        );
        insert ovrdeCaseTrg;
        Account at = new Account(
							name = 'Testa=Acct',
							recordtypeid = BAccount,
                            Provide_Benefits_for_Employee__c=True
							);
		insert at; 
         Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                Web_External_Member_ID__c = 'testMemberId',
                Origin = 'Email',
            	recordTypeId =Caseret,
                Service_Type__c='Aging',
                Business_Account_w_Benefits__c=at.id,
                Question1__c='Mandatory Referral',
                Question2__c='CISD',
                Question3__c='Manager' ,
                Question4__c='Pet Benefit',
                Question5__c='Family',
                Question6__c='Colleague' ,
                Question7__c='Prenatal consult' ,
                Question8__c='Wills',
                Question9__c='Location',
                Quick_Code_Case_Type__c='ACC'
                
              
            );
        insert c;
        
        task products = new task(Lifecare_Activity_Type__c='Needs Assessment Completed',
                                Care_to_Begin__c=system.today(),WhatId=c.id,
                                status='Open',recordtypeId=taskret);
        insert products;
        task products2 = new task(Lifecare_Activity_Type__c='Research',
                                Care_to_Begin__c=system.today(),WhatId=c.id,
                                status='Open',recordtypeId=taskret);
        insert products2;
               
		Contact ct = new Contact(
							accountid = c.AccountId,
							recordtypeid = PContact,
							firstName = 'Daniel',
							lastName = 'Koffee',
							referral_fee__c = 250,
							referral_gift_card__c = 225,
							gift__c = true,
							gift_notes__c = 'Notes on the Contact'
							);
		insert ct;
        Care_Recipient__c Crp3 = new Care_Recipient__c(FirstName__c='test1',
								LastName__c='test2',
								DateOfBirth__c=system.today(),
								Relationship_to_Seeker__c='Cousin',
								Street_Address__c=' 23 lion dr',
                                City__c='frisco',
								State__c='Tx',
                                Country__c='USA',
                                Zip_Code__c='67887',	
                                Case__c=c.id,
                                Contact_Name__c=ct.Id
                                                       
                                );
        insert Crp3;
        SynCaseWrapper testWraper = new SynCaseWrapper();
        SynCaseWrapper.ClsCreateCompIntfcLCSFCASECI obj= new SynCaseWrapper.ClsCreateCompIntfcLCSFCASECI();
         Test.setMock(HttpCalloutMock.class, new SyncCaseMockHttpservices());
        database.executeBatch(new SyncBatch(),1);
        test.stopTest();
        
    }
    @IsTest
    public static void testdoSyncCase(){
        
        Test.startTest();
                Override_Apex_Triggers__c ovrdeCaseTrg = new  Override_Apex_Triggers__c(
       		TriggerDisabled__c = false,
            Name ='Case'
        );
        insert ovrdeCaseTrg;
         Account at = new Account(
							name = 'Testa=Acct',
							recordtypeid = BAccount,
                            Provide_Benefits_for_Employee__c=True
							);
         Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                CaseTriage__c=false,
                Web_External_Member_ID__c = 'testMemberId',
                Origin = 'Email',
            	recordTypeId =Caseret,
                 Question1__c='Mandatory Referral',
                Question2__c='CISD',
                Question3__c='Manager' ,
                Question4__c='Pet Benefit',
                Question5__c='Family',
                Question6__c='Colleague' ,
                Question7__c='Prenatal consult' ,
                Question8__c='Wills',
                Question9__c='Location'
            );
        insert c;
         task products = new task(Lifecare_Activity_Type__c='Needs Assessment Completed',//added
                                Care_to_Begin__c=system.today(),WhatId=c.id,
                                status='Open',recordtypeId=taskret);
        insert products;
        task products2 = new task(Lifecare_Activity_Type__c='Research',
                                Care_to_Begin__c=system.today(),WhatId=c.id,
                                status='Open',recordtypeId=taskret);
        insert products2;
        Contact ct = new Contact(   //added
							accountid = c.AccountId,
							recordtypeid = PContact,
							firstName = 'Daniel',
							lastName = 'Koffee',
							referral_fee__c = 250,
							referral_gift_card__c = 225,
							gift__c = true,
							gift_notes__c = 'Notes on the Contact'
							);
		insert ct;
        Care_Recipient__c Crp3 = new Care_Recipient__c(FirstName__c='test1',
								LastName__c='test2',
								DateOfBirth__c=system.today(),
								Relationship_to_Seeker__c='Cousin',
								Street_Address__c=' 23 lion dr',
                                City__c='frisco',
								State__c='Tx',
                                Country__c='USA',
                                Zip_Code__c='67887',	
                                Case__c=c.id,
                                Contact_Name__c=ct.Id
                                                       
                                );
        insert Crp3; //added
        
        list<case> caselist = new list<case>();
        caselist.add(c);
         Test.setMock(HttpCalloutMock.class, new SyncCaseMockHttpservices());
         SyncCase.doSyncCase(caselist);
         SyncBatch myClass = new SyncBatch ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
        
        
    }
}