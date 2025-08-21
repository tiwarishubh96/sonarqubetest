@IsTest
private class CommunityMyAccountControllerTest {

   static testMethod void unitTest() {
      
    // Create Account
        Account acc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678');
        insert acc;
    
    // Create Contact for Account
        Contact con = new Contact(
            AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact', Phone = '12345678', Email = 'abc@123.com');     
        insert con;   

    
    // Get Admin user details to login and create the Community User
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    // Create Community User for this Contact
    User communityUser;
    
    System.runAs ( thisUser ) {

    Profile p = [select Id,name from Profile where Name  ='Sage: CBC Customer Community User' limit 1];          

            communityUser = new User(
                //UserRoleId = ur.Id,
                profileId = p.id, 
                username = 'testSageCpqzs@test.com', 
                email = 'test@test.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_GB', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'Europe/London', 
                alias='nuser', 
                lastname='lastname', 
                contactId = con.id
            );
            insert communityUser;      
         }
         
    test.startTest();
     
    // Login as Community User     
    System.runAs ( communityUser ) {
    
        //Call CommunityMyAccountController
        CommunityMyAccountController controller = new CommunityMyAccountController();
        //Call PageReference
        CommunityMyAccountController controllerStd = new CommunityMyAccountController(new ApexPages.StandardController(acc));
        //check getCon propery
        system.assertEquals(true, controller.getCon() != null, 'Contact should be retured');
        //check account page reference
        PageReference pageRef = controller.getMyAccount();
        system.assertEquals(true, pageRef.getUrl().contains(controller.getCon().accountid), 'Page should pointing to account');
     }

    test.stopTest();         

   }
    
    static testMethod void unitTestForNonCommunityUser() {
        // Create Community User for this Contact
        User standardUser;
        
        System.runAs ( new User(id=UserInfo.getUserId()) ) {
    
        Profile p = [select Id,name from Profile where Name  ='Standard User' limit 1];          
    
                standardUser = new User(
                    //UserRoleId = ur.Id,
                    profileId = p.id, 
                    username = 'testSageCpqzs@test.com', 
                    email = 'testSageCpqzs@test.com', 
                    emailencodingkey = 'UTF-8', 
                    localesidkey = 'en_GB', 
                    languagelocalekey = 'en_US', 
                    timezonesidkey = 'Europe/London', 
                    alias='qazxc', 
                    lastname='lastname' 
                );
                insert standardUser;      
             }
             
        test.startTest();
         
        // Login as Community User     
        System.runAs ( standardUser ) {
            CommunityMyAccountController controller = new CommunityMyAccountController();
            system.assertEquals(null, controller.getCon(), 'User should not have reference to ContactId');
            system.assertEquals(null, controller.getMyAccount(), 'User should not be aligned with account');
        }
    }
}