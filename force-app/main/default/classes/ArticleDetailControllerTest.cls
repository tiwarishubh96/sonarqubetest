@isTest
private class ArticleDetailControllerTest
{
	//Inserting Required test data
 	@testSetup
	static void dataSetup() {
		//Knowledge Article Version test records inserted using Knowledge_Article__kav object
	Knowledge_Article__kav kak = new Knowledge_Article__kav(
        Title = 'test apex',
        Summary = 'test from apex',
        Language = 'en_US',
        URLName = 'test2'
    );

    insert kak;

    //Assigning parent id for Knowledge_Article__DataCategorySelection
	Id parentid = kak.id;
	String urlName = kak.URLName;
	//Fetching KnowledgeArticleId from article version

	kak = [SELECT KnowledgeArticleId FROM Knowledge_Article__kav WHERE Id = :kak.Id];

	//Publishing Knowledge Article Version to make publishStatus = Online
	KbManagement.PublishingService.publishArticle(kak.KnowledgeArticleId, true);
	

	//Getting data from DataCatagorySelection based on SObject Knowledge Article Version
	DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(
    new String[] { 'KnowledgeArticleVersion'} );

	system.debug(results + ' hell   '+ results[0].getName() +'Test : '+results[1].getName()+'Test : '+results[2].getName());
 		//RegionTest : ProductsTest : Partner_Type
	// Inserting 3 Test Knowlege Article DatacatagorySelection
	Knowledge_Article__DataCategorySelection knowArticleDataCat = new Knowledge_Article__DataCategorySelection(
		ParentId = parentid , DataCategoryGroupName = results[0].getName() ,DataCategoryName = 'United_States');

    Knowledge_Article__DataCategorySelection knowArticleDataCat1 = new Knowledge_Article__DataCategorySelection(
        ParentId = parentid , DataCategoryGroupName = results[1].getName() ,DataCategoryName = 'Sage_One');
    /*
    Knowledge_Article__DataCategorySelection knowArticleDataCat2 = new Knowledge_Article__DataCategorySelection(
        ParentId = parentid , DataCategoryGroupName = results[1].getName() ,DataCategoryName = 'Standard');
*/
	List<Knowledge_Article__DataCategorySelection> listKAD =new List<Knowledge_Article__DataCategorySelection>();
	listKAD.add(knowArticleDataCat);
	listKAD.add(knowArticleDataCat1);
	//listKAD.add(knowArticleDataCat2);
	insert listKAD;

	//Create Test User
 	
 		//Profile Id

        Id prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
        
Map<String,object> userAttributesForRecords = new Map<String,object>();
        userAttributesForRecords.put('ProfileId',prof);
        userAttributesForRecords.put( 'LastName','testUser');
        userAttributesForRecords.put('CommunityNickname','testnick');
        userAttributesForRecords.put('Email','testUser@test.com');

        userAttributesForRecords.put('Username','testUser@test.com' + System.currentTimeMillis());
        userAttributesForRecords.put( 'Alias','alias');
        
        userAttributesForRecords.put('TimeZoneSidKey','America/Los_Angeles');

        userAttributesForRecords.put('EmailEncodingKey','UTF-8');
        userAttributesForRecords.put( 'LanguageLocaleKey','en_US');
        userAttributesForRecords.put('LocaleSidKey','en_US');
        userAttributesForRecords.put('UserPermissionsKnowledgeUser',true);
        TestDataUtility.createSobject(1, true, userAttributesForRecords, 'User');

	
}



	/*
	*Method to Test getArticleCategories Method from ArticleDetailController Class.
	*
	**/

@isTest
static void itShould()
{

	User u = [Select Id , name FROM User WHERE Email='testUser@test.com'];
	String urlName = [SELECT Id,urlName from Knowledge_Article__kav WHERE publishStatus = 'Online' and Language = 'en_US'].urlName;
	// When

	test.startTest();
 	System.RunAs(u){
	//Calling Method from class and Passing Parameters.
	List<DataCategoryWrapper> articleCata = ArticleDetailController.getArticleCategories(urlName);	
	System.debug(articleCata);

	System.assertEquals(articleCata.size(),2);
	}

	test.stopTest();
	// Then
}//End of Test Method

}