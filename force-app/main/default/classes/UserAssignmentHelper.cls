/*
 * UserAssignmentHelper
 * ----------------------------
 * Invoked by the UserAssignmentTrigger and UserAssignmentHandler class when an User Assignment record is inserted
 * Updates the specified User's owner with the user identified in the Assignee__c field
 * via a batched job - a simple update was resulting in Apex CPU limits exceeded on >50 User updates
 */
public class UserAssignmentHelper {
    static String CLASSNAME = 'UserAssignmentHelper';    
    /**
     * @description EAD-1539 Mass update Users via the Data Import Wizard
     * @param newUAs list of new trigger records
     */

    public static void assignUsers(List<User_Assignment__c> newUAs) {
        LogControl.push('assignUsers', CLASSNAME);
        List<User_Assignment__c> assignForUpdate = new List<User_Assignment__c>();
        // Map to allow recording of updates in the original User Assignment records and the Users themselves
        Map<User_Assignment__c, User> mapAssignmentsToUsers = new Map<User_Assignment__c, User>();
        // Unique set of Users to prevent duplicate updates to same User
        Set<Id> uniqueUsers = new Set<Id>();
        system.Debug('UserAssignmentHelper newUAs:' + newUAs);
        // "Create" Users for update
        for (User_Assignment__c ua : newUAs) {
            if (uniqueUsers.contains(ua.User__c)) {
                // duplicate User spotted
                User_Assignment__c uaUpdate = new User_Assignment__c();
                uaUpdate.Id = ua.Id;
                uaUpdate.Status__c = 'Duplicate';
                uaUpdate.Outcome__c = '';
                assignForUpdate.add(uaUpdate);
                System.Debug('UserAssignmentHelper Duplicated' + uaUpdate);
            } else {
                User u = new User();
                u.Id = ua.User__c; 
                if (!String.isBlank(ua.FirstName__c)){ 
                   u.FirstName = ua.FirstName__c;
                }
                if (!String.isBlank(ua.LastName__c)){ 
                   u.LastName = ua.LastName__c;
                }
                if (!String.isBlank(ua.UserRole__c)){ 
                   u.UserRoleId = ua.UserRole__c;
                }
                if (!String.isBlank(ua.Manager__c)){ 
                   u.new_Manager__c = ua.Manager__c; // user new_manager__c to update the manager, flow will move new_manager__c to Manager
                }
                if (!String.isBlank(ua.EmployeeNumber__c)){ 
                  u.EmployeeNumber = ua.EmployeeNumber__c;         
                }

                User_Assignment__c uaReq = new User_Assignment__c();
                uaReq.Id = ua.Id;
                uaReq.Status__c = 'Request';
                uaReq.Outcome__c = '';
                assignForUpdate.add(uaReq);
                
                                    
                mapAssignmentsToUsers.put(ua, u);
                uniqueUsers.add(u.Id);
              }
        }
                                   
        // Kick off the batch to update Users (and User Assignment status)
        if (!system.isBatch() && mapAssignmentsToUsers.size() > 0){         
          Database.executeBatch(new UserAssignmentBatch(mapAssignmentsToUsers), 200);
        }    
        
        // Update the User Assignments which attempted to update Users already being reassigned
        Database.update(assignForUpdate, false);

    }
}