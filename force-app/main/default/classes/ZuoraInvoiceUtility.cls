public with sharing class ZuoraInvoiceUtility {

    // Developer name of the custom permission Mana
    public static final String MANAGE_SUBSCRIPTION_PERMISSION = 'Manage_Subscriptions';
    // Error message shown when the user does not have the right permission to see the invoices
    public static final String NO_PERMISSION_ERROR = Label.CustComm_Subscription_No_Permission_Error;
    // This variable if used for returning a value when querying Zuora
    @TestVisible private static Zuora.zObject testZObject;

    /**
    *  Method to get the Invoices that the User has access to
    *  @author Salesforce Services
    *  @param fieldNames are the name of the fields to retrieve from the query
    *  @param sortField is the field used in the Order By clause
    *  @param queryLimit is the number used in the Limit clause
    *  @return List of invoices that the User has access to
    **/
    @AuraEnabled
    public static List<sObject> getInvoices(List<String> fieldNames, String sortField, String queryLimit) {
        List<sObject> invoices = new List<sObject>();
        Boolean hasManageSubscriptionPermission = CommunityUtilities.hasPermission(MANAGE_SUBSCRIPTION_PERMISSION);
        if (hasManageSubscriptionPermission){
            // Set that contains the datatypes that we should format
            Set<Schema.DisplayType> datatypesToFormat = new Set<Schema.DisplayType>{Schema.DisplayType.Date, Schema.DisplayType.DateTime, Schema.DisplayType.Currency};
            // Get the describe sObject for Zuora__ZInvoice__c
            String invoiceObject = 'Zuora__ZInvoice__c';
            Map<String, Schema.SobjectField> invoiceFields = Schema.getGlobalDescribe().get(invoiceObject).getDescribe().fields.getMap();
            String fields = '';
            for (String fieldName : fieldNames) {
                // Check if it's a valid field
                if (invoiceFields.get(fieldName) != null){
                    // Check the datatype of the field
                    Schema.DisplayType fieldDataType = invoiceFields.get(fieldName).getDescribe().getType();
                    if (datatypesToFormat.contains(fieldDataType)){
                        // Enclose the field using FORMAT() to return dates and currencies on the appropriate locale
                        fieldName = GenericUtilities.enclose('FORMAT(', ')', fieldName);
                    }
                    if (fields == '') {
                        fields += fieldName;
                    } else {
                        fields += ',' + fieldName;
                    }
                }
            }
            // Get the invoices
            if(queryLimit != '-1'){
                invoices = Database.query('SELECT ' + fields + ' FROM ' + invoiceObject + ' ORDER BY ' + sortField + ' LIMIT ' + queryLimit);
            }else{
               invoices = Database.query('SELECT ' + fields + ' FROM ' + invoiceObject + ' ORDER BY ' + sortField); 
            }
            
        } else {
            throw new AuraHandledException(NO_PERMISSION_ERROR);
        }
        return invoices;
    }

    /**
    *  Method to retrieve the Invoice pdf Attachment Id
    *  @author Salesforce Services
    *  @param invoiceId is the Zuora Id of the Invoice
    *  @return Id of the attachment that holds the invoice pdf
    **/
    @AuraEnabled
    public static String getInvoiceBody(String invoiceId) {
        String result = null;
        // Name of the attachment that will have the invoice pdf
        String invoiceAttachmentName = 'invoice-' + invoiceId + '.pdf';
        // Query the Invoice and its related attachments to see if the invoice pdf was already retrieved from Zuora
        String query = 'SELECT Id, (SELECT Id FROM Attachments WHERE Name = \'' + invoiceAttachmentName + '\')';
        query += 'FROM Zuora__ZInvoice__c WHERE Zuora__Zuora_Id__c = \'' + invoiceId + '\'';
        List<sObject> invoices = Database.query(query);
        if (invoices.size() > 0) {
            if (invoices[0].getSObjects('Attachments') == null || invoices[0].getSObjects('Attachments').isEmpty()){
                List<Zuora.zObject> resultRecords = new List<Zuora.zObject>();
                // Generate the Zuora query
                String zoql = 'SELECT Id, Body FROM Invoice WHERE Id = \'' + invoiceId + '\'';
                Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
                qr.zoql = zoql;

                if (!Test.IsRunningTest()){
                    Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraInvoiceUtility');
                    Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(qr);
                    resultRecords = queryResult.records;
                } else {
                    // Add the test object when running tests
                    resultRecords.add(testZObject);
                }
                for (Zuora.zObject z : resultRecords) {
                    String resultBody = (String) z.getValue('Body');
                    result = GenericUtilities.createBase64Attachment(invoiceAttachmentName, resultBody, 'application/pdf', invoices[0].Id);
                }
            } else {
                result = invoices[0].getSObjects('Attachments')[0].Id;
            }
        }
        return result;
    }

    @AuraEnabled
    public static Boolean hasPermissionForInvoices() {
        Boolean sage_one_check=false;
        Boolean sage_live_check=false;
        Boolean sage_one_try_now=false;
        Boolean sage_live_try_now=false;
        String product_name;
        Id usrId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:usrId];
        List<Subscription_Master__c> activities = [SELECT Id,Product__c FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Status__c = 'Trial'];
        List<Zuora__ZInvoice__c> invoicesList = [SELECT Id FROM Zuora__ZInvoice__c where Zuora__Account__c=:u.AccountId];
        if (activities.size() > 0) {
            return false;
        }
        else if(invoicesList.size()<1)
            return false;
        else
            return true;
    }

    @AuraEnabled
    public static boolean hasPermissionSet(String name) {

        List<CustomPermission> customPermissions =
            [SELECT Id, DeveloperName
             FROM CustomPermission
             WHERE DeveloperName = :name];

        System.debug('***********' + customPermissions);
        if (customPermissions.size() > 0) {

            List<Id> customPermissionSetIds = new List<Id>();
            for (CustomPermission p : customPermissions) {
                customPermissionSetIds.add(p.Id);
            }

            System.debug('***********' + customPermissionSetIds);

            List<SetupEntityAccess> setupEntities =
                [SELECT SetupEntityId
                 FROM SetupEntityAccess
                 WHERE SetupEntityId in :customPermissionSetIds AND
                 ParentId IN (SELECT PermissionSetId
                              FROM PermissionSetAssignment
                              WHERE AssigneeId = :UserInfo.getUserId())];

            if (setupEntities.size() > 0) {
                return true;

            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}