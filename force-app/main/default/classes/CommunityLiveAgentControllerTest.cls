@isTest
public class CommunityLiveAgentControllerTest{

    public static testMethod void runTest(){
        User u = createTestData('test', 'test', 'test@test.com', 'test@test.com');
        system.runAs(u){
            CommunityLiveAgentController controller = new CommunityLiveAgentController();
            system.assertEquals('firstname lastname', controller.userName);
            system.assertEquals('00D250000000N0w', controller.orgId);
            system.assertEquals('liveagent_button_online_57324000000PDCS', controller.atlantaOnline);
            system.assertEquals('firstname', controller.userFirstName);
        }
    }
    
    private static User createTestData(String firstName,String lastName,String email,String userName){
        Live_Support_Configuration__c config = new Live_Support_Configuration__c(
                     Name = 'Live Agent Configuration', 
                     Organization_Id__c = '00D250000000N0w',
                     Live_Agent_Deployment_Id__c = '57224000000PBjy',
                     Atlanta_Chat_Button_Id__c = '57324000000PDCS',
            		 Atlanta_French_Canadian_Chat_Button_Id__c = '573260000004CNU',
                     Dublin_Chat_Button_Id__c = '57324000000PDCT',
                     Default_Chat_Button_Id__c = '57324000000PCFG');
        insert config;
        Account acc = new Account(Name = 'test', Sales_Office__c = 'Atlanta CBC');
        insert acc;
        Contact con = new Contact(FirstName = 'test', LastName = 'test', AccountId = acc.Id);
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sage: CBC Customer Community User' LIMIT 1];  
         
        User u = new User(profileId = p.id, IsActive = true,username = 'liveAgentTestUser@test.com', email = 'liveAgentTestUser@test.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', firstname='firstname', lastname='lastname', contactId = con.id);
        
        Database.insert(u);
        return u;
    }

}