/*
Helper Class for Case Triage
Description:  Created for case triaging through case assignment rules for Safety cases by disabling breeze rules for Safety
CreatedBy : md Ashwaq
CreatedDate: 25/12/2022
ModifiedDate: 20/07/2023
*/
public class SafetyCaseTriage {
    Public Map<String, Entitlement> entitlementsMap;
    Public Boolean automatedUserMap =false;
    public Id IntlSafety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
    Public Id usSafety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
    Public Id pbgc = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premier Background Check').getRecordTypeId();
    
    public void routeCasetoOmniInsert(List<Case> newItems) {
        Map<id,User> integrationUser = CaseTriage.isAutomatedUser(UserInfo.getUserId()); //UserInfo.getName()
        system.debug('integrationUser******'+integrationUser);
        if(integrationUser.containsKey(UserInfo.getUserId())){
            automatedUserMap = true;
        }
        List<Case> caseList = new List<Case>();
        List<Case> socialCaseList = new List<Case>();
        for(Case cs : newItems){
            if((cs.RecordTypeId == usSafety || cs.RecordTypeId  == IntlSafety || cs.RecordTypeId == pbgc) && !cs.isClosed){
                caseList.add(cs);        
            }            
        }
        if(caseList.size() > 0){
            routeCasetoOmni(caseList);
        }
    }
    public void routeCasetoOmniUpdate(Map<Id, Case> newItems, Map<Id, Case> oldItems) {  
        List<Case> caseList = new List<Case>();
        for(Case cs : newItems.values()){
            if(cs.RecordTypeId == usSafety || cs.RecordTypeId  == IntlSafety || cs.RecordTypeId == pbgc){
                if(newItems.get(cs.id).SafetyCaseTriage__c && newItems.get(cs.id).SafetyCaseTriage__c !=oldItems.get(cs.id).SafetyCaseTriage__c){
                    automatedUserMap = true;
                    caseList.add(cs);
                }            
                if(newItems.get(cs.id).MC_Email__c && newItems.get(cs.id).MC_Email__c !=oldItems.get(cs.id).MC_Email__c) {
                    automatedUserMap = true;
                    caseList.add(cs);
                }
                if(newItems.get(cs.id).Subject !=null && newItems.get(cs.id).Subject !=oldItems.get(cs.id).Subject) {
                    automatedUserMap = true;
                    caseList.add(cs);
                }
            }
        }
        if(caseList.size() > 0){
            routeCasetoOmni(caseList);
        }    
    }    
    public void routeCasetoOmni(List<Case> newItems) { 
        system.debug('Into case triage***************');
        Map<String, Group> safetyQueuesMap = CaseTriage.safetyQueues();
        Id BusinessHoursId = CaseTriage.getBusinessHours();
        Map<String, Entitlement> entitlementsMap = CaseTriage.getEntitlements();
        
        Map<Id, String> safetyRecMap =  CaseTriage.getRecordTypesforCaseTriage('Safety');
        //Iterate through Cases to update                              
        for(Case cs : newItems){ 
            try {
                if(safetyRecMap.containsKey(cs.RecordTypeId)){
                    
                    
                    system.debug('Safety RecordType ***************');
                    //The cases should exclude the closed cases, such as IsClosed = true
                    if(!CaseTriage.closeCaseStatus(cs.Status) &&  !CaseTriage.safetyCasesNottoRoute(cs)){  
                        system.debug('Safety status ***************');
                        if(cs.RecordTypeId == usSafety || cs.RecordTypeId == IntlSafety){
                            system.debug('again Safety RT***************');
                            if(cs.mc_email__c && cs.Member_Language__c !=null && cs.Member_Language__c =='English'){
                                cs.OwnerId = safetyQueuesMap.get('Member_Care_EN_Tier_2').Id;
                                cs.Priority = '6';
                                cs.Support_Skill__c= 'Member Care - EN Tier 2';
                            }    
                            if(cs.mc_email__c &&  cs.Member_Language__c !=null && cs.Member_Language__c !='English'){
                                cs.OwnerId = safetyQueuesMap.get('Member_Care_ROW_Tier_2').Id;
                                cs.Priority = '6';
                                cs.Support_Skill__c= 'Member Care - ROW Tier 2';
                            }
                        }
                        system.debug('automatedUserMa*********');
                        system.debug('automatedUserMap Safety***************'+automatedUserMap);
                        if(automatedUserMap){
                            system.debug('AUTO USER Safety ***************');
                            if(cs.RecordTypeId == usSafety){
                                system.debug('US Safety ***************');
                                if(cs.Member_Language__c == null){
                                    cs.Member_Locale__c = 'en_US';
                                    cs.Member_Language__c = 'English';
                                }                                
                                if(cs.Subject == 'Message with inappropriate word/phrase' ||
                                   cs.Subject == 'Inappropriate Search' ||
                                   cs.Subject == 'Inappropriate Word Search'){
                                       cs.OwnerId = safetyQueuesMap.get('S_Inappropriate_Activity').Id;
                                       cs.Priority = '1';
                                       cs.Support_Skill__c = 'Inappropriate Activity';
                                       cs.EntitlementId = entitlementsMap.get('10 Hour SLA').Id;
                                       cs.BusinessHoursId = BusinessHoursId;
                                   }                             
                                else if(cs.Subject == 'Reviews Platform Escalation' ||
                                   cs.Subject == 'Reviews Platform Escalation & Bad Word Content Flag'){
                                    cs.OwnerId = safetyQueuesMap.get('S_Safety_Reviews').Id;
                                    cs.Priority = '1';
                                    cs.Support_Skill__c= 'Safety Review';
                                    cs.EntitlementId= entitlementsMap.get('10 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }                           
                                else if(cs.Subject == 'Flagged by Member') {
                                    cs.OwnerId = safetyQueuesMap.get('S_Member_Flags').Id;
                                    cs.Priority = '2';
                                    cs.Support_Skill__c= 'Member Flags';
                                    cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if( cs.Subject.Contains('Blocklist Partial Match')){
                                    cs.OwnerId = safetyQueuesMap.get('S_Blocklist_Partial_Match').Id;
                                    cs.Priority = '2';
                                    cs.Support_Skill__c= 'Blocklist Partial Match';
                                    cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if( cs.Subject == 'Blocklisted'){
                                    cs.OwnerId = safetyQueuesMap.get('Q_Blocked_Member_Appeal').Id;
                                    cs.Priority = '5';
                                    cs.Support_Skill__c= 'Blocklisted Member Appeals';
                                    cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if(cs.Subject == 'High Touch Rejected-Safety Concern' || cs.Subject == 'Approved-Safety' || cs.Subject == 'Reviewed-Safety' || cs.Subject == 'Rejected-Safety') {
                                    cs.OwnerId = safetyQueuesMap.get('S_Member_Review_Escalations').Id;
                                    cs.Priority = '1';
                                    cs.Support_Skill__c= 'Member Review Escalations';
                                    cs.EntitlementId= entitlementsMap.get('10 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }                                
                                else if( cs.Subject == 'Seeker Create Account - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Post a job Content - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Content Message Abuse - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Recruitment Upgrade membership - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'CC update - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Recruitment Create Account - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'SMB Create Account - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'SMB Upgrade membership - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Provider Upgrade membership - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Payment - Research due to fraud rules' || 
                                        cs.Subject == 'Payment - Decline due to fraud rules' || 
                                        cs.Subject == 'Provider Create Account - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Lite member Create Account - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Seeker Upgrade membership - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Transaction payment - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'Provider BGC purchase - Decline due to SiftScience fraud rules' || 
                                        cs.Subject == 'MaxMind Credit Card Alert' || 
                                        cs.Subject == 'Payment request flagged' || 
                                        cs.Subject == 'Payment spam limit hit' || 
                                        cs.Subject == 'Basic Seeker Message Limit' ){   
                                            cs.OwnerId = safetyQueuesMap.get('S_Fraud_Detection').Id;
                                            cs.Priority = '3';
                                            cs.Support_Skill__c= 'Fraud Detection';
                                            cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                            cs.BusinessHoursId =BusinessHoursId;
                                        }
                                else if( cs.Subject == 'Accused List Match') {                                   
                                    cs.OwnerId = safetyQueuesMap.get('S_Accused_List_Match').Id;
                                    cs.Priority = '2';
                                    cs.Support_Skill__c= 'Accused List Match';
                                    cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                    system.debug('line 199***'+BusinessHoursId);
                                    system.debug('line 200***'+entitlementsMap);
                                    system.debug('line 201***'+safetyQueuesMap);
                                }
                                else if( cs.Subject == 'Negative Media Check Alert' || cs.Subject == 'Negative Media Check Alert Backfill') {
                                    cs.OwnerId = safetyQueuesMap.get('S_Negative_Media').Id;
                                    cs.Priority = '4';
                                    cs.Support_Skill__c= ' Negative Media';
                                    cs.EntitlementId= entitlementsMap.get('200 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if( cs.Subject == 'IDV Failure' || cs.Subject == 'IDV Discrepancy'){
                                    cs.OwnerId = safetyQueuesMap.get('S_Identity_Verification').Id;                                
                                    cs.Priority = '5';
                                    cs.Support_Skill__c= 'Identity Verification';
                                    cs.EntitlementId= entitlementsMap.get('24 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if(cs.Subject == 'RDC List Match'){
                                    cs.OwnerId = safetyQueuesMap.get('RDC_List_Match').Id;
                                    cs.Priority = '32';
                                    cs.Support_Skill__c= 'Safety';
                                    cs.EntitlementId= entitlementsMap.get('200 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                }
                                else if(cs.Subject == 'RDC List Match - Medium Risk' ){
                                    cs.OwnerId = safetyQueuesMap.get('RDC_List_Match_Medium_Risk').Id;
                                    cs.Priority = '31';
                                    cs.Support_Skill__c= 'Safety';
                                    cs.EntitlementId= entitlementsMap.get('200 Hour SLA').Id;
                                    cs.BusinessHoursId =BusinessHoursId;
                                } 
                                else {
                                    cs.Support_Skill__c= 'No Skill Matched';
                                    cs.Member_Language__c= 'English';
                                } 
                            }
                            else if(cs.RecordTypeId == IntlSafety){    
                                cs.OwnerId = safetyQueuesMap.get('S_International_Safety_Alert').Id;
                                cs.Support_Skill__c= 'Safety';
                            }                            
                            else if( safetyRecMap.get(cs.RecordTypeId)  == 'Premier Background Check' ){
                                cs.OwnerId = safetyQueuesMap.get('Q_Premier_Background_Checks').Id;
                                cs.Support_Skill__c= 'Premier Background Check';
                            }
                            else {
                                cs.Support_Skill__c= 'No Skill Matched';
                                cs.Member_Language__c= 'English';
                            } 
                        }
                    } 
                    else if(!CaseTriage.safetyCasesNottoRoute(cs)){
                    	cs.OwnerId = safetyQueuesMap.get('Member_Care_Closed').Id;
                        cs.Status = 'Closed';
                        cs.Support_Skill__c= 'No Skill Matched';
                        cs.Member_Language__c= 'English';
                    }
                    else{
                        cs.OwnerId = safetyQueuesMap.get('Member_Care_Closed').Id;
                        cs.Status = 'Closed';
                        cs.Support_Skill__c= 'No Skill Matched';
                        cs.Member_Language__c= 'English';
                    }
                } 
            } 
            catch(Exception e) {
                System.debug('**An exception occurred: ' + e.getMessage() + e);
            } 
            finally {
                System.debug('Closing the stream writer in the finally block.');                
            }
        }
    } 
}