public class DataCategoryGroupModel {

        @AuraEnabled 
        public String sObjectName;        

    	@AuraEnabled 
        public String dataCategoryGroupName;        
        
    	@AuraEnabled 
        public String dataCategoryGroupLabel;        

        @AuraEnabled 
        public String dataCategoryGroupDescription;        

    	@AuraEnabled 
        public List<DataCategoryModel> dataCategories;        

}