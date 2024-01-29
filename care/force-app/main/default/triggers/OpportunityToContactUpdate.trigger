/*
This trigger is modified as per the JIRA Sforce 1827 -- HomePay Contact Type Field Clean-Up. 
We are updating the contact type of the contact based on the Opportunity record type and the Opportunity product type values.
Author : Sridhar Neeli
Modified on : 25/06/2017
*/
trigger OpportunityToContactUpdate on Opportunity (after insert, after update,before delete)
{
    //ID oppRt1Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
    //ID oppRt2Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Partner').getRecordTypeId();
    ID oppRt1Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Referral');
    ID oppRt2Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Partner');
    
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.old ==============>:'+Trigger.old);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.new ==============>:'+Trigger.new);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.isAfter==============>:'+Trigger.isAfter);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.isBefore==============>:'+Trigger.isBefore);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.isInsert==============>:'+Trigger.isInsert);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.isDelete==============>:'+Trigger.isDelete);
    if(CareDotComUtil.runningInASandbox())   System.debug('Trigger.isUpdate==============>:'+Trigger.isUpdate);
Map<Id,Opportunity> delOppsMap=new Map<Id,Opportunity>();
    if(Trigger.isAfter && Trigger.isDelete)
    {
        for(Opportunity oppObj:Trigger.old)
        {
            delOppsMap.put(oppObj.id,oppObj);
        }
        
    }
   if(((trigger.isInsert || trigger.isUpdate) && trigger.isAfter) || (trigger.isDelete && trigger.isBefore))
   {
       // Map<id,OpportunityContactRole> oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId=:Trigger.newMap.keySet() and Opportunity.StageName='Closed Won' and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
//        Map<id,OpportunityContactRole> oppContRoleMap= new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId=:Trigger.isDelete?new List<Opportunity>(delOppsMap.values()):Trigger.New and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
        Map<id,OpportunityContactRole> oppContRoleMap= new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId=:Trigger.isDelete?Trigger.Old:Trigger.New and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
        if(CareDotComUtil.runningInASandbox())   System.debug('1st opp role Query ====>:'+oppContRoleMap.size());
        Set<id> contList=new Set<id>();
        Set<id> oppList=new Set<id>();
        Map<id,List<Opportunity>> contOppListMap=new Map<id,List<Opportunity>>();
        
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
           contList.add(oppContObj.contactId);
        }
        
        if(Trigger.isBefore && Trigger.isDelete)
        {
            oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.RecordTypeId,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId !=:Trigger.Old and  contactId=:contList and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
            if(CareDotComUtil.runningInASandbox())   System.debug('oppContRoleMap.size After delete====>:'+oppContRoleMap);
        }
        else if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter)
        {
            oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.RecordTypeId,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE contactId=:contList and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
        }
                if(CareDotComUtil.runningInASandbox())   System.debug('2nd opp role Query ====>:'+oppContRoleMap.size());
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
            oppList.add(oppContObj.opportunityId);
        }
        Map<id,opportunity>  oppMap=new Map<id,opportunity>([select Id,name,RecordTypeId,RecordType.name,Product_Type__c,stageName from Opportunity where id=:oppList]);
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
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

        Map<id,List<String>> contIdOppProdListRec1Map=new Map<id,List<String>>();
        Map<id,List<String>> contIdOppProdListRec2Map=new Map<id,List<String>>();
        Map<id,Contact> contMap=new Map<id,Contact>([SELECT id,name,RecordTypeId,Recordtype.name,Contact_type__c,Contact_Type_Backup__c from Contact where id=:contList LIMIT 50000]);
        
                if(CareDotComUtil.runningInASandbox())   System.debug('ContMap Size =======>:'+contMap.size());
        if(contMap.size()>0)
        {
                                if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+8);
                for(Contact contObj:contMap.values())
                {
                                         if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+9);
                        List<String> prodList1=new List<String>();
                        List<String> prodList2=new List<String>();
                        if(contOppListMap.get(contObj.id)!=null && contOppListMap.get(contObj.id).size()>0 && contOppListMap.containsKey(contObj.id))
                        {
                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+91);
                                        
                                for(Opportunity oppObj:contOppListMap.get(contObj.id))
                                {
                                    if(CareDotComUtil.runningInASandbox())   System.debug('Processing Contact ==>:'+contMap.get(contObj.id).name+'       oppObj.Name===>:'+oppObj.name);
                                if(oppObj!=null)
                                {
                                           if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+10);
                                            // For Opportunities with HomePay Referral record type
                                            if(!contIdOppProdListRec1Map.containsKey(contObj.id))
                                            {
                                                contIdOppProdListRec1Map.put(contObj.id,prodList1);
                                            }
                                            /*
                                            if(!contIdOppProdListRec2Map.containsKey(contObj.id))
                                            {
                                                contIdOppProdListRec2Map.put(contObj.id,prodList2);
                                            }
                                            */
                                    
                                            //if(oppObj.RecordType.Name=='HomePay Referral' && oppObj.Product_Type__c=='Authorized Contact')
                                            if(oppObj.RecordTypeId==oppRt1Id && oppObj.Product_Type__c=='Authorized Contact')
                                            {
                                                if(!contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact'))
                                                {
                                                contIdOppProdListRec1Map.get(contObj.id).add('Authorized Contact');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+12);
                                                }
                                                
                                            }
                                            else 
                                            if(oppObj.RecordTypeId==oppRt1Id && oppObj.Product_Type__c=='Referral')
                                            {
                                                if(!contIdOppProdListRec1Map.get(contObj.id).contains('Referral'))
                                                {
                                                contIdOppProdListRec1Map.get(contObj.id).add('Referral');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+13);
                                                }
                                                
                                            }
                                            else if(oppObj.RecordTypeId==oppRt1Id && oppObj.Product_Type__c=='Referrer')
                                            {
                                                if(!contIdOppProdListRec1Map.get(contObj.id).contains('Referrer'))
                                                {
                                                contIdOppProdListRec1Map.get(contObj.id).add('Referrer');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+14);
                                                }
                                                
                                            }
                                            // For Opportunities with HomePay HomePay Partner 
                                            if(!contIdOppProdListRec2Map.containsKey(contObj.id))
                                            {
                                                contIdOppProdListRec2Map.put(contObj.id,prodList2);
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+15);
                                            }
                                    
                                            if(oppObj.RecordTypeId==oppRt2Id && oppObj.Product_Type__c=='Authorized Contact')
                                            {
                                                if(!contIdOppProdListRec2Map.get(contObj.id).contains('Authorized Contact'))
                                                {
                                                contIdOppProdListRec2Map.get(contObj.id).add('Authorized Contact');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+16);
                                                }
                                                
                                            }
                                            else if(oppObj.RecordTypeId==oppRt2Id && oppObj.Product_Type__c=='Referral')
                                            {
                                                if(!contIdOppProdListRec2Map.get(contObj.id).contains('Referral'))
                                                {
                                                contIdOppProdListRec2Map.get(contObj.id).add('Referral');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+17);
                                                }
                                                
                                            }
                                            else if(oppObj.RecordTypeId==oppRt2Id && oppObj.Product_Type__c=='Referrer')
                                            {
                                                if(!contIdOppProdListRec2Map.get(contObj.id).contains('Referrer'))
                                                {
                                                contIdOppProdListRec2Map.get(contObj.id).add('Referrer');
                                                                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+18);
                                                }
                                                
                                            }
                                    }
                                }
                         }
                     
                }
        
        }
