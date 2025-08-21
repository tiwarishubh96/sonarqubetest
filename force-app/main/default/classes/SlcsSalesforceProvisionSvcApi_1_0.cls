/*
    Pathtitle:  Sage Provisioning Service API
    Description: Initially designed for Sage Business Cloud for LMA
*/

@RestResource(urlMapping='/api/1.0/slcs/ps/user/*')
global with sharing class SlcsSalesforceProvisionSvcApi_1_0
{
    /*
        Description:  Validates if a given username exists      
        verb: POST
        input: username
        output: true/false
    */
    @HttpPost
    global static Boolean DoPost(String username)
    {
        Boolean isDuplicated = true;
        try
        {
            isDuplicated = existsName(username);
            system.debug('DoPost - username duplicated is: ' + isDuplicated);
        }
        catch (Exception ex) {
            system.debug('DoPost - Exception raised');
            system.debug(ex.getStackTraceString());
            RestContext.response.statusCode =  400;
        }
        return isDuplicated;        
    }

    private static Boolean existsName(String username) {
        Boolean result = false;

        User user = new User();  
        user.FirstName = 'any';
        user.LastName = 'any';
        user.Alias = 'any';
        user.EMail = 'any@email.com';
        user.Username = username;
        user.CommunityNickname = username;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.ProfileId = [SELECT Id, Name FROM Profile WHERE Name='Standard User' limit 1].Id;

        Savepoint sp = Database.setSavepoint();

        try {
            insert user;
        }
        catch(DmlException ex) {
            if(ex.getDmlStatusCode(0) == String.valueOf(StatusCode.DUPLICATE_USERNAME)) {
                result = true; 
            } else {
                system.debug('existsName - ex.getDmlStatusCode returns not duplicated username ' + ex.getDmlStatusCode(0));
                system.debug(ex.getStackTraceString());
            }
        }
        finally {
            Database.rollback(sp);
        }

        return result;
    }
}