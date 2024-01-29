@isTest
public class Test_CustomClone{
@isTest static void test1(){

             
        Case c1= new Case();
        c1.Status ='New';
        c1.Priority = 'Medium'; 
        c1.Origin = 'Email';
        c1.Reason='Site Usage';
        c1.Secondary_Case_Reason__c = 'Login Trouble';
        c1.recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        insert c1;
        c1.status = 'In Progress';
        update c1;
      ApexPages.StandardController caseControl = new ApexPages.StandardController(c1);
      CustomClone testCase = new CustomClone(caseControl);
      testCase.newRecordId = c1.Id;
     
      testCase.cloneCase();
  }
}