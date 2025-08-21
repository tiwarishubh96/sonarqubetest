public with sharing class AccountKIPartnerSvcImpl extends AccountKIBaseSvc{

    //Used to help test when using External Objects
    @TestVisible 
    private static List<VW_Connect_AccountPartner__x> mockInformation = new List<VW_Connect_AccountPartner__x>();

    public List<AccountKeyInfoWrapper> getKeyData(String recordId) {
        
        List<AccountKeyInfoWrapper> keyDataItems = new List<AccountKeyInfoWrapper>();
        List<VW_Connect_AccountPartner__x> partnerInfo;

        if(Test.isRunningTest()){
            partnerInfo = mockInformation;
        }else{
            try{
                partnerInfo = [SELECT PartnerAccountID__c,SalesforceAccountId__c,SerialNumber__c 
                            From VW_Connect_AccountPartner__x where SalesforceAccountId__c = :recordId];
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, e);
                //don't show the error
            }

        }
        
        System.debug('Account Partner info : ' + partnerInfo);
        if(partnerInfo != null && partnerInfo.size() > 0){
                keyDataItems.add(new AccountKeyInfoWrapper(PARTNER_TYPE,new String[]{partnerInfo[0].PartnerAccountID__c},1));
            }
        return keyDataItems;    
    }
}