/**
* @author cjbradshaw
* @date Jun 2019
* @description Test Calss for Service supporting AccountKeyInfo LEX component CCORE-1714
*/
@isTest
public with sharing class AccountKICustInteractionSvcImpl_Test {

    @isTest
    public static void testGetKeyInfo() {
        
        VW_Connect_CustomerInteraction__x mockInformation1 = new VW_Connect_CustomerInteraction__x(
            AccountID__c='12345', ContactName__c='frank1', InteractionDate__c=Date.parse('10/03/2018'),InteractionCategory__c='Case',SalesforceAccountId__c='0019E000010LxfwQAC');
        AccountKICustInteractionSvcImpl.mockInformation.add(mockInformation1);

        VW_Connect_CustomerInteraction__x mockInformation2 = new VW_Connect_CustomerInteraction__x(
            AccountID__c='876635', ContactName__c='frank2', InteractionDate__c=Date.parse('10/04/2019'),InteractionCategory__c='Complaint',SalesforceAccountId__c='0019E000010LxfwQAC');          
        AccountKICustInteractionSvcImpl.mockInformation.add(mockInformation2);
        
        Test.startTest();
            AccountKICustInteractionSvcImpl service = new AccountKICustInteractionSvcImpl();

            List<AccountKeyInfoWrapper> keyInfoResults = service.getKeyData('0019E000010LxfwQAC');
        Test.stopTest();
        System.assertEquals(2, keyInfoResults.size(),'Should have returned 2 record but had ' + keyInfoResults);
    

    }


}