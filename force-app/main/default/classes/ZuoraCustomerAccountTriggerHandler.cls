/**
 * @description Handles Zuora__CustomerAccount__c DML Events.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
public with sharing class ZuoraCustomerAccountTriggerHandler
{
    ////////////
    // Events //
    ////////////

    static public void afterUpdate()
    {
        unblockEntitlements();
    }

    ///////////////
    // Processes //
    ///////////////

    /**
     * @description When electronic payment method id changes on a billing account, all related subscription masters
     *              are sent to the entitlement engine for unblocking.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-10
     */
    static public void unblockEntitlements()
    {
        Set<Id> paymentChangedAccountIds = new Set<Id>();
        for( Integer i = 0; i < Trigger.new.size(); i++)
        {
            Zuora__CustomerAccount__c newZAcc = (Zuora__CustomerAccount__c)Trigger.new[i];
            Zuora__CustomerAccount__c oldZAcc = (Zuora__CustomerAccount__c)Trigger.old[i];

            if( newZAcc.ElectronicPaymentMethodId__c != oldZAcc.ElectronicPaymentMethodId__c && String.isNotBlank( newZAcc.ElectronicPaymentMethodId__c ) )
            {
                paymentChangedAccountIds.add( newZAcc.Zuora__Account__c );
            }
        }

        List<Id> affectedSubsMasterIds = new List<Id>( new Map<Id, Subscription_Master__c>( [SELECT Id FROM Subscription_Master__c WHERE Is_Blocked__c = TRUE and Account__c IN :paymentChangedAccountIds ] ).keySet() );
        EntitlementEngine.unblockEntitlements( affectedSubsMasterIds );
    }
}