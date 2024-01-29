trigger PersonAccountToLead on Account (after insert) {
    
    RecordType smbRecType = new RecordType();
    for (RecordType rt: getRecordtypesStatic.persAcctRecTypes) {
        if (rt.DeveloperName == 'SMB_Provider') {
            smbRecType = rt;
        }
    }
    
    //possible where RT=Marketplace
    list <Lead> perAcctLeadList = new list<Lead>(); 
    map<string,Lead> emailStrings = new map<string,Lead>();
    list<Lead> newMemsLeads = new list<Lead>();
    
    set<Id> ContactIdSet = new set<Id>();
    for(Account personAccount : trigger.new){
        if(personAccount.RecordTypeId == smbRecType.Id )
            ContactIdset.add(personAccount.personContactId);  
    }
    
    list<Contact> personContactList = [SELECT Id, LastName, FirstName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState,
                                       MailingPostalCode, MailingCountry, Business_Name__c, MemberID__c, MembershipCreationDate__c,
                                       Service_Id__c, Sub_Service_Id__c, Company_ID__c, Brand_ID__c, AccountId
                                       FROM Contact WHERE Id IN: ContactIdSet];
                                       
    //turn the Assignment Rules on
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.useDefaultRule = true;
    
    //Checking the list of Accounts just inserted to see if any of them have SMB RecordType
    for(Contact justinserted : personContactList ){
        Lead perAcctLead = new Lead (); 
        perAcctLead.LastName = justInserted.LastName;
        perAcctLead.FirstName = justInserted.FirstName;
        perAcctLead.RecordTypeId = getRecordTypesStatic.mktplcLeadRecType;
        perAcctLead.Email = justInserted.Email;
        perAcctLead.Phone = justInserted.Phone;
        perAcctLead.MobilePhone = justInserted.MobilePhone;
        perAcctLead.City = justInserted.MailingCity;
        perAcctLead.State = justInserted.MailingState;
        perAcctLead.Street = justInserted.MailingStreet;
        perAcctLead.PostalCode = justInserted.MailingPostalCode;
        perAcctLead.Country = justInserted.MailingCountry;
        perAcctLead.Company = justInserted.Business_Name__c;
        perAcctLead.Member_ID__c = justInserted.MemberID__c;
        perAcctLead.MembershipCreationDate__c = justInserted.MembershipCreationDate__c;
        perAcctLead.Service_Id__c = justInserted.Service_Id__c;
        perAcctLead.Sub_Service_Id__c = justInserted.Sub_Service_Id__c;
        perAcctLead.Company_ID__c = justInserted.Company_ID__c;
        perAcctLead.Brand_ID__c = justInserted.Brand_ID__c;
        perAcctLead.Person_Account__c = justInserted.Id;
        perAcctLead.setOptions(dmo); //make sure assignment rules run
        perAcctLeadList.add(perAcctLead);
    }
    
    if(!perAcctLeadList.isempty()){
        insert perAcctLeadList;
        
        set<id> newLeadIds = new set<Id>();
        for(Lead leadItem : perAcctLeadList) {
            if(leadItem.Email != null){
                emailStrings.put(leadItem.Email, leadItem);
            }
            newMemsLeads.add(leadItem);
            newLeadIds.add(leadItem.id);
        }
            

        list<Lead> leadEmails = [SELECT Id, Name, Email  FROM Lead WHERE Email IN: emailStrings.keyset() AND Id NOT IN: newLeadIds AND RecordTypeId =: getRecordTypesStatic.mktplcLeadRecType];
        for(Lead oldDup : leadEmails)
            newMemsLeads.add(oldDup);
        
        list<Contact> newMemsConts = [SELECT Id, LastName, Email FROM Contact WHERE (Email IN: emailStrings.keyset() AND RecordTypeId =: getRecordTypesStatic.mktplcContactRecType)];
        
        list <CampaignMember> campMemList = new list <CampaignMember>();
        list<Task> dupeAlertList = new list <Task>();
        set<Id> alreadyAlertedLdIds = new set<Id>();
        List<Campaign> signupCamp = [Select Id FROM Campaign WHERE Name = 'Care.com Signup' limit 1];
        
        if (!signupCamp.isEmpty()) {
            for(Lead newMem : newMemsLeads){
                CampaignMember campMem = new CampaignMember();
                Task dupeAlert = new Task();
                campMem.campaignid = signupCamp[0].Id;
                campMem.leadId=newMem.Id;
                campMemList.add(campMem);
                if (newMem.email != null) {
                    if (!newLeadIds.contains(newMem.id) && !alreadyAlertedLdIds.contains(emailStrings.get(newMem.email).id)) {
                        dupeAlert.Subject = 'Marketplace Lead Dupe Alert';
                        dupeAlert.Description = 'This Marketplace Lead was recently created and is a duplicate. One or more Marketplace Leads or Contacts with this email address already exists in Salesforce. All Marketplace Leads and Contacts with this email address have been added to the Care.com Signup Campaign.';
                        dupeAlert.WhoID = emailStrings.get(newMem.email).id;
                        //dupeAlert.OwnerId = ????
                        dupeAlertList.add(dupeAlert);
                        alreadyAlertedLdIds.add(emailStrings.get(newMem.email).id);
                    }
                }
            }
        
            if(!newMemsConts.isempty()){        
                for(Contact newMem : newMemsConts){
                    CampaignMember campMem = new CampaignMember();
                    Task dupeAlert = new Task();
                    campMem.campaignid = signupCamp[0].Id;
                    campMem.ContactId=newMem.Id;
                    campMemList.add(campMem);
                    if (!alreadyAlertedLdIds.contains(emailStrings.get(newMem.email).id)) {
                        dupeAlert.Subject = 'Marketplace Lead Dupe Alert';
                        dupeAlert.Description = 'This Marketplace Lead was recently created and is a duplicate. One or more Marketplace Leads or Contacts with this email address already exists in Salesforce. All Marketplace Leads and Contacts with this email address have been added to the Care.com Signup Campaign.';
                        dupeAlert.WhoID = emailStrings.get(newMem.email).id;
                        //dupeAlert.OwnerId = ????
                        dupeAlertList.add(dupeAlert);
                        alreadyAlertedLdIds.add(emailStrings.get(newMem.email).id);
                    }
                }
            }
        }
        
            
        if(!campMemList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.insert(campMemList,false);
            insert dupeAlertList;
        }
    }       
}