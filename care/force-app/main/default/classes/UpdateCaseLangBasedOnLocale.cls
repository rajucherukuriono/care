/*
** _________________________________________________________________________________
** Created by:    NBOS Technologies [http://nbostechnologies.com/]
** Developer:     Sridhar Neeli, SFDC Lead [sridhar.neeli@care.com]
** Created Date:  12.22.2016

** =================================================================================
** Description: 
** Update the Case/Contact Language whenever the Locale is updated
** Context: before insert, before update
** Outcome:  Changes Case.Member_Language__c according to the Locale
*/
public without sharing class UpdateCaseLangBasedOnLocale{
    public static void updateMemberLanguageToCase(Case caseObj)
    {
        if (String.isNotBlank(caseObj.Member_Locale__c))
        {
            // ensure that the language field is blank
            caseObj.Member_Language__c = CareDotComUtil.ConvertLocaleToLanguage(caseObj.Member_Locale__c);
        }
        /*
        else if(caseObj.Member_Locale__c ==null || String.isBlank(caseObj.Member_Locale__c))
        caseObj.Member_Language__c = null;
*/
    }
}