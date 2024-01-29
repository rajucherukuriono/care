/*
Batc class to Automation sync of cases to peoplesoft
Description:  This class is scheduled to run everyday at 11pm
Supported Test class:SyncBatch_Test
CreatedBy : shahid
*/
public class SyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful,Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){
        string Q='SELECT ID,CaseNumber,MemberUUID__c,Program_ID__c,Service_Type__c,Service_ID__c,Status,Account.memberUUID__c,Account.PersonEmail,Account.FirstName,Account.LastName,Account.PersonMailingstreet,Account.PersonMailingCity,Account.PersonMailingpostalcode,Account.PersonMailingcountry,Account.PersonMailingstate,Account.LifeCare_Company_Id__c, Syc_Status_message__c,IsCaseSync__c,First_Name_of_recipient__c,Last_Name_of_recipient__c,Relationship_to_Seeker__c,Syc_Status__c,Date_of_Birth__c,Gender_Preference__c,ClosedDate,Quick_Code_Case_Type__c,Recipient_s_Address__c,Recipient_s_City__c,Recipient_s_State__c, Recipient_s_Zip__c,Description,CreatedDate,Due_Date__c,Subject,Origin,SLA_Late_Response_Reason__c,Care_to_Begin_Date__c,Business_Account_w_Benefits__r.LifeCare_Company_Id__c,Question1__c,Question2__c, Question3__c, Question4__c, Question5__c, Question6__c,Question7__c,  Question8__c, Question9__c, Owner.name FROM Case WHERE recordtype.Name=\'LifeCare\'AND Business_Account_w_Benefits__c !=Null AND Service_Type__c !=Null AND Quick_Code_Case_Type__c !=Null AND Syc_Status_message__c !=\'Success!\' AND Care_Recipients__c !=0  AND LastModifiedBy.Name !=\'Care.com Salesforce Admin\' AND LastModifiedDate =Last_n_days:1';
      
        return Database.getQueryLocator(Q);
   }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for(case caserecord:(List<case>) scope){
            SyncCase.callCallout(caserecord); 
        } 
    }

   public void finish(Database.BatchableContext BC){
   }
   
    public void execute(SchedulableContext sc)
    {
        database.executeBatch(new SyncBatch(),1);
    }
     

}