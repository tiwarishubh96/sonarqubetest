@isTest
private class TwitterFeedControllerTest {
    @isTest static void testUpdate(){
        List<TwitterWidget__c> twitList = new List<TwitterWidget__c>();
        TwitterWidget__c twit = new TwitterWidget__c();
        twit.Name = 'Home-cs';
        twit.Page_Name__c = 'Home';
        twit.Widget_Id__c = '803309591261945856';
        twit.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit);
        
        TwitterWidget__c twit2 = new TwitterWidget__c();
        twit2.Name = 'Default-cs';
        twit2.Page_Name__c = 'Default';
        twit2.Widget_Id__c = '803309591261945856';
        twit2.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit2);
        
        insert twitList;
        
        
        PageReference pageRef = Page.TwitterFeed;
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getHeaders().put('referer', 'community');
        TwitterFeedController tfc = new TwitterFeedController();  
        
        Test.startTest();
            //tfc.currentURL2 = 'https://sagew17uat-sagegroup.cs89.force.com/community/s/';
            tfc.save();
            tfc.Cancel();
            tfc.Click();
            tfc.getTwitterId('s/');
        Test.stopTest();
    }
    
    @isTest static void testUpdate2(){
        List<TwitterWidget__c> twitList = new List<TwitterWidget__c>();
        TwitterWidget__c twit = new TwitterWidget__c();
        twit.Name = 'Home-pt';
        twit.Page_Name__c = 'Home';
        twit.Widget_Id__c = '803309591261945856';
        twit.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit);
        
        TwitterWidget__c twit2 = new TwitterWidget__c();
        twit2.Name = 'Default-pt';
        twit2.Page_Name__c = 'Default';
        twit2.Widget_Id__c = '803309591261945856';
        twit2.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit2);
        
        insert twitList;
        
        
        PageReference pageRef = Page.TwitterFeed;
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController controller = new ApexPages.StandardController();
        ApexPages.currentPage().getHeaders().put('referer', 'partner');
        TwitterFeedController tfc = new TwitterFeedController();  
        
        Test.startTest();
            tfc.getTwitterId('s/sage-one-home');
        Test.stopTest();
    }
    @isTest static void testUpdate3(){
        List<TwitterWidget__c> twitList = new List<TwitterWidget__c>();
        TwitterWidget__c twit = new TwitterWidget__c();
        twit.Name = 'Home-cs';
        twit.Page_Name__c = 'Home';
        twit.Widget_Id__c = '803309591261945856';
        twit.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit);
        
        TwitterWidget__c twit2 = new TwitterWidget__c();
        twit2.Name = 'Default-cs';
        twit2.Page_Name__c = 'Default';
        twit2.Widget_Id__c = '803309591261945856';
        twit2.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit2);
        
        insert twitList;
        
        
        PageReference pageRef = Page.TwitterFeed;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('referer', 'community');
        TwitterFeedController tfc = new TwitterFeedController();  
        
        Test.startTest();
            tfc.getTwitterId('s/Default');
            tfc.widgetId = 'href="test"data-widget-id="test"';
            tfc.save();
        Test.stopTest();
    }
    @isTest static void testUpdate4(){
        List<TwitterWidget__c> twitList = new List<TwitterWidget__c>();
        TwitterWidget__c twit = new TwitterWidget__c();
        twit.Name = 'Home-pt';
        twit.Page_Name__c = 'Home';
        twit.Widget_Id__c = '803309591261945856';
        twit.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit);
        
        TwitterWidget__c twit2 = new TwitterWidget__c();
        twit2.Name = 'Default-cs';
        twit2.Page_Name__c = 'Default';
        twit2.Widget_Id__c = '803309591261945856';
        twit2.Search_Id__c = 'https://twitter.com/hashtag/CloudFirst';
        twitList.add(twit2);
        
        insert twitList;
        
        
        PageReference pageRef = Page.TwitterFeed;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('referer', 'partner');
        TwitterFeedController tfc = new TwitterFeedController();  
        
        Test.startTest();
            tfc.createNew = true;
            tfc.currentTab = 'test';
            tfc.updateCustomSetting();
        Test.stopTest();
    }
}