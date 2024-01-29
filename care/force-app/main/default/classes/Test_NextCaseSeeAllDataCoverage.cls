@isTest(seealldata=false)
private class Test_NextCaseSeeAllDataCoverage{
    
    @isTest(seeAllData=false)
    static void finalCaseOrderTest() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        List<User> userList=[
            Select Id, Name, Language__c//, Platform__c, Tier__c
            FROM User 
            WHERE 
                userRole.name='International WPS Ops' and 
                //Tier__c='3' and 
                //Platform__c='International' and 
                Language__c ='German'   
            LIMIT 1];
        if(!userList.isEmpty())
        {
            User dachTeamLeadUser=userList[0];
            id finalCaseid1=null;
            id finalCaseid2=null;
            system.runAs(dachTeamLeadUser)
            {
                OnloadController OLC = new OnloadController();
                OLC.returnLink();
                finalCaseid1=OLC.TheFinalCase!=null?OLC.TheFinalCase.id:null;
                system.debug('finalCaseid1=>:     '+finalCaseid1);
            }
        }
    } 
    
    @isTest(seeAllData=false)
    static void validateAndCloseTest1() {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name in ('International Operations Agent','System Administrator')];
        Map<String,id> profileNameIdMap=new Map<String,id>();
        for(Profile pro:profileList){
            profileNameIdMap.put(pro.name,pro.id); 
        }
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
         Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
                   Account a = new Account(Name='TestAccount');

            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
                 Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1];                              
        Case C = new Case(/*Tier__c='1',*/ownerid=G.id,status = 'new',subject='Parent Test',contactid=contObj.id);
         C.setOptions(dmo);
        insert c;
        system.debug('c.ownerid 1=============>:'+c.ownerid);
        Case C1 = new Case(/*Tier__c='1',*/ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',contactid=contObj.id);
         C1.setOptions(dmo);
        insert c1;
        
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';
            
            CCE.ValidateAndClose();
            List<case> childCases=[select id,status,Reason,Secondary_Case_Reason__c,Current_Member_Type__c from case where parentid=:c.id];
            system.debug('childCases==>:'+childCases);
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
            c.status='New';
            //c.ownerid=G.id;
             C.setOptions(dmo);
            c1.status='New';
            //c1.ownerid=G.id;
             C1.setOptions(dmo);
            update new List<case>{c,c1};
                CaseController = new ApexPages.Standardcontroller(c);
            CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';
            
            CCE.ValidateAndClose();
            /*
            CCE.deleteAcceptance=false;
            CCE.ValidateAndClose();
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
            */
            Test.stopTest();
    } 
    @isTest(seeAllData=false)
    static void validateAndCloseTest2() {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name in ('International Operations Agent','System Administrator')];
        Map<String,id> profileNameIdMap=new Map<String,id>();
        for(Profile pro:profileList){
            profileNameIdMap.put(pro.name,pro.id); 
        }
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
         Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
                   Account a = new Account(Name='TestAccount');

            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
                 Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1];                              
        Case C = new Case(/*Tier__c='1',*/ownerid=G.id,status = 'new',subject='Parent Test',contactid=contObj.id);
         C.setOptions(dmo);
        insert c;
        system.debug('c.ownerid 1=============>:'+c.ownerid);
        Case C1 = new Case(/*Tier__c='1',*/ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',contactid=contObj.id);
         C1.setOptions(dmo);
        insert c1;
        
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';
            
            CCE.ValidateAndClose();
            List<case> childCases=[select id,status,Reason,Secondary_Case_Reason__c,Current_Member_Type__c from case where parentid=:c.id];
            system.debug('childCases==>:'+childCases);
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
            c.status='New';
            //c.ownerid=G.id;
             C.setOptions(dmo);
            c1.status='New';
            //c1.ownerid=G.id;
             C1.setOptions(dmo);
            update new List<case>{c,c1};
                CaseController = new ApexPages.Standardcontroller(c);
            CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';
            
            //CCE.ValidateAndClose();
            
            CCE.deleteAcceptance=false;
            CCE.ValidateAndClose();
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
            
            Test.stopTest();
    }           
   /* 
    @isTest(seeAllData=false)
    static void validateAndCloseAndNextTest() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name in ('International Operations Agent','System Administrator')];
        Map<String,id> profileNameIdMap=new Map<String,id>();
        for(Profile pro:profileList){
            profileNameIdMap.put(pro.name,pro.id); 
        }
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
                 Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
                       Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
                 Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1];                              
        Case C = new Case(Tier__c='1',ownerid=G.id,status = 'new',subject='Parent Test',contactid=contObj.id);
        C.setOptions(dmo);
        insert c;
        
        Case C1 = new Case(Tier__c='1',ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',contactid=contObj.id);
        C1.setOptions(dmo);
        insert c1;

            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';
            CCE.ValidateAndCloseAndNext();
            List<case> childCases=[select id,status,Reason,Secondary_Case_Reason__c,Current_Member_Type__c from case where parentid=:c.id];
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
            c.status='New';
            //c.ownerid=G.id;
            c1.status='New';
            C.setOptions(dmo);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            update new List<case>{c,c1};
            CaseController = new ApexPages.Standardcontroller(c);
            CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Provider';
            CCE.comment.commentbody='Sample Comment';
            CCE.deleteAcceptance=false;
            CCE.ValidateAndCloseAndNext();
            for(Case caseObj:childCases){
                system.debug('Child Cases Inheritance from parent (ValidateAndClose)==>:');
                system.debug('CCE.deleteAcceptance =>:'+CCE.deleteAcceptance);
                system.debug('CCE.TheCase.Reason==caseObj.Reason =>:'+CCE.TheCase.Reason+'<====>'+caseObj.Reason);
                system.debug('CCE.TheCase.Secondary_Case_Reason__c==caseObj.Secondary_Case_Reason__c =>:'+CCE.TheCase.Secondary_Case_Reason__c+'<====>'+caseObj.Secondary_Case_Reason__c);
                system.debug('CCE.TheCase.Current_Member_Type__c==caseObj.Current_Member_Type__c =>:'+CCE.TheCase.Current_Member_Type__c+'<====>'+caseObj.Current_Member_Type__c);
                system.debug('caseObj.status==\'Closed\' =>:'+caseObj.status);
            }
        } 
        */
        @isTest(seeAllData=false)
    static void finalCaseOrderTest1() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
                Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
        //List<User> intlUserList=[Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE userRole.name='International WPS Ops' and Tier__c='3' and Platform__c='International' and Language__c ='German' and  isActive=true  LIMIT 1];
        List<User> intlUserList=[
            Select Id, Name, Language__c//, Platform__c, Tier__c
            FROM User 
            WHERE 
                //Tier__c!=null and 
                //Platform__c!=null and 
                Language__c!=null and  
                isActive=true  
            LIMIT 1];
         /*
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'International WPS Ops');
insert r;
       
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
     LocaleSidKey = 'en_US',
     UserRoleId = r.Id
);
insert u;
*/
//List<User> intlUserList=new List<User>{u};

       // FutureUserQueueAssignment.RefreshUserQueueAssignments();
        if(!intlUserList.isEmpty())
        {
            User dachTeamLeadUser=intlUserList[0];
              
            id finalCaseid1=null;
            id finalCaseid2=null;
            system.runAs(dachTeamLeadUser)
            {
                  OnloadController OLC = new OnloadController();
                OLC.returnLink();
                finalCaseid1=OLC.TheFinalCase!=null?OLC.TheFinalCase.id:null;
                system.debug('finalCaseid1=>:     '+finalCaseid1);
            }
        }
    } 
    /*
    @isTest(seeAllData=false)
    static void finalCaseOrderTest2() {
            
                Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
        List<User> usUserList=[Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE userRole.name!=null and Tier__c!=null and Platform__c!=null and Language__c!=null and  isActive=true  LIMIT 1];
        /*
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'English Team Lead');
insert r;
        User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'Operations Manager'].Id,
     LastName = 'last',
     Email = 'test1user@care.com',
     Username = 'test1user@care.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     UserRoleId = r.Id
);
insert u;
List<User> usUserList=new List<User>{u};
*//*
        //FutureUserQueueAssignment.RefreshUserQueueAssignments();
        if(!usUserList.isEmpty())
        {
            User usUser=usUserList[0];
            
                             Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
                       Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
                Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1];                               
        Case C = new Case(Tier__c='1',ownerid=G.id,status = 'new',subject='Parent Test',contactid=contObj.id);
        C.setOptions(dmo);
        insert c;
        
        Case C1 = new Case(Tier__c='1',ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',contactid=contObj.id);
        C1.setOptions(dmo);
        insert c1;
        
        
            id finalCaseid1=null;
            id finalCaseid2=null;
                //c.ownerId=usUser.id;
                //c1.ownerId=usUser.id;

                update new List<Case>{C,C1};
                
            system.runAs(usUser)
            {
                  OnloadController OLC = new OnloadController();
                OLC.returnLink();
                finalCaseid1=OLC.TheFinalCase!=null?OLC.TheFinalCase.id:null;
                system.debug('finalCaseid1=>:     '+finalCaseid1);
            }
        }
    } 
    */
     
    @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestIntlUser() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent','English Team Manager')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactid=contObj.id);
            C2.setOptions(dmo);
            //c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
        update new List<Case>{C,C1,C2};
