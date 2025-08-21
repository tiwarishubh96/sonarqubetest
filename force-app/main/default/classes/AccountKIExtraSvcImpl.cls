/**
* @author cjbradshaw
* Home = 1, Export = 0
* @date Jun 2019
* @description KeyInformation Service that pulls Account Extra view data for an account CCORE-1714
*/

public with sharing class AccountKIExtraSvcImpl extends AccountKIBaseSvc{

    //Used to help test when using External Objects
    @TestVisible
    private static List<VW_Connect_AccountExtra__x> mockInformation = new List<VW_Connect_AccountExtra__x>();


    /**
    * @author cjbradshaw
    * @date Jun 2019
    * @description Returns any KeyInfo relating to AccountExtra External Object
    * @return List<AccountKeyInfoWrapper>
    */
    public List<AccountKeyInfoWrapper> getKeyData(String recordId) {
        List<AccountKeyInfoWrapper> keyDataItems = new List<AccountKeyInfoWrapper>();
        List<VW_Connect_AccountExtra__x> extraInformation;

        if(Test.isRunningTest()){
            extraInformation = mockInformation;
        }else{
            extraInformation = [SELECT CreditStatus__c, AccountPassword__c, HomeOrExport__c From VW_Connect_AccountExtra__x where SalesforceAccountId__c = :recordId LIMIT 1];
        }


        System.debug('Account Extra info : ' + extraInformation);
        if(extraInformation != null && !extraInformation.isEmpty()){
            if(extraInformation[0].CreditStatus__c != null){
                keyDataItems.add(new AccountKeyInfoWrapper(CREDIT_TYPE,new String[]{extraInformation[0].CreditStatus__c},1));
            }
            if(extraInformation[0].AccountPassword__c !=null){
                keyDataItems.add(new AccountKeyInfoWrapper(PASSWORD_TYPE,new String[]{extraInformation[0].AccountPassword__c},1));
            }
            if(extraInformation[0].HomeOrExport__c == false){
                keyDataItems.add(new AccountKeyInfoWrapper(EXPORT_TYPE,new String[]{''},1));
            }
        }
        return keyDataItems;
    }
}