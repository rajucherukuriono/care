@isTest
public class Test_CopyPersonAccountToContactOnCase{
     @isTest public static void test1(){
        CopyPersonAccountToContactOnCase catab = new CopyPersonAccountToContactOnCase();
   
   
        }
    public static ID safetyRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Safety Alert').getRecordTypeId();
    
    
   @isTest static void StandardCase(){
        // Case Contact should be propagated for Standard Case
        TestUtil.SterlingCreatesBasicProvider_enGB();
        TestUtil.createBasicChildCareSeeker();
        
        Account a1 = [SELECT id,PersonContactId FROM Account WHERE FirstName =: TestUtil.InternationalProviderFirstName];
        Account a2 = [SELECT id,PersonContactId FROM Account WHERE FirstName =: TestUtil.BasicChildCareSeekerFirstName];
        
        Test.startTest();
        Case c1= new Case(Status ='New', Priority = 'Medium', Origin = 'Email',accountId=a1.id,recordtypeid=getRecordTypesStatic.StandardRecordType);
        insert c1;
        c1 = [SELECT id,AccountId,ContactId FROM Case WHERE id =:c1.id];
        System.assertEquals(c1.ContactId, a1.PersonContactId,'Case Contact was not propagated');
        
        c1.AccountId = a2.id;
        update c1;
        
        c1 = [SELECT id,AccountId,ContactId FROM Case WHERE id =:c1.id];
        System.assertEquals(c1.ContactId, a2.PersonContactId,'Case Contact was not propagated');

        c1.AccountId = null;
        update c1;
        Test.stopTest();

        c1 = [SELECT id,AccountId,ContactId FROM Case WHERE id =:c1.id];
        System.assertEquals(null,c1.AccountId, 'Case Account should be null');
        System.assertEquals(null,c1.ContactId, 'Case Contact should be null');
        
    }
    
    @isTest static void SafetyAlertCase(){
        // Case Contact should NOT be propagated for Safety Alert Cases
        TestUtil.SterlingCreatesBasicProvider_enGB();
        TestUtil.createBasicChildCareSeeker();
        
        Account a1 = [SELECT id,PersonContactId FROM Account WHERE FirstName =: TestUtil.InternationalProviderFirstName];
        Account a2 = [SELECT id,PersonContactId FROM Account WHERE FirstName =: TestUtil.BasicChildCareSeekerFirstName];
        
        Test.startTest();
        Case c1= new Case(Status ='New', Priority = 'Medium', Origin = 'Email',accountId=a1.id,recordtypeid=safetyRtId);
        insert c1;
        c1 = [SELECT id,AccountId,ContactId FROM Case WHERE id =:c1.id];
        System.assertEquals(null, c1.ContactId,'Case Contact should be null');
        
        c1.AccountId = a2.id;
        update c1;
        Test.stopTest();
        
        c1 = [SELECT id,AccountId,ContactId FROM Case WHERE id =:c1.id];
        System.assertEquals(null,c1.ContactId,'Case Contact should be null');
    }
    
}