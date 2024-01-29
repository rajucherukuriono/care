/*
test Class for CloseChildCases
//When closing a US MC Parent Case, close only US MC child cases only that has origin = Web, owner is still owned by a Queue, and Open = True.
//We don’t want to implement this yet for Intl Cases, because when we Cancel/Downgrade for Intl Case, it would Cancel/Downgrade the actual intl member
//We don’t want to impact chat Case so do not including origin = Chat
//MC Cases record type = Standard, MobileCreatedBy : md Ashwaq
CreatedDate: 25/06/2021
*/
@isTest
public class Test_CloseChildCasesHelper {
    public static ID Standard = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    @testSetup static void setupData(){
        Test.startTest();
        
         Group G = [Select Id, DeveloperName FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1]; 
         User u = new User(
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'International Operations Agent'].Id,
        LastName = 'last',
        Email = 'test1user@care.com',
        Username = 'test1user@care.com' + System.currentTimeMillis(),
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
        insert u;
                
        Account a = new Account(Name = 'TestCo');
        insert a;  
        
        
        contact con1=new contact(lastname='caredotcom');
        insert con1;
        
        List<Case> parentC = new List<Case>();    
        Case parentCase1 = new Case(
            ContactId = con1.id,
            AccountID = a.Id, 
            OwnerId = u.Id,
            Subject = 'test Parent Case Satandard',
            Origin = 'Web',
            parentId=null,
            Status = 'New',
            Reason = 'Reason',
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
            RecordTypeId = Standard
        );               
        parentC.add(parentCase1);
        
        Case parentCase2 = new Case(
            ContactId = con1.id,
            AccountID = a.Id, 
            OwnerId = UserInfo.getUserId(),
            Subject = 'test Parent 2',
            Origin = 'Web',
            parentId=null,
            Status = 'ReOpen',
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='French',
            RecordTypeId = Standard
        );               
        parentC.add(parentCase2);
        
        if(!parentC.isEmpty()){
            insert parentC;
        }
                    
        List<Case> lstChild = new List<Case>();
        Case child1 = new Case(
            ContactId = con1.id,
            AccountID = a.Id, 
            OwnerId = u.Id, //G.Id,
            Subject = 'Test Child Case standard 1',
            Origin = 'Web',
            Status = 'New',
            ParentId=parentCase1.Id,
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
            RecordTypeId = Standard
        );
        lstChild.add(child1);
        
        Case child2 = new Case(
            ContactId = con1.id,
            AccountID = a.Id, 
            OwnerId = u.Id, //G.Id,
            ParentId=parentCase1.Id,
            Subject = 'Test Child Case standard 3',
            Origin = 'Web',
            Status = 'New',
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
            RecordTypeId = Standard
        );
        lstChild.add(child2);
        
        Case child3 = new Case(
            ContactId = con1.id,
            AccountID = a.Id, 
            OwnerId = u.Id, //G.Id,
            ParentId=parentCase1.Id,
            Subject = 'Test Child Case standard 4',
            Origin = 'Web',
            Status = 'New',
            Support_Skill__c ='MC: EN Tier 1',
            Member_Language__c ='English',
            RecordTypeId = Standard
        );
        lstChild.add(child3);
        
        if(!lstChild.isEmpty()){
            insert lstChild; 
        }
        Test.stopTest();
    }
    
    
    @isTest
    static void testCloseChildCases1(){
        String standardRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
        Test.startTest();
        Account a= [select id from account limit 1];
        Contact con= [select id from Contact limit 1];
        Group G = [Select Id, DeveloperName FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1];
        List<Id> recIds=new List<Id> {Standard};
        List<Case> parentCase = [SELECT id,ownerId,isClosed, origin, Support_Skill__c, member_language__c, recordTypeId, status FROM Case WHERE ParentId =null and  RecordTypeId IN :recIds];
        list<Case> UpdParentCase = new List<Case>();
        list<Id> pCaseId = new List<Id>();
        for(Case ps: parentCase){
            ps.Status ='Closed';
            ps.contact_reason__c='Other';
            ps.contact_secondary_reason__c='Other';
            ps.contact_theme__c='Other';
            ps.Sentiment__c='Positive';
            pCaseId.add(ps.Id);
            UpdParentCase.add(ps);            
        }
        update UpdParentCase;
        
        
        List<Case> childCase = [SELECT id,ownerId,isClosed, origin, Support_Skill__c, member_language__c, recordTypeId, status FROM Case WHERE OwnerId =:G.id and parentId IN:pCaseId AND RecordTypeId IN :recIds ];
        list<Case> UpdchildCase = new List<Case>();
        for(Case c: childCase){
            c.Status ='Closed';   
            c.contact_reason__c='Background Checks';
            c.contact_secondary_reason__c='Ability to Apply';
            c.contact_theme__c='Safety';
            c.Sentiment__c='Negative';
        }
        update UpdchildCase;
        
        
        
        for(case lc: UpdchildCase){
            System.assertEquals('Closed', lc.status);
            //System.assertEquals('00G', String.valueOf(c.ownerId).left(3), 'Case should be owned by a queue.');
        }
        Test.stopTest();
    }
    
    
}