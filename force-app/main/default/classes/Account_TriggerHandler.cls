/**
 * Created by craigb on 2019-02-26.
 *  @description trigger handler class for ACCOUNT trigger. This class should be responsible for invoking all business logics
 *  involved on ACCOUNT object
 */

public without sharing class Account_TriggerHandler extends TriggerService {
    public override void onBeforeInsert() {
        List<SObject> newItems = this.listNewSObject;
        //EAD - 296
        Account_ValidationRules.validateBillingCityandStreet((List<Account>) newItems);
        //Populate Eligibility Start Date based on Foundation eligibiity
        Account_Helper.UpdateStartDateBasedOnFoundationEligibility((List<Account>) newItems, new Map<Id, Account>());
        Account_Helper.updateSalesOffice((List<Account>) newItems, new Map<Id, Account>());
        Account_Helper.updateNonProfitOrganisation((List<Account>) newItems, new Map<Id, Account>()); // EAD-2262
        Account_Helper.updateRegionOnOpportunity((List<Account>) newItems);
    }

    public override void onBeforeUpdate() {
        Map<Id, SObject> newItems = this.mapNewSObject;
        Map<Id, SObject> oldItems = this.mapOldSObject;
        Account_Helper.updateSyncDateTime( (List<Account>)newItems.values(), (Map<Id, Account>) oldItems);  
        //EAD - 296
        Account_ValidationRules.validateBillingCityandStreet(newItems.values());
         Account_Helper.updateNonProfitOrganisation((List<Account>)newItems.values(), (Map<Id, Account>) oldItems);
        Account_Helper.updatePartnerOldTier((List<Account>) newItems.values(), (Map<Id, Account>) oldItems);
        Account_Helper.updateSalesOffice((List<Account>) newItems.values(), (Map<Id, Account>) oldItems);
        //Populate Eligibility Start Date based on Foundation eligibiity
        Account_Helper.UpdateStartDateBasedOnFoundationEligibility((List<Account>)newItems.values(), (Map<Id, Account>) oldItems);
        Account_ValidationRules.validateExCoSponsorship((List<Account>) newItems.values(),(List<Account>) oldItems.values());  // EAD-2227               
        Account_Helper.updateRegionOnOpportunity((List<Account>) newItems.values());
    }

    public override void onBeforeDelete() {
        Map<Id, SObject> oldItems = this.mapOldSObject;
        Account_Helper.getBillingAccountsAndSubscriptionMaster((Map<Id, Account>) oldItems);   
    }

    public override void onAfterUpdate() {
        Map<Id, SObject> newItems = this.mapNewSObject;
        Map<Id, SObject> oldItems = this.mapOldSObject;
        Account_Helper.updateZquQuoteOwner((List<Account>) newItems.values(), (List<Account>) oldItems.values(), (Map<Id, Account>) newItems);
        Account_Helper.getVatAndNameUpdatedAccountIDs((List<Account>) newItems.values(), (List<Account>) oldItems.values());        
        Account_Helper.getBillingAddressandPhoneinZuora((List<Account>) newItems.values(), (List<Account>) oldItems.values());
        Account_Helper.updateFoundationFieldsOnContact((List<Account>) newItems.values(), (List<Account>) oldItems.values());
        Account_Helper.updateNonProfitOrganisationContacts((List<Account>) newItems.values(),(List<Account>) oldItems.values()); // 02/25/2021 bphan EAD-2114
    }
}