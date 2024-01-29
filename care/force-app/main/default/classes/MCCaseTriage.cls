/*
Helper Class for Case Triage
Description:  Created for case triaging through case assignment rules for membercare cases by disabling breeze rules for member care
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
ModifiedDate: 21/06/2023
*/
public class MCCaseTriage {
    Map<id,Case> TriggerNewMap;
    Map<id,Case> TriggerOldMap;
    public MCCaseTriage(Map<id, Case> TriggerNewMap, Map<id, Case> TriggerOldMap){
        this.TriggerNewMap = TriggerNewMap;
        this.TriggerOldMap = TriggerOldMap;        
    }
    public  void routeCasetoAgent() {
        Map<Id, String> MCRecMap = CaseTriage.getRecordTypesforCaseTriage('MC');
        Map<id,Case> caseMap = new Map<id,Case>();
        for(Case csMC: TriggerNewMap.values()){
            if(MCRecMap.containsKey(csMC.RecordTypeId)){
                caseMap.put(csMC.Id, csMC);
            }
        }
        if(!caseMap.isEmpty()){            
            Boolean automatedUsers = false;
            Map<id,User> integrationUser = CaseTriage.isAutomatedUser(UserInfo.getUserId()); //UserInfo.getName()
            if(integrationUser.containsKey(UserInfo.getUserId())){
                automatedUsers = true;
            }
            Map<Id, Group> sunsetGroupCheck = new Map<Id, Group>();
            Map<Id, Group> tempGroupCheck = new Map<Id, Group>();
            Map<Id, Boolean> isOmniQueue = new  Map<Id, Boolean>();
            Map<String, Group> mcNameGroupMap = new  Map<String, Group>();
            Map<String, List<String>> MCGroupNamewithData = new Map<String, List<String>>();
            Map<String, List<String>> MCGroupIdwithData = new Map<String, List<String>>();
            Map<String, List<String>> groupIds = CaseTriage.mapCustomMetadata();
            Map<String, Entitlement> entitlementsMap = CaseTriage.getEntitlements();
            for(Group g: [Select Id,  Name, DeveloperName, QueueRoutingConfigId, Email  FROM Group where DeveloperName in : groupIds.KeySet()]){
                if(g.QueueRoutingConfigId !=null){
                    isOmniQueue.put(g.Id, true);
                }
                if(g.DeveloperName == 'MC_Temporary'){
                    tempGroupCheck.put(g.Id , g);
                }
                else if(g.DeveloperName == 'Careteam_care_com_Sunset'){
                    sunsetGroupCheck.put(g.Id, g);
                }                
                mcNameGroupMap.put(g.DeveloperName, g);
                List<String> lst2 = groupIds.get(g.DeveloperName);
                lst2.add(g.Id);
                MCGroupIdwithData.put(g.Id, lst2);
                MCGroupNamewithData.put(g.DeveloperName, lst2);
            }
            //Iterate through Cases to update                              
            for(Case cs : caseMap.values()){
                //MC EMail =true
                
                if(TriggerNewMap.get(cs.id).MC_Email__c && !TriggerOldMap.get(cs.id).MC_Email__c){
                    if(cs.Member_Language__c=='' || cs.Member_Language__c=='English') {                                    
                        cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                        cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];     
                        cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                    }
                    else{
                        cs.OwnerId=mcNameGroupMap.get('Member_Care_ROW_Tier_2').Id;
                        cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[1];     
                        cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[2]; //'6';
                    }                                      
                    cs.Assigned_from_Queue__c =false;
                }
                //When MC Case is escalated to Safety , safety_email =true    
                if(TriggerNewMap.get(cs.id).Safety_Email__c  && !TriggerOldMap.get(cs.id).Safety_Email__c){
                    List<Entitlement> Ent = [select id ,name from Entitlement where Name ='24 Hour SLA' limit 1];
                    if(!Ent.isEmpty()){
                        cs.EntitlementId = Ent[0].Id;                               
                    }
                    Group g = [select id , name, DeveloperName from Group where DeveloperName ='S_Safety_Email'];
                    if(g!=null){
                        cs.OwnerId = g.Id;
                    }
                    cs.Support_Skill__c ='Safety Email';
                    cs.Assigned_from_Queue__c =false;
                    cs.Priority = MCGroupNamewithData.get('S_Safety_Email')[2];
                }  
                if(cs.RecordTypeId == getRecordTypesStatic.StandardRecordType || 
                   cs.RecordTypeId == getRecordTypesStatic.CallCenterRecordType || 
                   cs.RecordTypeId ==getRecordTypesStatic.InternationalCallCenterRecordType || 
                   cs.RecordTypeId == getRecordTypesStatic.InternationalEmailRecordType ||
                   cs.RecordTypeId ==  getRecordTypesStatic.chargebackRecordType){
                       try {
                           //case with agent should not re route
                           if(String.ValueOf(cs.OwnerId).left(3) != '00G' && integrationUser.containsKey(cs.OwnerId))  {
                               automatedUsers = true;
                           }
                           // run case triage process if user check CaseTriage__c manually                               
                           if(TriggerNewMap.get(cs.id).CaseTriage__c && TriggerNewMap.get(cs.id).CaseTriage__c !=TriggerOldMap.get(cs.id).CaseTriage__c){
                               automatedUsers=true;
                           }
                           if((!CaseTriage.closeCaseStatus(cs.Status) &&  cs.Origin !='Chat') || 
                              (TriggerNewMap.get(cs.id).Origin =='Web' && TriggerNewMap.get(cs.id).Origin != TriggerOldMap.get(cs.id).Origin) ||
                              (TriggerNewMap.get(cs.id).CaseTriage__c !=TriggerOldMap.get(cs.id).CaseTriage__c)){                               
                                  if((cs.Subject !='Blocked Member Appeal' && !sunsetGroupCheck.ContainsKey(cs.OwnerId)) || 
                                     (sunsetGroupCheck.ContainsKey(cs.OwnerId) && cs.SuppliedEmail !=null && cs.SuppliedEmail == 'message@inbound.efax.com')){
                                         //change skill if owner changes or vise versa
                                         if( TriggerNewMap.get(cs.id).OwnerId !=TriggerOldMap.get(cs.id).OwnerId && String.ValueOf(TriggerNewMap.get(cs.id).OwnerId).left(3) == '00G'){
                                             if(!MCGroupIdwithData.isEmpty() && MCGroupIdwithData.containsKey(TriggerNewMap.get(cs.id).OwnerId)){
                                                 cs.Priority = MCGroupIdwithData.get(TriggerNewMap.get(cs.id).OwnerId)[2]; // MCGroupIdwithData keys are : cm.Case_Queue__c, cm.Case_Skill__c, cm.Case_Priority__c, ownerId                                 
                                                 cs.Support_Skill__c =MCGroupIdwithData.get(TriggerNewMap.get(cs.id).OwnerId)[1];
                                             }
                                             cs.Assigned_from_Queue__c =false;
                                         }
                                         string skillsetMain = '';
                                         if(TriggerNewMap.get(cs.id).Support_Skill__c !=null){
                                             skillsetMain = TriggerNewMap.get(cs.id).Support_Skill__c;
                                             skillsetMain = skillsetMain.replaceAll('[^a-zA-Z0-9\\s+]', '');
                                             skillsetMain = skillsetMain.trim();
                                             skillsetMain = skillsetMain.replaceAll('(\\s+)', '_');
                                         }
                                         if(skillsetMain!='' && MCGroupNamewithData.containsKey(skillsetMain)){
                                             if( TriggerNewMap.get(cs.id).Support_Skill__c !=TriggerOldMap.get(cs.id).Support_Skill__c){                                          
                                                 cs.Priority = MCGroupNamewithData.get(skillsetMain)[2];                                    
                                                 cs.OwnerId = mcNameGroupMap.get(skillsetMain).Id;                                          
                                                 cs.Assigned_from_Queue__c =false;
                                             }
                                         }
                                         //Checking if support skill is blank
                                         if(String.isBlank(TriggerNewMap.get(cs.id).Support_Skill__c)){
                                             cs.Support_Skill__c = 'No Skill Matched';
                                         }
                                         //Checking if Member Language  is blank
                                         if(String.isBlank(TriggerNewMap.get(cs.id).Member_Language__C)){
                                             if(cs.RecordTypeId == getRecordTypesStatic.StandardRecordType || cs.RecordTypeId == getRecordTypesStatic.CallCenterRecordType) {
                                                 cs.Member_Language__C = 'English';
                                             }
                                         }
                                         //runs case triage only for system users                                      
                                         if(automatedUsers){       
                                             if(cs.RecordTypeId ==  getRecordTypesStatic.chargebackRecordType && cs.Origin =='Stripe'){
                                                 cs.Status = 'Auto-Closed';
                                                 cs.OwnerId = mcNameGroupMap.get('Careteam_care_com_Sunset').Id;
                                             }
                                             //when ODS is ran, Member details are available
                                             if((TriggerNewMap.get(cs.id).Origin =='Web' && TriggerNewMap.get(cs.id).Origin != TriggerOldMap.get(cs.id).Origin) ||
                                                (TriggerNewMap.get(cs.id).AccountId != TriggerOldMap.get(cs.id).AccountId) || 
                                                (cs.Is_ODS_Complete__c && tempGroupCheck.ContainsKey(cs.OwnerId)) ||
                                                (cs.Is_ODS_Complete__c && tempGroupCheck.ContainsKey(TriggerNewMap.get(cs.id).OwnerId)) ||
                                                (TriggerNewMap.get(cs.id).Is_ODS_Complete__c && tempGroupCheck.ContainsKey(cs.OwnerId)) ||                                               
                                                (TriggerNewMap.get(cs.id).Is_ODS_Complete__c && tempGroupCheck.ContainsKey(TriggerNewMap.get(cs.id).OwnerId)) ||
                                                (TriggerNewMap.get(cs.id).Is_ODS_Complete__c && !TriggerOldMap.get(cs.id).Is_ODS_Complete__c) || 
                                                (TriggerNewMap.get(cs.id).CaseTriage__c !=TriggerOldMap.get(cs.id).CaseTriage__c) ||
                                                (cs.Subject !=null && (cs.Subject =='Visitor Downgrade Request' || cs.Subject =='Extraordinary Downgrade Request' || cs.Type =='International Imprint'))){
                                                    //Email - Privacy (GDPR) Case
                                                    if ((cs.Origin  == 'Email - Privacy' || TriggerOldMap.get(cs.id).Origin  == 'Email - Privacy') && cs.Member_Language__c =='English') {
                                                        cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                                                        cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];                                                         
                                                        cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                                                        cs.Assigned_from_Queue__c =false;
                                                    }
                                                    else if ((cs.Origin  == 'Email - Privacy' || TriggerOldMap.get(cs.id).Origin  == 'Email - Privacy') && cs.Member_Language__c !='' && cs.Member_Language__c !='English') {
                                                        cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_2').Id;
                                                        cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[1];                                                         
                                                        cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[2]; //'6';
                                                        cs.Assigned_from_Queue__c =false;
                                                    }
                                                    //CCPA Cases
                                                    else if (cs.Origin.Contains('Privacy') && cs.Origin != 'Email - Privacy'){
                                                        cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_2').Id;
                                                        cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[1];                                                         
                                                        cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[2]; //'6';
                                                        cs.Assigned_from_Queue__c =false;
                                                    }
                                                    else if(cs.RecordTypeId == getRecordTypesStatic.StandardRecordType || cs.RecordTypeId == getRecordTypesStatic.CallCenterRecordType) { 
                                                        //Domestic Cases (US or English)   
                                                        if(cs.Member_Language__c=='' || cs.Member_Language__c=='English') {
                                                            //Instant Book
                                                            if( cs.Subject !=null && (cs.Subject.Contains('Transaction') || cs.Subject.Contains('Booking') || cs.Subject.Contains('IB'))){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                          
                                                                cs.Priority = '1'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Care@Work, english
                                                            else if(cs.Employer_Program__c != null){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                          
                                                                cs.Priority = '2'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }   
                                                            //International, Visitor Downgrade Request
                                                            else if(cs.Subject !=null && cs.Subject =='Visitor Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                                                                cs.Type ='Visitor Downgrade Request';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            else if(cs.Subject !=null && cs.Subject =='Extraordinary Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.Type ='Extraordinary Downgrade Request';
                                                            }
                                                            //Premium Seeker AND Pending Active Seeker
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker' &&  (cs.Member_Overall_Status__c !=null && cs.Member_Overall_Status__c.Contains('Premium') || (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Premium')) || (cs.Member_Account_Type__c !=null && cs.Member_Account_Type__c == 'PendingActive')) ){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '3'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium Provider AND Pending Active Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Premium') || cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('PendingActive'))){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '4'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium (Featured) SMB Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='SMB_Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Featured') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '4';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Basic (Individual) Provider- Paid Basic
                                                            //Free Gated needs to be split out based on Package Tier Picklist. 
                                                            //This will need to be priotized under Paid Basic which will push all other 2nd prioties down by 1 number. 
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Basic') || cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Individual') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Basic SMB Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='SMB_Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Basic') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Basic Seeker - US English
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker' && ((cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c=='Basic') || (cs.Member_Overall_Status__c != null && cs.Member_Overall_Status__c.contains('Basic')))) {
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                          
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Lite
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c.Contains('Lite') ){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '6'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('200 Hour SLA').Id;
                                                            }
                                                            //US Domestic, Any Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c.Contains('Provider')){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            //US Domestic Default Queue is  changed to Member Care - EN Tier 1 on 21-03-2022 as part of SFORCE-4847, SFORCE-4705
                                                            else{
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                        }         
                                                    }
                                                    else if(cs.RecordTypeId ==getRecordTypesStatic.InternationalCallCenterRecordType || cs.RecordTypeId == getRecordTypesStatic.InternationalEmailRecordType){
                                                        if(cs.Member_Language__c=='' || cs.Member_Language__c=='English') {
                                                            //International, Visitor Downgrade Request
                                                            if(cs.Subject !=null && cs.Subject =='Visitor Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                                                                cs.Type ='Visitor Downgrade Request';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            else if(cs.Subject !=null && cs.Subject =='Extraordinary Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_2')[2]; //'6';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.Type ='Extraordinary Downgrade Request';
                                                            }
                                                            else if(cs.Type =='International Imprint'){                                                        
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            //Care@Work,Intl english
                                                            else if(cs.Employer_Program__c != null){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                          
                                                                cs.Priority = '2'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium Seeker AND Pending Active Seeker
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker' &&  (cs.Member_Overall_Status__c !=null && cs.Member_Overall_Status__c.Contains('Premium') || (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Premium')) || (cs.Member_Account_Type__c !=null && cs.Member_Account_Type__c == 'PendingActive')) ){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '3'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium Provider AND Pending Active Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Premium') || cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('PendingActive'))){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '4'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium (Featured) SMB Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='SMB_Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Featured') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '4';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Basic (Individual) Provider- Paid Basic
                                                            //Free Gated needs to be split out based on Package Tier Picklist. 
                                                            //This will need to be priotized under Paid Basic which will push all other 2nd prioties down by 1 number. 
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Basic') || cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Individual') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Basic SMB Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='SMB_Provider' && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Basic') )){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Basic Seeker - Intl English
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker' && ((cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c=='Basic') || (cs.Member_Overall_Status__c != null && cs.Member_Overall_Status__c.contains('Basic')))) {
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                          
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Lite
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c.Contains('Lite')){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = '6'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('200 Hour SLA').Id;
                                                            }
                                                            //US Domestic Default Queue is  changed to MC: EN Tier 1 on 21-03-2022 as part of SFORCE-4847, SFORCE-4705
                                                            else{
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                        }                                                      
                                                        //Non English (ROW) Cases
                                                        if(cs.Member_Language__c !='' && cs.Member_Language__c!='English') { 
                                                            //International, Visitor Downgrade Request
                                                            if(cs.Subject !=null && cs.Subject =='Visitor Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[2]; //'6';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.Type ='Visitor Downgrade Request';
                                                            }
                                                            else if(cs.Subject !=null && cs.Subject =='Extraordinary Downgrade Request'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_2').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_2')[2]; //'6';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.Type ='Extraordinary Downgrade Request';
                                                            }
                                                            else if(cs.Type =='International Imprint'){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            //Care@Work (Intl Row)
                                                            else if(cs.Employer_Program__c != null){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id; 
                                                                cs.Support_Skill__c= MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                          
                                                                cs.Priority = '1';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium Seeker AND Pending Active Seeker (Intl Row)
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker' &&  ((cs.Account !=null && cs.Account.Type__pc !=null && cs.Account.Type__pc.Contains('Premium')) || (cs.Member_Account_Type__c !=null && cs.Member_Account_Type__c == 'Premium') || (cs.Member_Account_Type__c !=null && cs.Member_Account_Type__c == 'PendingActive'))){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = '2';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Premium AND Pending Active Provider (Intl Row)
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Provider' && ((cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Premium')) || (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('PendingActive')))){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = '3'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('24 Hour SLA').Id;
                                                            }
                                                            //Basic Provider (Intl Row)
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c.Contains('Provider') && (cs.Member_Account_Type__c!=null && cs.Member_Account_Type__c.Contains('Basic')) ){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = '4'; 
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Basic Seeker (Intl Row)
                                                            else if((cs.AccountId !=null && cs.Account.Type__pc !=null && cs.Account.Type__pc.Contains('Basic')) || (cs.Member_Account_Type__c != null && cs.Member_Account_Type__c=='Basic') && cs.Member_Type__c !=null && cs.Member_Type__c =='Seeker') {
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = '4';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }
                                                            //Null or Visitor (Intl Row)
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c =='Visitor'){
                                                                cs.OwnerId=mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = '4';
                                                                cs.Assigned_from_Queue__c =false;
                                                                cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                            }                                                          
                                                            //ROW, Any Provider
                                                            else if(cs.Member_Type__c !=null && cs.Member_Type__c.Contains('Provider')){
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                            //International - Default Queue is  changed to MC: ROW Tier 1 on 21-03-2022 as part of SFORCE-4847, SFORCE-4705
                                                            else {
                                                                cs.OwnerId = mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                                cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                                cs.Priority = MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[2]; //'5';
                                                                cs.Assigned_from_Queue__c =false;
                                                            }
                                                        }
                                                    } //International Row Cases ends   
                                                }//ODS Check ends   
                                             else if(TriggerNewMap.get(cs.id).Is_ODS_Complete__c && !TriggerOldMap.get(cs.id).Is_ODS_Complete__c && (cs.Member_Type__c ==null || cs.Member_Account_Type__c==null)){
                                                 //when member is blank on case                                           
                                                 if(cs.Member_Language__c=='' || cs.Member_Language__c=='English'){
                                                     cs.OwnerId=mcNameGroupMap.get('Member_Care_EN_Tier_1').Id;
                                                     cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_EN_Tier_1')[1];                                                         
                                                     cs.Priority = MCGroupNamewithData.get('Member_Care_EN_Tier_1')[2]; //'5';
                                                     cs.Assigned_from_Queue__c =false;
                                                     cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                 }
                                                 //Member_Account_Type__c = null  OR Member_Type__c = null OR Visitor and  Intl - Row
                                                 else {
                                                     cs.OwnerId=mcNameGroupMap.get('Member_Care_ROW_Tier_1').Id;
                                                     cs.Support_Skill__c=MCGroupNamewithData.get('Member_Care_ROW_Tier_1')[1];                                                         
                                                     cs.Priority = '4';
                                                     cs.Assigned_from_Queue__c =false;
                                                     cs.EntitlementId = entitlementsMap.get('48 Hour SLA').Id;
                                                 }
                                             }                                             
                                         }
                                     }                                      
                              }                           
                           if(!CaseTriage.closeCaseStatus(cs.status) && cs.Origin =='Chat'){
                               if( TriggerNewMap.get(cs.id).OwnerId !=TriggerOldMap.get(cs.id).OwnerId && String.ValueOf(cs.OwnerId).left(3) == '00G' && isOmniQueue.get(cs.OwnerId)){
                                   if(!MCGroupIdwithData.isEmpty() && MCGroupIdwithData.containsKey(TriggerNewMap.get(cs.id).OwnerId)){
                                       cs.Priority = MCGroupIdwithData.get(TriggerNewMap.get(cs.id).OwnerId)[2]; // MCGroupIdwithData keys are : cm.Case_Queue__c, cm.Case_Skill__c, cm.Case_Priority__c, ownerId                                   
                                       cs.Support_Skill__c =MCGroupIdwithData.get(TriggerNewMap.get(cs.id).OwnerId)[1];
                                   }
                               }
                               string skillsetMain = '';
                               if(TriggerNewMap.get(cs.id).Support_Skill__c !=null){
                                   skillsetMain = TriggerNewMap.get(cs.id).Support_Skill__c;
                                   skillsetMain = skillsetMain.replaceAll('[^a-zA-Z0-9\\s+]', '');
                                   skillsetMain = skillsetMain.trim();
                                   skillsetMain = skillsetMain.replaceAll('(\\s+)', '_');
                               }
                               if(skillsetMain!='' && MCGroupNamewithData.containsKey(skillsetMain)){
                                   if( TriggerNewMap.get(cs.id).Support_Skill__c !=TriggerOldMap.get(cs.id).Support_Skill__c){                                          
                                       cs.Priority = MCGroupNamewithData.get(skillsetMain)[2];                                    
                                       cs.OwnerId = mcNameGroupMap.get(skillsetMain).Id;                                          
                                       cs.Assigned_from_Queue__c =false;
                                   }
                               }
                           }
                       } //Try method ends
                       catch(Exception e) {
                           System.debug('**An exception occurred: ' + e.getMessage() + e);
                       } //Catch method ends
                       finally {
                           System.debug('Closing the stream writer in the finally block.');
                           // Close the stream writer
                       }
                   }
            } //for loop ends
        }//caseMap ends
    } //routeCasetoAgent method ends
    //Custom Metadata Name: RecordType_for_Case_Triage__mdt and Method to get all recordTypes for case triaging
}