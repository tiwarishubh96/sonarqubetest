@isTest
private class UpdateCommunityUserTCsAgreedTest {
    /*
     * Test method for getUserRecord method checking if user record
     * was updated 
    */
    static testMethod void testgetUserRecord(){
        
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
                        username = 'testSagegetUserRecord@test.com', 
                        email = 'testgetUserRecord@test.com', 
                        emailencodingkey = 'UTF-8', 
                        localesidkey = 'en_GB', 
                        languagelocalekey = 'en_US', 
                        timezonesidkey = 'Europe/London', 
                        alias='n12er', 
                        lastname='lastname', 
                        contactId = con.id
                    );
                    insert communityUser;      
      }
      system.debug('Start executing test method community user context');  
      System.runAs(communityUser) { 
            //execute method from tested contoller
            UpdateCommunityUserTCsAgreed.getUserRecord(new List<Id>{communityUser.id});
        
            //check wehter user T&C fields were updated
            User userDataAfterUpdate = [SELECT T_C_Agreed__c,T_C_Acknowledged__c FROM User where id =:communityUser.id Limit 1];
            //check T&C flag if marked on true
            system.assertEquals(true, userDataAfterUpdate.T_C_Agreed__c, 'Flag should be marked on true after UpdateCommunityUserTCsAgreed.getUserRecord method invocation');
            system.assertEquals(Date.today(), userDataAfterUpdate.T_C_Acknowledged__c, 'Field  should be set to today after UpdateCommunityUserTCsAgreed.getUserRecord method invocation');
      }
        
    }

}