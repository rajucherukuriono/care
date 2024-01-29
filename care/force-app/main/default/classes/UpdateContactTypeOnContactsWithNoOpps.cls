/*
** _________________________________________________________________________________
** Created by:    NBOS Technologies [www.nbostechnologies.com]
** Developer:     SRIDHAR NEELI, SFDC Tech Lead [sridhar.neeli@care.com]
** Created Date:  09.01.2018
** Modified by:   NBOS Technologies [http://nbostechnologies.com/]
** Modified Date: 09.01.2018
** =================================================================================
** Description: 
**            Created as part of 'SFORCE-1827 HomePay Contact Type Field Clean-Up'
** _______________________________________________________________________________
*/
global class UpdateContactTypeOnContactsWithNoOpps
{
    webservice static void updateContactTypeOnContactsWithNoOpps()
    {
    
  ID oppRt1Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Referral');
    ID oppRt2Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Partner');
      // Map<id,OpportunityContactRole> oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId=:Trigger.newMap.keySet() and Opportunity.StageName='Closed Won' and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
        Map<id,OpportunityContactRole> oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE Contact.RecordType.Name='Homepay Business Contact' order by createddate desc LIMIT 50000]);
        Set<id> contList=new Set<id>();
        Set<id> oppList=new Set<id>();
        Map<id,List<Opportunity>> contOppListMap=new Map<id,List<Opportunity>>();
        
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
           contList.add(oppContObj.contactId);
           oppList.add(oppContObj.opportunityId);
           
        }
        
        Map<id,opportunity>  oppMap=new Map<id,opportunity>([select Id,name,RecordTypeId,RecordType.name,Product_Type__c,stageName from Opportunity where id=:oppList]);
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
            if(oppMap.get(oppContObj.opportunityId)!=null)
            {
                if(!contOppListMap.containsKey(oppContObj.contactId))
                {  
                    contOppListMap.put(oppContObj.contactId,new List<Opportunity>{oppMap.get(oppContObj.opportunityId)});
                }
                else
                {
                    contOppListMap.get(oppContObj.contactId).add(oppMap.get(oppContObj.opportunityId));
                }
            }
            
        }
        //Map<id,Contact> contMap=new Map<id,Contact>([SELECT id,name,RecordTypeId,Recordtype.name,Contact_type__c,Contact_Type_Backup__c from Contact where RecordType.Name='Homepay Business Contact' order by createddate desc LIMIT 50000]);
        /**************************Update contacts with No Opps To Prospective Partner*************/       
         Set<Contact> contactsWoOpps=new Set<Contact>();
        for(Contact contObj:[SELECT id,name,RecordTypeId,Recordtype.name,Contact_type__c,Contact_Type_Backup__c from Contact where recordType.Name='Homepay Business Contact'])
        {
            if(CareDotComUtil.runningInASandbox())   System.debug('!contOppListMap.containsKey(contObj.id)===>:'+!contOppListMap.containsKey(contObj.id)+'         contObj.Contact_type__c!=\'Prospective Partner\'===>:'+(contObj.Contact_type__c!='Prospective Partner'));
            if(!contOppListMap.containsKey(contObj.id) && contObj.Contact_type__c!='Prospective Partner')
            {contObj.Contact_type__c='Prospective Partner';contactsWoOpps.add(contObj);}
        }
        if(!contactsWoOpps.isEmpty())  update new List<Contact>(contactsWoOpps);
        
        
        /*******************************************************************************************/
    }
}