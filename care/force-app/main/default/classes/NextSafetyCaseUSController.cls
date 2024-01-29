/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Lead Salesforce [sridharn@wavelabs.com]
** Modified Date:  03.26.2019
** Modified Date:  05.09.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-2041 Safety Next Case requiremet.
**             This is the Controller for Safety Next Case button on Home Page (NextSafetyCase.page). 
**             Only 'Q: Safety Alert' cases are assigns to users upon clicking on the button.
**             This is modified as part of SFORCE-2403 And SFORCE-3127 to avoid assigning the same case to more than one Rep
**             Introduced Locking and unlocking on Final Case to assign to single Rep
** _______________________________________________________________________________
*/
    public without sharing class NextSafetyCaseUSController
{

public NextSafetyCaseUSController(){}
    public NextSafetyCaseUSController(ApexPages.StandardController controller) {
    }

    

    
    public boolean dispError {get; set;}
    public boolean tryAgain {get; set;}
    
    public list<Case> UpdateList {get; set;}
     
    public boolean openconsoletabbool {get; set;}
    
    private transient String desiredURL;
    
    public string getDesiredURL(){return this.desiredURL;}
    
    public void setDesiredURL(String desiredURL){this.desiredURL=desiredURL;}
    
    public case TheFinalCase {get; set;}
    
    private Integer Queries_Limit = 0;
    
   /* all commented out in favor of BREeze/Omni
    public void FindNextCase() {
    
    
    
    transient Id TheUserId;
    
    transient Map<String,User_Controlled_Settings__c> safetyPriorityMatrixMap;
    
    transient Map<Integer,List<Id>> priorityCaseListMap;
    
    transient List<Integer> sortedCaseListByPriority=new List<Integer>();   
    
    tryAgain=false;
    
   
        transient Map<Integer,List<String>> typePriorityListMap=new Map<Integer,List<String>>();    
        transient Map<Id,Integer> caseIdSortedIndex=new Map<Id,Integer>();
        transient Map<Id,Integer> caseIdTimeDiffMap=new Map<Id,Integer>(); 
     
        updateList=new List<Case>();
        priorityCaseListMap = new Map<Integer,List<Id>>();
        safetyPriorityMatrixMap=new Map<String,User_Controlled_Settings__c>();
        
        loginUser=[
            SELECT id,language__c,UserRole.Name//,Platform__c,Tier__c
            FROM USER 
            WHERE ID=:UserInfo.getUserId()][0];
      
        openconsoletabbool = false;
        //TheFinalCase = new case();
        
        TheUserId = UserInfo.getUserId();
        
        //SLAMap = SLA_Exceeded_Amount__c.getAll();
/*
Commented below line as part of SFORCE-3182Next Safety Case Button: Convert to Standard Object So Member Care can Manage Threshold     
//List<Next_Safety_Case_Settings__mdt> safeyCustomSettingsList = new List<Next_Safety_Case_Settings__mdt>([SELECT Id,Label,DeveloperName,MasterLabel,Priority__c,Time_Threshold__c,Type__c,Volume_Threshold__c from Next_Safety_Case_Settings__mdt]);
* /
String nextSafetyCaseSettingsRecId=getRecordTypesStatic.recordTypeNameIdMap.get('Next Safety Case Settings');
List<User_Controlled_Settings__c> safeyCustomSettingsList = new List<User_Controlled_Settings__c>([SELECT Id,Name,RecordTypeId,Priority__c,Time_Threshold__c,Type__c,Volume_Threshold__c from User_Controlled_Settings__c where recordtypeid=:nextSafetyCaseSettingsRecId]);
if(CareDotComUtil.runningInASandbox()) 
System.debug('safeyCustomSettingsList size====>:'+safeyCustomSettingsList.size());
        for (User_Controlled_Settings__c safetyPriorityMatrix : safeyCustomSettingsList)
        {
            //safetyPriorityMatrixMap.put(safetyPriorityMatrix.Label,Integer.valueOf(safetyPriorityMatrix.Priority__c));
            safetyPriorityMatrixMap.put(safetyPriorityMatrix.Type__c,safetyPriorityMatrix);
            if(CareDotComUtil.runningInASandbox()) 
            System.debug('Reading custom metadata settings');
            
               if(typePriorityListMap.get(Integer.valueOf(safetyPriorityMatrix.Priority__c))==null)
                {
                    typePriorityListMap.put(Integer.valueOf(safetyPriorityMatrix.Priority__c),new List<String>{safetyPriorityMatrix.Type__c});
                    if(CareDotComUtil.runningInASandbox()) 
                    System.debug('Priority Map If...'+Integer.valueOf(safetyPriorityMatrix.Priority__c));
                }
                else 
                {
                    typePriorityListMap.get(Integer.valueOf(safetyPriorityMatrix.Priority__c)).add(safetyPriorityMatrix.Type__c);
                    if(CareDotComUtil.runningInASandbox()) 
                     System.debug('Priority Map Else...'+Integer.valueOf(safetyPriorityMatrix.Priority__c));
                }
            
        } 
        Process_Control_Values__mdt gmdt = [SELECT Safety_Next_Case_Queries_Threshold__c FROM Process_Control_Values__mdt where Label='Global']; 
        Queries_Limit = Integer.valueOf(gmdt.Safety_Next_Case_Queries_Threshold__c);
        if(CareDotComUtil.runningInASandbox()) 
        system.debug('Queries_Limit ----------------->>>>>'+Queries_Limit);
       
        if(CareDotComUtil.runningInASandbox()) 
            system.debug(safetyPriorityMatrixMap.values());
            
        Integer caseCount=0;
        User TheUser = [Select Id, Name, Language__c//, Platform__c, Tier__c 
                        FROM User 
                        WHERE Id =: TheUserId];
        
        //get list of queue memberships
        
        list<GroupMember> UserQueues = [Select Id, GroupId,Group.Name,UserOrGroupId 
                                        FROM GroupMember 
                                        WHERE  Group.Name = 'Q: Safety Alert' and UserOrGroupId =: TheUserId];
        if(CareDotComUtil.runningInASandbox())
            system.debug('UserQueues is -->:'+UserQueues);
        //Set<String> usersAllTierQueues=new Set<String>();
        Map<String,id> queueIdNameMap=new Map<String,id>();
        Set<id> userQueueIds=new Set<id>();
        //collect queue ids of queues that user is a member of
        for(GroupMember gm : UserQueues){
            userQueueIds.add(gm.groupId);
            if(CareDotComUtil.runningInASandbox()){
                system.debug('Queue Name Trim: ' + gm.Group.Name);
            }

            
       }
        if(CareDotComUtil.runningInASandbox())
            system.debug('userQueueIds -->:'+userQueueIds);
        list<Case> FinalCases = new list<Case>();
        
        //query all open cases and order them by age ()
        
        Id SafetyAlertRecordTypeId =getRecordTypesStatic.recordTypeNameIdMap.get('Safety Alert');
        transient Map<Id,Case> caseMap=new Map<Id,Case>();
        transient List<Case> QueryCases = [
            SELECT Id,Case_Age_Hours_Custom__c,CreatedDate, OwnerId, isClosed, ContactId,Contact.MemberID__c, ParentId, CaseNumber, Owner.Name, Subject,Member_Type__c//,Tier__c
            FROM Case 
            WHERE 
                OwnerId in :userQueueIds and 
                subject not in ('Care Q\'s','rejected-recruiting','eBureau check','rejected-agency as individual','rejected-other','rejected-age','rejected-individualAsAgency','High Touch Rejected-Insufficient') and 
                Member_Type__c!='lite' and 
                isClosed = false and 
                ((Status = 'New' and Current_Member_Status__c!='Closed') or (Status = 'Reopened')) 
                and recordTypeId =:SafetyAlertRecordTypeId  
                ORDER BY CreatedDate ASC 
                LIMIT 50000];

        if(CareDotComUtil.runningInASandbox()) 
        system.debug('QueryCases -->:'+QueryCases.size());
        if(CareDotComUtil.runningInASandbox())
        {
            //system.debug('queueIdNameMap.values()==>:'+queueIdNameMap.values());
            //system.debug('QueryCases==>:'+QueryCases);
        }
Integer index=0;
            priorityCaseListMap = new Map<Integer,List<Id>>();

        for(Case AssignCase : QueryCases)
        {
            caseMap.put(AssignCase.id,AssignCase);
            caseIdSortedIndex.put(AssignCase.Id,++index);
            //Next_Safety_Case_Settings__mdt caseSLAThresholdSettings=safetyPriorityMatrixMap.get(qIdToCountryCode.get(AssignCase.OwnerId));
            //Priority,Time Threshold, Volume Threshold
            if(!AssignCase.subject.startsWith('Flagged by Member') && safetyPriorityMatrixMap.containsKey(AssignCase.subject))
            //if(!AssignCase.subject.startsWith('Flagged by Member') && safetyPriorityMatrixMap.get(AssignCase.subject)!=null)
            {
                if(!priorityCaseListMap.containsKey(Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c)))
                //if(priorityCaseListMap.get(Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c))==null)
                {
                    priorityCaseListMap.put(Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c),new List<Id>{AssignCase.id});
                    if(CareDotComUtil.runningInASandbox()) 
                    System.debug('Priority========>:'+Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c)+'-----'+AssignCase.id);
                }
                else 
                {
                    priorityCaseListMap.get(Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c)).add(AssignCase.id);
                    if(CareDotComUtil.runningInASandbox()) 
                    System.debug('Priority========>:'+Integer.valueOf(safetyPriorityMatrixMap.get(AssignCase.subject).Priority__c)+'-----'+AssignCase.id);
                }
                
            }
            else if(AssignCase.subject.startsWith('Flagged by Member') && safetyPriorityMatrixMap.containsKey('Flagged by Member'))
 //           else if(AssignCase.subject.startsWith('Flagged by Member') && safetyPriorityMatrixMap.get('Flagged by Member')!=null)
            {
                if(!priorityCaseListMap.containsKey(Integer.valueOf(safetyPriorityMatrixMap.get('Flagged by Member').Priority__c)))
                  //if(priorityCaseListMap.get(Integer.valueOf(safetyPriorityMatrixMap.get('Flagged by Member').Priority__c))==null)
                {
                    priorityCaseListMap.put(Integer.valueOf(safetyPriorityMatrixMap.get('Flagged by Member').Priority__c),new List<Id>{AssignCase.id});
                }
                else 
                {
                    priorityCaseListMap.get(Integer.valueOf(safetyPriorityMatrixMap.get('Flagged by Member').Priority__c)).add(AssignCase.id);
                }
                
            }
            
            datetime caseCreatedDate= AssignCase.createdDate;
            datetime currentTime = datetime.now();
            decimal millisecs = decimal.valueOf(currentTime.getTime() - caseCreatedDate.getTime());
            if(CareDotComUtil.runningInASandbox()) 
            system.debug('millisecs: ' +millisecs);
            
            decimal diffHoursDeci= millisecs/1000/60/60;
            if(CareDotComUtil.runningInASandbox()) 
            system.debug('diffHoursDeci: ' +diffHoursDeci);
            integer diffHours = integer.valueOf(math.ceil(diffHoursDeci));
            if(CareDotComUtil.runningInASandbox()) 
            system.debug('diffHours: ' +diffHours);
            caseIdTimeDiffMap.put(AssignCase.id,diffHours);
            if(CareDotComUtil.runningInASandbox()) 
            System.debug('Assign Case Time Difference ====>:'+AssignCase.id+'--------'+diffHours);
        }
        if(CareDotComUtil.runningInASandbox()) 
        System.debug('priorityCaseListMap.keySet()=======>:'+priorityCaseListMap.keySet());
        sortedCaseListByPriority= new List<Integer>(priorityCaseListMap.keySet());
        sortedCaseListByPriority.sort();
       //descOrderSLAExceededCasesList.add(new SObjectWrapper(Integer.valueOf(dec)));
       if(CareDotComUtil.runningInASandbox()) 
System.debug('sortedCaseListByPriority===========>:'+sortedCaseListByPriority);
        for(Integer casePriority:sortedCaseListByPriority)
        {
            for(Id caseId:priorityCaseListMap.get(casePriority))
            {
                if(caseIdTimeDiffMap.get(caseId)>Integer.valueOf(safetyPriorityMatrixMap.get(caseMap.get(caseId).subject.startsWith('Flagged by Member')?'Flagged by Member':caseMap.get(caseId).subject).Time_Threshold__c))
                {
                ThefinalCase=caseMap.get(caseId);
                if(CareDotComUtil.runningInASandbox()) 
                System.debug('casePriority====>:'+casePriority+'-----ThefinalCase=======>:'+ThefinalCase);
                break;
                }
            }
            if(ThefinalCase==null)
            {
                if(priorityCaseListMap.get(casePriority)!=null && priorityCaseListMap.get(casePriority).size()>Integer.valueOf(safetyPriorityMatrixMap.get((typePriorityListMap.get(casePriority))[0]).Volume_Threshold__c))
                {
                    ThefinalCase=caseMap.get(priorityCaseListMap.get(casePriority).get(0));
                    if(CareDotComUtil.runningInASandbox()) 
                    System.debug('casePriority====>:'+casePriority+'-----ThefinalCase=======>:'+ThefinalCase);
                }
            }
            
            if(ThefinalCase!=null) 
            {
                break;
            
            }
         } 
       if(ThefinalCase==null && QueryCases!=null && !QueryCases.isEmpty())
       {
           if(!sortedCaseListByPriority.isEmpty())
           {
               for(Integer priority : sortedCaseListByPriority)
               {
                   ThefinalCase = caseMap.get(priorityCaseListMap.get(priority)[0]); 
                   if(CareDotComUtil.runningInASandbox()) 
                   System.debug('ThefinalCase=======>:'+ThefinalCase);
                   break;
               }    
           }
           if(ThefinalCase==null)    
           {
           ThefinalCase=QueryCases[0];
           if(CareDotComUtil.runningInASandbox()) 
           System.debug('ThefinalCase  doesnt meet safety next case criteria and considering oldest case in Q:Safety Alert case'+ThefinalCase);
           }
       }
       
        if(ThefinalCase!=null){
            //find child cases (other open Cases by same member in queue of same country/language as final case)
            if (ThefinalCase.ContactId != null) {
                for(Case childCase : QueryCases) {
                    //if(childCase.contactId == ThefinalCase.contactId && childCase.id != ThefinalCase.id ) {
                    //if(childCase.OwnerId== ThefinalCase.OwnerId  && childCase.contact.MemberID__c == ThefinalCase.contact.MemberID__c && childCase.id != ThefinalCase.id) {
                    if(childCase.OwnerId== ThefinalCase.OwnerId  && childCase.contactId== ThefinalCase.contactId&& childCase.id != ThefinalCase.id) {
                        childCase.ParentId = ThefinalCase.Id; //link child to parent
                        childCase.OwnerId = TheUserId; //assign child cases to user
                        updateList.add(childCase);
                    }
                }
            }
            
            ThefinalCase.OwnerId = TheUserId; //assign final case to user
            ThefinalCase.parentId=null;
            updateList.add(ThefinalCase);
            dispError = false;
            pageReference opencasePage;
            if(apexpages.currentpage() != null && apexpages.currentpage().getURL()!=null && apexpages.currentpage().getURL().contains('console')){
                openCasePage = new pageReference('/console?tsid=' + ThefinalCase.Id);
                openconsoletabbool = true;
            }
            else
                {
                openCasePage = new pageReference('/' + ThefinalCase.Id);
                }
            
            desiredURL = openCasePage.getURL();
            //desiredURL = 'https://caredotcom--force2.my.salesforce.com'+'/' + ThefinalCase.Id;
            if(CareDotComUtil.runningInASandbox())
                system.debug('URL of TheFinalCase: ' + desiredURL);
        }
    }
    */

    public void returnLink(){   
        //this.FindNextCase(); 
        
        if(updateList == null || updateList.isempty()){
            dispError=true;
            }
        else //if(updateList.isempty())
        {
            Approval.LockResult[] lrList=Approval.lock(updateList, true);
            List<Case> caseList=new List<Case>([select id from case where id=:updateList and (not owner.name like 'Q:%')]);
            if(lrList[0].isSuccess() && caseList.isEmpty()){
                try{
                        update updateList;
                    }catch(Exception e){
                        System.debug('Exception occured================>> '+e);
                        dispError=true;
                    }                      
                
                }else if (!caseList.isEmpty() && Limits.getQueries() <= Queries_Limit){
                    if(CareDotComUtil.runningInASandbox()) 
                    system.debug('Iterating ================>> within getQueries() Limit'+Limits.getQueries());
                    Approval.UnlockResult[] urList = Approval.unlock(updateList, true); 
                    returnLink();
                 }else { 
                    if(CareDotComUtil.runningInASandbox())  
                    system.debug('Notifying user to retry once again================>>  Exceeding getQueries() Limit'+Limits.getQueries());
                    tryAgain =true;                  
                 } 
             
             Approval.UnlockResult[] urList = Approval.unlock(updateList, true); 
         }
         /**else 
        {
            System.debug('getAggregateQueries()----------->'+ Limits.getAggregateQueries());
            System.debug('getCpuTime()---------->'+ Limits.getCpuTime());           
            System.debug('getHeapSize()----------->'+  Limits.getHeapSize());
            System.debug('getDMLRows()----------->'+  Limits.getDMLRows());                        
            System.debug('getDMLStatements()----------->'+ Limits.getDMLStatements());
            System.debug('getQueries()----------->'+ Limits.getQueries()); 
            System.debug('getQueryRows()----------->'+ Limits.getQueryRows());
            System.debug('getQueryLocatorRows()----------->'+ Limits.getQueryLocatorRows());
            if( Limits.getQueries() > 80 ){
                System.debug('getQueries()-----------Try Again1001>'+ Limits.getQueries());     
                tryAgain = true;                  
            }
            else                                     
                returnLink();
            
        } **/
    }
    
    public PageReference returnLinkAction(){
        this.returnLink();
        return null;
    }


    public User loginUser{get;set;}
    
        public boolean getIsQSafetyAlertMember()
    {
        List<GroupMember> grpMember=new List<GroupMember>([Select id from GroupMember where userorgroupid=:UserInfo.getUserId()]);
        return grpMember.isEmpty()?false:true;
    }

}