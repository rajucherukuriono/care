/*
** _______________________________________________________________________________
** Created By:    Jack Odell
** Created Date:  10.25.2013
** Updated By:    Wavelabs [https://www.wavelabs.ai]
** Developer:     Sridhar, Salesforce Architect [sridhar.neeli@care.com]
** Updated Date:  09.02.2019
** ===============================================================================
** Description: 
** This is a Utility Class which defines several generic methods utilized by
** processes like GDPR,Retention, ODS etc..
** 
** _______________________________________________________________________________
*/
public with sharing class CareDotComUtil {

    public static Boolean isSandbox = null;
    /*
    public static ID aIsId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID aIpId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    public static ID cIccId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    public static ID oIeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static ID intlBUCId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International BUC').getRecordTypeId();
    */
    public static ID aIsId = getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
    public static ID aIpId = getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
    public static ID cIccId = getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center');
    public static ID oIeId = getRecordTypesStatic.recordTypeNameIdMap.get('International Email');
    public static ID intlBUCId = getRecordTypesStatic.recordTypeNameIdMap.get('International BUC');
    
    public static String ConvertLocaleToLanguage(String sLocale){
        // assuming locale passed as: 2 charater language, underscore, 2 character country (ex.: en_GB)
        String sLanguage = CountryLocaleMapHelper.getLanguageFromLocale(sLocale);
        return sLanguage;
    }

    public static Boolean runningInASandbox() {
        if (isSandbox == null) isSandbox = [SELECT Id,isSandbox FROM Organization LIMIT 1].isSandbox;
        return isSandbox;
    }

    public static boolean isInternationalCase(Case c) {
        // This method attempts to identify whether we're dealing with an international case that leverages the close case button
        // Right now, this is limited to the International Call Center, International Email case record types
        
        if (c.recordtypeid == cIccId || c.recordtypeid == oIeId || c.recordTypeId == intlBUCId) return true;  
        return false;
    }

    public static boolean isInternationalAccount(Account a) {
        // This method attempts to identify whether we're dealing with an international Account
        // Right now, this is limited to the International Seeker, International Provider account record types
        
        if (a.recordtypeid == aIsId || a.recordtypeid == aIpId) return true;  
        return false;
    }

    public static String convertId(String inputId){
        string suffix = '';
        integer flags;
        try{
            for (integer i = 0; i < 3; i++) {
                flags = 0;
                for (integer j = 0; j < 5; j++) {
                    string c = inputId.substring(i * 5 + j,i * 5 + j + 1);
                    if (c.toUpperCase().equals(c) && c >= 'A' && c <= 'Z') {
                        flags = flags + (1 << j);
                    }
                }
                if (flags <= 25) {
                    suffix += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(flags,flags+1);
                }else{
                    suffix += '012345'.substring(flags - 26, flags-25);
                }
            }
        }
        catch(Exception exc){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Valid 15 digit Id'));
        }
        String outputId = inputId+suffix;
        return outputId;
    }
/*
public static dateTime getLastModifiedRecInList(List<SObject> sObjList){
            DateTime maxDateTimeFound=null;
                if(!sObjList.isEmpty())
                {
                    for(SObject sObj:sObjList)
                    {
                        Account accObj=null;
                        Case caseObj=null;
                        Task taskObj=null;
                        Event eventObj=null;
                        EmailMessage emailMsgObj=null;
                        
                        if(sObj.getSObjectType()==Schema.Account.getSObjectType())
                        {
                            accObj=(Account)sObj;
                            if(maxDateTimeFound==null)
                            maxDateTimeFound=accObj.lastModifiedDate;
                            else if(accObj.lastModifiedDate > maxDateTimeFound)
                            maxDateTimeFound=accObj.lastModifiedDate;
                       }
                       else if(sObj.getSObjectType()==Schema.Case.getSObjectType())
                        {
                            caseObj=(Case)sObj;
                            if(maxDateTimeFound==null)
                            maxDateTimeFound=caseObj.lastModifiedDate;
                            else if(caseObj.lastModifiedDate > maxDateTimeFound)
                            maxDateTimeFound=caseObj.lastModifiedDate;
                       }
                       else  if(sObj.getSObjectType()==Schema.Task.getSObjectType())
                        {

                            taskObj=(Task)sObj;
                            System.debug(taskObj.id+'   '+'Task date is the maximum'+taskObj.lastModifiedDate);
                            if(maxDateTimeFound==null)
                            maxDateTimeFound=taskObj.lastModifiedDate;
                            else if(taskObj.lastModifiedDate > maxDateTimeFound)
                            maxDateTimeFound=taskObj.lastModifiedDate;
                       }
                       else  if(sObj.getSObjectType()==Schema.Event.getSObjectType())
                        {
                            eventObj=(Event)sObj;
                            if(maxDateTimeFound==null)
                            maxDateTimeFound=eventObj.lastModifiedDate;
                            else if(eventObj.lastModifiedDate > maxDateTimeFound)
                            maxDateTimeFound=eventObj.lastModifiedDate;
                       }
                       else  if(sObj.getSObjectType()==Schema.EmailMessage.getSObjectType())
                        {
                            emailMsgObj=(EmailMessage)sObj;
                            if(maxDateTimeFound==null)
                            maxDateTimeFound=emailMsgObj.lastModifiedDate;
                            else if(emailMsgObj.lastModifiedDate > maxDateTimeFound)
                            maxDateTimeFound=emailMsgObj.lastModifiedDate;
                       }
                    }
                }
                return maxDateTimeFound;
            }
   */         
    public static void  getSalesforceLastModifiedDateOnAccount(List<Account> accList)
    {
      Map<id,Case> caseMap;    
    
     Map<id,List<Case>> accIdCaseListMap;
    
     Map<id,EmailMessage> caseEmailMessageMap;
     Map<id,List<EmailMessage>> caseIdEmailMessageListMap;
     List<EmailMessage> deleteCaseEmailMessageList=new List<EmailMessage>();
    
    
     Map<id,Event> caseEventMap;
     Map<id,List<Event>> caseIdEventListMap;
     
     Map<id,Task> caseTaskMap;
     Map<id,List<Task>> caseIdTaskListMap;
     Set<Task> updateCaseTaskList=new Set<Task>();
    
     Map<id,CaseComment> caseCaseCommentMap;
     Map<id,List<CaseComment>> caseIdCaseCommentListMap;
    

     Map<id,boolean> accWithNonClearCasesMap;
     Map<id,List<Case>> accWithOpenCasesMap;
     Map<id,DateTime> accWithLatModifiedTimeStampMap;
     Map<id,List<Id>> accWithCaseMap;
     Set<Id> closedCaseSet;
    
    
     Map<id,String> caseRecTypes=new Map<id,String>();
     Map<String,id> caseRecTypeNameIdMap=new Map<String,id>();
    
     Map<id,Account> accMap;
    
     Map<id,id> accPersonContactMap=new Map<id,id>();
     Map<id,id> personContactAccMap=new Map<id,id>();
    

        
        for(Account accObj:accList)
        {
            accPersonContactMap.put(accObj.id,accObj.personContactId);
            personContactAccMap.put(accObj.personContactId,accObj.id);
            /*
            if(accObj.Gdpr_Request__c=='RT Open Inactive' || accObj.Gdpr_Request__c=='RT Closed Acct' || accObj.Gdpr_Request__c=='RT Incomplete')
            {
                if(accObj.Request_Type__c!=accObj.Gdpr_Request__c)  accObj.Request_Type__c=accObj.Gdpr_Request__c;
            }
            */
        }
        
        List<String> closedStatusList = new List<String>();
        for(CaseStatus csObj: [SELECT Id, isClosed, MasterLabel FROM CaseStatus WHERE IsClosed = true])
        {
            closedStatusList.add(csObj.MasterLabel);
        }
        
        if(CareDotComUtil.runningInASandbox()) System.debug('Inside ProcessMemberIntlRetentionInstantRequest method ==>:');

        accMap=new Map<id,Account>();
        for(Account accobj:accList)
        {
            accMap.put(accObj.id,accObj);
        }

        /**********************************************************************/
        
        caseMap=new Map<id,Case>([SELECT ID,STATUS,RECORDTYPEID,ACCOUNTID,subject,description,Account.Name,Employer_Program__c,CreatedDate,LastModifiedDate FROM CASE WHERE ACCOUNTID=:accMap.keySet() LIMIT 50000]);
        
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
        /**********************************************************************/
        
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'),'International Safety Alert');
        caseRecTypeNameIdMap.put('International Safety Alert',getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert'));
        /*caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'),'International NPS');
        caseRecTypeNameIdMap.put('International NPS',getRecordTypesStatic.recordTypeNameIdMap.get('International NPS'));
        caseRecTypes.put(getRecordTypesStatic.recordTypeNameIdMap.get('NPS'),'NPS');
        caseRecTypeNameIdMap.put('NPS',getRecordTypesStatic.recordTypeNameIdMap.get('NPS'));*/
        /**********************************************************************/
        accWithNonClearCasesMap=new Map<id,boolean>();
        accWithOpenCasesMap=new Map<id,List<Case>>();
        accWithLatModifiedTimeStampMap=new Map<id,DateTime>();
        accWithCaseMap=new Map<id,List<Id>>();
        /**************************************************************************************/
        
        Set<Id> listWithoutNulls=new Set<Id>(accPersonContactMap.values());listWithoutNulls.remove(null);
        Map<id,Task> accTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT,LastModifiedDate FROM Task WHERE whoId=:listWithoutNulls LIMIT 50000]);
        Map<id,List<Task>> accIdTaskListMap=new Map<id,List<Task>>();

        if(!listWithoutNulls.isEmpty())
        {
            for(Task TaskObj:accTaskMap.values())
            {
                if(CareDotComUtil.runningInASandbox()) System.debug('Adding task to accIdTaskListMap================>:'+taskObj.subject);
                if(accIdTaskListMap.get(TaskObj.whoId)==null)
                {
                    accIdTaskListMap.put(TaskObj.whoId,new List<Task>{TaskObj});
                }
                else
                {
                    accIdTaskListMap.get(TaskObj.whoId).add(TaskObj);
                }
            }
        }
       /* 
        for(Account accObj:accList)
        {
            accWithLatModifiedTimeStampMap.put(accObj.id,accObj.Salesforce_Last_Action_Date__c==null?accObj.createdDate:accObj.Salesforce_Last_Action_Date__c);
        }
        */
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdTaskListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Task taskObj:accIdTaskListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('taskObj.whoId==>:'+taskObj.whoId+personContactAccMap.get(taskObj.whoId)+taskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(taskObj.whoId)) < taskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+taskObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(taskObj.whoId),taskObj.lastModifiedDate);
                            }
                    }               
            }
            
        }
      /**********************************************************************************************/
      Map<id,Task> accTask2Map=new Map<id,Task>([SELECT ID,whoID,whatId,SUBJECT,LastModifiedDate FROM Task WHERE whatId=:accList LIMIT 50000]);
        
        
        Map<id,List<Task>> accIdTask2ListMap=new Map<id,List<Task>>();
        
        for(Task TaskObj:accTask2Map.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Task to accTasklist================>:'+TaskObj.subject);
            if(accIdTask2ListMap.get(TaskObj.whatId)==null)
            {
                accIdTask2ListMap.put(TaskObj.whatId,new List<Task>{TaskObj});
            }
            else
            {
                accIdTask2ListMap.get(TaskObj.whatId).add(TaskObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdTask2ListMap.containsKey(accObj.id))
            {
                    for(Task TaskObj:accIdTask2ListMap.get(accObj.id))
                    {
                            System.debug('TaskObj.whatId==>:'+TaskObj.whatId+TaskObj.whatId+TaskObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(TaskObj.whatId) < TaskObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+TaskObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(TaskObj.whatId,TaskObj.lastModifiedDate);
                            }
                    }               
            }
            
        }
/**********************************************************************************************/

            Map<id,Event> accEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID,SUBJECT,LastModifiedDate FROM Event WHERE whoId=:listWithoutNulls  LIMIT 50000] );
        
        
        Map<id,List<Event>> accIdEventListMap=new Map<id,List<Event>>();
        
        for(Event EventObj:accEventMap.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Event to accEventlist================>:'+EventObj.subject);
            if(accIdEventListMap.get(EventObj.whoId)==null)
            {
                accIdEventListMap.put(EventObj.whoId,new List<Event>{EventObj});
            }
            else
            {
                accIdEventListMap.get(EventObj.whoId).add(EventObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEventListMap.containsKey(accPersonContactMap.get(accObj.id)))
            {
                    for(Event eventObj:accIdEventListMap.get(accPersonContactMap.get(accObj.id)))
                    {
                            System.debug('eventObj.whoId==>:'+eventObj.whoId+personContactAccMap.get(eventObj.whoId)+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId))==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(eventObj.whoId),eventObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(personContactAccMap.get(eventObj.whoId)) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(personContactAccMap.get(eventObj.whoId),eventObj.lastModifiedDate);
                            }
                    }               
            }
            
        }
        /*********************************************************************************************/  
        Map<id,Event> accEvent2Map=new Map<id,Event>([SELECT ID,whoID,whatId,SUBJECT,LastModifiedDate FROM Event WHERE whatId=:accList  LIMIT 50000]);
        
        
        Map<id,List<Event>> accIdEvent2ListMap=new Map<id,List<Event>>();
        
        for(Event EventObj:accEvent2Map.values())
        {
            if(CareDotComUtil.runningInASandbox()) System.debug('Adding Event to accEventlist================>:'+EventObj.subject);
            if(accIdEvent2ListMap.get(EventObj.whatId)==null)
            {
                accIdEvent2ListMap.put(EventObj.whatId,new List<Event>{EventObj});
            }
            else
            {
                accIdEvent2ListMap.get(EventObj.whatId).add(EventObj);
            }
        }
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEvent2ListMap.containsKey(accObj.id))
            {
                    for(Event eventObj:accIdEvent2ListMap.get(accObj.id))
                    {
                            System.debug('eventObj.whatId==>:'+eventObj.whatId+eventObj.whatId+eventObj.lastModifiedDate);
                            if(accWithLatModifiedTimeStampMap.get(eventObj.whatId)==null)
                            {
                                System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(eventObj.whatId) < eventObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+eventObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(eventObj.whatId,eventObj.lastModifiedDate);
                            }
                    }               
            }
            
        }
        
        /**********************************************************************************************/
        /*
        Map<id,EmailMessage> accIdEmailMsgMap=new Map<id,EmailMessage>([SELECT ID,PARENTID,LastModifiedDate FROM EmailMessage WHERE parentId=:accMap.keySet() LIMIT 50000]);
        
        
        Map<id,List<EmailMessage>> accIdEmailMsgListMap=new Map<id,List<EmailMessage>>();
        
        for(EmailMessage EmailMessageObj:accIdEmailMsgMap.values())
        {
            if(accIdEmailMsgListMap.get(EmailMessageObj.parentId)==null)
            {
                accIdEmailMsgListMap.put(EmailMessageObj.parentId,new List<EmailMessage>{EmailMessageObj});
            }
            else
            {
                accIdEmailMsgListMap.get(EmailMessageObj.parentId).add(EmailMessageObj);
            }
        }
        
        
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdEmailMsgListMap.containsKey(accObj.id))
            {
                    for(EmailMessage emailMsgObj:accIdEmailMsgListMap.get(accObj.id))
                    {
                            if(accWithLatModifiedTimeStampMap.get(emailMsgObj.parentId)==null)
                            {
                                System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(emailMsgObj.parentId,emailMsgObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(emailMsgObj.parentId) < emailMsgObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+emailMsgObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(emailMsgObj.parentId,emailMsgObj.lastModifiedDate);
                            }
                    }               
            }
            
        }
        */
        /************************************************************************************************/
       
        for(Account accObj:accList)
        {
            if(accObj!=null && accIdCaseListMap.containsKey(accObj.id))
            {
                    for(Case caseObj:accIdCaseListMap.get(accObj.id))
                    {
                        if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 222');
                        //if(caseObj.recordTypeId!=caseRecTypeNameIdMap.get('NPS') && caseObj.recordTypeId!=caseRecTypeNameIdMap.get('International NPS'))
                        if(caseObj.recordTypeId!=null)
                        {
                            if(CareDotComUtil.runningInASandbox()) System.debug('CUSTOM DEBUG LINE ============>: 333 Non Cleared Safety Alert Found'+caseObj.id);
                            accWithNonClearCasesMap.put(caseObj.accountId,true);
                           if(accWithLatModifiedTimeStampMap.get(caseObj.accountId)==null)
                            {
                                System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                            }
                            else if(accWithLatModifiedTimeStampMap.get(caseObj.accountId) < caseObj.lastModifiedDate)
                            {   System.debug('Put last action date =======>:'+caseObj.lastModifiedDate);                              
                                accWithLatModifiedTimeStampMap.put(caseObj.accountId,caseObj.lastModifiedDate);
                            }
                        }
                    }
                
            }
        }
        
                
    

        
        
        
    /**********************************************************************/
    caseEmailMessageMap=new Map<id,EmailMessage>([SELECT ID,PARENTID,CreatedDate,LastModifiedDate FROM EmailMessage WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        
        
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
        /**********************************************************************/
        caseEventMap=new Map<id,Event>([SELECT ID,WHATID,WHOID,CreatedDate,LastModifiedDate FROM Event WHERE whatId=:caseMap.keySet() LIMIT 50000]);
        
        
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
        /**********************************************************************/
        caseTaskMap=new Map<id,Task>([SELECT ID,WHATID,WHOID,SUBJECT,CreatedDate,LastModifiedDate FROM Task WHERE whatId=:caseMap.keySet()]);
        
        
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
        /**********************************************************************/
        caseCaseCommentMap=new Map<id,CaseComment>([SELECT ID,parentId,CreatedDate,LastModifiedDate FROM CaseComment WHERE parentId=:caseMap.keySet() LIMIT 50000]);
        
        
        caseIdCaseCommentListMap=new Map <id,List<CaseComment>>();
        
        for(CaseComment caseCommentObj:caseCaseCommentMap.values())
        {
            if(caseIdCaseCommentListMap.get(caseCommentObj.parentId)==null)
            {
                caseIdCaseCommentListMap.put(caseCommentObj.parentId,new List<CaseComment>{caseCommentObj});
            }
            else
            {
                caseIdCaseCommentListMap.get(caseCommentObj.parentId).add(caseCommentObj);
            }
        }
        /**********************************************************************/
        
        for(Id caseCommentId:caseCaseCommentMap.keySet())
        {
                        System.debug('CaseComment For Loop'+caseCommentId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId);
                
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId);
                datetime caseCommentMDate = caseCaseCommentMap.get(caseCommentId).lastModifiedDate;
                
                if(caseCommentMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+caseCommentMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseCaseCommentMap.get(caseCommentId).parentId).accountId,caseCommentMDate);

                }
            }
        }


 
        for(Id emailMsgId:caseEmailMessageMap.keySet())
        {
                        System.debug('emailMessage For Loop'+emailMsgId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId);
                datetime emailMsgLMDate = caseEmailMessageMap.get(emailMsgId).lastModifiedDate;
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseEmailMessageMap.get(emailMsgId).parentId).accountId,emailMsgLMDate);

                }
            
            
            }
        }
        
        for(Id eventId:caseEventMap.keySet())
        {
                        System.debug('Event For Loop'+eventId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseEventMap.get(eventId).WhatId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseEventMap.get(eventId).WhatId).accountId);
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseEventMap.get(eventId).WhatId).accountId);
                datetime emailMsgLMDate = caseEventMap.get(eventId).lastModifiedDate;
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseEventMap.get(eventId).WhatId).accountId,emailMsgLMDate);

                }
            
            
            }
        }
        
        for(Id taskId:caseTaskMap.keySet())
        {
            System.debug('Task For Loop'+taskId);
            
            if(accWithLatModifiedTimeStampMap.containsKey(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId))
            {
                Account accObj=accMap.get(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);
                System.debug('Found Account of Task......');
                datetime caseLastModifiedDate= accWithLatModifiedTimeStampMap.get(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);
                System.debug('Found caseLastModifiedDate of Task......'+caseLastModifiedDate);
                datetime emailMsgLMDate = caseTaskMap.get(taskId).lastModifiedDate;
                System.debug('Found emailMsgLMDate of Task......');
                if(emailMsgLMDate > caseLastModifiedDate)
                {
                    System.debug('Put last action date =======>:'+emailMsgLMDate);
                    accWithLatModifiedTimeStampMap.put(caseMap.get(caseTaskMap.get(taskId).WhatId).accountId,emailMsgLMDate);
                    System.debug('updating emailMsgLMDate  of Task on account.....'+emailMsgLMDate+caseMap.get(caseTaskMap.get(taskId).WhatId).accountId);

                }
            
            
            }
        }

        for(Account accObj:accList)
        {
        System.debug('accObj====>:'+accObj.id+accWithLatModifiedTimeStampMap.containsKey(accObj.id));
           
           system.debug('Setting Last Action Date ====>:'+accWithLatModifiedTimeStampMap.get(accObj.id));
           accObj.Salesforce_Last_Action_Date__c=accWithLatModifiedTimeStampMap.get(accObj.id);
           accObj.GDPR_Sync_Status__c='SLAD Success';
        }

       //return accList; 
    
  }
    public static String commaSeperatedString(List<String> strList)
    {
        String csStr='';
        if(strList!=null)
        {
            for(integer i=0;i<strList.size();i++)
            {
                if(i==strList.size()-1)
                {
                    csStr='\''+strList[i]+'\'';
                }
                else
                {
                    csStr='\''+strList[i]+'\',';
                }
            }
        }
        if(csStr!='') csStr='('+csStr+')';
        return csStr;
    }
}