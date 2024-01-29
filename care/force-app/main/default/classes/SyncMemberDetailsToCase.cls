/*
** _________________________________________________________________________________
** Created by:    NBOS Technologies [http://nbostechnologies.com/]
** Developer:     Sridhar Neeli, SFDC Lead [sridhar.neeli@care.com]
** Created Date:  12.22.2016

** =================================================================================
** Description: 
**Associate Member Details to a Case whenever a member is associated to the case
**Context: before insert, before update
**Outcome: copies Member_Locale__c, Member_Country__c, Member_Type__c, Global_Member_Id__c, Member_Type__c, 
**Member_Account_Type__c, USAA_Member__c, OverallStatus__c  from Contact to Case 
    Also if Case has Dummy Web Email, it updates it with Contact's actual email & name
*/
public without sharing class SyncMemberDetailsToCase {

    public static Set<id> getContactIdList(List<Case> TriggerNew){
        Set<id> contactIdList=new Set<id>();
        for(Case caseObj : TriggerNew){
            if(caseObj.contactId!=null) contactIdList.add(caseObj.contactId);
        }
        return contactIdList;
    }

    public static Map<id,Contact> getCaseContactMap(Set<id> contactIdList){
        return new Map<id,Contact>([SELECT id,Locale__c,MailingCountry,MemberType__c,Global_Member_Id__c,Type__c,Status__c,
                                                    USAA_Member__c,OverallStatus__c,Employer_Program__c,Email,FirstName,LastName                                              		
                                                    FROM Contact WHERE id = :contactIdList]);
    }

    public static void associateMemberDtlsToCase(Case caseObj,Map<id,Contact> caseContactMap){
              // if the case has not been associated with a contact, then don't copy values
                    Contact caseContactObj=caseContactMap.get(caseObj.contactId);
                    if(caseContactObj!=null){
                        if(caseContactObj.Locale__c !=null){
                        	caseObj.Member_Locale__c = caseContactObj.Locale__c;
                        }
                        if(caseContactObj.MailingCountry!=null){
                        	caseObj.Member_Country__c = caseContactObj.MailingCountry;
                        }
                        caseObj.Member_Type__c = caseContactObj.MemberType__c;
                        caseObj.Global_Member_Id__c = caseContactObj.Global_Member_Id__c;
                        caseObj.Member_Account_Type__c = caseContactObj.Type__c;
                        caseObj.Member_Status__c = caseContactObj.Status__c;
                        caseObj.USAA_Member__c = caseContactObj.USAA_Member__c;
                        caseObj.Member_Overall_Status__c = caseContactObj.OverallStatus__c;
                        
                        //Added as part of SF-979 requirement
                        //if(caseContactObj.Employer_Program__c !=null && caseObj.Origin != null && caseObj.Origin.Right(5).contains('- Web')){//added this line for BUC-UK-IRE Sforce 3149 and removed again. 
                        caseObj.Employer_Program__c = caseContactObj.Employer_Program__c;
                       // }
                       

                        // If Case has Dummy Web Email, update with Contact's actual email & name
                        if (CDCCPreChatController.isDummyEmail(caseObj.SuppliedEmail)){
                            caseObj.SuppliedEmail = caseContactObj.Email;
                            if (caseContactObj.FirstName != null && caseContactObj.LastName != null){
                                caseObj.SuppliedName = caseContactObj.FirstName + ' ' + caseContactObj.LastName;
                            }
                        }

                    }
                        /*
                        else{
                        caseObj.Member_Locale__c = null;
                        caseObj.Member_Country__c = null;
                        caseObj.Member_Type__c = null;
                        caseObj.Global_Member_Id__c = null;
                        caseObj.Member_Account_Type__c = null;
                        caseObj.Member_Status__c = null;
                        caseObj.USAA_Member__c = false;
                        caseObj.Member_Overall_Status__c = null;
                        //Added as part of SF-979 requirement
                        caseObj.Employer_Program__c = null;
                        }
                         */         
    }

    @InvocableMethod(label='Sync Member Details to Case')
    public static List<List<Case>> syncMemberDetailsToCaseAction(List<List<Case>> Cases){
        for(List<Case> innerCases : Cases){
            if (innerCases != null){
                Set<id> contactIdList = getContactIdList(innerCases);
                Map<id,Contact> caseContactMap = getCaseContactMap(contactIdList);
                for(Case c : innerCases){
                    associateMemberDtlsToCase(c,caseContactMap);
                }
            }
        }
        return Cases;

    }
}