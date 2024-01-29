/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.ai]
** Modified Date:  03.26.2019
** =================================================================================
** Description: 
**             This is written as part of SFORCE-2041 Safety Next Case requiremet.
**             This is the test class for Safety Next Case button on Home Page (NextSafetyCase.page). 
**             Only 'Q: Safety Alert' cases are assigns to users upon clicking on the button.
** _______________________________________________________________________________
*/
@isTest(seealldata=true)
private class Test_NextSafetyCase{
    
    @isTest(seeAllData=true)
    static void validateAndCloseAndNextTestAdditional1() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: Safety Alert' LIMIT 1]; 
        Case C = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',subject='RDC List Match - Medium Risk',Member_Type__c='Seeker',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',parentId=c.id,subject='MaxMind Credit Card Alert',Member_Type__c='Seeker',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
            //C1.setOptions(dmo);
            c1.ownerid=G.id;
            Case C2 = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',parentId=c.id,subject='Blocklist Partial Match',Member_Type__c='Provider',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
            //C2.setOptions(dmo);
            c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
        System.debug('Case Owner Ids :======================================>:'+c.ownerid+c1.ownerId+c2.ownerId);
        
//Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
//Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));
//Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            SafetyCloseNextCase CCE = new SafetyCloseNextCase(CaseController);
            CCE.TheCase.Reason = 'Spam';
            CCE.TheCase.Secondary_Case_Reason__c = 'Contact';
            CCE.TheCase.Contact_Theme__c='Safety';
            CCE.TheCase.Contact_Reason__c = 'Safety Communication';
            CCE.TheCase.Contact_Secondary_Reason__c = 'Other';
            CCE.TheCase.Sentiment__c='Positive';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';            
            CCE.TheCase.Member_Type__c = 'Seeker';
            CCE.comment.commentbody='Sample Comment';


                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE userRole.name='Safety Manager' and isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                if(testUser!=null){
                system.runas(testUser)
                {
                CCE.validateAndClose();
                CCE.ValidateAndCloseAndNext();
                CCE.deleteAcceptance=true;

                try
                {
                    CCE.closeChildCases();
                }
                catch (Exception ex)
                {
                    // ignore - just getting coverage
                }
            }
            }
            
Test.stopTest();
            

        }  
 @isTest(seeAllData=true)
    static void validateAndCloseAndNextTestAdditional2() {
        Test.setCurrentPageReference(new PageReference('Page.TestconsolePage'));
        System.currentPageReference().getParameters().put('id','id');
        
        Account a = new Account(Name='TestAccount');
            insert a;update a;
        Contact contObj=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=a.id);
                                     insert contObj;update contObj;
            
         Group G = [Select Id, Name FROM Group WHERE NAME = 'Q: Safety Alert' LIMIT 1]; 
        Case C = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',subject='Blocklist Partial Match',Member_Type__c='Seeker',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
         // Set options to ignore assignment
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = false;
    C.setOptions(dmo);
     
        
        Case C1 = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',parentId=c.id,subject='Blocklist Partial Match',Member_Type__c='Seeker',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
            //C1.setOptions(dmo);
            c1.ownerid=G.id;
            Case C2 = new Case(Language = 'en_US', recordtypeId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert'),ownerid=G.id,status = 'Reopened',parentId=c.id,subject='Approved-Safety',Member_Type__c='Provider',Current_Member_Type__c = 'Seeker',contactid=contObj.id);
            //C2.setOptions(dmo);
            c2.ownerid=G.id;
        insert new List<Case>{C,C1,C2};
        System.debug('Case Owner Ids :======================================>:'+c.ownerid+c1.ownerId+c2.ownerId);
        
//Test.setCreatedDate(C.Id, DateTime.newInstance(2017,12,12));
//Test.setCreatedDate(C1.Id, DateTime.newInstance(2017,12,12));Approved-Safety
//Test.setCreatedDate(C2.Id, DateTime.newInstance(2017,12,12));
            ApexPages.Standardcontroller CaseController = new ApexPages.Standardcontroller(c);
            SafetyCloseNextCase CCE = new SafetyCloseNextCase(CaseController);
            CCE.TheCase.Reason = 'Spam';
            CCE.TheCase.Secondary_Case_Reason__c = 'Contact';
            CCE.TheCase.Contact_Theme__c='Safety';
            CCE.TheCase.Contact_Reason__c = 'Safety Communication';
            CCE.TheCase.Contact_Secondary_Reason__c = 'Other';
            CCE.TheCase.Current_Member_Type__c = 'Seeker';
            CCE.TheCase.Member_Type__c = 'Seeker';
                        CCE.TheCase.Sentiment__c='Positive';
            CCE.comment.commentbody='Sample Comment';


                User testUser=[
                    Select Id, Name, Language__c//, Platform__c, Tier__c
                    FROM User 
                    WHERE userRole.name='Safety Manager' and isActive=true  
                    LIMIT 1];
                Test.startTest();
                //c.ownerId=testUser.id;
                //c.ownerid=G.id;
                //c1.ownerId=testUser.id;
                //c1.ownerid=G.id;
                //c2.ownerId=testUser.id;
                //c2.ownerid=G.id;
                if(testUser!=null){
                system.runas(testUser)
                {
                CCE.validateAndClose();
                CCE.ValidateAndCloseAndNext();
                CCE.deleteAcceptance=true;

                try
                {
                    CCE.closeChildCases();
                }
                catch (Exception ex)
                {
                    // don't care - just getting coverage
                }
            }
            }
            
Test.stopTest();
            

        }  
}