@isTest
private class Test_HomePay1stTimeReferringContactRpt
{
    static testMethod void testMethod1() {
       // Create test records
        ID oppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        Opportunity opp = new Opportunity();
        opp.RecordtypeId = oppRtId;
        opp.Name = 'home pay test opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.Probability = 0;
        opp.How_did_you_hear_about_Care_com__c = 'Agency';
        opp.Product_Type__c='Authorized Contact';
        opp.stageName = 'Closed Won';
        insert opp;


        //oppACContRoleList=[SELECT Opportunity.Name,Opportunity.Product_Type__c, Contact.Name,Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where Opportunity.Product_Type__c='Authorized Contact' and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
        //oppRefContRoleList=[SELECT Opportunity.Name,Opportunity.Product_Type__c, Contact.Name,Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where Opportunity.Product_Type__c='Referral' and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
        OpportunityContactRole contRole=new OpportunityContactRole(opportunityid=opp.id,contactid=con.id);
        insert contRole;
        HomePay1stTimeReferringContactReport.setHomePay1stTimeReferringContactReport();
                opp.Product_Type__c= 'Referral';
        update opp;
                HomePay1stTimeReferringContactReport.setHomePay1stTimeReferringContactReport();
        
    }
}