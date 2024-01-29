trigger PrimaryContactOnOpp on Opportunity (before update) {
/* 2015-06-24 - Jack Odell, Kivo Solutions
    The purpose of this trigger is to store the Primary Contact on the Opportunity.  We do that so that
    we can write validation rules that check for the existence of a primary contact.
    
    The trigger manages two fields:  
        Primary_Contact_Associated__c: a lookup to the primary contact
        Number_of_Primary_Contacts__c: a count of the number of primary contacts associated with the opportunity.
            Validation rules should check whether this value is 0 to force primary contact to be added.
    
    Known Limitation: since Salesforce does not yet allow triggers on the OpportunityContactRole object (which is 
    where the Primary Contact actually lives), this trigger is only invoked after an Opportunity is edited AFTER
    the Primary Contact has been added to Opportunity Contact Role.  This should be ok because users will need
    to add the Primary Contact first and then edit the Opportunty's stage to invoke the validation rules.
*/

    // Build a Map of all opportunities passed to the trigger
    Map<Id,Opportunity> oMap = new Map<Id,Opportunity>(trigger.new);

/* USE CASE #1: Remove Primary Contact */
/* 
    We need to identify which Opportunities have had the Primary Contact removed.
    To do so we will compare opps that have Primary_Contact_Associated__c but whose Primary Contact are no longer in the OCR table.
    Then we will null out those opps Primary_Contact_Associated__c & set their Number_of_Primary_Contacts__c to 0
*/

// OppsWithPCA (set): iterate though oMap and return Opps with Primary_Contact_Associated__c
    Set<Opportunity> OppsWithPCA = new Set<Opportunity>();
    for (Opportunity o : trigger.new){
        if (o.Primary_Contact_Associated__c != null) OppsWithPCA.add(o); 
    }

// Get Opportunities which are in OppsWithPCA and which also have a Primary Contact in OCR
    Set<Opportunity> OppsWithPCinOCR = new Set<Opportunity>();
    for (OpportunityContactRole ocr : [SELECT id,opportunityId,contactId FROM OpportunityContactRole WHERE isPrimary = true AND OpportunityId = :OppsWithPCA]){
        OppsWithPCinOCR.add(oMap.get(ocr.opportunityId));
    }
    
    //Items that are in OppsWithPCA but not in OppsWithPCinOCR have had their primary contacts removed
    OppsWithPCA.RemoveAll(OppsWithPCinOCR);
    for (Opportunity o : OppsWithPCA){
        o.Primary_Contact_Associated__c = null;
        o.Number_of_Primary_Contacts__c = 0;
    }


/* USE CASE #2: Add Primary Contact */
/* 
    We need to find Opportunities who have primary contacts and attach the primary contact to them.
    To do so, we will query all passed opportunities on OpportunityContactRole table to see if the opps have any 
    Primary Contacts.  If they do, we will update the  Primary_Contact_Associated__c and Number_of_Primary_Contacts__c
    in the opportunity.
*/
    for (OpportunityContactRole ocr : [SELECT id,opportunityId,contactId FROM OpportunityContactRole WHERE isPrimary = true AND OpportunityId = :oMap.keyset()]){
        if (oMap.get(ocr.opportunityId).Primary_Contact_Associated__c != ocr.contactId) oMap.get(ocr.opportunityId).Primary_Contact_Associated__c = ocr.contactId;
        if (oMap.get(ocr.opportunityId).Number_of_Primary_Contacts__c != 1) oMap.get(ocr.opportunityId).Number_of_Primary_Contacts__c = 1;
    }

    

}