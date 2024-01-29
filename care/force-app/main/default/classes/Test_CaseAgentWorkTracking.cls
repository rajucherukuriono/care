/*
Helper Class for CaseAgentWorkTracking
Description:  Created for Case Agent Work Tracking
CreatedBy : md Ashwaq
CreatedDate: 12/11/2021
*/
@IsTest
public class Test_CaseAgentWorkTracking {
    Public static Id Strd = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    
    @testSetup static void setup() {
        Override_Apex_Triggers__c ovrdeCaseTrg = new  Override_Apex_Triggers__c(
            TriggerDisabled__c = false,
            Name ='Case'
        );
        insert ovrdeCaseTrg;
        
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
        
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'International Operations Agent'].Id,
            LastName = 'last2',
            Email = 'test2user@care.com',
            Username = 'test2user@care.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'ali2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        
        Group G_Sales = [Select Id, DeveloperName,Name FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1]; 
        
        Case c = new Case(
            subject='basicSeeker1',
            Member_Language__c = 'English',
            ownerId =u.Id,
            Member_Account_Type__c = 'Basic',
            Member_Type__c = 'Seeker',
            Member_Overall_Status__c ='Active Basic',
            Safety_Email__c =false,
            Status='New',
            origin='Email',
            recordTypeId =Strd,
            Support_Skill__c ='MC: EN Tier 1',
            MC_Email__c= false
        );
        insert c;
        
        Case c1 = new Case(
            subject='basicSeeker2',
            Member_Language__c = 'English',
            ownerId =G_Sales.Id,
            Member_Account_Type__c = 'Basic',
            Member_Type__c = 'Seeker',
            Member_Overall_Status__c ='Active Basic',
            Safety_Email__c =false,
            Status='New',
            origin='Email',
            recordTypeId =Strd,
            Support_Skill__c ='MC: EN Tier 1',
            MC_Email__c= false
        );
        insert c1;
        
