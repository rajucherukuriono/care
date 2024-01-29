/*
** _______________________________________________________________________________
** Created by:    Wavelabs [https://www.wavelabs.ai]
** Developer:     Sridhar, Salesforce Architect [sridhar.neeli@care.com]
** Created Date:  08.15.2019
** ===============================================================================
** Description: 
** This class defines several rules which restricts access to deletion of cases.
** 
** ______________________________________________________________________________
*/
public class CaseDataDeletionAccessTrigger
{
// on Case (before Delete) {
List<Case> TriggerNew;
List<Case> TriggerOld;
Map<id,Case> TriggerNewMap;
Map<id,Case> TriggerOldMap;
Boolean TriggerIsInsert;
Boolean TriggerIsUpdate;
Boolean TriggerIsDelete;
Boolean TriggerIsBefore;
Boolean TriggerIsAfter;

public CaseDataDeletionAccessTrigger(){
}
public CaseDataDeletionAccessTrigger(List<Case> TriggerNew,List<Case> TriggerOld,Map<id,Case> TriggerNewMap,Map<id,Case> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
{
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
public void processCaseDataDeletionAccessTrigger()
{
if(TriggerIsBefore && TriggerIsDelete)
{
Map<id,Data_Deletion_Rules__mdt>   dataDelRuleSettings=new Map<id,Data_Deletion_Rules__mdt>([SELECT Error_Message__c,DeveloperName,Id,Label,MasterLabel,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where SObject_Name__c='Case' and Override_Data_Deletion__c=false]);
Map<id,Case> deniedDelMap=new Map<id,Case>();
Map<id,boolean> haveDelPermission=new Map<id,boolean>();
Map<id,Data_Deletion_Rules__mdt> deniedDelErrMsgMap=new Map<id,Data_Deletion_Rules__mdt>();
Map<id,Integer> noMatchInAllCustSetgs=new Map<id,Integer>();
    for(Data_Deletion_Rules__mdt ddrObj:dataDelRuleSettings.values())
    {
    
        Map<String,id> recNameIdMap=null;
        if(!String.isBlank(ddrObj.Record_Type__c))
        {
        if(CareDotComUtil.runningInASandbox()) System.debug('ddrObj.Record_Type__c.split(\';\')==>:'+ddrObj.Record_Type__c.split(';'));
        getRecordTypesStatic.filteredRecNameIdMap=null;
        recNameIdMap=getRecordTypesStatic.getFilteredRecNameIdMap(ddrObj.Record_Type__c.split(';'));
        if(CareDotComUtil.runningInASandbox()) System.debug('recNameIdMap==>:'+recNameIdMap);
        }
        
        //if(CareDotComUtil.runningInASandbox()) System.debug('restricted rec Types====>:'+getSQLStringFromDelimitedList(ddrObj.Record_Type__c));
        Map<id,String> recIdNameMap =null;
        if(!recNameIdMap.isEmpty())
        recIdNameMap =getRecordTypeIdNameMap(recNameIdMap);   
        if(CareDotComUtil.runningInASandbox()) System.debug('ddrObj.Record_Type__c==>:'+ddrObj.Record_Type__c+'    recNameIdMap====>:'+recNameIdMap+'recIdNameMap===>:'+recIdNameMap);
        
        if(!dataDelRuleSettings.isEmpty() && !ddrObj.Override_Data_Deletion__c)
        {
        

            List<String> permissionSetList=null;
            if(!String.isBlank(ddrObj.Permission_Set_Name__c))
            permissionSetList=ddrObj.Permission_Set_Name__c.split(';');
            
            List<String> profileList=null;
            if(!String.isBlank(ddrObj.Profile_Name__c))
            profileList=ddrObj.Profile_Name__c.split(';');
            
            List<String> userList= null;
            if(!String.isBlank(ddrObj.User_Name__c))
            userList= ddrObj.User_Name__c.split(';');
            
            List<AggregateResult> permQuery= null;
            if(permissionSetList!=null && !permissionSetList.isEmpty())
            permQuery= [SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and permissionSet.label=:permissionSetList];
            
            List<AggregateResult> profQuery=null;
            if(profileList!=null && !profileList.isEmpty())
            {
             if(CareDotComUtil.runningInASandbox()) System.debug('profileList ==>:'+profileList +'   Userinfo.getUserId()===>:'+Userinfo.getUserId());
            profQuery=[select count(id) from user where Profile.Name=:profileList and id=:Userinfo.getUserId()];
            }
             if(CareDotComUtil.runningInASandbox()) System.debug('profQuery===>:'+profQuery);
        for(Case caseObj:TriggerOld)
        {
             //if(recNameIdMap.get(caseObj.recordTypeId)   permQuery[0].get('expr0')==0)
            //System.debug((recIdNameMap.containsKey(caseObj.recordTypeId))+ '   '+ (permQuery[0].get('expr0')==0)+ '   '+ (profQuery[0].get('expr0')==0)+'  userList=>:'+userList);
System.debug((userList==null)+'1===>:'+ (userList!=null && !userList.isEmpty() && !userList.contains(UserInfo.getUserName())));
System.debug(recIdNameMap+'2===>:'+(recIdNameMap!=null && recIdNameMap.containsKey(caseObj.recordTypeId)));
System.debug((permQuery==null)+'3===>:'+(permQuery!=null && permQuery[0].get('expr0')==0));
System.debug((profQuery==null)+'4===>:'+(profQuery!=null && profQuery[0].get('expr0')==0));
if((recIdNameMap!=null && recIdNameMap.containsKey(caseObj.recordTypeId)))
{
            if
            (
                (
                  (userList==null ||  (userList!=null && !userList.isEmpty() && !userList.contains(UserInfo.getUserName())))
                   &&
                  (permQuery==null ||  (permQuery!=null && permQuery[0].get('expr0')==0))
                   && 
                   (profQuery==null || (profQuery!=null && profQuery[0].get('expr0')==0))
                )
                ||
                (userList==null && permQuery==null && profQuery==null)
               
            )
            {
                //if(CareDotComUtil.runningInASandbox()) System.debug('Unable to delete the Case with Id '+caseObj.id+' with Name '+caseObj.name+', Due to insufficient Previliges, Please contact System Administartor for more information.');
                //caseObj.addError('Unable to delete the Case with Id '+caseObj.id+' with Name '+(caseObj.firstName==null?'':caseObj.firstName)+' '+caseObj.lastName+', Due to insufficient Previliges, Please contact System Administartor for more information.');
                //caseObj.addError(dataDelRuleSettings.get(0).Error_Message__c);
                //if(haveDelPermission.containsKey(caseObj.id)==false)   
                //{
                    deniedDelMap.put(caseObj.id,caseObj);
                    deniedDelErrMsgMap.put(caseObj.id,ddrObj);
                    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 1');
                 //}
            }
            else    
            {
                    deniedDelMap.remove(caseObj.id);
                    deniedDelErrMsgMap.remove(caseObj.id);
                    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 2');
                    haveDelPermission.put(caseObj.id,true);
            }
 }
 else  
{
 if(CareDotComUtil.runningInASandbox()) System.debug('No Match...');
if(!noMatchInAllCustSetgs.containsKey(caseObj.id)) 
{
noMatchInAllCustSetgs.put(caseObj.id,1);
 if(CareDotComUtil.runningInASandbox()) System.debug('Setting unmatch count to 1');
}
else 
{
noMatchInAllCustSetgs.put(caseObj.id,noMatchInAllCustSetgs.get(caseObj.id)+1);
 if(CareDotComUtil.runningInASandbox()) System.debug('Setting unmatch count to '+noMatchInAllCustSetgs.get(caseObj.id)+1);
}
    deniedDelMap.put(caseObj.id,caseObj);
    //deniedDelErrMsgMap.put(caseObj.id,ddrObj);
    haveDelPermission.put(caseObj.id,false);
    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 1');
 }
        }    // End Of For Loop
      }
  }  
  if(!deniedDelMap.isEmpty())
  {
    for(Case caseObj:deniedDelMap.values())
    {
     if(CareDotComUtil.runningInASandbox()) System.debug('noMatchInAllCustSetgs.get(caseObj.id)==>:'+noMatchInAllCustSetgs.get(caseObj.id));
     if(CareDotComUtil.runningInASandbox()) System.debug('dataDelRuleSettings.size()==>:'+dataDelRuleSettings.size());
        if(noMatchInAllCustSetgs.get(caseObj.id)!=dataDelRuleSettings.size() && deniedDelErrMsgMap.containsKey(caseObj.id))
        caseObj.addError(String.isBlank(deniedDelErrMsgMap.get(caseObj.id).Error_Message__c)?'':deniedDelErrMsgMap.get(caseObj.id).Error_Message__c);
    }  
  } 
}
 }   /*
    public String getSQLStringFromDelimitedList(String delimitedString)
    {
        String sqlString='';
        if(!String.isBlank(delimitedString))
        {
            List<String> delString=delimitedString.split(';');
            for(integer i=0;i<delString.size();i++)
            {
                if(i==delString.size()-1)
                {
                  sqlString+='\''+delString[i]+'\'';
                          if(CareDotComUtil.runningInASandbox()) System.debug('if sqlString==>:'+sqlString);
                }else
                {
                    sqlString+='\''+delString[i]+'\',';
                                              if(CareDotComUtil.runningInASandbox()) System.debug('else sqlString==>:'+sqlString);
                }
            }
        }

        return sqlString;
    }
    */
    public Map<Id,String> getRecordTypeIdNameMap(Map<String,Id> recNameIdMap)
    {
        Map<Id,String> recIdNameMap=new Map<Id,String>();
        for(String recName:recNameIdMap.keySet())
        {
            recIdNameMap.put(recNameIdMap.get(recName),recName);
            if(CareDotComUtil.runningInASandbox()) System.debug('recName==>:'+recName+'recNameIdMap.get(recName)==>:'+recNameIdMap.get(recName));
        }
        return recIdNameMap;
    }
  
}