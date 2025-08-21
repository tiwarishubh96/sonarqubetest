/**
 * @description Provides API level methods for managing entitlements.
 *
 *              All entitlement related functionality between entitlments and other functional components
 *              should be invoked through this class.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
public abstract with sharing class EntitlementEngine
{
    static {
        // Creates a dummy entitlement message definition to reference it instead of real pre-defined
        // definitions. This allows to change definitions without the need to amend the test code.
        if( Test.isRunningTest() )
        {
            Entitlement_Message_Definition__c dummyDef = new Entitlement_Message_Definition__c();
            dummyDef.Url__c = '/test';
            dummyDef.Action_Name__c = 'Test';
            dummyDef.Method__c = 'GET';
            dummyDef.Message_Format__c = '{}';
            insert dummyDef;
        }
    }

    /**
     * @description A request wrapper for create entitlements method.
     */
    public class CreateEntitlementRequest
    {
        public Id parentId { get; set; }
        // determines if the entitlement is full (active) or trial.
        public Boolean isTrial { get; set; }

        public CreateEntitlementRequest(final Id parentId, final Boolean isTrial)
        {
            this.parentId = parentId;
            this.isTrial = isTrial;
        }
    }

    /**
     * @description Creates entitlements for given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       reqs is a collection of create requests. See inner CreateEntitlementRequest
     *                   class for details.
     */
    static public List<Entitlement_Message__c> createEntitlements(List<CreateEntitlementRequest> reqs)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for(Integer i = 0; i < reqs.size(); i++)
        {
            CreateEntitlementRequest cer = reqs[i];
            String actionName = cer.isTrial ? 'Start Trial' : 'Buy Now';
            Entitlement_Message__c msg = createNewEntitlementMessage( cer.parentId, actionName );
            msgs.add( msg );
        }
        insert msgs;

        return msgs;
    }

    /**
     * @description Creates a single entitlement from an subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       parentId an id of the subscription master for which the entitlement should be created (enabled).
     * @param       isTrial determines if the entitlement is full (active) or trial.
     */
    static public void createEntitlement(final Id parentId, final Boolean isTrial)
    {
        createEntitlements( new List<CreateEntitlementRequest>{ new CreateEntitlementRequest( parentId, isTrial ) } );
    }

    /**
     * @description Blocks entitlements for given subscription masters.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       mapSubsMasterId_BlockedReason is a map where a key is a subscription master whose entitlement should be blocked
     *                                       and a value is a reason that entitlement is blocked.
     */
    static public List<Entitlement_Message__c> blockEntitlements(final Map<Id, String> mapSubsMasterId_BlockedReason)
    {
        Set<Id> subsMasterIds = mapSubsMasterId_BlockedReason.keySet();
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        List<Subscription_Master__c> blockedSubscriptions = new List<Subscription_Master__c>();
        for( Id sId : subsMasterIds )
        {
            blockedSubscriptions.add( new Subscription_Master__c( Id = sId, Is_Blocked__c = true ) );
            Entitlement_Message__c entMsg = createNewEntitlementMessage( sId, 'Block Entitlement' );
            entMsg.Param_Custom_Payment_Failure_Message__c = mapSubsMasterId_BlockedReason.get( sId );
            if (String.isNotBlank(entMsg.Param_Custom_Payment_Failure_Message__c))
                entMsg.Param_Custom_Payment_Failure_Message__c = entMsg.Param_Custom_Payment_Failure_Message__c.replaceAll('[^A-Za-z0-9._$\\\\\\-+!*() ]', '*');
            msgs.add( entMsg );
        }
        update blockedSubscriptions;
        insert msgs;
        
        return msgs;
    }

    /**
     * @description Blocks a single entitlement on a given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       parentId is an id of the subscription master whose entitlement will be blocked.
     * @param       blockedReason is the reason the entitlement is blocked.
     */
    static public void blockEntitlement(final Id parentId, final String blockedReason)
    {
        blockEntitlements( new Map<Id, String>{ parentId => blockedReason } );
    }

    /**
     * @description Unblocks entitlements on given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterIds is a list of subscription master ids to unblock.
     */
    static public List<Entitlement_Message__c> unblockEntitlements(final List<Id> subsMasterIds)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        List<Subscription_Master__c> unblockedSubs = new List<Subscription_Master__c>();
        for( Id sId : subsMasterIds )
        {
            unblockedSubs.add( new Subscription_Master__c( Id = sId, Is_Blocked__c = false ) );
            msgs.add( createNewEntitlementMessage( sId, 'Unblock Entitlement' ) );
        }
        update unblockedSubs;
        insert msgs;
        
        return msgs;
    }

    /**
     * @description Unblocks a single entitlement on a given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterId is an id of the subscription master that should be unblocked.
     */
    static public void unblockEntitlement(final Id subsMasterId)
    {
        unblockEntitlements( new List<Id>{ subsMasterId } );
    }

    /**
     * @description Cancels entitlements for given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterIds is a list of subscription master ids whose entitlements should be cancelled.
     */
    static public List<Entitlement_Message__c> cancelEntitlements(final List<Id> subsMasterIds)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        List<Subscription_Master__c> cancelledSubs = new List<Subscription_Master__c>();
        for( Id sId : subsMasterIds )
        {
            cancelledSubs.add( new Subscription_Master__c( Id = sId, Is_Cancelled__c = true ) );
            msgs.add( createNewEntitlementMessage( sId, 'Cancel Subscription' ) );
        }
        update cancelledSubs;
        insert msgs;
        
        return msgs;
    }

    /**
     * @description Cancels a single entitlement for a given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterId is a subscription master id whose entitlement should be cancelled.
     */
    static public void cancelEntitlement(final Id subsMasterId)
    {
        cancelEntitlements( new List<Id>{ subsMasterId } );
    }

    /**
     * @description Upgrades entitlements for given subscription masters.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterIds is a list of subscription master ids whose entitlement should be upgraded.
     */
    static public List<Entitlement_Message__c> upgradeEntitlements(final List<Id> subsMasterIds)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        
        Map<Id, Subscription_Master__c> mapUpgradedSubsMasters = new Map<Id, Subscription_Master__c>( [SELECT Id, Product_Tier__r.UpgradeToProductTier__r.ZProduct__c, Product__c, ZProduct__r.Upgrade_To__c, Product_Tier__r.UpgradeToProductTier__r.Product__c, Product_Tier__c, Product_Tier__r.UpgradeToProductTier__c, Product_Tier_Rate_Plan__c, Is_ZProduct_Upgradeable__c, Product_Tier_Rate_Plan__r.UpgradeToProductTierRatePlan__r.Product_Tier__c, Product_Tier_Rate_Plan__r.UpgradeToProductTierRatePlan__c, Status__c FROM Subscription_Master__c WHERE Id IN :subsMasterIds] );
        List<Subscription_Master__c> upgradeableSubsMasters = new List<Subscription_Master__c>();
        for( Id sId : subsMasterIds )
        {
            Subscription_Master__c subsMaster = mapUpgradedSubsMasters.get( sId );
            if( subsMaster.Is_ZProduct_Upgradeable__c )
            {
                
                subsMaster.Product_Upgraded_From__c = subsMaster.Product__c;
                subsMaster.ZProduct_Upgraded_From__c = subsMaster.ZProduct__c; // For backward compatability
                subsMaster.ZProduct__c = subsMaster.Product_Tier__r.UpgradeToProductTier__r.ZProduct__c;
                subsMaster.Product__c = subsMaster.Product_Tier__r.UpgradeToProductTier__r.Product__c; // For backward compatability
                subsMaster.Product_Tier_Upgraded_From__c = subsMaster.Product_Tier__c;
                subsMaster.Product_Tier_Rate_Plan_Upgraded_From__c = subsMaster.Product_Tier_Rate_Plan__c;
                subsMaster.Product_Tier__c = subsMaster.Product_Tier__r.UpgradeToProductTier__c;
                subsMaster.Product_Tier_Rate_Plan__c = subsMaster.Product_Tier_Rate_Plan__r.UpgradeToProductTierRatePlan__c;
                subsMaster.Is_Upgraded__c = true;
                upgradeableSubsMasters.add( subsMaster );
                
                System.debug('subsMaster.Status__c='+subsMaster.Status__c);
                if (subsMaster.Status__c == Constants.ASSET_STATUS_TRIAL)
                    msgs.add( createNewEntitlementMessage( sId, 'Add Trial Product' ) );
                else
                    msgs.add( createNewEntitlementMessage( sId, 'Add Entitlement Product' ) );

                msgs.add( createNewEntitlementMessage( sId, 'Delete Entitlement Product' ) );
            }
        }
        update upgradeableSubsMasters;
        insert msgs;
        
        return msgs;
    }

    /**
     * @description Upgrades a single entitlement for a given subscription master.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterId is a subscription master id whose entitlement should be upgraded.
     */
    static public void upgradeEntitlement(final Id subsMasterId)
    {
        upgradeEntitlements( new List<Id>{ subsMasterId });
    }


    /**
     * @description Converts a trial entitlement into a full (active) entitlement.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       subsMasterIds is an list of subscription master ids whose entitlements should be converted.
     */
    static public List<Entitlement_Message__c> convertTrialEntitlements(final List<Id> subsMasterIds)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        
        for( Id sId : subsMasterIds )
        {
            msgs.add( createNewEntitlementMessage( sId, 'Add Entitlement Product With Dates' ) );
            msgs.add( createNewEntitlementMessage( sId, 'Delete Trial Feature' ) );
        }
        insert msgs;

        return msgs;
    }

    /**
     * @description Converts a trial entitlement into a full (active) entitlement.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       parentId is a subscription master id whose entitlement should be converted.
     */
    static public void convertTrialEntitlement(final Id parentId)
    {
        convertTrialEntitlements( new List<Id>{ parentId } );
    }

    /**
     * @description Activates cancelled entitlements.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-07-05
     * @param       subsMasterIds is an list of subscription master ids whose entitlements should be reactivated.
     */
    static public List<Entitlement_Message__c> reactivateEntitlements(final List<Id> subsMasterIds)
    {
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        
        for( Id sId : subsMasterIds )
        {
            subsMasters.add( new Subscription_Master__c( Id = sId, Is_Cancelled__c = false, End_Date__c = Date.newInstance( 2099, 12, 31) ) );
            msgs.add( createNewEntitlementMessage( sId, 'Add Entitlement Product With Dates' ) );
        }
        insert msgs;
        update subsMasters;

        return msgs;
    }

    /**
     * @description Activates cancelled entitlement.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-07-05
     * @param       parentId is a subscription master id whose entitlement should be reactivated.
     */
    static public void reactivateEntitlement(final Id parentId)
    {
        reactivateEntitlements( new List<Id>{ parentId } );
    }

    /////////////
    // Helpers //
    /////////////

    /**
     * @description creates new entitlement message.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-13
     * @param       parentId is an subscription master id for which the entitlement should be created.
     * @param       actionName is a name of the entitlement message definition that should be applied to the entitlement message.
     * @return      a new entitlememt message.
     */
    static private Entitlement_Message__c createNewEntitlementMessage(Id parentId, String actionName)
    {
        return new Entitlement_Message__c( Subscription_Master__c = parentId
                                        , Entitlement_Message_Definition__r = new Entitlement_Message_Definition__c( Action_Name__c = Test.isRunningTest() ? 'Test' : actionName )
                                        , Status__c = 'New');
    }
}