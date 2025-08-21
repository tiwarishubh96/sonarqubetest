/**
* Test calss for AccountKIDummySvcImpl
*
*/ 
@isTest
public with sharing class AccountKIDummySvcImpl_Test {
    
    @isTest
    public static void testGetKeyInfo(){
        AccountKIDummySvcImpl service = new AccountKIDummySvcImpl();
        List<AccountKeyInfoWrapper> results = service.getKeyData('0019E000010LxfwQAC');
        System.assert(results != null,'Should have returned some results');
    }

}