public class FlowUtilitiesCheckPermission {
    
	@InvocableMethod
    public static List<Boolean> hasPermission(List<String> names) {
        
        List<Boolean> result = new List<Boolean>();
        for (String name : names) {
            result.add(false);
        }
        
        List<CustomPermission> customPermissions =
            [SELECT Id, DeveloperName
             FROM CustomPermission
             WHERE DeveloperName in :names];
        
        List<Id> customPermissionSetIds = new List<Id>();
        Map<Id, String> mapOfCustomPermissionIdToName = new Map<Id, String>();
        
        for (CustomPermission p : customPermissions) {
            customPermissionSetIds.add(p.Id);
            mapOfCustomPermissionIdToName.put(p.Id, p.DeveloperName);
        }
        
        List<SetupEntityAccess> setupEntities =
                [SELECT SetupEntityId
                 FROM SetupEntityAccess
                 WHERE SetupEntityId in :customPermissionSetIds AND
                 ParentId IN (SELECT PermissionSetId
                              FROM PermissionSetAssignment
                              WHERE AssigneeId = :UserInfo.getUserId())];
        
        for (SetupEntityAccess entityAccess : setupEntities) {
            Id setupEntityId = entityAccess.SetupEntityId;
            String n = mapOfCustomPermissionIdToName.get(setupEntityId);
            Integer index = 0;
            
            for (String name : names) {
                if (name == n) {
                    result[index] = true;
                }
            	index += 1;    
            }
        }
        
        return result;
    }
}