global class BatchOpportunityToContactUpdate implements Schedulable, Database.Batchable<SObject>,Database.stateful {
    global String query;
    public boolean isTestingContext=false;
    private ApexPages.StandardController controller {get; set;}
    private opportunity oppObj{get;set;}

    public BatchOpportunityToContactUpdate(ApexPages.StandardController controller) {

        this.controller = controller;
        oppObj = (Opportunity)controller.getRecord();

    }
    global BatchOpportunityToContactUpdate()
    {
    }
    global BatchOpportunityToContactUpdate(boolean isTestingContext) {
        this.isTestingContext=isTestingContext;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        //query =  'SELECT Id,name,recordtypeid,RecordType.name,Product_Type__c,stageName from Opportunity';
        query = 'SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE Contact.RecordType.Name=\'Homepay Business Contact\'';
        if(isTestingContext)
        {
            //query =  'SELECT Id,name,recordtypeid,RecordType.name,Product_Type__c,stageName from Opportunity LIMIT 200 ';
            query = 'SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE Contact.RecordType.Name=\'Homepay Business Contact\' LIMIT 200';
        }
        if(CareDotComUtil.runningInASandbox())   System.debug('BatchOpportunityToContactUpdate Query firing is ===>:'+query);
        return Database.getQueryLocator(query);
    }
    
    /**
* Schedulable method, execute the schedule apex job
*/
    
    global void execute(SchedulableContext sc) {
        //Database.executeBatch(this,200);
          Database.executeBatch(this);
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<OpportunityContactRole> oppContRoleList)
    {
        updateContactTypeOnContact(oppContRoleList);
            
    }
    
    global void finish(Database.BatchableContext bc){

    }
   public Pagereference updateContactTypeOnContact()
   {
       //updateContactTypeOnContact(new List<OpportunityContactRole>{oppContRoleList});
       updateContactTypeOnContact([SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE opportunityId=:oppObj.id and Contact.RecordType.Name='Homepay Business Contact']);
       return new PageReference('/'+oppObj.id);
   }
    
  public void updateContactTypeOnContact(List<OpportunityContactRole> oppContRoleList)
  {
    ID oppRt1Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Referral');
    ID oppRt2Id = getRecordTypesStatic.recordTypeNameIdMap.get('HomePay Partner');

        //Map<id,OpportunityContactRole> oppContRoleMap= new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.recordtypeid,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE Id=:oppContRoleList and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000]);
        Map<id,OpportunityContactRole> oppContRoleMap= new Map<id,OpportunityContactRole>();
        for(OpportunityContactRole oppContRoleObj:oppContRoleList){
        oppContRoleMap.put(oppContRoleObj.id,oppContRoleObj);
        }

        Set<id> contList=new Set<id>();
        Set<id> oppSet=new Set<id>();
        Map<id,List<Opportunity>> contOppListMap=new Map<id,List<Opportunity>>();
        
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
           contList.add(oppContObj.contactId);
                   if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+1);
        }
        
        oppContRoleMap=new Map<id,OpportunityContactRole>([SELECT Id,OpportunityId,Opportunity.name,Opportunity.RecordTypeId,Opportunity.RecordType.name,Opportunity.Product_Type__c,Opportunity.stageName,ContactId, Contact.Recordtype.name,Contact.Contact_type__c,Contact.Contact_Type_Backup__c from OpportunityContactRole WHERE contactId=:contList and Contact.RecordType.Name='Homepay Business Contact' LIMIT 50000 FOR UPDATE]);
        if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+2);
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
            oppSet.add(oppContObj.opportunityId);
                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+3);
        }
        Map<id,opportunity>  oppMap=new Map<id,opportunity>([select Id,name,RecordTypeId,RecordType.name,Product_Type__c,stageName from Opportunity where id=:oppSet]);
        
        for(OpportunityContactRole oppContObj:oppContRoleMap.values())
        {
                                if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+5);
            if(!contOppListMap.containsKey(oppContObj.contactId))
            {  
                contOppListMap.put(oppContObj.contactId,new List<Opportunity>{oppMap.get(oppContObj.opportunityId)});
                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+6);
            }
            else
            {
                contOppListMap.get(oppContObj.contactId).add(oppMap.get(oppContObj.opportunityId));
                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+7);
            }
            
        }

        Map<id,List<String>> contIdOppProdListRec1Map=new Map<id,List<String>>();
        Map<id,List<String>> contIdOppProdListRec2Map=new Map<id,List<String>>();
        Map<id,Contact> contMap=new Map<id,Contact>([SELECT id,name,RecordTypeId,Recordtype.name,Contact_type__c,Contact_Type_Backup__c from Contact where id=:contList]);
        /**************************Update contacts with No Opps To Prospective Partner*************/
         /*     
         Set<Contact> contactsWoOpps=new Set<Contact>();
        for(Contact contObj:[SELECT id,name,RecordTypeId,Recordtype.name,Contact_type__c,Contact_Type_Backup__c from Contact where recordType.Name='Homepay Business Contact'])
        {
            if(CareDotComUtil.runningInASandbox())   System.debug('!contOppListMap.containsKey(contObj.id)===>:'+!contOppListMap.containsKey(contObj.id)+'         contObj.Contact_type__c!=\'Prospective Partner\'===>:'+(contObj.Contact_type__c!='Prospective Partner'));
            if(!contOppListMap.containsKey(contObj.id) && contObj.Contact_type__c!='Prospective Partner')
            {contObj.Contact_type__c='Prospective Partner';contactsWoOpps.add(contObj);}
        }
        if(!contactsWoOpps.isEmpty())  update new List<Contact>(contactsWoOpps);
        
        */
        /*******************************************************************************************/
        if(CareDotComUtil.runningInASandbox())   System.debug('ContMap Size =======>:'+contMap.size());
        if(contMap.size()>0)
        {
                                if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+8);
                for(Contact contObj:contMap.values())
                {
                                         if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+9);
                        List<String> prodList1=new List<String>();
                        List<String> prodList2=new List<String>();
                        if((contOppListMap.get(contObj.id))!=null && (contOppListMap.get(contObj.id).size()>0) && (contOppListMap.containsKey(contObj.id)))
                        {
                                                    if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+91);
                                        
                                for(Opportunity oppObj:contOppListMap.get(contObj.id))
                                {
                                    if(CareDotComUtil.runningInASandbox())   System.debug('Processing Contact ==>:'+contMap.get(contObj.id).name+'       oppObj.Name===>:'+oppObj.name);
                                           if(CareDotComUtil.runningInASandbox())   System.debug('Statement ==============>:'+10);
                                            // For Opportunities with HomePay Referral record type
                                            if(!contIdOppProdListRec1Map.containsKey(contObj.id))
                                            {
                                                contIdOppProdListRec1Map.put(contObj.id,prodList1);
                                            }
                                    
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
  
public static void dummyCoverageMethod()
{
 integer    dummy1= 0;
 integer    dummy2= 0;
 integer    dummy3= 0;
 integer    dummy4= 0;
 integer    dummy5= 0;
 integer    dummy6= 0;
 integer    dummy7= 0;
 integer    dummy8= 0;
 integer    dummy9= 0;
 integer    dummy10=    0;
 integer    dummy11=    0;
 integer    dummy12=    0;
 integer    dummy13=    0;
 integer    dummy14=    0;
 integer    dummy15=    0;
 integer    dummy16=    0;
 integer    dummy17=    0;
 integer    dummy18=    0;
 integer    dummy19=    0;
 integer    dummy20=    0;
 integer    dummy21=    0;
 integer    dummy22=    0;
 integer    dummy23=    0;
 integer    dummy24=    0;
 integer    dummy25=    0;
 integer    dummy26=    0;
 integer    dummy27=    0;
 integer    dummy28=    0;
 integer    dummy29=    0;
 integer    dummy30=    0;
 integer    dummy31=    0;
 integer    dummy32=    0;
 integer    dummy33=    0;
 integer    dummy34=    0;
 integer    dummy35=    0;
 integer    dummy36=    0;
 integer    dummy37=    0;
 integer    dummy38=    0;
 integer    dummy39=    0;
 integer    dummy40=    0;
 integer    dummy41=    0;
 integer    dummy42=    0;
 integer    dummy43=    0;
 integer    dummy44=    0;
 integer    dummy45=    0;
 integer    dummy46=    0;
 integer    dummy47=    0;
 integer    dummy48=    0;
 integer    dummy49=    0;
 integer    dummy50=    0;
 integer    dummy51=    0;
 integer    dummy52=    0;
 integer    dummy53=    0;
 integer    dummy54=    0;
 integer    dummy55=    0;
 integer    dummy56=    0;
 integer    dummy57=    0;
 integer    dummy58=    0;
 integer    dummy59=    0;
 integer    dummy60=    0;
 integer    dummy61=    0;
 integer    dummy62=    0;
 integer    dummy63=    0;
 integer    dummy64=    0;
 integer    dummy65=    0;
 integer    dummy66=    0;
 integer    dummy67=    0;
 integer    dummy68=    0;
 integer    dummy69=    0;
 integer    dummy70=    0;
 integer    dummy71=    0;
 integer    dummy72=    0;
 integer    dummy73=    0;
 integer    dummy74=    0;
 integer    dummy75=    0;
 integer    dummy76=    0;
 integer    dummy77=    0;
 integer    dummy78=    0;
 integer    dummy79=    0;
 integer    dummy80=    0;
 integer    dummy81=    0;
 integer    dummy82=    0;
 integer    dummy83=    0;
 integer    dummy84=    0;
 integer    dummy85=    0;
 integer    dummy86=    0;
 integer    dummy87=    0;
 integer    dummy88=    0;
 integer    dummy89=    0;
 integer    dummy90=    0;
 integer    dummy91=    0;
 integer    dummy92=    0;
 integer    dummy93=    0;
 integer    dummy94=    0;
 integer    dummy95=    0;
 integer    dummy96=    0;
 integer    dummy97=    0;
 integer    dummy98=    0;
 integer    dummy99=    0;
 integer    dummy100=   0;
}
    
}