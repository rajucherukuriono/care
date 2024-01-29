@isTest
public class OpenTask_Test {
    
    @isTest 
    static void OpenActivityCases()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testasass238712367@testorg.com');
        Account a = new Account(Name='TestAccount',Provide_Benefits_for_Employee__c=True);
        insert a;
        update a;
        
        Id LifecareRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('LifeCare').getRecordTypeId();
        List<Case> LstCases = new list<Case>();  
        
        Case caseObj1 = new Case(Status = 'New',Origin = 'Web',RecordTypeId =LifecareRecordTypeId,Program_ID__c='CAREATWORK',Service_Type__c='Aging',Quick_Code_Case_Type__c='Benefits Communication',Business_Account_w_Benefits__c=a.id);
        LstCases.add(caseObj1);
        Case caseObj2 = new Case(Status = 'New',Origin = 'Web',RecordTypeId =LifecareRecordTypeId,Program_ID__c='CAREATWORK',Service_Type__c='Aging',Quick_Code_Case_Type__c='Benefits Communication',Business_Account_w_Benefits__c=a.id);
        LstCases.add(caseObj2);
        Case caseObj3 = new Case(Status = 'New',Origin = 'Web',RecordTypeId =LifecareRecordTypeId,Program_ID__c='CAREATWORK',Service_Type__c='Aging',Quick_Code_Case_Type__c='Benefits Communication',Business_Account_w_Benefits__c=a.id);
        LstCases.add(caseObj3);
        insert LstCases;
        test.startTest();
        
        update new List<case>{caseObj1,caseObj2,caseObj3};
            List<Case> LifeCareCases =[SELECT ID, RecordTypeId, Status From Case where RecordTypeId=: LifecareRecordTypeId]; 
        try{
            For(Case CS:LifeCareCases){
                CS.Syc_Status_message__c='DONE';
                CS.Status='Closed';
            }
            Update LifeCareCases;
        }catch(Exception e){
            System.assert(e.getMessage().contains('Update failed')); 
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(e.getMessage().contains('Please Complete all Open Activities'));
        }
        
        test.stopTest();
        Task t1 = new Task(Subject='Test Task',Status='Not Started',Priority='Normal',whatid=caseObj1.id);
        insert t1;
        Update t1;
        
    }
    
}