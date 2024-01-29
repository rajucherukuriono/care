@isTest
public class Test_DealSummaryController
{
@isTest
public static void test1()
{
    Account a=new Account(name='TestAccount');insert a;
    Contact cont1=new Contact(lastname='TestAccount',accountid=a.id);insert cont1;
    Opportunity oppObj=new Opportunity(accountid=a.id,name='test opportunity',stageName='New',closeDate=Datetime.now().date());insert oppObj;
    OpportunityContactRole oppContRoleObj=new OpportunityContactRole(opportunityid=oppObj.id,contactid=cont1.id);
insert    oppContRoleObj;
    ApexPages.StandardController dealSummaryStdCtrl= new ApexPages.StandardController(oppObj);
        DealSummaryController testAccPlan = new DealSummaryController (dealSummaryStdCtrl);
        testAccPlan.refreshContDetailsCtrlMethod();testAccPlan.getContacts();
        testAccPlan.saveDealSummary();
        testAccPlan.readOnlyDealSummary();
        testAccPlan.editDealSummary();testAccPlan.existingBusiness();
}
}