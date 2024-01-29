/*
Helper Class for Case Triage
Description:  Created for case triaging through case assignment rules for membercare cases by disabling breeze rules for member care
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
ModifiedDate: 21/06/2023
*/
public without sharing class SMCaseTriage {
    List<Case> newList;
    Map<id,Case> TriggerNewMap;
    Map<id, Case> TriggerOldMap;
    Boolean isBeforeInsert;
    Boolean isBeforeUpdate;
    
    public SMCaseTriage(List<Case> newList, Map<id, Case> TriggerNewMap, Map<id, Case> TriggerOldMap, Boolean isBeforeInsert, Boolean isBeforeUpdate){
        this.newList = newList;
        this.TriggerNewMap = TriggerNewMap;
        this.TriggerOldMap = TriggerOldMap;
        this.isBeforeInsert = isBeforeInsert;
        this.isBeforeUpdate = isBeforeUpdate;
        
    }
    public  void routeCasetoAgent() {
        SYSTEM.DEBUG(isBeforeInsert+'routeCasetoAgent ****4'+isBeforeUpdate);
        Map<id,User> integrationUser = CaseTriage.isAutomatedUser(UserInfo.getUserId());        
        Map<Id, String> SMRecMap = CaseTriage.getRecordTypesforCaseTriage('Social');        
        Map<String, Group> smNameGroupMap = new  Map<String, Group>();
        for(Group g: [Select Id,  Name, DeveloperName, QueueRoutingConfigId, Email  FROM Group where DeveloperName in ('Member_Care_EN_SM', 'Member_Care_ROW_SM', 'Member_Care_EN_SM_Private', 'Member_Care_EN_SM_Public')]){
            smNameGroupMap.put(g.DeveloperName, g);
        }
        
        for(Case cs: newList){            
            SYSTEM.DEBUG(cs.isClosed+'cs.isClosed ****4'+SMRecMap.containsKey(cs.RecordTypeId));
            if(SMRecMap.containsKey(cs.RecordTypeId)){
                if(isBeforeInsert){
                    SYSTEM.DEBUG('Insert ****4');
                    routeCasetoQueueInsert(smNameGroupMap, integrationUser);
                }
                else if(isBeforeUpdate){
                    SYSTEM.DEBUG('Update ****4');
                    routeCasetoQueueUpdate(smNameGroupMap, integrationUser);
                }
                
            }
        }     
    }
    
    public  void routeCasetoQueueInsert(Map<String, Group> smNameGroupMap, Map<id,User> integrationUser) {
        //UserInfo.getName()
        for(Case cs : newList){
           // if(integrationUser.containsKey(UserInfo.getUserId()) && integrationUser.containsKey(cs.ownerId) &&  String.ValueOf(cs.ownerId).left(3) != '00G' && !CaseTriage.closeCaseStatus(cs.status)){
                SYSTEM.DEBUG('New Integration user ****4');
                if(cs.Region_Sprinklr__c !=null && cs.Region_Sprinklr__c.contains('International') && cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId()){
                    cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
                    cs.OwnerId = smNameGroupMap.get('Member_Care_ROW_SM').Id;
                    cs.Support_Skill__c= 'Member Care - ROW SM';                                                        
                    cs.Priority = '6';
                    cs.Assigned_from_Queue__c =false;
                } 
            	/*else if( cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId() &&  cs.Initial_Message_Privacy_Sprinklr__c !=null && (cs.Initial_Message_Privacy_Sprinklr__c =='Private' || cs.Initial_Message_Privacy_Sprinklr__c.contains('Private'))){
                    cs.OwnerId = smNameGroupMap.get('Member_Care_EN_SM_Private').Id;
                    cs.Support_Skill__c= 'Member Care - EN SM Private';                                                        
                    cs.Priority = '6';
                    cs.Assigned_from_Queue__c =false;
                } 
            	else if( cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId() &&  cs.Initial_Message_Privacy_Sprinklr__c !=null && (cs.Initial_Message_Privacy_Sprinklr__c =='Public' || cs.Initial_Message_Privacy_Sprinklr__c.contains('Public'))){
                    cs.OwnerId = smNameGroupMap.get('Member_Care_EN_SM_Public').Id;
                    cs.Support_Skill__c= 'Member Care - EN SM Public';                                                        
                    cs.Priority = '6';
                    cs.Assigned_from_Queue__c =false;
                } */
                else if( cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId() ){
                    cs.OwnerId = smNameGroupMap.get('Member_Care_EN_SM').Id;
                    cs.Support_Skill__c= 'Member Care - EN SM';                                                        
                    cs.Priority = '6';
                    cs.Assigned_from_Queue__c =false;
                } 
                else if( cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId()){
                    cs.OwnerId = smNameGroupMap.get('Member_Care_ROW_SM').Id;
                    cs.Support_Skill__c= 'Member Care - ROW SM';                                                        
                    cs.Priority = '6';
                    cs.Assigned_from_Queue__c =false;
                } 
           // }                    
        }
    }
    public  void routeCasetoQueueUpdate(Map<String, Group> smNameGroupMap, Map<id,User> integrationUser) {
        for(Case cs : TriggerNewMap.values()){
            if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId() && TriggerOldMap.get(cs.id).Social_PostTags__c == null && TriggerNewMap.get(cs.id).Social_PostTags__c !=null && TriggerNewMap.get(cs.id).Social_PostTags__c.contains('International')){
                cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
                cs.OwnerId = smNameGroupMap.get('Member_Care_ROW_SM').Id;
                cs.Support_Skill__c= 'Member Care - ROW SM';                                                        
                cs.Priority = '6';
                cs.Assigned_from_Queue__c =false;
            }
            else if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId() && TriggerOldMap.get(cs.id).Region_Sprinklr__c == null && TriggerNewMap.get(cs.id).Region_Sprinklr__c !=null && TriggerNewMap.get(cs.id).Region_Sprinklr__c.contains('International')){
                cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
                cs.OwnerId = smNameGroupMap.get('Member_Care_ROW_SM').Id;
                cs.Support_Skill__c= 'Member Care - ROW SM';                                                        
                cs.Priority = '6';
                cs.Assigned_from_Queue__c =false;
            } 
            else if((integrationUser.containsKey(UserInfo.getUserId()) && String.ValueOf(cs.OwnerId).left(3) != '00G' && !integrationUser.containsKey(cs.ownerId) && !CaseTriage.closeCaseStatus(TriggerNewMap.get(cs.id).status) && CaseTriage.closeCaseStatus(TriggerOldMap.get(cs.id).status)) ||
               (TriggerNewMap.get(cs.id).CaseTriage__c && TriggerNewMap.get(cs.id).CaseTriage__c !=TriggerOldMap.get(cs.id).CaseTriage__c)){
                   //When New Social Media US case is created through Social Studio or When a Social Media case reopens
                   if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId()){
                       cs.OwnerId = smNameGroupMap.get('Member_Care_EN_SM').Id;
                       cs.Support_Skill__c= 'Member Care - EN SM';                                                         
                       cs.Priority = '6';
                       cs.Assigned_from_Queue__c =false;
                   }
                   else if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId()){
                       cs.OwnerId = smNameGroupMap.get('Member_Care_ROW_SM').Id;
                       cs.Support_Skill__c= 'Member Care - ROW SM';                                                         
                       cs.Priority = '6';
                       cs.Assigned_from_Queue__c =false;
                   } 
               }
            if(TriggerNewMap.get(cs.id).Crisis_Keyword_Sprinklr__c != TriggerOldMap.get(cs.id).Crisis_Keyword_Sprinklr__c &&  TriggerNewMap.get(cs.id).Crisis_Keyword_Sprinklr__c=='Yes'){
                cs.Priority ='5';
            }
        }    
    }
}