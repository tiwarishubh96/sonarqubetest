/**
* @author Prasanti Avula, Docmation
* @creationDate August 12, 2017
*
* @description Wrapper Class with Cart Related info. This is used in TETRIS R2.
*
* Modification Log
* ------------------------------------------------------------------------------------------------------------
* 1.0 - August 12, 2017 - Prasanti Avula
*       Created the initial version of Wrapper Class.
* ------------------------------------------------------------------------------------------------------------
*/
global class TetrisCartModel extends TetrisBaseModel {
    global String cartId;
    global String sfId;
    global String storefront;
    
    global String cartNumber;
    global String transactionType;
    global String cartStatus;
    global String cartType;
    
    global String currencyCode;
    global String cartLocale;
    global String cartLocaleId;
    global String country;
    
    global Decimal totalAmount;
    global Decimal subTotalAmount;
    global Decimal adjustmentAmount;
    global String adjustmentReason;
    global Decimal taxAmount;
    global Decimal taxPercentage;
    
    global Boolean taxExemptFlag;
    global Decimal taxSubtotalAmount;
    global Decimal totalDiscount;
    global String vatNumber;
    global String taxCode;
    
    global String userIdentityId;
    global String accountId;
    global String contactId;
    global String leadId;
    global String billTo;
    global String opportunityId;
    global String zuoraSubscriptionId;
    global String zuoraSubscriptionNumber;
    global String productSubscriptionId;
    global String paymentMethodId;
    
    global String user;
    global String buyerEmail;
    global String productEntitlementId;
    global String slcsClientRef;
    global String slcsSubscriptionGroupId;
    global String slcsSubscriptionId;
    
    global String transactionReferenceNumber;
    global String subscriptionTermType;
    global List<TetrisCartItemModel> cartItems;

    //added for restoring cart\
    //
    global TetrisAccountModel account {get; set;}
    global TetrisContactModel contact {get; set;}
    
    //SAC product related attribute changes
    global String intouchLocalCRMRef;
    global String userLoginId;
    global Boolean purchaseCommit;
    global Boolean guidedSelling;
    global String accountManagerEMail;
    global String accountManagerName;
    global String accountManagerId;
    

}