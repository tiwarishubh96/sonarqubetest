@IsTest ( SeeAllData=true )
public class TetrisLoginController_Test {

	static testMethod void testTetrisLoginController(){
		TetrisLoginController tetrisController = new TetrisLoginController();
	}
    
    static testMethod void testRedirecttoTetrispage(){

    	TetrisLoginController tetrisController = new TetrisLoginController();
        tetrisController.RedirecttoTetrispage();

    }

    static testMethod void testSetRedirectUrl() {

    	TetrisLoginController tetrisController = new TetrisLoginController();
        tetrisController.SetRedirectUrl(new PageReference('/test?startUrl=123'));
    }
    
    static testMethod void testSetParamsToKillSessionCookie() {
        TetrisLoginController tetrisController = new TetrisLoginController();
        tetrisController.SetParamsToKillSessionCookie(new PageReference('/test?startUrl=123'));
    }
    
    static testMethod void testUpdateCookies() {
    	TetrisLoginController tetrisController = new TetrisLoginController();
    	tetrisController.UpdateCookies(new PageReference('/test?startUrl=123'));
    }
}