/*
** _______________________________________________________________________________
** Created by:    Wavelabs [https://www.wavelabs.ai]
** Developer:     Sridhar, Salesforce Architect [sridhar.neeli@care.com]
** Created Date:  08.15.2019
** ===============================================================================
** Description: 
** This class defines several rules which restricts access to deletion of accounts.
** 
** ______________________________________________________________________________
*/
trigger AccountDataDeletionAccessTrigger on Account (before Delete) {
Map<id,Data_Deletion_Rules__mdt>   dataDelRuleSettings=new Map<id,Data_Deletion_Rules__mdt>([SELECT Error_Message__c,DeveloperName,Id,Label,MasterLabel,Override_Data_Deletion__c,Permission_Set_Name__c,Profile_Name__c,QualifiedApiName,Record_Type__c,SObject_Name__c,User_Name__c FROM Data_Deletion_Rules__mdt where SObject_Name__c='Account' and Override_Data_Deletion__c=false]);
Map<id,Account> deniedDelMap=new Map<id,Account>();
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
        for(Account accObj:Trigger.Old)
        {
             //if(recNameIdMap.get(accObj.recordTypeId)   permQuery[0].get('expr0')==0)
            //System.debug((recIdNameMap.containsKey(accObj.recordTypeId))+ '   '+ (permQuery[0].get('expr0')==0)+ '   '+ (profQuery[0].get('expr0')==0)+'  userList=>:'+userList);
System.debug((userList==null)+'1===>:'+ (userList!=null && !userList.isEmpty() && !userList.contains(UserInfo.getUserName())));
System.debug(recIdNameMap+'2===>:'+(recIdNameMap!=null && recIdNameMap.containsKey(accObj.recordTypeId)));
System.debug((permQuery==null)+'3===>:'+(permQuery!=null && permQuery[0].get('expr0')==0));
System.debug((profQuery==null)+'4===>:'+(profQuery!=null && profQuery[0].get('expr0')==0));
if((recIdNameMap!=null && recIdNameMap.containsKey(accObj.recordTypeId)))
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
                //if(CareDotComUtil.runningInASandbox()) System.debug('Unable to delete the Account with Id '+accObj.id+' with Name '+accObj.name+', Due to insufficient Previliges, Please contact System Administartor for more information.');
                //accObj.addError('Unable to delete the Account with Id '+accObj.id+' with Name '+(accObj.firstName==null?'':accObj.firstName)+' '+accObj.lastName+', Due to insufficient Previliges, Please contact System Administartor for more information.');
                //accObj.addError(dataDelRuleSettings.get(0).Error_Message__c);
                //if(haveDelPermission.containsKey(accObj.id)==false)   
                //{
                    deniedDelMap.put(accObj.id,accObj);
                    deniedDelErrMsgMap.put(accObj.id,ddrObj);
                    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 1');
                 //}
            }
            else    
            {
                    deniedDelMap.remove(accObj.id);
                    deniedDelErrMsgMap.remove(accObj.id);
                    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 2');
                    haveDelPermission.put(accObj.id,true);
            }
 }
 else  
{
 if(CareDotComUtil.runningInASandbox()) System.debug('No Match...');
if(!noMatchInAllCustSetgs.containsKey(accObj.id)) 
{
noMatchInAllCustSetgs.put(accObj.id,1);
 if(CareDotComUtil.runningInASandbox()) System.debug('Setting unmatch count to 1');
}
else 
{
noMatchInAllCustSetgs.put(accObj.id,noMatchInAllCustSetgs.get(accObj.id)+1);
 if(CareDotComUtil.runningInASandbox()) System.debug('Setting unmatch count to '+noMatchInAllCustSetgs.get(accObj.id)+1);
}
    deniedDelMap.put(accObj.id,accObj);
    //deniedDelErrMsgMap.put(accObj.id,ddrObj);
    haveDelPermission.put(accObj.id,false);
    if(CareDotComUtil.runningInASandbox()) System.debug('Condition 1');
 }
        }    // End Of For Loop
      }
  }  
  if(!deniedDelMap.isEmpty())
  {
    for(Account accObj:deniedDelMap.values())
    {
     if(CareDotComUtil.runningInASandbox()) System.debug('noMatchInAllCustSetgs.get(accObj.id)==>:'+noMatchInAllCustSetgs.get(accObj.id));
     if(CareDotComUtil.runningInASandbox()) System.debug('dataDelRuleSettings.size()==>:'+dataDelRuleSettings.size());
        if(noMatchInAllCustSetgs.get(accObj.id)!=dataDelRuleSettings.size())
        accObj.addError(String.isBlank(deniedDelErrMsgMap.get(accObj.id).Error_Message__c)?'':deniedDelErrMsgMap.get(accObj.id).Error_Message__c);
    }  
  } 
    
    /*
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
                          System.debug('if sqlString==>:'+sqlString);
                }else
                {
                    sqlString+='\''+delString[i]+'\',';
                                              System.debug('else sqlString==>:'+sqlString);
                }
            }
        }

        return sqlString;
    }
    */
    public Map<Id,String> getRecordTypeIdNameMap(Map<String,Id> recNameIdMap){
           Map<Id,String> recIdNameMap=new Map<Id,String>();
        for(String recName:recNameIdMap.keySet())
        {
            recIdNameMap.put(recNameIdMap.get(recName),recName);
            System.debug('recName==>:'+recName+'recNameIdMap.get(recName)==>:'+recNameIdMap.get(recName));
        }
        return recIdNameMap;
    }
}