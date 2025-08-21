/*
 * AccountAssignmentBatch
 * ----------------------------
 * Invoked by the AccountAssignmentHandler  
 * For a given list of fields to update the specified Account in batches
 *  06/13/2020 bphan EAD-1539 Created
 */      
public class AccountAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    static String CLASSNAME = 'AccountAssignmentBatch';
    public List<Account> accountsForUpdate = new List<Account>();
    public Set<Id> uniqueAccounts = new Set<Id>();
    public List<Account_Assignment__c> aas2Update = new List<Account_Assignment__c>();
    public Map<Id, Id> account2assignment = new Map<Id, Id>();

    // constructor
    public AccountAssignmentBatch(Map<Account_Assignment__c, Account> aa2Account) {
        // Account update will be attempted for all Accounts
        for (Account_Assignment__c aa : aa2Account.keySet()) {
            uniqueAccounts.add(aa.Account__c);
            accountsForUpdate.add(aa2Account.get(aa));
            account2assignment.put(aa.Account__c, aa.Id);
        }
    }
    
    public List<Account> start(Database.BatchableContext bc) {

if(bc==null){
}
else if(b!=null){
}
        LogControl.push('start', CLASSNAME);
        return accountsForUpdate;
    }

    public void execute(Database.BatchableContext bc, List<Account> uAccounts) {
        LogControl.push('execute', CLASSNAME);

        // Update the accounts
        Database.SaveResult[] srList = Database.update(uAccounts, false);
        //System.Debug('AccountAssignmentBatch Updated Account:' + uAccounts)            ;
        
        // Iterate through returned results using the Accounts list
        // as ids can be picked up for failed records here - the SaveResult list corresponds in order
        for (Integer i = 0; i < uAccounts.size(); i++) {
            Account_Assignment__c aaUpdate = new Account_Assignment__c();
            aaUpdate.Id = account2assignment.get(uAccounts[i].id);                          
            Database.SaveResult sr = srList[i];            
            if (sr.isSuccess()) {
                aaUpdate.Status__c = 'Success';
                aaUpdate.Outcome__c = '';
            } else {
                aaUpdate.Status__c = 'Fail';
                Database.Error err = sr.getErrors()[0];
                aaUpdate.Outcome__c = err.getStatusCode() + ': ' + err.getMessage();
            }
            // Update the Account Assignment records too
            aas2Update.add(aaUpdate);
            
        }

        // Update the Account Assignment records too
        User thisUser = [Select Id from User where isActive = true and Profile.name = 'System Administrator' LIMIT 1];
        Database.SaveResult[] srAA;
        if (Test.isRunningTest()){
           System.runAs(thisUser){
               srAA = database.update(aas2Update,false);
           }    
        }else{    
            srAA = Database.update(aas2Update,false);
        }
    }    

    public void finish(Database.BatchableContext bc) {
        LogControl.push('finish', CLASSNAME);
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
       // System.debug(job);
    }
}
