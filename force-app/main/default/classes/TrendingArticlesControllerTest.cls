@isTest
private class TrendingArticlesControllerTest
{
	@isTest(SeeAllData=true)
	static void itShould()
	{
		// Given

		Id commId = [SELECT id, name FROM Network where Name='Sage Customer Community' limit 1].id;
		Community_Component_Config__c componentConfig = new Community_Component_Config__c();
            componentConfig.Community_Id__c = commId;
            componentConfig.Component_Name__c = 'componentName';
            componentConfig.Settings__c = 'settings';
            insert componentConfig;
		// When
		 
		String componentId = componentConfig.id;
		TrendingArticlesController.saveSettings('', commId, 'componentName','Trending Articles Component', 'settings');

		TrendingArticlesController.saveSettings(componentId, commId, 'componentName','Trending Articles Component', 'settings');

		try
		{
			TrendingArticlesController.getCommunities();
			}catch(Exception ex)
			{

			}

			try
		{
			TrendingArticlesController.getCommunityNavigationalTopics(commId);

			}catch(Exception ex)
			{
				
			}
			try
			{
			TrendingArticlesController.getCommunityNavigationalTopicsByName('Sage Customer Community');
			}catch(Exception ex)
			{
				
			}

			try
			{
			TrendingArticlesController.getCommunityNavigationalTopicsByParent('communityId', 'parentTopicId');
			}catch(Exception ex)
			{
				
			}

			try
			{
                Community_Component_Config__c commCompConfig = new Community_Component_Config__c();
        		commCompConfig.Component_Name__c = 'Customer Community Comp';
        		commCompConfig.Name = 'Comp';
                commCompConfig.Community_Id__c=commId;
                commCompConfig.Component_Type__c = 'Featured Articles Component';
                commCompConfig.Permission_Name__c='Sage: Customer CC Admin';
                commCompConfig.Settings__c='{"maxRecords":10,"navigationalTopicDepth":3, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}},{"languageLabels": {"en": "Getting Started","default": "Getting Started"}, "dataCategories": {"Products": "Start","Category": "Getting_Started"}},{"languageLabels": {"en": "My Account","fr": "Mon compte","default": "My Account"}, "dataCategories": {"Products": "Start","Category": "Settings"}},{"languageLabels": {"en": "Contacts","default": "Contacts"}, "dataCategories": {"Products": "Start","Category": "Contacts_Featured"}},{"languageLabels": {"en": "Invoicing","default": "Invoicing"}, "dataCategories": {"Products": "Start","Category": "Expenses"}}]}';
        		insert commCompConfig;
			TrendingArticlesController.retrieveCurrentConfig('Sage Customer Community', commId, 'Customer Community Comp','Sage: Customer CC Admin');
			}catch(Exception ex)
			{
				
			}
			try
			{
			TrendingArticlesController.retrieveCurrentConfig('Sage Customer Community', '', 'componentName','');
			}catch(Exception ex)
			{
				
			}
			
		/*

		

		

		TrendingArticlesController.getCommunityNavigationalTopicsByParent('communityId', 'parentTopicId');

		
		
		TrendingArticlesController.retrieveCurrentConfig('communityName', comId, 'componentName');
		
**/
		// Then

	}
}