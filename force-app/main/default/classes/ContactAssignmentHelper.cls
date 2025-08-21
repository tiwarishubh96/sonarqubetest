/*
 * ContactAssignmentHelper
 * ----------------------------
 * Invoked by the ContactAssignmentTrigger and ContactAssignmentHandler class when an Contact Assignment record is inserted
 * Updates the specified Contact's owner with the contact identified in the Assignee__c field
 * via a batched job - a simple update was resulting in Apex CPU limits exceeded on >50 Contact updates
 */
public class ContactAssignmentHelper {
    static String CLASSNAME = 'ContactAssignmentHelper';    
    /**
     * @description EAD-1539 Mass update Contacts via the Data Import Wizard
     * @param newCAs list of new trigger records
     */

    public static void assignContacts(List<Contact_Assignment__c> newCAs) {
        LogControl.push('assignContacts', CLASSNAME);
        List<Contact_Assignment__c> assignForUpdate = new List<Contact_Assignment__c>();
        // Map to allow recording of updates in the original Contact Assignment records and the Contacts themselves
        Map<Contact_Assignment__c, Contact> mapAssignmentsToContacts = new Map<Contact_Assignment__c, Contact>();
        // Unique set of Contacts to prevent duplicate updates to same Contact
        Set<Id> uniqueContacts = new Set<Id>();
        // "Create" Contacts for update
        for (Contact_Assignment__c ca : newCAs) {
            if (uniqueContacts.contains(ca.Contact__c)) {
                // duplicate Contact spotted
                Contact_Assignment__c caUpdate = new Contact_Assignment__c();
                caUpdate.Id = ca.Id;
                caUpdate.Status__c = 'Duplicate';
                caUpdate.Outcome__c = '';
                assignForUpdate.add(caUpdate);
            } else {
                Contact c = new Contact();
                c.Id = ca.Contact__c; 
                if (!String.isBlank(ca.Contact_Email__c)){
                	c.Email = ca.Contact_Email__c;
                }    
                if (!String.isBlank(ca.Contact_Job_Role__c)){
                  c.Job_Role__c = ca.Contact_Job_Role__c;
                }    
                if (!String.isBlank(ca.Contact_FirstName__c)){
                   c.FirstName = ca.Contact_FirstName__c;
                }    
                if (!String.isBlank(ca.Contact_LastName__c)){  // Last name can't be empty                
                  c.LastName = ca.Contact_LastName__c;
                }
                if (!String.isBlank(ca.Contact_Owner__c)){  // Onwer can't be empty                                    
                	c.OwnerId = ca.Contact_Owner__c;
                }    
                if (!String.isBlank(ca.Contact_Phone__c)){
                   c.Phone = ca.Contact_Phone__c;
                }    
                if (!String.isBlank(ca.Contact_Title__c)){
                  c.Title = ca.Contact_Title__c;
                }    
                
                Contact_Assignment__c caReq = new Contact_Assignment__c();
                caReq.Id = ca.Id;
                caReq.Status__c = 'Request';
                caReq.Outcome__c = '';
                assignForUpdate.add(caReq);
                
                mapAssignmentsToContacts.put(ca, c);
                uniqueContacts.add(c.Id);
              }
        }
                                   

        // Update the Contact Assignments which attempted to update Contacts already being reassigned
        Database.update(assignForUpdate, false);
        
        // Kick off the batch to update Contacts (and Contact Assignment status)
        if (!system.isBatch() && mapAssignmentsToContacts.size() > 0){
        	Database.executeBatch(new ContactAssignmentBatch(mapAssignmentsToContacts), 200);
        }    
    }
}