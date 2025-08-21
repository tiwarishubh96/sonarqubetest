/**
 * @description Server-side controller for custCommSubscriptionUpgradeButton.cmp
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
public with sharing class CustCommSubscriptionUpgradeBtnCtrl {
    /**
     * @description Creates new case of type upgrade.
     * @author      Arturs Gusjko <arturs.gusjko@betercloudsolutions.co.uk>
     * @date        2016-05-23
     */

    static public void createCase() {
        try {
            CommunityUtilities.createCase('upgrade', '');
            if (Test.isRunningTest()) TestExc.subscribe(CustCommSubscriptionUpgradeBtnCtrl.class, 'error');
        } catch (Exception ex) {
            throw ex;
        }
        //throw new AuraHandledException('bla bla');
    }


    @AuraEnabled
    static public void upgradeTrial() {

        System.debug('xxgot here');
        User currentUser = [SELECT contactId, contact.AccountId FROM User WHERE Id = :Userinfo.getUserId()];
        if (currentUser.contactId != null) {
            Id billingAccount = currentUser.contact.AccountId;
            List<Subscription_Master__c> subscriptionMasters = [SELECT Is_Cancelled__c, Is_Blocked__c, Is_Upgraded__c,Is_ZProduct_Upgradeable__c,Sage_API_Activity__r.ActivityType__c,Status__c,Submit_for_Upgrade__c FROM Subscription_Master__c where Account__c = :billingAccount];
            if (subscriptionMasters.size() > 0) {
                System.debug('xxgot here1' + subscriptionMasters[0]);
                if (subscriptionMasters[0].Status__c == 'Trial' && subscriptionMasters[0].Sage_API_Activity__r.ActivityType__c == 'TryNow' && subscriptionMasters[0].Is_Upgraded__c == false && subscriptionMasters[0].Is_ZProduct_Upgradeable__c == true && subscriptionMasters[0].Is_Cancelled__c == false && subscriptionMasters[0].Is_Blocked__c == false) {
                    System.debug('xxxupdate');
                    subscriptionMasters[0].Submit_for_Upgrade__c = true;
                    update subscriptionMasters;
                } else {
                    createCase();
                }
            }

        }
    }



    /**
     * @description Checks if the current subscription is upgradeable
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-01
     * @return whether the current user has an upgradeable subscription
     */
    @AuraEnabled
    static public Boolean canUpgradeSubscription() {
        Boolean canUpgrade = false;
        // Get the billing account of the current User
        User currentUser = [SELECT contactId, contact.AccountId FROM User WHERE Id = :Userinfo.getUserId()];
        if (currentUser.contactId != null) {
            Id billingAccount = currentUser.contact.AccountId;
            // We query the Subscription Master object to find the number of subscriptions the billing account has
            // related to ZProducts that are upgradeable (specified by the lookup field to itself: Upgrade_To__c)
            Integer upgradeableAssets = [
                    SELECT COUNT()
                    FROM Subscription_Master__c
                    WHERE
                           Account__c = :billingAccount AND Is_ZProduct_Upgradeable__c = true AND ChannelPartner__r.ChannelPlatform__r.Name != 'AppDirect' and Is_Cancelled__c = false and Is_Blocked__c = false];


            canUpgrade = upgradeableAssets > 0;
        }
        return canUpgrade;
    }

    /**
     * @description Determines whether there are open subscription management cases.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-08-17
     * @return      true if there are open cases of similar type, false otherwise.
     */
    @AuraEnabled
    static public Boolean hasOpenCases() {
        return !CommunityUtilities.getSubscriptionManagementOpenCases().isEmpty();
    }


}