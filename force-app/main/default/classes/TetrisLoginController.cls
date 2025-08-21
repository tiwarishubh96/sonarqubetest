//Apex controller for the StoreFront Community Login functionality - This page redirects to the Tetris main page

global class TetrisLoginController {

    global TetrisLoginController () {}

    global String redirectUrl {get;set;}
    global String sfDomain {get;set;}
    
    // Code we will invoke on page load.
    global PageReference redirecttoTetrispage() {
    
      System.debug('In TetrisLoginController:redirecttoTetrispage...');

      System.PageReference currentPage = System.currentPageReference();
      System.debug('currentPage => ' + currentPage);
      
      SetRedirectUrl(currentPage);
      
      SetParamsToKillSessionCookie(currentPage);
      
      UpdateCookies(currentPage);
      
      System.debug('Exiting TetrisLoginController:redirecttoTetrispage');
      
      //let the page return so the client-side script can kill cookies and then redirect
      // to the originally-requested storefront page
      return null;
      
    }
    
    @TestVisible private void SetRedirectUrl(PageReference currentPage) {
        // /apex/TetrisLoginPage?action=buy&pageKey=TetrisRegistration&sku=SKU-00000030&startURL=%2FDefaultStore%2Fccrz__CCPage%3Faction%3Dbuy%26pageKey%3DTetrisRegistration%26sku%3DSKU-00000030
        redirectUrl = currentPage.getParameters().get('startURL');
        //redirectUrl = currentPage.getUrl();
        System.debug('Setting redirectUrl => ' + redirectUrl );
    }
    
    @TestVisible private void SetParamsToKillSessionCookie(PageReference currentPage) {
        
        String fullUrl = URL.getSalesforceBaseUrl().toExternalForm();
        if(fullUrl != null && fullUrl.indexOf('//') > -1) {
            //remove the protocol
            sfDomain = fullUrl.substring(fullUrl.indexOf('//') + 2);
        } else {
            sfDomain = fullUrl;
        }
    }
    
    
    //NOTE: This isn't used since the cookies get written out with an 'apex__' prefix so it
    //       isn't properly removing the SF session
    @TestVisible private void UpdateCookies(PageReference currentPage) {
    
      //System.debug('fetching incoming cookies collection...');
      //Map<String, System.Cookie> incomingCookies = ApexPages.currentPage().getCookies();
      
      //for(String cookieName: incomingCookies.keyset()) {
      //    System.Cookie currCookie = incomingCookies.get(cookieName);
      //    System.debug('cookieName => ' + cookieName);
      //    System.debug('cookie value => ' + currCookie);
      // }
       
      //Cookie sId = ApexPages.currentPage().getCookies().get('sid');
      //System.debug('incoming force.com session cookie => ' + sId);
      
      //Cookie sidToRemoveCookie = new Cookie('sid', '', '/', 0, true);
      //System.debug('New cookie to remove session => ' + sidToRemoveCookie );
      //ApexPages.currentPage().setCookies(new Cookie[]{sidToRemoveCookie });
      
      //if(sId != null) {
      //      sIdcookie = sid.getValue();
      //      System.debug('Attempting to remove force.com session cookie...');
      //      ApexPages.currentPage().setCookies(new Cookie[]{sId});  
      // }
          
    }
}