/**
* @author cjbradshaw
* @date Jun 2019
* @description Service supporting AccountKeyInfo LEX component CCORE-1714
* Looks for teh precense of a prompt records belonging to an account
*/
public with sharing class AccountKIPromptSvcImpl extends AccountKIBaseSvc{



    //Used to help test when using External Objects
    @TestVisible 
    private static List<VW_Connect_AccountPrompt__x> mockInformation = new List<VW_Connect_AccountPrompt__x>();


    public List<AccountKeyInfoWrapper> getKeyData(String recordId) {
        List<AccountKeyInfoWrapper> keyDataItems = new List<AccountKeyInfoWrapper>();

        List<VW_Connect_AccountPrompt__x> promptInfo;

        if(Test.isRunningTest()){
            promptInfo = mockInformation;
        }else{        
            promptInfo = [SELECT PromptText__c,PromptType__c 
                From VW_Connect_AccountPrompt__x where SalesforceAccountId__c = :recordId];
        }
        System.debug('Account Prompt info : ' + promptInfo);
        if(promptInfo != null && promptInfo.size() > 0){
                keyDataItems.add(new AccountKeyInfoWrapper(PROMPT_TYPE,new String[]{promptInfo[0].PromptText__c,promptInfo[0].PromptType__c},1));
        }
        return keyDataItems;            
    }
}