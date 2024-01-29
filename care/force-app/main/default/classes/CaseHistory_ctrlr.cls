/*
** _________________________________________________________________________________
** Created by:    Eustace Consulting [www.eustaceconsulting.com]
** Developer:	  Liam Stokinger, Software Developer [Liam@eustaceconsulting.com]
** Created Date:  08.12.2014
** =================================================================================
** Description: 
				Controlling class for caseHistoryReport vf page
** _______________________________________________________________________________
*/
public with sharing class CaseHistory_ctrlr {
    
    public Map<Id, User> UserMap {get; set;}
    public list<CaseHistory> CaseHistories {get; set;}
    public map<Id, list<Case>> UserCaseMap {get; set;}
    public map<string, string> newValueNameMap {get; set;}
    public map<string, string> oldValueNameMap {get; set;}
    public list<UserWrapper> WrapperList {get; set;}
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public string theRole {get; set;}
    public list<SelectOption> RoleSelect {get; set;}
    public list<CaseHistoryRole__c> CHRlist {get; set;}
    public boolean showtable {get; set;}
    public Id userId {get; set;}
    public integer userSeq{get; set;}
    
    public CaseHistory_ctrlr(){
        StartDate = date.today().addDays(-7);
        EndDate = date.today();
        theRole = 'All';
        
        map<String, CaseHistoryRole__c> CHRmap = CaseHistoryRole__c.getAll();
        CHRlist = CHRmap.values();
        
        RoleSelect = new list<SelectOption>();
        RoleSelect.add(new SelectOption('All','All'));
        for(CaseHistoryRole__c CHR : CHRlist){
            RoleSelect.add(new SelectOption(CHR.Name,CHR.Name));
        }
                
        showtable = false;
        
    }
    
    public void refreshUsers(){
    	
    	if(StartDate != null && StartDate < Date.today().addDays(-90)){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Start date cannot be more than 90 days in past.'));
    		return;
    	}
    	
        list<string> Roles = new list<string>();
        if(theRole == 'All'){
            for(CaseHistoryRole__c CHR : CHRlist){
                Roles.add(CHR.Name);
            }
        } else {
            Roles.add(theRole);
        }
        
        EndDate = EndDate.addDays(1);
        

        UserMap = new Map<Id, User>([Select Id, UserRoleId, UserRole.Name, Name FROM User WHERE UserRole.Name IN: Roles ORDER BY LastName]);
 
        CaseHistories = [
	                         SELECT 
	    						Id, CaseId, CreatedById, CreatedBy.Name, Case.CaseNumber,
	    						Case.ContactId, Case.Contact.Name, Case.Subject, Case.OwnerId, 
	    						Case.IsDeleted, Field, NewValue, OldValue, createdDate, case.status
	                         FROM 
	                           CaseHistory 
	                         WHERE 
	                           Case.IsDeleted = FALSE 
	                             AND 
	                           (Field = 'Owner' OR Field = 'ownerAssignment') 
	                             AND 
	                           CreatedDate >=: StartDate 
	                             AND 
	                           CreatedDate <=: EndDate 
	                             AND 
	                           CreatedById in: UserMap.keySet() 
	                         ORDER BY Case.CaseNumber
                         ];
                                           
        
        newValueNameMap = new map<String, String>();
        set<string> NewValueIds = new set<string>();
        oldValueNameMap = new map<String, String>();
        set<string> OldValueIds = new set<string>();
        
        integer x = 0;
        while(x < CaseHistories.size()){
        	Boolean removeMe = false;
        	CaseHistory CH = CaseHistories.get(x);
        	
        	system.debug('###Case Num.: ' + CH.Case.CaseNumber +  '  Case Contact: ' + CH.Case.Contact.Name + '  Field Changed: ' + CH.Field + '  Old Value: ' + CH.OldValue + '  New Value: ' + CH.NewValue + '  Change Date: ' + CH.CreatedDate + ' Changed By: ' + CH.CreatedBy.Name);
        	
        	if ((string.valueof(CH.newValue).length()==15 || string.valueof(CH.newValue).length()==18) && string.valueof(CH.newValue).startsWith('00')) {
        		system.debug('NewValue is an ID: ' + string.valueof(CH.newValue));
            	NewValueIds.add(string.valueof(CH.newValue));
        	} else {
        		removeMe = true;
            }
            
            if ((string.valueof(CH.oldValue).length()==15 || string.valueof(CH.newValue).length()==18) && string.valueof(CH.oldValue).startsWith('00')) {
            	system.debug('OldValue is an ID: ' + string.valueof(CH.oldValue));
            	OldValueIds.add(string.valueof(CH.oldValue));
            } else {
            	removeMe = true;
            }
            
            if (removeMe) CaseHistories.remove(x);
            else x++;
        }
        
        list<User> allUsers = [Select Id, Name FROM User WHERE Id IN: NewValueIds or Id IN: OldValueIds];
        list<Group> allGroups = [Select Id, Name FROM Group WHERE Id IN: NewValueIds or Id IN: OldValueIds];
        
        for(User U : allUsers) {
        	if (NewValueIds.contains(U.id)) {
            	newValueNameMap.put(U.Id,U.Name);
            	system.debug('Added User Id: ' + U.id + ' and Name: ' + U.Name + ' to newValueNameMap.');
        	} 
        	if (OldValueIds.contains(U.id)) {
            	oldValueNameMap.put(U.id, U.Name);
            	system.debug('Added User Id: ' + U.id + ' and Name: ' + U.Name + ' to oldValueNameMap.');
        	}
        }
        
        for(Group G : allGroups) {
        	if (NewValueIds.contains(G.id)) {
        		system.debug('Added Group Id: ' + G.id + ' and Name: ' + G.Name + ' to newValueNameMap.');
            	newValueNameMap.put(G.Id,G.Name);
        	} 
        	if (OldValueIds.contains(G.id)) {
        		system.debug('Added Group Id: ' + G.id + ' and Name: ' + G.Name + ' to oldValueNameMap.');
            	oldValueNameMap.put(G.id, G.Name);
        	}
        }
        
        WrapperList = new list<UserWrapper>();
        integer i = 0;
        for(User TheUser : UserMap.values()){
        	system.debug('Creating wrapper for User ' + TheUser.Name);
        	UserWrapper uw =  new UserWrapper(TheUser, this);
        	uw.UserNumber = i;
            WrapperList.add(uw);
            if(WrapperList[i].NumberReassigned == 0)
                WrapperList.remove(i);
            else
                i++;
        }
        
        showtable = true;
        
        CaseHistories.clear();
        
        EndDate = EndDate.addDays(-1);
    }
    
    public class UserWrapper {
        
        public list<CaseHistory> CaseHistoryList {get; set;}
        public list<string> CreatedDates {get; set;}
        public integer NumberReassigned {get; set;}
        public User CurrUser {get; set;}
        public integer UserNumber {get; set;}
        
        public UserWrapper(User TheUser, CaseHistory_ctrlr parent){
            NumberReassigned = 0;
            CaseHistoryList = new list<CaseHistory>();
            CreatedDates = new list<string>();
            CurrUser = TheUser;
       		system.debug('Looking for pertinent history records.');
            for(CaseHistory CH : parent.CaseHistories){
            	//system.debug('Pertinent User Name: ' + CurrUser.Name);
            	//system.debug('Case History Owner Name (OLD): ' + parent.oldValueNameMap.get(string.valueOf(CH.OldValue)));
            	//system.debug('Case History Created By: ' + CH.CreatedBy.Name);
                if(parent.oldValueNameMap.get(string.valueOf(CH.OldValue)) == CurrUser.Name && CH.CreatedBy.Name == CurrUser.Name){
                	//system.debug('FOUND MATCHING CASE HISTORY RECORD! INCREMENTING REASSIGNED COUNTER!');
                    NumberReassigned += 1;
                    if (parent.userId != null && CurrUser.Id == parent.userId) {
                    	system.debug('adding to case history list');
                    	CaseHistoryList.add(CH);
                    	CreatedDates.add(CH.CreatedDate.format());
                    } 	
                }
            }
        }
    }

}