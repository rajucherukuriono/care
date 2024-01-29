/*
** _________________________________________________________________________________
** Created by:    Eustace Consulting [www.eustaceconsulting.com]
** Developer:     Liam Stokinger, Software Developer [Liam@eustaceconsulting.com]
** Developer:     Zach Buzaid, Software Development Intern [Zachary@eustaceconsulting.com]
** Developer:     Jen Blair, Salesforce Architect [Jen@eustaceconsulting.com]
** Modified by:   NBOS Technologies [http://nbostechnologies.com/]
** Developer:     Sridhar Neeli, Software Developer [sridharn@nbostech.com]
** Modified Date:  04.26.2016
** Modified Date:  05.24.2016
** Modified Date:  12.16.2016
** Modified Date:  04.11.2018
** =================================================================================
** Description: 
**             Controller for Next Case button on Home Page (caseFinderButton.page). This 
**             controller is also used by the controller (CaseCommentExtension.cls) for the 
**             Close Case publisher action (closeCase.page).
**             Added Switch me to German Team and Switch me to English Team buttons on home pagea
**             to swap the user between German and English queues which removes the extra overhead  
**             to theadmin to change user language.
**             Fine tuned next case logic, reduced the amount of code, and overcome the cyclic redundancy error.
**             Enitire next case logic is been modified as part of SF-979 Flexible Tiers Project.
** _______________________________________________________________________________
*/
public without sharing class OnLoadController{
    
    public boolean dispError {get; set;}
    
    public list<Case> UpdateList {get; set;}
    
    public boolean openconsoletabbool {get; set;}
    
    private String desiredURL;

    public string getDesiredURL(){return this.desiredURL;}
    
    public void setDesiredURL(String desiredURL){this.desiredURL=desiredURL;}
    
    public case TheFinalCase {get; set;}
    
    public Integer QueryThreshold {get; set;}

    public Map<String,List<Case>> tierCaseMap{get;set;}
    
    public Map<String,Case> slaExceededCaseMap{get;set;}
    
    public boolean tryAgain {get; set;}
    
    private Integer Queries_Limit = 0;
    
    private Id TheUserId;
    
    //private Map<String, SLA_Exceeded_Amount__c> SLAMap;
    
    Map<String,SLA_Thresholds_by_Country_Member_Type__mdt> SLAThresholdByCMTypeMap;
    
    Map<String,id> usrRoleMap{get;set;}
    
    List<Case> intlCasesWithoutTier=new List<Case>();

    public String uiThemeDisplayed {get;set;}
    
    public OnLoadController() {
        
        uiThemeDisplayed = UserInfo.getUiThemeDisplayed();

        loginUser=
			[SELECT id,language__c,UserRole.Name//,Platform__c,Tier__c
			FROM USER 
			WHERE ID=:UserInfo.getUserId()][0];
        
        tierCaseMap=new Map<String,List<Case>>();
        
        slaExceededCaseMap=new Map<String,Case>();        
        
        List<UserRole> usrRoleList=[SELECT Id,Name FROM UserRole where name in ('DACH Team Lead','DACH Team Agent','English Team Lead','English Team Agent')];
        usrRoleMap=new Map<String,id>();
        for(UserRole usrRoleObj:usrRoleList){
            usrRoleMap.put(usrRoleObj.name,usrRoleObj.id);
        }
        
        openconsoletabbool = false;
        TheFinalCase = new case();
        
        TheUserId = UserInfo.getUserId();
        
        //SLAMap = SLA_Exceeded_Amount__c.getAll();
        SLAThresholdByCMTypeMap=new Map<String,SLA_Thresholds_by_Country_Member_Type__mdt>();
        for (SLA_Thresholds_by_Country_Member_Type__mdt slaThreshold : [SELECT DeveloperName,Id,Label,Default_SLA__c,Provider_SLA__c,Seeker_SLA__c,QualifiedApiName FROM SLA_Thresholds_by_Country_Member_Type__mdt])
        {
            SLAThresholdByCMTypeMap.put(slaThreshold.DeveloperName,slaThreshold);
            
        } 
        if(CareDotComUtil.runningInASandbox()) 
            system.debug(SLAThresholdByCMTypeMap.values());
            tryAgain=false;   
            Process_Control_Values__mdt gmdt = [SELECT Next_Case_Queries_Threshold__c FROM Process_Control_Values__mdt where Label='Global']; 
            Queries_Limit = Integer.valueOf(gmdt.Next_Case_Queries_Threshold__c);
            QueryThreshold=Queries_Limit;
            if(CareDotComUtil.runningInASandbox()) 
                system.debug('Queries_Limit ----------------->>>>>'+Queries_Limit); 
    }

    public void FindNextCase() {
        
		// commented out in favor of BREeze/Omni
    /*
        Integer caseCount=0;
        Set<Id> Tier1 = new Set<Id>();
        Set<Id> Tier2 = new Set<Id>();
        Set<Id> Tier3 = new Set<Id>();
        
        Map<Id, String> qIdToCountryCode = new Map<Id, String>();
        User TheUser = [Select Id, Name, Platform__c, Language__c, Tier__c 
                        FROM User 
                        WHERE Id =: TheUserId];
        
        //get list of queue memberships
        
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                        FROM GroupMember 
                                        WHERE  (not Group.Name like '%Tier%') and Group.Name like 'Q: __: %' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
            system.debug('UserQueues is ==>:'+UserQueues);
        //Set<String> usersAllTierQueues=new Set<String>();
        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            if(CareDotComUtil.runningInASandbox()){
                system.debug('Queue Name Trim: ' + gm.Group.Name);
                //system.debug('TierLevel = \'' + TierLevel + '\'');
            }
            //get country code from queue name
            qIdToCountryCode.put(gm.GroupId, gm.Group.Name.split(':')[1].trim());
            if(CareDotComUtil.runningInASandbox())
                system.debug('Setting country code to ' + gm.Group.Name.split(':')[1].trim() + ' for queue ' + gm.Group.Name);
            
       }
        if(CareDotComUtil.runningInASandbox())
            system.debug('userQueueIds ==>:'+userQueueIds);
        list<Case> FinalCases = new list<Case>();
        
        //query all open cases and order them by age ()
        
        Id StandardRecordTypeId =getRecordTypesStatic.StandardRecordType;
        Id MobileHelpRecordTypeId=getRecordTypesStatic.MobileHelpRecordType; 
        list<Case> QueryCases = [Select Id, Case_Age_Hours_Custom__c, OwnerId, isClosed, ContactId, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c,Tier__c
                                 FROM Case WHERE Tier__c!=null and OwnerId in :userQueueIds and  isClosed = false and ((Status = 'New') or (Status = 'Reopened' and (recordTypeId =:StandardRecordTypeId  or recordTypeId =:MobileHelpRecordTypeId)))  ORDER BY Case_Age_Hours_Custom__c DESC,CreatedDate ASC LIMIT 50000];
        
        //system.debug('QueryCases -->:'+QueryCases .size());
        if(CareDotComUtil.runningInASandbox())
        {
            //system.debug('queueIdNameMap.values()==>:'+queueIdNameMap.values());
            system.debug('QueryCases==>:'+QueryCases);
        }

        for(Case AssignCase : QueryCases){
            SLA_Thresholds_by_Country_Member_Type__mdt caseSLAThresholdSettings=SLAThresholdByCMTypeMap.get(qIdToCountryCode.get(AssignCase.OwnerId));
            Integer caseSLA=0; 
            
            if(AssignCase.Member_Type__c!=null && AssignCase.Member_Type__c.contains('Seeker')){
                caseSLA=Integer.valueOf(caseSLAThresholdSettings.Seeker_SLA__c);
            }
            else if(AssignCase.Member_Type__c!=null && AssignCase.Member_Type__c.contains('Provider')){
                caseSLA=Integer.valueOf(caseSLAThresholdSettings.Provider_SLA__c);
            }
            else{
                caseSLA=Integer.valueOf(caseSLAThresholdSettings.Default_SLA__c);
            }
            
            if(CareDotComUtil.runningInASandbox())
                system.debug('caseSLA-->:'+caseSLA);
                
            if(((TheUser.Platform__c=='US' && Integer.valueOf(AssignCase.Tier__c)<=Integer.valueOf(loginUser.Tier__c)) || TheUser.Platform__c=='International') && userQueueIds.contains(AssignCase.OwnerId))
            {
                if((AssignCase.Case_Age_Hours_Custom__c > caseSLA))
                {
                
                    if(FinalCases.size()==0)
                    {
                        FinalCases.add(AssignCase);
                    }
                    
                    // Added as part of SFORCE-1809 Add new rule to Q: US English
                    if(CareDotComUtil.runningInASandbox())
                        system.debug('Found SLA Exceeded Case: ' + AssignCase.CaseNumber);
                    
                    if(slaExceededCaseMap.get(AssignCase.Tier__c)==null)
                    {
                        if(CareDotComUtil.runningInASandbox()) 
                            system.debug('tierCaseMap.keySet().size()==>:'+tierCaseMap.keySet().size());
                        slaExceededCaseMap.put(AssignCase.Tier__c,AssignCase);
                    }
                    if(CareDotComUtil.runningInASandbox()) 
                        system.debug('caseCount==>:'+caseCount);
                }   
                else 
                { 
                    if(tierCaseMap.get(AssignCase.Tier__c)==null)
                    {
                        if(CareDotComUtil.runningInASandbox()) 
                            system.debug('tierCaseMap.keySet().size()==>:'+tierCaseMap.keySet().size());
                        tierCaseMap.put(AssignCase.Tier__c,new List<Case>());
                    }
                    if(CareDotComUtil.runningInASandbox()) 
                        system.debug('caseCount==>:'+caseCount);
                    if(tierCaseMap.get(AssignCase.Tier__c).size()==0)
                    {
                        tierCaseMap.get(AssignCase.Tier__c).add(AssignCase);
                        intlCasesWithoutTier.add(AssignCase);
                    }
                }
            } 
            
        }
        
        List<SObjectWrapper> descOrderSLAExceededCasesList=new List<SObjectWrapper>();
        for(String dec: slaExceededCaseMap.keySet())
        {
            descOrderSLAExceededCasesList.add(new SObjectWrapper(Integer.valueOf(dec)));
        }
        descOrderSLAExceededCasesList.sort();
        
        if(descOrderSLAExceededCasesList.size()>0){
            //FinalCases.add(slaExceededCaseMap.get(String.valueOf(descOrderSLAExceededCasesList[0].caseTier)));
        }
        
        
        //system.debug('casesLtOrEqToUserTier ====>:'+casesLtOrEqToUserTier);
        // Sort list of cases having tier less than or equal to with User in descending order with Tier
        List<SObjectWrapper> descOrderTierList=new List<SObjectWrapper>();
        for(String dec: tierCaseMap.keySet())
        {
            descOrderTierList.add(new SObjectWrapper(Integer.valueOf(dec)));
        }
        descOrderTierList.sort();
        if(CareDotComUtil.runningInASandbox())
        {
            for(SObjectWrapper sobjWrapper:descOrderTierList){
                if(CareDotComUtil.runningInASandbox()) 
                    system.debug('User Descending Order Tier=============>:'+sObjWrapper.caseTier+'tierCaseMap.get(sObjWrapper.caseTier)=================>:'+tierCaseMap.get(String.valueOf(sObjWrapper.caseTier)));
            }
        }
        
        
        //if no SLA exceeded cases found, add other open cases to FinalCases list
        if (FinalCases.isEmpty()) {
            if(CareDotComUtil.runningInASandbox())
                system.debug('No SLA Exceeded Cases found!');
             if(TheUser.Platform__c=='International') 
            {
                if(!intlCasesWithoutTier.isEmpty())       {FinalCases.addAll(intlCasesWithoutTier);}
            }
            else
            {
                for(SObjectWrapper tierNumberWrapper:descOrderTierList){
                    FinalCases.addAll(tierCaseMap.get(String.valueOf(tierNumberWrapper.caseTier)));
                }
            }
            
            if(CareDotComUtil.runningInASandbox())
                system.debug('FinalCases=====================>:'+FinalCases); 
        }
        
        updateList = new list<Case>();
        
        if(!FinalCases.isempty()){
            //set<Id> childTierSet = new set<Id>();
            ThefinalCase = FinalCases[0]; //set the final case
            
            
           
            //find child cases (other open Cases by same member in queue of same country/language as final case)
            if (ThefinalCase.ContactId != null) {
                for(Case childCase : QueryCases) {
                    //if(childCase.contactId == ThefinalCase.contactId && childCase.id != ThefinalCase.id ) {
                    if(childCase.OwnerId== ThefinalCase.OwnerId  && childCase.contactId == ThefinalCase.contactId && childCase.id != ThefinalCase.id) {
                        childCase.ParentId = ThefinalCase.Id; //link child to parent
                        childCase.OwnerId = TheUserId; //assign child cases to user
                        updateList.add(childCase);
                    }
                }
            }
            
            ThefinalCase.OwnerId = TheUserId; //assign final case to user
            ThefinalCase.parentId=null;
            updateList.add(ThefinalCase);
            dispError = false;
            pageReference opencasePage;
            if(apexpages.currentpage() != null && apexpages.currentpage().getURL()!=null && apexpages.currentpage().getURL().contains('console')){
                openCasePage = new pageReference('/console?tsid=' + ThefinalCase.Id);
                openconsoletabbool = true;
            }
            else
                openCasePage = new pageReference('/' + ThefinalCase.Id);
            
            desiredURL = openCasePage.getURL();
            if(CareDotComUtil.runningInASandbox())
                system.debug('URL of TheFinalCase: ' + desiredURL);
        }
    */
    }
    
    public void returnLink(){
        this.FindNextCase();
        
        if(updateList == null || updateList.isempty()){
            dispError=true;
        }
        else //if(updateList.isempty())
        {
            Approval.LockResult[] lrList=Approval.lock(updateList, true);
            List<Case> caseList=new List<Case>([select id from case where id=:updateList and (not owner.name like 'Q:%')]);
            if(lrList[0].isSuccess() && caseList.isEmpty()){
                try{
                        update updateList;
                    }catch(Exception e){
                        System.debug('Exception occured================>> '+e);
                        dispError=true;
                    }                      
                
                }else if (!caseList.isEmpty() && Limits.getQueries() <= Queries_Limit){
                    if(CareDotComUtil.runningInASandbox()) 
                    system.debug('Iterating ================>> within getQueries() Limit'+Limits.getQueries());
                    Approval.UnlockResult[] urList = Approval.unlock(updateList, true); 
                    returnLink();
                 }else { 
                    if(CareDotComUtil.runningInASandbox())  
                    system.debug('Notifying user to retry once again================>>  Exceeding getQueries() Limit'+Limits.getQueries());
                    tryAgain =true;                  
                 } 
             
             Approval.UnlockResult[] urList = Approval.unlock(updateList, true); 
         }
        /**else 
        {
            System.debug('getAggregateQueries()----------->'+ Limits.getAggregateQueries());
            System.debug('getCpuTime()---------->'+ Limits.getCpuTime());           
            System.debug('getHeapSize()----------->'+  Limits.getHeapSize());
            System.debug('getDMLRows()----------->'+  Limits.getDMLRows());                        
            System.debug('getDMLStatements()----------->'+ Limits.getDMLStatements());
            System.debug('getQueries()----------->'+ Limits.getQueries()); 
            System.debug('getQueryRows()----------->'+ Limits.getQueryRows());
            System.debug('getQueryLocatorRows()----------->'+ Limits.getQueryLocatorRows());
            if( Limits.getQueries() > 80 ){
                System.debug('getQueries()-----------Try Again1001>'+ Limits.getQueries());     
                tryAgain = true;                  
            }
            else                                     
                returnLink();
            
        } **/
    }
    

    public PageReference returnLinkAction(){
        this.returnLink();
        return null;
    }
    
    public User loginUser{get;set;}

    public PageReference switchLanguage() {
        if(loginUser.UserRole.Name=='DACH Team Lead')
            loginUser.userRoleId=usrRoleMap.get('English Team Lead');
        else if(loginUser.UserRole.Name=='DACH Team Agent')
            loginUser.userRoleId=usrRoleMap.get('English Team Agent');
        else if(loginUser.UserRole.Name=='English Team Lead')
            loginUser.userRoleId=usrRoleMap.get('DACH Team Lead');
        else if(loginUser.UserRole.Name=='English Team Agent')
            loginUser.userRoleId=usrRoleMap.get('DACH Team Agent');  
        
        if(loginUser.language__c !=null && loginUser.language__c.contains('German'))       loginUser.language__c='English';
        else if(loginUser.language__c !=null &&  loginUser.language__c.contains('English'))       loginUser.language__c='German';
        
        update loginUser;

        loginUser=[
			SELECT id,language__c,UserRole.Name//,Platform__c,Tier__c
			FROM USER 
			WHERE ID=:UserInfo.getUserId()][0];
        
        return null;
    }

    private boolean switchUserToGerman;

    public boolean getSwitchUserToGerman(){
        if(loginUser.Language__c!=null){
        return 
			//loginUser.Platform__c == 'International' && 
			//loginUser.Tier__c != null && 
			loginUser.Language__c !=null && loginUser.UserRole !=null && loginUser.Language__c.contains('English') && !loginUser.Language__c.contains('German') && (loginUser.UserRole.Name=='English Team Lead' || loginUser.UserRole.Name=='English Team Agent');
        }
        else{
            return false;
        }
        
    } 

    public void setSwitchUserToGerman(boolean switchUserToGerman){
        this.switchUserToGerman=switchUserToGerman;
    }

    private boolean switchUserToEnglish;

    public boolean getSwitchUserToEnglish(){
        if(loginUser.Language__c!=null){
        	return loginUser.Language__c !=null && loginUser.UserRole !=null &&	loginUser.Language__c.contains('German') && !loginUser.Language__c.contains('English') &&  (loginUser.UserRole.Name=='DACH Team Lead' || loginUser.UserRole.Name=='DACH Team Agent') ;
        }
        return false;
     } 

    public void setSwitchUserToEnglish(boolean switchUserToEnglish){
        this.switchUserToEnglish=switchUserToEnglish;
    }

    public class SObjectWrapper implements Comparable {
        
        public Integer caseTier;
        
        // Constructor
        public SObjectWrapper(Integer caseTier) {
            this.caseTier= caseTier;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareToCaseTier) {
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (caseTier < ((SObjectWrapper)compareToCaseTier).caseTier) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (caseTier >  ((SObjectWrapper)compareToCaseTier).caseTier) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;
        }
    }
}