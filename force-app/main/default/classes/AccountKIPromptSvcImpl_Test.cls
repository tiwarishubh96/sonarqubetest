/**
* @author cjbradshaw
* @date Jun 2019
* @description Test Calss for Service supporting AccountKeyInfo LEX component CCORE-1714
*/
@isTest
public with sharing class AccountKIPromptSvcImpl_Test {
    @isTest
    public static void testGetKeyInfo() {
        VW_Connect_AccountPrompt__x mockInformation = new VW_Connect_AccountPrompt__x(
            PromptText__c='Prompt Text',PromptType__c='Prompt Type',SalesforceAccountId__c='0019E000010LxfwQAC');

        AccountKIPromptSvcImpl.mockInformation.add(mockInformation);
        Test.startTest();
            AccountKIPromptSvcImpl service = new AccountKIPromptSvcImpl();

            List<AccountKeyInfoWrapper> keyInfoResults = service.getKeyData('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(1, keyInfoResults.size(),'Should have returned 1 record');
    
    }
}