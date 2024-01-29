/*
** _________________________________________________________________________________
** Created by:    NBOS Technologies [www.nbostechnologies.com]
** Developer:     SRIDHAR NEELI, SFDC Tech Lead [sridhar.neeli@care.com]
** Created Date:  03.20.2018
** Modified by:   NBOS Technologies [http://nbostechnologies.com/]
** Modified Date: 03.29.2016
** =================================================================================
** Description: 
**            Created as part of 'SFORCE-1757 HomePay 1st time referring contact report'
**            JIRA. It provides a button provided on contact list view, iterate through all 'Home Pay Business Contact' records and note down the first closed opportunity with the given criteria. 
**            ============================================= 
**            Opportunity : 
**            Record Type: HomePay Referral 
**            Product Type: 'Authorized Contact' or 'Referral' 
**            Stage: Closed Won 
**            ============================================== 
**            Contact Role (Contact): 
**            Record Type: Homepay Business Contact 
**            =============================================
** _______________________________________________________________________________
*/
global class HomePay1stTimeReferringContactReport
{
    webservice static void setHomePay1stTimeReferringContactReport()
    {
        Set<id> oppSet=new Set<id>();
        Map<id,Contact> contACUpdateMap=new Map<id,Contact>();
        Map<id,Contact> contRefUpdateMap=new Map<id,Contact>();
        Set<Id> acContSet=new Set<Id>();
        Set<Id> refContSet=new Set<Id>();
        Map<id,OpportunityContactRole> contIdOppACSet=new Map<id,OpportunityContactRole>();
        Map<id,OpportunityContactRole> contIdOppRefSet=new Map<id,OpportunityContactRole>();
        List<OpportunityContactRole> oppACContRoleList=null;
        List<OpportunityContactRole> oppRefContRoleList=null;
        /*
        if(cont!=null)
        oppContRoleList=[SELECT Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where contactId=:cont.id and Opportunity.Product_Type__c  in('Authorized Contact','Referral') and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
        else if(opp!=null)
        oppContRoleList=[SELECT Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where opportunityId=:opp.id and Opportunity.Product_Type__c  in('Authorized Contact','Referral') and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
        else
        */
                oppACContRoleList=[SELECT Opportunity.Name,Opportunity.Product_Type__c, Contact.Name,Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where Opportunity.Product_Type__c='Authorized Contact' and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
                oppRefContRoleList=[SELECT Opportunity.Name,Opportunity.Product_Type__c, Contact.Name,Opportunity.CloseDate,Opportunity.Date_Time_Closed__c,ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where Opportunity.Product_Type__c='Referral' and Opportunity.StageName='Closed Won' and Opportunity.RecordType.Name='HomePay Referral' and Contact.RecordType.Name='Homepay Business Contact' order by Opportunity.closeDate asc];
        for(OpportunityContactRole oppContRoleObj:oppACContRoleList)
        {   
            
            //oppSet.add(oppContRoleObj.opportunityId);
            //oppSet.add(oppContRoleObj.opportunityId);
            if(contIdOppACSet.get(oppContRoleObj.contactId)==null)
            {
                contIdOppACSet.put(oppContRoleObj.contactId,oppContRoleObj);
                acContSet.add(oppContRoleObj.contactId);
                
            }
            }
        for(OpportunityContactRole oppContRoleObj:oppRefContRoleList)
        {   
         
            if(contIdOppRefSet.get(oppContRoleObj.contactId)==null)
            {
                contIdOppRefSet.put(oppContRoleObj.contactId,oppContRoleObj);
                refContSet.add(oppContRoleObj.contactId);
                
            }
            /*
            else
            {
            contIdOppSet.get(oppContRoleObj.contactId).add(oppContRoleObj.opportunityId);
            }
            */
        }
        
        Map<id,Contact> acContMap=new Map<id,Contact>([SELECT ID,X1stTimeReferringOpportunityACCloseDate__c,X1stTimeReferringACOpportunityID__c,X1stTimeReferringACOpportunityName__c,X1stTimeReferringContactName__c from Contact where id=:acContSet]);

        
        for(Contact contObj:acContMap.values())
        {
            if(contIdOppACSet.get(contObj.id)!=null && contIdOppACSet.get(contObj.id).Opportunity!=null)
            {
                //if(contIdOppSet.get(contObj.id).Opportunity.Product_Type__c=='Authorized Contact' && (contObj.X1stTimeReferringOpportunityACCloseDate__c==null || contObj.X1stTimeReferringACOpportunityID__c==null || contObj.X1stTimeReferringACOpportunityName__c==null || contObj.X1stTimeReferringContactName__c==null))
                //if(contIdOppACSet.get(contObj.id).Opportunity.Product_Type__c=='Authorized Contact')
                if(contIdOppACSet.get(contObj.id).Opportunity.Product_Type__c=='Authorized Contact' && (contObj.X1stTimeReferringOpportunityACCloseDate__c==null || contObj.X1stTimeReferringACOpportunityID__c==null || contObj.X1stTimeReferringACOpportunityName__c==null))
                {
                    if(contACUpdateMap.get(contObj.id)==null) contACUpdateMap.put(contObj.id,contObj);
                    
                    contACUpdateMap.get(contObj.id).X1stTimeReferringOpportunityACCloseDate__c=contIdOppACSet.get(contObj.id).Opportunity.CloseDate;
                    contACUpdateMap.get(contObj.id).X1stTimeReferringACOpportunityID__c=contIdOppACSet.get(contObj.id).Opportunity.Id;
                    contACUpdateMap.get(contObj.id).X1stTimeReferringACOpportunityName__c=contIdOppACSet.get(contObj.id).Opportunity.Name;
                    contACUpdateMap.get(contObj.id).X1stTimeReferringContactName__c=contIdOppACSet.get(contObj.id).Contact.Name;                    

                }
              }
            }
            
             if(contACUpdateMap.keySet().size()>0)
            update contACUpdateMap.values();
            
            
        Map<id,Contact> refContMap=new Map<id,Contact>([SELECT ID,X1stTimeReferringContactName__c,X1stTimeReferringOpportunityRefCloseDate__c,X1stTimeReferringRefOpportunityID__c,X1stTimeReferringRefOpportunityName__c from Contact where id=:refContSet]);
            
        for(Contact contObj:refContMap.values())
        {
              if(contIdOppRefSet.get(contObj.id)!=null && contIdOppRefSet.get(contObj.id).Opportunity!=null)
            {
                //if(contIdOppSet.get(contObj.id).Opportunity.Product_Type__c=='Referral' && (contObj.X1stTimeReferringOpportunityRefCloseDate__c==null || contObj.X1stTimeReferringRefOpportunityID__c==null || contObj.X1stTimeReferringRefOpportunityName__c==null || contObj.X1stTimeReferringContactName__c==null))
                //if(contIdOppRefSet.get(contObj.id).Opportunity.Product_Type__c=='Referral')
                if(contIdOppRefSet.get(contObj.id).Opportunity.Product_Type__c=='Referral' && (contObj.X1stTimeReferringOpportunityRefCloseDate__c==null || contObj.X1stTimeReferringRefOpportunityID__c==null || contObj.X1stTimeReferringRefOpportunityName__c==null))
                {
                    if(contRefUpdateMap.get(contObj.id)==null) contRefUpdateMap.put(contObj.id,contObj);
                    contRefUpdateMap.get(contObj.id).X1stTimeReferringOpportunityRefCloseDate__c=contIdOppRefSet.get(contObj.id).Opportunity.CloseDate;
                    contRefUpdateMap.get(contObj.id).X1stTimeReferringRefOpportunityID__c=contIdOppRefSet.get(contObj.id).Opportunity.Id;
                    contRefUpdateMap.get(contObj.id).X1stTimeReferringRefOpportunityName__c=contIdOppRefSet.get(contObj.id).Opportunity.Name;
                    contRefUpdateMap.get(contObj.id).X1stTimeReferringContactName__c=contIdOppRefSet.get(contObj.id).Contact.Name;    
                }
            }
        
        }
        

            
           if(contRefUpdateMap.keySet().size()>0)
            update contRefUpdateMap.values();
    }
 }