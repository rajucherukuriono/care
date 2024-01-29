@isTest
public class MemberExt_Test {
    
    static testMethod void testMethod1() 
    {
        List<Case> listCases = new List<Case>();
        listCases.add(new Case(Status='Cleared'));
        Test.startTest();
        Test.setCurrentPage(Page.SelectCases);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listCases);
        MemberExt ext = new MemberExt(stdSetController);
        ext.acceptCases();
        System.assertEquals('My Open Cases', ext.listViewOption.getlabel());
        Test.stopTest();
    }
    
     static testMethod void testMethod2() 
    {
        List<Case> listCases = new List<Case>();
        listCases.add(new Case(Status='Cleared'));
        Test.startTest();
        Test.setCurrentPage(Page.SelectCases);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listCases);
        stdSetController.setSelected(listCases);
        System.currentPageReference().getParameters().put('retURL', 'https://google.com');
        MemberExt ext = new MemberExt(stdSetController);
        ext.acceptCases();
        Test.stopTest();
    }
    
}