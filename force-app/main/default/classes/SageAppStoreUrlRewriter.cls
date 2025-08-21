global with sharing class SageAppStoreUrlRewriter implements Site.UrlRewriter {

    //Variables to represent the user-friendly URLs
    String HOME_PAGE = '/asb_home/';

    //Variables to represent my custom Visualforce pages
    String HOME_VISUALFORCE_PAGE = '/asb_home?';

    global PageReference mapRequestUrl(PageReference
            myFriendlyUrl){
        return null;
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> 
            mySalesforceUrls){
        //A list of pages to return after all the links 
        //have been evaluated
        List<PageReference> myFriendlyUrls = new List<PageReference>();
                
        // it is important to go through all the urls again, so that the order
        // of the urls in the list is maintained. 
        for(PageReference mySalesforceUrl : mySalesforceUrls) {
        
           //Get the URL of the page
           String url = mySalesforceUrl.getUrl();
        
           if(url.startsWith(HOME_VISUALFORCE_PAGE )){
                myFriendlyUrls.add(new PageReference(Site.getPathPrefix()+url));
           } else {
                //If this doesn't start like a home page,
                //don't do any transformations
                myFriendlyUrls.add(mySalesforceUrl);
           }
        }
        
        //Return the full list of pages
        return myFriendlyUrls;
    }

}