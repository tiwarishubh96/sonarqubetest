/**
 * AccountKeyInfoContext is responsible for loading the configurtaions fromt eh 
 * Key Information Custom Metadata
 */
public with sharing class AccountKeyInfoContext {

    static string CLASSNAME = 'AccountKeyInfoContext';

    static final String ERROR_NO_CONFIG_FOUND = 'No Configuration found - contact your administrator';

    static final String DELIMITER = ',';

    Map<String, Integer> priorityMap = new Map<String,Integer>();

    static AccountKeyInfoContext instance;

    @TestVisible
    Map<String,IAccountKISvc> keyServices;

    @TestVisible 
    static Key_Info_Service__mdt keyInfoConfig {get;set;}


    /**
     * getInstance Singleton instance
     * @param  componentContext componentContext description
     * @return                  return description
     */
    public static AccountKeyInfoContext getInstance(String componentContext){
        if(instance == null){
            instance = new AccountKeyInfoContext(componentContext);
        }
        return instance;
    }

    public class AccountKeyInfoContextException extends Exception {
    }

    
    private AccountKeyInfoContext(String context){
        LogControl.push('AccountKeyInfoContext', CLASSNAME);
        System.debug('AccountKeyInfoContext - Loading context for : ' + context);
        //to support testing (as we can't created custom metadata in Tests) we can set it, 
        List<Key_Info_Service__mdt> keyInfoConfigs;
        if(!Test.isRunningTest()){
             keyInfoConfigs =  [select NamespacePrefix, MasterLabel, Key_Service_Classes__c, Object_Name__c from Key_Info_Service__mdt where MasterLabel = :context ];
             System.debug('AccountKeyInfoContext - Key_Info_Service__mdt for ' + context + ' = ' + keyInfoConfigs);
             if(keyInfoConfigs != null && !keyInfoConfigs.isEmpty()){
                 keyInfoConfig = keyInfoConfigs[0];
             }
        }
                
        //we only expect 1 records per object / name
        
        if(keyInfoConfig != null){
            keyServices = new Map<String, IAccountKISvc>();
            List<String> clazzNames = keyInfoConfig.Key_Service_Classes__c.split(DELIMITER);
            System.debug('clazzNames list ' + clazzNames);
            for(String clazz:clazzNames){
                try{
                    keyServices.put(clazz, (IAccountKISvc)Type.forName(clazz + 'impl').newInstance());
                }catch (Exception e ){
                    LogControl.debugException(e);
                    System.debug('Error initialising service : ' + clazz + ' Error - ' + e);
                    continue;
                }
            }
        }else{
            throw new AccountKeyInfoContextException(ERROR_NO_CONFIG_FOUND);
        }
    }


    private List<AccountKeyInfoWrapper> callServices(String recordId){
        LogControl.push('callServices', CLASSNAME);
        List<AccountKeyInfoWrapper> aggKeyInfo = new List<AccountKeyInfoWrapper>();
        //Loop the configured services and fetch the data.
        for(IAccountKISvc service:keyServices.values()){
            try{
                aggKeyInfo.addAll(service.getKeyData(recordId));
            }catch(Exception e){
                //log the error but don't stop the other services from trying to fetch the data.
                LogControl.debugException(e);
                System.debug('callServices Error ' + e);
                continue;
            }
        }
        LogControl.pop();
        System.debug('callServices aggKeyInfo ' + aggKeyInfo);
        return aggKeyInfo;
    }

    public List<AccountKeyInfoWrapper> getKeyInfo(String recordId){
        LogControl.push('getKeyInfo', CLASSNAME);

        List<AccountKeyInfoWrapper> accountInfo;
        //aggregated list for all accountinfo items returned by various configured services
        try{
            List<AccountKeyInfoWrapper> aggKeyInfo = callServices(recordId);
            System.debug('getKeyInfo aggKeyInfo ' + aggKeyInfo);
        
            //Got resuts ? decorate it
            if(aggKeyInfo != null && !aggKeyInfo.isEmpty()){
                AccountKeyInfoSimpleDecorator decorator = new AccountKeyInfoSimpleDecorator();
                accountInfo =  decorator.decorate(aggKeyInfo);
                System.debug('getKeyInfo accountInfo ' + accountInfo);
            }else{
                //empty list 
                accountInfo = aggKeyInfo;
            }         
        }catch(Exception e){
                //log the error
                LogControl.debugException(e);
                System.debug('getKeyInfo Error ' + e);
        }finally{
            LogControl.pop();
        }
        System.debug('Returing accountInfo ' + accountInfo);
        return accountInfo;
        
    }

}