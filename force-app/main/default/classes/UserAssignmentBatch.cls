/*
 * UserAssignmentBatch
 * ----------------------------
 * Invoked by the UserAssignmentHandler 
 * For a given list of fields to update the specified User in batches
 *  06/13/2020 bphan EAD-1539 Created
 */
public class UserAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    static String CLASSNAME = 'UserAssignmentBatch';
    public List<User> usersForUpdate = new List<User>();
    public Set<Id> uniqueUsers = new Set<Id>();
    public List<User_Assignment__c> uas2Update = new List<User_Assignment__c>();
    public Map<Id, Id> user2assignment = new Map<Id, Id>();

    // constructor
    public UserAssignmentBatch(Map<User_Assignment__c, User> ua2User) {
        // User update will be attempted for all Users
        for (User_Assignment__c ua : ua2User.keySet()) {
            uniqueUsers.add(ua.User__c);
            usersForUpdate.add(ua2User.get(ua));
            user2assignment.put(ua.User__c, ua.Id);
        }
    }
    
    public List<User> start(Database.BatchableContext bc) {
        LogControl.push('start', CLASSNAME);
        return usersForUpdate;
    }

    public void execute(Database.BatchableContext bc, List<User> uUsers) {
        LogControl.push('execute', CLASSNAME);

        // Update the users
        Database.SaveResult[] srList = Database.update(uUsers, false);
        System.Debug('UserAssignmentBatch Updated User:' + uUsers)            ;
        
        // Iterate through returned results using the Users list
        // as ids can be picked up for failed records here - the SaveResult list corresponds in order
        for (Integer i = 0; i < uUsers.size(); i++) {
            User_Assignment__c uaUpdate = new User_Assignment__c();
            uaUpdate.Id = user2assignment.get(uUsers[i].id);                          
            Database.SaveResult sr = srList[i];            
            if (sr.isSuccess()) {
                uaUpdate.Status__c = 'Success';
                uaUpdate.Outcome__c = '';
            } else {
                uaUpdate.Status__c = 'Fail';
                Database.Error err = sr.getErrors()[0];
                uaUpdate.Outcome__c = err.getStatusCode() + ': ' + err.getMessage();
            }
            // Update the User Assignment records too
            uas2Update.add(uaUpdate);
            
        }

        // Update the User Assignment records too
        User thisUser = [Select Id from User where isActive = true and Profile.name = 'System Administrator' LIMIT 1];
        Database.SaveResult[] srUA;
        if (Test.isRunningTest())
        {
           System.runAs(thisUser) 
           {
               srUA = database.update(uas2Update,false);
           }    
        }   
        else
        {    
            srUA = Database.update(uas2Update,false);
        }
        System.Debug('UserAssignmentUdateStatus srUA=' + srUA);     
        
   
    }
    
  

    public void finish(Database.BatchableContext bc) {
        LogControl.push('finish', CLASSNAME);
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        System.debug(job);
    }
}