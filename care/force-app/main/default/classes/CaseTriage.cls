/*
Helper Class for Case Triage
Description:  Created for case triaging through case assignment rules for membercare cases by disabling breeze rules for member care
CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
ModifiedDate: 20/07/2023
*/
public class CaseTriage {  
    //Custom Metadata Name: Safety_Case_RecordType__mdt and Method to get all recordTypes for case triaging
    public static Map<Id, String> getRecordTypesforCaseTriage(string rtype){
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> MapRecordTypes = new Map<Id,String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(rtype == 'MC' && (info.getName() == 'Call Center' || info.getName() == 'Chargeback' || info.getName() == 'International Call Center' || info.getName() == 'International Email' || info.getName() == 'Standard')){
                MapRecordTypes.put(info.getRecordTypeId(), info.getName());
            }
            else if(rtype == 'Safety' && (info.getName() == 'Safety Alert' || info.getName() == 'International Safety Alert' ||  info.getName() == 'Premier Background Check')){
                MapRecordTypes.put(info.getRecordTypeId(), info.getName());
            }
            else if(rtype == 'Social' && (info.getName() == 'Social Media International' || info.getName() == 'Social Media US')){
                MapRecordTypes.put(info.getRecordTypeId(), info.getName());
            }
        }
        return MapRecordTypes;
    }
    //Check closed Case statuses
    Public static boolean closeCaseStatus(String strStatus){
        //Case statuses
        Set<String> caseStatuses = new Set<String>{'Duplicate', 'Resolved', 'Warning', 'Closed Account', 'Cleared', 'Closed-Loss', 'Closed-Won', 'Deleted', 'Auto-Closed', 'Closed'};
            if(caseStatuses.Contains(strStatus)){
                return true;
            }
        return false;
    }
    public static boolean safetyCasesNottoRoute(Case cs){
        String csSubject = cs.Subject.toLowercase();
        String intCase = Label.Do_Not_Route_These_Safety_Cases.toLowercase();
        List<String> SubjectSet = intCase.split(';');   
        
        if(SubjectSet.contains(csSubject)) {
            return true;
        }
        return false;
    }
    //checking automated user 
    public static Map<Id, user> isAutomatedUser(String UserName){
        //Map automated users
        String intUsers = Label.SystemUsers;
		List<String> userSet = intUsers.split(';');        
        Map<Id, user> userMap = new Map<Id, User>();
        userMap.putAll([Select id, name, email from user where name IN : userSet]);
        return userMap;
    }
    public static Map<String, Entitlement> getEntitlements(){
        Map<String, Entitlement> caseEntitlements = new Map<String, Entitlement>();
        for(Entitlement en:  [Select id , Name 
                              FROM Entitlement 
                              where Name  IN ('10 Hour SLA', 
                                              '24 Hour SLA', 
                                              '48 Hour SLA', 
                                              '200 Hour SLA')]){
                                                  caseEntitlements.put(en.Name, en);                         
                                              }            
        return caseEntitlements;
    }
    public static Id getBusinessHours(){
        BusinessHours bh = [Select id , Name FROM BusinessHours where Name = 'Default' LIMIT 1];
        Id caseBusinessHours = bh.Id;
        return caseBusinessHours;
    }
    //get safety Omni Queues
    public static Map<String, Group> safetyQueues(){        
        Map<String, Group> groupMap = new  Map<String, Group>();
        Set<String> queueNames = new Set<String>{'S_Inappropriate_Activity',
            'Member_Care_Closed',
            'S_Safety_Reviews' ,
            'Member_Care_EN_Tier_2',
            'Member_Care_ROW_Tier_2',
            'S_Member_Flags' ,
            'S_Blocklist_Partial_Match',
            'Q_Blocked_Member_Appeal',
            'S_Member_Review_Escalations', 
            'S_Accused_List_Match' ,
            'S_Fraud_Detection' ,
            'S_Identity_Verification',
            'RDC_List_Match',
            'RDC_List_Match_Medium_Risk' ,
            'Q_Premier_Background_Checks' ,
            'S_International_Safety_Alert',
            'S_Negative_Media'};
                for(Group g: [Select Id,  Name, DeveloperName, QueueRoutingConfigId, Email  
                              FROM Group 
                              WHERE DeveloperName IN : queueNames limit 20]){           
                                  groupMap.put(g.DeveloperName, g);            
                              }
        return groupMap;
    }
    //Custom Metadata Name: RecordType_for_Case_Triage__mdt
    public static  Map<String, List<String>> mapCustomMetadata(){
        Map<String, List<String>> MCQueueData = new Map<String, List<String>>();
        List<Custom_Case_Configuration__mdt> ListcpMdt = [select id,DeveloperName, Case_Skill__c,Case_Queue__c,Case_Priority__c, Case_RecordType__c, Case_Status__c, Order__c FROM Custom_Case_Configuration__mdt];
        if (!ListcpMdt.isEmpty()){
            for(Custom_Case_Configuration__mdt cm : ListcpMdt){
                List<String> lst = new List<String> {cm.Case_Queue__c, cm.Case_Skill__c, cm.Case_Priority__c};
                    MCQueueData.put(cm.DeveloperName , lst);
            }
        }
        return MCQueueData;
    } 
}