global class TetrisProvisionResponseModel extends TetrisBaseModel {

    global String channelPlatform {get; set;}
    global Boolean isTrial {get; set;}
    global CustomObject entitledAccount {get; set;}
    global CustomObject customerContact {get; set;}
    global SubscriptionDateRange effectivePeriod {get; set;}
    global List<ProductInfo> products;
    global List<ProductUsersInfo> productUsers;
    global List<CustomerCommunityUsersInfo> customerCommunityUsers;
    global List<Map<String, String>> links;
    
    global class CustomObject {
        global String id {get; set;}
    }

    global class SubscriptionDateRange {
        global String notBefore {get; set;}
        global String notAfter {get; set;}
    }    

    global class ProductInfo {
        global String product {get; set;}
        global List<FeatureInfo> features {get; set;}
        
    }
    
    global class FeatureInfo {
         global String name {get; set;}
        global List<FeatureProperties> properties {get; set;}
    }
    
    global class FeatureProperties {
         global String name {get; set;}
         global String value {get; set;}
        
    }
        
    global class ProductUserInfo {
        global String product {get; set;}
        global String role {get; set;}
        
    }

    global class ProductUsersInfo {
        global IdentityInfo identity;
      global List<ProductUserInfo> products;
    }
    
    global class IdentityInfo {
        global String idp {get; set;}
        global String idpId {get; set;}        
    }
    
    global class CustomerCommunityUsersInfo {
        global String contactId {get; set;}
        global String role {get; set;}        
        global IdentityInfo identity;
    }    

    global String tetrisSubscriptionId {get; set;}    
}