@isTest
public class Test_CopyHiddenWebFieldsOnCaseToCustFlds
{
    public static ID homePayRtId = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Privacy');
    public static ID galoreRtId = getRecordTypesStatic.recordTypeNameIdMap.get('Galore Privacy');
    
    @isTest static void copyHiddenWebFieldsOnCaseToCustFields(){
        
        Test.startTest();
        
        Case c1= new Case(Status ='New', Priority = 'Medium', Origin = 'Email',recordtypeid=homePayRtId,SuppliedEmail='abc1@gmail.com',SuppliedName='ABC1');
        Case c2= new Case(Status ='New', Priority = 'Medium', Origin = 'Email',recordtypeid=galoreRtId,SuppliedEmail='abc2@gmail.com',SuppliedName='ABC2');
        insert new List<Case>{c1,c2};
        
        List<Case> caseList = [SELECT id,Name_m__c,Email_m__c,SuppliedName,SuppliedEmail FROM Case where suppliedEmail in ('abc1@gmail.com','abc2@gmail.com')];
        System.assertNotEquals(null,caseList[0].SuppliedName, 'Case Name (m) should not be null');
        System.assertNotEquals(null,caseList[0].SuppliedEmail, 'Case Email (m) should not be null');
        System.assertNotEquals(null,caseList[1].SuppliedName, 'Case Name (m) should not be null');
        System.assertNotEquals(null,caseList[1].SuppliedEmail, 'Case Email (m) should not be null');
        
        Test.stopTest();
        
    }
}