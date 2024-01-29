// Common trigger for EmailMessage records
//
// added by GearsCRM
trigger EmailMessageTrigger on EmailMessage (after insert, after update)
{
	string triggerName = 'EmailMessage' + 
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
			UCaseMilestones.AutoCloseOnRelatedObject('EmailMessage', 'ParentId', null, trigger.new, trigger.oldMap);
			UCaseMilestones.HandleIncomingMessages(trigger.new, trigger.oldMap);
		}
		else 
		if (trigger.isUpdate)
		{
			UCaseMilestones.AutoCloseOnRelatedObject('EmailMessage', 'ParentId', null, trigger.new, trigger.oldMap);
			UCaseMilestones.HandleIncomingMessages(trigger.new, trigger.oldMap);
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