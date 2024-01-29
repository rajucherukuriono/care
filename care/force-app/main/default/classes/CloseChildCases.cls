/*
Name: CloseChildCases
//When closing a US MC Parent Case, close only US MC child cases only that has origin = Web, owner is still owned by a Queue, and Open = True.
//We don’t want to implement this yet for Intl Cases, because when we Cancel/Downgrade for Intl Case, it would Cancel/Downgrade the actual intl member
//We don’t want to impact chat Case so do not including origin = Chat
//MC Cases record type = Standard
//CreatedBy : md Ashwaq
CreatedDate: 25/06/2021
*/
public class CloseChildCases {
    
    //When closing a US MC Parent Case, close only US MC child cases only that has origin = Web, owner is still owned by a Queue, and Open = True.
    //We don’t want to implement this yet for Intl Cases, because when we Cancel/Downgrade for Intl Case, it would Cancel/Downgrade the actual intl member
    //We don’t want to impact chat Case so do not including origin = Chat
    //MC Cases record type = Standard
    public static void CloseChildCasesHelper(list<Case>NewRecords, list<Case>OldRecords,map<Id, Case>NewMap,  map<Id, Case>oldMap)
	{
        Set<String> typeNames = new Set<String>{'standard'};		
        set<Id> MCTypes = new set<Id>();
        for (RecordTypeInfo rt : Case.sObjectType.getDescribe().getRecordTypeInfos()){
            if (typeNames.contains(rt.getDeveloperName().toLowerCase())) {
                MCTypes.add(rt.getRecordTypeId());
            }
        }
        system.debug('**********MCTypes'+MCTypes.size() +'***'+MCTypes);
        List<Id> ParentCaseIds = new List<Id>();
        for(Case c: NewRecords){
            if(c.ParentId==null  && !oldMap.get(c.Id).IsClosed && c.IsClosed && MCTypes.Contains(c.RecordTypeId)){
            	ParentCaseIds.add(c.Id);
            }
		}
        system.debug('**********ParentCaseIds'+ParentCaseIds.size() +'***'+ParentCaseIds);
        List<Case> updateChildCases = new List<Case>();
        if(!ParentCaseIds.isEmpty()){
            system.debug('**********ParentCaseIds'+ ParentCaseIds);
            for (Case parentCase : [SELECT Id, Device__c, Support_Skill__c, Member_Language__c, Browsers_and_Versions__c, Appeal_Decision__c,Appeal_Decision_Reason__c, origin, OwnerId,Contact_Theme__c,Contact_Reason__c,Contact_Secondary_Reason__c,Sentiment__c, IsClosed, Status,RecordTypeId, (Select id, Support_Skill__c, Member_Language__c, Device__c, Browsers_and_Versions__c, Appeal_Decision__c,Appeal_Decision_Reason__c,  RecordTypeId, origin, OwnerId, Contact_Theme__c,Contact_Reason__c,Contact_Secondary_Reason__c,Sentiment__c, IsClosed, status from cases) FROM Case WHERE Id IN :ParentCaseIds AND IsClosed = true AND RecordTypeId IN :MCTypes])
			{
                if(parentCase.Cases.size() !=0 ){
                   
                    for(Case childCase: parentCase.Cases){
                        
                        system.debug('**********child for loop'+ childCase);
                        if(childCase.Support_Skill__c==parentCase.Support_Skill__c && childCase.Member_Language__c ==parentCase.Member_Language__c){
                        //When closing a US MC Parent Case, close only US MC child cases only that has origin = Web, owner is still owned by a Queue, and Open = True.
                            if(!childCase.isClosed && childCase.origin=='Web' && String.valueof(childCase.OwnerId).left(3) != '00G' && MCTypes.Contains(childCase.RecordTypeId)){                            
                                childCase.Status = parentCase.Status;
                                childCase.Contact_Theme__c  = parentCase.Contact_Theme__c;
                                childCase.Device__c = parentCase.Device__c;
                                childCase.Browsers_and_Versions__c = parentCase.Browsers_and_Versions__c;
                                childCase.Contact_Reason__c = parentCase.Contact_Reason__c;
                                childCase.Contact_Secondary_Reason__c = parentCase.Contact_Secondary_Reason__c;
                                childCase.Sentiment__c = parentCase.Sentiment__c;
                                childCase.Appeal_Decision__c = parentCase.Appeal_Decision__c;
                                childCase.Appeal_Decision_Reason__c = parentCase.Appeal_Decision_Reason__c;                           
                            }
                        }
                        updateChildCases.add(childCase);
                    }
                }
            }
        }
        system.debug('**********updateChildCases'+updateChildCases.size()+'**'+updateChildCases);
        if(!updateChildCases.isEmpty()){
            update updateChildCases;            
        }
        
			
    }
    
}