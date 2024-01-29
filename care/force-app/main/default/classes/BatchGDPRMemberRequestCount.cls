/*  This class counts the number of person accounts enabled for Gdpr_Request__c as delete and sends email on daily basis
    Devoper Name:  SRIDHAR NEELI(sridharn@wavelabs.in)
    Date:05/29/2018
    last updated By: MD Ashwaq
    last updated Date: 02/14/2023
*/
global class BatchGDPRMemberRequestCount implements Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    public integer totalGdprCount=0;
    public integer totalClosedCount=0;
    public integer employerProgramPopulated=0;
    public Map<id,RecordType> caseRecTypes;
    public Map<id,List<case>> accWithSafetyCaseMap;
    public Map<id,Account> accSafetyMap=new Map<id,Account>();
    public List<User> userList=new List<User>();
    public integer totalNoOfSafetyCases=0;
    global BatchGDPRMemberRequestCount(boolean isTestingContext,List<User> userList) {
        this.userList=userList;
        this.isTestingContext=isTestingContext;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        caseRecTypes=new Map<id,RecordType>([SELECT ID,NAME FROM RECORDTYPE WHERE sObjectType='Case' and NAME IN ('International Call Center','International Email','International Safety Alert', 'Social Media International')]);
        //query = 'Select id from Account Where RecordType.Name in (\'International Seeker\',\'International Provider\') and GDPR_Request__c=\'Delete\'';
        query = 'Select id,recordtypeid,status__pc,Employer_Program__pc from Account WHERE GDPR_Request__c in (\'Delete\',\'RTBF\')';
        if(isTestingContext)
        {
            //query  ='Select id from Account Where RecordType.Name in (\'International Seeker\',\'International Provider\') and GDPR_Request__c=\'Delete\' LIMIT 200';
            query = 'Select id,recordtypeid,status__pc,Employer_Program__pc from Account WHERE GDPR_Request__c in (\'Delete\',\'RTBF\') LIMIT 200';
        }
        System.debug('GDPR Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    /**
    Schedulable method, execute the schedule apex job
    */  
    global void execute(Database.BatchableContext bc, List<Account> gdprList)
    {
        totalGdprCount=totalGdprCount+gdprList.size();
        accWithSafetyCaseMap=new Map<id,List<case>>();
        Map<id,Case> caseMap=new Map<id,Case>([Select id,accountid,recordtypeid from case where accountid=:gdprList]);
        for(Case caseObj:caseMap.values())
        {
            if(caseRecTypes.containsKey(caseObj.recordTypeId) && caseRecTypes.get(caseObj.recordTypeId).name=='International Safety Alert')
            {
                totalNoOfSafetyCases=totalNoOfSafetyCases+1;
                if(accWithSafetyCaseMap.containsKey(caseObj.accountId))
                    accWithSafetyCaseMap.get(caseObj.accountId).add(caseObj);
                else
                    accWithSafetyCaseMap.put(caseObj.accountId,new List<Case>{caseObj});
            }
        }
        for(Account accObj:gdprList){
            if(accWithSafetyCaseMap.containsKey(accObj.id))
            {
                accSafetyMap.put(accObj.id,accObj);
            }
            if(accObj.Status__pc=='Closed')            
                totalClosedCount=totalClosedCount+1;
            if(!String.isBlank(accObj.Employer_Program__pc)) 
                employerProgramPopulated=employerProgramPopulated+1;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        System.debug('GDPR accounts in delete status are =========>:'+totalGdprCount);
        List<EmailTemplate> gdprEmailTemplate = [SELECT id, name, Subject, HtmlValue, Body  FROM EmailTemplate WHERE Name = 'GDPR Member Request Count Notification Email'];
        List<Messaging.Singleemailmessage> emails = getMailMessageForUsers(gdprEmailTemplate[0], userList);
        Messaging.sendEmail(emails);
    }  
    private List<Messaging.Singleemailmessage> getMailMessageForUsers(EmailTemplate emailTemplate, List<User> usersListToNotify){
        List<Messaging.Singleemailmessage> mailMessageList = new List<Messaging.Singleemailmessage>();
        for(User user: usersListToNotify) {
            mailMessageList.add(createEmailTemplate(emailTemplate, user));
        }
        return mailMessageList;
    }
    private Messaging.SingleEmailMessage createEmailTemplate(EmailTemplate emailTemplate,User user) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!gdpRecCount}', String.valueOf(totalGdprCount));
        String plainBody = emailTemplate.Body;
        String htmlBody = emailTemplate.htmlValue;
        plainBody = plainBody.replace('{!gdpRecCount}', String.valueOf(totalGdprCount));
        plainBody = plainBody.replace('{!username}', user.Username);
        plainBody = plainBody.replace('{!firstName}', user.firstname==null?user.lastname:user.firstname);
        plainBody = plainBody.replace('{!totalClosedCount}', String.valueOf(totalClosedCount));
        plainBody = plainBody.replace('{!employerProgramPopulated}', String.valueOf(employerProgramPopulated));
        plainBody = plainBody.replace('{!accountsWithSafetyCases}', String.valueOf(accSafetyMap.size()));
        plainBody = plainBody.replace('{!totalNoOfSafetyCases}', String.valueOf(totalNoOfSafetyCases));
        htmlBody = htmlBody.replace('{!gdpRecCount}', String.valueOf(totalGdprCount));
        htmlBody = htmlBody.replace('{!username}', user.Username);
        htmlBody = htmlBody.replace('{!firstName}', user.firstname==null?user.lastname:user.firstname);
        htmlBody = htmlBody.replace('{!totalClosedCount}', String.valueOf(totalClosedCount));
        htmlBody = htmlBody.replace('{!employerProgramPopulated}', String.valueOf(employerProgramPopulated));
        htmlBody = htmlBody.replace('{!accountsWithSafetyCases}', String.valueOf(accSafetyMap.size()));
        htmlBody = htmlBody.replace('{!totalNoOfSafetyCases}', String.valueOf(totalNoOfSafetyCases));
        email.setTemplateId(emailTemplate.id);
        email.setReplyTo('test@email.com');
        email.setSenderDisplayName('Care.com Admin');
        email.setTargetObjectId(user.Id);
        email.setSubject(subject);
        email.setPlainTextBody(plainBody);
        email.setHtmlBody(htmlBody);
        email.setSaveAsActivity(false);
        return email;
    }  
}