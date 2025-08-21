@isTest
private class BrightCoveLinkContTest {
    
    @isTest static void testCont1(){
        
        PageReference pageRef = Page.BrightCoveLink;
        Test.setCurrentPage(pageRef);
        
        BrightCoveLinkCont controller = new BrightCoveLinkCont();
        test.startTest();
        	controller.iFrameLink = '<iframe src="//players.brightcove.net/1180526826001/default_default/index.html?videoId=5110092734001" ></iframe>';
        	controller.Save();
        test.stopTest();
    }
    
    @isTest static void testCont2(){
        
        PageReference pageRef = Page.BrightCoveLink;
        Test.setCurrentPage(pageRef);
        
        BrightCoveLinkCont controller = new BrightCoveLinkCont();
        test.startTest();
        	controller.iFrameLink = '<iframe src=\'//players.brightcove.net/1180526826001/default_default/index.html?videoId=5110092734001\' ></iframe>';
        	controller.Save();
        test.stopTest();
    }
    
    @isTest static void testCont3(){
        
        PageReference pageRef = Page.BrightCoveLink;
        Test.setCurrentPage(pageRef);
        
        BrightCoveLinkCont controller = new BrightCoveLinkCont();
        test.startTest();
        	controller.iFrameLink = 'test';
        	controller.Save();
        test.stopTest();
    }
			
}