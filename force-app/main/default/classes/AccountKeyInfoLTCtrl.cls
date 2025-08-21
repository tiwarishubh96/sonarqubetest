/**
 * Aura Enabled Contoller supporting the AccountKeyInfo Component
 * @author craig.bradshaw@sage.com
 * @date May 2019
 */
public with sharing class AccountKeyInfoLTCtrl {
    
    @TestVisible
    static String accountId {get;set;}
    /**
     * fetchKeyInfo Fetch relevant data for the account
     * @param  configName  The configName of the entry in the Key_Information custom medata
     * @param  recordId  The record Id that is driving this component
     * @param  soql      For the component to work, you need to define some SOQL so that the Salesforce Account ID can be determined
     * @param  accountFieldName On the driving object - what's the account fields called 
     * @return           returns a list of key information wrapper objects
     */
    @AuraEnabled
    public static List<AccountKeyInfoWrapper> fetchKeyInfo(String configName,String recordId,String soql,String accountFieldName){
        System.debug('-- keyInfoCmp > configName = ' + configName + ' > recordId = ' + recordId + ' > soql = ' + soql + ' > accountFieldName = ' + accountFieldName);
        
		System.debug('soql : ' + soql);
        if(soql != null && soql == 'recordId'){
            System.debug('Account recordId will be used');
            accountId = recordId;
        }
        else if(soql != null & soql != ''){
            // 2020/06/30 bphan EAD-1171: prevent inject query
            //String QUERY = soql + '\'' + recordId + '\' LIMIT 1' ;
            String QUERY = soql + '\'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1' ;        
            System.debug('QUERY:' + QUERY);
            SObject xas = Database.query(QUERY);
            System.debug('xas : ' + xas);
            if(xas != null){
                accountId = (String)xas.get(accountFieldName);
            }

        }
        System.debug('accountId : ' + accountId);
        List<AccountKeyInfoWrapper> keyInfos = new List<AccountKeyInfoWrapper>();
        //don't invoke the service is running Tests
        if(!Test.isRunningTest()){
            keyInfos = AccountKeyInfoContext.getInstance(configName).getKeyInfo(accountId);
            System.debug('-- keyInfoCmp >  keyInfos = ' + keyInfos);
        }

        return keyInfos;

    }
}