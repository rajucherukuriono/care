/*
Class for Integration between SF and Peoplesoft
Description:  This class retrieve all the data to e pushed to PS and makes the Rest Api call. 
Supported Test class:SyncBatch_Test
CreatedBy : shahid
*/
public class SyncCase {   
    
    @InvocableMethod(callout=true)
    public Static list<string> doSyncCase(List<case> inputCases){
        
        list<Case> caseSoql=[SELECT ID,
                                     CaseNumber,
                                     MemberUUID__c,
                                     Program_ID__c,
                                     Service_Type__c,
                                     Service_ID__c,
                                     Status,
                             		 Account.PersonEmail,
                             		 Account.FirstName,
                             		 Account.LastName,
                             		 Account.PersonMailingstreet, 
                                     Account.PersonMailingCity,
                                     Account.PersonMailingpostalcode,
                                     Account.PersonMailingcountry,
                                     Account.PersonMailingstate,
                                     Account.LifeCare_Company_Id__c,
                                     Account.memberUUID__c,
                                     Syc_Status_message__c,
                                    // IsCaseSync__c,
                                     First_Name_of_recipient__c,
                                     Last_Name_of_recipient__c,
                                     Relationship_to_Seeker__c,
                                     Date_of_Birth__c,
                                     Gender_Preference__c,
                                     ClosedDate,
                                     Quick_Code_Case_Type__c,
                                     Recipient_s_Address__c,
									 Recipient_s_City__c,
									 Recipient_s_State__c,
									 Recipient_s_Zip__c,
                                     Description,
                                     CreatedDate,
                                     Due_Date__c,
                                     Subject,
                                     Origin,
                                     SLA_Late_Response_Reason__c,
                                     Care_to_Begin_Date__c,
                                     Business_Account_w_Benefits__r.LifeCare_Company_Id__c,
                                     Question1__c,
                                     Question2__c,
                                     Question3__c,
                                     Question4__c,
                                     Question5__c,
                                     Question6__c,
                                     Question7__c, 
                                     Question8__c,
                                     Question9__c,
                                     Owner.name
                                     FROM Case WHERE ID =:inputCases[0].Id];
               
             string result = callCallout(caseSoql[0]);
        return  new list<string>{result};
     }
   
