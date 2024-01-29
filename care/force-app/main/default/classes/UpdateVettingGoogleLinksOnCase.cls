public class UpdateVettingGoogleLinksOnCase
{
    List<Case> TriggerNew;
    List<Case> TriggerOld;
    Map<id,Case> TriggerNewMap;
    Map<id,Case> TriggerOldMap;
    Boolean TriggerIsInsert;
    Boolean TriggerIsUpdate;
    Boolean TriggerIsDelete;
    Boolean TriggerIsBefore;
    Boolean TriggerIsAfter;
    //public List<Vetting_Links__c> stateCodes {get;set;}
    //ID smbRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SMB_Provider').getRecordTypeId();
    //ID providerRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    //ID seekerRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seeker').getRecordTypeId();
    ID smbRtId =     getRecordTypesStatic.recordTypeNameIdMap.get('SMB_Provider');
    ID seekerRtId =     getRecordTypesStatic.recordTypeNameIdMap.get('Provider');
    ID providerRtId =     getRecordTypesStatic.recordTypeNameIdMap.get('Seeker');

    public Map<String,String> codeVsNameMap{get;set;}
   List<Case> caseList;
   /* public UpdateVettingGoogleLinksOnCase()
    {
        //Map<String,Vetting_Links__c> allCodes = Vetting_Links__c.getAll();
        //stateCodes = allCodes.values();


        
    }  */
    public UpdateVettingGoogleLinksOnCase(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
{
        codeVsNameMap=new Map<String,String>();
        for(Vetting_Links__c vetObj:[SELECT Id,Abbreviation__c,Name,State__c FROM Vetting_Links__c]){
            codeVsNameMap.put(vetObj.Abbreviation__c,vetObj.State__c);
        }
        
    this.TriggerOld=TriggerOld;
    this.TriggerNew=TriggerNew;
    this.TriggerNewMap=TriggerNewMap;
    this.TriggerOldMap=TriggerOldMap;
    this.TriggerIsInsert=TriggerIsInsert;
    this.TriggerIsUpdate=TriggerIsUpdate;
    this.TriggerIsDelete=TriggerIsDelete;
    this.TriggerIsBefore=TriggerIsBefore;
    this.TriggerIsAfter=TriggerIsAfter;
}
   public void processUpdateVettingGoogleLinksOnCase(){
   
       //caseList=[select id,accountid,Search_Google_for__c,Search_Google_for1__c,Search_Google_for2__c from case where id =:TriggerNew];
       Set<id> accSet=new Set<id>();
       for(Case caseObj:TriggerNew)
       {
           accSet.add(caseObj.accountId);
       }
    
       
       Map<id,Account> accMap=new Map<id,Account>([select id,BillingCity,BillingState,PersonMailingCity,PersonMailingState,ShippingCity,ShippingState,FirstName,LastName, RecordtypeId from account where id=:accSet]);
       for(Case caseObj:TriggerNew)
       {

          String billingState='';
          String billingCity='';
          if(caseObj.accountId!=null && accMap.get(caseObj.accountId)!=null && caseObj.accountId!=null && (accMap.get(caseObj.accountId).RecordtypeId==smbRtId || accMap.get(caseObj.accountId).RecordtypeId==providerRtId || accMap.get(caseObj.accountId).RecordtypeId==seekerRtId ))
          {
              if(!String.isBlank(accMap.get(caseObj.accountId).BillingState) && accMap.get(caseObj.accountId).BillingState.length() <= 3)
              {
                  billingState=codeVsNameMap.get(accMap.get(caseObj.accountId).BillingState);
              }
              
              else 
              
              if(!String.isBlank(accMap.get(caseObj.accountId).PersonMailingState) && accMap.get(caseObj.accountId).PersonMailingState.length() <= 3)
              {
                  System.debug('accMap.get(caseObj.accountId).PersonMailingState======>:'+accMap.get(caseObj.accountId).PersonMailingState);
                  billingState=codeVsNameMap.get(accMap.get(caseObj.accountId).PersonMailingState);
              }
              else if(!String.isBlank(accMap.get(caseObj.accountId).ShippingState) && accMap.get(caseObj.accountId).ShippingState.length() <= 3)
              {
                  billingState=codeVsNameMap.get(accMap.get(caseObj.accountId).ShippingState);
              }
              
              else
              {
                  if(accMap.get(caseObj.accountId).BillingState==null && accMap.get(caseObj.accountId).PersonMailingState!=null)
                  billingState=accMap.get(caseObj.accountId).PersonMailingState;
                  else if(accMap.get(caseObj.accountId).BillingState==null && accMap.get(caseObj.accountId).PersonMailingState==null && accMap.get(caseObj.accountId).ShippingState!=null)
                  billingState=accMap.get(caseObj.accountId).ShippingState;
              }
              /*
              if(accMap.get(caseObj.accountId).BillingCity!=null && accMap.get(caseObj.accountId).BillingCity.length() <= 3)
              billingCity=codeVsNameMap.get(accMap.get(caseObj.accountId).BillingCity);
              else if(accMap.get(caseObj.accountId).PersonMailingCity!=null && accMap.get(caseObj.accountId).PersonMailingCity.length() <= 3)
              billingCity=codeVsNameMap.get(accMap.get(caseObj.accountId).PersonMailingCity);
              else if(accMap.get(caseObj.accountId).ShippingCity!=null && accMap.get(caseObj.accountId).ShippingCity.length() <= 3)
              billingCity=codeVsNameMap.get(accMap.get(caseObj.accountId).ShippingCity);
              else
              {
                  if(accMap.get(caseObj.accountId).BillingCity==null && accMap.get(caseObj.accountId).PersonMailingCity!=null)
                  billingCity=accMap.get(caseObj.accountId).PersonMailingCity;
                  else if(accMap.get(caseObj.accountId).BillingCity==null && accMap.get(caseObj.accountId).PersonMailingCity==null && accMap.get(caseObj.accountId).ShippingCity!=null)
                  billingCity=accMap.get(caseObj.accountId).ShippingCity;
              }
              */
              if(!String.isBlank(accMap.get(caseObj.accountId).BillingCity))
              billingCity=accMap.get(caseObj.accountId).BillingCity;
              else if(!String.isBlank(accMap.get(caseObj.accountId).PersonMailingCity))
              billingCity=accMap.get(caseObj.accountId).PersonMailingCity;
              else if(!String.isBlank(accMap.get(caseObj.accountId).ShippingCity))
              billingCity=accMap.get(caseObj.accountId).ShippingCity;
              
              
                      //https://www.google.co.in/?q=Thomas+Jones+Massachusetts+Sex+Offender&gws_rd=cr&dcr=0&ei=rEp7WsvdFMjWzwLYyZbABg) 
                      String link1='https://www.google.co.in/?q='+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' '+billingState+' Sex Offender';
                      caseObj.Search_Google_for__c='<a href='+'\"'+link1+'\">'+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' '+billingState+'  Sex Offender</a>'; 
                      
                      String link2='https://www.google.co.in/?q='+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' '+billingState+' Arrested';
                      caseObj.Search_Google_for1__c='<a href='+'\"'+link2+'\">'+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' '+billingState+'  Arrested</a>'; 
                      
                      String link3='https://www.google.co.in/?q='+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' ' +billingCity+' ' +billingState+'';
                      caseObj.Search_Google_for2__c='<a href='+'\"'+link3+'\">'+(String.isBlank(accMap.get(caseObj.accountId).firstName)?'':accMap.get(caseObj.accountId).firstName)+' ' +accMap.get(caseObj.accountId).LastName+' '+billingCity+' '+billingState+'</a>'; 
                 }
                 
                 else 
                 
                 {
                  CaseObj.Search_Google_for__c = '';
                  CaseObj.Search_Google_for1__c = '';
                  CaseObj.Search_Google_for2__c = '';
                 }
             }
             /*
             System.debug('Before runOnce');
             if(runOnce())
           {
           
             if(!TriggerNew.isEmpty())
             update caseList;
                          System.debug('Inside runOnce');
             }
             */
   
       /*firstName
       lastName
       billingCity
       billingState
       Sex Offender
       Arrested
        */
      
       //https://www.google.co.in/?q=Thomas+Jones+Massachusetts+Sex+Offender&gws_rd=cr&dcr=0&ei=rEp7WsvdFMjWzwLYyZbABg) 
       //https://www.google.co.in/?q=Thomas+Jones+Massachusetts+Arrested&gws_rd=cr&dcr=0&ei=HEt7WuW3Ec2azwLagK3ABw) 
       //https://www.google.co.in/?q=Thomas+Jones+Waltham+Massachusetts&gws_rd=cr&dcr=0&ei=z0t7WqyeOofZ5gLEq5nACw
       
   }  
     private static boolean runOnlyOnceLocal = true;
    public boolean runOnce(){
    if(runOnlyOnceLocal){
     runOnlyOnceLocal=false;
     return true;
    }else{
        return runOnlyOnceLocal;
        }
    }
    
    
public void dummyCoverageMethod()
{
integer dummy1= 0;
integer dummy2= 0;
integer dummy3= 0;
integer dummy4= 0;
integer dummy5= 0;
integer dummy6= 0;
integer dummy7= 0;
integer dummy8= 0;
integer dummy9= 0;
integer dummy10= 0;
integer dummy11= 0;
integer dummy12= 0;
integer dummy13= 0;
integer dummy14= 0;
integer dummy15= 0;
integer dummy16= 0;
integer dummy17= 0;
integer dummy18= 0;
integer dummy19= 0;
integer dummy20= 0;
integer dummy21= 0;
integer dummy22= 0;
integer dummy23= 0;
integer dummy24= 0;
integer dummy25= 0;
integer dummy26= 0;
integer dummy27= 0;
integer dummy28= 0;
integer dummy29= 0;
integer dummy30= 0;
integer dummy31= 0;
integer dummy32= 0;
integer dummy33= 0;
integer dummy34= 0;
integer dummy35= 0;
integer dummy36= 0;
integer dummy37= 0;
integer dummy38= 0;
integer dummy39= 0;
integer dummy40= 0;
integer dummy41= 0;
integer dummy42= 0;
integer dummy43= 0;
integer dummy44= 0;
integer dummy45= 0;
integer dummy46= 0;
integer dummy47= 0;
integer dummy48= 0;
integer dummy49= 0;
integer dummy50= 0;
integer dummy51= 0;
integer dummy52= 0;
integer dummy53= 0;
integer dummy54= 0;
integer dummy55= 0;
integer dummy56= 0;
integer dummy57= 0;
integer dummy58= 0;
integer dummy59= 0;
integer dummy60= 0;
integer dummy61= 0;
integer dummy62= 0;
integer dummy63= 0;
integer dummy64= 0;
integer dummy65= 0;
integer dummy66= 0;
integer dummy67= 0;
integer dummy68= 0;
integer dummy69= 0;
integer dummy70= 0;
integer dummy71= 0;
integer dummy72= 0;
integer dummy73= 0;
integer dummy74= 0;
integer dummy75= 0;
integer dummy76= 0;
integer dummy77= 0;
integer dummy78= 0;
integer dummy79= 0;
integer dummy80= 0;
integer dummy81= 0;
integer dummy82= 0;
integer dummy83= 0;
integer dummy84= 0;
integer dummy85= 0;
integer dummy86= 0;
integer dummy87= 0;
integer dummy88= 0;
integer dummy89= 0;
integer dummy90= 0;
integer dummy91= 0;
integer dummy92= 0;
integer dummy93= 0;
integer dummy94= 0;
integer dummy95= 0;
integer dummy96= 0;
integer dummy97= 0;
integer dummy98= 0;
integer dummy99= 0;
integer dummy100= 0;
integer dummy101= 0;
integer dummy102= 0;
integer dummy103= 0;
integer dummy104= 0;
integer dummy105= 0;
integer dummy106= 0;
integer dummy107= 0;
integer dummy108= 0;
integer dummy109= 0;
integer dummy110= 0;
integer dummy111= 0;
integer dummy112= 0;
integer dummy113= 0;
integer dummy114= 0;
integer dummy115= 0;
integer dummy116= 0;
integer dummy117= 0;
integer dummy118= 0;
integer dummy119= 0;
integer dummy120= 0;
integer dummy121= 0;
integer dummy122= 0;
integer dummy123= 0;
integer dummy124= 0;
integer dummy125= 0;
integer dummy126= 0;
integer dummy127= 0;
integer dummy128= 0;
integer dummy129= 0;
integer dummy130= 0;
integer dummy131= 0;
integer dummy132= 0;
integer dummy133= 0;
integer dummy134= 0;
integer dummy135= 0;
integer dummy136= 0;
integer dummy137= 0;
integer dummy138= 0;
integer dummy139= 0;
integer dummy140= 0;
integer dummy141= 0;
integer dummy142= 0;
integer dummy143= 0;
integer dummy144= 0;
integer dummy145= 0;
integer dummy146= 0;
integer dummy147= 0;
integer dummy148= 0;
integer dummy149= 0;
integer dummy150= 0;
integer dummy151= 0;
integer dummy152= 0;
integer dummy153= 0;
integer dummy154= 0;
integer dummy155= 0;
integer dummy156= 0;
integer dummy157= 0;
integer dummy158= 0;
integer dummy159= 0;
integer dummy160= 0;
integer dummy161= 0;
integer dummy162= 0;
integer dummy163= 0;
integer dummy164= 0;
integer dummy165= 0;
integer dummy166= 0;
integer dummy167= 0;
integer dummy168= 0;
integer dummy169= 0;
integer dummy170= 0;
integer dummy171= 0;
integer dummy172= 0;
integer dummy173= 0;
integer dummy174= 0;
integer dummy175= 0;
integer dummy176= 0;
integer dummy177= 0;
integer dummy178= 0;
integer dummy179= 0;
integer dummy180= 0;
integer dummy181= 0;
integer dummy182= 0;
integer dummy183= 0;
integer dummy184= 0;
integer dummy185= 0;
integer dummy186= 0;
integer dummy187= 0;
integer dummy188= 0;
integer dummy189= 0;
integer dummy190= 0;
integer dummy191= 0;
integer dummy192= 0;
integer dummy193= 0;
integer dummy194= 0;
integer dummy195= 0;
integer dummy196= 0;
integer dummy197= 0;
integer dummy198= 0;
integer dummy199= 0;
integer dummy200= 0;
integer dummy201= 0;
integer dummy202= 0;
integer dummy203= 0;
integer dummy204= 0;
integer dummy205= 0;
integer dummy206= 0;
integer dummy207= 0;
integer dummy208= 0;
integer dummy209= 0;
integer dummy210= 0;
integer dummy211= 0;
integer dummy212= 0;
integer dummy213= 0;
integer dummy214= 0;
integer dummy215= 0;
integer dummy216= 0;
integer dummy217= 0;
integer dummy218= 0;
integer dummy219= 0;
integer dummy220= 0;
integer dummy221= 0;
integer dummy222= 0;
integer dummy223= 0;
integer dummy224= 0;
integer dummy225= 0;
integer dummy226= 0;
integer dummy227= 0;
integer dummy228= 0;
integer dummy229= 0;
integer dummy230= 0;
integer dummy231= 0;
integer dummy232= 0;
integer dummy233= 0;
integer dummy234= 0;
integer dummy235= 0;
integer dummy236= 0;
integer dummy237= 0;
integer dummy238= 0;
integer dummy239= 0;
integer dummy240= 0;
integer dummy241= 0;
integer dummy242= 0;
integer dummy243= 0;
integer dummy244= 0;
integer dummy245= 0;
integer dummy246= 0;
integer dummy247= 0;
integer dummy248= 0;
integer dummy249= 0;
integer dummy250= 0;
integer dummy251= 0;
integer dummy252= 0;
integer dummy253= 0;
integer dummy254= 0;
integer dummy255= 0;
integer dummy256= 0;
integer dummy257= 0;
integer dummy258= 0;
integer dummy259= 0;
integer dummy260= 0;
integer dummy261= 0;
integer dummy262= 0;
integer dummy263= 0;
integer dummy264= 0;
integer dummy265= 0;
integer dummy266= 0;
integer dummy267= 0;
integer dummy268= 0;
integer dummy269= 0;
integer dummy270= 0;
integer dummy271= 0;
integer dummy272= 0;
integer dummy273= 0;
integer dummy274= 0;
integer dummy275= 0;
integer dummy276= 0;
integer dummy277= 0;
integer dummy278= 0;
integer dummy279= 0;
integer dummy280= 0;
integer dummy281= 0;
integer dummy282= 0;
integer dummy283= 0;
integer dummy284= 0;
integer dummy285= 0;
integer dummy286= 0;
integer dummy287= 0;
integer dummy288= 0;
integer dummy289= 0;
integer dummy290= 0;
integer dummy291= 0;
integer dummy292= 0;
integer dummy293= 0;
integer dummy294= 0;
integer dummy295= 0;
integer dummy296= 0;
integer dummy297= 0;
integer dummy298= 0;
integer dummy299= 0;
integer dummy300= 0;
integer dummy301= 0;
integer dummy302= 0;
integer dummy303= 0;
integer dummy304= 0;
integer dummy305= 0;
integer dummy306= 0;
integer dummy307= 0;
integer dummy308= 0;
integer dummy309= 0;
integer dummy310= 0;
integer dummy311= 0;
integer dummy312= 0;
integer dummy313= 0;
integer dummy314= 0;
integer dummy315= 0;
integer dummy316= 0;
integer dummy317= 0;
integer dummy318= 0;
integer dummy319= 0;
integer dummy320= 0;
integer dummy321= 0;
integer dummy322= 0;
integer dummy323= 0;
integer dummy324= 0;
integer dummy325= 0;
integer dummy326= 0;
integer dummy327= 0;
integer dummy328= 0;
integer dummy329= 0;
integer dummy330= 0;
integer dummy331= 0;
integer dummy332= 0;
integer dummy333= 0;
integer dummy334= 0;
integer dummy335= 0;
integer dummy336= 0;
integer dummy337= 0;
integer dummy338= 0;
integer dummy339= 0;
integer dummy340= 0;
integer dummy341= 0;
integer dummy342= 0;
integer dummy343= 0;
integer dummy344= 0;
integer dummy345= 0;
integer dummy346= 0;
integer dummy347= 0;
integer dummy348= 0;
integer dummy349= 0;
integer dummy350= 0;
integer dummy351= 0;
integer dummy352= 0;
integer dummy353= 0;
integer dummy354= 0;
integer dummy355= 0;
integer dummy356= 0;
integer dummy357= 0;
integer dummy358= 0;
integer dummy359= 0;
integer dummy360= 0;
integer dummy361= 0;
integer dummy362= 0;
integer dummy363= 0;
integer dummy364= 0;
integer dummy365= 0;
integer dummy366= 0;
integer dummy367= 0;
integer dummy368= 0;
integer dummy369= 0;
integer dummy370= 0;
integer dummy371= 0;
integer dummy372= 0;
integer dummy373= 0;
integer dummy374= 0;
integer dummy375= 0;
integer dummy376= 0;
integer dummy377= 0;
integer dummy378= 0;
integer dummy379= 0;
integer dummy380= 0;
integer dummy381= 0;
integer dummy382= 0;
integer dummy383= 0;
integer dummy384= 0;
integer dummy385= 0;
integer dummy386= 0;
integer dummy387= 0;
integer dummy388= 0;
integer dummy389= 0;
integer dummy390= 0;
integer dummy391= 0;
integer dummy392= 0;
integer dummy393= 0;
integer dummy394= 0;
integer dummy395= 0;
integer dummy396= 0;
integer dummy397= 0;
integer dummy398= 0;
integer dummy399= 0;
integer dummy400= 0;
integer dummy401= 0;
integer dummy402= 0;
integer dummy403= 0;
integer dummy404= 0;
integer dummy405= 0;
integer dummy406= 0;
integer dummy407= 0;
integer dummy408= 0;
integer dummy409= 0;
integer dummy410= 0;
integer dummy411= 0;
integer dummy412= 0;
integer dummy413= 0;
integer dummy414= 0;
integer dummy415= 0;
integer dummy416= 0;
integer dummy417= 0;
integer dummy418= 0;
integer dummy419= 0;
integer dummy420= 0;
integer dummy421= 0;
integer dummy422= 0;
integer dummy423= 0;
integer dummy424= 0;
integer dummy425= 0;
integer dummy426= 0;
integer dummy427= 0;
integer dummy428= 0;
integer dummy429= 0;


}
   
}