if(CareDotComUtil.runningInASandbox())   System.debug('contMap.size() ==========>:'+  contMap.size());
        for(Contact contObj:contMap.values())
        {
            if(CareDotComUtil.runningInASandbox())   System.debug(contobj.name+' Cont Obj in for loop contIdOppProdListRec1Map.get(contObj.id)'+ contIdOppProdListRec1Map.get(contObj.id));
            if(CareDotComUtil.runningInASandbox())   System.debug(contObj.name+' Cont Obj in for loop contIdOppProdListRec2Map.get(contObj.id)'+ contIdOppProdListRec2Map.get(contObj.id));
             
                boolean partnerCriteriaMet=false;
                boolean referralCriteriaMet=false;
                String partnerContactType='';
                String referralContactType='';
                
                //contObj.Contact_Type__c='Referring Partner';
                if(contIdOppProdListRec2Map.get(contObj.id)!=null &&
                !(contIdOppProdListRec2Map.get(contObj.id)).contains('Authorized Contact') && 
                !(contIdOppProdListRec2Map.get(contObj.id)).contains('Referral') && 
                (contIdOppProdListRec2Map.get(contObj.id)).contains('Referrer')){
                //contObj.Contact_Type__c='Prospective Partner';
                partnerCriteriaMet=true;
                partnerContactType='Prospective Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('1 Setting '+contobj.name +' contact type as Prospective Partner');
                }
                else if(contIdOppProdListRec2Map.get(contObj.id)!=null && 
                (contIdOppProdListRec2Map.get(contObj.id)).contains('Authorized Contact') && 
                (contIdOppProdListRec2Map.get(contObj.id)).contains('Referral') && 
                (contIdOppProdListRec2Map.get(contObj.id)).contains('Referrer')){
                //contObj.Contact_Type__c='Referring Partner';
                partnerCriteriaMet=true;
                partnerContactType='Referring Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('2 Setting '+contobj.name +'  contact type as Referring Partner');
                }
                                
                if(
                contIdOppProdListRec1Map.get(contObj.id)!=null && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact') && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Referral') && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Referrer')){
                //contObj.Contact_Type__c='Partner with Client Connection';
                referralCriteriaMet=true;
                referralContactType='Partner with Client Connection';
                if(CareDotComUtil.runningInASandbox())   System.debug('3 Setting  '+contobj.name +' contact type as Partner with Client Connection');
                }
                else if(contIdOppProdListRec1Map.get(contObj.id)!=null && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact') && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Referral') && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Referrer')){
                //contObj.Contact_Type__c='Referring Partner';
                referralCriteriaMet=true;
                referralContactType='Referring Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('4 Setting contact type as Referring Partner');
                }
                else if(
                contIdOppProdListRec1Map.get(contObj.id)!=null && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact') && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Referral') && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Referrer')){
                                //contObj.Contact_Type__c='Referring Partner';
                                referralCriteriaMet=true;
                                referralContactType='Referring Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('5 Setting contact type as Referring Partner');
                }
                else if(contIdOppProdListRec1Map.get(contObj.id)!=null && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact') && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Referral') && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Referrer')){
                                                //contObj.Contact_Type__c='Referring Partner';
                                                referralCriteriaMet=true;
                                                referralContactType='Referring Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('6 Setting  '+contobj.name +' contact type as Referring Partner');
                }
                else if(contIdOppProdListRec1Map.get(contObj.id)!=null && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Authorized Contact') && 
                !contIdOppProdListRec1Map.get(contObj.id).contains('Referral') && 
                contIdOppProdListRec1Map.get(contObj.id).contains('Referrer')){
                //contObj.Contact_Type__c='Partner with Client Connection';
                referralCriteriaMet=true;
                referralContactType='Partner with Client Connection';
                if(CareDotComUtil.runningInASandbox())   System.debug('7 Setting  '+contobj.name +' contact type as Partner with Client Connection');
                }

               if(partnerCriteriaMet && !referralCriteriaMet)
               {
                contObj.contact_Type__c=partnerContactType;
              }
              
              if((!partnerCriteriaMet && referralCriteriaMet)||(partnerCriteriaMet && referralCriteriaMet))
              {
                    contObj.contact_Type__c=referralContactType;
              }             

            if(!partnerCriteriaMet && !referralCriteriaMet)
            {
                contObj.Contact_Type__c='Prospective Partner';
                if(CareDotComUtil.runningInASandbox())   System.debug('8 Setting  '+contobj.name +' contact type as Prospective Partner');
            }
            if(CareDotComUtil.runningInASandbox())   System.debug('Setting '+contObj.name+'<===> contact type as ==>:'+contObj.contact_Type__c+'<===>'+partnerCriteriaMet+partnerContactType+'<===>'+referralCriteriaMet+referralContactType);
        }
                        
        update contMap.values();
   }

