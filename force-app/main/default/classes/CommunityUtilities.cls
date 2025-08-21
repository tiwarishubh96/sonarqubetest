/*Set of generic utilities used by the Customer and Partner communities*/
public without sharing class CommunityUtilities {
    
    @AuraEnabled
    public static Boolean hasPermissionForSuccessPlans() {
        system.debug('in hasPermissionForSuccessPlans');
        /*Check for Sage One Customer*/
        String product_name;
        Boolean sage_live_check = false;
        Id usrId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:usrId];
        List<Account> foundationAccounts = [Select Id, Name from Account where Id = :u.AccountId and Foundation_Customer__c = 'Approved'];
        system.debug('foundationAccounts = '+foundationAccounts);
        //adding org status check for licenses to get licenses of related account with org status='Active'
        List<sfLma__License__c> lstValidLicense = [Select id from sfLma__License__c where sfLma__Account__c=:u.AccountId  AND sfLma__License_Status__c='Active' AND sfLma__Org_Status__c='Active' AND (sfLma__Package__r.Name like '%Live%' OR sfLma__Package__r.Name like '%Financials%') AND sfLma__Account__c!=null];        
        if (foundationAccounts.size() > 0) {
            sage_live_check = true;
        }/*adding check for licenses as it is replacing subscription master for sage live customers*/        
        else if(lstValidLicense.size()>0) {
            sage_live_check = true;
        }/*check for license end*/
        /*
        else {
            List<Zuora__SubscriptionProductCharge__c> zproduct = [SELECT Id,Zuora__ProductName__c FROM Zuora__SubscriptionProductCharge__c where Zuora__Account__c = :u.AccountId];
            for (Zuora__SubscriptionProductCharge__c zsp:zproduct) {
                product_name = zsp.Zuora__ProductName__c;
                if (product_name.containsIgnoreCase('Live')|| product_name.containsIgnoreCase('Financials')) {
                    sage_live_check = true;
                    break;
                }
            }
        }*/
        /*End of check*/    
        return sage_live_check;
    }
    
    @AuraEnabled
    public static Boolean hasPermissionForProduct(String sageProduct, Boolean manageSubscription) {
        
        system.debug('###sageprd'+sageProduct);
        system.debug('###managesubs'+manageSubscription);
        Boolean sage_live_check=false;
        String product_name;
        Boolean result;
        Id usrId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:usrId];
        List<Account> foundationAccounts = [Select Id, Name from Account where Id = :u.AccountId and Foundation_Customer__c = 'Approved'];
        List<Subscription_Master__c> activities = [SELECT Id,product__c,ZProduct__c,ChannelPartner__r.ChannelPlatform__r.Name FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND  Account__c != '' and  (Status__c = 'Trial' or Status__c = 'Active' or (ChannelPartner__r.ChannelPlatform__r.Name = 'AppDirect' and Is_Blocked__c = false and Is_Cancelled__c = false)) and SubscriptionState__c = ''];
        List<Subscription_Master__c> newUserActivities = new List<Subscription_Master__c>();
        for(Subscription_Master__c submaster : [SELECT Id,Product__c,ZProduct__c,ChannelPartner__r.ChannelPlatform__r.Name, (Select Id, Name from Entitled_Products__r) FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Account__c != '' AND End_Date__c >= :System.Today() AND SubscriptionState__c = 'Active']){
            system.debug('submaster: '+submaster);
            system.debug('sub: '+submaster.Entitled_Products__r);
            if(!submaster.Entitled_Products__r.isEmpty()){
                for(EntitlementProduct__c product : submaster.Entitled_Products__r){
                    if(product != null && product.Name != null && product.Name.containsIgnoreCase('Accounting')){
                        newUserActivities.add(submaster);
                    }
                }
            }
        }
        system.debug('Find activities :'+newUserActivities);
        //adding check for License
        //adding org status check for licenses to get licenses of related account with org status='Active'
        List<sfLma__License__c> lstValidLicense = [Select id from sfLma__License__c where sfLma__Account__c=:u.AccountId  AND sfLma__License_Status__c='Active' AND sfLma__Org_Status__c='Active' AND (sfLma__Package__r.Name like '%Live%' OR sfLma__Package__r.Name like '%Financials%') AND sfLma__Account__c!=null];
        System.debug(LOGGINGLEVEL.INFO,'--lstValidLicense--'+lstValidLicense);
        if(foundationAccounts.size() > 0) {
            if (sageProduct.containsIgnoreCase('Live') || sageProduct.containsIgnoreCase('Financials')) {
                sage_live_check = true;
            }
            return sage_Live_check;
        }
        /*adding check for licenses as it is replacing subscription master for sage live customers*/
        
        else if(lstValidLicense.size()>0) {
            if (sageProduct.containsIgnoreCase('Live') || sageProduct.containsIgnoreCase('Financials')) {
                sage_live_check = true;
            }
            system.debug('####1'+sage_Live_check);
            return sage_Live_check;
        }/*check for license end*/
        else if (activities.size() > 0 || newUserActivities.size() > 0) {
            List<Subscription_Master__c> userActivities = new List<Subscription_Master__c>();
            if(activities.size() > 0){
                userActivities = activities;
                system.debug('$$$$inside if');
            }
            else {
                userActivities = newUserActivities;
                system.debug('$$$$inside else');
            }
            system.debug('newActivities: '+newUserActivities);
            result=checkSubscriptionMaster(u,sageProduct,userActivities,manageSubscription); 
            
            system.debug('####2'+result);
            return result;
        } 
        else if(activities.isEmpty()) 
        {
            
            result= checkSubscriptionProductCharge(u,sageProduct); 
            system.debug('####3'+result);
            return result;
            
        }
        system.debug('####4'+result);
        return result;
        
    }
    public static Boolean checkSubscriptionMaster(user u,String sageProduct,list<Subscription_Master__c> activities,Boolean manageSubscription) {
        
        Boolean sage_one_try_now=false;
        Boolean sage_live_try_now=false;
        String product_name;
        boolean isAppDirect = false; 
        system.debug('@@@@Outside CSM' +u);
        system.debug('@@@@Outside CSM' +sageProduct);
        system.debug('@@@@Outside CSM' +activities[0].Product__c);
        system.debug('@@@@Outside CSM' +manageSubscription);
        for(Subscription_Master__c sm:activities) {
            system.debug('@@@@Inside CSM');
            List<Product2> zp = [select Id,Name from Product2 where Id=:sm.Product__c];
            List<zqu__ZProduct__c> zproduct = [select Id,Name from zqu__ZProduct__c where Id=:sm.ZProduct__c];
            system.debug('Find activities :zp '+ zp);
            if((zp!=null && zp.size()>0) || (zproduct!=null && zproduct.size()>0)){
                if(zp!=null && zp.size()>0) {
                    product_name = zp[0].Name;
                    system.debug('@@@@1'+product_name);
                }
                else if(zproduct!=null && zproduct.size()>0 ) {
                    product_name = zproduct[0].Name;
                    system.debug('@@@@2'+product_name);
                }    
                
                system.debug('Find activities :product_name '+ product_name);
                if (sm.ChannelPartner__r.ChannelPlatform__r.Name == 'AppDirect') {
                    isAppDirect = true;
                    system.debug('@@@@3'+isAppDirect);
                }
                
                if((product_name.containsIgnoreCase('One') && sageProduct.containsIgnoreCase('One')) || (product_name.containsIgnoreCase('Accounting') && sageProduct.containsIgnoreCase('Accounting'))) {
                    sage_one_try_now = true;
                    system.debug('@@@@4'+sage_one_try_now);
                }
                
                /*
                if((product_name.containsIgnoreCase('Live') && sageProduct.containsIgnoreCase('Live'))||(product_name.containsIgnoreCase('Financials') && sageProduct.containsIgnoreCase('Financials'))) {
                sage_live_try_now = true;
                }*/
            }
            else if (!sm.Entitled_Products__r.isEmpty()){
                sage_one_try_now = true;
            }
        }
        
        if (isAppDirect && manageSubscription) {
            sage_one_try_now = false;
            sage_live_try_now = false;
        }
        system.debug('Find activities :sage_one_try_now '+ sage_one_try_now);
        if(sage_one_try_now==true)
            return sage_one_try_now;
        else if(sage_live_try_now==true)
            return sage_live_try_now;
        else
            return false;
    }
    public static Boolean checkSubscriptionProductCharge(user u,String sageProduct) {
        String product_name;
        
        
        Boolean sage_one_try_now=false;
        Boolean sage_live_try_now=false;
        
        List<Zuora__SubscriptionProductCharge__c> zproduct = [SELECT Id,Zuora__ProductName__c FROM Zuora__SubscriptionProductCharge__c where Zuora__Account__c=:u.AccountId];
        for(Zuora__SubscriptionProductCharge__c zsp:zproduct) {
            product_name = zsp.Zuora__ProductName__c; 
            if((product_name.containsIgnoreCase('One') && sageProduct.containsIgnoreCase('One')) || (product_name.containsIgnoreCase('Accounting') && sageProduct.containsIgnoreCase('Accounting'))) {
                sage_one_try_now = true;
            }
            /*
if((product_name.containsIgnoreCase('Live') && sageProduct.containsIgnoreCase('Live'))|| (product_name.containsIgnoreCase('Financials') && sageProduct.containsIgnoreCase('Financials'))) {
sage_live_try_now= true;
}*/
        }
        
        
        if(sage_one_try_now==true)
            return sage_one_try_now;
        else if(sage_live_try_now==true)
            return sage_live_try_now;
        else
            return false;
    }
    
    
    
    
    
    /*Generic method to create a case from the community and associate it with the contact and account*/
    @AuraEnabled
    public static void createCase(String type, String reason) {
        try {
            
            Map<String, Object> flowParams = new Map<String, Object>{
                'actionType' => type, 'reason' => reason
                    };
                        Flow.Interview.Customer_Community_Case_Creation_for_Change_of_Subscription createCaseFlow = new Flow.Interview.Customer_Community_Case_Creation_for_Change_of_Subscription(flowParams);
            createCaseFlow.start();
            if(Test.isRunningTest()) TestExc.subscribe(CommunityUtilities.class, 'error');
        } catch (Exception ex){
            System.debug( LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString() );
            throw ex;
        }
    }
    
    /* Retrieves open subscription management cases*/
    @AuraEnabled
    public static List<Case> getSubscriptionManagementOpenCases()
    {
        Flow.Interview.Customer_Community_Find_Open_Subscription_Management_Cases findCasesFlow = new Flow.Interview.Customer_Community_Find_Open_Subscription_Management_Cases(new Map<String,Object>());
        findCasesFlow.start();
        
        Object result = findCasesFlow.getVariableValue('SMOpenCases');
        
        return result == null ? new List<Case>() : (List<Case>)result;
    }
    @AuraEnabled
    public static boolean hasPermissionSet(String name) {
        
        List<PermissionSetAssignment> permissionAssignment =
            [SELECT Id
             FROM PermissionSetAssignment
             WHERE PermissionSet.label like :name
             AND assigneeId = :UserInfo.getUserId()];
        
        if (permissionAssignment.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    
    /*Generic method to check if the logged in user has permission*/
    @AuraEnabled
    public static boolean hasPermission(String name) {
        
        List<CustomPermission> customPermissions =
            [SELECT Id, DeveloperName
             FROM CustomPermission
             WHERE DeveloperName = :name];
        if (customPermissions.size() > 0) {
            
            List<Id> customPermissionSetIds = new List<Id>();
            for (CustomPermission p : customPermissions) {
                customPermissionSetIds.add(p.Id);
            }
            List<SetupEntityAccess> setupEntities =
                [SELECT SetupEntityId
                 FROM SetupEntityAccess
                 WHERE SetupEntityId in :customPermissionSetIds AND
                 ParentId IN (SELECT PermissionSetId
                              FROM PermissionSetAssignment
                              WHERE AssigneeId = :UserInfo.getUserId())];
            
            if (setupEntities.size() > 0) {
                return true;
                
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    
    /*Generic method to get the picklist values of a particular field*/
    @AuraEnabled
    public static List<String> getPicklistValues(String objectAPIName, String fieldAPIName){
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult describe = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
        for(Schema.PicklistEntry picklistEntry : describe.getPicklistValues()){
            picklistValues.add(picklistEntry.getLabel());
        }
        return picklistValues;
    }
    
    
    /*Method to get the list of communities that a user has access to */ 
    @AuraEnabled
    public static List<CommunitiesAvailable> getCommunities(){
        String serverInstance = URL.getSalesforceBaseUrl().toExternalForm();
        serverInstance = '/servlet/networks/switch?networkId=';
        List<CommunitiesAvailable> communities = new List<CommunitiesAvailable>();
        // First check if the current user is authenticated
        if (!hasPermission(Constants.UNAUTHENTICATED_USER)){
            ConnectApi.CommunityPage commPage = ConnectApi.Communities.getCommunities(ConnectApi.CommunityStatus.Live);
            // Iterate over the available communities
            for(ConnectApi.Community commItem : commPage.communities){
                CommunitiesAvailable c = new CommunitiesAvailable();
                c.name = commItem.name;
                c.switchUrl = commItem.siteUrl;
                communities.add(c);
            }
        }
        return communities;
    }
    
    /*Wrapper class to list the communities a user has acccess to */
    public class CommunitiesAvailable {
        @AuraEnabled public String name;
        @AuraEnabled public String switchUrl;
    }
    
    /*Wrapper class to to check what should be displayed in the Payment button*/
    public class PaymentButtonAvailable {
        @AuraEnabled public Boolean hasBillingAccount = false;
        @AuraEnabled public String payNowURL;
    } 
    
    @AuraEnabled
    public static PaymentButtonAvailable paymentButtonAvailabilityChecks() {
        PaymentButtonAvailable result = new PaymentButtonAvailable();
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        if (users.size() > 0) {
            if (users[0].Contact != null) {
                if (users[0].Contact.AccountId != null) { 
                    Boolean sage_one_check;
                    
                    Id usrId = UserInfo.getUserId();
                    User u = [select Id,Name,AccountId from User where Id=:usrId];
                    
                    /* sage one check*/
                    sage_one_check=checkProduct(u.AccountId);
                    /*Billing Account check*/
                    result=checkSageApiActivity(users[0].Contact.AccountId,sage_one_check, result);           
                    
                }
            }
        }        
        return result;
    }
    
    public static PaymentButtonAvailable checkSageApiActivity( Id AccountId,Boolean sage_one_check,PaymentButtonAvailable result) {
        
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id,Name FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :AccountId];
        if (billingAccounts.size() > 0 && sage_one_check == true) {
            result.hasBillingAccount = true;
        } 
        else 
        {
            // If billing account is not found then search for Sage API Activity
            List<SageApiActivity__c> activities = [SELECT Id, PaymentUrl__c, SubscriptionMaster__r.Status__c FROM SageApiActivity__c 
                                                   WHERE Account__c = :AccountId AND ActivityStatus__c = 'Success' 
                                                   and (ActivityType__c = 'TryNow' or ActivityType__c = :SageApiActivityTriggerHandler.TetrisStartTrialActivityType)];
            if (activities.size() > 0) {
                if (activities[0].SubscriptionMaster__r.Status__c != 'Active' && activities[0].PaymentUrl__c != null) {
                    result.payNowURL = activities[0].PaymentUrl__c;        
                }
            }
        }
        return result;
        
    }
    
    public static Boolean checkProduct( Id AccountId) {  
        String product_name = '';
        String product_Category = '';
        String product_family = '';
        Boolean sage_one_check;
        List<Zuora__SubscriptionProductCharge__c> zproduct = [SELECT Id,Zuora__ProductName__c FROM Zuora__SubscriptionProductCharge__c where Zuora__Account__c=:AccountId];
        for(Zuora__SubscriptionProductCharge__c zsp:zproduct) {
            product_name = zsp.Zuora__ProductName__c;
            if(product_name.containsIgnoreCase('One') || product_name.containsIgnoreCase('Accounting')) {
                sage_one_check = true; 
            }
        }
        return sage_one_check;
    }
    
    
    @AuraEnabled    
    public static String getSuccessPlanLabel() {    
        string componentTitle = Label.Customer_Community_Success_Plans_Label;    
        return componentTitle;    
    }    
    @AuraEnabled    
    public static String getManageCasesLabel() {    
        string componentTitle = Label.Customer_Community_Manage_Cases_Label;    
        return componentTitle;    
    }    
    
    @AuraEnabled    
    public static String getManageSubscriptionLabel() {    
        string componentTitle = Label.Customer_Community_Manage_Subscription_Label;    
        return componentTitle;    
    }
    @AuraEnabled
    public static boolean canCancelSubscription() {
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        if (users.size() > 0) {
            if (users[0].Contact != null) {
                if (users[0].Contact.AccountId != null) {
                    
                    DateTime d = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day());
                    
                    List<Subscription_Master__c> sms = [SELECT Id FROM Subscription_Master__c WHERE Account__c = :users[0].Contact.AccountId AND Status__c = 'Active' AND End_Date__c >= :d AND ChannelPartner__r.ChannelPlatform__r.Name != 'AppDirect'];
                    if (sms.size() > 0) {
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
    //Adding method to determine customer type for contact us redirection
    //This method is called by ContactUsRedirection component from blank Contact-US page for redirection
    //blank page was added to prevent displaying contact-us page for users with slow internet connection
    //added by Ravi Yalamati 31st-May-2018
    @AuraEnabled
    public static string getCustomerTypeForCase() {
        Id usrId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId, Profile.name from User where Id=:usrId];
        String contactUs = 'contactUs';
        //check for sage financials
        List<sfLma__License__c> lstValidLicense = [Select id from sfLma__License__c where sfLma__Account__c=:u.AccountId  AND sfLma__License_Status__c='Active' AND sfLma__Org_Status__c='Active' AND (sfLma__Package__r.Name like '%Live%' OR sfLma__Package__r.Name like '%Financials%') AND sfLma__Account__c!=null];        
        if(lstValidLicense!=null && lstValidLicense.size()>0) {
            contactUs = 'Financials';
        }
        //check for sage accounting
        List<Subscription_Master__c> activities = [SELECT Id,Product__c, ZProduct__c,ChannelPartner__r.ChannelPlatform__r.Name FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND  Account__c != '' and  (Status__c = 'Trial' or Status__c = 'Active' or (ChannelPartner__r.ChannelPlatform__r.Name = 'AppDirect' and Is_Blocked__c = false and Is_Cancelled__c = false))];
        if(activities!=null && activities.size()>0) {
            contactUs = 'Accounting';
        }
        if(u.Profile.Name.containsignorecase('partner')) {
            contactUS+='Partner';
        }
        
        return contactUs;
    }
    
}