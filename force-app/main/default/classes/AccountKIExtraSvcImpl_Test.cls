/**
* @author cjbradshaw
* @date Jun 2019
* @description Test Calss for Service supporting AccountKeyInfo LEX component CCORE-1714
*/
@isTest
public with sharing class AccountKIExtraSvcImpl_Test {
    
    @isTest
    public static void testGetKeyInfo_Home() {
        VW_Connect_AccountExtra__x mockInformation = new VW_Connect_AccountExtra__x(
            CreditStatus__c='Good', AccountPassword__c='frankSample', HomeOrExport__c=true,SalesforceAccountId__c='0019E000010LxfwQAC');

        AccountKIExtraSvcImpl.mockInformation.add(mockInformation);
        Test.startTest();
            AccountKIExtraSvcImpl service = new AccountKIExtraSvcImpl();

            List<AccountKeyInfoWrapper> accountExtraKeyInfo = service.getKeyData('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(2, accountExtraKeyInfo.size(),'Should have returned 2 records');
    
    }

    @isTest
    public static void testGetKeyInfo_Export() {
        VW_Connect_AccountExtra__x mockInformation = new VW_Connect_AccountExtra__x(
            CreditStatus__c='Good', AccountPassword__c='frankSample', HomeOrExport__c=false,SalesforceAccountId__c='0019E000010LxfwQAC');

        AccountKIExtraSvcImpl.mockInformation.add(mockInformation);
        Test.startTest();
            AccountKIExtraSvcImpl service = new AccountKIExtraSvcImpl();

            List<AccountKeyInfoWrapper> accountExtraKeyInfo = service.getKeyData('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(3, accountExtraKeyInfo.size(),'Should have returned 3 records');
    
    }    
}