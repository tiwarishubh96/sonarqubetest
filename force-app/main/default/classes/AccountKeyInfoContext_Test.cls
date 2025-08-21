@isTest
public with sharing class AccountKeyInfoContext_Test {
    
    @isTest 
    public static void testCreateInstance_NoConfigError() {
        try{
            AccountKeyInfoContext context =  AccountKeyInfoContext.getInstance('NOCONFID');
            //shouldn't get here so force a failure
            System.assert(context==null,'Should have errored' + context);
        }catch(AccountKeyInfoContext.AccountKeyInfoContextException error){
            System.assertEquals(error.getMessage(),'No Configuration found - contact your administrator',error);
        }
    }
    @isTest 
    public static void testCreateInstance_ConfigFound() {
        Key_Info_Service__mdt dummy = new Key_Info_Service__mdt(MasterLabel='Account', Key_Service_Classes__c='DummySvc', Object_Name__c='Account');
        AccountKeyInfoContext.keyInfoConfig = dummy;
        try{
            AccountKeyInfoContext context =  AccountKeyInfoContext.getInstance('Account');
            //shouldn't get here so force a failure
            System.assert(context != null,'Should have loaded the context and services');
            System.assert(context.keyServices != null, 'key services map should have been loaded');
        }catch(AccountKeyInfoContext.AccountKeyInfoContextException error){
            System.assert(false,'should not have errored on load');
        }
    }

   @isTest 
    public static void testgetKeyInfo() {
        Key_Info_Service__mdt dummy = new Key_Info_Service__mdt(MasterLabel='DummySvc', Key_Service_Classes__c='AccountKIDummySvc', Object_Name__c='Account');
        AccountKeyInfoContext.keyInfoConfig = dummy;
        try{
            AccountKeyInfoContext context =  AccountKeyInfoContext.getInstance('Dummy');
            //shouldn't get here so force a failure
            System.assert(context != null,'Should have loaded the context and services');
            System.assert(context.keyServices != null, 'key services map should have been loaded');

            List<AccountKeyInfoWrapper> results = context.getKeyInfo('0019E000010LxfwQAC');
            System.assert(results != null,'Should have returned some results');
            System.assertEquals(2,results.size(),'Should have returned 2 infos but returned ' + results.size());
        }catch(AccountKeyInfoContext.AccountKeyInfoContextException error){
            System.assert(false,'should not have errored on load');
        }
    }    



}