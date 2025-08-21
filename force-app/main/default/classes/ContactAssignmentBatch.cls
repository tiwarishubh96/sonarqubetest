/*
 * ContactAssignmentBatch
 * ----------------------------
 * Invoked by the ContactAssignmentHandler 
 * For a given list of fields to update the specified Contact in batches
 *  07/03/2020 bphan EAD-1539 Created
 */
public class ContactAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    static String CLASSNAME = 'ContactAssignmentBatch';
    public List<Contact> accountsForUpdate = new List<Contact>();
    public Set<Id> uniqueContacts = new Set<Id>();
    public List<Contact_Assignment__c> cas2Update = new List<Contact_Assignment__c>();
    public Map<Id, Id> account2assignment = new Map<Id, Id>();

    // constructor
    public ContactAssignmentBatch(Map<Contact_Assignment__c, Contact> ca2Contact) {
        // Contact update will be attempted for all Contacts
        for (Contact_Assignment__c ca : ca2Contact.keySet()) {
            uniqueContacts.add(ca.Contact__c);
            accountsForUpdate.add(ca2Contact.get(ca));
            account2assignment.put(ca.Contact__c, ca.Id);
        }
    }
    
    public List<Contact> start(Database.BatchableContext bc) {
        LogControl.push('start', CLASSNAME);
        return accountsForUpdate;
    }

    public void execute(Database.BatchableContext bc, List<Contact> uContacts) {
        LogControl.push('execute', CLASSNAME);

        // Update the accounts
        Database.SaveResult[] srList = Database.update(uContacts, false);
        System.Debug('ContactAssignmentBatch Updated Contact:' + uContacts)            ;
        
        // Iterate through returned results using the Contacts list
        // as ids can be picked up for failed records here - the SaveResult list corresponds in order
        for (Integer i = 0; i < uContacts.size(); i++) {
            Contact_Assignment__c caUpdate = new Contact_Assignment__c();
            caUpdate.Id = account2assignment.get(uContacts[i].id);                          
            Database.SaveResult sr = srList[i];            
            if (sr.isSuccess()) {
                caUpdate.Status__c = 'Success';
                caUpdate.Outcome__c = '';
            } else {
                caUpdate.Status__c = 'Fail';
                Database.Error err = sr.getErrors()[0];
                caUpdate.Outcome__c = err.getStatusCode() + ': ' + err.getMessage();
            }
            // Update the Contact Assignment records too
            cas2Update.add(caUpdate);
            
        }

        // Update the Contact Assignment records too
        User thisUser = [Select Id from User where isActive = true and Profile.name = 'System Administrator' LIMIT 1];
        Database.SaveResult[] srAA;
        if (Test.isRunningTest()){
           System.runAs(thisUser){
               srAA = database.update(cas2Update,false);
           }    
        }else{    
            srAA = Database.update(cas2Update,false);
        }       
    }

    public void finish(Database.BatchableContext bc) {
        LogControl.push('finish', CLASSNAME);
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
    }
}