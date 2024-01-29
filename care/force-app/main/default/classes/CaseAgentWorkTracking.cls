/*
Helper Class for CaseAgentWorkTracking
Description:  Created for Case Agent Work Tracking
CreatedBy : md Ashwaq
CreatedDate: 12/11/2021
*/
public class CaseAgentWorkTracking {
    public static void stampAgentAssignmentTime(list<Case>NewRecords, list<Case>OldRecords,map<Id, Case>NewMap,  map<Id, Case>oldMap)
	{
        Map<Id, String> recTypeIds = CaseTriage.getRecordTypesforCaseTriage('MC');
        Map<Id, String> mcIdGroupMap = new  Map<Id, String>();
        Map<String, group> MCGroups = new Map<String, group>();
        Map<String, List<String>> groupIds = CaseTriage.mapCustomMetadata();
        for(Group g: [Select Id,  Name, DeveloperName, QueueRoutingConfigId, Email  FROM Group where DeveloperName in : groupIds.KeySet()]){              
            mcIdGroupMap.put(g.Id, g.DeveloperName);
            MCGroups.put(g.DeveloperName, g);
        }
        
        //get all MC cases , status open and closed
        Map<Id, case> caseMap = new Map<Id, Case>();
        for(Case c: NewRecords){
             string skillsetMain = '';
            if(C.Support_Skill__c !=null){
                skillsetMain = C.Support_Skill__c;
                skillsetMain = skillsetMain.replaceAll('[^a-zA-Z0-9\\s+]', '');
                skillsetMain = skillsetMain.trim();
                skillsetMain = skillsetMain.replaceAll('(\\s+)', '_');
            }
             if(recTypeIds.ContainsKey(c.RecordTypeId) && !c.Safety_email__c && MCGroups.containskey(skillsetMain)){
                 caseMap.put(C.id, C);
             }
        }
        
        //Getting all open agent records on case
        Map<id, list<Agent_work__c>> caseAgentMap = new Map<id, list<Agent_work__c>>();
        for(Agent_work__c ag:  [Select id, status__c, name, Agent_Lookup__c,Agent_Text__c,Case__c,Start_Date_Time__c,  End_Date_Time__c, Start_Date_Time_H_M_S__c,End_Date_Time_H_M_S__c, OwnerId from Agent_Work__c where Case__c IN: caseMap.keySet() and status__c !='Closed' ]) {
            if(caseAgentMap.containsKey(ag.Case__c) && caseAgentMap.get(ag.Case__c) != null) {
                List<Agent_work__c> lst_agent = caseAgentMap.get(ag.Case__c);
                lst_agent.add(ag);
                caseAgentMap.put(ag.Case__c,lst_agent); 
            }   
            else {
                caseAgentMap.put(ag.Case__c, new List<Agent_work__c> {ag});
            }
        }
        
        //New Agent related record will created when Case owner changes from Queue to Agent
        //Agnet start dtae is stamped when case is open and not onhold or escalated
        //Agent end date will be populated when agent changed to next agent, a new RL is created for new agent
        List<Agent_Work__c> updListAgent = new List<Agent_Work__c>();
        for(Case C: NewRecords){
            System.debug('****into for loop');
            //Puls only the records which are Member care cases
            string skillsetMain = '';
            if(C.Support_Skill__c !=null){
                skillsetMain = C.Support_Skill__c;
                skillsetMain = skillsetMain.replaceAll('[^a-zA-Z0-9\\s+]', '');
                skillsetMain = skillsetMain.trim();
                skillsetMain = skillsetMain.replaceAll('(\\s+)', '_');
            }
            if(recTypeIds.ContainsKey(c.RecordTypeId) && !C.Safety_email__c && MCGroups.containskey(skillsetMain)){                
                if(oldMap.get(C.id).OwnerId !=  NewMap.get(C.id).OwnerId && !C.IsClosed){
                    //1. when owner changes from queue to user  - New Agent
                    if(String.ValueOf(oldMap.get(C.id).OwnerId).left(3) == '00G' && String.ValueOf(NewMap.get(C.id).OwnerId).left(3) != '00G'){	
                        createAgentWork(C);
                    }                    
                    //2. When owner changes from User to Queue - Update old Agent
                    if(String.ValueOf(oldMap.get(C.id).OwnerId).left(3) != '00G' && String.ValueOf(NewMap.get(C.id).OwnerId).left(3) == '00G') {
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }                    
                    //3. when owner changes from user to user - New Agent / update old agent
                    if(String.ValueOf(oldMap.get(C.id).OwnerId).left(3) != '00G' && String.ValueOf(NewMap.get(C.id).OwnerId).left(3) != '00G'){
                        createAgentWork(C);
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }
                }
                
                if(oldMap.get(C.id).Status !=  NewMap.get(C.id).Status && String.ValueOf(C.OwnerId).left(3) != '00G' ){
                    //4. when status changes from Open to Close - update old agent
                    if(!OldMap.get(C.id).IsClosed && OldMap.get(C.id).Status !='On Hold' && OldMap.get(C.id).Status !='Escalated' &&  NewMap.get(C.id).IsClosed){
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }                    
                    //5. when status changes from close to open - new agent
                    if(OldMap.get(C.id).IsClosed &&  !NewMap.get(C.id).IsClosed && NewMap.get(C.id).Status !='On Hold' &&  NewMap.get(C.id).Status !='Escalated' ){
                        createAgentWork(C);
                    }
                    //6. when status changes from open to esc/hold - update old agent /  new agent
                    if(!OldMap.get(C.id).IsClosed &&  OldMap.get(C.id).Status !='On Hold' &&  OldMap.get(C.id).Status !='Escalated' &&  (NewMap.get(C.id).Status =='On Hold' ||  NewMap.get(C.id).Status =='Escalated' ) ){
                        createAgentWork(C);
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }
                    //7. when status changes from esc/hold to open - update old agent /  new agent
                    if((OldMap.get(C.id).Status =='On Hold' ||  OldMap.get(C.id).Status =='Escalated') &&  NewMap.get(C.id).Status !='On Hold' && NewMap.get(C.id).Status !='Escalated'  && !NewMap.get(C.id).IsClosed){
                        createAgentWork(C);
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }
                    //8. when status changes from closed to esc/hold - new agent
                    if(OldMap.get(C.id).IsClosed &&  (NewMap.get(C.id).Status =='On Hold' ||  NewMap.get(C.id).Status =='Escalated' ) ){
                        createAgentWork(C);
                    }
                    //9.when status changes from esc/hold to closed - update old agent
                    if(NewMap.get(C.id).IsClosed &&  (OldMap.get(C.id).Status =='On Hold' ||  OldMap.get(C.id).Status =='Escalated' ) ){
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }
                    //10.when status changes from esc to hold and vice versa- update old agent / new agent
                    if((OldMap.get(C.id).Status =='On Hold' && NewMap.get(C.id).Status =='Escalated') ||  (OldMap.get(C.id).Status =='Escalated' && NewMap.get(C.id).Status =='On Hold')){
                        createAgentWork(C);
                        updateAgentWork(oldMap.get(C.id), caseAgentMap);
                    }
                }
                
        	}	
        }
    }
    
