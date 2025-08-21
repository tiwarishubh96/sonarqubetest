@isTest
public class CommunityComponentControllerTest {
    @isTest
    static void getCurrentCommunityIdTest() {
        CommunityComponentController.getCurrentCommunityId();
    }
    @isTest
    static void getUserInfoTest() {
        Contact con = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'Jordan', 'Smith', 'jsmith@gmail.com');
        User u = CommunityUtilitiesTest.createPortalUser(con);
        System.runAs(u){
            CommunityComponentController.getUserInfo();
        }
    }
    @isTest
    static void getUserContextTest() {
        Contact con = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'Jordan', 'Smith', 'jsmith@gmail.com');
        User u = CommunityUtilitiesTest.createPortalUser(con);
        System.runAs(u){
            
            CommunityComponentController.getUserContext();
            
        }
    }
    
   
}