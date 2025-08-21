@isTest
public class PartnerActivationEmailHandler_Test{
    
    public static testMethod void activationEmailHandlerTest(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Type = 'Partner';
        acc.phone = '1779094738';
        acc.Sales_Office__c = 'Atlanta CBC';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.LastName = 'Yalamati';
        con.Email = 'Ravi@gmail.com';
        con.invite_user_to_Partner_Community__c = false;
        insert con;
        
        List<Id> lstId = new List<Id>();
        lstId.add(acc.id);
        
        PartnerActivationEmailHandler.ActivationEmailHandler(lstId);
    }
}