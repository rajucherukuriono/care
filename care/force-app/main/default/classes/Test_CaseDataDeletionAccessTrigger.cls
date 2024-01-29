@isTest(SeeAllData=true)
private class Test_CaseDataDeletionAccessTrigger{
    
    static testMethod void CheckServiceAgreement(){   
        Test.startTest();
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
        String intlSafetyAlertRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
        Account a1=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a1;
        
        Case c1=new Case(accountid=a1.id,Recordtypeid=intlSafetyAlertRecId,Status='Cleared');
        insert c1;

        
        Test.stopTest();
        
    }
    @isTest(SeeAllData=true)
    static void testCaseDataDeletion() 
    {
        List<Data_Deletion_Rules__mdt> ddrList=[SELECT DeveloperName,Error_Message__c,Id,Label,Language,MasterLabel,NamespacePrefix,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where sobject_name__c='Case'];
        
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
        String intlSafetyAlertRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
        
        Account a=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
        delete a;
        Account a1=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a1;
        
        Case c1=new Case(accountid=a1.id,Recordtypeid=intlSafetyAlertRecId,Status='Cleared');
        insert c1;
      //  delete c1;
        
    }
    @isTest(SeeAllData=true)
    static void testStandardAccountDeletion() 
    {
        List<Data_Deletion_Rules__mdt> ddrList=[SELECT DeveloperName,Error_Message__c,Id,Label,Language,MasterLabel,NamespacePrefix,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where sobject_name__c='Case'];
        
        String liteRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Lite');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
        String intlSafetyAlertRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
        
        Account a=new Account(lastname='testNormal',recordtypeid=liteRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a;
       // delete a;

        
        Case c1=new Case(accountid=a.id,Recordtypeid=intlSafetyAlertRecId,Status='Cleared');
        insert c1;
        delete c1;
        
    }
        @isTest(SeeAllData=true)
    static void testCaseIntlSafetyCaseDeletion() 
    {
        List<Data_Deletion_Rules__mdt> ddrList=[SELECT DeveloperName,Error_Message__c,Id,Label,Language,MasterLabel,NamespacePrefix,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where sobject_name__c='Case'];
        System.debug('ddrList==>:'+ddrList);
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
        String intlSafetyAlertRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Safety Alert');
        Account a1=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk');
        insert a1;
        
        Case c1=new Case(accountid=a1.id,Recordtypeid=intlSafetyAlertRecId,Status='Cleared');
        insert c1;
        delete c1;
        
    }
            @isTest(SeeAllData=true)
    static void testCaseUSSafetyCaseDeletion() 
    {
        List<Data_Deletion_Rules__mdt> ddrList=[SELECT DeveloperName,Error_Message__c,Id,Label,Language,MasterLabel,NamespacePrefix,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where sobject_name__c='Case'];
        System.debug('ddrList==>:'+ddrList);
        String seekerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Seeker');
        String providerRecId=getRecordTypesStatic.recordTypeNameIdMap.get('International Provider');
        String usSafetyAlertRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert');
        Account a1=new Account(lastname='testNormal',recordtypeid=seekerRecId,Global_Member_Id__c='12345678',personEmail='sridhar.neeli@care.com',locale__pc='uk'); 
        insert a1;
        
        Case c1=new Case(accountid=a1.id,Recordtypeid=usSafetyAlertRecId,Status='Cleared');
        insert c1;
        delete c1;
        
    }
}