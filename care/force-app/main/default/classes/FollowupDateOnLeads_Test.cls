@isTest
private class FollowupDateOnLeads_Test {
private static Id HomePayB2CLeadRt =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HomePay_B2C_Lead').getRecordTypeId();

static testMethod void HomepayB2CLeadsTest () {


Lead l = new Lead();
            l.FirstName = 'Test';
            l.LastName = 'Person';
            l.Status = 'Open';
            l.RecordTypeId = HomePayB2CLeadRt;
            insert l;
            
 Task t = new Task();
            t.WhoId = l.Id; 
            t.Subject = 'Meeting Scheduled';
            t.ActivityDate = system.today();
            t.status = 'Not Started';
            t.priority = 'Normal';
            insert t;
        }
    }