//Test.setCreatedDate(C.Id, DateTime.newInstance(2012,12,12));
//Test.setCreatedDate(C1.Id, DateTime.newInstance(2012,12,12));
//Test.setCreatedDate(C2.Id, DateTime.newInstance(2012,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.TheCase.Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';

Id theUserId= UserInfo.getUserId();       
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
        system.debug('UserQueues in test Class -->:'+UserQueues);

        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            }
            list<Case> QueryCases = [
                Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
                FROM Case 
                WHERE 
                    //Tier__c!=null and 
                    OwnerId in :userQueueIds and  
                    isClosed = false and 
                    Status = 'New' 
                ORDER BY createdDate ASC 
                LIMIT 50000];
                                 if(CareDotComUtil.runningInASandbox()){
        system.debug('QueryCases in Test Clas-->:'+QueryCases .size());
                system.debug('QueryCases in Test Clas-->:'+QueryCases );
                }
               
                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE 
                        userRole.name='International WPS Ops' and 
                        //Platform__c='International' and 
                        Language__c ='German' and  
                        isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                //update new List<Case>{C,C1,C2};
                if(testUser!=null){
                system.runas(testUser)
                {
                if(CareDotComUtil.runningInASandbox())
                system.debug('Run as testuser group query result=============>:'+[Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId]);
            CCE.ValidateAndCloseAndNext();
            }
            }
            
