/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
            test.startTest();
            CommunitiesLandingController ctrl = new CommunitiesLandingController();
            PageReference pf = ctrl.forwardToStartPage();
            system.assertEquals('', pf == null? '':pf.getUrl(), 'Landing page should not be returned');
            test.stopTest();
      }
    
    
}