/**
 * Created by Craig.Bradshaw on 15/03/2019.
 */

public with sharing class AccountKICustInteractionSvcImpl extends AccountKIBaseSvc{


    //Used to help test when using External Objects
    @TestVisible 
    private static List<VW_Connect_CustomerInteraction__x> mockInformation = new List<VW_Connect_CustomerInteraction__x>();    

    public List<AccountKeyInfoWrapper> getKeyData(String recordId) {
        List<AccountKeyInfoWrapper> keyDataItems = new List<AccountKeyInfoWrapper>();
        
        List<VW_Connect_CustomerInteraction__x> interactions;
        
        if(Test.isRunningTest()){
            interactions = mockInformation;
        }else{
            try{
            //Have to split the queries becuase oData connector re-writes this (In IICS) into crap SQL
            interactions = new List<VW_Connect_CustomerInteraction__x>();
            interactions =
                [SELECT AccountID__c, ContactName__c, InteractionDate__c,InteractionCategory__c
                        From VW_Connect_CustomerInteraction__x where InteractionCategory__c = 'Complaint'
                        AND SalesforceAccountId__c = :recordId LIMIT 1];
            interactions.addAll([SELECT AccountID__c, ContactName__c, InteractionDate__c,InteractionCategory__c
                        From VW_Connect_CustomerInteraction__x where InteractionCategory__c = 'Case'
                        AND SalesforceAccountId__c = :recordId LIMIT 1] );  
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, 'Eror fetching VW_Connect_CustomerInteraction__x ->' + e);
                //don't show the error
            }

                      
        }

        if(interactions != null && interactions.size() > 0){
            for(VW_Connect_CustomerInteraction__x ci:interactions){
                keyDataItems.add(new AccountKeyInfoWrapper(COMPLAINT_TYPE,
                        new String[]{'Date : ' + ci.InteractionDate__c,'Contact Name : ' + ci.ContactName__c},
                        1));
            }
        }
        return keyDataItems;
    }
}