//    Prospective Partner       Partner with Client Connection       Referring Partner

/*
    List<Id> acctIds = new List<Id>();
    
    if(trigger.new !=null){
    for(opportunity opp : trigger.new){
        acctIds.add(opp.AccountId);
    }
    }
    else{
    for(opportunity opp : trigger.old){
        acctIds.add(opp.AccountId);
    }
}
  
    Map<Id, Account> acctList = new Map<Id,Account>([Select Id, IsPersonAccount, contact_type__pc, (Select Id, RecordtypeId,Contact_type__c,Contact_Type_Backup__c from Contacts) from Account where IsPersonAccount = false and Id in : acctIds]); 
    
    ID oppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
    ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
   if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){
    set<contact> contSet = new Set<contact>();
    for (Opportunity opp : trigger.new)
    { 
        if(opp.AccountId!=null)
        {
            //if opportunity is new or updated to closed won stage
            Account accObj = acctList.get(opp.AccountId);
            if(accObj != null)
            {
                for(contact cont : accObj.contacts)
                {
                    cont.Contact_Type_Backup__c = cont.Contact_type__c;
                        //contact upates
                        
                    if((Trigger.oldMap!=null && Trigger.oldMap.get(opp.Id).StageName!='Closed Won') || (Trigger.oldMap==null))
                    {           
                        
                       if(cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c == 'Referral' && opp.stageName == 'Closed Won')
                        {
                            cont.Contact_Type__c = 'Referring Partner';
                            
                        }
                        else if (cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c == 'Authorized Contact' && opp.stageName == 'Closed Won') 
                        {
                            cont.Contact_Type__c = 'Partner with Client Connection';
                        }
                        else if(cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c != 'Authorized Contact' && opp.Product_Type__c != 'Referral' && opp.stageName == 'Closed Won')
                        {
                            cont.Contact_Type__c = 'Prospective Partner';
                            }
                        contSet.add(cont);
                   
                     }
                    
                    
                }
            
            }
        }
       
       } 
       update new List<contact>(contSet); 
    }
    if(trigger.isDelete && trigger.isBefore)
    {
    Set<contact> contSet=new Set<contact>();
        for (Opportunity opp : trigger.old)
        { 
            //if opportunity is new or updated to closed stage
            Account accObj = acctList.get(opp.AccountId);
            if (accObj != null) 
            {
            list<contact> contList = accObj.contacts;

            for(contact cont : contList)
            {
                //contact upates
                    
                if(cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c == 'Referral' && opp.stageName == 'Closed Won')
                {
                    cont.Contact_Type__c = cont.Contact_Type_Backup__c;
                    
                }
                else if (cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c == 'Authorized Contact' && opp.stageName == 'Closed Won') 
                {
                    cont.Contact_Type__c = cont.Contact_Type_Backup__c;
                }
                else if(cont.RecordtypeId == conRtId && opp.RecordtypeId==oppRtId && opp.Product_Type__c != 'Authorized Contact' && opp.Product_Type__c != 'Referral' && opp.stageName == 'Closed Won')
                {
                    cont.Contact_Type__c = cont.Contact_Type_Backup__c;
                }
                contSet.add(cont);
            }
            update new List<contact>(contSet);
            }
           }
           
    }
    */
    //if(CareDotComUtil.runningInASandbox())   System.debug('Limits.getQueries() 4 =================>:'+Limits.getQueries());
}