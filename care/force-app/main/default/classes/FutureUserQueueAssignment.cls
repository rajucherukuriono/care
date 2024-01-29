/*
** _________________________________________________________________________________
** Created by:    Eustace Consulting [www.eustaceconsulting.com]
** Developer:     Liam Stokinger, Software Developer [Liam@eustaceconsulting.com]
** Created Date:  07.28.2014
** =================================================================================
** Description: 
                Assigns Users to queues on insert and update
** _______________________________________________________________________________
*/

// GearsCRM: leaving these webservice methods in but commenting out the logic, since things 
// are moving to BREeze/Omni. It's unknown if external systems are still calling them - they
// take no params and don't return anything so it should be safe to just stub these out

global with sharing class FutureUserQueueAssignment 
{
	WebService 
	static void RefreshUserQueueAssignments()
	{
	/*
		Map<id,User> userMap=new Map<id,user>([select id from User where Tier__c != null and Platform__c != null and Language__c != null and IsActive=true LIMIT 50000]);
		AssignQueue(userMap.keySet());
	*/
	}

	WebService 
	static void RefreshSafetyUserQueueAssignments()
	{
	}
/*
		Map<Id,User> usrMap=new Map<Id,User>([SELECT ID FROM USER WHERE USERROLE.NAME in ('Safety Agent','Safety Manager','Senior Safety Manager') and isActive=true]);
		//Group safetyGroup=[select id from group where name ='G: US Safety Team'][0];
Group safetyQueue=[select id from group where name ='Q: Safety Alert'][0];
Map<Id,GroupMember> usrGrpMemMap=new Map<Id,GroupMember>([SELECT ID,UserOrGroupId FROM GROUPMEMBER WHERE Group.NAME = 'Q: Safety Alert']);
Map<Id,GroupMember> usrIdGrpMemMap=new Map<Id,GroupMember>();
for(Id grpId:usrGrpMemMap.keySet())
{
    usrIdGrpMemMap.put(usrGrpMemMap.get(grpId).UserOrGroupId,usrGrpMemMap.get(grpId));
}
List<GroupMember> grpList=new List<GroupMember>();
for(User usrObj:usrMap.values())
{
    if(!usrIdGrpMemMap.containsKey(usrObj.id))
    {
        grpList.add(new GroupMember(userOrGroupId=usrObj.id,groupid=safetyQueue.id));
    }
}
if(!grpList.isEmpty())
insert grpList;
}
    public static void AssignQueue(set<Id> UserIds){
        list<User> UserList = [Select Id, Platform__c, Tier__c, Language__c, IsActive FROM User WHERE Id IN: UserIds];
        list<Group> Queues = [Select Id, Name FROM Group WHERE Type = 'Queue'];
        
        //Code commented as part of part of SFORCE-1373 fix.
        /*
        list<GroupMember> deletelist = [Select Id FROM GroupMember WHERE UserOrGroupId IN: UserIds];
        delete deletelist;
        * /
        list<GroupMember> deletelist = [Select Id 
                                        FROM GroupMember 
                                        WHERE  Group.Name like 'Q: __: %' and UserOrGroupId IN: UserIds];
        delete deletelist;
        
        list<GroupMember> insertList = new list<GroupMember>();
        for(User TheUser : UserList){
            //if (TheUser.Tier__c != null && TheUser.Platform__c != null && TheUser.Language__c != null && TheUser.IsActive) {
            if (TheUser.Platform__c != null && TheUser.Language__c != null && TheUser.IsActive) {
                for(Group TheQueue : Queues){
                    integer endPosition = string.Valueof(TheQueue.Name).length();
                    for(string langstring : TheUser.Language__c.split(';')){
                    /*
                        if(TheQueue.name.contains(langstring) && 
                        (
                        (TheUser.Tier__c == '3' && (string.Valueof(TheQueue.Name).substring(endPosition-1) == '3' || string.Valueof(TheQueue.Name).substring(endPosition-1) == '2' || string.Valueof(TheQueue.Name).substring(endPosition-1) == '1')) ||
                        (TheUser.Tier__c == '2' && (string.Valueof(TheQueue.Name).substring(endPosition-1) == '2' || string.Valueof(TheQueue.Name).substring(endPosition-1) == '1')) ||
                        (TheUser.Tier__c == '1' && string.Valueof(TheQueue.Name).substring(endPosition-1) == '1')
                        )
                        )
                        * /
                        if(TheQueue.name.contains(langstring))
                        {
                        /*
                            if(!(theUser.Platform__c == 'US' && !TheQueue.name.contains(' US:')) && !(theUser.Platform__c == 'international' && TheQueue.name.contains(' US:'))){
                                insertlist.add(new GroupMember(GroupId = TheQueue.Id, UserOrGroupId = TheUser.Id));
                            }
                         * /
                            boolean USPlatform= theUser.Platform__c == 'US';
                            boolean InternationalPlatform=theUser.Platform__c == 'international';
                            boolean queueContainsUS=TheQueue.name.contains(' US:');
                            if((InternationalPlatform && !queueContainsUS) || (USPlatform && queueContainsUS)) 
                             {
                                 insertlist.add(new GroupMember(GroupId = TheQueue.Id, UserOrGroupId = TheUser.Id));
                             }
                        }
                    }
                }
            }
        }
        insert insertlist;
    }

	*/
}