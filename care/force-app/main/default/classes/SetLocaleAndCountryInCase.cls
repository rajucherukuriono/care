public class SetLocaleAndCountryInCase 
{

    public static void main (Case c){
    String caseOrigin=c.Origin;
     if(caseOrigin!=null && caseOrigin.contains(' - Privacy'))
            caseOrigin=caseOrigin.remove(' - Privacy');
 
     if(caseOrigin!=null && caseOrigin.contains(' - Covid'))
            caseOrigin=caseOrigin.remove(' - Covid');
            
     if(caseOrigin!=null && caseOrigin.contains(' - Web'))  
            caseOrigin=caseOrigin.remove(' - Web'); 
        
     if(caseOrigin!=null && caseOrigin.contains(' - Imprint'))
            caseOrigin=caseOrigin.remove(' - Imprint');
 
       /*
        if (c.Origin != null && c.Origin.left(5).ToLowerCase() == 'email'){ // should apply to email origins only
            Sterling_Country_Setting__mdt s = CountryLocaleMapHelper.getSettingByCaseOrigin(c.Origin);
            */
            
            if (caseOrigin != null && caseOrigin.left(5).ToLowerCase() == 'email'){ // should apply to email origins only
            Sterling_Country_Setting__mdt s = CountryLocaleMapHelper.getSettingByCaseOrigin(caseOrigin);
            
            if (s != null){
                if (s.Country_Code__c != 'us'){ // exclude US for now because US doesn't have full multilanguage support
                    c.Member_Locale__c = s.Locale__c;
                    c.Member_Country__c = s.Country_Code__c;
                }
            }
        }
    } 
}