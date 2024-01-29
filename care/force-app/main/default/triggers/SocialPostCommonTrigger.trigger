trigger SocialPostCommonTrigger on SocialPost (After insert) {
   // boolean bypassSocialPostTriggers=Override_Validation_Rules__c.getInstance().Override_Social_Post_Triggers__c;
//if(!bypassSocialPostTriggers)
{   
   /*  if(Trigger.isAfter && Trigger.isInsert)
    {
            SocialPostLastActionDate SocialPostLastActionDateObj=new SocialPostLastActionDate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isBefore,Trigger.isAfter);
            System.enqueueJob(SocialPostLastActionDateObj);  
            //SocialPostLastActionDateObj.processCalculateSocialPostsSLA();
    }*/
}

}