    @InvocableMethod(label='create AgentWorkRL' description='UPDATE CASE' category= 'Case')
    public static void createAgentWork(List<Id> CaseIds) {        
        Map<Id, case> caseMap = new Map<Id, Case>();
        if(CaseIds!=null){
            for(Case C :[select Id, IsClosed, Creator_License__c,Social_PostTags__c,OwnerId, Owner.Name, Safety_Email__c, RecordTypeId, RecordType.Name,Run_Through_BREeze__c, MC_Email__c, Member_Locale__c,  CaseTriage__c,  Case_Triage_Step__c, Member_Language__c, Support_Skill__c,Priority, Origin,Member_Overall_Status__c, Member_Type__c, AccountId, Account.Type__pc, Member_Account_Type__c from case where id in :CaseIds  and isClosed =false and Safety_Email__c=false]){
                caseMap.put(C.id, C);
            }        
        }
        //New Agent related record will created when Case owner changes from Queue to Agent
        //Agnet start dtae is stamped when case is open and not onhold or escalated
        //Agent end date will be populated when agent changed to next agent, a new RL is created for new agent
        List<Agent_Work__c> updListAgent = new List<Agent_Work__c>();
        if(!caseMap.isEmpty()){
            for(Case C: caseMap.values()){
                //Scenario 1
                //When owner changes from Queue to Agent
                //status is not closed, onhold, escalated
                Agent_Work__c ag = new Agent_Work__c();
                ag.Case__c = C.id;
                ag.Status__c ='Open';
                ag.OwnerId = C.OwnerId;                    
                ag.Agent_Lookup__c = C.OwnerId;
                ag.Start_Date_Time__c = datetime.now();
                ag.Start_Date_Time_H_M_S__c = datetime.now().format('MM-dd-yyyy HH:mm:ss');
                updListAgent.add(ag);
            }
            if(!updListAgent.isEmpty()){
                Upsert updListAgent;
            }
        }
    }    
    
    public static void updateAgentWork(Case C , Map<id, list<Agent_work__c>> caseAgentMap){
        List<Agent_Work__c> updListAgent = new List<Agent_Work__c>();
        if(!caseAgentMap.isEmpty()){
            if(caseAgentMap.containsKey(C.id)){
                List<Agent_Work__c> existingAgent = caseAgentMap.get(C.Id);		
                for(Agent_Work__c ag: existingAgent){
                    if(ag.OwnerId ==c.OwnerId && ag.End_Date_Time__c == null){
                        ag.End_Date_Time__c = datetime.now();
                        ag.End_Date_Time_H_M_S__c = datetime.now().format('MM-dd-yyyy HH:mm:ss');
                        if(C.Status !='On Hold' && C.Status !='Escalated' && !C.IsClosed){
                            ag.Status__c ='Closed';
                        }
                        if(C.Status =='On Hold' || C.Status =='Escalated'){
                            ag.Status__c =C.Status;
                        }
                        updListAgent.add(ag);
                    }
                }
            }
        }
        if(!updListAgent.isEmpty()){
            update updListAgent;
        }
    }
    public static void createAgentWork(Case CS){
        List<Agent_Work__c> insertListAgent = new List<Agent_Work__c>();
        Agent_Work__c ag = new Agent_Work__c();
        ag.Case__c = CS.id;
        Case C = [Select id , ownerId, Status, isClosed from case where Id=:CS.id];
        if(String.ValueOf(C.OwnerId).left(3) != '00G'){
            if(C.Status !='On Hold' && C.Status !='Escalated' && !C.IsClosed){
                ag.Status__c ='Open';
            }
            if(C.Status =='On Hold' || C.Status =='Escalated'){
                ag.Status__c =C.Status;
            }
            ag.OwnerId = C.OwnerId;                    
            ag.Agent_Lookup__c = C.OwnerId;
            ag.Start_Date_Time__c = datetime.now();
            ag.Start_Date_Time_H_M_S__c = datetime.now().format('MM-dd-yyyy HH:mm:ss');
            insertListAgent.add(ag);
        }
        if(!insertListAgent.isEmpty()){
            insert insertListAgent;
        }
    }
}