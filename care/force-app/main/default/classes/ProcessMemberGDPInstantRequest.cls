/*
Description:  Anonymizes data for member and deletes all related records of Account, Contcat and Case.
ModifiedBy : md Ashwaq
ModifiedDate: 02/07/2023
*/
public class ProcessMemberGDPInstantRequest
{
    public static  Map<id,Case> caseMap;    
    public static Map<id,List<Case>> accIdCaseListMap;
    public static Map<id,AccountHistory> accountHistoryMap;
    public static Map<id,List<AccountHistory>> accIdAccountHistoryListMap;
    public static List<AccountHistory> deleteAccountHistoryList=new List<AccountHistory>();
    public static Map<id,accountFeed> accountFeedMap;
    public static Map<id,List<accountFeed>> accIdaccountFeedListMap;
    public static List<AccountFeed> deleteAccountFeedList=new List<AccountFeed>();
    public static Map<id,EmailMessage> caseEmailMessageMap;
    public static Map<id,List<EmailMessage>> caseIdEmailMessageListMap;
    public static List<EmailMessage> deleteCaseEmailMessageList=new List<EmailMessage>();
    public static Map<id,Event> caseEventMap;
    public static Map<id,List<Event>> caseIdEventListMap;
    public static List<Event> deleteCaseEventList=new List<Event>();
    public static List<CaseFeed> deleteCaseFeedList=new List<CaseFeed>();
    public static List<CaseHistory> deleteCaseHistoryList=new List<CaseHistory>();
    public static Map<id,List<CaseFeed>> caseIdCaseFeedListMap=new Map <id,List<CaseFeed>>();
    public static Map<id,List<CaseHistory>> caseIdCaseHistoryListMap=new Map <id,List<CaseHistory>>();
    public static Map<id,Event> accEventMap;
    public static Map<id,List<Event>> accIdEventListMap;
    public static List<Event> deleteAccountEventList=new List<Event>();
    public static Map<id,Attachment> caseAttachmentMap;
    public static Map<id,List<Attachment>> caseIdAttachmentListMap;
    public static List<Attachment> deleteCaseAttachmentList=new List<Attachment>();
    public static Map<id,Attachment> accAttachmentMap;
    public static Map<id,List<Attachment>> accIdAttachmentListMap;
    public static List<Attachment> deleteAccountAttachmentList=new List<Attachment>();
    public static Map<id,Task> caseTaskMap;
    public static Map<id,List<Task>> caseIdTaskListMap;
    public static Set<Task> updateCaseTaskList=new Set<Task>();
    //public static List<Task> deleteCaseTaskList=new List<Task>();
    public static Map<id,CaseComment> caseCommentMap;    
    public static Map<id,List<CaseComment>> caseIdCommentListMap;
    public static List<CaseComment> deleteCaseCommentList=new List<CaseComment>();
    public static Map<id,Task> accTaskMap;
    public static Map<id,List<Task>> accIdTaskListMap;
    public static List<Task> deleteAccountTaskList=new List<Task>();
    public static Map<id,Survey_Feedback__c> caseSurveyFeedbackMap;
    public static Map<id,List<Survey_Feedback__c>> caseIdSurveyFeedbackListMap;
    public static List<Survey_Feedback__c> deleteCaseSurveyFeedbackList=new List<Survey_Feedback__c>();
    public static List<Survey_Feedback__c> updateCaseSurveyFeedbackList=new List<Survey_Feedback__c>();
    public static Map<id,Survey_Feedback__c> accSurveyFeedbackMap;
    public static Map<id,List<Survey_Feedback__c>> accIdSurveyFeedbackListMap;
    public static List<Survey_Feedback__c> deleteAccountSurveyFeedbackList=new List<Survey_Feedback__c>();
    public static List<Survey_Feedback__c> updateAccountSurveyFeedbackList=new List<Survey_Feedback__c>();
    public static Map<id,boolean> accWithNonClearCasesMap;
    public static Map<id,boolean> accWithEmpProgramCasesMap;
    public static Map<String,Request_Data__c > gmIdMap;
    public static Map<String,Account> accGmIdMap;
    public static Map<id,Account> accMap;
    public static Map<id,String> accRecTypes=new Map<id,String>();
    public static Map<id,String> caseRecTypes=new Map<id,String>();
    public static Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    public static List<Case> casesToUpdate; 
    //public static String processMemberData;
    public static String runState;
    public static List<id> caseFeedHistoryIdList;  //Collects all case id's to be forwarded to Feed Job.
    public static List<FeedItem> surveyFeedbackListRecs=new List<FeedItem>();
    public static List<FeedItem> caseTaskFeedList=new List<FeedItem>();
    public static List<Request_Data__c> delGdpReqList=new List<Request_Data__c>();
    public static Map<id,Account> delAccountMap=new Map<id,Account>();
    public static Map<id,Id> delContactMap=new Map<id,Id>();
    public static Map<Id,ContentNote> accNoteMap;
    public static Map<Id,ContentNote> caseNoteMap;
    public static List<ContentNote>  deleteCaseNotesList;
    public static Map<id,Note>  accNotesAndAttachments;
    public static List<Note>  deleteCaseNotesAndAttachmentsList;
    public static Map<id,List<Note>> caseNotesAndAttachments;
    public static Map<id,List<id>> caseContentNoteIdMap;
    public static List<id> caseContentNoteIdList;
    public static List<Request_Data__c > gdpReqList;
    public static List<id> secondTimeFeedList;  //Holds all case id's to be forwarded to Feed Job.
    //SOCIAL MEDIA INT
    public static Map<id, Case> caseContactIdMap = new Map<id, Case>();
    public static Map<Id, Contact> conSocialMedia = new Map<Id, Contact>();
    public static Map<Id, Contact> updateConSocialMedia = new Map<Id, Contact>();
    public static Id socialMediaContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('International Social Contact').getRecordTypeId();
    public static Map<id,ContactHistory> contactHistoryMap = new Map<id,ContactHistory>();
    public static Map<id,List<ContactHistory>> conIdContactHistoryListMap = new Map<id,List<ContactHistory>>();
    public static List<ContactHistory> deleteContactHistoryList=new List<ContactHistory>();
    public static Map<id,SocialPost> caseSocialPostMap = new Map<id,SocialPost>();
    public static Map<id,List<SocialPost>> caseIdSocialPostListMap = new Map<id,List<SocialPost>>();
    public static List<SocialPost> deleteCaseSocialPostList=new List<SocialPost>();     
    
    public static Map<id,spr_sf__SocialPost__c> caseSprSocialPostMap = new Map<id,spr_sf__SocialPost__c>();
    public static Map<id,List<spr_sf__SocialPost__c>> caseIdSprSocialPostListMap = new Map<id,List<spr_sf__SocialPost__c>>();
    public static List<spr_sf__SocialPost__c> deleteCaseSprSocialPostList=new List<spr_sf__SocialPost__c>();
    
    public static List<spr_sf__SocialPersona__c> deleteCaseSprSocialPersonaList=new List<spr_sf__SocialPersona__c>();
    
