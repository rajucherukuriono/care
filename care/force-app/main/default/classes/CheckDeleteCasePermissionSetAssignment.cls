global with sharing class CheckDeleteCasePermissionSetAssignment
{
    webservice static String CheckCaseDeletePermission(Id userId) 
    { 
         List<PermissionSetAssignment> permresult = [SELECT Id FROM PermissionSetAssignment
            WHERE (PermissionSet.Name = 'Delete_International_Cases' OR PermissionSet.Name = 'Delete_US_Cases')
            AND AssigneeId = :userId];
            
            if (permresult.isEmpty()){
                String psAssignment = '';
                return psAssignment;
            }
            else {
                String psAssignment = '1';
                return psAssignment;
            }
    }
}