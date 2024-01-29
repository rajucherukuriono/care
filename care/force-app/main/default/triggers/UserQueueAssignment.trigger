/*
** _________________________________________________________________________________
** Created by:    Eustace Consulting [www.eustaceconsulting.com]
** Developer:     Liam Stokinger, Software Developer [Liam@eustaceconsulting.com]
** Created Date:  07.28.2014
** Modified Date: 05.18.2019
** =================================================================================
** Description: 
                Assigns Users to domestic/member care queues on member insert or update
                Modified this trigger based on SFORCE-2041 requirement, so that All users
                under Safety Alert,Safety Manager,Senior Safety Manager role users become 
                individual members of the queue 'Q: Safety Alert' upon user record insert 
                or edit(This is mandatory to make the next safety case button works for any 
                safery user).
                
** _______________________________________________________________________________
*/
trigger UserQueueAssignment on User (after insert, after update) 
{

/* all obsolete now - using BREeze/Omni instead

	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
	{
		//Group safetyGroup=[select id from group where name ='G: US Safety Team'][0];
		Group safetyQueue=[select id from group where name ='Q: Safety Alert'][0];

		Map<Id,UserRole> saferyUsrRoles=new Map<Id,UserRole>([select id from UserRole where name in ('Safety Agent','Safety Manager','Senior Safety Manager')]);

		Map<Id,GroupMember> usrGrpMemMap=new Map<Id,GroupMember>([SELECT ID,UserOrGroupId FROM GROUPMEMBER WHERE Group.NAME = 'Q: Safety Alert']);
		Map<Id,GroupMember> usrIdGrpMemMap=new Map<Id,GroupMember>();
		for(Id grpId:usrGrpMemMap.keySet())
		{
			usrIdGrpMemMap.put(usrGrpMemMap.get(grpId).UserOrGroupId,usrGrpMemMap.get(grpId));
			System.debug('Adding user to safety alert queue...1');
		}

		List<GroupMember> grpList=new List<GroupMember>();
            
               
		set<Id> UsersToAssign = new set<Id>();
		for(User TheUser : trigger.new)
		{
			if (trigger.IsInsert && TheUser.IsActive && TheUser.Platform__c != null && TheUser.Tier__c != null && TheUser.Language__c != null) 
			{
				UsersToAssign.add(TheUser.Id);
			} 
			else 
			if (trigger.isUpdate && 
					(TheUser.Platform__c != trigger.oldmap.get(TheUser.Id).Platform__c || 
					 TheUser.Tier__c     != trigger.oldmap.get(TheUser.Id).Tier__c || 
					 TheUser.Language__c != trigger.oldmap.get(TheUser.Id).Language__c || 
					 TheUser.IsActive    != trigger.oldmap.get(TheUser.Id).isActive)) 
			{
				UsersToAssign.add(TheUser.Id);
			}

			System.debug(TheUser.IsActive + TheUser.UserRole.Name);
			if(TheUser.IsActive==true && saferyUsrRoles.containsKey(TheUser.UserRoleId))
			{
				System.debug('Adding user to safety alert queue...2');

				if(!usrIdGrpMemMap.containsKey(TheUser.id))
				{
					System.debug('Adding user to safety alert queue...3');
					grpList.add(new GroupMember(userOrGroupId=TheUser.id,groupid=safetyQueue.id));
				}
			}
		}

		if(!grpList.isEmpty())
			insert grpList;
            
		if(!UsersToAssign.isempty())
			FutureUserQueueAssignment.AssignQueue(UsersToAssign);
		}
*/
}