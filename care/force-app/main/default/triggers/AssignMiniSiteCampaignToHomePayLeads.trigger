// All HomePay leads with a lead source of Web will get assigned to the MiniSite Campaign
// Ideally this would have been done by tech, but the requiremnts came late, so I decided to do it myself in apex.
// As more HomePay lead records types are developped in the future, more logic may need to be added.
// Context: the trigger executes "after insert" since it is defining a new relationship and should not need to modify lead itself

trigger AssignMiniSiteCampaignToHomePayLeads on Lead (after insert) {
    
    private static RecordType HomePayLeadRt = [SELECT id FROM RecordType WHERE DeveloperName = 'HomePay_Lead' and sObjectType = 'Lead' and isActive = true limit 1];
    private static Campaign[] HomePayMiniSiteCampaign = [SELECT id FROM Campaign WHERE Name = 'HomePay Mini Site' and isActive = true limit 1];
    boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
    if(!bypassLeadTriggers)
    {
        Set<sObject> ObjectsToInsert = new Set<sObject>(); 
        
        for (Lead newLead : trigger.newMap.values()){
            if (newLead.RecordTypeId == HomePayLeadRt.id && newLead.LeadSource == 'Web'){
                CampaignMember mem = new CampaignMember(CampaignId = HomePayMiniSiteCampaign[0].id, LeadId = newLead.id);
                ObjectsToInsert.add(mem);
            }
        }
        List<sObject> objectsToInsertList = new List<sObject>();
        objectsToInsertList.addAll(objectsToInsert); // convert set to list to pass to insert statement;
        insert objectsToInsertList;
    }
}