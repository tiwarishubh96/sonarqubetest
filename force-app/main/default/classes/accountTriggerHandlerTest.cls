@isTest
public class accountTriggerHandlerTest{
    public static testMethod void ENHC0010766positive(){
        Integer max = 1;
        List<Account> listAccount = new List<Account>();
        List<zqu__Quote__c> listzqu_Quote = new List<zqu__Quote__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User usr = new User(Alias = 'standt', Email='standardusrjoemark@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Foundation', FirstName='Sage', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjoemark@testorg.com');
        User usrGraeme = new User(Alias = 'standt', Email='standardusrjoemark@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Houghton', FirstName='Graeme', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='HoughtonGraeme@testorg.com');
       	for(integer integr = 0; integr < max; integr++){
            Account accountnewAccount = new Account();
            accountnewAccount.Name = 'accountnewAccount.Name' + integr;
            listAccount.add(accountnewAccount);
        }
        insert listAccount;
        for(integer integr = 0; integr < max; integr++){
            zqu__Quote__c zqu_Quote = new zqu__Quote__c();
            zqu_Quote.zqu__Account__c = listAccount[integr].Id;
            listzqu_Quote.add(zqu_Quote);
        }
        insert listzqu_Quote;
        //Query for Sage Foundation user, change made to fix the test  
        //system.runas(usr){
        User sageFouUsr = [SELECT FirstName, Id, LastName FROM User WHERE FirstName =: 'Sage' AND LastName =: 'Foundation'];
        system.runas(sageFouUsr){
            for(Account forAccount: listAccount){
                forAccount.OwnerId = sageFouUsr.Id;
            }
            update listAccount;
        }
        User userUser = [SELECT Id FROM User WHERE LastName='Houghton' AND FirstName='Graeme'];
        for(zqu__Quote__c zqu_Quote: [SELECT OwnerId FROM zqu__Quote__c WHERE zqu__Account__c IN: listAccount]){
            system.assertEquals(zqu_Quote.OwnerId, userUser.Id);
        }
    }
}