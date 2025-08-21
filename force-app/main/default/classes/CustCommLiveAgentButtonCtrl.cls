public without sharing class CustCommLiveAgentButtonCtrl
{
    public class InitParams
    {
        @AuraEnabled public User curUser { get; set; }
        @AuraEnabled public String deploymentId { get; set; }
        @AuraEnabled public String buttonId { get; set; }
        @AuraEnabled public String orgId { get; set; }
        @AuraEnabled public String baseUrl { get; set; }
    }
    
    @AuraEnabled
    public static Boolean hasPermissionForProduct(String sageProduct) {
        Boolean manageSubscription=false;
        boolean value=false;
        Boolean result=CommunityUtilities.hasPermissionForProduct(sageProduct,manageSubscription);
        
  system.debug('Find activities :result '+ result);
        return result;
        
    }

    /* @description Retrieves component initialisation parameters. */
    @AuraEnabled
    public static InitParams getInitParams(String deploymentAPIName, String sageProduct)
    { 
        system.debug('Find :deploymentAPIName'+deploymentAPIName); 
        system.debug('Find :sageProduct'+sageProduct);
        String buttonAPIName;
        String userLanguage = UserInfo.getLanguage();
        String userLocale = UserInfo.getLocale();
        Id curUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, Name, ContactId, Contact.Account_Sales_Office__c, AccountId From User Where Id = :curUserId LIMIT 1];
        String salesOffice = currentUser.Contact.Account_Sales_Office__c;
        Boolean manageSubscription=false;
        Boolean result1=CommunityUtilities.hasPermissionForProduct(sageProduct,manageSubscription);
         system.debug('Find :result1'+result1);
        InitParams init  = new InitParams();
        if(result1== true){
            system.debug('Find : userLocale'+userLocale);
            system.debug('Find : salesOffice'+salesOffice);
            system.debug('Find : sageProduct'+sageProduct);
            list<Live_Chat_Mapping__mdt> buttonAPINamelist=[Select Button_API_Name__c from Live_Chat_Mapping__mdt where Locale__c =: userLocale and Salesoffice__c lIKE :('%'+salesOffice+'%') and Product__c lIKE :('%'+sageProduct+'%') LIMIT 1];
            
            for(Live_Chat_Mapping__mdt bt:buttonAPINamelist)
                buttonAPIName =bt.Button_API_Name__c;
            init=returnInitParams(buttonAPIName,currentUser,deploymentAPIName);            
        }
           system.debug('Find :init'+init);
        return init;
    }
    
    public static InitParams returnInitParams(String buttonAPIName, User currentUser,String deploymentAPIName){
    system.debug('Find :buttonAPIName'+buttonAPIName);
         system.debug('Find :currentUser'+currentUser);
         system.debug('Find :deploymentAPIName'+deploymentAPIName);
        InitParams init  = new InitParams();
        init.curUser = currentUser;
        if(!Test.isRunningTest()){
             system.debug('Find :init.deploymentId before' );
        init.deploymentId = [SELECT Id FROM LiveChatDeployment WHERE DeveloperName = :deploymentAPIName LIMIT 1].Id;
            system.debug('Find :init.deploymentId '+init.deploymentId );
        init.deploymentId = init.deploymentId.left(15);
        try{
            init.buttonId = [SELECT Id FROM LiveChatButton WHERE DeveloperName = :buttonAPIName LIMIT 1].Id;
              system.debug('Find :init.buttonId '+ init.buttonId);
        }
        catch(DMLException e){
            System.debug('Live Chat Button doesn\'t exist'+ e.getMessage());
        }
        
        init.buttonId = init.buttonId.left(15);
       
      
        }
         init.orgId = UserInfo.getOrganizationId();
          init.orgId = init.orgId.left(15);
        init.baseUrl = Site.getBaseCustomUrl().removeEnd('/s'); // + Site.getPathPrefix().removeEnd('/s');
        system.debug('init :'+init);
        
        return init;
        
    }
    
    /* Check if the current user is authenticated or not*/
    @AuraEnabled
    public static boolean isAuthenticatedUser() {
        // Call the method hasPermision to determine if the current user has the UNAUTHENTICATED_USER permission Assigned
        // If it does, it means it's a guest user and therefore NOT authenticated
        return !CommunityUtilities.hasPermission(Constants.UNAUTHENTICATED_USER);
    }
}