@isTest(SeeAllData=false)
public class Test_AutoPopulateOverallScoreonVetting {
    private static ID BUCNetAgencyRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Agency').getRecordTypeId();
    private static ID BUCNetCenterRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Center').getRecordTypeId();
    private static ID USBUCRtId = Schema.SObjectType.Vetting__c.getRecordTypeInfosByName().get('US BUC Network Vetting').getRecordTypeId();
    @isTest(SeeAllData=false)
    static void autoPopulateOverallScoretest() 
{
    Test.startTest();
    Account a = new Account(Name='TestAccount1',overall_score__c=79, recordTypeId=BUCNetCenterRtId);
    insert a;
    Account a1 = new Account(Name='TestAccount2',overall_score__c=79, recordTypeId=BUCNetAgencyRtId);
    insert a1;
    a.overall_score__c=82;
    update a;
    a1.overall_score__c=82;
    update a1;
    Vetting__c vetObj1=new Vetting__c(Name='Vetting Test',overall_score__c= 82, BUC_Center_Name__c=a.id, recordTypeId=USBUCRtId);
    insert vetObj1;
    Vetting__c vetObj2=new Vetting__c(Name='Vetting Test',overall_score__c= 82, BUC_Center_Name__c=a1.id, recordTypeId=USBUCRtId);
    insert vetObj2;
    Test.stopTest();
    list<Account> acc= [select id, overall_score__c from account limit 1];
    list<Vetting__c> vet = [select id, overall_score__c, Business_Name__c from Vetting__c where Business_Name__c=:a.id limit 1];
}
}