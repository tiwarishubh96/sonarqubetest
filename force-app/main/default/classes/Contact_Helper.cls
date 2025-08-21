/**
 * Created by Craig.Bradshaw on 18/02/2019.
 * @description Contact Helper is a helper class that performs a variety of field level checking and manipulated based on Contact data
 * Contains all the GLOBAL related logics
 * Use Contact_ValidationRules for any REGIONAL related rules
 */

public without sharing class Contact_Helper {
  static String CLASSNAME = 'Contact_Helper';
   
  /**
   * @description: Updates the Email_Opt_Out_LMT__c for unconverted Leads fed in from Eloqua
   *   (PopulateLocalCRMFieldsOncontact)
   * @param:  List of trigger new Contacts
   **/    
   public static void updateEmailOptOutLMT(List<Contact> contacts){
     try {
       LogControl.push('updateEmailOptOutLMT', CLASSNAME);
       if (RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
         RecursiveTriggerHandler.isFirstTime = false;
         for (Contact c : contacts) {
           if (c.isLeadConverted__c == false) {
             if (c.HasOptedOutOfEmail == true && system.UserInfo.getFirstName() != Global_Constants.USER_ELOQUA_FIRST_NAME && system.UserInfo.getLastName() != Global_Constants.USER_ELOQUA_LAST_NAME) {
               c.Email_Opt_Out_LMT__c = Datetime.now();
             }
           }
           c.isLeadConverted__c = false;
         }
      }
    } catch (Exception e) { LogControl.debugException(e);
    } finally { LogControl.pop(); 
    }
  }	 
  /**
   * @description:If the user updating the records isn't in an exception list, then set the syncDataTime to null
   * (PopulateLocalCRMFieldsOncontact)
   * @param: List of trigger new Contacts
   * @param: map of trigger old Contact
   **/    
  public static void updateSyncDateTime(List<Contact> Contacts, Map<Id, Contact> oldContactsMap){
    try{
      LogControl.push('updateSyncDateTime', CLASSNAME);
      //18 digit user ids are added in the SPPDataSyncSkipUsers label, some of them are - Eloqua interation user, Inside sales, Informatica UserAccount
      List<String> skipUsers = Label.SPPDataSyncSkipUsers.split(',');
      Set<String> skipUserSet = new Set<String>();
      skipUserSet.addAll(skipUsers);
      System.debug('skipUserSet &&&&& '+skipUserSet);
      for(Contact c :Contacts){
        //Set SyncDateTime to null if the user updating the record is not in the skipUserSet
        if((oldContactsMap != null && oldContactsMap.get(c.Id)!= null && c.SyncDateTime__c == oldContactsMap.get(c.Id).SyncDateTime__c)
            && (skipUserSet != null && !skipUserSet.contains(UserInfo.getUserId())) ){
                    c.SyncDateTime__c = null;
         }
       }
    } catch (Exception e) { LogControl.debugException(e);
    } finally { LogControl.pop(); 
    }
  }	
  /**
   * @description:Calculates the number of contacts on realted account
   *
   * @param: List of trigger new Contacts
   **/
/*  public static void populateNumAccountContacts(List<Contact> contacts){
    try {
      LogControl.push('populateNumAccountContacts', CLASSNAME);       
      List<Id> accountIds = new List<Id>();
      for(Contact c:contacts){
        accountIds.add(c.AccountId);
      }
      List<Account> updateAccounts = [select Id, Number_of_contacts__c, (select Id from Contacts) from Account where Id IN :accountIds];
      for(Account account:updateAccounts){
        System.debug('account contacts found  : ** ' + account.Contacts.size());
        if(account.Contacts != null){
          account.Number_of_contacts__c = Integer.valueOf(account.Contacts.size());
        }
      }
      update updateAccounts;
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }	 
*/
  /**
   * @description: Populate the Local CRM Data from the related Account object onto the Contact object
   * (PopulateLocalCRMFieldsOncontact)
   * @param:  List of trigger new Contacts
   **/
  public static void populateLocalCRMData(List<Contact> Contacts){
    try {
      LogControl.push('populateLocalCRMData',CLASSNAME);
      Set<Id> accIds = new Set<Id>();
      for (Contact c : Contacts) {
         accIds.add(c.AccountId);
      }
      Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name,RecordType.Name, Local_CRM_Region__c,Local_CRM_Country__c, Local_CRM_Name__c FROM Account
                                                          WHERE Id IN :accIds AND RecordType.Name = 'Partner Account']);

      //Set the Local CRM Country
      for (Contact c : Contacts) {
        if (accountMap != null && accountMap.get(c.AccountId) != null) {
          c.Local_CRM_Region__c = accountMap.get(c.AccountId).Local_CRM_Region__c;
          c.Local_CRM_Country__c = accountMap.get(c.AccountId).Local_CRM_Country__c;
          c.Local_CRM_Name__c = accountMap.get(c.AccountId).Local_CRM_Name__c;
        }
      }
    } catch (Exception e) { LogControl.debugException(e);
    } finally { LogControl.pop(); 
    }
  }

    /**
     * @description: Align checkbox and picklist communication preference field values on new Contacts
     * Pick up preferences for new Contacts
     * Ideally these come from the new picklist fields
     * If picklist value is --None-- / null
     * look to standard fields for for new Contacts from InTouch / Eloqua / data import
     * @param: List of trigger new Contacts
    **/
	public static void syncCommunicationPreferences (List<Contact> contacts) {
        try {
            LogControl.push('syncCommunicationPreferences', CLASSNAME);
            for (Contact con : contacts) {
                
                // 1) PHONE CALL
                if (con.Allow_Call__c == 'No') {
                    // Default value of DoNotCall flag is false
                    con.DoNotCall = true;
                } else if (con.Allow_Call__c == null) {
                    if (con.DoNotCall) {
                        con.Allow_Call__c = 'No';
                    } // We can't assume a false checkbox means calls are allowed
                }
                
                // 2) POSTAL MAIL
                if (con.Allow_Mail__c == 'No') {
                    // Default value of Do_Not_Mail__c flag is false
                    con.Do_Not_Mail__c = true;
                } else if (con.Allow_Mail__c == null) {
                    // As the picklist is not set we can use the checkbox value as a guide
                    if (con.Do_Not_Mail__c) {
                        con.Allow_Mail__c = 'No';
                    } // we can't assume a false checkbox means post is allowed
                }
                
                // 3) SURVEY
                // There is no checkbox preference for Survey 
                
                // 4) EMAIL
                if (con.HasOptedOutOfEmail) {
                    con.Allow_Email__c = 'No';
                    // We can't assume a false checkbox means emails are allowed
                } else if (con.Allow_Email__c == 'No') {
                    // Default value of HasOptedOutOfEmail flag is false, only set it if email definitely allowed
                    con.HasOptedOutOfEmail = true;
                }
            } // end of loop
        } catch (Exception e) { LogControl.debugException(e);
        } finally { LogControl.pop(); 
        }
	}

    /**
     * @description: Align checkbox and picklist communication preference field values on updated Contacts
     * @param: List of trigger new Contacts
     * @param: Map of trigger old Contacts
    **/
    public static void syncCommunicationPreferences (List<Contact> contacts, Map<Id, Contact> oldContactMap) {
        try {
            LogControl.push('syncCommunicationPreferences', CLASSNAME);
            // For updates values have been selected - not defaulted - so we update according to what has changed
            for (Contact con : contacts) {
                Contact oldContact = oldContactMap.get(con.Id);
                // Identify updates from to the checkbox preferences for Phone and Postal Mail
                // If none, look for updates to the picklist preferences which could come from InTouch or Salesforce
                // and synchronize the picklist/checkbox values as far as this is possible
                
                // 1) PHONE CALL
                if (con.DoNotCall != oldContact.DoNotCall) {
                    if (con.DoNotCall) {
                        con.Allow_Call__c = 'No';
                    } else {
                        con.Allow_Call__c = 'Yes';
                    }
                } else if (con.Allow_Call__c != oldContact.Allow_Call__c) {
                    if (con.Allow_Call__c == 'No') {
                        con.DoNotCall = true;
                    } else {
                        con.DoNotCall = false;
                    }
                }
                
                // 2) POSTAL MAIL
                if (con.Do_Not_Mail__c != oldContact.Do_Not_Mail__c) {
                    if (con.Do_Not_Mail__c) {
                        con.Allow_Mail__c = 'No';
                    } else {
                        con.Allow_Mail__c = 'Yes';
                    }
                } else if (con.Allow_Mail__c != oldContact.Allow_Mail__c) {
                    if (con.Allow_Mail__c == 'No') {
                        con.Do_Not_Mail__c = true;
                    } else {
                        con.Do_Not_Mail__c = false;
                    }
                }
                
                // 3) SURVEY
                // There is no checkbox preference for Survey so no synch is required for Allow_Survey__c preference field
                
                // 4) EMAIL
                // Identify updates from Eloqua or imported Contacts to the Email checkbox HasOptedOutOfEmail
                // If none, look for Salesforce updates to the picklist preference
                if (con.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail) {
                    if (con.HasOptedOutOfEmail) {
                        con.Allow_Email__c = 'No';
                    } else {
                        con.Allow_Email__c = 'Yes';
                    }
                } else if (con.Allow_Email__c != oldContact.Allow_Email__c) {
                    if (con.Allow_Email__c == 'No') {
                        con.HasOptedOutOfEmail = true;
                    } else {
                        con.HasOptedOutOfEmail = false;
                    }
                }        
            } // end of loop
        } catch (Exception e) { LogControl.debugException(e);
        } finally { LogControl.pop(); 
        }
	}

    /**
     * @description: Align checkbox Hard Bounce base on Email address
     * @param: List of trigger new Contacts
     * @param: Map of trigger old Contacts
    **/
    public static void alignedHardBounce (List<Contact> contacts, Map<Id, Contact> oldContactMap) {
        try {
            LogControl.push('alignedHardBounce', CLASSNAME);
            // If Email address is changed, need to uncheck on HardBounce__c
            for (Contact con : contacts) {
                Contact oldContact = oldContactMap.get(con.Id);
                if (con.Email != oldContact.Email) {
                    con.HardBounce__c = false;
                }
                
            } // end of loop
        } catch (Exception e) { LogControl.debugException(e);
        } finally { LogControl.pop(); 
        }
	}

    /**
   * @description: Update Foundation Fields from Account 
   * 08/12/2020 Dharani Chennupati
   * EAD-1564
   **/
     public static void updateFoundationFieldsFromAccount (List<Contact> Contacts) {
        try {
            LogControl.push('updateFoundationFieldsFromAccount', CLASSNAME);            
            Set<Id> accountIds = new Set<Id>();
            for (Contact con : Contacts) {
                accountIds.add(con.AccountId);
            }
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT ID,Name,Foundation_Customer__c,Eligibility_Start_Dateone__c,
                                                                Eligibility_Expiration_Date__c,Sage_Foundation_Customer__c,
                                                                Military_Veteran_Owned_Business__c,Grant_Recipient__c,Product_Recipient__c,
                                                                Volunteer_Recipient__c,FreeTrial__c FROM Account WHERE ID IN :accountIds]);            
            for (Contact con : Contacts) {
                if (accountMap != null && accountMap.get(con.AccountId) != null) {
                    con.Foundation_Customer__c=  accountMap.get(con.AccountId).Foundation_Customer__c;
                    con.Eligibility_Start_Dateone__c= accountMap.get(con.AccountId).Eligibility_Start_Dateone__c;
                    con.Eligibility_Expiration_Date__c= accountMap.get(con.AccountId).Eligibility_Expiration_Date__c;
                    con.Sage_Foundation_Customer__c= accountMap.get(con.AccountId).Sage_Foundation_Customer__c;
                    con.Military_Veteran_Owned_Business__c= accountMap.get(con.AccountId).Military_Veteran_Owned_Business__c;
                    con.Grant_Recipient__c= accountMap.get(con.AccountId).Grant_Recipient__c;
                    con.Product_Recipient__c= accountMap.get(con.AccountId).Product_Recipient__c;
                    con.Volunteer_Recipient__c= accountMap.get(con.AccountId).Volunteer_Recipient__c;
                    con.FreeTrial__c= accountMap.get(con.AccountId).FreeTrial__c;
                }
            }            
        } 
        
        catch (Exception e) { LogControl.debugException(e);
                            } finally { LogControl.pop(); 
                                      }
    }
}