    public static string callCallout(case caserecord){
        Integer maxSize = 80;
        SynCaseWrapper.ClsCreateCompIntfcLCSFCASECI reqString= new SynCaseWrapper.ClsCreateCompIntfcLCSFCASECI();
        //List<Group> lstQueueRecords = [Select id, Name from Group where id = :caserecord.OwnerId];
        reqString.LC_SFORCE_CASE_NBR  =caserecord.CaseNumber; 
        reqString.LC_SFCASE_ID=0;
        reqString.LC_EMPLID =caserecord.Account.memberUUID__c;
        reqString.CUST_ID =caserecord.Business_Account_w_Benefits__r.LifeCare_Company_Id__c; 
        reqString.LC_PRGM_NAME =caserecord.Program_ID__c;
        reqString.LC_SERVICE_TYPE_NM =caserecord.Service_Type__c;
        reqString.LC_SERVICE_ID_DESC =caserecord.Service_ID__c; 
        reqString.CLOSED_DTTM =string.Valueof(caserecord.ClosedDate);
        reqString.STATUS_FIELD =caserecord.Status;
      	reqString.FIRST_NAME=caserecord.Account.FirstName;
        reqString.LAST_NAME=caserecord.Account.LastName;
        reqString.GENDER=caserecord.Gender_Preference__c=='Male'?'M':'F';
        reqString.EMAILID=caserecord.Account.PersonEmail;
        reqString.ADDRESS1=caserecord.Account.PersonMailingstreet;
        reqString.ADDRESS2='';
        reqString.CITY=caserecord.Account.PersonMailingCity;
        reqString.STATE=caserecord.Account.PersonMailingstate;
        reqString.COUNTRY='USA';
        reqString.POSTAL=caserecord.Account.PersonMailingpostalcode;
        reqString.ADDRESS_TYPE='MAIL';
        reqString.QUICK_CD=caserecord.Quick_Code_Case_Type__c;
        reqString.RC_DESCRLONG=caserecord.Description;
        reqString.CREATEDTTM=string.Valueof(caserecord.CreatedDate);  
        reqString.DUE_DATE=string.Valueof(caserecord.Due_Date__c);
        if(caserecord.Subject !=null && caserecord.Subject.length() > maxSize )
        reqString.RC_SUMMARY =caserecord.Subject.substring(0, maxSize);
        else
        reqString.RC_SUMMARY=caserecord.Subject;
        reqString.CASE_TYPE=caserecord.Origin;
        reqString.DESCR=caserecord.SLA_Late_Response_Reason__c;
        reqString.LC_SF_CTBDATE=string.Valueof(caserecord.Care_to_Begin_Date__c);
        reqString.LC_CASE_OWNER=caserecord.Owner.name;
         system.debug('OWNER-->'+caserecord.Owner.name);
       
      
        list<SynCaseWrapper.cls_LC_SF_DEP_INFO > CarerepList = new list<SynCaseWrapper.cls_LC_SF_DEP_INFO>();
        list<SynCaseWrapper.cls_LC_SFCASE_SVACT> ndsaList = new list<SynCaseWrapper.cls_LC_SFCASE_SVACT>();
        list<SynCaseWrapper.cls_LC_SFCASE_PROD > productList = new list<SynCaseWrapper.cls_LC_SFCASE_PROD>();
        list<SynCaseWrapper.cls_LC_SFCASE_QUES> QuesList = new list<SynCaseWrapper.cls_LC_SFCASE_QUES>();//EAP questions
        
        //EAP questions
        map<string,Case_Questions__mdt> caseques=Case_Questions__mdt.getAll();
        if( caserecord.Question1__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q1').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q1').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question1__c;
                QuesList.add(Ques);
            }
			
			if(Caserecord.Question2__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID = caseques.get('Q2').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q2').AnswersetId__c;
               // Ques.ANSWER_VALUE = caserecord.Question2__c;
                QuesList.add(Ques);
            } 
        
