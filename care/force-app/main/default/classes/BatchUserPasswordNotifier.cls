global class BatchUserPasswordNotifier implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    //Default user password expire days. Security Controls -> Password Policies -> “User password expires in” field
    private Integer pwdExpiryDays = 90;
    private String query;
    public boolean isTestingContext=false;
    //Days before password expire
    private Integer DaysToExpire= 10;
//Email template to notify users about passowrd expiration
private static final String PASSWORD_NOTIFICATION_EMAIL = 'Password Reset Notification Email';
/**
* Constructor of the Batchable and Schedulable class, receives the default days of passowrd expire
*/
    global BatchUserPasswordNotifier(Integer pwdExpiryDays,Integer DaysToExpire,boolean isTestingContext) {
        this.pwdExpiryDays = pwdExpiryDays;
        this.DaysToExpire=DaysToExpire;
        this.isTestingContext=isTestingContext;
     }
/**
* Schedulable method, execute the schedule apex job
*/
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
/**
* start method of the Batchable interface
*/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = createSOQLQuery();
        return Database.getQueryLocator(query);
    }
/**
* execute method of Batchable interface
*/
    global void execute(Database.BatchableContext bc, List<SObject> records) {
        List<User> usersList = (List<User>)records;
        List<EmailTemplate> passwExpiryTemplates = [SELECT id, name, Subject, HtmlValue, Body  FROM EmailTemplate WHERE Name = :PASSWORD_NOTIFICATION_EMAIL];
        if(!passwExpiryTemplates.isEmpty() && !usersList.isEmpty()){
        List<Messaging.Singleemailmessage> emails = getMailMessageForUsers(passwExpiryTemplates[0], usersList);
        Messaging.sendEmail(emails);
        }
    }
/**
* finish method of Batchable interface
*/
    global void finish(Database.BatchableContext bc) {
    }
    private String createSOQLQuery(){
    
        String soql = '';
        String selectUser = 'Select id,firstname,lastname,name,Division,LastPasswordChangeDate,username from User where (';
        Integer passExpAux = 0;
        String whereCondition ='';

            for(integer i=DaysToExpire;i>0;i--)
            {
                passExpAux = pwdExpiryDays - i;
                if(i==DaysToExpire)
                whereCondition +=' ((lastPasswordChangeDate = last_n_days:'+ passExpAux  + ') and ' +' (lastPasswordChangeDate != last_n_days:'+ (passExpAux-1)  + '))';
                else 
                whereCondition +=' OR  ((lastPasswordChangeDate = last_n_days:'+ passExpAux  + ') and ' +' (lastPasswordChangeDate != last_n_days:'+ (passExpAux-1)  + '))';
            }
            // +' and lastPasswordChangeDate != last_n_days:' + (passExpAux - 1)
            whereCondition += ') and isActive = true and Division= \'SF Team\' ' ;
            soql = selectUser + whereCondition; 
 if(isTestingContext)
 {
        soql='Select id,firstname,lastname,name,LastPasswordChangeDate,username from User LIMIT 200';

 }
        System.debug(' SOQL===============>:************* ' + soql + ' ************* ');
        return soql;
    }
    private List<Messaging.Singleemailmessage> getMailMessageForUsers(EmailTemplate emailTemplate, List<User> usersListToNotify){
        List<Messaging.Singleemailmessage> mailMessageList = new List<Messaging.Singleemailmessage>();
        for(User user: usersListToNotify) {
//mailMessageList.add(createEmailTemplate(emailTemplate, DAYS_TO_EXPIRE_10_DAYS, user));
if(user!=null && user.LastPasswordChangeDate!=null && !isPasswordNeverExpireUser(user.id))
mailMessageList.add(createEmailTemplate(emailTemplate, pwdExpiryDays-(user.LastPasswordChangeDate.date().daysBetween(system.now().date())), user));
        }
        return mailMessageList;
    }
    Private Messaging.SingleEmailMessage createEmailTemplate(EmailTemplate emailTemplate, Integer daysToExpire, User user) {
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!days}', String.valueOf(daysToExpire));
        
        String plainBody = emailTemplate.Body;
        String htmlBody = emailTemplate.htmlValue;
        
        plainBody = plainBody.replace('{!days}', String.valueOf(daysToExpire));
        plainBody = plainBody.replace('{!username}', user.Username);
        plainBody = plainBody.replace('{!firstName}', user.firstname==null?user.lastname:user.firstname);
        
        htmlBody = htmlBody.replace('{!days}', String.valueOf(daysToExpire));
        htmlBody = htmlBody.replace('{!username}', user.Username);
        htmlBody = htmlBody.replace('{!firstName}', user.firstname==null?user.lastname:user.firstname);
        
        email.setTemplateId(emailTemplate.id);
        email.setReplyTo('helpdesk@care.com');
        email.setSenderDisplayName('Care.com Admin');
        email.setTargetObjectId(user.Id);
        email.setSubject(subject);
        email.setPlainTextBody(plainBody);
        //email.setHtmlBody(htmlBody);
        email.setSaveAsActivity(false);
        return email;
    }
    public boolean isPasswordNeverExpireUser(id userId)
    {
    Map<id,Date> usrPwdExpMap=new Map<id,Date>();  
Map<id,id> usrPwdNeverExpireMap=new Map<id,id>();  
    
// Get the report ID
List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
    DeveloperName like  '%Users_Password_Expire_10_Days%'];
    if(reportList.size()>0)
    {
String reportId = (String)reportList.get(0).get('Id');

// Run a report asynchronously
/*
Reports.reportInstance repInstance= Reports.ReportManager.runAsyncReport(reportId, true);
Reports.ReportResults results=repInstance.getReportResults();
*/

// Run a report synchronously
Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);

// Get the first down-grouping in the report
Reports.Dimension dim = results.getGroupingsDown();
Reports.GroupingValue groupingVal = dim.getGroupings()[0];
System.debug('Key: ' + groupingVal.getKey());
System.debug('Label: ' + groupingVal.getLabel());
System.debug('Value: ' + groupingVal.getValue());

// Construct a fact map key, using the grouping key value
String factMapKey = groupingVal.getKey() + '!T';

// Get the fact map from the report results
Reports.ReportFactWithDetails factDetails =
    (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);

// Get the first summary amount from the fact map
Reports.SummaryValue sumVal = factDetails.getAggregates()[0];
System.debug('Summary Value: ' + sumVal.getLabel());

List<Reports.ReportDetailRow> reportDtlRow=factDetails.getRows();

    for(Reports.ReportDetailRow dtlRow:reportDtlRow)
    {
        if(dtlRow.getDataCells().get(dtlRow.getDataCells().size()-1).getLabel().length()>1)
        {
            usrPwdExpMap.put(dtlRow.getDataCells().get(0).getLabel(),Date.parse(dtlRow.getDataCells().get(dtlRow.getDataCells().size()-1).getLabel().subString(0,9).trim()));
        }
        else
        {
            usrPwdNeverExpireMap.put(dtlRow.getDataCells().get(0).getLabel(),dtlRow.getDataCells().get(0).getLabel());
        }
    }
         System.debug('usrPwdNeverExpireMap===========>:'+usrPwdNeverExpireMap);

    
        if(usrPwdNeverExpireMap.containsKey(userId)) return true;
    }
    return false;
}
}