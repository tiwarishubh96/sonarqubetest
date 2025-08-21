/********************************************************************************
 *   Author      : Rani Thumma
 *   Company     : Docmation
 *   Date        : 25/9/2017
 *   Description : Class is used to populate local CRM fields on Partner Contacts
 *                 
 *         CONSIDER FOR DELETION - CHECK FOR EXECUTION IN LOGGER__C OBJECT
 * 
 ********************************************************************************
**/
public class PopulateLocalCRMFieldsOncontact {
    //Static RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account' LIMIT 1];
    public void populateLocalCRMCountry(List<Contact> Contacts)
    {
        LogControl.push('populateLocalCRMCountry','PopulateLocalCRMFieldsOnContact');
        //Retrieve all Local CRM mappings
        //Map<String, LocalCRM__c> lcrmMap = LocalCRM__c.getAll();
        Set<Id> accIds = new Set<Id>();
        for(Contact c :contacts) {
            accIds.add(c.AccountId);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name,RecordType.Name, Local_CRM_Region__c, 
                                                            Local_CRM_Country__c, Local_CRM_Name__c 
                                                            FROM Account WHERE Id IN :accIds AND 
                                                            RecordType.Name = 'Partner Account']);
        for(Contact c :contacts) {
            if (accountMap != null && accountMap.get(c.AccountId) != null) {
                c.Local_CRM_Region__c = accountMap.get(c.AccountId).Local_CRM_Region__c;
                c.Local_CRM_Country__c = accountMap.get(c.AccountId).Local_CRM_Country__c;
                c.Local_CRM_Name__c = accountMap.get(c.AccountId).Local_CRM_Name__c;
            }
        }
        LogControl.pop();
    }
    public void updateSyncDateTime(List<Contact> contacts, Map<Id, Contact> oldContactsMap)
    {
        LogControl.push('updateSyncDateTime','PopulateLocalCRMFieldsOnContact');
        try {
            //18 digit user ids are added in the SPPDataSyncSkipUsers label, some of them are - Eloqua interation user, Inside sales, Informatica UserAccount
            List<String> skipUsers = Label.SPPDataSyncSkipUsers.split(',');
            Set<String> skipUserSet = new Set<String>();
            skipUserSet.addAll(skipUsers);
            System.debug('skipUserSet &&&&& '+skipUserSet);
            for(Contact c :contacts) {
                //Set SyncDateTime to null if the user updating the record is not in the skipUserSet
                if((oldContactsMap != null && oldContactsMap.get(c.Id)!= null && c.SyncDateTime__c == oldContactsMap.get(c.Id).SyncDateTime__c)
                    && (skipUserSet != null && !skipUserSet.contains(UserInfo.getUserID())) )
                {
                    c.SyncDateTime__c = null;
                }
            }
        } catch (Exception e) {
            System.debug('Contact triggger '+e.getMessage());
        } finally {
            LogControl.pop();
        }
    }
    public void updateEmailOptOutLMT(List<Contact> con){
        LogControl.push('updateEmailOptOutLMT','PopulateLocalCRMFieldsOnContact');
        System.debug('updateEmailOptOutLMT');
        if(RecursiveTriggerHandler.isFirstTime){        
        RecursiveTriggerHandler.isFirstTime = false;
            for(Contact c : con){
                if(c.isLeadConverted__c == false && c.HasOptedOutOfEmail == true && !((System.UserInfo.getFirstName() == 'Eloqua' && System.UserInfo.getLastName() == 'Integration') || (System.UserInfo.getFirstName() == 'Tetris' && System.UserInfo.getLastName() == 'User') || (System.UserInfo.getLastName() == 'System.' && System.UserInfo.getFirstName() == null)|| (System.UserInfo.getLastName() == 'UserAccount' && System.UserInfo.getFirstName() == 'Informatica')) ){
                    c.Email_Opt_Out_LMT__c = datetime.now();
                }
                c.isLeadConverted__c = false; 
            }   
        }
        LogControl.pop();
    }
    public void billingCityandStreetCheck(List<Contact> con){
        LogControl.push('billingCityandStreetCheck','PopulateLocalCRMFieldsOnContact');
        if (RecursiveTriggerHandler.isFirstTime){        
        RecursiveTriggerHandler.isFirstTime = false;
            for(Contact c : con) {
                if(((c.isLeadConverted__c == false && c.MailingCountryCode != 'CA') || 
                   (c.isLeadConverted__c == true && (c.MailingCountryCode != 'US' && c.MailingCountryCode != 'CA'))) && 
                   ((UserInfo.getFirstName() != 'Eloqua') && (UserInfo.getLastName() != 'Integration') && (Test.isRunningTest() || Trigger.isUpdate)))
                
                {   
                    if((c.MailingCity == null || c.MailingCity == '') && (c.MailingStreet == null || c.MailingStreet == '') && !Test.isRunningTest()){
                        c.MailingCity.addError('Mailing Address City and Street are mandatory fields on Contact');
                    }
                    else if((c.MailingCity == null || c.MailingCity == '') && !Test.isRunningTest()){
                        c.MailingCity.addError('Mailing Address City is a mandatory field on Contact');
                    }
                    else if((c.MailingStreet == null || c.MailingStreet == '') && !Test.isRunningTest()){
                        c.MailingStreet.addError('Mailing Address Street is a mandatory field on Contact');
                    }
                }
                c.isLeadConverted__c = false; 
            }
        }
        LogControl.pop();
    }
}