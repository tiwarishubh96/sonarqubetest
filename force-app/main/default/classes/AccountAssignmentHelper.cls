/*
 * AccountAssignmentHelper
 * ----------------------------
 * Invoked by the AccountAssignmentTrigger and AccountAssignmentHandler class when an Account Assignment record is inserted
 * Updates the specified Account's owner with the account identified in the Assignee__c field
 * via a batched job - a simple update was resulting in Apex CPU limits exceeded on >50 Account updates
 */
public class AccountAssignmentHelper {
    static String CLASSNAME = 'AccountAssignmentHelper';    
    /**
     * @description EAD-1539 Mass update Accounts via the Data Import Wizard
     * @param newAAs list of new trigger records
     */

    public static void assignAccounts(List<Account_Assignment__c> newAAs) {
        LogControl.push('assignAccounts', CLASSNAME);
        List<Account_Assignment__c> assignForUpdate = new List<Account_Assignment__c>();
        // Map to allow recording of updates in the original Account Assignment records and the Accounts themselves
        Map<Account_Assignment__c, Account> mapAssignmentsToAccounts = new Map<Account_Assignment__c, Account>();
        // Unique set of Accounts to prevent duplicate updates to same Account
        Set<Id> uniqueAccounts = new Set<Id>();
        //system.Debug('AccountAssignmentHelper newAAs:' + newAAs);
        // "Create" Accounts for update
        for (Account_Assignment__c aa : newAAs) {
            if (uniqueAccounts.contains(aa.Account__c)) {
                // duplicate Account spotted
                Account_Assignment__c aaUpdate = new Account_Assignment__c();
                aaUpdate.Id = aa.Id;
                aaUpdate.Status__c = 'Duplicate';
                aaUpdate.Outcome__c = '';
                assignForUpdate.add(aaUpdate);
            } else {
                Account a = new Account();
                a.Id = aa.Account__c; 
                if (!String.isBlank(aa.Account_Name__c)){  // account name can't be empty
                	a.Name = aa.Account_Name__c;
                }    
                if (!String.isBlank(aa.Account_Billing_City__c)){ // billing city is mandatory
                	a.BillingCity = aa.Account_Billing_City__c;
                }    
                if (!String.isBlank(aa.Account_Billing_Street__c)){ //billing street is mandatory
                	a.BillingStreet = aa.Account_Billing_Street__c;
                }    
                if (!String.isBlank(aa.Account_Billing_Country__c)){ //billing country is mandatory                
                	a.BillingCountry = aa.Account_Billing_Country__c;
                }    
                if (!String.isBlank(aa.Account_Billing_Postal__c)){ //billing postal is mandatory          
                	a.BillingPostalCode = aa.Account_Billing_Postal__c;
                }
                if (!String.isBlank(aa.Account_Billing_Postal__c)){ //billing postal is mandatory          
                	a.BillingState = aa.Account_Billing_State__c;                                
                }    
                if (!String.isBlank(aa.Account_Currency__c)){
                    a.CurrencyIsoCode = aa.Account_Currency__c;
                }    
	            if (!String.isBlank(aa.Account_Locale__c)){
                    a.Locale__c = aa.Account_Locale__c;
                }    
     			if (!String.isBlank(aa.Account_Industry__c)){
                        a.Industry = aa.Account_Industry__c;
                }    
                if (!String.isBlank(aa.Account_Owner__c))
                {  // ownerid can't be empty    
                	a.OwnerId = aa.Account_Owner__c;
                }    
        		if (!String.isBlank(aa.Account_Phone__c)){
                	a.Phone = aa.Account_Phone__c;
            	}
            	if (!String.isBlank(aa.Account_Sales_Office__c)){
                	a.Sales_Office__c = aa.Account_Sales_Office__c;
                }    
                
                //added new section of code for Customer insight fields 
                if (!String.isBlank(aa.Insight_1__c)){
                    a.Insight_1__c = aa.Insight_1__c;
                }  
                if (!String.isBlank(aa.Insight_2__c)){
                    a.Insight_2__c = aa.Insight_2__c;
                }  
                if (!String.isBlank(aa.Insight_3__c)){
                    a.Insight_3__c = aa.Insight_3__c;
                }  
                if (!String.isBlank(aa.Insight_4__c)){
                    a.Insight_4__c = aa.Insight_4__c;
                }  
                if (!String.isBlank(aa.Insight_5__c)){
                    a.Insight_5__c = aa.Insight_5__c;
                }  
                if (!String.isBlank(aa.Insight_6__c)){
                    a.Insight_6__c = aa.Insight_6__c;
                }  
                //added new section of code for Customer insight fields 
                
                Account_Assignment__c aaReq = new Account_Assignment__c();
                aaReq.Id = aa.Id;
                aaReq.Status__c = 'Request';
                aaReq.Outcome__c = '';
                assignForUpdate.add(aaReq);
                
                mapAssignmentsToAccounts.put(aa, a);
                uniqueAccounts.add(a.Id);
               //System.Debug('AccountAssignmentHelper Success=' + a);
              }
        }
        
        //System.Debug('AccountAssignmentHelper assignForUpdate=' + assignForUpdate);
        // Update the Account Assignments which attempted to update Accounts already being reassigned
        Database.update(assignForUpdate, false);
        
        //System.Debug('AccountAssignmentHelper maps=' + mapAssignmentsToAccounts);
        // Kick off the batch to update Accounts (and Account Assignment status)
        if (!system.isBatch() && mapAssignmentsToAccounts.size() > 0){
        	Database.executeBatch(new AccountAssignmentBatch(mapAssignmentsToAccounts), 200);
        }    

    }
}