Test.stopTest();
            

        }  
  
    @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestAdditional1() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent','English Team Manager')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactid=contObj.id);
            C2.setOptions(dmo);
            //c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
        update new List<Case>{C,C1,C2};
Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.TheCase.Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';

Id theUserId= UserInfo.getUserId();       
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
        system.debug('UserQueues in test Class -->:'+UserQueues);

        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            }
            list<Case> QueryCases = [
                Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
                FROM Case 
                WHERE 
                    //Tier__c!=null and 
                    OwnerId in :userQueueIds and  
                    isClosed = false and 
                    Status = 'New' 
                ORDER BY createdDate ASC 
                LIMIT 50000];
                                 if(CareDotComUtil.runningInASandbox()){
        system.debug('QueryCases in Test Clas-->:'+QueryCases .size());
                system.debug('QueryCases in Test Clas-->:'+QueryCases );
                }
               
                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE 
                        userRole.name='International WPS Ops' and 
                        //Platform__c='International' and 
                        Language__c ='German' and  
                        isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                try{
                update new List<Case>{C,C1,C2};
                }catch(Exception e){}
                if(testUser!=null){
                system.runas(testUser)
                {
                if(CareDotComUtil.runningInASandbox())
                system.debug('Run as testuser group query result=============>:'+[Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId]);
            CCE.ValidateAndCloseAndNext();
            }
            }
            
Test.stopTest();
            

        }  
    @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestAdditional2() {
        //Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        /*
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent','English Team Manager')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        */
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactid=contObj.id);
            C2.setOptions(dmo);
            //c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.TheCase.Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';

