/*
** _________________________________________________________________________________
** Created by:   SRIDHAR NEELI [sridharn@wavelabs.ai]
** Developer:    SRIDHAR NEELI [sridharn@wavelabs.ai]
** Created Date:  07.28.2014
** Modified Date: 05.18.2019
** =================================================================================
** Description: 
                Assigns Users to domestic/member care queues on member insert or update
                Modified this trigger based on SFORCE-2041 requirement, so that All users
                under Safety Alert,Safety Manager,Senior Safety Manager role users become 
                individual members of the queue 'Q: Safety Alert' upon user record insert 
                or edit(This is mandatory to make the next safety case button works for any 
                safery user).
                
** _______________________________________________________________________________
*/
@isTest(seealldata=false)
private class Test_NextCase {
    
    @testSetup static void setupData(){
        
        // Create system objects required for the tests
        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Name in ('International Operations Agent','System Administrator')];
        Map<String,id> profileNameIdMap=new Map<String,id>();
        for(Profile pro:profileList){
            profileNameIdMap.put(pro.name,pro.id); 
        }
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Dutch Team Agent'];
        List<User> usrInsertList=new List<User>();
        // Create new user with a non-null user role ID
        User u = new User(alias = 'testalia', email='test@care.com',
                          emailencodingkey='UTF-8', 
						  lastname='testLastName',
                          languagelocalekey='en_US',
                          localesidkey='en_US', profileid = profileNameIdMap.get('International Operations Agent'), 
						  userroleid = r.Id,
                          timezonesidkey='America/Los_Angeles',
                          username='test@care.com.nextcaseunittest',
						  //Platform__c = 'International',
                          //Tier__c = '3',
                          Language__c = 'Dutch; German; French; English; Finnish; Danish; Swedish'
                         );
        usrInsertList.add(u);
        
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('DACH Team Lead','DACH Team Agent','English Team Lead','English Team Agent')];
        Map<String,id> usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        
        User adminUser= new User(alias = 'tstadmin', email='testadmin@care.com',
                                emailencodingkey='UTF-8', 
								lastname='testadmin',
                                languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profileNameIdMap.get('System Administrator'), 
                                timezonesidkey='America/Los_Angeles',
                                username='admin@care.com.nextcaseunittest',
								//Platform__c = 'International',
								//Tier__c = '3',
                                Language__c = 'Dutch; German; French;  Finnish; Danish; Swedish');
        
        usrInsertList.add(adminUser);
        
        User dachTeamLeadUser = new User(alias = 'test1', email='test1@care.com',
                                         emailencodingkey='UTF-8', lastname='testLastName',
                                         languagelocalekey='en_US',
                                         localesidkey='en_US', profileid = profileNameIdMap.get('International Operations Agent'), 
                                         timezonesidkey='America/Los_Angeles',
                                         username='test1@care.com.nextcaseunittest',
										 //Platform__c = 'International',
                                         //Tier__c = '1',
                                         Language__c = 'German',
										 userroleid=usrRoleMap.get('DACH Team Lead'));
        usrInsertList.add(dachTeamLeadUser);
        
        User dachTeamLeadAgent = new User(alias = 'test2', email='test2@care.com',
                                          emailencodingkey='UTF-8', lastname='testLastName',
                                          languagelocalekey='en_US',
                                          localesidkey='en_US', profileid = profileNameIdMap.get('International Operations Agent'), 
                                          timezonesidkey='America/Los_Angeles',
                                          username='test2@care.com.nextcaseunittest',
                                          Language__c = 'Dutch; German; French;  Finnish; Danish; Swedish',
										  //Platform__c = 'International',
                                          //Tier__c = '3',
										  userroleid=usrRoleMap.get('DACH Team Agent'));
        usrInsertList.add(dachTeamLeadAgent);
        
        User englishTeamLeadUser = new User(alias = 'test3', email='test3@care.com',
                                            emailencodingkey='UTF-8', lastname='testLastName',
                                            languagelocalekey='en_US',
                                            localesidkey='en_US', profileid = profileNameIdMap.get('International Operations Agent'), 
                                            timezonesidkey='America/Los_Angeles',
                                            username='test3@care.com.nextcaseunittest',
                                            Language__c = 'Dutch; French; English; Finnish; Danish; Swedish',
											//Platform__c = 'International',
                                            //Tier__c = '3',
											userroleid=usrRoleMap.get('English Team Lead'));
        usrInsertList.add(englishTeamLeadUser);
        
        User englishTeamAgentUser = new User(alias = 'test4', email='test4@care.com',
                                             emailencodingkey='UTF-8', lastname='testLastName',
                                             languagelocalekey='en_US',
                                             localesidkey='en_US', profileid = profileNameIdMap.get('International Operations Agent'), 
                                             timezonesidkey='America/Los_Angeles',
                                             username='test4@care.com.nextcaseunittest',
                                             Language__c = 'Dutch; French; English; Finnish; Danish; Swedish',
											 //Platform__c = 'International',
                                             //Tier__c = '3',
											 userroleid=usrRoleMap.get('English Team Agent'));
        usrInsertList.add(englishTeamAgentUser);
        insert usrInsertList;
        
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Write_Access_To_Audit_Fields';
        ps.Label = 'Write Access To Audit Fields';
        
        //Provide write access to audit fields
        ps.PermissionsCreateAuditFields = true;
        insert ps;
        
        //Assign the permission set to the current user   
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = adminUser.id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = dachTeamLeadUser.id;
        psa1.PermissionSetId = ps.Id;
        insert psa1;
        
        Group G = new Group(Name = 'Q: AT: German', Type = 'Queue');
        insert G;
        
                QueuesObject testQueue = new QueueSObject(QueueID = g.id, SObjectType = 'Case');
        insert testQueue;
        
        //Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
        //System.debug('Group ID---------------->>>> GroupID'+G.Id);
        //User U = [Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE username = 'test@care.com.nextcaseunittest'];
        //Case C = new Case(OwnerId = G.Id, status = 'new',Tier__c='1',Tier_Model__c='International',Member_Type__c='Seeker',Origin='Web',Reason='Refund',Secondary_Case_Reason__c='Terms Of Use Violation');
        //Test.startTest();
        GroupMember member = new GroupMember();
        member.UserOrGroupId = u.Id;
        member.GroupId = G.Id;
        insert member;
        //Test.stopTest();
    }
    
    static testMethod void myUnitTestOne() {
        // Test the user update trigger
        
        User U = [
			Select Id, Name, Language__c//, Platform__c, Tier__c
			FROM User 
			WHERE IsActive = true //AND Platform__c != 'International' 
			limit 1];
        U.Language__c = 'Dutch; German; French; English; Finnish; Danish; Swedish';
        //U.Platform__c = 'International';
        //U.Tier__c = '3';
        update U;
        
    }
    
    static testMethod void myUnitTestTwo() {
    CaseHistory_ctrlr CHR_ctrlr = new CaseHistory_ctrlr();
        CHR_ctrlr.refreshUsers();
       Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German' LIMIT 1]; 
       System.debug('Group ID---------------->>>> GroupID'+G.Id);

		User U = [
			Select Id, Name, Language__c//, Platform__c, Tier__c
			FROM User 
			WHERE username = 'test@care.com.nextcaseunittest'];

        //Case C = new Case(OwnerId = G.Id, status = 'new',Tier__c='1',Tier_Model__c='International',Member_Type__c='Seeker',Origin='Web',Reason='Refund',Secondary_Case_Reason__c='Terms Of Use Violation');
       /** Test.startTest();
        GroupMember member = new GroupMember();
        member.UserOrGroupId = U.Id;
        member.GroupId = G.Id;
        insert member;
        Test.stopTest(); */
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId FROM GroupMember 
        WHERE  (not Group.Name like '%Tier%') and Group.Name like 'Q: __: %' and UserOrGroupId =: U.Id];

        system.debug('UserQueues is ------------->>>> :'+UserQueues);
        
        System.debug('Before ---------------->>>> Case creation');
        Case C = new Case(OwnerId = G.Id, status = 'new',Member_Type__c='Seeker',Origin='Web',Reason='Refund',Secondary_Case_Reason__c='Terms Of Use Violation');
        insert new list<Case>{C};
        System.debug('After ---------------->>>> Case creation');
        //C.Tier__c='3';
        //C.Tier_Model__c='International';
 
        list<Case> QueryCases = [Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
                                 FROM Case 
								 WHERE 
									//Tier__c != null and 
									OwnerId = :G.Id and 
									isClosed = false and 
									((Status = 'New') or (Status = 'Reopened' and  recordTypeId ='01270000000Dq7E'))
									ORDER BY Case_Age_Hours_Custom__c DESC,CreatedDate ASC 
									LIMIT 50000];
        //Tier__c != null and
        System.debug('Case List Size---------------->>>> QueryCases'+QueryCases.size()); 
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
           system.runAs(U){
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(C);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            
            OnloadController OLC = new OnloadController();
            OLC.returnLink();
            CCE.ValidateAndClose();
            
               OnLoadController.SObjectWrapper sobj1=new OnLoadController.SObjectWrapper(1);
            OnLoadController.SObjectWrapper sobj2=new OnLoadController.SObjectWrapper(2);
            List<OnLoadController.SObjectWrapper> sobList=new List<OnLoadController.SObjectWrapper>{sobj1,sobj2};
            sobList.sort();   
            OnLoadController.SObjectWrapper temp=sobj2;
           sobj2=sobj1;
           sobj1=temp; 
           sobList.sort();          
            OLC.setDesiredURL(OLC.getDesiredURL());
            }
    }
    static testMethod void myUnitTestThree() {
        CaseHistory_ctrlr CHR_ctrlr = new CaseHistory_ctrlr();
        CHR_ctrlr.refreshUsers();
        Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: US: English' LIMIT 1]; 
        System.debug('Group ID---------------->>>> GroupID'+G.Id);
        User U = [
			Select Id, Name, Language__c//, Platform__c, Tier__c
			FROM User 
			WHERE username = 'test@care.com.nextcaseunittest'];

        //Case C = new Case(OwnerId = G.Id, status = 'new',Tier__c='1',Tier_Model__c='International',Member_Type__c='Seeker',Origin='Web',Reason='Refund',Secondary_Case_Reason__c='Terms Of Use Violation');
       /** Test.startTest();
        GroupMember member = new GroupMember();
        member.UserOrGroupId = U.Id;
        member.GroupId = G.Id;
        insert member;
        Test.stopTest(); */
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId FROM GroupMember 
        WHERE  (not Group.Name like '%Tier%') and Group.Name like 'Q: __: %' and UserOrGroupId =: U.Id];

        system.debug('UserQueues is ------------->>>> :'+UserQueues);
        
        Case C = new Case(OwnerId = G.Id, status = 'new',Member_Type__c='Seeker',Origin='Web',Reason='Refund',Secondary_Case_Reason__c='Terms Of Use Violation');
        insert new list<Case>{C};
       /* System.debug('After ---------------->>>> Case creation');
        C.Tier__c='3';
        C.Tier_Model__c='US';
        C.RecordTypeId='01270000000HlML';
        update C;*/
 
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
           system.runAs(U){
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(C);
            //CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            
            OnloadController OLC = new OnloadController();
            OLC.returnLink();
            //CCE.ValidateAndClose();
            OLC.setDesiredURL('care.com');
            OLC.getDesiredURL();
            }
    }    
    /*
    static testMethod void myUnitTestTwo() {
        // Creates & Updates cases to exercise the logic of the next case button

        CaseHistory_ctrlr CHR_ctrlr = new CaseHistory_ctrlr();
        CHR_ctrlr.refreshUsers();

        CaseHistoryRole__c CHR = new CaseHistoryRole__c(name = 'E-mail Rep');
        insert CHR;
        
        Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: AT: German: Tier 3' LIMIT 1]; 
        User U = [Select Id, Name, Platform__c, Tier__c, Language__c FROM User WHERE username = 'test@care.com.nextcaseunittest'];
        

        
        
        Case C = new Case(OwnerId = G.Id, status = 'new');
        Case C1 = new Case(OwnerId = U.Id, status = 'new');
        insert new list<Case>{C,C1};
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id','id');
        
        system.runAs(U){
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(C);
            CaseCommentExtension CCE = new CaseCommentExtension(CaseController);
            
            OnloadController OLC = new OnloadController();
            OLC.returnLink();
            CCE.ValidateAndClose();
            
            CCE.TheCase.status = 'New';
            CCE.TheCase.Reason = 'reason';
            CCE.TheCase.Secondary_Case_Reason__c = 'sec reason';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.ValidateAndCloseAndNext();
            
            C.OwnerId = G.Id;
            update C;
            
            CCE.TheCase.status = 'New';
            CCE.TheCase.reason = 'Account';
            CCE.TheCase.Secondary_Case_Reason__c = 'Edit';
            CCE.ValidateAndClose();
            CCE.TheCase.status = 'New';
            CCE.ValidateAndCloseAndNext();
            getDesiredUrl();
            setDesiredUrl(null);
            getSortedTierCaseList();
            setSortedTierCaseList(null);
        }
    }
    */
    static testMethod void switchLanguageTest() {
        List<User> usrList = [
			Select Id, Name, Language__c//, Platform__c, Tier__c
			FROM User 
			WHERE username in ('test1@care.com.nextcaseunittest','test2@care.com.nextcaseunittest','test3@care.com.nextcaseunittest','test4@care.com.nextcaseunittest')];
        for(User usr:usrList){
            system.runAs(usr){
                OnloadController OLC = new OnloadController();
                OLC.setSwitchUserToGerman(OLC.getSwitchUserToGerman());
                OLC.setSwitchUserToEnglish(OLC.getSwitchUserToEnglish());
                OLC.switchLanguage();
            }
            
        } 
    }
    
    
    
}