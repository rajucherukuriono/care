@isTest(SeeAllData=false)
private class Test_BatchGDPRMemberRequestCount{
    private static ID seekerRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    private static ID safetyAlertRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Safety Alert').getRecordTypeId();
    @isTest(SeeAllData=false)
    static void test() 
    {        
        Account a=new Account(lastname='Test',Gdpr_request__c='RTBF',recordtypeid=seekerRecId);
        insert a;
        Account a2=new Account(lastname='Test',Gdpr_request__c='GDPR',recordtypeid=seekerRecId);
        insert a2;
        Case caseObj1=new Case(subject='Test Subject',accountid=a.id,recordtypeid=safetyAlertRecId);
        Case caseObj2=new Case(subject='Test Subject',accountid=a.id,recordtypeid=safetyAlertRecId);
        insert new List<Case>{caseObj1,caseObj2};
        Test.startTest();
        //Database.executeBatch(new BatchGDPRMemberRequestCount(true));
        List<User> userList=[select id,firstname,lastname,email,name,username from user where email in ('mohammed.ashwaq@care.com')];
        List<Process_Control_Settings__mdt> pcsm = [select id,DeveloperName,MasterLabel,Process_Name__c,Switch__c from Process_Control_Settings__mdt where Process_Name__c in ('GDPR Fail Over','Intl Retention Fail Over')];
        System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,200);
        //System.schedulebatch(new BatchGDPRMemberRequestCount(true,userList),'GDPR Count',1,200);
        ProcessGDPRCount.processGDPRCount('mohammed.ashwaq@care.com, ramaganesh.guttula@care.com');
        GDPRFailoverHandler gdpfoh = new GDPRFailoverHandler();
        Test.stopTest();
    }    
}