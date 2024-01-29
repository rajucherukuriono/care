/***
Created by: Vivek Suryawanshi.
Date:20/1/2012
Description: Called by Trigger when the opportunity is created or updated, in return it gets the Winning provider details and 
roll ups in the respective seeker opportunity records. 
***/

public class updateSeekerOpportunity{

public static void gtAcctDetails(set<id> reqAcctIds, list<opportunity> opptlst)
{
   map<id,Account> winMap2=new map<id,Account>();
   try
   {
     if(!reqAcctIds.isEmpty())
     {
       //get the winning provider details and storing it in map.
       for(Account a:[SELECT Id,Billing_Type__c,Base_Rate_Percent__c,Care_Charge_Percent__c FROM Account WHERE Id IN:reqAcctIds])
       {
         winMap2.put(a.Id,a);
       }
       
       if(!winMap2.isEmpty())
       {
         //iterating through the opportunity list and assigning the winning provider details to valid records.
         for(opportunity o:opptlst)
         {//Verifying the opportunities winning provider validity. 
           if(reqAcctIds.contains(o.Winning_Provider__c))
           {
             //verifying existance of winning provider id in map
             if(winMap2.get(o.Winning_Provider__c)!=Null)
             {
              //Assigning the winning provider details to related seeker opportunity.
               o.Billing_Type__c=winMap2.get(o.Winning_Provider__c).Billing_Type__c;
               o.Base_Rate_Per__c=winMap2.get(o.Winning_Provider__c).Base_Rate_Percent__c;
               o.Care_Charge_Per__c=winMap2.get(o.Winning_Provider__c).Care_Charge_Percent__c;
             }
           }
         }
       }
     }  
   }Catch(Exception e){
    System.debug('*************************Error in updateSeekerOpportunity class:'+e);
   }
}

}