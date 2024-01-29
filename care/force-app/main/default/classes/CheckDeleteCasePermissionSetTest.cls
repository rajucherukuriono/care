@isTest(SeeAllData=true)
        private class CheckDeleteCasePermissionSetTest 
        { 

            static testMethod void CheckDeleteCasePermissionSetTest() 
            { 
                List<PermissionSetAssignment> permresult1 = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE (PermissionSet.Name = 'Delete_International_Cases' OR PermissionSet.Name = 'Delete_US_Cases')];
                if(!permresult1.isEmpty())
                {

                    CheckDeleteCasePermissionSetAssignment.CheckCaseDeletePermission(permresult1[0].AssigneeId);
                }
                List<User> adminUserList=[SELECT ID FROM USER WHERE PROFILE.NAME='System Administrator'];
                if(!adminUserList.isEmpty())
                {
                    
                    CheckDeleteCasePermissionSetAssignment.CheckCaseDeletePermission(adminUserList[0].id);
                }
            }
        }