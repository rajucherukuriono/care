trigger CopyStageOrderToOpp on Opportunity (before insert, before update) {
	Set<Opportunity> oSet = new Set<Opportunity>(); 
	for (Opportunity o : trigger.new){
		if (trigger.isInsert || o.StageName != trigger.oldMap.get(o.id).stageName){
			oSet.add(o);
		}
	}

	Map<String,OpportunityStage> stageMap = UGears.GetOpStages();
	// = new Map<String,OpportunityStage>();
	//for (OpportunityStage os : [SELECT id,masterlabel,sortorder FROM OpportunityStage WHERE isActive = true]){
	//	stageMap.put(os.masterlabel,os);
	//} 

	for (Opportunity o : oSet){
		if (stageMap.get(o.StageName) != null){ 
			o.Stage_Sort_Order__c = stageMap.get(o.StageName).sortOrder;
		}	
		// should there be an else? 0? keep null?
	}
}