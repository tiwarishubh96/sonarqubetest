global with sharing class CanManageEntitlementController {

    @InvocableMethod(label='Check if current user can manage entitlement' description='Returns true or false to indicate if user can manage entitlement')
    public static List<boolean> CanManageEntitlement() {
        List<PermissionSetAssignment> permissionAssignment = [SELECT Id
                                                                FROM PermissionSetAssignment
                                                                WHERE PermissionSet.Name = 'Sage_CBC_Manage_Entitlements_Created_by_Activity_API'
                                                                AND assigneeId = :UserInfo.getUserId()];
        List<boolean> response = new List<boolean>();
        if (permissionAssignment.size() > 0) {
            return new List<boolean> {true};
        } else {
            return new List<boolean> {false};
        }
    }
}