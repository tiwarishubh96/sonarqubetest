public class AccountDAO implements IAccountDAO{

    public interface IAccountDAO{
        Account getAccountById(String id);
        Account getAccountByZuoraId(String zuoraId);
        List<Account> insertAccounts(List<Account> accounts);
        List<Account> updateAccounts(List<Account> accounts);
    }

    public Account getAccountById(String id){
        return [SELECT Id, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, Zuora_Id__c, Name,
        			ShippingStreet, ShippingCity, ShippingStateCode, ShippingPostalCode
        				FROM Account WHERE Id =: id];
    }

    public Account getAccountByZuoraId(String zuoraId){
        return [SELECT Id,  BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, Zuora_Id__c, Name,
        			ShippingStreet, ShippingCity, ShippingStateCode, ShippingPostalCode
        				FROM Account WHERE Zuora_Id__c =: zuoraId];
    }
    
    public List<Account> insertAccounts(List<Account> accounts) {
        insert accounts;
        return accounts;
    }

    public List<Account> updateAccounts(List<Account> accounts) {
        update accounts;
        return accounts;
    }
}