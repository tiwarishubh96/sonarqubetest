@isTest
private class CaseRequestClosureChatterPostCtrlTest {
    
    /*
     *Testing RequestCaseClosure method
	*/
    static testMethod void testRequestCaseClosure(){
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
                    username = 'testSageCpqzssa@test.com', 
                    email = 'testsss2@test.com', 
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
        System.runAs ( communityUser ) {
            Case c = new Case();
            c.Type ='Question';
            c.ContactId=con.id;
            c.AccountId = acc.id;
            c.Case_Category__c='Processing';
            c.Case__c='Adjustments';
            c.Customer_Lifecycle_Stage__c='Trial';
            c.Status = 'New';
            c.Priority ='Low';
            c.Origin='Web';
            c.Subject= 'Unit test case';
            insert c;
            
            system.assertEquals('New', c.Status, 'Case should have status New');
            CaseRequestClosureChatterPostController ctrl = new CaseRequestClosureChatterPostController(new ApexPages.StandardController(c));
            ctrl.message='Unit test feed message';
            ctrl.requestCaseClosure();
            system.assertEquals(true, ctrl.lastAddedFeedId != null, 'FeedItem should be added during requestCaseClosure method execution');
        }
        
        Test.stopTest();
    }

}