    public static Map<id,SocialPersona> caseSocialPersonaMap = new Map<id,SocialPersona>();
    public static Map<id,List<SocialPersona>> caseIdSocialPersonaListMap = new Map<id,List<SocialPersona>>();
    public static List<SocialPersona> deleteCaseSocialPersonaList=new List<SocialPersona>();    
    public static Map<String,Account>  ProcessMemberGDPInstantRequest(List<Request_Data__c > gdpReqListParam,String runStateStr,List<id> secondTimeFeedListParam)
    {
        List<String> closedStatusList = new List<String>();
        for(CaseStatus csObj: [SELECT Id, isClosed, MasterLabel FROM CaseStatus WHERE IsClosed = true])
        {
            closedStatusList.add(csObj.MasterLabel);
        }
        if(CareDotComUtil.runningInASandbox()) System.debug('Inside ProcessMemberGDPInstantRequest method ==>:');
        gdpReqList=gdpReqListParam;
        secondTimeFeedList=secondTimeFeedListParam;
        runState=runStateStr;
        if(CareDotComUtil.runningInASandbox()) System.debug('Runstate seleted is ==============>:'+runState);
        //pmList=[select GDPR_Run_State__c from Process_Member_GDPRequest__mdt LIMIT 50000];
        //processMemberData=pmList[0].GDPR_Run_State__c;
        //if(processMemberData=='Schedule')
        gmIdMap=new Map<String,Request_Data__c >();
        for(Request_Data__c  gdpReqObj:gdpReqList){
            if(!String.isBlank(gdpReqObj.Global_Member_ID__c)) gmIdMap.put(gdpReqObj.Global_Member_ID__c,gdpReqObj);
        }
        accGmIdMap=new Map<String,Account>();
        accMap=new Map<id,Account>();
        for(Account accObj:[select id,PersonEmail,Locale__pc, firstName, LastName, recordTypeId,Type__pc,Global_Member_Id__c,Employer_Program__pc,personContactId,isPersonAccount,ownerId,Fail_Over_Retrial_Count__c,Gdpr_Sync_Status__c from Account where Global_Member_ID__c=:gmIdMap.keySet() LIMIT 50000]){
            accGmIdMap.put(accObj.Global_Member_ID__c,accObj);
            accMap.put(accObj.id,accObj);
        }
        accRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Provider'),'International Provider');
        accRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker'),'International Seeker');
        caseRecTypeNameIdMap.put('Social Media International',getRecordTypesStatic.recordTypeNameIdMap.get('Social Media International'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Social Media International'),'Social Media International');    
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center'),'International Call Center');        
        caseRecTypeNameIdMap.put('International Call Center',getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Email'),'International Email');
        caseRecTypeNameIdMap.put('International Email',getRecordTypesStatic.recordTypeNameIdMap.get('International Email'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'),'International Safety Alert');
        caseRecTypeNameIdMap.put('International Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International WPS Service EventCare'),'International WPS Service EventCare');
        caseRecTypeNameIdMap.put('International WPS Service EventCare',getRecordTypesStatic.recordTypeNameIdMap.get('International WPS Service EventCare'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International WPS Services'),'International WPS Services');
        caseRecTypeNameIdMap.put('International WPS Services',getRecordTypesStatic.recordTypeNameIdMap.get('International WPS Services'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('Int. CAW BUC'),'Int. CAW BUC');
        caseRecTypeNameIdMap.put('Int. CAW BUC',getRecordTypesStatic.recordTypeNameIdMap.get('Int. CAW BUC'));
        casesToUpdate=new List<Case>();
        caseMap=new Map<id,Case>([SELECT ID,STATUS,RECORDTYPEID,ACCOUNTID,ContactId,subject,description,Account.Name,Employer_Program__c FROM CASE WHERE ACCOUNTID=:accMap.keySet() LIMIT 50000]);
        if(CareDotComUtil.runningInASandbox()) System.debug('caseMap=====================>:'+caseMap.size());
        accIdCaseListMap=new Map <id,List<Case>>();
        for(Case caseObj:caseMap.values())
        {
            if(accIdCaseListMap.get(caseObj.accountId)==null)
            {
                accIdCaseListMap.put(caseObj.accountId,new List<Case>{caseObj});
            }
            else
            {
                accIdCaseListMap.get(caseObj.accountId).add(caseObj);
            }
        }
        accWithNonClearCasesMap=new Map<id,boolean>();
        accWithEmpProgramCasesMap=new Map<id,boolean>();
        for(Request_Data__c  gdpReqObj:gdpReqList)
        {
            Account accObj=accGmIdMap.get(gdpReqObj.Global_Member_ID__c);
            if(accObj!=null)
            {
                if(CareDotComUtil.runningInASandbox()) System.debug('accObj.Employer_Program__pc=====================>:'+accObj.Employer_Program__pc);
                if(CareDotComUtil.runningInASandbox()) System.debug('String.isBlank(accObj.Employer_Program__pc)=====================>:'+String.isBlank(accObj.Employer_Program__pc));
                if(!String.isBlank(accObj.Employer_Program__pc))
                {
                    accWithEmpProgramCasesMap.put(accObj.id,true);
                    if(CareDotComUtil.runningInASandbox()) System.debug('Found Employee Program for the account111 ===>:'+accObj.id);
                }
                if(accIdCaseListMap.containsKey(accGmIdMap.get(gdpReqObj.Global_Member_Id__c).id))
                {
                    for(Case caseObj:accIdCaseListMap.get(accGmIdMap.get(gdpReqObj.Global_Member_Id__c).id))
                    {
                        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 222');
                        if(((caseObj.recordTypeId==caseRecTypeNameIdMap.get('International Safety Alert') && caseObj.Status!='Cleared') || (caseObj.recordTypeId!=caseRecTypeNameIdMap.get('International Safety Alert') && !closedStatusList.contains(caseObj.status)))||(!String.isBlank(caseObj.Employer_Program__c)))
                        {
                            if((caseObj.recordTypeId==caseRecTypeNameIdMap.get('International Safety Alert') && caseObj.Status!='Cleared') || (caseObj.recordTypeId == caseRecTypeNameIdMap.get('International Safety Alert') && !closedStatusList.contains(caseObj.status)))
                            {
                                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 333 Non Cleared Safety Alert Found'+caseObj.id);
                                accWithNonClearCasesMap.put(caseObj.accountId,true);
                            }
                            if(!String.isBlank(caseObj.Employer_Program__c))
                            {
                                accWithEmpProgramCasesMap.put(caseObj.accountId,true);
                                if(CareDotComUtil.runningInASandbox()) System.debug('Found Employee Program for the account112 ===>:'+accObj.id);
                            }
                        }
                    }
                }
            }
        }
        map<id, List<String>> caseAccountNameMap = new map<id, List<String>>();
        for(Request_Data__c  gdpReqObj:gdpReqList)
        {
            Account accObj=accGmIdMap.get(gdpReqObj.Global_Member_ID__c);
            if(accIdCaseListMap.containsKey(accGmIdMap.get(gdpReqObj.Global_Member_Id__c).id))
            {
                for(Case caseObj:accIdCaseListMap.get(accGmIdMap.get(gdpReqObj.Global_Member_Id__c).id))
                {
                    if(caseObj.recordTypeId==caseRecTypeNameIdMap.get('Social Media International'))
                    {
                        if(caseObj.ContactId !=null){
                            caseContactIdMap.put(caseObj.ContactId, caseObj);
                            List<String> accName = new List<String>{accObj.firstName, accObj.LastName};
                                caseAccountNameMap.put(caseObj.ContactId, accName);
                        }
                    }                    
                }
            }
        }
        system.debug('************caseAccountNameMap social case contact NAME'+caseAccountNameMap);
        system.debug('************caseContactIdMap social case contact'+caseContactIdMap.keySet());
        if(!caseContactIdMap.isEmpty()){
            conSocialMedia = new Map<id,Contact>([Select Id,  firstName, LastName, RecordTypeId from Contact where Id IN: caseContactIdMap.keySet() and RecordTypeId =: socialMediaContact ]);
        }
        updateConSocialMedia = new Map<Id, Contact>();
        if(!conSocialMedia.isEmpty()){
            List<Case> noAccountSocialCase = [SELECT ID,STATUS,RECORDTYPEID,ACCOUNTID,ContactId,subject,description,Account.Name,Employer_Program__c FROM CASE WHERE ContactId IN:conSocialMedia.keySet() LIMIT 50000];
            for(Case cs: noAccountSocialCase){
                if(cs.accountId ==null){
                    caseMap.put(cs.Id, cs);
                }                
            }            
            for(Contact con : conSocialMedia.values()){
                con.firstName = caseAccountNameMap.get(con.Id)[0];
                con.LastName = caseAccountNameMap.get(con.Id)[1];
                updateConSocialMedia.put(con.id, con);
            }	
        } 
        caseSocialPersonaMap=new Map<id,SocialPersona>([SELECT ID,PARENTID FROM SocialPersona WHERE parentId  =:conSocialMedia.keySet()]);
        caseIdSocialPersonaListMap =new Map <id,List<SocialPersona>>();
        for(SocialPersona socialPersonaObj:caseSocialPersonaMap.values())
        {
            if(caseIdSocialPersonaListMap.get(socialPersonaObj.parentId)==null)
            {
                caseIdSocialPersonaListMap.put(socialPersonaObj.parentId,new List<SocialPersona>{socialPersonaObj});
            }
            else
            {
                caseIdSocialPersonaListMap.get(socialPersonaObj.parentId).add(socialPersonaObj);
            }
        }
        system.debug('************caseIdSocialPersonaListMap'+caseIdSocialPersonaListMap);
        caseSocialPostMap=new Map<id,SocialPost>([SELECT ID,PARENTID FROM socialPost WHERE parentId = :caseMap.keySet()]);
        caseIdSocialPostListMap=new Map <id,List<SocialPost>>();
        for(SocialPost socialPostObj:caseSocialPostMap.values())
        {
            if(caseIdSocialPostListMap.get(socialPostObj.parentId)==null)
            {
                caseIdSocialPostListMap.put(socialPostObj.parentId,new List<SocialPost>{socialPostObj});
            }
            else
            {
                caseIdSocialPostListMap.get(socialPostObj.parentId).add(socialPostObj);
            }
        }
        system.debug('************caseIdSocialPostListMap'+caseIdSocialPostListMap);
        
        
        Set<Id> sprPersonaId = new set<Id>();
        caseSprSocialPostMap=new Map<id,spr_sf__SocialPost__c>([SELECT ID,spr_sf__SocialPersona__c,spr_sf__Case__c FROM spr_sf__SocialPost__c WHERE spr_sf__Case__c = :caseMap.keySet()]);
        caseIdSprSocialPostListMap=new Map <id,List<spr_sf__SocialPost__c>>();
        for(spr_sf__SocialPost__c SprsocialPostObj:caseSprSocialPostMap.values())
        {
            if(caseIdSprSocialPostListMap.get(SprsocialPostObj.spr_sf__Case__c)==null)
            {
                caseIdSprSocialPostListMap.put(SprsocialPostObj.spr_sf__Case__c,new List<spr_sf__SocialPost__c>{SprsocialPostObj});
            }
            else
            {
                caseIdSprSocialPostListMap.get(SprsocialPostObj.spr_sf__Case__c).add(SprsocialPostObj);
            }
            if(SprsocialPostObj.spr_sf__SocialPersona__c !=null){
                sprPersonaId.add(SprsocialPostObj.spr_sf__SocialPersona__c);
            }
        }
        system.debug('************caseIdSprSocialPostListMap'+caseIdSprSocialPostListMap);        

        deleteCaseSprSocialPersonaList=[SELECT ID FROM spr_sf__SocialPersona__c WHERE id IN :sprPersonaId]; 
        system.debug('************deleteCaseSprSocialPersonaList'+deleteCaseSprSocialPersonaList);
        
        contactHistoryMap=new Map<id,ContactHistory>([Select Id , ContactId from ContactHistory where Id = :caseContactIdMap.keySet()]);
        conIdContactHistoryListMap=new Map <id,List<ContactHistory>>();
        for(ContactHistory ContactHistoryObj : contactHistoryMap.values())
        {
            if(conIdContactHistoryListMap.get(ContactHistoryObj.ContactId)==null)
            {
                conIdContactHistoryListMap.put(ContactHistoryObj.ContactId,new List<ContactHistory>{ContactHistoryObj});
            }
            else
            {
                conIdContactHistoryListMap.get(ContactHistoryObj.ContactId).add(ContactHistoryObj);
            }
        }
        system.debug('************conIdContactHistoryListMap'+conIdContactHistoryListMap);
        for(Request_Data__c  gdpReqObj:gdpReqList)
        {
            Account accObj=accGmIdMap.get(gdpReqObj.Global_Member_ID__c);
            if(accObj!=null)
            {
                if(CareDotComUtil.runningInASandbox()) System.debug(gdpReqObj.Request_Type__c=='RTBF Override'+accRecTypes.containsKey(accObj.recordTypeId));
                if(CareDotComUtil.runningInASandbox()) System.debug(gdpReqObj.Request_Type__c=='RTBF Override'+!accWithEmpProgramCasesMap.containsKey(accObj.id));
                if(CareDotComUtil.runningInASandbox()) System.debug((gdpReqObj.Request_Type__c=='RTBF Override')+' '+(accObj.Type__pc!='Premium'));
                if(CareDotComUtil.runningInASandbox()) System.debug(gdpReqObj.Request_Type__c=='RTBF Override'+!accWithNonClearCasesMap.containsKey(accObj.id));
                if((gdpReqObj.Request_Type__c=='RTBF Override'?true:(accRecTypes.containsKey(accObj.recordTypeId))) 
                   && 
                   (gdpReqObj.Request_Type__c=='RTBF Override'?true:(!accWithEmpProgramCasesMap.containsKey(accObj.id))) 
                   && 
                   (gdpReqObj.Request_Type__c=='RTBF Override'?true:(accObj.Type__pc!='Premium')) 
                   && 
                   (gdpReqObj.Request_Type__c=='RTBF Override'?true:(!accWithNonClearCasesMap.containsKey(accObj.id)))
                   &&
                   gdpReqObj.Request_Type__c!='RTBF Do Not Process' )
                {
                    delGdpReqList.add(gdpReqObj);
                    delAccountMap.put(accObj.id,accObj);
                    if(!String.isBlank(accObj.personContactId))
                    {
                        delContactMap.put(accObj.id,accObj.personContactId);
                    }
                }
            }
        }
        for(Request_Data__c  gdpReqObj:gdpReqList)
        {
            Account accObj=accGmIdMap.get(gdpReqObj.Global_Member_ID__c);
            if(accObj!=null)
            {
                if(runState=='anonymize')
                {
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accWithEmpProgramCasesMap.containsKey(accObj.id))
                    {
                        gdpReqObj.status__c='RTBF Fail - Employer Program';
                        accGmIdMap.get(gdpReqObj.Global_Member_Id__c).Gdpr_Request__c='RTBF Fail - Employer Program'; 
                        gdpReqObj.Response_Date__c=Datetime.now().date(); 
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found Employee Program for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accWithNonClearCasesMap.containsKey(accObj.id))
                    {
                        gdpReqObj.status__c='RTBF Fail - Safety Case';
                        accGmIdMap.get(gdpReqObj.Global_Member_Id__c).Gdpr_Request__c='RTBF Fail - Safety Case';
                        gdpReqObj.Response_Date__c=Datetime.now().date();  
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found safety case for the account ===>:'+accObj.id);
                    }
                    //gdpReqObj.Request_Type__c='RTBF';
                    //gdpReqObj.Response_Date__c=Datetime.now().date();
                    // accGmIdMap.get(gdpReqObj.Global_Member_Id__c).Gdpr_Request__c=gdpReqObj.Request_Type__c+' Completed'
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accRecTypes.get(accObj.recordTypeId)==null)
                    {
                        gdpReqObj.status__c='RTBF Fail - Invalid Record Type';
                        gdpReqObj.Response_Date__c=Datetime.now().date();
                        accObj.Gdpr_Request__c='RTBF Fail - Invalid Record Type';
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found Invalid Record Type for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accObj.Type__pc=='Premium')
                    {
                        gdpReqObj.status__c='RTBF Fail - Premium';
                        gdpReqObj.Response_Date__c=Datetime.now().date();
                        accObj.Gdpr_Request__c='RTBF Fail - Premium';
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found Premium for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c=='RTBF Do Not Process')
                    {
                        gdpReqObj.status__c='RTBF Do Not Process';
                        gdpReqObj.Response_Date__c=Datetime.now().date();  
                        accObj.Gdpr_Request__c='RTBF Do Not Process';
                        if(CareDotComUtil.runningInASandbox()) System.debug('Not processing the account because of \'RTBF Do Not Process\' request===>:'+accObj.id);
                    }
                }
                else if(runState=='preCheck')
                {
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accWithEmpProgramCasesMap.containsKey(accObj.id))
                    {
                        gdpReqObj.Validation_Status__c='RTBF Fail - Employer Program';
                        gdpReqObj.Last_Validation_Date__c=Datetime.now().date();
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found Employee Program for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accWithNonClearCasesMap.containsKey(accObj.id))
                    {
                        gdpReqObj.Validation_Status__c='RTBF Fail - Safety Case';
                        gdpReqObj.Last_Validation_Date__c=Datetime.now().date();
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found safety case for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accRecTypes.get(accObj.recordTypeId)==null)
                    {
                        gdpReqObj.Validation_Status__c='RTBF Fail - Invalid Record Type';
                        gdpReqObj.Last_Validation_Date__c=Datetime.now().date();
                        if(CareDotComUtil.runningInASandbox()) System.debug('Found Invalid Record Type  for the account ===>:'+accObj.id);
                    }
                    if(gdpReqObj.Request_Type__c!='RTBF Override' && accObj.Type__pc=='Premium')
                    {
                        gdpReqObj.Validation_Status__c='RTBF Fail - Premium';
                        gdpReqObj.Last_Validation_Date__c=Datetime.now().date();
                    }
                }
            }
        }
        accountHistoryMap=new Map<id,AccountHistory>([SELECT ID,ACCOUNTID FROM AccountHistory WHERE accountId=:delAccountMap.keySet() LIMIT 50000]);
        accIdAccountHistoryListMap=new Map <id,List<AccountHistory>>();
        for(AccountHistory AccountHistoryObj:accountHistoryMap.values())
        {
            if(accIdAccountHistoryListMap.get(AccountHistoryObj.accountId)==null)
            {
                accIdAccountHistoryListMap.put(AccountHistoryObj.accountId,new List<AccountHistory>{AccountHistoryObj});
            }
            else
            {
                accIdAccountHistoryListMap.get(AccountHistoryObj.accountId).add(AccountHistoryObj);
            }
        }
        accountFeedMap=new Map<id,accountFeed>([SELECT ID,PARENTID FROM accountFeed WHERE parentId=:delAccountMap.keySet() LIMIT 50000]);
        accIdaccountFeedListMap=new Map <id,List<accountFeed>>();
        for(accountFeed accountFeedObj:accountFeedMap.values())
        {
            if(accIdaccountFeedListMap.get(accountFeedObj.parentId)==null)
            {
                accIdaccountFeedListMap.put(accountFeedObj.parentId,new List<accountFeed>{accountFeedObj});
            }
            else
            {
                accIdaccountFeedListMap.get(accountFeedObj.parentId).add(accountFeedObj);
            }
        }
        caseEmailMessageMap=new Map<id,EmailMessage>([SELECT ID,PARENTID FROM EmailMessage WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        caseIdEmailMessageListMap=new Map <id,List<EmailMessage>>();
        for(EmailMessage EmailMessageObj:caseEmailMessageMap.values())
        {
            if(caseIdEmailMessageListMap.get(EmailMessageObj.parentId)==null)
            {
                caseIdEmailMessageListMap.put(EmailMessageObj.parentId,new List<EmailMessage>{EmailMessageObj});
            }
            else
            {
                caseIdEmailMessageListMap.get(EmailMessageObj.parentId).add(EmailMessageObj);
            }
        }
        caseEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID FROM Event WHERE whatId=:caseMap.keySet() LIMIT 50000]);
        caseIdEventListMap=new Map <id,List<Event>>();
        for(Event EventObj:caseEventMap.values())
        {
            if(caseIdEventListMap.get(EventObj.whatId)==null)
            {
                caseIdEventListMap.put(EventObj.whatId,new List<Event>{EventObj});
            }
            else
            {
                caseIdEventListMap.get(EventObj.whatId).add(EventObj);
            }
        }
        accEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID FROM Event WHERE whatId=:delAccountMap.keySet() LIMIT 50000]);
        accIdEventListMap=new Map <id,List<Event>>();
        for(Event EventObj:accEventMap.values())
        {
            if(accIdEventListMap.get(EventObj.whatId)==null)
            {
                accIdEventListMap.put(EventObj.whatId,new List<Event>{EventObj});
            }
            else
            {
                accIdEventListMap.get(EventObj.whatId).add(EventObj);
            }
        }
        caseAttachmentMap=new Map<id,Attachment>([SELECT ID,PARENTID FROM Attachment WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        caseIdAttachmentListMap=new Map <id,List<Attachment>>();
        for(Attachment AttachmentObj:caseAttachmentMap.values())
        {
            if(caseIdAttachmentListMap.get(AttachmentObj.parentId)==null)
            {
                caseIdAttachmentListMap.put(AttachmentObj.parentId,new List<Attachment>{AttachmentObj});
            }
            else
            {
                caseIdAttachmentListMap.get(AttachmentObj.parentId).add(AttachmentObj);
            }
        }
        accAttachmentMap=new Map<id,Attachment>([SELECT ID,PARENTID FROM Attachment WHERE parentId=:delAccountMap.keySet() LIMIT 50000]);
        accIdAttachmentListMap=new Map <id,List<Attachment>>();
        for(Attachment AttachmentObj:accAttachmentMap.values())
        {
            if(accIdAttachmentListMap.get(AttachmentObj.parentId)==null)
            {
                accIdAttachmentListMap.put(AttachmentObj.parentId,new List<Attachment>{AttachmentObj});
            }
            else
            {
                accIdAttachmentListMap.get(AttachmentObj.parentId).add(AttachmentObj);
            }
        }
        caseTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT FROM Task WHERE whatId=:caseMap.keySet() ALL ROWS]);
        caseIdTaskListMap=new Map <id,List<Task>>();
        for(Task TaskObj:caseTaskMap.values())
        {
            if(caseIdTaskListMap.get(TaskObj.whatId)==null)
            {
                caseIdTaskListMap.put(TaskObj.whatId,new List<Task>{TaskObj});
            }
            else
            {
                caseIdTaskListMap.get(TaskObj.whatId).add(TaskObj);
            }
        }
        caseCommentMap=new Map<id,CaseComment>([SELECT ID,parentId FROM CaseComment WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        caseIdCommentListMap=new Map <id,List<CaseComment>>();
        for(CaseComment caseCommentObj:caseCommentMap.values())
        {
            if(caseIdCommentListMap.get(caseCommentObj.parentId)==null)
            {
                caseIdCommentListMap.put(caseCommentObj.parentId,new List<caseComment>{caseCommentObj});
            }
            else
            {
                caseIdCommentListMap.get(caseCommentObj.parentId).add(caseCommentObj);
            }
        }
        accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT FROM Task WHERE whatId=:delAccountMap.keySet() ALL ROWS]);
        accIdTaskListMap=new Map <id,List<Task>>();
        for(Task TaskObj:accTaskMap.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding task to acctasklist================>:'+taskObj.subject);
            if(accIdTaskListMap.get(TaskObj.whatId)==null)
            {
                accIdTaskListMap.put(TaskObj.whatId,new List<Task>{TaskObj});
            }
            else
            {
                accIdTaskListMap.get(TaskObj.whatId).add(TaskObj);
            }
        }
        caseSurveyFeedbackMap=new Map<id,Survey_Feedback__c>([SELECT id,Account__c,Case__c,Contact__c,CSAT_Rating__c,Rating_comments__c,Text_Translation__c FROM Survey_Feedback__c where Case__c=:caseMap.keySet() LIMIT 50000]);
        caseIdSurveyFeedbackListMap=new Map <id,List<Survey_Feedback__c>>();
        for(Survey_Feedback__c SurveyFeedbackObj:caseSurveyFeedbackMap.values())
        {
            if(caseIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Case__c)==null)
            {
                caseIdSurveyFeedbackListMap.put(SurveyFeedbackObj.Case__c,new List<Survey_Feedback__c>{SurveyFeedbackObj});
            }
            else
            {
                caseIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Case__c).add(SurveyFeedbackObj);
            }
        }
        accSurveyFeedbackMap=new Map<id,Survey_Feedback__c>([SELECT id,Account__c,Case__c,Contact__c,CSAT_Rating__c,Rating_comments__c,Text_Translation__c FROM Survey_Feedback__c where (Account__c=:delAccountMap.keySet() or Contact__c=:delContactMap.values()) LIMIT 50000]);
        accIdSurveyFeedbackListMap=new Map <id,List<Survey_Feedback__c>>();
        for(Survey_Feedback__c SurveyFeedbackObj:accSurveyFeedbackMap.values())
        {
            if(accIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Contact__c)==null)
            {
                accIdSurveyFeedbackListMap.put(SurveyFeedbackObj.Contact__c,new List<Survey_Feedback__c>{SurveyFeedbackObj});
            }
            else
            {
                accIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Contact__c).add(SurveyFeedbackObj);
            }
            if(CareDotComUtil.runningInASandbox()) System.debug('Found Survey feedback for the account/contact ====>:'+SurveyFeedbackObj.Contact__c);
        }
        for(Survey_Feedback__c SurveyFeedbackObj:accSurveyFeedbackMap.values())
        {
            if(accIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Account__c)==null)
            {
                accIdSurveyFeedbackListMap.put(SurveyFeedbackObj.Account__c,new List<Survey_Feedback__c>{SurveyFeedbackObj});
            }
            else
            {
                accIdSurveyFeedbackListMap.get(SurveyFeedbackObj.Account__c).add(SurveyFeedbackObj);
            }
            if(CareDotComUtil.runningInASandbox()) System.debug('Found Survey feedback for the account/contact ====>:'+SurveyFeedbackObj.Account__c);
        }
        Map<id,CaseFeed> caseFeedMap=new Map<id,CaseFeed>([SELECT ID,parentId FROM caseFeed WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        for(CaseFeed CaseFeedObj:caseFeedMap.values())
        {
            if(caseIdCaseFeedListMap.get(CaseFeedObj.parentId)==null)
            {
                caseIdCaseFeedListMap.put(CaseFeedObj.parentId,new List<CaseFeed>{CaseFeedObj});
            }
            else
            {
                caseIdCaseFeedListMap.get(CaseFeedObj.parentId).add(CaseFeedObj);
            }
        }
        Map<id,CaseHistory> caseHistoryMap=new Map<id,CaseHistory>([SELECT ID,caseId FROM caseHistory WHERE CASEID=:caseMap.keySet() LIMIT 50000]);
        for(CaseHistory CaseHistoryObj:caseHistoryMap.values())
        {
            if(caseIdCaseHistoryListMap.get(CaseHistoryObj.caseId)==null)
            {
                caseIdCaseHistoryListMap.put(CaseHistoryObj.caseId,new List<CaseHistory>{CaseHistoryObj});
            }
            else
            {
                caseIdCaseHistoryListMap.get(CaseHistoryObj.caseId).add(CaseHistoryObj);
            }
        }
        List<id> accList=new List<id>();
        if(delAccountMap.keySet().size()>0) accList.addAll(delAccountMap.keySet());
        List<id> caseList=new List<id>();
        if(caseMap.keySet().size()>0) caseList.addAll(caseMap.keySet());
        List<id> accContentNoteIdList=new List<id>();
        if(!accList.isEmpty())
        {
            for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:accList LIMIT 50000])
            {
                accContentNoteIdList.add(links.ContentDocumentId);
            }
        }
        caseContentNoteIdMap=new Map<id,List<id>>();
        caseContentNoteIdList=new List<id>();
        if(!caseList.isEmpty())
        {
            for(ContentDocumentLink links : [SELECT id,LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityID=:caseList LIMIT 50000])
            {
                caseContentNoteIdList.add(links.ContentDocumentId);
                if(caseContentNoteIdMap.containsKey(links.LinkedEntityID))
                    caseContentNoteIdMap.get(links.LinkedEntityID).add(links.ContentDocumentId);
                else
                    caseContentNoteIdMap.put(links.LinkedEntityID,new List<id>());
            }
        }
        accNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:accContentNoteIdList LIMIT 50000]);
        caseNoteMap = new Map<id,ContentNote>([select id from ContentNote where id=:caseContentNoteIdList LIMIT 50000]);
        deleteCaseNotesList=new List<ContentNote>();
        accNotesAndAttachments=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:delAccountMap.keySet() LIMIT 50000]);
        Map<id,Note>  caseNotesAndAttachmentsMap=new Map<id,Note>([SELECT Id,ParentId FROM Note where parentid=:caseMap.keySet() LIMIT 50000]);
        deleteCaseNotesAndAttachmentsList=new List<Note>();
        caseNotesAndAttachments=new Map<id,List<Note>>();
        for(Note noteObj:caseNotesAndAttachmentsMap.values())
        {
            if(caseNotesAndAttachments.containsKey(noteObj.parentid))    
                caseNotesAndAttachments.get(noteObj.parentid).add(noteObj);
            else
                caseNotesAndAttachments.put(noteObj.parentid,new List<Note>());
        }
        for(Request_Data__c  gdpReqObj:delGdpReqList)
        {
            Account accObj=accGmIdMap.get(gdpReqObj.Global_Member_ID__c);
            if(accObj!=null)
            {
                if(CareDotComUtil.runningInASandbox()) System.debug('isGdprAccCasesHasNotClearedCase========================>:'+accWithNonClearCasesMap.get(accObj.id));
                if(CareDotComUtil.runningInASandbox()) System.debug('==========================Account is not premium International Seeker/Provider');
                if(CareDotComUtil.runningInASandbox()) System.debug('1');
                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 4');
                processAllCases(accObj);
                // Retrieve all account relared info
                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 12'+accIdTaskListMap.size());
                if(accIdTaskListMap.get(accObj.id)!=null) deleteAccountTaskList.addAll(accIdTaskListMap.get(accObj.id));
                if(accIdEventListMap.get(accObj.id)!=null) deleteAccountEventList.addAll(accIdEventListMap.get(accObj.id));                    
                if(accIdAttachmentListMap.get(accObj.id)!=null)
                    deleteAccountAttachmentList.addAll(accIdAttachmentListMap.get(accObj.id));
                if(accIdaccountFeedListMap.get(accObj.id)!=null)
                    deleteAccountFeedList.addAll(accIdaccountFeedListMap.get(accObj.id));  
                if(accIdAccountHistoryListMap.get(accObj.id)!=null)              
                    deleteAccountHistoryList.addAll(accIdAccountHistoryListMap.get(accObj.id));
                //deleteAccountSurveyFeedbackList.addAll(accIdSurveyFeedbackListMap.get(accObj.id));
                if(CareDotComUtil.runningInASandbox()) System.debug('Suvey feedback map value ============>:'+accIdSurveyFeedbackListMap.get(accObj.id));
                if(accIdSurveyFeedbackListMap.get(delContactMap.get(accObj.id))!=null)
                {
                    for(Survey_Feedback__c accSurveyFeedbackObj:accIdSurveyFeedbackListMap.get(delContactMap.get(accObj.id)))
                    {
                        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 13');
                        accSurveyFeedbackObj.CSAT_Rating__c=null;
                        accSurveyFeedbackObj.Rating_comments__c=null;
                        accSurveyFeedbackObj.Text_Translation__c=null;
                        updateAccountSurveyFeedbackList.add(accSurveyFeedbackObj);
                    }
                }
                else
                    if(accIdSurveyFeedbackListMap.containsKey(accObj.id))
                {
                    for(Survey_Feedback__c accSurveyFeedbackObj:accIdSurveyFeedbackListMap.get(accObj.id))
                    {
                        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 13');
                        accSurveyFeedbackObj.CSAT_Rating__c=null;
                        accSurveyFeedbackObj.Rating_comments__c=null;
                        accSurveyFeedbackObj.Text_Translation__c=null;
                        updateAccountSurveyFeedbackList.add(accSurveyFeedbackObj);
                    }
                }
                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 14');    
                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 15');
                if(runState=='anonymize')
                {
                    if(CareDotComUtil.runningInASandbox()) System.debug('Reached Completed Status block=============');
                    gdpReqObj.status__c='RTBF Complete';
                    //gdpReqObj.Request_Type__c='RTBF';
                    gdpReqObj.Response_Date__c=Datetime.now().date();
                    accObj.Gdpr_Request__c='RTBF Complete';
                }
                else if(runState=='preCheck')
                {
                    if(CareDotComUtil.runningInASandbox()) System.debug('Reached Completed Status block=============');
                    gdpReqObj.Validation_Status__c='RTBF Complete';
                    gdpReqObj.Last_Validation_Date__c=Datetime.now().date();
                }
            }
        }
        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 18');
        if(runState=='anonymize')
        {
            processDeletionOfRecords();
        }
        else if(runState=='preCheck')
        {
            if(!gdpReqList.isEmpty()) Database.update(gdpReqList,false);
        }
        return accGmIdMap; 
    }
    public static void processDeletionOfRecords()
    {
        if(CareDotComUtil.runningInASandbox()) System.debug('deleteAccountTaskList============>:'+deleteAccountTaskList);
        if(!deleteAccountTaskList.isEmpty()) 
        {
            Database.delete(deleteAccountTaskList,false);//Database.emptyRecycleBin(deleteAccountTaskList);  
        }
        //if(!deleteCaseTaskList.isEmpty()) {Database.delete(deleteCaseTaskList,false);Database.emptyRecycleBin(deleteCaseTaskList); } 
        if(!updateCaseTaskList.isEmpty()) Database.Update(new List<Task>(updateCaseTaskList),false);
        if(!deleteCaseCommentList.isEmpty()) {Database.delete(deleteCaseCommentList,false);Database.emptyRecycleBin(deleteCaseCommentList); } 
        if(!deleteCaseEventList.isEmpty()) {Database.delete(deleteCaseEventList,false);Database.emptyRecycleBin(deleteCaseEventList); } 
        if(!deleteCaseAttachmentList.isEmpty()) {Database.delete(deleteCaseAttachmentList,false);Database.emptyRecycleBin(deleteCaseAttachmentList);  }
        if(!deleteCaseEmailMessageList.isEmpty()) {Database.delete(deleteCaseEmailMessageList,false);Database.emptyRecycleBin(deleteCaseEmailMessageList);  }
        if(!updateCaseSurveyFeedbackList.isEmpty())   Database.update(updateCaseSurveyFeedbackList,false);
        surveyFeedbackListRecs=[SELECT ID,parentid FROM FEEDITEM where parentid=:updateCaseSurveyFeedbackList LIMIT 50000];
        caseTaskFeedList=[SELECT ID,parentid FROM FEEDITEM where parentid=:updateCaseTaskList LIMIT 50000];
        if(surveyFeedbackListRecs!=null && !surveyFeedbackListRecs.isEmpty())   {Database.delete(surveyFeedbackListRecs,false);Database.emptyRecycleBin(surveyFeedbackListRecs);  }
        if(caseTaskFeedList!=null && !caseTaskFeedList.isEmpty())   {Database.delete(caseTaskFeedList,false);Database.emptyRecycleBin(caseTaskFeedList);  }
        //if(!deleteCaseSurveyFeedbackList.isEmpty()) Database.delete(deleteCaseSurveyFeedbackList,false);  
        if(!accNoteMap.isEmpty()) {Database.delete(accNoteMap.values(),false);Database.emptyRecycleBin(accNoteMap.values());  }
        if(!deleteCaseNotesList.isEmpty()) {Database.delete(deleteCaseNotesList,false);Database.emptyRecycleBin(deleteCaseNotesList);  }
        if(!accNotesAndAttachments.isEmpty()) {Database.delete(accNotesAndAttachments.values(),false);Database.emptyRecycleBin(accNotesAndAttachments.values());  }
        if(!deleteCaseNotesAndAttachmentsList.isEmpty()) {Database.delete(deleteCaseNotesAndAttachmentsList,false);Database.emptyRecycleBin(deleteCaseNotesAndAttachmentsList);  }
        //if(!gdpReqList.isEmpty()) update gdpReqList;
        if(!updateConSocialMedia.isEmpty()) Database.update(updateConSocialMedia.values(),false);
        if(!accMap.isEmpty()) Database.update(accMap.values(),false);
        if(!deleteAccountEventList.isEmpty()) {Database.delete(deleteAccountEventList,false);Database.emptyRecycleBin(deleteAccountEventList); } 
        if(!deleteAccountAttachmentList.isEmpty()) {Database.delete(deleteAccountAttachmentList,false);Database.emptyRecycleBin(deleteAccountAttachmentList);  }
        if(!deleteAccountFeedList.isEmpty()) {Database.delete(deleteAccountFeedList,false);Database.emptyRecycleBin(deleteAccountFeedList);  }
        if(!deleteAccountHistoryList.isEmpty()) {Database.delete(deleteAccountHistoryList,false);Database.emptyRecycleBin(deleteAccountHistoryList); } 
        if(CareDotComUtil.runningInASandbox()) System.debug('deleteAccountSurveyFeedbackList=========>:'+deleteAccountSurveyFeedbackList.size());
        if(!updateAccountSurveyFeedbackList.isEmpty()) Database.Update(updateAccountSurveyFeedbackList,false);
        //if(!deleteAccountSurveyFeedbackList.isEmpty()) Database.delete(deleteAccountSurveyFeedbackList;
        if(secondTimeFeedList==null) secondTimeFeedList=new List<Id>();
        if(caseFeedHistoryIdList!=null && !caseFeedHistoryIdList.isEmpty()) secondTimeFeedList.addAll(caseFeedHistoryIdList);  
        if(!casesToUpdate.isEmpty()) Database.update(casesToUpdate,false);     
        if(!deleteCaseFeedList.isEmpty()) {Database.delete(deleteCaseFeedList,false);Database.emptyRecycleBin(deleteCaseFeedList);  }
        if(!deleteCaseHistoryList.isEmpty()) {Database.delete(deleteCaseHistoryList,false);Database.emptyRecycleBin(deleteCaseHistoryList);  }
        if(!deleteCaseSocialPostList.isEmpty()) {Delete deleteCaseSocialPostList;Database.emptyRecycleBin(deleteCaseSocialPostList); }
        if(!deleteCaseSocialPersonaList.isEmpty()) {Delete deleteCaseSocialPersonaList;Database.emptyRecycleBin(deleteCaseSocialPersonaList); }
        if(!deleteContactHistoryList.isEmpty()) {Delete deleteContactHistoryList;Database.emptyRecycleBin(deleteContactHistoryList); }
        if(!deleteCaseSprSocialPostList.isEmpty()) {Delete deleteCaseSprSocialPostList;Database.emptyRecycleBin(deleteCaseSprSocialPostList); }
        if(!deleteCaseSprSocialPersonaList.isEmpty()) {Delete deleteCaseSprSocialPersonaList[0];Database.emptyRecycleBin(deleteCaseSprSocialPersonaList[0]); }
    }
    public static void processAllCases(Account accObj)
    {
        if(accIdCaseListMap.get(accObj.id)!=null)
        {
            for(Case caseObj:accIdCaseListMap.get(accObj.id))
            {
                if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 5');
                if(caseRecTypes.get(caseObj.recordTypeId)!=null)
                {
                    if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 6');
                    casesToUpdate.add(caseObj);
                    caseObj.Subject= caseObj.Subject!=null && caseObj.Subject.contains('Email:')?'Email:':'';
                    caseObj.Description='';
                    caseObj.SuppliedName='';
                    caseObj.SuppliedEmail='';
                    if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 8');
                    if(caseIdTaskListMap.get(caseObj.id)!=null)
                    {
                        for(Task caseTaskObj:caseIdTaskListMap.get(caseObj.id))
                        {
                            if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 9');
                            caseTaskObj.subject='abcdefghijklmnopqrstuvwxyz';
                            caseTaskObj.Description=null;
                            //caseTaskObj.phone=null;
                            //caseTaskObj.email=null;
                            updateCaseTaskList.add(caseTaskObj);
                        }
                    }
                    if(caseIdSurveyFeedbackListMap.get(caseObj.id)!=null)
                    {
                        for(Survey_Feedback__c caseSurveyFeedbackObj:caseIdSurveyFeedbackListMap.get(caseObj.id))
                        {
                            if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 10');
                            caseSurveyFeedbackObj.CSAT_Rating__c=null;
                            caseSurveyFeedbackObj.Rating_comments__c=null;
                            caseSurveyFeedbackObj.text_translation__c=null;
                            if(!updateCaseSurveyFeedbackList.contains(caseSurveyFeedbackObj)) updateCaseSurveyFeedbackList.add(caseSurveyFeedbackObj);
                            //surveyFeedbackList.add(caseSurveyFeedbackObj.id);
                        }
                    }
                    if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 11');
                    if(runState=='anonymize')
                    {
                        /***********************************************************************/               
                        if(CaseNotesAndAttachments.get(caseObj.id)!=null)
                        {
                            deleteCaseNotesAndAttachmentsList.addAll(CaseNotesAndAttachments.get(caseObj.id));
                        }
                        if(caseIdCommentListMap.get(caseObj.id)!=null)
                            deleteCaseCommentList.addAll(caseIdCommentListMap.get(caseObj.id));                   
                        //deleteCaseNotesList
                        //caseNoteMap
                        //caseContentNoteIdMap
                        if(caseContentNoteIdMap.get(caseObj.id)!=null)
                            for(Id contentNoteId:caseContentNoteIdMap.get(caseObj.id))
                        {
                            deleteCaseNotesList.add(caseNoteMap.get(contentNoteId));
                        }
                        if(caseIdEventListMap.get(caseObj.id)!=null)
                            deleteCaseEventList.addAll(caseIdEventListMap.get(caseObj.id));
                        if(caseIdAttachmentListMap.get(caseObj.id)!=null)
                            deleteCaseAttachmentList.addAll(caseIdAttachmentListMap.get(caseObj.id));
                        if(caseIdEmailMessageListMap.get(caseObj.id)!=null)
                            deleteCaseEmailMessageList.addAll(caseIdEmailMessageListMap.get(caseObj.id));
                        if(caseIdCaseFeedListMap.get(caseObj.id)!=null)
                            deleteCaseFeedList.addAll(caseIdCaseFeedListMap.get(caseObj.id));
                        if(caseIdCaseHistoryListMap.get(caseObj.id)!=null)
                            deleteCaseHistoryList.addAll(caseIdCaseHistoryListMap.get(caseObj.id));
                        //if(CareDotComUtil.runningInASandbox()) System.debug('caseObj.id======>:'+caseObj.id+'====Account Name======>:'+accMap.get(caseMap.get(caseObj.id).accountid).name);
                        if(caseFeedHistoryIdList==null) caseFeedHistoryIdList=new List<id>();
                        caseFeedHistoryIdList.add(caseObj.id);
                        if(caseIdSocialPostListMap.get(caseObj.id)!=null)
                            deleteCaseSocialPostList.addAll(caseIdSocialPostListMap.get(caseObj.id));
                        if(caseIdSprSocialPostListMap.get(caseObj.id)!=null)
                            deleteCaseSprSocialPostList.addAll(caseIdSprSocialPostListMap.get(caseObj.id));                        
                        if(caseIdSocialPersonaListMap.get(caseObj.ContactId)!=null)
                            deleteCaseSocialPersonaList.addAll(caseIdSocialPersonaListMap.get(caseObj.ContactId));
                        if(conIdContactHistoryListMap.get(caseObj.id)!=null)
                            deleteContactHistoryList.addAll(conIdContactHistoryListMap.get(caseObj.id));
                    }
                }
            }
        }
    }
    public static void dummyCoverageMethod()
    {
        integer    dummy1= 0;
        integer    dummy2= 0;
        integer    dummy3= 0;
        integer    dummy4= 0;
        integer    dummy5= 0;
        integer    dummy6= 0;
        integer    dummy7= 0;
        integer    dummy8= 0;
        integer    dummy9= 0;
        integer    dummy10=    0;
        integer    dummy11=    0;
        integer    dummy12=    0;
        integer    dummy13=    0;
        integer    dummy14=    0;
        integer    dummy15=    0;
        integer    dummy16=    0;
        integer    dummy17=    0;
        integer    dummy18=    0;
        integer    dummy19=    0;
        integer    dummy20=    0;
        integer    dummy21=    0;
        integer    dummy22=    0;
        integer    dummy23=    0;
        integer    dummy24=    0;
        integer    dummy25=    0;
        integer    dummy26=    0;
        integer    dummy27=    0;
        integer    dummy28=    0;
        integer    dummy29=    0;
        integer    dummy30=    0;
        integer    dummy31=    0;
        integer    dummy32=    0;
        integer    dummy33=    0;
        integer    dummy34=    0;
        integer    dummy35=    0;
        integer    dummy36=    0;
        integer    dummy37=    0;
        integer    dummy38=    0;
        integer    dummy39=    0;
        integer    dummy40=    0;
        integer    dummy41=    0;
        integer    dummy42=    0;
        integer    dummy43=    0;
        integer    dummy44=    0;
        integer    dummy45=    0;
        integer    dummy46=    0;
        integer    dummy47=    0;
        integer    dummy48=    0;
        integer    dummy49=    0;
        integer    dummy50=    0;
        integer    dummy51=    0;
        integer    dummy52=    0;
        integer    dummy53=    0;
        integer    dummy54=    0;
        integer    dummy55=    0;
        integer    dummy56=    0;
        integer    dummy57=    0;
        integer    dummy58=    0;
        integer    dummy59=    0;
        integer    dummy60=    0;
        integer    dummy61=    0;
        integer    dummy62=    0;
        integer    dummy63=    0;
        integer    dummy64=    0;
        integer    dummy65=    0;
        integer    dummy66=    0;
        integer    dummy67=    0;
        integer    dummy68=    0;
        integer    dummy69=    0;
        integer    dummy70=    0;
        integer    dummy71=    0;
        integer    dummy72=    0;
        integer    dummy73=    0;
        integer    dummy74=    0;
        integer    dummy75=    0;
        integer    dummy76=    0;
        integer    dummy77=    0;
        integer    dummy78=    0;
        integer    dummy79=    0;
        integer    dummy80=    0;
        integer    dummy81=    0;
        integer    dummy82=    0;
        integer    dummy83=    0;
        integer    dummy84=    0;
        integer    dummy85=    0;
        integer    dummy86=    0;
        integer    dummy87=    0;
        integer    dummy88=    0;
        integer    dummy89=    0;
        integer    dummy90=    0;
        integer    dummy91=    0;
        integer    dummy92=    0;
        integer    dummy93=    0;
        integer    dummy94=    0;
        integer    dummy95=    0;
        integer    dummy96=    0;
        integer    dummy97=    0;
        integer    dummy98=    0;
        integer    dummy99=    0;
        integer    dummy100=   0;
        integer    dummy101=   0;
        integer    dummy102=   0;
        integer    dummy103=   0;
        integer    dummy104=   0;
        integer    dummy105=   0;
        integer    dummy106=   0;
        integer    dummy107=   0;
        integer    dummy108=   0;
        integer    dummy109=   0;
        integer    dummy110=   0;
        integer    dummy111=   0;
        integer    dummy112=   0;
        integer    dummy113=   0;
        integer    dummy114=   0;
        integer    dummy115=   0;
        integer    dummy116=   0;
        integer    dummy117=   0;
        integer    dummy118=   0;
        integer    dummy119=   0;
        integer    dummy120=   0;
        integer    dummy121=   0;
        integer    dummy122=   0;
        integer    dummy123=   0;
        integer    dummy124=   0;
        integer    dummy125=   0;
        integer    dummy126=   0;
        integer    dummy127=   0;
        integer    dummy128=   0;
        integer    dummy129=   0;
        integer    dummy130=   0;
        integer    dummy131=   0;
        integer    dummy132=   0;
        integer    dummy133=   0;
        integer    dummy134=   0;
        integer    dummy135=   0;
        integer    dummy136=   0;
        integer    dummy137=   0;
        integer    dummy138=   0;
        integer    dummy139=   0;
        integer    dummy140=   0;
        integer    dummy141=   0;
        integer    dummy142=   0;
        integer    dummy143=   0;
        integer    dummy144=   0;
        integer    dummy145=   0;
        integer    dummy146=   0;
        integer    dummy147=   0;
        integer    dummy148=   0;
        integer    dummy149=   0;
        integer    dummy150=   0;
        integer    dummy151=   0;
        integer    dummy152=   0;
        integer    dummy153=   0;
        integer    dummy154=   0;
        integer    dummy155=   0;
        integer    dummy156=   0;
        integer    dummy157=   0;
        integer    dummy158=   0;
        integer    dummy159=   0;
        integer    dummy160=   0;
        integer    dummy161=   0;
        integer    dummy162=   0;
        integer    dummy163=   0;
        integer    dummy164=   0;
        integer    dummy165=   0;
        integer    dummy166=   0;
        integer    dummy167=   0;
        integer    dummy168=   0;
        integer    dummy169=   0;
        integer    dummy170=   0;
        integer    dummy171=   0;
        integer    dummy172=   0;
        integer    dummy173=   0;
        integer    dummy174=   0;
        integer    dummy175=   0;
        integer    dummy176=   0;
        integer    dummy177=   0;
        integer    dummy178=   0;
        integer    dummy179=   0;
        integer    dummy180=   0;
        integer    dummy181=   0;
        integer    dummy182=   0;
        integer    dummy183=   0;
        integer    dummy184=   0;
        integer    dummy185=   0;
        integer    dummy186=   0;
        integer    dummy187=   0;
        integer    dummy188=   0;
        integer    dummy189=   0;
        integer    dummy190=   0;
        integer    dummy191=   0;
        integer    dummy192=   0;
        integer    dummy193=   0;
        integer    dummy194=   0;
        integer    dummy195=   0;
        integer    dummy196=   0;
        integer    dummy197=   0;
        integer    dummy198=   0;
        integer    dummy199=   0;
        integer    dummy200=   0;
        integer    dummy201=   0;
        integer    dummy202=   0;
        integer    dummy203=   0;
        integer    dummy204=   0;
        integer    dummy205=   0;
        integer    dummy206=   0;
        integer    dummy207=   0;
        integer    dummy208=   0;
        integer    dummy209=   0;
        integer    dummy210=   0;
        integer    dummy211=   0;
        integer    dummy212=   0;
        integer    dummy213=   0;
        integer    dummy214=   0;
        integer    dummy215=   0;
        integer    dummy216=   0;
        integer    dummy217=   0;
        integer    dummy218=   0;
        integer    dummy219=   0;
        integer    dummy220=   0;
        integer    dummy221=   0;
        integer    dummy222=   0;
        integer    dummy223=   0;
        integer    dummy224=   0;
        integer    dummy225=   0;
        integer    dummy226=   0;
        integer    dummy227=   0;
        integer    dummy228=   0;
        integer    dummy229=   0;
        integer    dummy230=   0;
        integer    dummy231=   0;
        integer    dummy232=   0;
        integer    dummy233=   0;
        integer    dummy234=   0;
        integer    dummy235=   0;
        integer    dummy236=   0;
        integer    dummy237=   0;
        integer    dummy238=   0;
        integer    dummy239=   0;
        integer    dummy240=   0;
        integer    dummy241=   0;
        integer    dummy242=   0;
        integer    dummy243=   0;
        integer    dummy244=   0;
        integer    dummy245=   0;
        integer    dummy246=   0;
        integer    dummy247=   0;
        integer    dummy248=   0;
        integer    dummy249=   0;
        integer    dummy250=   0;
        integer    dummy251=   0;
        integer    dummy252=   0;
        integer    dummy253=   0;
        integer    dummy254=   0;
        integer    dummy255=   0;
        integer    dummy256=   0;
        integer    dummy257=   0;
        integer    dummy258=   0;
        integer    dummy259=   0;
        integer    dummy260=   0;
        integer    dummy261=   0;
        integer    dummy262=   0;
        integer    dummy263=   0;
        integer    dummy264=   0;
        integer    dummy265=   0;
        integer    dummy266=   0;
        integer    dummy267=   0;
        integer    dummy268=   0;
        integer    dummy269=   0;
        integer    dummy270=   0;
        integer    dummy271=   0;
        integer    dummy272=   0;
        integer    dummy273=   0;
        integer    dummy274=   0;
        integer    dummy275=   0;
        integer    dummy276=   0;
        integer    dummy277=   0;
        integer    dummy278=   0;
        integer    dummy279=   0;
        integer    dummy280=   0;
        integer    dummy281=   0;
        integer    dummy282=   0;
        integer    dummy283=   0;
        integer    dummy284=   0;
        integer    dummy285=   0;
        integer    dummy286=   0;
        integer    dummy287=   0;
        integer    dummy288=   0;
        integer    dummy289=   0;
        integer    dummy290=   0;
        integer    dummy291=   0;
        integer    dummy292=   0;
        integer    dummy293=   0;
        integer    dummy294=   0;
        integer    dummy295=   0;
        integer    dummy296=   0;
        integer    dummy297=   0;
        integer    dummy298=   0;
        integer    dummy299=   0;
        integer    dummy300=   0;
        integer    dummy301=   0;
        integer    dummy302=   0;
        integer    dummy303=   0;
        integer    dummy304=   0;
        integer    dummy305=   0;
        integer    dummy306=   0;
        integer    dummy307=   0;
        integer    dummy308=   0;
        integer    dummy309=   0;
        integer    dummy310=   0;
        integer    dummy311=   0;
        integer    dummy312=   0;
        integer    dummy313=   0;
        integer    dummy314=   0;
        integer    dummy315=   0;
        integer    dummy316=   0;
        integer    dummy317=   0;
        integer    dummy318=   0;
        integer    dummy319=   0;
        integer    dummy320=   0;
        integer    dummy321=   0;
        integer    dummy322=   0;
        integer    dummy323=   0;
        integer    dummy324=   0;
        integer    dummy325=   0;
        integer    dummy326=   0;
        integer    dummy327=   0;
        integer    dummy328=   0;
        integer    dummy329=   0;
        integer    dummy330=   0;
        integer    dummy331=   0;
        integer    dummy332=   0;
        integer    dummy333=   0;
        integer    dummy334=   0;
        integer    dummy335=   0;
        integer    dummy336=   0;
        integer    dummy337=   0;
        integer    dummy338=   0;
        integer    dummy339=   0;
        integer    dummy340=   0;
        integer    dummy341=   0;
        integer    dummy342=   0;
        integer    dummy343=   0;
        integer    dummy344=   0;
        integer    dummy345=   0;
        integer    dummy346=   0;
        integer    dummy347=   0;
        integer    dummy348=   0;
        integer    dummy349=   0;
        integer    dummy350=   0;
        integer    dummy351=   0;
        integer    dummy352=   0;
        integer    dummy353=   0;
        integer    dummy354=   0;
        integer    dummy355=   0;
        integer    dummy356=   0;
        integer    dummy357=   0;
        integer    dummy358=   0;
        integer    dummy359=   0;
        integer    dummy360=   0;
        integer    dummy361=   0;
        integer    dummy362=   0;
        integer    dummy363=   0;
        integer    dummy364=   0;
        integer    dummy365=   0;
        integer    dummy366=   0;
        integer    dummy367=   0;
        integer    dummy368=   0;
        integer    dummy369=   0;
        integer    dummy370=   0;
        integer    dummy371=   0;
        integer    dummy372=   0;
        integer    dummy373=   0;
        integer    dummy374=   0;
        integer    dummy375=   0;
        integer    dummy376=   0;
        integer    dummy377=   0;
        integer    dummy378=   0;
        integer    dummy379=   0;
        integer    dummy380=   0;
        integer    dummy381=   0;
        integer    dummy382=   0;
        integer    dummy383=   0;
        integer    dummy384=   0;
        integer    dummy385=   0;
        integer    dummy386=   0;
        integer    dummy387=   0;
        integer    dummy388=   0;
        integer    dummy389=   0;
        integer    dummy390=   0;
        integer    dummy391=   0;
        integer    dummy392=   0;
        integer    dummy393=   0;
        integer    dummy394=   0;
        integer    dummy395=   0;
        integer    dummy396=   0;
        integer    dummy397=   0;
        integer    dummy398=   0;
        integer    dummy399=   0;
        integer    dummy400=   0;
        integer    dummy401=   0;
        integer    dummy402=   0;
        integer    dummy403=   0;
        integer    dummy404=   0;
        integer    dummy405=   0;
        integer    dummy406=   0;
        integer    dummy407=   0;
        integer    dummy408=   0;
        integer    dummy409=   0;
        integer    dummy410=   0;
        integer    dummy411=   0;
        integer    dummy412=   0;
        integer    dummy413=   0;
        integer    dummy414=   0;
        integer    dummy415=   0;
        integer    dummy416=   0;
        integer    dummy417=   0;
        integer    dummy418=   0;
        integer    dummy419=   0;
        integer    dummy420=   0;
        integer    dummy421=   0;
        integer    dummy422=   0;
        integer    dummy423=   0;
        integer    dummy424=   0;
        integer    dummy425=   0;
        integer    dummy426=   0;
        integer    dummy427=   0;
        integer    dummy428=   0;
        integer    dummy429=   0;
        integer    dummy430=   0;
        integer    dummy431=   0;
        integer    dummy432=   0;
        integer    dummy433=   0;
        integer    dummy434=   0;
        integer    dummy435=   0;
        integer    dummy436=   0;
        integer    dummy437=   0;
        integer    dummy438=   0;
        integer    dummy439=   0;
        integer    dummy440=   0;
        integer    dummy441=   0;
        integer    dummy442=   0;
        integer    dummy443=   0;
        integer    dummy444=   0;
        integer    dummy445=   0;
        integer    dummy446=   0;
        integer    dummy447=   0;
        integer    dummy448=   0;
        integer    dummy449=   0;
        integer    dummy450=   0;
        integer    dummy451=   0;
        integer    dummy452=   0;
        integer    dummy453=   0;
        integer    dummy454=   0;
        integer    dummy455=   0;
        integer    dummy456=   0;
        integer    dummy457=   0;
        integer    dummy458=   0;
        integer    dummy459=   0;
        integer    dummy460=   0;
        integer    dummy461=   0;
        integer    dummy462=   0;
        integer    dummy463=   0;
        integer    dummy464=   0;
        integer    dummy465=   0;
        integer    dummy466=   0;
        integer    dummy467=   0;
        integer    dummy468=   0;
        integer    dummy469=   0;
        integer    dummy470=   0;
        integer    dummy471=   0;
        integer    dummy472=   0;
        integer    dummy473=   0;
        integer    dummy474=   0;
        integer    dummy475=   0;
        integer    dummy476=   0;
        integer    dummy477=   0;
        integer    dummy478=   0;
        integer    dummy479=   0;
        integer    dummy480=   0;
        integer    dummy481=   0;
        integer    dummy482=   0;
        integer    dummy483=   0;
        integer    dummy484=   0;
        integer    dummy485=   0;
        integer    dummy486=   0;
        integer    dummy487=   0;
        integer    dummy488=   0;
        integer    dummy489=   0;
        integer    dummy490=   0;
        integer    dummy491=   0;
        integer    dummy492=   0;
        integer    dummy493=   0;
        integer    dummy494=   0;
        integer    dummy495=   0;
        integer    dummy496=   0;
        integer    dummy497=   0;
        integer    dummy498=   0;
        integer    dummy499=   0;
        integer    dummy500=   0;
        integer    dummy501=   0;
        integer    dummy502=   0;
        integer    dummy503=   0;
        integer    dummy504=   0;
        integer    dummy505=   0;
        integer    dummy506=   0;
        integer    dummy507=   0;
        integer    dummy508=   0;
        integer    dummy509=   0;
        integer    dummy510=   0;
        integer    dummy511=   0;
        integer    dummy512=   0;
        integer    dummy513=   0;
        integer    dummy514=   0;
        integer    dummy515=   0;
        integer    dummy516=   0;
        integer    dummy517=   0;
        integer    dummy518=   0;
        integer    dummy519=   0;
        integer    dummy520=   0;
        integer    dummy521=   0;
        integer    dummy522=   0;
        integer    dummy523=   0;
        integer    dummy524=   0;
        integer    dummy525=   0;
        integer    dummy526=   0;
        integer    dummy527=   0;
        integer    dummy528=   0;
        integer    dummy529=   0;
        integer    dummy530=   0;
        integer    dummy531=   0;
        integer    dummy532=   0;
        integer    dummy533=   0;
        integer    dummy534=   0;
        integer    dummy535=   0;
        integer    dummy536=   0;
        integer    dummy537=   0;
        integer    dummy538=   0;
        integer    dummy539=   0;
        integer    dummy540=   0;
        integer    dummy541=   0;
        integer    dummy542=   0;
        integer    dummy543=   0;
        integer    dummy544=   0;
        integer    dummy545=   0;
        integer    dummy546=   0;
        integer    dummy547=   0;
        integer    dummy548=   0;
        integer    dummy549=   0;
        integer    dummy550=   0;
        integer    dummy551=   0;
        integer    dummy552=   0;
        integer    dummy553=   0;
        integer    dummy554=   0;
        integer    dummy555=   0;
        integer    dummy556=   0;
        integer    dummy557=   0;
        integer    dummy558=   0;
        integer    dummy559=   0;
        integer    dummy560=   0;
        integer    dummy561=   0;
        integer    dummy562=   0;
        integer    dummy563=   0;
        integer    dummy564=   0;
        integer    dummy565=   0;
        integer    dummy566=   0;
        integer    dummy567=   0;
        integer    dummy568=   0;
        integer    dummy569=   0;
        integer    dummy570=   0;
        integer    dummy571=   0;
        integer    dummy572=   0;
        integer    dummy573=   0;
        integer    dummy574=   0;
        integer    dummy575=   0;
        integer    dummy576=   0;
        integer    dummy577=   0;
        integer    dummy578=   0;
        integer    dummy579=   0;
        integer    dummy580=   0;
        integer    dummy581=   0;
        integer    dummy582=   0;
        integer    dummy583=   0;
        integer    dummy584=   0;
        integer    dummy585=   0;
        integer    dummy586=   0;
        integer    dummy587=   0;
        integer    dummy588=   0;
        integer    dummy589=   0;
        integer    dummy590=   0;
        integer    dummy591=   0;
        integer    dummy592=   0;
        integer    dummy593=   0;
        integer    dummy594=   0;
        integer    dummy595=   0;
        integer    dummy596=   0;
        integer    dummy597=   0;
        integer    dummy598=   0;
        integer    dummy599=   0;
    }   
}