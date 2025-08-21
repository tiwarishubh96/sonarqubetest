@isTest
private class KnowledgeHelperTest
{
	@isTest
	static void getTrendingArticlesByTopicTest()
	{
		// Given
		ConnectApi.KnowledgeArticleVersionCollection testArt = new ConnectApi.KnowledgeArticleVersionCollection();
        //List<ConnectApi.KnowledgeArticleVersion> testItemList;

        List<ConnectApi.KnowledgeArticleVersion> taArticles = new List<ConnectApi.KnowledgeArticleVersion>();
        taArticles.add(new ConnectApi.KnowledgeArticleVersion());
        taArticles.add(new ConnectApi.KnowledgeArticleVersion());
        testArt.items = taArticles;

		Topic t = new Topic(name='TestTopic');
		insert t;

		Id commId = [SELECT id, name FROM Network limit 1].id;

		ConnectApi.Knowledge.setTestGetTrendingArticlesForTopic
		(commId,t.Id,1,testArt);

		// When
		KnowledgeHelper knowleHelp =new KnowledgeHelper();
		List<ConnectApi.KnowledgeArticleVersion> taArticlesRes 
		= KnowledgeHelper.getTrendingArticlesByTopic(commId, t.Id, 1);

		System.assertEquals(taArticlesRes.size(),2);
		// Then

	}
    
    @isTest
    static void testGetArticlesByDataCategories() {
        // Given
		ConnectApi.KnowledgeArticleVersionCollection testArt = new ConnectApi.KnowledgeArticleVersionCollection();

        List<ConnectApi.KnowledgeArticleVersion> taArticles = new List<ConnectApi.KnowledgeArticleVersion>();
        taArticles.add(new ConnectApi.KnowledgeArticleVersion());
        taArticles.add(new ConnectApi.KnowledgeArticleVersion());
        testArt.items = taArticles;

		Topic t = new Topic(name='TestTopic');
		insert t;

		Id commId = [SELECT id, name FROM Network limit 1].id;

		ConnectApi.Knowledge.setTestGetTrendingArticlesForTopic
		(commId,t.Id,1,testArt);
        
        List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>();
        kavList = KnowledgeHelper.getArticlesByDataCategories('en_US', '');
        System.debug('kavList : '+kavList);
    }
    
    @isTest
    static void testGetDataCategoryValues() {
        
        List<DataCategoryGroupSobjectTypePair> kdcGroups = KnowledgeHelper.getAllKnowledgeDataCategoryGroups();
        DataCategoryGroupSobjectTypePair kdcPair = kdcGroups[0];
        
        String kdcGroupName = kdcPair.getDataCategoryGroupName();
        String kdcSObject = kdcPair.getSobject();

        DataCategoryGroupModel dcgModel = KnowledgeHelper.getDataCategoryValues(kdcSObject, kdcGroupName);
         system.debug('dcgModel ::'+dcgModel);

        System.assertNotEquals(null, dcgModel);
    }
    
    //Testing Exception for getDataCategoryValues
     @isTest
    static void testGetDataCategoryValuesError() {
      
        try{
        	DataCategoryGroupModel dcgModel = KnowledgeHelper.getDataCategoryValues('KnowledgeArticleVersion', 'as'); 

        }
        catch(Exception ex)
        {
            System.debug('Error');
        }
        
    }
}