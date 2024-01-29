/*
test Class for Case Triage
Description:  Created for method mcCaseManualPrioritization
CreatedBy : md Ashwaq
CreatedDate: 31/03/2023
*/
@IsTest
public class Test_mcCaseManualPrioritization {
	Public static Id IntlCall = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    Public static Id IntlEmail = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    Public static Id Strd = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    Public static Id Safety = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
    Public static Id CallCent = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();
    Public static Id SocialMediaUS =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media US').getRecordTypeId();
    Public static Id SocialMediaIntl =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media International').getRecordTypeId();
    Public static Group GTemp = [Select Id, Name FROM Group WHERE DeveloperName = 'MC_Temporary' LIMIT 1]; 
    public static User automatedUser = [Select id , name from user where name  = 'Care.com Salesforce Admin' and isActive=true];
   @testSetup 
	Public static void setupData(){
        List<Case> lstCases = new List<Case>();
        Case c = new Case(
            Subject = 'MemberCare Case 1',
            Description = 'MC EN Tier 1 case',
            Type = 'Question',
            Origin = 'Email',
            Status = 'New',
            Priority = '1',
            RecordTypeId = Strd
        );
        lstCases.add(c);
        Case c1 = new Case(
            Subject = 'MemberCare Case 2',
            Description = 'MC EN Tier 2 case',
            Type = 'Question',
            Origin = 'Email',
            Status = 'New',
            Priority = '2',
            RecordTypeId = Strd
        );
        lstCases.add(c1);
        Case c2 = new Case(
            Subject = 'MemberCare Case 1',
            Description = 'MC EN Tier 1 case',
            Type = 'Question',
            Origin = 'Email',
            Status = 'New',
            Priority = '1',
            RecordTypeId = Strd
        );
        lstCases.add(c2);
        insert lstCases;
    }
    
	@IsTest
    public static void testgetPicklistValuesfromMap(){
        list<MC_RePrioritization__mdt> lstMtd = [Select id, Member_Account_Type__c,Member_Language__c, Member_Type__c, Priority__c, Support_Skill__c from MC_RePrioritization__mdt];
        mcCaseManualPrioritization.getPicklistValuesfromMap();
    }
    
    @isTest
    public static void testupdateCases(){
        Case c1 = [Select id , priority from case where Subject ='MemberCare Case 1' limit 1];       
        system.assertEquals(c1.Priority, '1');
        c1.Priority = '5';
        List<Map<String, string>> lstCases = new List<Map<String, string>>();
        Map<String, string> mapStr = new Map<String, String>();
        mapStr.put('Id', c1.Id);
        mapStr.put('Priority', c1.Priority);
        lstCases.add(mapStr);
        mcCaseManualPrioritization.updateCases(lstCases);
        Case UpdCase = [Select id , priority from case where Subject ='MemberCare Case 1' limit 1];       
        system.assertEquals(c1.Priority, '5');
    }
    @isTest
    public static void testappCustomWrapListMthd(){
        List<Map<String, string>> lstCases = new List<Map<String, string>>();
        
        Map<String, string> mapStr = new Map<String, String>();
        mapStr.put('key', 'Priority__c');
        mapStr.put('value', '1');
        lstCases.add(mapStr);
        
        Map<String, string> mapStr1 = new Map<String, String>();
        mapStr1.put('key', 'Member_Type__c');
        mapStr1.put('value', 'Seeker');
        lstCases.add(mapStr1);
        
        Map<String, string> mapStr2 = new Map<String, String>();
        mapStr2.put('key', 'Priority__c');
        mapStr2.put('value', '1');
        lstCases.add(mapStr2);
        
        Map<String, string> mapStr3 = new Map<String, String>();
        mapStr3.put('key', 'Member_Account_Type__c');
        mapStr3.put('value', 'Basic');
        lstCases.add(mapStr3);
        
        Map<String, string> mapStr4 = new Map<String, String>();
        mapStr4.put('key', 'Support_Skill__c');
        mapStr4.put('value', 'MC: EN Tier 1');
        lstCases.add(mapStr4);
        
        Map<String, string> mapStr5 = new Map<String, String>();
        mapStr5.put('key', 'Member_Language__c');
        mapStr5.put('value', 'English');
        lstCases.add(mapStr5);
        
        
        mcCaseManualPrioritization.appCustomWrapListMthd(lstCases);
    }
    @isTest
    public static void testupdatePriority(){
        List<Case> lstCases = [Select id , priority from case where  Subject ='MemberCare Case 1'];
        List<Id> caseIds = new List<id>();
        for(case cs: lstCases){
            system.assertEquals(cs.Priority, '1');
            caseIds.add(cs.id);
        }
        String priority = '5';
        mcCaseManualPrioritization.updatePriority(caseIds, priority);
        List<Case> updCases = [Select id , priority from case where  Subject ='MemberCare Case 1'];
        for(case cs: updCases){
            system.assertEquals(cs.Priority, '5');
        }
    }
    
        
    
    
}