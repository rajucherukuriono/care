trigger VettingRecordCountOnAccount on Vetting__c (before insert,after insert,after update, after delete) {
    Id vetRecTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('US BUC Network Vetting');
    Id onlineVettRecTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('BUC Online Vetting');
    Map<id,List<Vetting__c>> accIdVettingObjMap=new Map<id,List<Vetting__c>>();
    Map<id,Vetting__c> accIdLastVettingObj=new Map<id,Vetting__c>();
    List<Id> accIdsList=new List<Id>();
    
    for(Vetting__c vetObj: Trigger.isDelete?Trigger.Old:Trigger.new){
        If(vetObj.RecordtypeId == vetRecTypeId){
            System.debug('1 vetObj.name==============>:'+vetObj.Name);
            accIdsList.add(vetObj.BUC_Center_Name__c);
            
        }
    }
    List<Account> accList=[select id,Vetting_Record_Count__c,Vetting_Records_Present__c,(select id,RecordtypeId,BUC_Center_Name__c,Name,CreatedDate from Vettings__r) from Account where id in:accIdsList];
    
    for(Account accObj:accList)
    {   
        for(Vetting__c vetObj:accObj.Vettings__r)
        {
            If(vetObj.RecordtypeId == vetRecTypeId)
            {   
                if(!accIdVettingObjMap.containsKey(vetObj.BUC_Center_Name__c))
                {
                    accIdVettingObjMap.put(vetObj.BUC_Center_Name__c,new List<Vetting__c>{vetObj});
                    System.debug('2 vetObj.name==============>:'+vetObj.Name);
                }
                else
                {
                    accIdVettingObjMap.get(vetObj.BUC_Center_Name__c).add(vetObj);
                    System.debug('3 vetObj.name==============>:'+vetObj.Name);
                }
            }
        }
    }
    
    
    for(Id accId:accIdVettingObjMap.keySet())
    {
        for(Vetting__c vetObj: accIdVettingObjMap.get(accId))
        {
            if(!accIdLastVettingObj.containsKey(vetObj.BUC_Center_Name__c))
                accIdLastVettingObj.put(vetObj.BUC_Center_Name__c,vetObj);
            else if(vetObj.createdDate > accIdLastVettingObj.get(vetObj.BUC_Center_Name__c).CreatedDate)
                accIdLastVettingObj.put(vetObj.BUC_Center_Name__c,vetObj);
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        accList=[select id,Vetting_Record_Count__c from Account where id in:accIdsList];
        for(Account accObj:accList){
            if(accObj.Vetting_Record_Count__c!=null && accObj.Vetting_Record_Count__c >= 1)
            {
                accObj.Vetting_Record_Count__c=accObj.Vetting_Record_Count__c+1;
            }
            else{
                accObj.Vetting_Record_Count__c=1;
            }
        }
        
        update accList;
    }
    else
        
        if(Trigger.isAfter && Trigger.isInsert)
    {
        
        accList=[select id,Vetting_Record_Count__c,Vetting_Records_Present__c,(select id,RecordtypeId,BUC_Center_Name__c,Name,CreatedDate from Vettings__r) from Account where id in:accIdsList];
        for(Account accObj:accList){
            System.debug('5 accObj.name==============>:'+accIdVettingObjMap.get(accObj.Id).size());
            accObj.Vetting_Records_Present__c=accIdVettingObjMap.get(accObj.Id).size();
            accObj.Date_Of_Last_Vetting__c=accIdLastVettingObj.get(accObj.id).createdDate.date();
        }
        
        update accList;
        
    }
    else if(Trigger.isAfter && Trigger.isDelete)
    {
        
        List<Account> accList=[select id,Vetting_Record_Count__c,Vetting_Records_Present__c,(select id,BUC_Center_Name__c,Name,CreatedDate from Vettings__r),(select id from Infractions__r) from Account where id in:accIdsList];
        for(Account accObj:accList){
            //System.debug('6 accObj.name==============>:'+accIdVettingObjMap.get(accObj.Id).size());
            accObj.Vetting_Records_Present__c=accIdVettingObjMap.get(accObj.Id).size();
            accObj.Violation_Records_Present__c=accObj.Infractions__r.size();
        }
        update accList;
        
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        system.debug('*****************after insert');
        if (AvoidRecursion.runonce()){ 
            system.debug('*****************after insert');
            List<Account> newAccList = new List<Account>();
            for(Vetting__c vetObj: Trigger.new){
                if(vetObj.RecordTypeId==onlineVettRecTypeId ){
                    accIdsList.add(vetObj.BUC_Center_Name__c);
                }
            }
            system.debug('*********accIdsList********'+accIdsList);
            List<Account> accList=[select id,Online_Vetting_Completed__c, Vetting_Status__c, (select id,Name, RecordTypeId, Completed_Date__c,Vetting_Status__c, CreatedDate, LastModifiedDate from Vettings__r  Order by createdDate DESC limit 1) from Account where id in:accIdsList];
            
            for(Account accObj:accList){
                for(Vetting__c vetObj:accObj.Vettings__r)
                {
                    system.debug('vetObj **'+vetObj);
                    if(vetObj.RecordTypeId==onlineVettRecTypeId){
                        accObj.Online_Vetting_Completed__c= Date.ValueOf(vetObj.Completed_Date__c);
                        if(vetObj.Vetting_Status__c =='Pass' || vetObj.Vetting_Status__c =='Fail' || vetObj.Vetting_Status__c =='In Progress') {
                            accObj.Online_Vetting_Result__c =vetObj.Vetting_Status__c;
                            System.debug('Vetting ashfaq' + accObj.Online_Vetting_Result__c  +'**'+vetObj.Vetting_Status__c);
                        }
                        newAccList.add(accObj);
                    }
                }                
            }
            System.debug(newAccList);
            update newAccList;
        }
    }
}