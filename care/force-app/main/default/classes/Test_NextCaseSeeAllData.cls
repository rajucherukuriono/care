@isTest(seealldata=true)
private class Test_NextCaseSeeAllData{
    @isTest(seeAllData=true)
    static void finalCaseOrderTest() {
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
        List<User> userList=[
            Select Id, Name, Language__c//, Platform__c, Tier__c
            FROM User 
            WHERE 
                userRole.name='DACH Team Lead' and 
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
    @isTest(seeAllData=true)
    static void validateAndCloseTest() {
		Test.startTest();   
        Account a = new Account(Name='TestAccount');
        insert a;
        update a;
        Contact contObj=new Contact(firstname='Test',
                                    lastname='Test',
                                    AccountId=a.id);
        insert contObj;
        Case C = new Case(status = 'new',subject='Parent Test',Member_Account_Type__c='Premium',contactid=contObj.id);
        C.Contact_Theme__c='Safety';
        C.Contact_Reason__c = 'Safety Communication';
        C.Contact_Secondary_Reason__c = 'Other';
        C.Sentiment__c='Positive';        
        insert c;
        
        Case C1 = new Case(status = 'new',parentId=c.id,subject='Child Test',Member_Account_Type__c='Premium',contactid=contObj.id);
        C1.Contact_Theme__c='Safety';
        C1.Contact_Reason__c = 'Safety Communication';
        C1.Contact_Secondary_Reason__c = 'Other';
        C1.Sentiment__c='Positive';
        insert c1;
        
        Casecomment cc1=new CaseComment(parentid=c.id,commentBody='TestCommentBody');
        Casecomment cc2=new CaseComment(parentid=c1.id,commentBody='TestCommentBody');
        insert new List<CaseComment>{cc1,cc2};
        ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
        CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
        CCE.TheCase.Reason = 'reason';
        CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
        CCE.TheCase.Current_Member_Type__c = 'Seeker';
        CCE.comment.commentbody='Sample Comment';
        update new List<case>{c,c1};
        CCE.ValidateAndClose();      
        Test.stopTest();
    }  
    // test starts Here
    @isTest(seeAllData=true)
    static void validateAndCloseTest44() {
		Test.startTest();           
        Account a = new Account(Name='TestAccount');
                  insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                    lastname='Test',
                                    AccountId=a.id);
        insert contObj;
        Case C33 = new Case(status = 'new',subject='Parent Test',Origin ='Email',Member_Account_Type__c='Premium',contactid=contObj.id);
        C33.Contact_Theme__c='Blocklist Appeal';
        C33.Appeal_Decision__c = 'Approve';
        C33.Appeal_Decision_Reason__c = 'Blocklist not required';
        C33.Sentiment__c='Positive';
        insert C33; 
        Casecomment cc1=new CaseComment(parentid=c33.id,commentBody='TestCommentBody');
        Casecomment cc2=new CaseComment(parentid=c33.id,commentBody='TestCommentBody');
        insert new List<CaseComment>{cc1}; //,cc2};
        ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c33);
        CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
        CCE.TheCase.Reason = 'reason';
        CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
        CCE.TheCase.Current_Member_Type__c = 'Seeker';
        CCE.comment.commentbody='Sample Comment';
        c33.status='Closed';
        update new List<case>{C33};
        CCE.deleteAcceptance=false;
        CCE.ValidateAndClose();
		Test.stopTest();
    }  
    @isTest(seeAllData=true)
    static void validateAndCloseAndNextTest() {
        Test.startTest();   
        Account a = new Account(Name='TestAccount');
        insert a;
		update a;
        Contact contObj=new Contact(firstname='Test',
                                    lastname='Test',
                                    AccountId=a.id);
        insert contObj;
        
        Case C = new Case(status = 'new',subject='Parent Test',Member_Account_Type__c='Premium',contactid=contObj.id);
        C.Contact_Theme__c='Safety';
        C.Contact_Reason__c = 'Safety Communication';
        C.Contact_Secondary_Reason__c = 'Other';
        C.Sentiment__c='Positive';
        insert c;
        
        Case C1 = new Case(status = 'new',parentId=c.id,subject='Child Test',Member_Account_Type__c='Premium',contactid=contObj.id);
        C1.Contact_Theme__c='Safety';
        C1.Contact_Reason__c = 'Safety Communication';
        C1.Contact_Secondary_Reason__c = 'Other';
        C1.Sentiment__c='Positive';
        insert c1;
        
        Casecomment cc1=new CaseComment(parentid=c.id,commentBody='TestCommentBody');
        Casecomment cc2=new CaseComment(parentid=c1.id,commentBody='TestCommentBody');
        insert new List<CaseComment>{cc1,cc2};
        ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
        CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
        CCE.TheCase.Reason = 'reason';
        CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
        CCE.TheCase.Current_Member_Type__c = 'Seeker';
        CCE.comment.commentbody='Sample Comment';
        CCE.ValidateAndClose();
        CCE.ValidateAndCloseAndNext();
        CCE.deleteAcceptance=false;
		Test.stopTest();
    }      
    @isTest(seeAllData=false)
    static void finalCaseOrderTest1() {
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
        Account a = new Account(Name='TestAccount');
        insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                    lastname='Test',
                                    AccountId=a.id);
        insert contObj;update contObj;
        //List<User> intlUserList=[Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE userRole.name='DACH Team Lead' and Tier__c='3' and Platform__c='International' and Language__c ='German' and  isActive=true  LIMIT 1];
        List<User> intlUserList=[
            Select Id, Name, Language__c//, Platform__c, Tier__c
            FROM User 
            WHERE 
                //Tier__c!=null and 
                //Platform__c!=null and 
                Language__c!=null and  
                isActive=true  
            LIMIT 1];
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
    @isTest(seeAllData=false)
    static void finalCaseOrderTest2() {
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
        List<User> usUserList=[
            Select Id, Name, Language__c//, Platform__c, Tier__c
            FROM User 
            WHERE 
                userRole.name!=null and 
                //Tier__c!=null and 
                //Platform__c!=null and 
                Language__c!=null and  
                isActive=true  
            LIMIT 1];
        //FutureUserQueueAssignment.RefreshUserQueueAssignments();
        if(!usUserList.isEmpty())
        {
            User usUser=usUserList[0];
            id finalCaseid1=null;
            id finalCaseid2=null;
            system.runAs(usUser)
            {
                OnloadController OLC = new OnloadController();
                OLC.returnLink();
                finalCaseid1=OLC.TheFinalCase!=null?OLC.TheFinalCase.id:null;
                system.debug('finalCaseid1=>:     '+finalCaseid1);
            }
        }
    } 
    @isTest(seeAllData=false)
    static void validateAndCloseAndNextTestIntlUser() {
       Test.startTest();
        Account a = new Account(Name='TestAccount');
        insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                    lastname='Test',
                                    AccountId=a.id);
        insert contObj;update contObj;
        Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        Case C = new Case(ownerid=G.id,status = 'new',subject='Parent Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactId=contObj.id,Member_Account_Type__c='Premium');
        // Set options to ignore assignment
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        C.setOptions(dmo);
        C.Contact_Theme__c='Safety';
        C.Contact_Reason__c = 'Safety Communication';
        C.Contact_Secondary_Reason__c = 'Other';
        C.Sentiment__c='Positive';
        Case C1 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Seeker'/*,Tier__c='1'*/,contactId=contObj.id,Member_Account_Type__c='Premium');
        C1.setOptions(dmo);
                C1.Contact_Theme__c='Safety';
        C1.Contact_Reason__c = 'Safety Communication';
        C1.Contact_Secondary_Reason__c = 'Other';
        C1.Sentiment__c='Positive';
        Case C2 = new Case(ownerid=G.id,status = 'new',parentId=c.id,subject='Child Test',Member_Type__c='Provider'/*,Tier__c='1'*/,contactId=contObj.id,Member_Account_Type__c='Premium');
        C2.setOptions(dmo);
                C2.Contact_Theme__c='Safety';
        C2.Contact_Reason__c = 'Safety Communication';
        C2.Contact_Secondary_Reason__c = 'Other';
        C2.Sentiment__c='Positive';
        insert new List<Case>{C}; //,C1,C2};
            update new List<Case>{C}; //,C1,C2};
         Casecomment cc1=new CaseComment(parentid=c.id,commentBody='TestCommentBody');
       // Casecomment cc2=new CaseComment(parentid=c1.id,commentBody='TestCommentBody');
        insert new List<CaseComment>{cc1}; //,cc2};
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
                                        WHERE  (Group.Name like '%Tier%') and Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
            system.debug('UserQueues in test Class -->:'+UserQueues);
        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
        }
        list<Case> QueryCases = [Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
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
                userRole.name='DACH Team Agent' and 
                //Platform__c='International' and 
                Language__c ='German' and  
                isActive=true  
            LIMIT 1];
        if(testUser!=null){
            system.runas(testUser)
            {
                if(CareDotComUtil.runningInASandbox())
                    system.debug('Run as testuser group query result=============>:'+[Select Id, GroupId,Group.Name,UserOrGroupId 
                                                                                      FROM GroupMember 
                                                                                      WHERE  (Group.Name like '%Tier%') and Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId]);
                CCE.ValidateAndCloseAndNext();
                CCE.getActionTimeValue();
                //CCE.closeChildCases();
                CCE.isInternationalCase();
                }
        }
        Test.stopTest();
    }  
}