global without sharing class TetrisZouraPaymentUtility {


    //   Declaration at top of class
    @TestVisible private static TetrisEndpointLookupUtility tetrisEndpoints = new TetrisEndpointLookupUtility();
    @TestVisible private static OrganizationDAO.IOrganizationDAO organizationDAOInstance = new OrganizationDAO();
    @TestVisible private static ICustomMetadataTypeDAO customMetadataTypeDAOInstance = DAOFactory.getCustomMetadataTypeDAO();

    /** 
    * Map of all Payment Page custom settings for the required domain
    **/
    public static Map<String, Zuora_Payment_Page_Setting__mdt> paymentPageSettingMap {
        get {
            List<Zuora_Payment_Page_Setting__mdt> zuoraPaymentPageSetting = 
                            customMetadataTypeDAOInstance.getZuoraPaymentPageSettings();
           
            if (paymentPageSettingMap == null) {
                paymentPageSettingMap = new Map<String, Zuora_Payment_Page_Setting__mdt>();
                for(Zuora_Payment_Page_Setting__mdt setting: zuoraPaymentPageSetting){
                    paymentPageSettingMap.put(setting.SFPageKey__c, setting);
                    System.debug(paymentPageSettingMap);
                }
            }

            return paymentPageSettingMap;
        }set;
    }
    //
    // -------------- PAYMENT ID ACCOUNT UPDATES (SF AND ZUORA) ------------------
    //
    private static Zuora.zApi zapi;
    
    public static Zuora.zApi getApiStub() {
        if (zapi == null && !Test.isRunningTest()) zapi = ZuoraUpdateUtility.loginToZuora('TetrisZouraPaymentUtility');
        return zapi;
    }
    
    /**
    * Method to update the Default Payment Method and Default Payment Gateway on the Account in Zuora.
    * @param accountId
    * @param paymentId
    **/
    @future(callout=true)
    public static void updatePaymentMethod(String accountId, String paymentId){
        List <Zuora.zObject> recordsToUpdate = new List<Zuora.zObject> ();
        
        // Read the Zuora Account Id and the Zuora Country Code from the Billing Account
        List<Zuora__CustomerAccount__c> acc = [select Zuora__Zuora_Id__c, Zuora__Account__r.Zuora_Country_Code__c from Zuora__CustomerAccount__c where Id = :accountId];
        if(acc.size()==1){
            
            String zuoraId = acc.get(0).Zuora__Zuora_Id__c;
            String countryPrefix = acc.get(0).Zuora__Account__r.Zuora_Country_Code__c;

            String client_Code ='Community-SageOne';
            
            // Call Zuora to get the Type of the newly created Payment Method
            // (Can't rely on getting it from the Salesforce object as it may not have been sync'd across from Zuora yet)
            String paymentMethodType;
            Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
            qr.zoql = 'SELECT Type FROM PaymentMethod WHERE Id=\'' + paymentId + '\'';
            
            if(!Test.isRunningTest()) {// Only call Zuora if not in test mode
                getApiStub();
                Zuora.zApi.QueryResult queryResult = zapi.zquery(qr);
                System.Debug('**** Zuora Account Payment Method Query Result: ' + queryResult);
                
                if(queryResult.records.size() == 1){
                    // Need to add spaces into the Payment Type Name so that the Hosted Payment Page Setting query below works successfully
                    if ((String)queryResult.records.get(0).getValue('Type') == 'CreditCard') paymentMethodType = 'Credit Card';
                    else if ((String)queryResult.records.get(0).getValue('Type') == 'ACH') paymentMethodType = 'ACH';
                    else if ((String)queryResult.records.get(0).getValue('Type') == 'BankTransfer') paymentMethodType = 'SEPA';                   
                }
            } else {	//Set the Payment Method Type to "Credit Card" for testing purposes
                paymentMethodType = 'Credit Card';
            }
            
            // If the Payment Method Type was found, read the Hosted Payment Page object to find the Gateway Name
            if(paymentMethodType != null) {
                List<zqu__HostedPageLiteSetting__c> pageSettings = (List<zqu__HostedPageLiteSetting__c>)Database.query('SELECT  Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Client_Code__c = \'' + client_Code + '\' AND Country_Code__c = \'' + countryPrefix + '\' AND zqu__paymentMethodType__c = \'' + PaymentMethodType + '\'');
                //List<zqu__HostedPageLiteSetting__c> pageSettings = (List<zqu__HostedPageLiteSetting__c>)Database.query('SELECT  Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE Name Like \'' + 'Customer Community ' + paymentMethodType + '%\' and Country_Code__c=\''+countryPrefix+'\'');
                if(pageSettings.size()==1){
                    String gateway = pageSettings.get(0).Payment_Gateway_Name__c;
                    if (gateway != null) {
                        //
                        // set account details to update
                        Zuora.zObject zo = new Zuora.zObject('Account');
                        zo.setValue('Id', zuoraId);
                        zo.setValue('DefaultPaymentMethodId', paymentId);
                        zo.setValue('PaymentGateway', gateway);
                        recordsToUpdate.add(zo);
                        //
                        // Update zuora
                        Map<String, String> errorMessageMap = new Map<String, String>();
                        if(!Test.isRunningTest()) // Only call Zuora if not in test mode
                        {
                            getApiStub();
                            List <Zuora.zApi.SaveResult> results = zapi.zUpdate(recordsToUpdate);
                            System.Debug('**** Zuora Account Default Payment Update Results: ' + results);
                            for(Zuora.zApi.SaveResult result : results){
                                if (!result.Success){
                                    //failure
                                    for(Zuora.zObject error : result.errors){   
                                        errorMessageMap.put(result.Id, (String)error.getValue('Message'));
                                    }
                                }
                            }
                        }
                        if(errorMessageMap.keySet().size() > 0){
                            ExceptionHandler.logZuoraRecordProcessingErrors('TetrisZouraPaymentUtility', 'updatePaymentMethod', errorMessageMap);
                        }
                    }
                }
            }
        }
    }
    //
    // -------------- HOSTED PAYMENT PAGES V2.0 (CORS REST) ----------------
    /**
    * ACH and Credit Card return object
    **/
    global class SubscriptionPaymentPages {
        @AuraEnabled global ZPaymentPage ppACH;
        @AuraEnabled global ZPaymentPage ppCreditCard;
    }
    /**
    * Payment Page result parameters
    **/
    global class ZPaymentPage {
        @AuraEnabled global String zppURL;
        @AuraEnabled global String zppPageID;
        @AuraEnabled global String zppTenantID;
        @AuraEnabled global String zppSignature;
        @AuraEnabled global String zppToken;
        @AuraEnabled global String zppKey;
        @AuraEnabled global String status;
        @AuraEnabled global String locale;
        @AuraEnabled global String zppFieldcurrency;
        public ZPaymentPage(ZClient.RESTCalloutResult sigResult, String pageURI, String pageId) {
            system.debug('constructor:'+sigResult);
            if((boolean)sigResult.responseMap.get('success')) {
                Id userId = tetrisEndpoints.getConfigByName('zuora-iframe-account').ClientId;
                /*
                User u = [select Id,Name,AccountId from User where Id=:userId];
                Account acc = [select Locale__c,CurrencyIsoCode from Account where Id=:u.AccountId];
                Id localeId = acc.Locale__c;
                Locale__c localeObj = [select Name from Locale__c where Id=:localeId];
                String localeName = localeObj.Name;
                */
                locale = 'US';
                status='SUCCESS';
                zppTenantId=(String)sigResult.responseMap.get('tenantId');
                zppToken=(String)sigResult.responseMap.get('token');
                zppKey=(String)sigResult.responseMap.get('key');
                zppFieldcurrency= 'USD';
                zppSignature=(String)sigResult.responseMap.get('signature');
                zppURL=pageURI;
                zppPageID=pageId;
            } else {
                status='ERROR';
            }
        }
        // error constructor
        public ZPaymentPage(String errStatus) { this.status=errStatus; }
    }
    /**
    * Fetch all page parameters required for ACH and Credit Card iframes
    * @return SubscriptionPaymentPages
    **/
    @AuraEnabled
    public static SubscriptionPaymentPages loadSubscriptionPaymentPages() {
        return loadSubscriptionPaymentPagesPrivate();
    }

    @RemoteAction
    global static ZPaymentPage loadPage(String pageName)
    {
        System.debug( LoggingLevel.ERROR, 'Zuora Utility: pageName : ' +  pageName);
        return requestSignatureV2(pageName);
    }

    @AuraEnabled
    public static String getBaseUrl()
    {
        return Site.getBaseCustomUrl().removeEnd('/s') + Site.getPathPrefix().removeEnd('/s');
    }

    @AuraEnabled
    public static List<zqu__HostedPageLiteSetting__c> getPaymentMethods()
    {
        /*
        Id userId = UserInfo.getUserId();
        system.debug('userId: '+userId);
        User u = [select Id,Name,AccountId from User where Id=:userId];
        system.debug('userId: '+u.Id+u.Name);
        Account acc = [select Name,Id,Locale__c from Account where Id=:u.AccountId];
        system.debug('userId: '+acc.Locale__c);
        Id localeId = acc.Locale__c;
        system.debug('111Id: '+localeId);
        Locale__c locale= [select Name from Locale__c where Id=:localeId];
        String localeName= locale.Name;
        system.debug('localeName :'+localeName);
        */
        String countryCode= 'USA';
        System.debug(countryCode);

        List<zqu__HostedPageLiteSetting__c> paymentPage = Database.query('SELECT Id, zqu__PaymentMethodType__c FROM zqu__HostedPageLiteSetting__c where Country_Code__c=\''+countryCode+'\' and Client_Code__c like '+'\'%Community%\' ORDER BY zqu__PaymentMethodType__c ASC');
        return paymentPage;
    }


    @AuraEnabled
    public static String getUserLocale() {
        /*
        Id userId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:userId];
        Account acc = [select Locale__c from Account where Id=:u.AccountId];
        Id localeId = acc.Locale__c;
        Locale__c locale = [select Name from Locale__c where Id=:localeId];
        String localeName = locale.Name;
        system.debug('Locale: '+localeName);
        String countryCode = localeName.substring(3);
        */
        return 'USA';
    }

    private static SubscriptionPaymentPages loadSubscriptionPaymentPagesPrivate() {
        SubscriptionPaymentPages subsPP=new SubscriptionPaymentPages();
        subsPP.ppACH=requestSignatureV2('ACH');
        subsPP.ppCreditCard=requestSignatureV2('CreditCard');
        return subsPP;
    }

    /**
    * Fetch payment page parameters for given SF page reference
    * @param sfPageRef
    **/
    public static ZPaymentPage requestSignatureV2(String sfPageRef) {
        try {

            System.debug( LoggingLevel.ERROR, 'IN requestSignatureV2 : sfPageRef : ' +  sfPageRef);

            // Get a dynamic config:    
            TetrisEndpointLookupUtility.TetrisEndpointConfig config = tetrisEndpoints.getConfigByName('zuora-iframe-account');
              
            /*
            Id userId = config.ClientId;
            //Id userId = storeFrontUserID;

            User u = [select Id, Name, AccountId from User where Id=:userId];

            Account acc = [select Locale__c from Account where Id=:u.AccountId];

            System.debug('Account ====> ' + acc);

            Id localeId = acc.Locale__c;

            Locale__c locale = [select Name from Locale__c where Id=:localeId];

            String localeName = locale.Name;
            */

            //String countryCode = localeName.substring(3);
            String countryCode = 'USA';

            System.debug(countryCode);

            //zqu__HostedPageLiteSetting__c paymentPage = Database.query('SELECT Id, zqu__PageId__c, Name FROM zqu__HostedPageLiteSetting__c where Country_Code__c=\''+countryCode+'\' and zqu__PaymentMethodType__c=\''+sfPageRef+'\' and Name like '+'\'%Community%\'');
            zqu__HostedPageLiteSetting__c paymentPage;

            System.debug('****sfPageRef: ' + sfPageRef);
            Zuora_Payment_Page_Setting__mdt zPageSetting = paymentPageSettingMap.get(sfPageRef);
            System.debug('****zPageSetting: ' + zPageSetting);

            String pageId = zPageSetting.ppPageID__c;
            //String pageId = '2c92c0f95a6b227b015a8a578dba5868';
            System.debug(pageId);
            String apiAccessID = zPageSetting.apiAccessID__c;
            String apiAccessKey = zPageSetting.apiAccessKey__c;
            String sigEndpoint = zPageSetting.ppDomain__c + zPageSetting.ppSignaturePath__c;
            String pageURI = zPageSetting.ppDomain__c + zPageSetting.ppPageRef__c;
/*
            String pageId= '2c92c0f954cd0e2e0154e3f1007e2c1c';
            String apiAccessID='sageapiuser@sage.com';
            String apiAccessKey= 'zuora201&Z';
            String sigEndpoint='https://apisandbox-api.zuora.com/rest/v1/rsa-signatures';
            String pageURI='https://apisandbox-api.zuora.com/apps/PublicHostedPageLite.do';
*/
            //pageId = '2c92c0f95a6b227b015a8a578dba5868';
            //apiAccessID = 'integration_user@sage.com.ecomm2';
            //apiAccessKey = 'p@$$w0rd';
            //sigEndpoint ='https://apisandbox-api.zuora.com/rest/v1/rsa-signatures';
            //pageURI ='https://apisandbox.zuora.com/apps/PublicHostedPageLite.do';
            //
            // build request query object
            requestQueryV2 reqObj=new requestQueryV2(pageURI, pageId, 'POST');
            // callout request for parameters
            ZClient.RESTCalloutResult sigResult=ZClient.restCallout(sigEndpoint,'POST', reqObj,
                                                                    apiAccessID, apiAccessKey);
            system.debug('REST response:'+sigResult.responseBody);
            //
            // parse results and return all required iframe payment page parameters
            return new ZPaymentPage(sigResult, pageURI, pageId);
            //
        }catch(exception e){
            System.debug('ERROR:' + e);
            ExceptionHandler.CatchException('TetrisZouraPaymentUtility','requestSignatureV2',e);
        }
        return new ZPaymentPage('ERROR');
    }
    /**
    * JSON Payment Page request structure V2.0
    **/
    public class requestQueryV2 {
        public String uri;
        public String pageId;
        public String method;
        public requestQueryV2(String uri, String pageId, String method) {
            this.uri=uri;
            this.pageId=pageId;
            this.method=method;
        }
    }
    //
    // -------------- HOSTED PAYMENT PAGES V1.0 ----------------
    //
    // cached store of requested pages
    private static Map<String, zIFrameURL> zPaymentPageMap;
    //
    /**
    * Returns iFrame src attribute.
    * This will create new parameters if page not cached, otherwise return cached iFrame src.
    * @param zPageRef - path and page e.g. '/apps/PublicHostedPaymentMethodPage.do'
    * @return iFrameSrc
    **/
    global String iFrameSrc(String zPageRef) {
        if(zPaymentPageMap==null) zPaymentPageMap=new Map<String, zIFrameURL>();
        zIFrameURL zif=zPaymentPageMap.get(zPageRef);
        if(zif==null) {
            zif=new zIFrameURL(zPageRef);
            zPaymentPageMap.put(zPageRef, zif);
        }
        system.debug('Url Signature from the debug is:'+zif.urlSignature);
        return zif.urlDomain+zPageRef+'?method=requestPage&'+zif.urlQueryString+'&signature='+zif.urlSignature;
    }
    /**
    * Clear page reference settings and create new src reference for page.
    * @param zPageRef
    * @return iFrameSrc
    **/
    global String refreshIFrameSrc(String zPageRef) {
        clearCachedPage(zPageRef);
        return iFrameSrc(zPageRef);
    }
    /**
    * Clear cached iFrame payment page.
    * @param zPageRef
    **/
    global void clearCachedPage(String zPageRef) {
        if(zPaymentPageMap!=null) {
            zPaymentPageMap.remove(zPageRef);
        }
    }
    /**
    * Zuora iFrame object
    **/
    public class zIFrameURL {
        public String urlDomain;
        public String urlPageRef;
        public String urlMethod;
        public String urlPageID;
        public String urlTenantID;
        public String urlTimestamp;
        public String urlToken;	//32 character random
        public String urlQueryString;
        public String urlSignature;
        //
        // constructor to create iFrame attributes from input page reference
        public zIFrameURL(String zPageRef) {
            system.debug('The zPageRef value from parameter is :'+ zPageRef);
            urlPageRef=zPageRef;
            Zuora_Payment_Page_Setting__mdt zPageSetting = paymentPageSettingMap.get(zPageRef);
            if(zPageSetting!=null) {
                urlDomain=zPageSetting.ppDomain__c;
                urlPageID=zPageSetting.ppPageID__c;
                urlTenantID=zPageSetting.ppTenantID__c;
                urlTimestamp=String.valueOf(Datetime.now().getTime());
                urlToken=generateRandomString(32);
                urlQueryString='id=' + urlPageID + '&' +'tenantId=' + urlTenantID + '&' +
                    'timestamp=' + urlTimestamp + '&' +'token=' + urlToken;
                String queryStringToHash=urlQueryString + zPageSetting.ppApiSecurityKey__c;
                String encoded = EncodingUtil.urlEncode(queryStringToHash, 'UTF-8');
                String signature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(encoded)));
                urlSignature=EncodingUtil.base64Encode(Blob.valueOf(signature));
                system.debug('the value of urlSignature is :'+ urlSignature);
                system.debug('The value of urlTenantID:'+ urlTenantID);
                system.debug('The value of urlPageID:'+ urlPageID);
                system.debug('The value of urlDomain : '+ urlDomain);
            }
        }
    }
    /**
    * Utility to generate random string
    * @param len - length of required random string
    * @return random string of length len
    **/
    global static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    /////////////////////////////////////////////
    // Payment Change Submit Limit Enforcement //
    /////////////////////////////////////////////

    @TestVisible static private Integer SUBMIT_LIMIT
    {
        get {
            Decimal submitLimit = Security_Payment_Change_Settings__c.getInstance().Payment_Details_Submit_Limit__c;
            return submitLimit == null ? 5 : submitLimit.intValue();
        }
    }

    @TestVisible static private Account ccAcc 
    {
        get {
            /*
            if( ccAcc == null ) {

               Id userId = tetrisEndpoints.getConfigByName('zuora-iframe-account').ClientId;
                System.debug( LoggingLevel.ERROR, 'UserInfo.getUserId().' + userId);
                System.debug( LoggingLevel.ERROR, 'SELECT SIZE: ' + [SELECT AccountId FROM User WHERE Id = :userId ].size());
                String accId = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1].AccountId;
                System.debug( LoggingLevel.ERROR, 'accId: ' + accId);
                System.debug( LoggingLevel.ERROR, 'SELECT SIZE: ' + [SELECT Zuora_Payment_Change_Last_Submit_Date__c, Zuora_Payment_Change_Submit_Count__c FROM Account WHERE Id = :accId ].size());
                List<String> ids = new List<String>();
                ids.add(accId);
                Account a = [SELECT Zuora_Payment_Change_Last_Submit_Date__c, Zuora_Payment_Change_Submit_Count__c FROM Account WHERE Id = :ids ];
                List<Account> accs = new List<Account>();
                accs.add(a);
                if( !accs.isEmpty() ) ccAcc = accs[0]; else System.debug( LoggingLevel.ERROR, 'No customer account found.');
            }
            System.debug( LoggingLevel.ERROR, 'Account RETURN => ' + ccAcc);
            */
            return null;
        }
        set;
    }
}