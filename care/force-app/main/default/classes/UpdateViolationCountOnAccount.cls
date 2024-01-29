/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli
** Developer:     Sridhar Neeli, Developer [sridhar.neeli@nbostech.com]
** Created Date:  09.04.2017
** =================================================================================
** Description: 
                Refresh Violation Level count on account which happened in last 365 days.
** _______________________________________________________________________________
*/
global with sharing class UpdateViolationCountOnAccount{
public Account accountObj{get;set;}
public Id accountId{get;set;}
    public UpdateViolationCountOnAccount(ApexPages.StandardController stdController) {
        this.accountObj= (Account)stdController.getRecord();
        this.accountId=accountObj.id;
    }

//WebService static String UpdateViolationSumsOnAccount(Id accountId)
public void UpdateViolationSumsOnAccount()
    {
    try
    {
        if(accountObj!=null)
        {
            Integer automaticFailCount=database.countQuery('SELECT count()  FROM Infraction__c where BUC_Center_Name__c=:accountId and Violation_Level__c=\'Automatic Fail\' and Violation_Date__c = LAST_N_DAYS:365 LIMIT 50000');
            Integer critialCount=database.countQuery('SELECT count()  FROM Infraction__c where BUC_Center_Name__c=:accountId and Violation_Level__c=\'Critical\' and Violation_Date__c = LAST_N_DAYS:365 LIMIT 50000');
            Integer subCriticalCount=database.countQuery('SELECT count()  FROM Infraction__c where BUC_Center_Name__c=:accountId and Violation_Level__c=\'Sub-Critical\' and Violation_Date__c = LAST_N_DAYS:365 LIMIT 50000');
                 
            Account accObj=[select id,Sum_of_Automatic_Fail_Violations__c,Sum_of_Critical_Violations__c,Sum_of_Sub_Critical_Violations__c,Violation_Sum_Counted_Date__c from Account where id=:accountId];
            if(automaticFailCount>0)
            accObj.Sum_of_Automatic_Fail_Violations__c=automaticFailCount;
            else 
            accObj.Sum_of_Automatic_Fail_Violations__c = null;
            
            if(critialCount>0)
            accObj.Sum_of_Critical_Violations__c=critialCount;
            else 
             accObj.Sum_of_Critical_Violations__c=null;
             
            if(subCriticalCount>0)
            accObj.Sum_of_Sub_Critical_Violations__c=subCriticalCount;
            else 
            accObj.Sum_of_Sub_Critical_Violations__c=null;
            
            accObj.Violation_Sum_Counted_Date__c =System.now();
    
            update accObj;
            }

        }catch(Exception e){System.debug('An exception has occured while counting violation sums ==>:'+e.getMessage()); }
         //PageReference stdAccPage= new PageReference('/'+accountId);
        //stdAccPage.setRedirect(true);
        //return stdAccPage; 
    }
}