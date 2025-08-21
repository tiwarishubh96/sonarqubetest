global class TrendingArticlesResult {
	@AuraEnabled    
    global String id;
    
    @AuraEnabled
    global String communityId;
    
    @AuraEnabled
    global String componentName;
    
    @AuraEnabled
    global String componentTitle;

    @AuraEnabled
    global String emptyDataSetMessage;

    @AuraEnabled
    public String permissionName;
          
    @AuraEnabled
    global Boolean isComponentAdmin;
    
    @AuraEnabled
    global CompConfigTrendingArticles componentConfig;
    
    @AuraEnabled
    global List<ConnectApi.KnowledgeArticleVersion> items;

}