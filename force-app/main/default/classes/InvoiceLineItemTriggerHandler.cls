/**
 * @description Handles Invoice_Line_Item__c DML Events.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
public with sharing class InvoiceLineItemTriggerHandler
{
    ////////////////
    // DML Events //
    ////////////////

    static public void afterInsert()
    {
        blockEntitlements();
    }

    //////////////
    // Handlers //
    //////////////

    /**
     * @description Blocks related entitlements.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     */
    static private void blockEntitlements()
    {
        Set<Id> invoiceIds = GenericUtilities.convertToParentMap( Trigger.new, String.valueOf( Invoice_Line_Item__c.Invoice__c ) ).keySet();
        Map<Id, Zuora__ZInvoice__c> mapInvoices = new Map<Id, Zuora__ZInvoice__c>([SELECT Id, Zuora__Account__c FROM Zuora__ZInvoice__c WHERE Id IN :invoiceIds]);
        Set<Id> invoiceAccountIds = GenericUtilities.convertToParentMap( mapInvoices.values(), String.valueOf( Zuora__ZInvoice__c.Zuora__Account__c ) ).keySet();
        Set<Id> zproductIds = GenericUtilities.convertToParentMap( Trigger.new, String.valueOf( Invoice_Line_Item__c.Product__c ) ).keySet();
        
        List<Subscription_Master__c> subsMasters = [SELECT Id, Account__c, Product__c FROM Subscription_Master__c WHERE Account__c IN :invoiceAccountIds AND Product__c IN :zproductIds];
        // subscription masters found - but we need to filter them based on the componsite key accountId - productId as the query might have returned invalid items
        Map<String, List<Subscription_Master__c>> mapAccZProd_SubsMaster = new Map<String, List<Subscription_Master__c>>();
        for( Subscription_Master__c subsMaster : subsMasters )
        {
            String accZProdKey = subsMaster.Account__c + ':' + subsMaster.Product__c;
            List<Subscription_Master__c> groupedSubsMasters = mapAccZProd_SubsMaster.get( accZProdKey );
            if( groupedSubsMasters == null )
            {
                groupedSubsMasters = new List<Subscription_Master__c>();
                mapAccZProd_SubsMaster.put( accZProdKey, groupedSubsMasters );
            }
            groupedSubsMasters.add( subsMaster );
        }

        Map<Id, String> mapBlockedSubsMasterId_Reason = new Map<Id, String>();
        for( Invoice_Line_Item__c item : (List<Invoice_Line_Item__c>)Trigger.new )
        {
            Zuora__ZInvoice__c invoice = mapInvoices.get( item.Invoice__c );
            Id accId = invoice.Zuora__Account__c;
            String accZProdKey = accId + ':' + item.Product__c;
            List<Subscription_Master__c> blockedSubsMasters = mapAccZProd_SubsMaster.get( accZProdKey );
            if( blockedSubsMasters == null ) continue;
            for(Subscription_Master__c subsMaster : blockedSubsMasters)
            {
                mapBlockedSubsMasterId_Reason.put( subsMaster.Id, item.Gateway_Response__c );
            }
        }

        EntitlementEngine.blockEntitlements( mapBlockedSubsMasterId_Reason );
    }
}