          if(Caserecord.Question3__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q3').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q3').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question3__c;
                QuesList.add(Ques);
                
		
            } 
         if(Caserecord.Question4__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q4').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q4').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question4__c;
                QuesList.add(Ques);
                
		
            } 
         if(Caserecord.Question5__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q5').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q5').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question5__c;
                QuesList.add(Ques);
                
		
            } 
         if(Caserecord.Question6__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q6').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q6').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question6__c;
                QuesList.add(Ques);
                
		
            } 
         if(Caserecord.Question7__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q7').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q7').AnswersetId__c;
                //Ques.ANSWER_ID = caserecord.Question1__c;
                Ques.ANSWER_VALUE = caserecord.Question7__c;
                QuesList.add(Ques);
                
		
            } 
        if(Caserecord.Question8__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q8').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q8').AnswersetId__c;
                Ques.ANSWER_VALUE = caserecord.Question8__c;
                QuesList.add(Ques);
                
		
            } 
         if(Caserecord.Question9__c !=null)
			{
                SynCaseWrapper.cls_LC_SFCASE_QUES  Ques = new SynCaseWrapper.cls_LC_SFCASE_QUES ();
                Ques.QUESTION_ID =caseques.get('Q9').QuestionId__c;
                Ques.RC_ANSWERSET_ID =caseques.get('Q9').AnswersetId__c;
                Ques.ANSWER_VALUE = caserecord.Question9__c;
                QuesList.add(Ques);
                
		
            } 
        reqString.LC_SFCASE_QUES  = QuesList;
         system.debug(' reqString.LC_SFCASE_QUES-->'+reqString.LC_SFCASE_QUES); 
		
		 //Retrive Care reciepents related to the case
        for(Care_Recipient__c Crp :[Select Id,
                                FirstName__c,
								LastName__c,
								DateOfBirth__c,
								Relationship_to_Seeker__c,
								Street_Address__c,
                                City__c,
								State__c,
                                Country__c,
                                Zip_Code__c								
                                From Care_Recipient__c where Case__c=:caserecord.Id])
        {
           
                SynCaseWrapper.cls_LC_SF_DEP_INFO  CarerepObj = new SynCaseWrapper.cls_LC_SF_DEP_INFO(); 
				 	CarerepObj.FIRST_NAME1=Crp.FirstName__c;	
					CarerepObj.LAST_NAME1=Crp.LastName__c;
					//CarerepObj.ROLE_TYPE_NAME =Crp.Relationship_to_Seeker__c;
					if(CarerepObj.ROLE_TYPE_NAME =='DOMESTIC_PARTNER')
                    CarerepObj.ROLE_TYPE_NAME ='Domestic Partner';
                    else 
                    CarerepObj.ROLE_TYPE_NAME =Crp.Relationship_to_Seeker__c;
                   	CarerepObj.BIRTHDATE=string.Valueof(Crp.DateOfBirth__c);
					CarerepObj.ADDRESS1_AC=Crp.Street_Address__c;
					CarerepObj.ADDRESS2_AC='';
					CarerepObj.CITY_AC=Crp.City__c;
					CarerepObj.STATE2=Crp.State__c;
					CarerepObj.COUNTRY2=Crp.Country__c;
					CarerepObj.POSTAL_OTHER=Crp.Zip_Code__c;
					CarerepObj.LC_ADDR_TYPE='MAIL';

                CarerepList.add(CarerepObj);
            
        }
		
		    reqString.LC_SF_DEP_INFO = CarerepList;
        
        for(Task rearch :[Select
                                Research_Type__c,
                                Lifecare_Activity_Type__c,
                                Care_to_Begin__c,
                                status,
                                Created_Date_Time__c,
                                CompletedDateTime
                                From task where WhatId=:caserecord.Id])
        {
            if(rearch.Lifecare_Activity_Type__c == 'Needs Assessment Completed'){
               SynCaseWrapper.cls_LC_SFCASE_SVACT  acticity = new SynCaseWrapper.cls_LC_SFCASE_SVACT (); 
                acticity.ACTIVITY_CODE = 'NDSASST';
                acticity.START_DT = String.ValueOf(rearch.Created_Date_Time__c);
                acticity.END_DT = String.ValueOf(rearch.CompletedDateTime);
                acticity.LC_ACT_STATUS_DESC =rearch.status; 
                ndsaList.add(acticity);
            }
          
            if(rearch.Lifecare_Activity_Type__c == 'Research'){
                 SynCaseWrapper.cls_LC_SFCASE_PROD   productObj = new SynCaseWrapper.cls_LC_SFCASE_PROD();
                 productObj.PRODUCT_NAME = rearch.Research_Type__c;
                 productObj.ACTIVITY_CODE_0 ='RSCH';
                 productObj.END_DT_0 = String.ValueOf(rearch.CompletedDateTime);
                 productObj.START_DT_0 = String.ValueOf(rearch.Created_Date_Time__c);
                 productObj.LC_ACT_STATUS_DESC_0 = rearch.status;
                 productList.add(productObj);
            }
        }
       
        //Populate the PS component for activities
        reqString.LC_SFCASE_SVACT = ndsaList;
        reqString.LC_SFCASE_PROD = productList;
        
       //Prepare the Jason for call out         
       String jsonBody = '{\"Create__CompIntfc__LC_SFCASE_CI\":'+JSON.serialize(reqString)+'}'; 
        jsonBody= jsonBody.replace('null','\"\"');
        system.debug('Case Details--------------->'+jsonBody);
        List<Peoplesoftcrmcallout__mdt> mcs = Peoplesoftcrmcallout__mdt.getAll().values();
        string endpoint = mcs[0].Endpoint__c;  
        string getendpoint =mcs[0].Get_Endpoint__c;
        string username = mcs[0].UserName__c;
        string password = mcs[0].Password__c;
        string method = 'POST';
        system.debug('endpoint-->'+endpoint);
        system.debug('getendpoint-->'+getendpoint);
        system.debug('password-->'+password+username);
        //Rest Call
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);        
        Blob headerValue = Blob.valueOf(username + ':' + password);        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);            
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody); 
        string returnMessage='';
        String errMessage='';
        try{
         	res = h.send(req);             
                caserecord.IsCaseSync__c=!system.isBatch();
            system.debug('caserecord.IsCaseSync__c--->'+caserecord.IsCaseSync__c);
            system.debug('--->'+res.getBody());
            system.debug('--->'+res.getStatusCode());
            if (res.getStatusCode() == 200  && res.getBody() != null && res.getBody() != '') {
                map<string,object> responceMap=(map<String,object>)JSON.deserializeUntyped(
                res.getBody()
                );
               map<string,object> actResponceMap=(map<String,object>)JSON.deserializeUntyped(
                JSON.serialize(responceMap.get('Create__CompIntfc__LC_SFCASE_CIResponse'))
                );
             
               map<string,object> detailResponceMap=(map<String,object>)JSON.deserializeUntyped(
                JSON.serialize(actResponceMap.get('detail'))
                );
                map<string,object> sFCIResponceMap=(map<String,object>)JSON.deserializeUntyped(
                JSON.serialize(detailResponceMap.get('LC_SFCASE_CI'))
                );
                string LC_SFCASE_ID = String.valueOf(sFCIResponceMap.get('LC_SFCASE_ID'));
                string BUSINESS_UNIT = String.valueOf(sFCIResponceMap.get('BUSINESS_UNIT'));
                system.debug('LC_SFCASE_ID---->'+LC_SFCASE_ID);
                system.debug('BUSINESS_UNIT---->'+BUSINESS_UNIT);
                system.debug('getendpoint---->'+getendpoint);
                getendpoint = getendpoint+BUSINESS_UNIT+'/'+LC_SFCASE_ID;
                system.debug('getendpoint---->'+getendpoint);
                HttpRequest errorreq = new HttpRequest();
                HttpResponse errorres = new HttpResponse();
                Http eh = new Http();
                errorreq.setEndpoint(getendpoint);
                errorreq.setMethod('GET');
                errorreq.setTimeout(120000);        
                Blob errorheaderValue = Blob.valueOf(username + ':' + password);        
                String errorauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(errorheaderValue);
                errorreq.setHeader('Authorization', errorauthorizationHeader);            
                errorreq.setHeader('Accept', 'application/json');
                errorreq.setHeader('Content-Type', 'application/json');
               	errorres = eh.send(errorreq); 
                system.debug('---->'+errorres.getBody());
                map<string,object> errorResponceMap=(map<String,object>)JSON.deserializeUntyped(
                errorres.getBody()
                );
               map<string,object> errorGetResponceMap=(map<String,object>)JSON.deserializeUntyped(
                JSON.serialize(errorResponceMap.get('Get__CompIntfc__LC_SFCASE_CIResponse'))
                );
				String ErrorMessage = errorGetResponceMap.get('ERROR_MESSAGE').toString();
                if( String.isBlank(ErrorMessage) ){
                     returnMessage='Sucessfully sync with People soft CRM .';
                     caserecord.Syc_Status_message__c='Success!';
                      
                }else{
                returnMessage='Error:'+errorGetResponceMap.get('ERROR_MESSAGE').toString();
                caserecord.Syc_Status_message__c=returnMessage;
                }
                     	
            }
            else{
                    
                returnMessage=' Peoplesoft Integration Error:'+res.getBody();
                errMessage='Error: something went wrong connect with Admin team!';
                 caserecord.Syc_Status_message__c=errMessage; 
			               
                            }
        }
        catch(Exception ex){
            returnMessage= 'Error: something went wrong connect with Admin team!'+ex.getMessage()+'-line Number:'+ex.getLineNumber();
            caserecord.Syc_Status_message__c='Error:'+ex.getMessage();
        } 
       try{
            system.debug('SYNSTATUS-->'+caserecord);
           update caserecord; 
            }
        catch(Exception e){
            system.debug('Error while updating sync error on Case-->'+e.getMessage());
             } 
            
          return returnMessage; 
       
    }
}