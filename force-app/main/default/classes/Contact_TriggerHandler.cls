/**
 @author Craig Bradshaw
 @date 15-Feb-2019
 @description trigger handler class for contact trigger. This class should be responsible for invoking all business logic
 involved on contact.
 */

public without sharing class Contact_TriggerHandler implements TriggerHandlerInterface {

    public void BeforeInsert(List<SObject> newItems) {
        Contact_Helper.syncCommunicationPreferences((List<Contact>) newItems);
        Contact_Helper.populateLocalCRMData((List<Contact>) newItems);
        Contact_ValidationRules.validateMailingCityandStreet(newItems);
        Contact_Helper.updateEmailOptOutLMT((List<Contact>)newItems);
        Contact_Helper.updateFoundationFieldsFromAccount((List<Contact>) newItems);
	
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Contact_Helper.syncCommunicationPreferences((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems);
        Contact_Helper.alignedHardBounce((List<Contact>) newItems.values(), (Map<Id, Contact>) oldItems); // 02/01/2021 bphan EAD-2035
        Contact_Helper.updateSyncDateTime((List<Contact>) newItems.values(),(Map<Id, Contact>)oldItems);
        Contact_ValidationRules.validateMailingCityandStreet((List<Contact>)newItems.values());
        Contact_Helper.updateEmailOptOutLMT((List<Contact>)newItems.values());
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {
    }

    public void AfterInsert(Map<Id, SObject> newItems) {
 //       Contact_Helper.populateNumAccountContacts((List<Contact>)newItems.values());
    }

    public void AfterUndelete(Map<Id, SObject> oldItems) {
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
//        Contact_Helper.populateNumAccountContacts((List<Contact>)newItems.values());
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {
//        Contact_Helper.populateNumAccountContacts((List<Contact>)oldItems.values());
    }



}