@isTest(SeeAllData=false) 
private class TetrisTrailExtensionVO_Test {

	static testMethod void testSettersGetters() {

        String strJSONBody = '{"subscriptionId": "722dcb88-0cda-4794-86c2-4bb27e8cd3ff", '+
            				'"subscriptionGroupId": "722dcb88-0cda-4794-86c2-4bb27e8cd3ff",'+
            				'"channelPlatform": "Tetris", "channelPartner": "Tetris","isTrial": true, '+
            				'"entitledAccount": { "id": "0010E00000MHGCjQAP" },"customerContact": { '+
            				'"id": "0030E00000M2ieLQAR"},"managingAccount": {"id": "0010E00000MHGCjQAP" '+
            				'},"state": "Active","effectivePeriod": { "notBefore": "2018-06-12","notAfter": "2018-08-11" '+
            				'},"entitlement": {"entitlementId": "38145833-97c1-4154-970b-0f58c6a0888b","products": [ '+
            				'{"product": "SageOneStartGB", "features": [ {"name": "trial", "properties": [] '+
            				'}],"launchUrl": "https://pre-central.uk.sageone.biz/service/access?service=SageOne-Start-GB" '+
            				'}]},"links": [ {"service": "SubscriptionManagement",'+
            				' "url": "https://preprod-sage-com-web-imagine.sagegwd.com/en-gb/subscriptions/" '+
            				'},{ "service": "Logout", '+
            				'"url": "https://preprod-sage-com-web-imagine.sagegwd.com/imagine-assets/sitecore/api/logout" '+
            				'},{"service": "PaymentMethod", "url": "https://preprod-sage-com-web-imagine.sagegwd.com/en-gb/subscriptions/"'+
            				'},{ "service": "TrialConversion", "url": "https://preprod-sage-com-web-imagine.sagegwd.com/en-gb/subscriptions/" '+
            				' } ]}';
        
        TetrisTrailExtensionVO.parse(strJSONBody);
		TetrisTrailExtensionVO.EntitledAccount acct = new TetrisTrailExtensionVO.EntitledAccount();
    	acct.id ='121';
          
        TetrisTrailExtensionVO.Products prdts = new TetrisTrailExtensionVO.Products();
        prdts.product='Test';
		prdts.features = null;
		prdts.launchUrl='';
          
        TetrisTrailExtensionVO trialExt = new TetrisTrailExtensionVO(); 
        trialExt.subscriptionId ='122';
        trialExt.subscriptionGroupId ='12121';
        trialExt.channelPlatform ='12121';
        trialExt.channelPartner='12121';
        trialExt.isTrial= false;
        trialExt.state ='121';
        trialExt.links=null;
        trialExt.errors=null;

      }
}