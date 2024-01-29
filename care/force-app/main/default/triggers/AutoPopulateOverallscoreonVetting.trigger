trigger AutoPopulateOverallscoreonVetting on Account (after Update)
{   
     Id BUCNetworkCenter= Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Center').getRecordTypeId();
     Id BUCNetworkAgency= Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Agency').getRecordTypeId();
     Id onlineVettRecTypeId = getRecordTypesStatic.recordTypeNameIdMap.get('BUC Online Vetting');
     
     List<Id> accIds = new List<Id>();
     for(Account accObj:Trigger.new)
    {
        if(accObj.recordTypeId==BUCNetworkCenter || accObj.recordTypeId==BUCNetworkAgency )
        {
            accIds.add(accObj.id);
        }
        
    }
    system.debug('lst acc***'+accIds);
    List<Vetting__c> updateLstVetting = new List<Vetting__c>();
    if(!accIds.isEmpty()){
    List<Account> vettingAcc = [Select id, name , Overall_score__c , (select id, RecordTypeId, name , Overall_score__c from Vettings__r order by CreatedDate DESC limit 1) From Account where id IN: accIds AND overall_score__c!=null];
        system.debug('lst vetting***'+vettingAcc);
        if(!vettingAcc.isEmpty()){
        for(Account acc: vettingAcc ){             
            for(vetting__c vtt: acc.Vettings__r ){
                if(vtt.RecordTypeId !=onlineVettRecTypeId){
                    if(vtt.overall_Score__c!=acc.Overall_score__c ){
                        vtt.overall_Score__c=acc.Overall_score__c;
                        updateLstVetting.add(vtt);
                    }
                }
            }
        }
        }
    }
    if(!updateLstVetting.isEmpty()){
        update updateLstVetting;
    }

}