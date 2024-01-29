/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Application Architect Salesforce [sridharn@wavelabs.com]
** Modified Date:  04.02.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-3000 CCPA - Access Data - Data Classification for Fields
** SFORCE-3001 CCPA - Access Data - Custom Web Service
** SFORCE-3002 CCPA - Access Data - Prepare a Sample JSON File
** SFORCE-3003 CCPA - Access Data - Query SFDC Fields
** SFORCE-3004 CCPA - Access Data - Encrypted the Queried SFDC Fields
** SFORCE-3005 CCPA - Access Data - Map specific field by record type
** SFORCE-3006 CCPA - Access Data - Generate JSON Files
** SFORCE-3004 CCPA - Access Data - Decrypt Files When US Platform Pulling Them
** SFORCE-3008 CCPA - Access Data - Need a Batch job to asynchronous Prepare Access Data Files
** SFORCE-3009 CCPA - Access Data - Secure Files so only Modify All and View All Data can see
** _______________________________________________________________________________
*/
@RestResource(urlMapping='/retrieveCCPADataAccessFile')
global with sharing class RetrieveCCPADataAccessFile {
static boolean errorFlag{get;set;}
static String errorMessage{get;set;}
static String attachmentNum{get;set;}
/*
    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account account = [SELECT Id FROM Account WHERE Id = :accountId];
        delete account;
    }
  */
  
  
  @HttpPost
    global static void doPost(String privacyRequestId,
        String attachmentNumber) {
 
        //Map<String,String> response=null;
        String response=null;
        attachmentNum=attachmentNumber;
      RestContext.response.addHeader('Content-Type', 'application/json'); 
        List<Process_Security_Settings__mdt>  pssList= new List<Process_Security_Settings__mdt>([SELECT Description__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName,AES_KEY__c,Initialization_Vector__c,Switch__c FROM Process_Security_Settings__mdt where Process_Name__c in ('CCPA Access Data')]);
     Map<String,Process_Security_Settings__mdt> pssListMap=new Map<String,Process_Security_Settings__mdt>();
     for(Process_Security_Settings__mdt pssStr:pssList)
     {
         pssListMap.put(pssStr.Process_Name__c,pssStr);
     }
Blob iVector = Blob.valueOf(pssListMap.get('CCPA Access Data').Initialization_Vector__c);
String ccpaAccessDataAESKey=pssListMap.get('CCPA Access Data').AES_KEY__c;

Blob key=EncodingUtil.base64Decode(ccpaAccessDataAESKey);
  List<Privacy_Request__c> prList=new List<Privacy_Request__c>([select id,Name,No_Of_Files_Retrieved__c from Privacy_Request__c where id=:privacyRequestId and (Request_Status__c='Queued - Remote Platform' OR Request_Status__c='Retrying - Remote Platform')]);
      try{  
       if(!prList.isEmpty() && Integer.valueOf(attachmentNum)> 0 && prList[0].No_Of_Files_Retrieved__c>0 && Integer.valueOf(attachmentNum) <= prList[0].No_Of_Files_Retrieved__c)
       {
           List<ContentDocumentLink> cdlList=new List<ContentDocumentLink>([select id,contentDocumentId from ContentDocumentLink where LinkedEntityId=:privacyRequestId]);
           
           if(!cdlList.isEmpty())
           {
               Set<Id> cdSet=new Set<Id>();
               for(ContentDocumentLink cdlObj:cdlList)
               {
                   cdSet.add(cdlObj.contentDocumentId);
               }
               String fileTitle=attachmentNumber+'_%';
               List<ContentVersion> contentVersionList=new List<ContentVersion>([SELECT ContentBodyId,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,FileExtension,FileType,Id,NetworkId,Origin,OwnerId,PathOnClient,SharingOption,SharingPrivacy,Title,VersionData,VersionNumber FROM ContentVersion WHERE contentDocumentId=:cdSet and Title like :fileTitle]);
               
            //List<ContentVersion> contentVersion=new List<ContentVersion>([SELECT ContentBodyId,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,FileExtension,FileType,Id,NetworkId,Origin,OwnerId,PathOnClient,SharingOption,SharingPrivacy,Title,VersionData,VersionNumber FROM ContentVersion WHERE contentDocumentId=:cdlList[cdlList.size()-1].contentDocumentId]);
                Blob encryptedData = contentVersionList[0].VersionData;

              if(pssListMap.get('CCPA Access Data').Switch__c=='On')
              {
                Blob decrypted = Crypto.decrypt('AES128', key, iVector, encryptedData);
                JSON.deserialize(decrypted.toString(),Map<String,Map<String,Map<String,String>>>.class);
                String decryptedString = '{"'+contentVersionList[0].Title+'":'+decrypted.toString()+'}'; 
                response = decryptedString;  
                if(CareDotComUtil.runningInASandbox()) System.debug('Encryption On Json Response====>:'+ response);

              }
              else
              {
                  //response=new Map<String,String>{'{ "'+contentVersionList[0].Title+'"'=>encryptedData.toString()+'}'};  
                  JSON.deserialize(encryptedData.toString(),Map<String,Map<String,Map<String,String>>>.class);
                  response = '{"'+contentVersionList[0].Title+'":'+encryptedData.toString()+'}'; 
                  if(CareDotComUtil.runningInASandbox()) System.debug('Encryption Off Json Response====>:'+ response);
              }
                
                //Map<String,String> jsonMap=new Map<String,String>{'#18.0 PR-2134 2020-04-09 04:46:51'=>'{"Cases" : {"500540000066C9cAAE":{"Case Number":"2020-03-31-15462973","Description":"null","Case Origin":"Web","Date/Time Closed":"null","Subject":"null","Date/Time Opened":"2020-03-31 19:23:43"},"50054000005eGqYAAU":{"Case Number":"2020-03-24-15462972","Description":"Test Description","Case Origin":"Web","Date/Time Closed":"2020-03-24 15:46:47","Subject":"Test Subjejct","Date/Time Opened":"2020-03-24 15:46:25"}},"Survey Feedback" : {"a1754000001xxkDAAQ":{"Explain why you chose the rating above":"null","User Rating - Understanding":"Somewhat Agree","User Rating - Expectations":"Somewhat Disagree","How satisfied with enrollment process?":"null","User Rating - Clear Explanation":"Somewhat Agree","CSAT Rating":"Extremely Satisfied","How satisfied with service by BUC reps?":"null","Adequate number of providers?":"null","Provider Utilization":"null","Did your caregiver arrive on time?":"null","Provider Rating 3":"Dissatisfied","Recommend BUC benefit to a colleague?":"null","Would you like our team to contact you?":"null","Care Specialist":"Care Specialist","Suggestions to enhance our service":"null","NPS Score":"1","Provider Utilization - Other":"null","Provider Rating 1":"Neutral","Satisfaction Rating":"null","Number of Provider Options given":"null","How satisfied with drop off/ pick up?":"null","How satisfied with the quality of care?":"null","User Rating - Knowledge":"Somewhat Agree","Work with Suggested Partner":"Yes","How Did You Hear About Benefit?":"How Did You Hear About Benefit?","Provider Rating 2":"Neutral","Satisfaction Comments":"null","Event":"null","Productive work time saved using BUC?":"null","Did caregiver follow your instructions?":"null","Provider Comments":"Provider Comments","Testimonial":"No","Text Translation":"Provider 1","Provider 1":"Provider 1","Provider 2":"Provider 2","Provider 3":"Provider 3","Rating comments":"sfks;lddkfl;sk","Provider Utilization Reasons":"null","Case Number":"2020-03-24-15462972"}},"Social Post" : {"0ST540000004G4jGAE":{"Message":"Test Social Post Message","Message Type":"null","Posted Date":"2020-03-31 19:33:00","Case Number":"2020-03-31-15462973"}},"Live Chat Transcript" : {"57054000000M3JoAAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 20:55:33","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 20:55:45 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 12s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi How are you doing( 1m 2s ) Visitor: Hey I need some care services @ my home , can you please assist.","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"},"57054000000M3K3AAK":{"Network":"Reliance Jio INFOCOMM","Request Time":"2020-03-31 21:02:46","Location":"Gurgaon, HR, India","Body":"Chat Started: Tuesday, March 31, 2020, 21:03:01 (+0000)Chat Origin: US: SafetyAgent Sridhar N( 15s ) Sridhar N: Hi, my name is Sridhar.  I am happy to help you today!( 28s ) Sridhar N: Hi, How are you doing( 58s ) Visitor: This is kimmie from Boston, need help in getting Care Services","Visitor IP Address":"49.37.131.58","Case Number":"2020-03-24-15462972"}},"Email Message" : {"02s540000018XSKAA2":{"To Address":"sridhar.neeli@care.com","From Name":"Sridhar Neeli","Message Date":"2020-03-31 19:39:37","Subject":"Test ccpa access data","Text Body":"Test ccpa access data ref:_00D5421UP._500545eGqY:ref","CC Address":"null","From Address":"sridhar.neeli@care.com","Case Number":"2020-03-24-15462972"}}}'};
       //return jsonMap;
       
       RestContext.response.responseBody = Blob.valueOf(response);
               
           }
       }
       else if(prList.isEmpty() || (!prList.isEmpty() && (prList[0].No_Of_Files_Retrieved__c==0 || Integer.valueOf(attachmentNum)<=0 || Integer.valueOf(attachmentNum) > prList[0].No_Of_Files_Retrieved__c)))
       {
           errorFlag=true;
           errorMessage='Privacy Request Exists =>:'+String.valueOf(!prList.isEmpty())+'  Number Of Files Available are =>:'+(prList.isEmpty()?Integer.valueOf('0'):Integer.valueOf(prList[0].No_Of_Files_Retrieved__c)) +' and tried with invalid attachment number =>:'+attachmentNum;
               System.debug('errorMessage ============>:'+errorMessage);
               RestContext.response.responseBody = Blob.valueOf(errorMessage);
               RestContext.response.statusCode=500;
               
       }
         
//return response;
  }
            catch(Exception e)
            {
                if(CareDotComUtil.runningInASandbox()) System.debug('Error Cause ===>:'+e.getCause());
                if(CareDotComUtil.runningInASandbox()) System.debug('Error LineNumber ===>:'+e.getLineNumber());
                if(CareDotComUtil.runningInASandbox()) System.debug('Error Message ===>:'+e.getMessage());
                if(CareDotComUtil.runningInASandbox()) System.debug('Error Stack Trace ===>:'+e.getStackTraceString());
                if(CareDotComUtil.runningInASandbox()) System.debug('Error Type ===>:'+e.getTypeName());
                //if(CareDotComUtil.runningInASandbox()) System.debug('Error Cause ===>:'+e.initCause());
                sendAdminEmail('Unable to Process Privacy Request ==>:'+prList[0].Name+' An Exception Has Occured in RetrieveCCPADataAccessFile Process ==>:'
                +'\n Error Cause ===>:'+e.getCause()
                +'\n Error Message ===>:'+e.getMessage()
                +'\n Error Stack Trace ===>:'+e.getStackTraceString()
                +'\n Error Type ===>:'+e.getTypeName()
                );
               RestContext.response.responseBody = Blob.valueOf('{"Error - Salesforce Platform":"'+e.getMessage()+'"}');
               RestContext.response.statusCode=500;
            }    
    }
    public static List<String> userEmailList;
    public static void sendAdminEmail(String emailBody)
    {
        userEmailList=new List<String>();
        List<SystemsEmailNotificationSettings__mdt> sensList=new List<SystemsEmailNotificationSettings__mdt>([SELECT DeveloperName,Email_Notification_List__c,Id,Label,Language,MasterLabel,NamespacePrefix,Process_Name__c,QualifiedApiName FROM SystemsEmailNotificationSettings__mdt where Process_Name__c='CCPA Access Data']);
        if(!sensList.isEmpty() && sensList[0].Email_Notification_List__c!=null)
        {
            List<String> userEmailList=new List<String>(sensList[0].Email_Notification_List__c.split(';'));

            if(CareDotComUtil.runningInASandbox()) System.debug('userEmailList==>:'+userEmailList);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(userEmailList);
            mail.setSubject('CCPA Data Access  Error @ RetrieveCCPADataAccessFile class');
            mail.setBccSender(false);
            mail.setPlainTextBody(emailBody);
            if (Limits.getEmailInvocations()<=Limits.getLimitEmailInvocations()) 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}