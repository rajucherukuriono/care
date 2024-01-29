public class MemberExt {
    public List<Case> memList {get;set;}
    private ApexPages.StandardSetController standardController;
    private Set<Id> memIds = new Set<Id>();
    public SelectOption listViewOption {get;set;}
        
    public MemberExt(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        memList = new List<Case>();
        for (Case mem : (List<Case>)standardController.getSelected()){ 
            memIds.add(mem.Id);
        }
        memList = [SELECT Id, OwnerId FROM Case WHERE ID IN: memIds];        
    }
    
     public PageReference acceptCases(){
        for(Case mem : memList){
            mem.OwnerId = System.UserInfo.getUserId();
        }
        update memList;
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null){
            listViewOption = standardController.getListViewOptions()[0];  
            List<SelectOption> listViewOptionList = standardController.getListViewOptions();
            for(SelectOption sOption : listViewOptionList){
                if(sOption.getLabel() == 'My Open Cases'){
                    listViewOption = sOption;
                }                
            }
            PageReference pr = new PageReference('/' + SObjectType.Case.KeyPrefix);            
            pr.getParameters().put('fcf', listViewOption.getValue().left(15));
            return pr;
        }
        PageReference pageRef = new PageReference(retURL);  
        pageRef.setRedirect(true);               
        return pageRef ;
    }
}