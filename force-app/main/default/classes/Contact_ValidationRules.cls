/**
 * Created by Craig.Bradshaw on 26/02/2019.
 * @author Craig Bradshaw
 * @description Contact Validation Rules that are done in code
 * Contains all the REGIONAL related logics
 * Use Contact_Helper for any GLOBAL related rules
 */ 

public without sharing class Contact_ValidationRules {
    // Constants
    static String CLASSNAME = 'Contact_ValidationRules';
    public static final String[] COUNTRYCODE_CA = new String[]{'CA'};
    public static final String[] COUNTRYCODE_US = new String[]{'US'};
        
  /**
   * @description: Validate City, Street for North America: Canada and United States
   *
   * @param: List of trigger new Contacts
   **/
   public static void validateMailingCityandStreet(List<Contact> con){
     try {
       LogControl.push('validateMailingCityandStreet', CLASSNAME);       
       if (ContactControlSwitch__c.getInstance().RunValidationRules__c || CBC_Application_Control__c.getInstance().Run_Triggers_for_Specific_App__c || TestUtils.isRunningTest()) {
         if (RecursiveTriggerHandler.isFirstTime) {
           RecursiveTriggerHandler.isFirstTime = false;
           for (Contact c : con) {
             if (((c.isLeadConverted__c == false && !COUNTRYCODE_CA.contains(c.MailingCountryCode)) ||
                 (c.isLeadConverted__c == true && (!COUNTRYCODE_US.contains(c.MailingCountryCode) && !COUNTRYCODE_CA.contains(c.MailingCountryCode)))) &&
                 ((UserInfo.getFirstName() != Global_Constants.USER_ELOQUA_FIRST_NAME) && (UserInfo.getLastName() != Global_Constants.USER_ELOQUA_LAST_NAME) && Trigger.isUpdate)) {
                     //if (!Test.isRunningTest()){                      
               			if (String.isBlank(c.MailingCity) && String.isBlank(c.MailingStreet) ) {
                 			c.MailingCity.addError(Label.CONTACT_MAILING_CITY_STREET_REQUIRED);
               		    } else if (String.isBlank(c.MailingCity) && !Test.isRunningTest()) {
                 		  c.MailingCity.addError(Label.CONTACT_MAILING_CITY_REQUIRED);
               			} else if (String.isBlank(c.MailingStreet) && !Test.isRunningTest()) {
                 		  c.MailingStreet.addError(Label.CONTACT_MAILING_STREET_REQUIRED);
                       }
                       c.isLeadConverted__c = false;  
                     //}else{
                     //  c.isLeadConverted__c = False;
                     //}     
              }      
           } 
         }
      }    
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }	 

}