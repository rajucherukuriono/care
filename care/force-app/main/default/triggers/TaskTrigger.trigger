trigger TaskTrigger on Task (after insert, after update, before insert)
{
	string triggerName = 'Task' + 
		(trigger.isBefore ? ' before ' : ' after ')  + 
		(trigger.isInsert ? 'insert' : 
		 trigger.isUpdate ? 'update' : 
		 trigger.isDelete ? 'delete' : 'undelete');

	system.debug('+' + triggerName);
    
	if (trigger.isBefore){
      if (trigger.isInsert){
          UCaseMilestones.AutoCloseTaskforOpenCase(trigger.new);
      }
   }
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
			UCaseMilestones.AutoCloseOnRelatedObject('Task', 'WhatId', 'Type', trigger.new, trigger.oldMap);
		}
		else 
		if (trigger.isUpdate)
		{
			UCaseMilestones.AutoCloseOnRelatedObject('Task', 'WhatId', 'Type', trigger.new, trigger.oldMap);
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