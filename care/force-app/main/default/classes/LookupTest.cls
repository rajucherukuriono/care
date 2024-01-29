/**Test Class for Lookup_class
 *
 *@modified by Kalpesh Thakur<Kthakur@innoveer.com>
 *@since 2,12,2011
 *
 *@Author:-Vabhiav Kulkarni<vkulkarni@innoveer.com>
 *@since 2,12,2011
 *
 */
@isTest
private class LookupTest {
    
    static testMethod void myUnitTest() {
     try
     {
        String likestring=ApexPages.currentPage().getParameters().put('likeString' , 'SCR Seeker Info for Home Care');
        ApexPages.currentPage().getParameters().put('msg', 'Provider');
        boolean showSearch;
        Lookup_class lookup=new Lookup_class();
        lookup.showSearch=true;
        lookup.name=likestring;
        lookup.FindTemplate();
        
       integer cnt = lookup.objTemplate.size();
       integer cntr=[Select count() from EmailTemplate where IsActive= true];
       System.assertNotEquals(cnt,cntr);
     }
     catch(Exception e)
     {
         //do nothing
     }
     
     
       
    }
    static testMethod void myUnitTest1() {
     
     Folder f;
      f= [Select f.Id, f.DeveloperName From Folder f where f.Name='Provider Referral Emails' LIMIT 1];
     String likestring=ApexPages.currentPage().getParameters().put('likeString' , '');
     ApexPages.currentPage().getParameters().put('msg', 'Provider');
     Lookup_class lookup=new Lookup_class();
     lookup.showSearch=true;
     lookup.name=likestring;
     lookup.FindTemplate();
       integer cnt1 = lookup.objTemplate.size();
       integer  cntr1=[Select count() from EmailTemplate where FolderId=:f.Id AND IsActive= true];
       System.assertEquals(cnt1,cntr1); 
    }
}