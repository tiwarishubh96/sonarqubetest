@istest
private class GuidUtilTest{
    static testmethod void Test1(){
        Account ac = new Account();
        ac.Name = 'testAccount';
        ac.RecordType = [select Id from RecordType where Name = 'Partner Account' and SobjectType = 'Account'];
        insert ac;
         
        Bulk_License__c bl = new Bulk_License__c();
        bl.account__c=ac.id;        
        insert bl;
    }
}