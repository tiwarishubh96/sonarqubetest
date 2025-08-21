/********************************************************************************
 *   Author      : Rani Thumma
 *   Company     : Docmation
 *   Date        : 25/9/2017
 *   Description : Class is used to populate local CRM fields on Partner Accounts
 *                 
 *         CONSIDER FOR DELETION - CHECK FOR EXECUTION IN LOGGER__C OBJECT
 * 
 ********************************************************************************
**/
public class PopulateLocalCRMFieldsOnAccount 
{        
    //Retrieve all Local CRM mappings
    Static Map<String, LocalCRM__c> lcrmMap = LocalCRM__c.getAll();
    Static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
       
    public void populateLocalCRMCountry(List<Account> accs, Map<Id, Account> oldAccountsMap) {
        LogControl.push('populateLocalCRMCountry','PopulateLocalCRMFieldsOnAccount');
        for(Account a : accs) {
            String recordTypeName = a.RecordTypeId != null && rtMap !=null && rtMap.get(a.RecordTypeId) != null?rtMap.get(a.RecordTypeId).getName():'';
            //check if the Account is synced to the Local CRM, if yes do not update the Local CRM Fields
            if (recordTypeName == 'Partner Account' && lcrmMap != null && lcrmMap.get(a.BillingCountryCode) != null && 
               (a.Partner_Agreement__c != 'Local' && a.Partner_Accountant_TnC__c == false && a.Partner_Alliance_TnC__c == false && 
                a.Partner_Implementation_TnC__c == false &&  a.Partner_ISV_TnC__c == false && a.Partner_Reseller_TnC__c == false)) {
                a.Local_CRM_Region__c = lcrmMap.get(a.BillingCountryCode).Region__c;
                a.Local_CRM_Country__c = lcrmMap.get(a.BillingCountryCode).Country__c;
                    a.Local_CRM_Name__c = lcrmMap.get(a.BillingCountryCode).Default_CRM__c;
            }
        }
        LogControl.pop();
    }
    public void populateConCRMFields(List<Account> accs, Map<Id, Account> newAccountsMap)
    {
       LogControl.push('populateConCRMFields','PopulateLocalCRMFieldsOnAccount');
       List<Contact> contactstoUpdate = new List<Contact>();
       List<Account> accounts = [SELECT Id, Name, RecordType.Name,Local_CRM_Region__c, Local_CRM_Country__c, Local_CRM_Name__c,
                            (SELECT Id, Name, Local_CRM_Region__c, Local_CRM_Country__c, Local_CRM_Name__c FROM Contacts)
                             FROM Account WHERE Id IN :newAccountsMap.keySet()AND RecordType.Name = 'Partner Account']; 
       for(Account a : accounts) {
           for(Contact c :a.contacts) {
               if (a.Local_CRM_Region__c != c.Local_CRM_Region__c ||a.Local_CRM_Country__c != c.Local_CRM_Country__c ||
                   a.Local_CRM_Name__c != c.Local_CRM_Name__c) {
                   c.Local_CRM_Region__c = a.Local_CRM_Region__c;
                   c.Local_CRM_Country__c = a.Local_CRM_Country__c;
                   c.Local_CRM_Name__c = a.Local_CRM_Name__c;
                   contactstoUpdate.add(c);
               }
           }
       }
       try {
           if (contactstoUpdate.size() > 0) {
               update contactstoUpdate;
           } 
       } catch(DMLException e) {
           System.debug('DML Exception '+e.getMessage());
       } finally {
           LogControl.pop();
       }
    }
    public void updateSyncDateTime(List<Account> accs, Map<Id, Account> oldAccountsMap)
    {
        LogControl.push('updateSyncDateTime','PopulateLocalCRMFieldsOnAccount');
        try {
            //18 digit user ids are added in the SPPDataSyncSkipUsers label, some of them are - Eloqua interation user, Inside sales, Informatica UserAccount
            List<String> skipUsers = Label.SPPDataSyncSkipUsers.split(',');
            Set<String> skipUserSet = new Set<String>();
            skipUserSet.addAll(skipUsers);
            System.debug('skipUserSet &&&&& '+skipUserSet);
            for(Account a :accs) {
                //Set SyncDateTime to null if the user updating the record is not in the skipUserSet
                if((oldAccountsMap != null && oldAccountsMap.get(a.Id)!= null && a.SyncDateTime__c == oldAccountsMap.get(a.Id).SyncDateTime__c)
                    && (skipUserSet != null && !skipUserSet.contains(UserInfo.getUserID())) ) {
                    a.SyncDateTime__c = null;
                }
            }
        } catch (Exception e) {
        	System.debug('Account triggger '+e.getMessage());
        } finally {
            LogControl.pop();
        }
    }
}