        Case c2 = new Case(
            subject='basicSeeker3',
            Member_Language__c = 'English',
            ownerId =u1.Id,
            Member_Account_Type__c = 'Basic',
            Member_Type__c = 'Seeker',
            Member_Overall_Status__c ='Active Basic',
            Safety_Email__c =false,
            Status='New',
            origin='Email',
            recordTypeId =Strd,
            Support_Skill__c ='MC: EN Tier 1',
            MC_Email__c= false
        );
        insert c2;
        Agent_Work__C ag= new Agent_Work__C(
            Case__c = c.id,
            Status__c ='Open',
            OwnerId = c.OwnerId,                 
            Agent_Lookup__c = c.OwnerId,
            Start_Date_Time__c = datetime.now() -2
        );
        insert ag;
        Agent_Work__C ag1= new Agent_Work__C(
            Case__c = c2.id,
            Status__c ='Open',
            OwnerId = c2.OwnerId,                 
            Agent_Lookup__c = c2.OwnerId,
            Start_Date_Time__c = datetime.now() -2
        );
        insert ag1;
        
    }
    
     
    
    //Scenario2
    //Queue to user
    @IsTest
    public static void testCaseQueue2UserTrigger(){
        Test.startTest();           
        user u = [select id from user where email='test1user@care.com'];
        Group G_Sales = [Select Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1]; 
        Case cse = [select id from case where OwnerId=:G_Sales.Id];
       	cse.OwnerId = u.Id;
        update cse;
        
        Agent_Work__C ag= new Agent_Work__C(
            Case__c = cse.id,
            Status__c ='Open',
            OwnerId = cse.OwnerId,                 
            Agent_Lookup__c = cse.OwnerId,
            Start_Date_Time__c = datetime.now()
        );
        insert ag;
        Test.stopTest();
    }
    
    //Scenario2
    //Queue to user - onHold
    @IsTest
    public static void testCaseQueue2UseronHold(){
        Test.startTest();   
        user u = [select id from user where email='test1user@care.com'];
        user u1 = [select id from user where email='test2user@care.com'];
        Case cse2 = [select id, OwnerId from case where OwnerId= :u.Id];
        Agent_Work__c Agentwrk = [Select id , status__c from Agent_Work__c where Case__c = :cse2.Id];
        
        cse2.Status = 'On Hold';
        update cse2;
        
        Agentwrk.Status__c ='Closed';
        Agentwrk.End_Date_Time__c = datetime.now();
        update Agentwrk;
        
        Agent_Work__C ag1= new Agent_Work__C(
            Case__c = cse2.id,
            Status__c =cse2.Status,
            OwnerId = cse2.OwnerId,                 
            Agent_Lookup__c = cse2.OwnerId,
            Start_Date_Time__c = datetime.now()
        );
        insert ag1;
        
        
        Test.stopTest();
    }
    
    //Scenario2
    //Queue to user - Closed
    @IsTest
    public static void testCaseQueue2UserClosed(){
        Test.startTest();   
        user u = [select id from user where email='test1user@care.com'];
        user u1 = [select id from user where email='test2user@care.com'];
        Case cse2 = [select id, OwnerId from case where OwnerId= :u.Id];
        Agent_Work__c Agentwrk = [Select id , status__c from Agent_Work__c where Case__c = :cse2.Id];
        
        cse2.Status = 'Closed';
        cse2.contact_Theme__c='Safety';
        cse2.contact_reason__c='Safety Communication';
        cse2.contact_secondary_reason__c='Other';
        cse2.Sentiment__c='Positive';
        update cse2;
        
        Agentwrk.Status__c ='Closed';
        Agentwrk.End_Date_Time__c = datetime.now();
        update Agentwrk;
        
        Agent_Work__C ag1= new Agent_Work__C(
            Case__c = cse2.id,
            Status__c =cse2.Status,
            OwnerId = cse2.OwnerId,                 
            Agent_Lookup__c = cse2.OwnerId,
            Start_Date_Time__c = datetime.now()
        );
        insert ag1;
        
        
        Test.stopTest();
    }
    
    //Scenario2
    //Queue to user - Closed
    @IsTest
    public static void testCaseQueue2UserEscalated(){
        Test.startTest();   
        user u = [select id from user where email='test1user@care.com'];
        user u1 = [select id from user where email='test2user@care.com'];
        Case cse2 = [select id, OwnerId from case where OwnerId= :u.Id];
        Agent_Work__c Agentwrk = [Select id , status__c from Agent_Work__c where Case__c = :cse2.Id];
        
        cse2.Status = 'Escalated';
        cse2.contact_Theme__c='Safety';
        cse2.contact_reason__c='Safety Communication';
        cse2.contact_secondary_reason__c='Other';
        cse2.Sentiment__c='Positive';
        update cse2;
        
        Agentwrk.Status__c ='Escalated';
        Agentwrk.End_Date_Time__c = datetime.now();
        update Agentwrk;
        
        Agent_Work__C ag1= new Agent_Work__C(
            Case__c = cse2.id,
            Status__c =cse2.Status,
            OwnerId = cse2.OwnerId,                 
            Agent_Lookup__c = cse2.OwnerId,
            Start_Date_Time__c = datetime.now()
        );
        insert ag1;
        
        
        Test.stopTest();
    }
    
    
    //Scenario3 - process builder
    //Queue to user 
    @IsTest
    public static void testCaseQueue2User(){
        Test.startTest();           
            user u = [select id from user where email='test1user@care.com'];
            Group ENTier1 = [Select Id, DeveloperName, Name FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1]; 
            Case cse = [select id from case where OwnerId=:ENTier1.Id];
            cse.OwnerId = u.Id;
            update cse;
            
            Agent_Work__C ag= new Agent_Work__C(
                Case__c = cse.id,
                Status__c ='Open',
                OwnerId = cse.OwnerId,                 
                Agent_Lookup__c = cse.OwnerId,
                Start_Date_Time__c = datetime.now()
            );
            insert ag;
            
            CaseAgentWorkTracking.createAgentWork(new List<Id>{ cse.Id });    
        Test.stopTest();
    }
    
    
    //Scenario4 - process builder
    //Queue to user 
    @IsTest
    public static void testCaseOwnerChange(){
        Test.startTest();           
            user u1 = [select id from user where email='test1user@care.com'];
        	user u2 = [select id from user where email='test2user@care.com'];
            Group ENTier1 = [Select Id, DeveloperName, Name FROM Group WHERE DeveloperName = 'MC_EN_Tier_1' LIMIT 1]; 
            Case cse = [select id from case where OwnerId=:ENTier1.Id];
            cse.OwnerId = u1.Id;
            update cse;
        	cse.OwnerId = u2.Id;
            update cse;
            
            Agent_Work__C ag= new Agent_Work__C(
                Case__c = cse.id,
                Status__c ='Open',
                OwnerId = cse.OwnerId,                 
                Agent_Lookup__c = cse.OwnerId,
                Start_Date_Time__c = datetime.now()
            );
            insert ag;
            
            CaseAgentWorkTracking.createAgentWork(new List<Id>{ cse.Id });    
        Test.stopTest();
    }
}