@isTest
private class SageCommunityCasePostCommentTest {
    
    public static String SageCommunityProfile;
    public static String SageCaseStatus;

    // Set up Environment Custom Settings    
    public static void setUpErrorCustomSettings(){
        
        Community_SSO_Settings__c setting = new Community_SSO_Settings__c();
        setting.SageCommunityProflieName__c = 'Sage: CBC Customer Community User';
        SageCommunityProfile =  setting.SageCommunityProflieName__c;
        insert setting;
        
        Community_Settings__c commSetting = new Community_Settings__c();
        commSetting.CaseStatusUpdate__c = 'Updated by Customer';
        SageCaseStatus = commSetting.CaseStatusUpdate__c;
        insert commSetting;
        
        insert new Application_Control__c(Run_Triggers__c = true);
        insert new CBC_Application_Control__c(Run_Triggers__c = true);
        
    }
    
    static testMethod void testCreatePosCommentUnderCaseByCommunityUserSingleFeedInsert(){
        setUpErrorCustomSettings();
        
        // Create Account
        Account acc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678',BillingCity='Test City',BillingCountry='Poland', BillingStreet ='Sample Street');
        insert acc;    
        // Create Contact for Account
        Contact con = new Contact(
            AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact', Phone = '12345678', Email = 'abc@123.com',MailingCity = 'Some City',MailingCountry = 'Poland',MailingStreet='Some Street');     
        insert con;   
        
        // Get Admin user details to login and create the Community User
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // Create Community User for this Contact
        User communityUser;
        
        System.runAs ( thisUser ) {
                 
            Profile p = [select Id,name from Profile where Name  =: SageCommunityProfile limit 1];          
    
                communityUser = new User(
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
         
         System.runAs ( communityUser ) {
            // Create a Case
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
                    
            // Create the Feed Item
            FeedItem f = new FeedItem();            
            f.Body = 'Chatter Test1';
            f.ParentId = c.id;
            f.Type = 'TextPost';            
            insert f;                                   
                 
            //Post a comment to feed item and check if status was changed
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'Chatter Reply1';                
            fc.FeedItemId = f.id;
            fc.CommentType = 'TextComment';
            insert fc;            
            
            Case updatedCase = [Select Status,Id FROM Case where id =: c.id Limit 1];
            system.assertEquals(SageCaseStatus,updatedCase.Status, 'Case status should be Updated by Customer');
            update fc;
            
        }
        test.stopTest();
    }
    
    
     static testMethod void testCreatePostCommentUnderCaseByNonCommunityUser(){
        setUpErrorCustomSettings();        
        
        // Get Admin user details to login and create the Community User
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        test.startTest();
        System.runAs ( thisUser ) {
            //Create a Case
            Case c = new Case();
            c.Type ='Question';
            c.Case_Category__c='Processing';
            c.Case__c='Adjustments';
            c.Customer_Lifecycle_Stage__c='Trial';
            c.Status = 'New';
            c.Priority ='Low';
            c.Origin='Web';
            c.Subject= 'Unit test case';
            insert c;
            
            // Create the Feed Item for the Case
            FeedItem f = new FeedItem();
            f.Body = 'Chatter Test1';
            f.ParentId = c.id;
            f.Type = 'TextPost';            
            insert f;  
            
            //Post a message comment to the Case and check if status was changed
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'Chatter Test1';
            fc.FeedItemId = f.id;
            fc.CommentType = 'ContentComment';
            
            insert fc;
            Case updatedCase = [Select Status,Id FROM Case where id =: c.id Limit 1];
            system.assertEquals('New',updatedCase.Status, 'Case status should be Updated by Customer');
          
        }

        test.stopTest();
    }
    
    static testMethod void testCreatePostCommentUnderCaseByCommunityUserMultipleFeedInsert(){
        setUpErrorCustomSettings();
        
        // Create Account
        Account acc = new Account(Name = 'Test Account', Sales_Office__c = 'Dublin CBC', Type = 'Customer', Industry = 'Finance', Phone = '12345678',BillingCity='Test City',BillingCountry='Poland', BillingStreet ='Sample Street');
        insert acc;  
        // Create Contact for Account
        Contact con = new Contact(
            AccountId = acc.Id, FirstName = 'Test', LastName = 'Contact', Phone = '12345678', Email = 'abc@123.com',MailingCity = 'Some City',MailingCountry = 'Poland',MailingStreet='Some Street');     
        insert con;   
        
        // Get Admin user details to login and create the Community User
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // Create Community User for this Contact
        User communityUser;
        
        System.runAs ( thisUser ) {
         
            Profile p = [select Id,name from Profile where Name  =: SageCommunityProfile limit 1];          
    
                communityUser = new User(
                    profileId = p.id, 
                    username = 'testSageCpqzs12@test.com', 
                    email = 'test@test.com', 
                    emailencodingkey = 'UTF-8', 
                    localesidkey = 'en_GB', 
                    languagelocalekey = 'en_US', 
                    timezonesidkey = 'Europe/London', 
                    alias='nuse2', 
                    lastname='lastname', 
                    contactId = con.id
                );
                insert communityUser;      
        }
             
        test.startTest();
        System.runAs ( communityUser ) {
            // Create a Case        
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

            // Create the Feed Item for the Case
            FeedItem f = new FeedItem();
            f.Body = 'Chatter Test1';
            f.ParentId = c.id;
            f.Type = 'TextPost';            
            insert f;
                        
            system.assertEquals('New', c.Status, 'Case should have status New');
            List<FeedComment> feedToInsert = new List<FeedComment>();
            //Post message comment to the Case and check if status was changed
            for(Integer i=0;i<100;i++){
                FeedComment fc = new FeedComment();
                fc.CommentBody = 'Chatter Test'+i;
                fc.FeedItemId = f.id;
                fc.CommentType = 'ContentComment';
                feedToInsert.add(fc);
            }

            insert feedToInsert;
            
            Case updatedCase = [Select Status,Id FROM Case where id =: c.id Limit 1];
            system.assertEquals(SageCaseStatus,updatedCase.Status, 'Case status should be Updated by Customer');
            
        }
        test.stopTest();
    }

}