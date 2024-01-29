trigger SyncLocaleToLanguageInAccount on Account (before insert, before update) {
    // Update the Contact Language whenever the Locale is updated; applies to all Accounts; if we need to apply only to international, use globalmemberid
    //      Context: before insert, before update
    //      Outcome:  Changes Account.Language__pc according to the Locale
    boolean bypassAccountTriggers=Override_Validation_Rules__c.getInstance().Override_Account_Triggers__c;
if(!bypassAccountTriggers)
{
    for (Account c: Trigger.new){
    
       if (String.isNotBlank(c.Locale__pc) && IsLocaleNewOrChanged(c))
        {
                c.Language__pc = CareDotComUtil.ConvertLocaleToLanguage(c.Locale__pc);
        }  
        else if(String.isBlank(c.Locale__pc))
            c.Language__pc = null;         
    }
    
   } 
    private static boolean IsLocaleNewOrChanged(Account c){
        // on insert: check whether a locale is not blank; on update, check whether locale has changed
        if (Trigger.isInsert) return true;
        else if (Trigger.isUpdate){
            Account oldC = Trigger.oldMap.get(c.id);
            if (c.Locale__pc != oldC.Locale__pc){
                return true;
            }           
        }
    return false;       
    } 
  
}




/*
trigger SyncLocaleToLanguageInAccount on Account (before insert, before update) {
    // Update the Contact Language whenever the Locale is updated; applies to all Accounts; if we need to apply only to international, use globalmemberid
    //      Context: before insert, before update
    //      Outcome:  Changes Account.Language__pc according to the Locale
    for (Account c: Trigger.new){
        if (IsLocaleNewOrChanged(c)){
            if (String.isBlank(c.Language__pc)){ // ensure that the language field is blank
                c.Language__pc = CareDotComUtil.ConvertLocaleToLanguage(c.Locale__pc);
                
            }
        }           
    }
    private static boolean IsLocaleNewOrChanged(Account c){
        // on insert: check whether a locale is not blank; on update, check whether locale has changed
        if (Trigger.isInsert && String.isNotBlank(c.Locale__pc)) return true;
        else if (Trigger.isUpdate){
            Account oldC = Trigger.oldMap.get(c.id);
            if (c.Locale__pc != oldC.Locale__pc){
                return true;
            }           
        }
    return false;       
    } 
}
*/