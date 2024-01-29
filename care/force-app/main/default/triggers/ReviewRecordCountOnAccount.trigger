trigger ReviewRecordCountOnAccount on Review__c (before insert,before update) {
/* 
 List<id> vetIds=new List<id>();
         for(Review__c reviewObj:Trigger.new){
         vetIds.add(reviewObj.Vetting_Object__c);
         }
        Map<id,Vetting__c> vetIdAccMap=new Map<id,Vetting__c>([SELECT ID,BUC_Center_Name__c FROM Vetting__c where Id in :vetIds]);
        */
          List<Id> accIdsList=new List<Id>();

 if(Trigger.isBefore && Trigger.isInsert)
 {   
    List<Id> accIdsList=new List<Id>();
    for(Review__c reviewObj:Trigger.new)
    {
     //reviewObj.BUC_Center_Name__c=vetIdAccMap.get(reviewObj.Vetting_Object__c).BUC_Center_Name__c;
    accIdsList.add(reviewObj.BUC_Center_Name__c);
    }
    List<Account> accList=[select id,Review_Record_Count__c from Account where id in:accIdsList];
    for(Account accObj:accList){
    if(accObj.Review_Record_Count__c!=null && accObj.Review_Record_Count__c >=1)
    {
    accObj.Review_Record_Count__c=accObj.Review_Record_Count__c+1;
    }
    else{
    accObj.Review_Record_Count__c=1;
    }
    }

    update accList;
    }
    /*
    else
    
     if(Trigger.isBefore && Trigger.isUpdate){
     for(Review__c reviewObj:Trigger.new)
            {
            reviewObj.BUC_Center_Name__c=vetIdAccMap.get(reviewObj.Vetting_Object__c).BUC_Center_Name__c;
            }
    }
    */
}