/**
* @author cjbradshaw
* @date Jun 2019
* @description Test Calss for Service supporting AccountKeyInfo LEX component CCORE-1714
*/
@isTest
public with sharing class AccountKIPartnerSvcImpl_Test {
    
    @isTest
    public static void testGetKeyInfo() {
        VW_Connect_AccountPartner__x mockInformation = new VW_Connect_AccountPartner__x(
            PartnerAccountID__c='12345',SalesforceAccountId__c='0019E000010LxfwQAC',SerialNumber__c='ABC321');

        AccountKIPartnerSvcImpl.mockInformation.add(mockInformation);
        Test.startTest();
            AccountKIPartnerSvcImpl service = new AccountKIPartnerSvcImpl();

            List<AccountKeyInfoWrapper> keyInfoResults = service.getKeyData('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(1, keyInfoResults.size(),'Should have returned 1 record');
    
    }
}