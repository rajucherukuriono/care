@isTest(SeeAllData=false)
private class Test_BUC_VettingViolationReview{
    private static ID BUCNetAgencyRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Agency').getRecordTypeId();
    private static ID BUCNetCenterRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Center').getRecordTypeId();
    private static ID USBUCRtId = Schema.SObjectType.Vetting__c.getRecordTypeInfosByName().get('US BUC Network Vetting').getRecordTypeId();
@isTest(SeeAllData=false)
static void VettingRecordCountOnAccountTest() 
{
 //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType where name IN ('BUC Network Agency', 'BUC Network Center')]);   
    Account a = new Account(Name='TestAccount1',recordTypeId=BUCNetCenterRtId);
    insert a;
    a.Vetting_Record_Count__c=0;
    update a;
    Vetting__c vetObj1=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id, recordTypeId=USBUCRtId);
    insert vetObj1;
       // delete vetObj1;
        Vetting__c vetObj2=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id, recordTypeId=USBUCRtId);
    insert vetObj2;
    //a.Vetting_Record_Count__c=-1;
    //update a;
    //delete vetObj2;
}
@isTest(SeeAllData=false)
static void ViolationRecordCountOnAccountTest1() 
{
 //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType where name IN ('BUC Network Agency', 'BUC Network Center')]);   
    Account a = new Account(Name='TestAccount1',recordTypeId=BUCNetCenterRtId);
    insert a;
    ApexPages.StandardController stdController=new ApexPages.StandardController(a);
    UpdateViolationCountOnAccount uvcOnAccount=new UpdateViolationCountOnAccount(stdController);
    Vetting__c vetObj=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id);
    insert vetObj;
    uvcOnAccount.UpdateViolationSumsOnAccount();
    //Violation Level => Automatic Fail,Critical,Sub-Critical,Medium,Non-Critical
    //Violation Type => Administration,Safety Health,Supervision,Nutrition,Building and Maintenance,No Violations
    Infraction__c violObj1=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Automatic Fail',Violation_Type__c='Administration');
    insert violObj1;
    Infraction__c violObj2=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Automatic Fail',Violation_Type__c='Administration');
    insert violObj2;
    delete violObj1;
    a.Violation_Records_Present__c=0;
    update a;
    delete violObj2;
}
@isTest(SeeAllData=false)
static void ReviewRecordCountOnAccountTest() 
{
 //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType where name IN ('BUC Network Agency', 'BUC Network Center')]);   
    Account a = new Account(Name='TestAccount1',recordTypeId=BUCNetCenterRtId);
    insert a;
    Vetting__c vetObj=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id);
    insert vetObj;
//Review__c reviewObj= new Review__c(Name='Violation Test',BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id);
Review__c reviewObj1= new Review__c(Name='Violation Test',BUC_Center_Name__c=a.id);
insert reviewObj1;
Review__c reviewObj2= new Review__c(Name='Violation Test',BUC_Center_Name__c=a.id);
insert reviewObj2;
}
@isTest(SeeAllData=false)
static void UpdateViolationCountOnAccountTest() 
{
 //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType where name IN ('BUC Network Agency', 'BUC Network Center')]);   
    Account a = new Account(Name='TestAccount1',recordTypeId=BUCNetCenterRtId);
    insert a;
    Vetting__c vetObj=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id);
    insert vetObj;
   //Violation Level => Automatic Fail,Critical,Sub-Critical,Medium,Non-Critical
    //Vi olation Type => Administration,Safety Health,Supervision,Nutrition,Building and Maintenance,No Violations
    Infraction__c violObj1=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Automatic Fail',Violation_Type__c='Administration');
    Infraction__c violObj2=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Critical',Violation_Type__c='Administration');
    Infraction__c violObj3=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Sub-Critical',Violation_Type__c='Administration');
    insert new List<Infraction__c>{violObj1,violObj2,violObj3};
//UpdateViolationCountOnAccount upObj=new UpdateViolationCountOnAccount();
     ApexPages.StandardController sc = new ApexPages.StandardController(a);
     UpdateViolationCountOnAccount upObj=new UpdateViolationCountOnAccount(sc);
    upObj.UpdateViolationSumsOnAccount();
}
/*
@isTest(SeeAllData=false)
static void BatchUpdateViolationCountsOnAllAccountsTest() 
{
 //Map<Id, RecordType> recTypeIds = new Map<Id, RecordType>([Select Id, Name From RecordType where name IN ('BUC Network Agency', 'BUC Network Center')]);   
 List<RecordType> recordTypeList=[select id,name from recordtype where name in ('BUC Network Agency','BUC Network Center')];
    Map<String,id> recMap=new Map<String,id>();
    for(RecordType recObj:recordTypeList)
    {
        recMap.put(recObj.name,recObj.id);
    }
    Account a = new Account(Name='TestAccount1',recordTypeId=recMap.get('BUC Network Center'));
    insert a;
    Vetting__c vetObj=new Vetting__c(Name='Vetting Test',BUC_Center_Name__c=a.id);
    insert vetObj;
   //Violation Level => Automatic Fail,Critical,Sub-Critical,Medium,Non-Critical
    //Vi olation Type => Administration,Safety Health,Supervision,Nutrition,Building and Maintenance,No Violations
    Infraction__c violObj1=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Automatic Fail',Violation_Type__c='Administration');
    Infraction__c violObj2=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Critical',Violation_Type__c='Administration');
    Infraction__c violObj3=new Infraction__c(BUC_Center_Name__c=a.id,Vetting_Object__c=vetObj.id,Violation_Date__c=system.now().date(), Violation_Level__c='Sub-Critical',Violation_Type__c='Administration');
    insert new List<Infraction__c>{violObj1,violObj2,violObj3};
    Test.startTest();
    Database.executeBatch(new BatchUpdateViolationCountsOnAllAccounts(true));    
    Test.stopTest();
}
*/
}