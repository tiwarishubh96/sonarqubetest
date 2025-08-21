/**
 * @description Handles Subscription Master DML Events invoked by SubscriptionMasterTrigger.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
public with sharing class SubscriptionMasterTriggerHandler
{
    ////////////
    // Events //
    ////////////

    static public void beforeInsert()
    {
        
    }

    static public void afterInsert()
    {
        createEntitlements( false );
    }

    static public void beforeUpdate()
    {
        collectCancelledEntitlements();
        collectUpgradedEntitlements();
        collectReactivatedEntitlements();
    }

    static public void afterUpdate()
    {
        createEntitlements( true );
        processCancelledEntitlements();
        processUpgradedEntitlements();
        processConvertedEntitlements();
        processReactivatedEntitlements();
    }

    ///////////////
    // Processes //
    ///////////////
    
    @TestVisible static private final String SUBSCRIPTION_MASTER_STATUS_TRIAL = 'Trial';
    @TestVisible static private final String SUBSCRIPTION_MASTER_STATUS_BUYNOW = 'Active';

    /**
     * @description Invokes entitlement engine that creates new entitlements based on subscription master status.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-07
     * @param checkPrevStatusValue determines if previous value of status flag should be checked before passing subscription masters to 
     *                             entitlement engine. Only subscription masters with changed status should be passed.
     */
    static private void createEntitlements(Boolean checkPrevStatusValue)
    {
        Set<String> entitlementStatuses = new Set<String>{ SUBSCRIPTION_MASTER_STATUS_TRIAL.toUpperCase(), SUBSCRIPTION_MASTER_STATUS_BUYNOW.toUpperCase() };

        List<EntitlementEngine.CreateEntitlementRequest> reqs = new List<EntitlementEngine.CreateEntitlementRequest>();

        for( Integer i = 0; i < Trigger.new.size(); i++ )
        {
            Subscription_Master__c newSubsMaster = (Subscription_Master__c)Trigger.new[i];
            // new process to avoid trigger
            if (! newSubsMaster.EnableInsertTrigger__c) continue;
            
            Boolean isStatusChanged = true;
            if( checkPrevStatusValue )
            {
                Subscription_Master__c oldSubsMaster = (Subscription_Master__c)Trigger.old[i];
                isStatusChanged = newSubsMaster.Status__c != oldSubsMaster.Status__c && !( newSubsMaster.Status__c == SUBSCRIPTION_MASTER_STATUS_BUYNOW && oldSubsMaster.Status__c == SUBSCRIPTION_MASTER_STATUS_TRIAL );
            }

            if( isStatusChanged && String.isNotBlank( newSubsMaster.Status__c ) && entitlementStatuses.contains( newSubsMaster.Status__c.toUpperCase() ) )
            {
                reqs.add( new EntitlementEngine.CreateEntitlementRequest( newSubsMaster.Id, newSubsMaster.Status__c ==  SUBSCRIPTION_MASTER_STATUS_TRIAL ) );
            }
        }

        EntitlementEngine.createEntitlements( reqs );
    }

    // subscription masters that should be submitted for cancellation
    static private List<Subscription_Master__c> cancelledSubsMasters;

    /**
     * @description Determines what subscription masters should be submitted for cancellation.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-09
     */
    static private void collectCancelledEntitlements()
    {
        cancelledSubsMasters = new List<Subscription_Master__c>();
        for( Subscription_Master__c subMaster : (List<Subscription_Master__c>)Trigger.new )
        {
            if( subMaster.Submit_For_Cancellation__c )
            {
                cancelledSubsMasters.add( subMaster );
                subMaster.Submit_For_Cancellation__c = false;
            }
        }
    }

    /**
     * @description Submits related subscription masters to the entitlement engine
     *              when they are cancelled.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     */
    static private void processCancelledEntitlements()
    {
        EntitlementEngine.cancelEntitlements( new List<Id>( new Map<Id, Subscription_Master__c>( cancelledSubsMasters ).keySet() ) );
    }


    // subscription masters that should be submitted for upgrade
    static private List<Subscription_Master__c> upgradedSubsMasters;

    /**
     * @description Determines what subscription masters should be submitted for upgrade.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-09
     */
    static private void collectUpgradedEntitlements()
    {
        upgradedSubsMasters = new List<Subscription_Master__c>();
        for( Subscription_Master__c newSubsMaster : (List<Subscription_Master__c>)Trigger.new )
        {
            if( newSubsMaster.Submit_For_Upgrade__c )
            {
                newSubsMaster.Submit_For_Upgrade__c = false;
                if( newSubsMaster.Is_ZProduct_Upgradeable__c )
                {
                    upgradedSubsMasters.add( newSubsMaster );
                }
            }
        }
        upgradedSubsMasters = [SELECT Id,Product_Tier__r.UpgradeToProductTier__r.Product_Tier_Code__c,Sage_API_Activity__r.PayNowToken__r.Name,Sage_API_Activity__r.ActivityType__c FROM Subscription_Master__c WHERE id IN: upgradedSubsMasters];
    }

    /**
     * @description Submits subscription masters to be upgraded by the entitlement engine.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     */
    static private void processUpgradedEntitlements()
    {
        if (upgradedSubsMasters.isEmpty()) return;
        updatePayNowPurchaseRequestCallout(JSON.serialize(upgradedSubsMasters));
        EntitlementEngine.upgradeEntitlements( new List<Id>( new Map<Id, Subscription_Master__c>( upgradedSubsMasters ).keySet() )  );
    }

    /**
     * @description Submits entitlement on subscription master to be converted from trial to active
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     */
    static private void processConvertedEntitlements()
    {
        List<Id> convertSubsMasterIds = new List<Id>();
        for( Integer i = 0; i < Trigger.new.size(); i++ )
        {
            Subscription_Master__c newSubsMaster = (Subscription_Master__c)Trigger.new[i];
            Subscription_Master__c oldSubsMaster = (Subscription_Master__c)Trigger.old[i];
            // new process to avoid trigger
            if (! newSubsMaster.EnableInsertTrigger__c) continue;

            if( newSubsMaster.Status__c == SUBSCRIPTION_MASTER_STATUS_BUYNOW && oldSubsMaster.Status__c == SUBSCRIPTION_MASTER_STATUS_TRIAL )
            {
                convertSubsMasterIds.add( newSubsMaster.Id );
            }
        }
        EntitlementEngine.convertTrialEntitlements( convertSubsMasterIds );
    }

    // subscription masters that should be submitted for reactivation
    static private List<Subscription_Master__c> reactivatedEntitlements;

    /**
     * @description Determines what subscription masters should be submitted for reactivation.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-07-05
     */
    static private void collectReactivatedEntitlements()
    {
        reactivatedEntitlements = new List<Subscription_Master__c>();
        for( Subscription_Master__c newSubsMaster : (List<Subscription_Master__c>)Trigger.new )
        {
            if( newSubsMaster.Submit_For_Reactivation__c )
            {
                newSubsMaster.Submit_For_Reactivation__c = false;
                if( newSubsMaster.Is_Cancelled__c )
                {
                    reactivatedEntitlements.add( newSubsMaster );
                }
                else
                {
                    newSubsMaster.addError('Cannot reactive non-cancelled entitlement.');
                }
            }
        }
    }

    /**
     * @description Submits subscription masters to be reactivated by the entitlement engine.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-07-05
     */
    static private void processReactivatedEntitlements()
    {
        EntitlementEngine.reactivateEntitlements( new List<Id>( new Map<Id, Subscription_Master__c>( reactivatedEntitlements ).keySet() )  );
    }

    /**
     * @description Callout to update PayNow purchase request for product upgrade
     * @author      Yong Kan
     * @date        2017-07-12
     */
    @Future(callout=true)
    private static void updatePayNowPurchaseRequestCallout(string serializedSubMasterList) {
        if (string.isBlank(serializedSubMasterList)) return;

        List<Subscription_Master__c> sms = (List<Subscription_Master__c>) JSON.deserialize(serializedSubMasterList, List<Subscription_Master__c>.class);
        if (sms.isEmpty()) return;

        PayNowSetting__c pnBaseUrl = PayNowSetting__c.getInstance('payNowBaseUrl');
        PayNowSetting__c pnUserName = PayNowSetting__c.getInstance('payNowServiceUserName');
        PayNowSetting__c pnPassword = PayNowSetting__c.getInstance('payNowServicePassword');
        string payNowBaseUrl = pnBaseUrl.Value__c;
        string userName = pnUserName.Value__c;
        string password = pnPassword.Value__c;
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        for (Subscription_Master__c sm : sms) {
            if (sm.Sage_API_Activity__r.ActivityType__c != SageApiActivityTriggerHandler.TryNowActivityType) continue;

            PurchaseRequestUpdatePayload payload = new PurchaseRequestUpdatePayload();
            payload.id = sm.Sage_API_Activity__r.PayNowToken__r.Name;
            payload.tierCode = sm.Product_Tier__r.UpgradeToProductTier__r.Product_Tier_Code__c;
            if (string.isBlank(payload.id) || string.isBlank(payload.tierCode)) continue;

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(payNowBaseUrl + '/api/PurchaseRequest/Update');
            req.setMethod('POST');
            req.setBody(JSON.serialize(payload));
            
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            System.debug('payLoad ' + payload);
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            Boolean success = false;
            Integer attempts = 0;
            Integer maxAttempts = 3;
            while (success == false && attempts < maxAttempts) {
                attempts++;
                try {
                    HttpResponse res = null;
                    if (Test.isRunningTest()) {
                        Http h = new Http();
                        res = h.send(req);
                    } else {
                        res = GenericUtilities.httpSend(req, SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
                    }

                    if (res.getStatusCode() == 200) success = true;
                    if (success == false && attempts == maxAttempts - 1) ExceptionHandler.CatchException('SubscriptionMasterTriggerHandler', 'updatePayNowPurchaseRequestCallout', new CustomException('Callout failed with status: ' + res.getStatusCode() + ', message: ' + res.getStatus()));
                } catch(Exception e) {
                    System.debug('~~~~Exception: ' + e);
                    ExceptionHandler.CatchException('SubscriptionMasterTriggerHandler', 'updatePayNowPurchaseRequestCallout', e);
                }
            }
        }
    }
    
    /**
     * @description Populates channel partner value of Subscription Master on Contact .
     * @author      Yue Lu <yeu.lu@sage.com>
     * @date        05-21-2018
     * @param		lstSubMaster is from Trigger.New of SubscriptionMasterTrigger
     */
    public static void updateChannelPartner(List<Subscription_Master__c> lstSubMaster){
        
        // Need to query the channel partner name which is not included in Trigger.New
        List<Subscription_Master__c> lstSubscriptionMaster = [SELECT ChannelPartner__r.name, Account__c FROM Subscription_Master__c WHERE Id IN:lstSubMaster];
        
        system.debug('lstSubscriptionMaster>>>'+lstSubscriptionMaster);
        
        Map<Id, String> mapAcctIDChannelPartner = new Map<Id,String>();
        
        for(Subscription_Master__c subMaster : lstSubscriptionMaster){
            
            if(subMaster.Account__c != NULL){
            	
                system.debug('subMaster.ChannelPartner__r.name>>>'+subMaster.ChannelPartner__r.name);
                
                mapAcctIDChannelPartner.put(subMaster.Account__c, subMaster.ChannelPartner__r.name);
            }
            
        }
        
        System.debug('mapAcctIDChannelPartner>>>'+ mapAcctIDChannelPartner);
            
        List<Account> lstAcct = [SELECT Id, (SELECT Id, AccountID,Channel_Partner__c FROM Contacts) FROM Account WHERE ID IN:mapAcctIDChannelPartner.keySet()];
        
        System.debug('lstAcct>>>'+lstAcct);
                
        if(lstAcct != NULL){
            
            List<Contact> lstCont = new List<Contact>();
            
            for(Account acct: lstAcct){
            	    
                for(Contact cont:acct.Contacts){
                    
                    cont.Channel_Partner__c = mapAcctIDChannelPartner.get(cont.AccountID);
                    
                    lstCont.add(cont);
                }
                
            }
            
            system.debug('lstCont>>>'+lstCont);
            
            try{

                //Excution Time Concern
                Database.update(lstCont,false);
                
                
            }Catch(Exception e){
                
                ExceptionHandler.CatchException('SubscriptionMasterTriggerHandler', 'updateChannelPartner', e);
            }
        } 
            
    }

    private class PurchaseRequestUpdatePayload {
        public string id;
        public string tierCode;
    }
}