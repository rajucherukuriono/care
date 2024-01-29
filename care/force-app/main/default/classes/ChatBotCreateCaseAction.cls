public class ChatBotCreateCaseAction {
    @InvocableMethod
    public static List <String> execute (List<Requests> requests) {
        LiveChatTranscript ct = [SELECT Id, CaseId FROM LiveChatTranscript WHERE Id = :requests[0].transcriptId];
        
        
        Case c = [SELECT Id, Status, No_Agent_For_Live_Chat__c  FROM Case WHERE Id = :ct.CaseId];
        //Set case fields to trigger breeze rule
        if(requests[0].routeCase.toLowerCase() == 'yes'){
            c.Chat_Case__c = 'No';
            c.Origin = 'Web';
            c.Auto_Response_Status__c = 'Not Invoked';
            //c.Run_Through_BREeze__c = true;
        }else if(requests[0].routeCase.toLowerCase() == 'no'){
            // Close case
            c.Status = 'Auto-closed';
            c.No_Agent_For_Live_Chat__c = true;
        }
        
        update c;
        return new List<String>{(String)c.Id};    
    }
    
    public class Requests {
        @InvocableVariable(label='Transcript Id' description='Id of the Case to be updated' required=true)
        public Id transcriptId;
        @InvocableVariable(label='Route Case?' description='Yes to route Case to queue, No to close Case' required=true)
        public String routeCase;
    }
    
}