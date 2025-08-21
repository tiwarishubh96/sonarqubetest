public with sharing class ArticleDetailController {

    /*
     * Method to retrieve Data Categories associated with the Article
     * @author
     * @return	JSON string listing Data Categories associated with the Article
     */ 
    @AuraEnabled
    public static List<DataCategoryWrapper> getArticleCategories(String articleName) {        
        //Data Categories for an Article are always stored for English
        //Translations for the English labels need to be obtained
        //Don't change this value
		String languageLocaleCode = 'en_US';

        //KnowledgeArticleVersion kav = [SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE publishstatus='Online' and Language = :languageLocaleCode and Urlname = :articleName ];
        String articleQuery = 'SELECT Id, KnowledgeArticleId, ArticleType FROM KnowledgeArticleVersion WHERE publishstatus=\'Online\'';        
        articleQuery += ' and Language = \'';
        articleQuery += languageLocaleCode;
        articleQuery += '\' and Urlname = \'';
		articleQuery += articleName + '\'';        
        System.debug('ArticleDetailController: getArticleCategories: articleQuery ' + articleQuery);
        
        KnowledgeArticleVersion kav = Database.query(articleQuery);
		String parentId = kav.Id;
        String articleType = kav.ArticleType;
        String dataCategorySource = articleType.substring(0, articleType.indexOf('__kav'));
        dataCategorySource += '__DataCategorySelection';
        
        List<KnowledgeDataCategoryWrapper> kdcList = new List<KnowledgeDataCategoryWrapper>();
        String dataCategoryQuery = 'SELECT toLabel(DataCategoryName), toLabel(DataCategoryGroupName) FROM ' + dataCategorySource + ' WHERE ParentId = \'' + parentId + '\'';
        System.debug('execute dataCategoryQuery ' + dataCategoryQuery); 

        List<sObject> kadList = Database.query(dataCategoryQuery);
        for (sObject kad : kadList) {
            String dataCategoryName = (String)kad.get('DataCategoryName');
            String dataCategoryGroupName = (String)kad.get('DataCategoryGroupName');
            DataCategoryWrapper dcw = new DataCategoryWrapper();
            dcw.DataCategoryName = dataCategoryName;
            dcw.DataCategoryGroupName = dataCategoryGroupName;
        	KnowledgeDataCategoryWrapper kdcw = new KnowledgeDataCategoryWrapper(dcw);   
            kdcList.add(kdcw);		
        }        
        kdcList.sort();
        
        String previousDataCategoryGroup = '';
        String previousDataCategory = '';
        List<DataCategoryWrapper> dataCategoryList = new List<DataCategoryWrapper>();
        for (KnowledgeDataCategoryWrapper kdcw : kdcList) {
            String dataCategoryGroup = kdcw.kdc.DataCategoryGroupName;
            String dataCategory = kdcw.kdc.DataCategoryName;
            System.debug( dataCategoryGroup + ': ' + dataCategory);
            if (!previousDataCategoryGroup.equals(dataCategoryGroup)) {
                if (!previousDataCategoryGroup.equals('')) {
                    DataCategoryWrapper dcw = new DataCategoryWrapper();
                    dcw.DataCategoryGroupName = previousDataCategoryGroup;
                    dcw.DataCategoryName = previousDataCategory;
                    dataCategoryList.add(dcw);
                }
                previousDataCategoryGroup = dataCategoryGroup;
                previousDataCategory = dataCategory;
            }
            else {
                previousDataCategory += ', ' + dataCategory;
            }
        }
        
        DataCategoryWrapper dcw = new DataCategoryWrapper();
        dcw.DataCategoryGroupName = previousDataCategoryGroup;
        dcw.DataCategoryName = previousDataCategory;
        dataCategoryList.add(dcw);
            
        return dataCategoryList;
    }    
}