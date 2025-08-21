global class TetrisProvisionRequestModel {
    
    global TetrisProvisionRequestModel() {}
    
    global String transactionType {get; set;}
    global String accountId {get; set;}
    global String contactId {get; set;}
    global String cartId {get; set;}
    global String userIdentityId {get; set;}
    global String userEMail {get; set;}
    global String effectiveDate {get; set;}
    
    global List<TetrisCartItemModel> products {get; set;}
    
}