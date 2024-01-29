/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.com]
** Modified Date:  03.26.2019
** =================================================================================
** Description: 
**             This is written as part of SFORCE-2041 Safety Next Case requiremet.
**             This is the Controller for buttons 'Next Safety Case','Close And Next Safety Case' buttons on 
**             'US Safety Alert Case Feed Layout'  case layout.  
**             Only 'Q: Safety Alert' cases are assigns to users upon clicking on the button.
** _______________________________________________________________________________
*/
public with sharing class SafetyCloseNextCase {
    
    public Case TheCase {get; set;}
    
    public boolean tryAgain {get; set;}
    
    public boolean displayError {get; set;}
    
    public boolean displayValError {get; set;}
    
    public string nextCaseId {get; set;}
    
    public string nextCaseName {get; set;}
    
    public caseComment Comment {get; set;}
    
    public boolean isInternationalCase  {get; set;}
    
    public Map<id,Case> childCaseMap{get;set;}
    
    public boolean hasChildCases{get;set;}
    
    public boolean deleteAcceptance{get;set;}
    
    public String exceptionMsg{get;set;}
    

    
    public SafetyCloseNextCase(ApexPages.StandardController controller) {
        TheCase = (Case) controller.getRecord();
        
        exceptionMsg='';
        
        isInternationalCase = isInternationalCase();
        
        Comment = new CaseComment(parentId = TheCase.Id);
        
        childCaseMap=new Map<id,Case>([SELECT ID,Reason,Secondary_Case_Reason__c,Current_Member_Type__c  FROM CASE WHERE ParentID =:TheCase.ID]);
        
        hasChildCases = childCaseMap.keySet().size()>0;
        
        deleteAcceptance = true;
    }
    
    public PageReference ValidateAndClose(){

        pageReference retPage = null;
        displayValError = false;
        exceptionMsg='';
        try{
            if(comment.commentbody != null){
                insert comment;
                comment = new CaseComment(parentId = TheCase.Id);
            }
            closeChildCases();
        }
        catch(Exception ex){
            //ApexPages.addMessages(ex);
            displayValError = true;
        exceptionMsg=ex.getMessage();
             if(CareDotComUtil.runningInASandbox())
             System.debug('ERROR: '+ ex);
        }
        return retPage;
    }
    
    public PageReference ValidateAndCloseAndNext(){
        pageReference retPage = null;
        displayValError = false;
        exceptionMsg='';
            try{
            if(comment.commentbody != null){
                insert comment;
                comment = new CaseComment(parentId = TheCase.Id, commentbody = null);
            }
            closeChildCases();
            NextSafetyCaseUSController nextCasectrlr = new NextSafetyCaseUSController();
            nextCasectrlr.returnLink();
            displayError=nextCasectrlr.dispError;
            tryAgain=nextCasectrlr.tryAgain;
            NextcaseId = nextCasectrlr.TheFinalCase.Id;
            NextcaseName = nextCasectrlr.TheFinalCase.CaseNumber;            
        }
        catch(Exception ex){
            //ApexPages.addMessages(ex);
            displayValError = true;
            exceptionMsg=ex.getMessage();
            if(CareDotComUtil.runningInASandbox())
                System.debug('ERROR: '+ ex);
        }
        if(CareDotComUtil.runningInASandbox())
            system.debug('Next Case Id: ' + nextcaseId);
        return retPage;
    }
    
     public boolean isInternationalCase() {
    return CareDotComUtil.isInternationalCase(TheCase);
}
 
    public void closeChildCases(){
        theCase.status = 'Closed';
        if(childCaseMap.keySet().size()>0 && deleteAcceptance){
            for(Case childCaseObj:childCaseMap.values()){
                childCaseObj.Reason=TheCase.Reason;
                childCaseObj.Secondary_Case_Reason__c=TheCase.Secondary_Case_Reason__c;
                childCaseObj.Current_Member_Type__c=TheCase.Current_Member_Type__c;
                childCaseObj.status = 'Closed';
            }                
        }
        if(childCaseMap.get(theCase.id)==null)
            childCaseMap.put(theCase.id,theCase);
        
        update childCaseMap.values();
    }
    public boolean getIsQSafetyAlertMember()
    {
        List<GroupMember> grpMember=new List<GroupMember>([Select id from GroupMember where userorgroupid=:UserInfo.getUserId()]);
        return grpMember.isEmpty()?false:true;
    }
    
}