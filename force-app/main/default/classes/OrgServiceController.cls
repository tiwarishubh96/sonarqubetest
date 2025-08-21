public with sharing class OrgServiceController {
    
    /* Screen constructs */
    public class UserItem {
        @AuraEnabled public String FirstName; 
        @AuraEnabled public String LastName; 
        @AuraEnabled public String Email;
        @AuraEnabled public String Id;
    }

    public class ScreenData {
        @AuraEnabled public List<UserItem> items = new List<UserItem>();
        @AuraEnabled public String businessId;
        @AuraEnabled public String state; 
        @AuraEnabled public String errorMessage;         
    }    

    @AuraEnabled
    public static ScreenData fetchData(String recordId){
        String businessId;
        System.debug('RecordId = ' + recordId);
        String soqlQuery = String.escapeSingleQuotes('SELECT Id,BusinessId__c FROM Business__c where id = :recordId LIMIT 1');
        SObject businessSObject = Database.query(soqlQuery);
        if(businessSObject != null){
            businessId = (String)businessSObject.get('BusinessId__c');
        }
        if(String.isBlank(businessId)){
            throw new AuraHandledException('Unable to find Business id');
        }

        ScreenData sd = new ScreenData();
        sd.businessId = businessId;

        try {
            
            orgdata_IBusinessRequest request = new orgdata_BusinessRequest(businessId,true);
            GenericServiceInvoker invoker = new GenericServiceInvoker('OrgServiceProxyV1_Users');
            orgdata_IGetUsersResponse output = (orgdata_IGetUsersResponse)invoker.call(request);
            List<orgdata_IUser> users = output.getUsers();
            for(orgdata_IUser u:users){
                UserItem ui = new UserItem();
                ui.Email = u.getEmail();
                ui.FirstName = u.getFirstName();
                ui.LastName = u.getLastName();
                ui.Id = u.getUserId();
                sd.items.add(ui);
            }
            sd.state = 'SUCCESS';
            
        } catch (Exception e) {
            sd.state = 'FAILURE';
            sd.errorMessage = e.getMessage();            
            //throw new AuraHandledException(e.getMessage());
        }
        return sd;
    }
}