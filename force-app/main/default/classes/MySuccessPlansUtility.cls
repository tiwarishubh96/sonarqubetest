public without sharing class MySuccessPlansUtility {
    
    public static final String NO_PERMISSION_ERROR = Label.CustComm_Subscription_No_Permission_Error;

    @AuraEnabled
    public static List<sObject> getSuccessPlans(List<String> fieldNames, String sortField, String queryLimit) {
        List<sObject> successplans = new List<sObject>();
        Boolean hasSuccessPlansPermission = CommunityUtilities.hasPermissionForSuccessPlans();
        if(hasSuccessPlansPermission) {
            Id usrId = UserInfo.getUserId();
            User u = [select Id,Name,AccountId from User where Id=:usrId];
            
            Set<Schema.DisplayType> datatypesToFormat = new Set<Schema.DisplayType>{Schema.DisplayType.Date, Schema.DisplayType.DateTime, Schema.DisplayType.Currency};
            // Get the describe sObject for Success_Plan__c
            String successplanObject = 'Success_Plan__c';
            Map<String, Schema.SobjectField> successplanFields = Schema.getGlobalDescribe().get(successplanObject).getDescribe().fields.getMap();
            String fields = '';

            for (String fieldName : fieldNames) {
                // Check if it's a valid field
                if (successplanFields.get(fieldName) != null){
                    // Check the datatype of the field
                    Schema.DisplayType fieldDataType = successplanFields.get(fieldName).getDescribe().getType();
                    if (datatypesToFormat.contains(fieldDataType)){
                        // Enclose the field using FORMAT() to return dates and currencies on the appropriate locale
                        fieldName = GenericUtilities.enclose('FORMAT(', ')', fieldName);
                    }
                    if(fieldName.equals('Status__c'))
                        fieldName = 'toLabel(Status__c)';
                    if(fieldName.equals('Type__c'))
                        fieldName = 'toLabel(Type__c)';
                    if (fields == '') {
                            fields += fieldName;
                    }else {
                        fields += ',' + fieldName;
                    }
                }
            }
            // Get the invoices
            successplans = Database.query('SELECT Id,' + fields + ' FROM ' + successplanObject +' where Account__c='+'\''+u.AccountId+'\''+ ' ORDER BY ' + sortField + ' LIMIT ' + queryLimit);
            system.debug('****************' + successplans);
            return successplans;
        }
        else  {
            throw new AuraHandledException(NO_PERMISSION_ERROR);
        }
    }
    
    @AuraEnabled
    public static Boolean hasPermissionForSuccessPlans() {
        /*Check for Sage Live Customer*/
        String product_name;
        Boolean sage_live_check = false;
        Id usrId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:usrId];
        List<Success_Plan__c> successplans = [select Id from Success_Plan__c where Account__c=:u.AccountId];
        if(successplans.size()>0)
            sage_live_check=true;
        /*End of check*/
        
        return sage_live_check;
    }

    @AuraEnabled
    public static Id getSuccessPlanBody(String name) {
        Success_Plan__c splanId = [SELECT Id FROM Success_Plan__c where Name=:name];

        return splanId.Id;
    }
}