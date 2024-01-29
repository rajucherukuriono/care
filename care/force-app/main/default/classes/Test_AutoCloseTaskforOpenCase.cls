/*
test Class for Case Triage
Description:  Created for method AutoCloseTaskforOpenCase from apex class UCaseMilestones
CreatedBy : md Ashwaq
CreatedDate: 14/06/2022
*/
@IsTest
public class Test_AutoCloseTaskforOpenCase {
    public static ID scRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    @testSetup 
	Public static void createBucCaseAssignToUserAndClose(){
        List<User> userList=[select id,name from user where name in ('Care.com Salesforce Admin','Clicktools')];
        Case c = new Case(
            Subject = 'BUC Test Description #1',
            Description = 'BUC Test Description #1',
            Type = 'Question',
            Origin = 'Email',
            Status = 'Closed',
            OwnerId = userList[0].id,
            Reason = 'Reason',
            Secondary_Case_Reason__c = 'Secondary Case Reason',
            contact_Theme__c='Safety',
            contact_reason__c='Safety Communication',
            contact_secondary_reason__c='Other',
            Sentiment__c='Positive',
            RecordTypeId = scRtId
        );
        insert c;
        Case cs = [SELECT id,ownerId,isClosed FROM Case WHERE id =:c.id];
        System.assertEquals(true, cs.IsClosed, 'Case is closed.');
    }
    
	@IsTest
    public static void testClosetaskwhenCasestatusisClosed(){
        Case c = [SELECT id,ownerId FROM Case WHERE RecordTypeId =:scRtId limit 1];
        
        Task t = new Task();
        t.WhatId = c.id;
        t.Status = 'Not Started';
        t.Subject = 'Respond to Not Satisfied Feedback';
        t.Type = 'eMail';
        t.ActivityDate = Date.today();
        insert t;
        
        Task ts= [select id, status from Task where whatId=:c.Id];
        System.assertEquals('Completed', ts.Status, 'Task is Auto-closed');
        
        
    }
}