public with sharing class TrendingArticlesController {
    @AuraEnabled
    public static List<ConnectAPI.Community> getCommunities() {
        return CommunityHelper.getAllCommunities();
    }

    @AuraEnabled
    public static List<ConnectApi.ManagedTopic> getCommunityNavigationalTopics(String communityId) {
        return CommunityHelper.getNavigationalTopics(communityId);
    }

    @AuraEnabled
    public static List<ConnectApi.ManagedTopic> getCommunityNavigationalTopicsByName(String communityName) {
    	String communityId = CommunityHelper.getCommunityId(communityName);
        System.debug('TrendingArticlesController: getCommunityNavigationalTopicsByName: communityId' + communityId);
        return CommunityHelper.getNavigationalTopics(communityId);
    }

    @AuraEnabled
    public static List<ConnectApi.ManagedTopic> getCommunityNavigationalTopicsByParent(String communityId, String parentTopicId) {
        System.debug('TrendingArticlesController: getCommunityNavigationalTopicsByParent: communityId' + communityId);
        System.debug('TrendingArticlesController: getCommunityNavigationalTopicsByParent: parentTopicId' + parentTopicId);
        return CommunityHelper.getNavigationalTopicsByParent(communityId, parentTopicId);
    }
    
    @AuraEnabled
    public static void saveSettings(String componentConfigId, String communityId, String componentName, String componentType, String settings) {
        saveSettingsEx(componentConfigId, communityId, componentName, '', componentType, settings);
    }
        

    @AuraEnabled
    public static void saveSettingsEx(String componentConfigId, String communityId, String componentName, String permissionName, String componentType, String settings) {
   		ComponentConfigHelper.saveSettings(componentConfigId, communityId, componentName, permissionName, componentType, settings);
    }

    @AuraEnabled
    public static TrendingArticlesResult retrieveCurrentConfig(String communityName, String communityId, String componentName, String permissionName) {
        System.debug('TrendingArticlesController: retrieveCurrentConfig: communityName' + communityName);
        if ((communityId == null) || (communityId.equals(''))) {
            communityId = CommunityHelper.getCurrentCommunitId();
            System.debug('Community ID from API is .... ' + communityId);
        }

        if (communityId.equals('')) {
	         System.debug('TrendingArticlesController: retrieveCurrentConfig: throwing error ' + communityName);
           throw new CustomCommunityException('Invalid Community Id. Valid Community Name is needed.');
        }
		    CompConfigTrendingArticles taConfig = new CompConfigTrendingArticles();
        List<ConnectApi.KnowledgeArticleVersion> articlesList = new List<ConnectApi.KnowledgeArticleVersion>();
        List<ConnectApi.KnowledgeArticleVersion> curatedArticlesList = new List<ConnectApi.KnowledgeArticleVersion>();
        List<ConnectApi.KnowledgeArticleVersion> childArticlesList = new List<ConnectApi.KnowledgeArticleVersion>();
        List<ConnectApi.KnowledgeArticleVersion> parentArticlesList = new List<ConnectApi.KnowledgeArticleVersion>();
        Set<ConnectApi.KnowledgeArticleVersion>  articlesSet = new Set<ConnectApi.KnowledgeArticleVersion>();

        String componentConfigId = '';
        try {
            System.debug('TrendingArticlesController: retrieveCurrentConfig: retrieve component config ' + communityId + ', componentName ' + componentName);
            Community_Component_Config__c componentConfig = [SELECT Id, Community_Id__c, Component_Name__c, Permission_Name__c, Settings__c FROM Community_Component_Config__c WHERE Community_Id__c =:communityId AND  Component_Name__c =:componentName LIMIT 1];
            if (componentConfig != null) {
                componentConfigId = componentConfig.Id;
                String  customSettingsJson = componentConfig.Settings__c;
                taConfig = (CompConfigTrendingArticles)JSON.deserialize(customSettingsJson, CompConfigTrendingArticles.class);
                Integer maxResults = taConfig.maxRecords;
                system.debug('maxResults'+ maxResults);
                String selectedTopicId = '';
                String rootTopicId = taConfig.rootTopic;
                String childTopicId = '';
                String grandChildTopicId = '';

                Integer navigationDepth = taConfig.navigationalTopicDepth;
                if (navigationDepth == 1) {
                    selectedTopicId = taConfig.rootTopic;
                }
                if (navigationDepth == 2) {
                    selectedTopicId = taConfig.childTopic;
                }
                if (navigationDepth == 3) {
                    selectedTopicId = taConfig.grandChildTopic;
                    childTopicId = taConfig.childTopic;

                }
                System.debug('*****************************************************');
                System.debug(selectedTopicId);
                if (!selectedTopicId.equals('')) {
                    //{"maxRecords":5,"navigationalTopicDepth":2,"rootTopic":"0TO24000000UF6sGAG","childTopic":"0TO24000000UF6wGAG","grandChildTopic":""}
                    childArticlesList = KnowledgeHelper.getTrendingArticlesByTopic(communityId, selectedTopicId, maxResults);
                    articlesSet.addAll(childArticlesList);
                    System.debug('Articles list length ' + articlesSet.size());

                    if ((articlesSet.size() <= maxResults) && (!selectedTopicId.equals(rootTopicId))) {
                        selectedTopicId = (!childTopicId.equals(''))?childTopicId:rootTopicId;
                        parentArticlesList = KnowledgeHelper.getTrendingArticlesByTopic(communityId, selectedTopicId, maxResults);
                    	System.debug('First Level up: length ' + parentArticlesList.size());
                        articlesSet.addAll(parentArticlesList);
                    	System.debug('First Level up: Articles list length ' + articlesSet.size());

                        if ((articlesSet.size() <= maxResults) && (!selectedTopicId.equals(rootTopicId))) {
                            selectedTopicId = rootTopicId;
                            parentArticlesList = KnowledgeHelper.getTrendingArticlesByTopic(communityId, selectedTopicId, maxResults);
                            articlesSet.addAll(parentArticlesList);
                            System.debug('Second Level up:Articles list length ' + articlesSet.size());
                    }
                }
          	  } //selectedTopic
               System.debug('Final Articles set length ' + articlesSet.size());
               articlesList.addAll(articlesSet);
                for (Integer i = 0; i < maxResults; i++) {
                    curatedArticlesList.add(articlesList.get(i));
                }
               System.debug('Final Articles list length ' + curatedArticlesList.size());

            } //componentconfig
        } //try
        catch (Exception ex) {
            //Error reported when no rows are returned
            System.debug('Exception ' + ex.getMessage());
        }

		//String componentAdmin = Community_Settings__c.getInstance().Component_Admin__c;
        //System.debug('TrendingArticlesController: retrieveConfig: componentAdmin ' + componentAdmin);
        System.debug('TrendingArticlesController: retrieveConfig: componentConfigId ' + componentConfigId);
        System.debug('TrendingArticlesController: retrieveConfig: communityId ' + communityId);
        System.debug('TrendingArticlesController: retrieveConfig: taConfig ' + taConfig);
        System.debug('articles list');
        System.debug(articlesList);
        TrendingArticlesResult taList = new TrendingArticlesResult();
        taList.id = componentConfigId;
        taList.componentName = componentName;
        taList.componentTitle = Label.CUST_COMMUNITY_TRENDING_ARTICLES_LABEL;
        taList.communityId = communityId;
        taList.permissionName = permissionName;
        taList.componentConfig = taConfig;
        taList.items = curatedArticlesList;
        taList.emptyDataSetMessage = Label.CUST_COMMUNITY_TRENDING_ARTICLES_EMPTY_DATASET_MESSAGE;
        boolean isComponentAdmin = false;
        if ((permissionName != null) & (!permissionName.equals(''))) {
	        isComponentAdmin = CommunityUtilities.hasPermissionSet(permissionName);                                                                
        }       
        taList.isComponentAdmin = isComponentAdmin;
        /*
        if (componentAdmin.toUpperCase().equals('YES')) {
            taList.isComponentAdmin = true;
        }
        else {
            taList.isComponentAdmin = false;
        }
        */
        return taList;

    }


    class CustomCommunityException extends Exception {}

}