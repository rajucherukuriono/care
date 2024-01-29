public class CountryLocaleMapHelper {
	/* This class should be used to access the Sterling Country Settings Map. 
	 * The class keeps a copy of the map & helper methods by which to access specific records
    
	*/

    public static List<Sterling_Country_Setting__mdt> CountryLocaleMap = [SELECT Country_Code__c, Case_Origin__c, Language__c, Locale__c, Production_URL_Root__c,Staging_URL_Root__c,User_Name__c,Password__c,QA_Email__c,Login__c,Upgrade__c,Join_Now__c,Apply_to_Jobs__c  FROM Sterling_Country_Setting__mdt];

    public static Sterling_Country_Setting__mdt getSettingByCaseOrigin(String CaseOrigin){
        for (Sterling_Country_Setting__mdt s : CountryLocaleMap){
			if (s.Case_Origin__c == CaseOrigin) return s;
        }
		return null;        
    }
    
    @AuraEnabled(cacheable=true)
    public static Sterling_Country_Setting__mdt getSettingByLocale(String locale){
        for (Sterling_Country_Setting__mdt s : CountryLocaleMap){
			if (s.Locale__c == locale) return s;
        }
		return null;        
    }
    
    public static Sterling_Country_Setting__mdt getSettingByCountry(String CountryCode){
		// multiple countries are alloweed in the table, but their records are interchangeable, so we return the first one we find
        for (Sterling_Country_Setting__mdt s : CountryLocaleMap){
			if (s.Country_Code__c == CountryCode) return s;
        }
		return null;        
    }

    public static String getLanguageFromLocale(String Locale){
        for (Sterling_Country_Setting__mdt s : CountryLocaleMap){
            if (s.Locale__c == Locale) return s.Language__c;
        }
        return null;
    }

    public static String getCaseOriginFromLocale(String Locale){
        for (Sterling_Country_Setting__mdt sc: CountryLocaleMap){
            if (sc.Locale__c == Locale) return sc.Case_Origin__c;
        }
        return null;
    }

    public static String getQAEmail(String Locale){
        for (Sterling_Country_Setting__mdt sc: CountryLocaleMap){
            if (sc.Locale__c == Locale) return sc.QA_Email__c;
        }
        return null;
        
    }

}