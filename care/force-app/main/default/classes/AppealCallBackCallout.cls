public class AppealCallBackCallout implements Queueable,Database.AllowsCallouts{
    public List<case> caseList ; 
    public AppealCallBackCallout(List<case> caseList){
        this.caseList = caseList ;  
    }

   	public void execute(QueueableContext context) {
         Appealcallout__mdt mcs = Appealcallout__mdt.getInstance('appeal');
                string endpoint = mcs.Endpoint__c;  
                string username = mcs.UserName__c;
                string password = mcs.Password__c;
        List<case> updateCaseList = new List<case>();
        Set<Id> Usrid = new Set<Id>();
        Set<Id> Caseid= new Set<Id>();
        String  emailAddresses;
        String  Fname;
        String  Lname;
       //Get User id/last modified id
        for(case cas:caseList){
              system.debug(' case id'+ cas.Id);
              Caseid.add(cas.id);
             
        }
        
        for (Case Cs : [SELECT LastModifiedBy.id FROM Case WHERE Id IN :Caseid])   
             {
                  system.debug(' cs.LastModifiedBy.id'+ cs.LastModifiedBy.id);
               Usrid.add(cs.LastModifiedBy.id);
                
            }
         for (User u : [SELECT email,Firstname,Lastname FROM User WHERE Id IN :Usrid])         
          {
               system.debug(' User details'+ U);
                emailAddresses=u.email;
                Fname=u.Firstname;
                Lname=u.Lastname;
               system.debug(' Usrid'+ Usrid);
                
            }
        for(case cas:caseList){
        	callbackResponce callbackReq = new callbackResponce();
        	callbackReq.case_id=cas.ID;
            callbackReq.case_status=cas.Status;
            callbackReq.appeal_decision=cas.Appeal_Decision__c;
            callbackReq.appeal_decision_reason=cas.Appeal_Decision_Reason__c;
            callbackReq.case_updated_time=cas.LastModifiedDate;
            callbackReq.case_updated_by_email=emailAddresses;
            callbackReq.case_updated_by_first_name=Fname;
            callbackReq.case_updated_by_last_name= Lname;
            callbackReq.Appeal_Free_form_justification= cas.Appeal_Free_form_justification__c;
         string reqBody=JSON.serialize(callbackReq);
        system.debug('----------'+JSON.serialize(callbackReq));
        system.debug('endpoint'+endpoint);
        system.debug('username'+username);
        system.debug('password'+password);

        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(120000);        
            Blob headerValue = Blob.valueOf(username + ':' + password);        
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);            
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(reqBody);
            res = h.send(req); 
           	case updateCaseRec = new case(id=cas.id);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 204 || res.getStatusCode() == 201){
                updateCaseRec.Syc_Status_message__c='Success!';
                updateCaseList.add(updateCaseRec);
                
            }else{
                updateCaseRec.Syc_Status_message__c='Error:'+res.getBody();
                updateCaseList.add(updateCaseRec);
            }
           system.debug('SF CallBackres'+ res+res.getStatusCode());  
       }
        update updateCaseList;
    }
    public class callbackResponce{
        public string case_id;
        public string case_status;
        public string appeal_decision;
        public string appeal_decision_reason;
        public dateTime case_updated_time;
        public string case_updated_by_email;
        public string case_updated_by_first_name;
        public string case_updated_by_last_name;
        public string Appeal_Free_form_justification;
             
    } 
    

   
}