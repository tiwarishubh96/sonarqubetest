global class TetrisSubscriptionItemModel  extends TetrisBaseModel {
    
    global String subscriptionId {get; set;}
    global String accountId {get; set;}
    global String bundleProductSKU {get; set;}
    global String bundleProductDescription {get; set;}
    global String billingProductId {get; set;}
    global String currencyISOCode {get; set;}
    global Boolean isTrial {get; set;}
    global Decimal recurringPrice {get; set;}
    global String slcsSubscriptionId {get; set;}
    global String slcsSubscriptionGroupId {get; set;}
    global String slcsClientReferenceNumber {get; set;}
    global String subscriptionTermType {get; set;}
    global String storefront {get; set;}
    global DateTime subscriptionStartDate {get; set;}
    global Date subscriptionEndDate {get; set;}
    global String subscriptionStatus {get; set;}
    global String subscriptionEvent {get; set;}
    global String subscriptionItemId {get; set;}
    global String productId {get; set;}
    global String sku {get; set;}
    global String productShortDescription {get; set;}
    global String productName {get; set;}
    global String productLongDescription {get; set;}
    global String tierDescription {get; set;}
    
}