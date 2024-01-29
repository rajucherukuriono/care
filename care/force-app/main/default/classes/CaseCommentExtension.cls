/* 
* Created by: Eustace Consulting [www.eustaceconsulting.com][Developer: Jennifer Blair] 
* Description: Controller for the Close Case publisher action (closeCase.page). This controller uses OnLoadController.cls
* for the logic of determining the next case.
** Modified by:   Md Ashwaq
** Developer:     Sridhar Neeli, Software Developer [sridharn@nbostech.com], mohammed Ashwaq
** Modified Date:  05.24.2016
** Modified Date:  10.17.2016
** Modified Date: 05-03-2021
** Description: Provided an optional checkbox for the user while closing a case using Case Quick Actions so that if checked 
** all it's associated cases also will be deleted along with current case.
** Commented code as part of SFORCE-1133, SFORCE-3711
*/
public with sharing class CaseCommentExtension {
    public Case TheCase {get; set;}
    public boolean displayError {get; set;}
    public boolean displayValError {get; set;}
    public string nextCaseId {get; set;}
    public string nextCaseName {get; set;}
    public caseComment Comment {get; set;}
    public boolean isInternationalCase  {get; set;}
    public boolean SendCancellationEmailUserInput{get;set;}
    public boolean tryAgain  {get; set;}
    public boolean deleteAcceptance{get;set;}
	public String uiThemeDisplayed {get;set;}
    public Map<id,Case> childCaseMap{get;set;}
    public boolean hasChildCases{get;set;}
	public String exceptionMsg = 'Unable to close the case. Please wait a few moments and try again.';
String Cancel_and_Downgrade_Require_Action_Time ='When Cases are closed with Cancel or Downgrade Checkbox Checked, an Action Time (indicating when to close the account in Smithers) must also be provided.';
String Contact_Reasons_Required_to_Close_a_Case = 'Closed cases require a Contact Theme,Contact Reason,Contact Secondary Reason and Sentiment.';
String Contact_Reasons_Required_to_Appeal_Decison = 'Closed cases require a "Appeal Decision" and "Appeal Decision Reason" when Contact Theme is Blocklist Appeal';   
String Please_select_either_Cancel_Or_Downgrade = 'You cannot Cancel and Downgrade a member at the same time. Please only check one of these boxes.';
String caseCommentValMsg = 'Case Comment is required when either Contact Reason or Contact Secondary Reason selected as \'Other\' or Escalated checkbox is checked.';
String If_Case_Bug_is_checked_few_fields_r_must='If bug is true, bug summary and actions taken are mandatory.';
    public void DefaultsForCancelOrDowngrade(){
        // Set Defaults for SendCancellationEmailUserInput 
        // For Premiums when Case it Set to Cancel or Downgrade it should be true; otherwise false
        if (TheCase.Member_Account_Type__c == 'Premium'){  //Premium
            if (TheCase.Cancel__c== True || TheCase.Downgrade__c == True) SendCancellationEmailUserInput = true;
        }
        else SendCancellationEmailUserInput = TheCase.Send_Cancellation_Email__c;
    }    
    public CaseCommentExtension(ApexPages.StandardController controller) {
		uiThemeDisplayed = UserInfo.getUiThemeDisplayed();
        TheCase = (Case) controller.getRecord();
        tryAgain = false;
        isInternationalCase = isInternationalCase();
        Comment = new CaseComment(parentId = TheCase.Id);
        childCaseMap=new Map<id,Case>([SELECT ID, Reason,Secondary_Case_Reason__c,Contact_Reason__c,Contact_Secondary_Reason__c,Current_Member_Type__c,Cancel__c,Downgrade__c,Member_Account_Type__c,Appeal_Decision__c,Appeal_Decision_Reason__c FROM CASE WHERE ParentID =:TheCase.ID]);
        hasChildCases = childCaseMap.keySet().size()>0;
        deleteAcceptance = true;
        DefaultsForCancelOrDowngrade();
    }
    public PageReference ValidateAndClose(){
        pageReference retPage = null;
        displayValError = false;
        try{
			if(comment.commentBody==null && (theCase.IsEscalated || (theCase.Contact_Reason__c=='Other' || theCase.Contact_Secondary_Reason__c=='Other'))){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,caseCommentValMsg));
			}
			else if(thecase.Bug__c == True && (thecase.Actions_Taken__c==null || thecase.Bug_Summary__c==null)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,If_Case_Bug_is_checked_few_fields_r_must));
			}
			else if(thecase.Cancel__c && theCase.Downgrade__c){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Please_select_either_Cancel_Or_Downgrade));
			}
			else if((theCase.Cancel__c==True || theCase.Downgrade__c==True) && thecase.Action_Time__c==null && (getRecordTypesStatic.recordTypeNameIdMap.get('International Email')==thecase.recordTypeId || getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center')==thecase.recordTypeId || getRecordTypesStatic.recordTypeNameIdMap.get('Social Media International')==thecase.recordTypeId)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Cancel_and_Downgrade_Require_Action_Time));
			}
			else if (theCase.Contact_Theme__c !='Blocklist Appeal'){
				if(theCase.Contact_Theme__c==null || theCase.Contact_Reason__c==null || theCase.Contact_Secondary_Reason__c==null || theCase.Sentiment__c==null)  {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Contact_Reasons_Required_to_Close_a_Case));
				}
				else { 
					closeChildCases();
				}     
			}
		    else if (theCase.Contact_Theme__c =='Blocklist Appeal'){                 
			   if (theCase.Appeal_Decision__c==null || theCase.Appeal_Decision_Reason__c==null) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Contact_Reasons_Required_to_Appeal_Decison));
			   }
			   else {  
					closeChildCases();
			   }  
			}    
			else {				
				closeChildCases();
			}
            return new PageReference('/'+TheCase.Id);
        }
        catch(Exception ex){
            //ApexPages.addMessages(ex);
            displayValError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exceptionMsg));
            if(CareDotComUtil.runningInASandbox())
             System.debug('ERROR: '+ ex);
        }
        return retPage;
    }
	public PageReference ValidateAndCloseAndNext(){
        pageReference retPage = null;
        displayValError = false;
        System.debug('theCase.Action_Time__c==>:'+theCase.Action_Time__c);
        try{
         /*   if(comment.commentBody==null && (theCase.IsEscalated || (theCase.Contact_Reason__c=='Other' || theCase.Contact_Secondary_Reason__c=='Other')))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,caseCommentValMsg));
            }
            //else if(thecase.Bug__c == True && (thecase.Actions_Taken__c==null || thecase.Browsers_and_Versions__c==null || thecase.Bug_Summary__c==null || thecase.Jira_Number__c==null))
            else if(thecase.Bug__c == True && (thecase.Actions_Taken__c==null || thecase.Bug_Summary__c==null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,If_Case_Bug_is_checked_few_fields_r_must));
            }
            else if(thecase.Cancel__c && theCase.Downgrade__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Please_select_either_Cancel_Or_Downgrade));
            }
            else if((theCase.Cancel__c==True || theCase.Downgrade__c==True) && thecase.Action_Time__c==null  &&
				(getRecordTypesStatic.recordTypeNameIdMap.get('International Email')==thecase.recordTypeId  ||
				getRecordTypesStatic.recordTypeNameIdMap.get('International Call Center')==thecase.recordTypeId ||
				getRecordTypesStatic.recordTypeNameIdMap.get('Social Media International')==thecase.recordTypeId))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Cancel_and_Downgrade_Require_Action_Time));
            }
            else if(theCase.Contact_Theme__c==null || theCase.Contact_Reason__c==null || theCase.Contact_Secondary_Reason__c==null || theCase.Sentiment__c==null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Contact_Reasons_Required_to_Close_a_Case));
            }
            else {                
                closeChildCases();
                onLoadController nextCasectrlr = new OnLoadController();
                nextCasectrlr.returnLink();
                displayError=nextCasectrlr.dispError;
                tryAgain=nextCasectrlr.tryAgain;
                NextcaseId = nextCasectrlr.TheFinalCase.Id;
                NextcaseName = nextCasectrlr.TheFinalCase.CaseNumber;  
            }
			*/
        }
        catch(Exception ex){
           /*
             //ApexPages.addMessages(ex);
            displayValError = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exceptionMsg));
            if(CareDotComUtil.runningInASandbox())
            System.debug('ERROR: '+ ex);
			*/
        }
        return retPage;
    }
    public string getActionTimeValue() {
        system.debug('getActionTimeValue************'+theCase.Action_Time__c);
        //  Set's the Case's Action Value according to the PM requirements
        String newActionTimeValue = null;
        //Commenting the below code as part of SFORCE-1133
        /*
        if (theCase.Member_Account_Type__c == 'PendingActive' && theCase.Member_Status__c == 'Open') newActionTimeValue = 'Now';
        else 
        */
        newActionTimeValue = theCase.Action_Time__c;  // in other words, the value from the UI 
        if(CareDotComUtil.runningInASandbox()){
            System.Debug('newActionTimeValue (at exit): ' + newActionTimeValue);
            System.Debug('Member_Account_Type__c ' + theCase.Member_Account_Type__c);
            System.Debug('Member_Status__c ' + theCase.Member_Status__c);
        }        
        return newActionTimeValue;
    }
    public boolean isInternationalCase() {
        return CareDotComUtil.isInternationalCase(TheCase);
	}
    public void closeChildCases(){
        theCase.status = 'Closed';
        theCase.Action_Time__c = getActionTimeValue();
        theCase.Send_Cancellation_Email__c = SendCancellationEmailUserInput==null?False:SendCancellationEmailUserInput;
        update theCase;
        if(comment.commentbody != null){                
            comment = new CaseComment(parentId = TheCase.Id, commentBody=comment.commentBody);
            insert comment;
        } 
    }
}