public class KnowledgeHelper {
    
	/*
	 * Method to retrieve a list of Trending Articles associated with a given Topic.
	 * Topics referred here are typically Navigational Topics setup in Communities.
	 */     
    public static List<ConnectApi.KnowledgeArticleVersion> getTrendingArticlesByTopic(String communityId, String topicId, Integer maxResults) {
        System.debug('KnowledgeHelper: trending articles by topic: communityId ' + communityId + ', topic id ' + topicId);
        ConnectApi.KnowledgeArticleVersionCollection taColl = ConnectApi.Knowledge.getTrendingArticlesForTopic(communityId, topicId, maxResults);
    	List<ConnectApi.KnowledgeArticleVersion> taArticles = taColl.items;        
        return taArticles;
    }
    
	/*
	 * Method to retrieve a list of Trending Articles associated with a given Topic.
	 * Topics referred here are typically Navigational Topics setup in Communities.
	 */     
    public static List<KnowledgeArticleVersion> getArticlesByDataCategories(String languageLocaleCode, String dataCategorySoql) {
        String articleQuery = 'SELECT Id, KnowledgeArticleId, ArticleType, Title, UrlName FROM KnowledgeArticleVersion ';
        articleQuery += ' WHERE publishstatus=\'Online\'';
        articleQuery += ' and Language = \'';
        articleQuery += languageLocaleCode;
        articleQuery += '\' ';
        articleQuery += dataCategorySoql;
        //'WITH DATA CATEGORY Products__c AT (Standard1__c, Essentials__c)'
                
        System.debug('KnowledgeHelper: getArticlesByDataCategories: articleQuery ' + articleQuery);
        
        List<KnowledgeArticleVersion> kavList = Database.query(articleQuery);

        return kavList;
    }

    /*
     * Method to retrieve a list of Data Category Groups setup in Knowledge
     */ 
	public static List<DataCategoryGroupSobjectTypePair> getAllKnowledgeDataCategoryGroups() {        
         //Making the call to the describeDataCategoryGroups to
         //get the list of category groups associated
         List<String> objType = new List<String>();
         objType.add(TYPE_KNOWLEDGE_ARTICLE_VERSION);

         List<DescribeDataCategoryGroupResult>  describeCategoryResult = Schema.describeDataCategoryGroups(objType);
         //Creating a list of pair objects to use as a parameter
         //for the describe call
         List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
         //Looping throught the first describe result to create
         //the list of pairs for the second describe call
         for(DescribeDataCategoryGroupResult singleResult: describeCategoryResult){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            
            System.debug('Data Category Name ' + singleResult.getName());
            pairs.add(p);
         }
		return pairs;        
    }
    
    /*
     * Method to return a list of Data Category Values for a given Data Category.
     * This function recursively retrieves all values in the data category hierarchy.
     */ 
	public static DataCategoryGroupModel getDataCategoryValues(String sObjectName, String dataCategoryName) {        
       DataCategoryGroupModel dcgm = new DataCategoryGroupModel();
                
        try {
            List<DataCategoryGroupSobjectTypePair> pairs = getDataCategoryGroupType(sObjectName, dataCategoryName);
	    	List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
                System.debug('KnowledgeHelper: getDataCategoryValues: Retrieving  ' + dataCategoryName);
    	    
            List<DataCategoryModel> dcmList = new List<DataCategoryModel>();
   	     	for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            	DataCategory [] toplevelCategories = singleResult.getTopCategories();

                System.debug('KnowledgeHelper: getDataCategoryValues: Retrieving result for ' + singleResult.getName());
                dcmList = getCategoryInfo(toplevelCategories);
        		//Get name of the associated Sobject
                dcgm.sObjectName = singleResult.getSobject();
            	//Get the name of the data category group
                dcgm.dataCategoryGroupName = singleResult.getName();
            	//Get the name of the data category group
                dcgm.dataCategoryGroupLabel = singleResult.getLabel();
            	//Get the description of the data category group
                dcgm.dataCategoryGroupDescription = singleResult.getDescription();
                dcgm.dataCategories = dcmList;
                
            }
      } catch (Exception e){
          System.debug('getDataCategoryValues: Exception ' + e.getMessage());
          throw e;
      }
      return dcgm;
    }

    /*
     * Private method to create the Data Category Group Object Type.
     * Created for every Data Category Group for which Values need to be retrieved.
     */
    private static  List<DataCategoryGroupSobjectTypePair> getDataCategoryGroupType(String sObjectName, String dataCategoryName) {
		//Creating a list of pair objects to use as a parameter
        //for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        //Looping throught the first describe result to create
        //the list of pairs for the second describe call
        DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
        p.setSobject(sObjectName);
        p.setDataCategoryGroupName(dataCategoryName);
        pairs.add(p);
		return pairs;
    }

    /*
     * Returns the information for each Category in the list passed and 
     * any of their corresponding Child Categories
     */ 
    private static List<DataCategoryModel> getCategoryInfo(DataCategory[] dataCategories) {      
        List<DataCategoryModel> dcmList = new List<DataCategoryModel>();
      	for(DataCategory category : dataCategories) {

            DataCategoryModel dcm = new DataCategoryModel();
            dcm.dataCategoryName =  category.getName();
            dcm.dataCategoryLabel = category.getLabel();
            dcm.hasChildCategories = false; 
            dcm.childCategories = new List<DataCategoryModel>(); 

            DataCategory [] childCategories = category.getChildCategories();
            if ((childCategories != null) && (childCategories.size() > 0)) {
	            dcm.hasChildCategories = true; 
                dcm.childCategories = getCategoryInfo(childCategories);
            }
            
            dcmList.add(dcm);
        }
        return dcmList;                                                 
    }
    
        
	public static final String TYPE_KNOWLEDGE_ARTICLE_VERSION = 'KnowledgeArticleVersion';

}