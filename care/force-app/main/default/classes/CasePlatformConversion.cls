public class CasePlatformConversion {
    public static ID stdRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static ID intEmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static List<Case_Type_Setting__mdt> intCaseTypes = [SELECT Member_Type__c,Source_Case_Type__c,Target_Case_Type__c FROM Case_Type_Setting__mdt WHERE Target_Platform__c = :OnDemandSync.PLATFORM_INTL];
    public static List<Case_Type_Setting__mdt> usCaseTypes = [SELECT Member_Type__c,Source_Case_Type__c,Target_Case_Type__c FROM Case_Type_Setting__mdt WHERE Target_Platform__c = :OnDemandSync.PLATFORM_US];
    public static Boolean firstcall = false;

    public static Case convert(Case c, Account a, String TargetPlatform){
        /*    
			Given a Case & target platform will convert the Case & return it
			ODS will call this method when it needs to convert a Case.  It will pass the platform opposite to the value in the ODS Request Platform field.
		*/

        if (TargetPlatform == OnDemandSync.PLATFORM_US) convertToUS(c, a);
        else if (TargetPlatform == OnDemandSync.PLATFORM_INTL) convertToInternational(c,a);

        return c;
    }

    public static void convertToUS(Case c, Account a){
        // Account is optional, so the code needs to handle null Accounts
        // When Account is null, if Case Type requires member type, pass the default Type of "Question" instead
        c.recordTypeId = stdRtId;
        //c.Tier_Model__c = OnDemandSync.PLATFORM_US;
        //c.Tier__c = null;
        c.Member_Country__c = null;
        // 2022-02-17 Jack Odell: US Cases used to use null lang; but they now use English
        // If this isn't set, the case won't route properly
        c.Member_Language__c = 'English';
        //c.Member_Locale__c = null;
        c.ODS_Request_Platform__c = OnDemandSync.PLATFORM_US;
        c.Type = getUSTargetCaseType(c.Type,(a != null) ? a.MemberType__pc : null);
        c.Origin = (c.Origin == 'Web') ? c.Origin : 'Email';
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerUserEmail  = true;
        //c.setOptions(dmlOpts);
    }

    public static void convertToInternational(Case c, Account a){
        // Account is optional, so the code needs to handle null Accounts
        // When Account is null, the case is mostly likely going to end up assigned to the Q: Internatonal Catch-all queue,
        // so the code just needs to faciliate that without any errors.
        // Also: Email origin will be set to 'Email' because we don't have a country to set it to
        c.recordTypeId = intEmailRtId;
        //c.Tier_Model__c = OnDemandSync.PLATFORM_INTL;
        //c.Tier__c = null;
        c.Type = getINTLTargetCaseType(c.Type);
        c.ODS_Request_Platform__c = OnDemandSync.PLATFORM_INTL;
        c.Origin = (c.Origin == 'Web') ? c.Origin : (a != null) ? CountryLocaleMapHelper.getCaseOriginFromLocale(a.Locale__pc) : 'Email';
        //Gears Case:00042482
        //Moved to Breeze
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId = SyncLocaleToLanguageInCase.AR.id;
        //dmlOpts.EmailHeader.triggerUserEmail  = true;
        //c.setOptions(dmlOpts);
    }

    public static String getINTLTargetCaseType(String sourceCaseType){
        String targetCaseType = 'Question'; // default case type for all platforms if there is no match
        for (Case_Type_Setting__mdt ct : intCaseTypes){
            if (ct.Source_Case_Type__c == sourceCaseType) return ct.Target_Case_Type__c;
        }
        return targetCaseType;
    }

    public static String getUSTargetCaseType(String sourceCaseType, String memberType){
        String targetCaseType = null;
        for (Case_Type_Setting__mdt ct : usCaseTypes){
            if (ct.Source_Case_Type__c == sourceCaseType && ct.Member_Type__c == memberType){
                return ct.Target_Case_Type__c;
            }
            else if (ct.Source_Case_Type__c == sourceCaseType && ct.Member_Type__c == null){
                return ct.Target_Case_Type__c;
            }
        }
        return targetCaseType;
    }

    public static List<Case> convertViaTrigger(Case[] Cases,Map<Id,Case> OldMap){
        // 		Allow reps to invoke Case Platform conversion by changing ODS Request Platform.
        //      Since this field is also changed during ODS, this logic will only be allowed after ODS is complete (Is ODS Complete == true).
        //      Since Case Platform Conversion causes Assignment Rules to be re-invoked, this logic must be run in "after update" context.
        //      Context: after update
        //      Outcome: Invokes CasePlatformConversion.convertViaTrigger() methods which will execute conversion & invoke assignment rules.

        // 		This method is invoked by reps who are trying to convert the case platform by changing the ODS Request Platform field
        Set<ID> CaseIds = new Set<ID>();
        Set<ID> AccountIds = new Set<ID>();
        Case[] CasesRW = new List<Case>();
        for (Case c: Cases){
            // Is ODS Complete true? Also make sure we are not getting invoked in the same transaction when ODS Complete was set to true
            if (c.Is_ODS_Complete__c == true && c.Is_ODS_Complete__c == OldMap.get(c.id).Is_ODS_Complete__c){
                if (c.ODS_Request_Platform__c != OldMap.get(c.id).ODS_Request_Platform__c){ // did ODS Request platform just change?
                    if (!firstcall){ // case conversion code doesn't defend itself against multiple invocations, so must avoid recursion
                        firstcall = true;
                        CaseIds.add(c.Id);                        
                        AccountIds.add(c.AccountId);
                    }
                }
            }
        }

        if (!CaseIds.isEmpty()){ // only try to invoke platform conversion if any Cases were caught in logic above
            CasesRW = [SELECT id,Account.MemberId__c,ownerId,Web_Member_Id__c,AccountId,SuppliedEmail,ODS_Number_of_Retries__c,
                    ODS_Start_Time__c,ODS_Request_Status__c,ODS_Request_Platform__c,Alt_ODS_Request_Status__c,Type,Origin
            FROM Case WHERE ID IN : CaseIds];

            if (!CasesRW.isEmpty()){
                // Grab Account fields required by CasePlatform Conversion fields above
                Map<Id,Account> aMap = new Map<Id,Account>([SELECT id,Locale__pc,MemberType__pc FROM Account WHERE Id IN :AccountIds]);
                for (Case c : CasesRW){
                    convert(c,aMap.get(c.AccountId),c.ODS_Request_Platform__c); // the rep has changed the platform manually, so we'll convert it to what they set it to
                }
            }
        }

        return CasesRW;
    }
}