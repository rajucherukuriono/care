// Common trigger for SocialPost records
//
// added by GearsCRM
trigger SocialPostTrigger on SocialPost (before insert, after insert, after update)
{
	string triggerName = 'SocialPost' + 
		(trigger.isBefore ? ' before ' : ' after ')  + 
		(trigger.isInsert ? 'insert' : 'update');
		/* trigger.isUpdate ? 'update' : 
		 trigger.isDelete ? 'delete' : 'undelete'); */

	system.debug('+' + triggerName);

	 /* if (trigger.isBefore) 	{
		if (trigger.isInsert)
		{
		}
		else if (trigger.isUpdate)
		{
		}
		else if (trigger.isDelete)
		{
		}  
	}   
	else */
    
    if (trigger.isBefore) 	{
		if (trigger.isInsert)
		{
            SocialPostSkillUpdate.skillandQueueUpdate(trigger.new, trigger.oldMap);
		}
    }
	if (trigger.isAfter)
	{
		if (trigger.isInsert)
		{
			UCaseMilestones.HandleIncomingMessages(trigger.new, trigger.oldMap);
            //CaseReopenforSocialMedia.checkSocialPost(trigger.new, trigger.oldMap);
		}
		else if (trigger.isUpdate)
		{
			UCaseMilestones.HandleIncomingMessages(trigger.new, trigger.oldMap);
		}
		/*else if (trigger.isDelete)
		{
		}
		else if (trigger.isUndelete)
		{
		} */
	}

	system.debug('-' + triggerName);
}