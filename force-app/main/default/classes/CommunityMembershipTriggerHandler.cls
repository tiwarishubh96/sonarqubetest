/**
 * Generic trigger handler class for Community Membership. 
 * - Updates the permission set for the user when a community membership record is created or updated. (US-46905)
 * @author Salesforce Services
**/
public class CommunityMembershipTriggerHandler {
	public static void beforeInsert(List<Community_Membership__c> newList, Map<Id, Community_Membership__c> newMap) {}

    public static void afterInsert(List<Community_Membership__c> newList, Map<Id, Community_Membership__c> newMap) {
        updateUserPermissionSets(newList);
    }

    public static void beforeUpdate(List<Community_Membership__c> oldList, Map<Id, Community_Membership__c> oldMap, List<Community_Membership__c> newList, Map<Id, Community_Membership__c> newMap) {}

    public static void afterUpdate(List<Community_Membership__c> oldList, Map<Id, Community_Membership__c> oldMap, List<Community_Membership__c> newList, Map<Id, Community_Membership__c> newMap) {
        updateUserPermissionSets(newList);
    }

    public static void afterDelete(List<Community_Membership__c> oldList, Map<Id, Community_Membership__c> oldMap) {
        updateUserPermissionSets(oldList);
    }
    
    /**
     * Gets a list of contacts for a membership. Clears existing community permissions, finds a new list of permissions, 
     * and inserts permissions for the user related to the contact. (US-46905)
     * @author Salesforce Services 
     * @param changedPermissions the list of permissions which have changed
    **/
    public static void updateUserPermissionSets(List<Community_Membership__c> changedPermissions) {
        
        // Collect list of affected contacts
        List<Id> contactIds = new List<Id>();
        for (Community_Membership__c permission : changedPermissions) {
            contactIds.add(permission.Contact__c);
        }
        
        // Collect a list of user records
        List<Id> userIds = new List<Id>();
		Map<Id, Id> mapOfContactIdsToUserIds = new Map<Id, Id>();
        for (User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds AND isActive = true]) {
            userIds.add(u.Id);
            mapOfContactIdsToUserIds.put(u.ContactId, u.Id);
        }
        
        // Get new set of permissions
        // Find all the communities which these contacts are a part of
        List<Community_Membership__c> memberships = [SELECT Id, Community_Role__c, Contact__c FROM Community_Membership__c WHERE Contact__c IN :contactIds];
        
        // Next get the list of role ids for each contact
        Map<Id, Set<Id>> mapOfRoleIdsToContactIds = new Map<Id, Set<Id>>();
        for (Community_Membership__c member : memberships) {
            if (mapOfRoleIdsToContactIds.containsKey(member.Community_Role__c)) {
                Set<Id> contacts = mapOfRoleIdsToContactIds.get(member.Community_Role__c);
                contacts.add(member.Contact__c);
            } else {
                mapOfRoleIdsToContactIds.put(member.Community_Role__c, new Set<Id> { member.Contact__c });
            }
        }
        
        // Get the list of permission set names for each role
        Map<String, Set<Id>> mapOfPermissionSetNamesToContactIds = new Map<String, Set<Id>>();
        List<Community_Role_Permission_Set__c> rolePermissionSets = [SELECT Id, Permission_Set__c, Community_Role__c FROM Community_Role_Permission_Set__c WHERE Community_Role__c IN :mapOfRoleIdsToContactIds.keySet()];
        
        for (Community_Role_Permission_Set__c rolePermissionSet : rolePermissionSets) {
            if (mapOfRoleIdsToContactIds.containsKey(rolePermissionSet.Community_Role__c)) {
                Set<Id> contacts = mapOfRoleIdsToContactIds.get(rolePermissionSet.Community_Role__c);
                mapOfPermissionSetNamesToContactIds.put(rolePermissionSet.Permission_Set__c, contacts);
            }
        }
        
        // Get the list of permission set Ids for each permission set name
        Map<Id, Set<Id>> mapOfPermissionSetIdsToContactIds = new Map<Id, Set<Id>>();
        List<PermissionSet> permissionSets = [SELECT Id, Name, Label FROM PermissionSet WHERE Label IN :mapOfPermissionSetNamesToContactIds.keySet()];

        for (PermissionSet permissionSet : permissionSets) {
            if (mapOfPermissionSetNamesToContactIds.containsKey(permissionSet.Label)) {
                Set<Id> contacts = mapOfPermissionSetNamesToContactIds.get(permissionSet.Label);
                mapOfPermissionSetIdsToContactIds.put(permissionSet.Id, contacts);
            }
        }
        
        CommunityMembershipTriggerHandler.createPermissionAssignments(mapOfContactIdsToUserIds, JSON.serialize(mapOfPermissionSetIdsToContactIds));
        
	}
    
    /**
     * Creates permissions users for portal contacts (US-46905)
     * Invoked as a future to avoid mixed DML operations. 
     * @author Salesforce Services 
     * @param mapOfContactIdsToUserIds map of contact ids to user ids
     * @param jsonOfmapOfPermissionSetIdsToContactIds map of permission set id to a list of contacts with that permission set
    **/
    @Future
    public static void createPermissionAssignments(Map<Id, Id> mapOfContactIdsToUserIds, String jsonOfmapOfPermissionSetIdsToContactIds) {
        
        List<Id> userIds = mapOfContactIdsToUserIds.values();
        
        Map<Id, Set<Id>> mapOfPermissionSetIdsToContactIds = (Map<Id, Set<Id>>) JSON.deserialize(jsonOfmapOfPermissionSetIdsToContactIds, Map<Id, Set<Id>>.class);
        
        // Clear existing permissions
        String permissionSetQueryCustomer = Constants.CUSTOMER_COMMUNITY_PERMISSION_SET_PREFIX + '%';
        String permissionSetQueryPartner = Constants.PARTNER_COMMUNITY_PERMISSION_SET_PREFIX + '%';
        
        List<PermissionSetAssignment> existingPermissions = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId in :userIds AND (PermissionSet.label LIKE :permissionSetQueryCustomer OR PermissionSet.label LIKE :permissionSetQueryPartner)];
        if (existingPermissions.size() > 0)
        	delete existingPermissions;
        
        // Insert permission assignments
		List<PermissionSetAssignment> newPermissionSetAssignments = new List<PermissionSetAssignment>();
        for (Id permissionSetId : mapOfPermissionSetIdsToContactIds.keySet()) {
            for (Id contactId : mapOfPermissionSetIdsToContactIds.get(permissionSetId)) {
                if (mapOfContactIdsToUserIds.containsKey(contactId)) {
                    Id userId = mapOfContactIdsToUserIds.get(contactId);
                	PermissionSetAssignment pa = new PermissionSetAssignment();
                    pa.AssigneeId = userId;
                    pa.PermissionSetId = permissionSetId;
                    newPermissionSetAssignments.add(pa);    
                }
            }
        }
        
        if (newPermissionSetAssignments.size() > 0)
        	insert newPermissionSetAssignments;
    }
}