Id theUserId= UserInfo.getUserId();       
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
        system.debug('UserQueues in test Class -->:'+UserQueues);

        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            }
            list<Case> QueryCases = [
                Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
                FROM Case 
                WHERE 
                    //Tier__c!=null and 
                    OwnerId in :userQueueIds and  
                    isClosed = false and 
                    Status = 'New' 
                ORDER BY createdDate ASC 
                LIMIT 50000];
                                 if(CareDotComUtil.runningInASandbox()){
        system.debug('QueryCases in Test Clas-->:'+QueryCases .size());
                system.debug('QueryCases in Test Clas-->:'+QueryCases );
                }
               
                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE 
                        userRole.name='International WPS Ops' and 
                        //Platform__c='International' and 
                        Language__c ='German' and  
                        isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                //update new List<Case>{C,C1,C2};
                if(testUser!=null){
                system.runas(testUser)
                {
                if(CareDotComUtil.runningInASandbox())
                system.debug('Run as testuser group query result=============>:'+[Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId]);
            CCE.ValidateAndCloseAndNext();
            }
            }
            OnLoadController ol=new OnLoadController();
            OnLoadController.SObjectWrapper sobj1=new OnLoadController.SObjectWrapper(1);
            OnLoadController.SObjectWrapper sobj2=new OnLoadController.SObjectWrapper(2);
            List<OnLoadController.SObjectWrapper> sobList=new List<OnLoadController.SObjectWrapper>{sobj1,sobj2};
            sobList.sort();   
            OnLoadController.SObjectWrapper temp=sobj2;
           sobj2=sobj1;
           sobj1=temp; 
           sobList.sort();          
            ol.setDesiredURL(ol.getDesiredURL());
        Test.stopTest();
            

        }  
         @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestAdditional3() {
        //Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        //System.currentPageReference().getParameters().put('id','id');
        /*
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent','English Team Manager')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        */
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactid=contObj.id);
            C2.setOptions(dmo);
            //c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));

Id theUserId= UserInfo.getUserId();       
                     
                //User testUser=[Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE userRole.name='International WPS Ops' and Platform__c='International' and Language__c ='German' and  isActive=true  LIMIT 1];
                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE name like '%Alice Panzlaff%'  
                    LIMIT 1];
                
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                //update new List<Case>{C,C1,C2};
                if(testUser!=null){
                //system.runas(testUser)
                {

OnloadController OLC = new OnloadController();
                OLC.returnLink();
            }
            }
            OnLoadController ol=new OnLoadController();
            OnLoadController.SObjectWrapper sobj1=new OnLoadController.SObjectWrapper(1);
            OnLoadController.SObjectWrapper sobj2=new OnLoadController.SObjectWrapper(2);
            List<OnLoadController.SObjectWrapper> sobList=new List<OnLoadController.SObjectWrapper>{sobj1,sobj2};
            sobList.sort();   
            OnLoadController.SObjectWrapper temp=sobj2;
           sobj2=sobj1;
           sobj1=temp; 
           sobList.sort();          
            ol.setDesiredURL(ol.getDesiredURL());
        Test.stopTest();
            

        }  
          @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestAdditional4() {
        //Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        //System.currentPageReference().getParameters().put('id','id');
        
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('International WPS Ops','DACH Team Agent','English Team Lead','English Team Agent','English Team Manager')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactid=contObj.id);
            C1.setOptions(dmo);
            //c1.ownerid=G.id;
            Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactid=contObj.id);
            C2.setOptions(dmo);
            //c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
        update new List<Case>{C,C1,C2};
Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));
Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.TheCase.Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';

Id theUserId= UserInfo.getUserId();       
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
        system.debug('UserQueues in test Class -->:'+UserQueues);

        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            }
            list<Case> QueryCases = [
                Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
                FROM Case 
                WHERE 
                    //Tier__c!=null and 
                    OwnerId in :userQueueIds and  
                    isClosed = false and 
                    Status = 'New' 
                ORDER BY createdDate ASC 
                LIMIT 50000];
                                 if(CareDotComUtil.runningInASandbox()){
        system.debug('QueryCases in Test Clas-->:'+QueryCases .size());
                system.debug('QueryCases in Test Clas-->:'+QueryCases );
                }
               
                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE 
                        userRole.name='International WPS Ops' and 
                        //Platform__c='International' and 
                        Language__c ='German' and  
                        isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                update new List<Case>{C,C1,C2};
                if(testUser!=null){
                system.runas(testUser)
                {
                if(CareDotComUtil.runningInASandbox())
                system.debug('Run as testuser group query result=============>:'+[Select Id, GroupId,Group.Name,UserOrGroupId 
                                FROM GroupMember 
                                WHERE  Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId]);
            //CCE.ValidateAndCloseAndNext();
               OnloadController OLC = new OnloadController();
                OLC.returnLink();
            }
            }
            
Test.stopTest();
            

        } 
}