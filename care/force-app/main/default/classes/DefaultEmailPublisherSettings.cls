/*
** _________________________________________________________________________________
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.in]
** Modified Date:  03.18.2019
** =================================================================================
** Description: 
**             This class modifies the to field in the email action(via Case Feed) which stripes out the 
**             invalid text appended by the stering platform.
*/
global class DefaultEmailPublisherSettings implements QuickAction.QuickActionDefaultsHandler {

   
     // Empty constructor
    global DefaultEmailPublisherSettings() {
    }

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
    QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    Id standardRecId = getRecordTypesStatic.recordTypeNameIdMap.get('Standard');
        if(CareDotComUtil.runningInASandbox()) system.debug('defaults: ' + defaults);
		
        
        sendEmailDefaults = getSendEmailDefaults(defaults);

        if (sendEmailDefaults != null) {
            Case c = [SELECT RecordTypeId,Member_Country__c,Origin,SuppliedEmail,Contact.Email,Global_Member_Id__c,accountId,contactId FROM Case WHERE Id=:sendEmailDefaults.getContextId()];

            // Create email message to be customized
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();

            // Implement Default TO logic;  Default TO logic is hardcoded and boils down to:
            // 1) Use Case.SuppliedEmail if provided
            // 2) Otherwise use Contact.Email (if provided)
            // 3) But if Contact.Email has the member id, strip it out
            if (String.isNotBlank(c.Contact.Email))
            {
                emailMessage.ToAddress = StripMemberIdFromEmail(c.Contact.Email,c.Global_Member_Id__c);
            }
            else if (String.isNotBlank(c.SuppliedEmail))
            {
                emailMessage.ToAddress = c.SuppliedEmail;
            } 
             /*** Code Change as part of SFORCE-2451 Req - Automatically CC Web Email, Along With Contact Email, When Sending Email Response ***/
                
                //if(c.recordTypeId==standardRecId && String.isNotBlank(c.suppliedEmail) && emailMessage.ToAddress == c.suppliedEmail && String.isNotBlank(c.contact.Email) && emailMessage.ToAddress != c.contact.Email )
                if(c.recordTypeId==standardRecId && String.isNotBlank(c.suppliedEmail) && String.isNotBlank(c.contact.Email))
                {
                    emailMessage.CcAddress = c.SuppliedEmail;
                }
                
                /**********************************************************************************************************************************/
                
            // Now apply defaults that are inherited from the MetataData Type record
            // First, get Metadata Type record that corresponds with Case details
            Default_Email_Publisher_Setting__mdt mdt = getMdt(c);

            // Set defaults that were defined in the metadata type
            if (mdt != null){
                system.debug('**mdt.Default_From__c*'+mdt.Default_From__c);
                if (String.isNotBlank(mdt.Default_From__c)){
                    emailMessage.FromAddress = mdt.Default_From__c;
                    emailMessage.ValidatedFromAddress = mdt.Default_From__c;
                } 
                if (String.isNotBlank(mdt.Default_CC__c)){
                    if (String.isNotBlank(emailMessage.CcAddress)) emailMessage.CcAddress = mdt.Default_CC__c + '; ' + emailMessage.CcAddress;
                    else emailMessage.CcAddress = mdt.Default_CC__c;
                } 
                
               
                if (String.isNotBlank(mdt.Default_BCC__c)) {
                    if (String.isNotBlank(emailMessage.BccAddress)) emailMessage.BccAddress = mdt.Default_BCC__c + '; ' + emailMessage.BccAddress;
                    else emailMessage.BccAddress = mdt.Default_BCC__c;
                }
                if (String.isNotBlank(mdt.Default_Subject__c)) emailMessage.Subject = mdt.Default_Subject__c;
           }
           
           //if(CareDotComUtil.runningInASandbox()) system.debug('emailMessage: ' + emailMessage);
        }
    }

    global static String StripMemberIdFromEmail(String emailAddress, String memberId){
        // This logic used to remove member ids from emails.  Now it just removes numeric sections at the
        //  end of email addresses preceeded by a period like in the example below.
        //String emailStr='test@care.com.10495783';
        if (emailAddress != null){
            String memIdStrAppended=emailAddress.subString(emailAddress.lastIndexOf('.')+1,emailAddress.length());
            if(memIdStrAppended.isNumeric() && memIdStrAppended.length()>=1){
                emailAddress=emailAddress.removeEnd('.'+memIdStrAppended);
            }
        }
        return emailAddress;
    }
    
    global static QuickAction.SendEmailQuickActionDefaults getSendEmailDefaults(QuickAction.QuickActionDefaults[] defaults){
        // Check if the action is an email action (Classic uses Email & LEX uses SendEmail); both are supported
        for (Integer j = 0; j < defaults.size(); j++) {
            system.debug('action type****'+defaults.get(j).getActionName());
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults &&
                    defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
                    (defaults.get(j).getActionType().equals('SendEmail') || defaults.get(j).getActionType().equals('Email') || defaults.get(j).getActionType().equals('Case.Email_w_Blank_Subject'))
               ) {
                   return (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
            }
        }
        return null;        
    }

    global static Default_Email_Publisher_Setting__mdt getMdt(Case c){
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        
        List<Default_Email_Publisher_Setting__mdt> lMdt = [select id,Record_Types__c,Countries__c,Default_BCC__c,Default_CC__c,Default_From__c,Default_Subject__c,Case_Origins__c FROM Default_Email_Publisher_Setting__mdt];
        // get mdt records that match Cases's record type
        lMdt = getMdtsThatMatchCaseRecordType(rt_map.get(c.RecordTypeId).getName(),lMdt);
        if(CareDotComUtil.runningInASandbox()) System.Debug('MDT Record Type matches: ' + lMdt.size());
        if (!lMdt.isEmpty()){
            // get mdt records that match Cases's Member Country
            lMdt = getMdtsThatMatchCaseCountry(c.Member_Country__c,lMdt);            
            if(CareDotComUtil.runningInASandbox()) System.Debug('MDT Country matches: ' + lMdt);
            if (!lMdt.isEmpty()){
                // Get mdt records that match Case Origin
                lMdt = getMdtsThatMatchCaseOrigin(c.Origin,lMdt);
                if(CareDotComUtil.runningInASandbox()) System.Debug('MDT Case Origin matches: ' + lMdt);
                if (!lMdt.isEmpty()){
                    // If there is one valid MDT, we return it; if there are 0 or more, we return null
                    // Why?  If there are 0 none matched.
                    // If there are more than 1 than the MDT has amiguous entries and we cannot figure out which to use
                    // so it is best to fail gracefully until someone fixes the amgiuity in the MDT
                    if (lMdt.size() == 1) return lMdt[0];                
                }

            }
        }
        return null;
    }

    global static List<Default_Email_Publisher_Setting__mdt> getMdtsThatMatchCaseRecordType(String sRecordTypeToMatch, List<Default_Email_Publisher_Setting__mdt> lMdt){
        List<Default_Email_Publisher_Setting__mdt> lMdtToReturn = new List<Default_Email_Publisher_Setting__mdt>();
        for (Default_Email_Publisher_Setting__mdt mdt : lMdt){
            for (String sRecordType : mdt.Record_Types__c.split(',')){
                sRecordType = sRecordType.trim();
                if (sRecordTypeToMatch == sRecordType){ // found a matching record type
                    lMdtToReturn.add(mdt);
                } 
            }
        }
        return lMdtToReturn;
    }

    global static List<Default_Email_Publisher_Setting__mdt> getMdtsThatMatchCaseCountry(String sMemberCountryToMatch, List<Default_Email_Publisher_Setting__mdt> lMdt){
        List<Default_Email_Publisher_Setting__mdt> lMdtToReturn = new List<Default_Email_Publisher_Setting__mdt>();
        for (Default_Email_Publisher_Setting__mdt mdt : lMdt){
            if (mdt.Countries__c != null){ // international use case where countries are listed in comma delimited list
                for (String sMemberCountry : mdt.Countries__c.split(',')){
                    sMemberCountry = sMemberCountry.trim();
                if (sMemberCountry == 'Any'){ // 'Any' is a special use case; all mdt's with 'Any' are returned; 
                        lMdtToReturn.add(mdt);
                    } else if (sMemberCountryToMatch == sMemberCountry){
                        lMdtToReturn.add(mdt);  // Mdt & Case Member Country match
                    }
                }
            }
        }
        return lMdtToReturn;
    }

    global static List<Default_Email_Publisher_Setting__mdt> getMdtsThatMatchCaseOrigin(String sCaseOriginToMatch, List<Default_Email_Publisher_Setting__mdt> lMdt){
        List<Default_Email_Publisher_Setting__mdt> lMdtToReturn = new List<Default_Email_Publisher_Setting__mdt>();
        for (Default_Email_Publisher_Setting__mdt mdt : lMdt){
            if (mdt.Case_Origins__c != null){ 
                for (String sCaseOrigin : mdt.Case_Origins__c.split(',')){
                    sCaseOrigin = sCaseOrigin.trim();
                    if (sCaseOrigin == 'Any'){ // 'Any' is a special use case; all mdt's with 'Any' are returned; 
                        lMdtToReturn.add(mdt);
                    } else if (sCaseOriginToMatch == sCaseOrigin){
                        lMdtToReturn.add(mdt);  // Mdt & Case Origin match
                    }
                }
            }
        }
        return lMdtToReturn;
    }

}