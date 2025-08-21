public with sharing class CaseRequestClosureChatterPostController {
    public Case cse { get; set; }
    public String message { get; set; }
    public String lastAddedFeedId{get;set;}
    
    /*
     * Controller constructor
     */
    public CaseRequestClosureChatterPostController(ApexPages.StandardController controller) {
        system.debug('***CaseRequestClosureChatterPostController controller initialization');
        cse = (Case) controller.getRecord();
        system.debug('***CaseRequestClosureChatterPostController controller exit');
    }
    
    /*
     Method add feed Item with request for closing the case
    */
    public PageReference requestCaseClosure() {
        system.debug('***requestCaseClosure callout');
        FeedItem fItem = new FeedItem();

        fItem.parentId = cse.Id;
        fItem.body = Label.CaseRequestClosureFeedItemPrefix +' \r\n\r\n'+ message;
        fItem.visibility = 'AllUsers';
        fItem.Type = 'TextPost';
        insert fItem;
        lastAddedFeedId = fItem.id;
        system.debug('following id was returned:'+lastAddedFeedId);

        message = '';
        system.debug('***requestCaseClosure exit folling feedItem was added:'+fItem);
        return null;
    }
}