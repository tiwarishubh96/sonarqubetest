public class DataCategoryModel {
    
 

    	@AuraEnabled
        public String dataCategoryName;
        
    	@AuraEnabled
        public String dataCategoryLabel;

    	@AuraEnabled
        public Boolean hasChildCategories;
        
        @AuraEnabled
        public List<DataCategoryModel> childCategories; 
        

}