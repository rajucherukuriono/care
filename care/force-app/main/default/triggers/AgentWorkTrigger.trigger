trigger AgentWorkTrigger on AgentWork (after insert, after update)  
{ 
	string triggerName = 'AgentWork' + 
		(trigger.isBefore ? ' before ' : ' after ')  + 
		(trigger.isInsert ? 'insert' : 
		 trigger.isUpdate ? 'update' : 
		 trigger.isDelete ? 'delete' : 'undelete');

	system.debug('+' + triggerName);

	//if (trigger.isBefore)
	//{
	//	if (trigger.isInsert)
	//	{
	//	}
	//	else 
	//	if (trigger.isUpdate)
	//	{
	//	}
	//	else 
	//	if (trigger.isDelete)
	//	{
	//	} 
	//}   
	//else 
	if (trigger.isAfter)
	{
		if (trigger.isInsert)
		{
			UAgentWork.HandleAssign(trigger.new, trigger.oldMap);
		}
		else 
		if (trigger.isUpdate)
		{
			UAgentWork.HandleAssign(trigger.new, trigger.oldMap);
		}
		//else 
		//if (trigger.isDelete)
		//{
		//}
		//else 
		//if (trigger.isUndelete)
		//{
		//}
	}

	system.debug('-' + triggerName);
}