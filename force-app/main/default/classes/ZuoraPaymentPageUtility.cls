/**
* ZuoraPaymentPageUtility - Zuora Payment Page utility class.
* Has the following utilities:-
*
* 1. Payment ID Account Updates: 
*       Update Billing Account in SF and Account in Zuora.
* 
* 2. Zuora Payment Page iFrame utility - V1.0 and V2.0(CORS REST)
* Prerequisites: 
*   Custom label ZAPI_DOMAIN must be set to the target Zuora endpoint. 
*   Custom Setting ZuoraPaymentPageSetting__c should be populate with Zuora page details.
*
* V2.0:
*   REST request callout for Payment Page parameters including signature, token, key.
*   https://knowledgecenter.zuora.com/CA_Commerce/G_Hosted_Commerce_Pages/B_Payment_Pages_2.0/F_Generate_the_Digital_Signature_for_Payment_Pages_2.0
*
* V1.0
*   Create iFrame SRC parameters.
*   https://knowledgecenter.zuora.com/CA_Commerce/G_Hosted_Commerce_Pages/C_Hosted_Payment_Pages/B_Implementing_Hosted_Payment_Pages_on_Your_Website/B_Generate_the_Signature_for_the_iFrame
*
* (US-45797)
* @author Richard Wintle
**/
global without sharing class ZuoraPaymentPageUtility {

    /** 
    * Map of all Payment Page custom settings for the required domain
    **/
    private static Map<String, ZuoraPaymentPageSetting__c> paymentPageSettingMap {
        get {
            if (paymentPageSettingMap == null) {
                paymentPageSettingMap=new Map<String, ZuoraPaymentPageSetting__c>();
                for(ZuoraPaymentPageSetting__c zif : ZuoraPaymentPageSetting__c.getAll().values()) {
                    if(zif.ppDomain__c==System.Label.ZAPI_DOMAIN) {
                        paymentPageSettingMap.put(zif.SFPageKey__c, zif);
                        System.debug(paymentPageSettingMap);
                    } else {
                        if(Test.IsRunningTest()) paymentPageSettingMap.put(zif.SFPageKey__c, zif);
                    }
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
        if (zapi == null && !Test.isRunningTest()) zapi = ZuoraUpdateUtility.loginToZuora('ZuoraPaymentPageUtility');
        return zapi;
    }
    /**
    * Update this users Billing Account with PaymentID and call future method to update the same on Zuora.
    * @param paymentId
    **/
    @AuraEnabled
    public static void processPaymentID(String paymentId) {
        try {
            //
            // find billing account of current user
            Id conId = [Select contactId from User where id =: Userinfo.getUserid()].contactId;
            Id accId  = [Select AccountId from Contact where id =: conId].AccountId;
            List<Zuora__CustomerAccount__c> baList= [select Id, ElectronicPaymentMethodId__c,
                                                     Zuora__Zuora_Id__c, Zuora__Account__r.Zuora_Country_Code__c 
                                                     from Zuora__CustomerAccount__c where Zuora__Account__c=:accId];
            // update billing account
            if(baList.size()==1) {
                baList[0].ElectronicPaymentMethodId__c = paymentId;
                update baList[0];
                //
                // update Zuora Account
                updatePaymentMethod(baList[0].Id, paymentId);
            }
        } catch (Exception ex){
            System.debug( LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString() );
            throw ex;
        }
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
            } else {    //Set the Payment Method Type to "Credit Card" for testing purposes
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
                            ExceptionHandler.logZuoraRecordProcessingErrors('ZuoraPaymentPageUtility', 'updatePaymentMethod', errorMessageMap);
                        }

                        //Specify Payment Retry fields in Zuora for Payment Method
                        Integer MaxConsecutivePaymentFailures;
                        Integer PaymentRetryWindow;
                        if (countryPrefix == 'US' || countryPrefix == 'CA'){
                            MaxConsecutivePaymentFailures =  3;
                            PaymentRetryWindow = 24;
                        }
                        else if(paymentMethodType == 'SEPA'){
                            MaxConsecutivePaymentFailures =  2;
                            PaymentRetryWindow = 24;
                        }
                        else {
                            MaxConsecutivePaymentFailures =  4;
                            PaymentRetryWindow = 24;
                        }

                        //Call Payment Retry fields update
                        boolean returnUpdate;

                        returnUpdate =  ZuoraUpdateUtility.updateZuoraObject(zapi, 'PaymentMethod', new Map<String, Object>{
                                'Id' => paymentId, 'MaxConsecutivePaymentFailures' => MaxConsecutivePaymentFailures,'PaymentRetryWindow' => PaymentRetryWindow,'UseDefaultRetryRule' => false});

                        System.debug('returnUpdate'+returnUpdate);

                        if(!returnUpdate && !Test.isRunningTest()){
                            errorMessageMap = new Map<String, String>();
                            errorMessageMap.put(paymentId, 'Update failed for payment method.');
                            ExceptionHandler.logZuoraRecordProcessingErrors('ZuoraPaymentPageUtility', 'updatePaymentMethod', errorMessageMap);
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
         @AuraEnabled global String zppLocale;
        @AuraEnabled global String zppFieldcurrency;
        public ZPaymentPage(ZClient.RESTCalloutResult sigResult, String pageURI, String pageId) {
            system.debug('constructor:'+sigResult);
            if((boolean)sigResult.responseMap.get('success')) {
                Id userId = UserInfo.getUserId();
                User u = [select Id,Name,AccountId from User where Id=:userId];
                Account acc = [select Locale__c,CurrencyIsoCode from Account where Id=:u.AccountId];
                Id localeId = acc.Locale__c;
                Locale__c localeObj = [select Name from Locale__c where Id=:localeId];
                String localeName = localeObj.Name;
                zppLocale = localeName.substring(0,2);
                status='SUCCESS';
                zppTenantId=(String)sigResult.responseMap.get('tenantId');
                zppToken=(String)sigResult.responseMap.get('token');
                zppKey=(String)sigResult.responseMap.get('key');
                zppFieldcurrency=acc.CurrencyIsoCode;
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
        Boolean isLimitReached = isSubmitLimitReached();
        return  isLimitReached ? null : requestSignatureV2(pageName);
    }

    @AuraEnabled
    public static String getBaseUrl()
    {
        return Site.getBaseCustomUrl().removeEnd('/s'); // + Site.getPathPrefix().removeEnd('/s');
    }

    @AuraEnabled
    public static List<zqu__HostedPageLiteSetting__c> getPaymentMethods()
    {
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
        String countryCode= localeName.substring(3);
        System.debug(countryCode);
        List<zqu__HostedPageLiteSetting__c> paymentPage = Database.query('SELECT Id, zqu__PaymentMethodType__c FROM zqu__HostedPageLiteSetting__c where Country_Code__c=\''+countryCode+'\' and Client_Code__c like '+'\'%Community%\' ORDER BY zqu__PaymentMethodType__c ASC');
        return paymentPage;
    }


    @AuraEnabled
    public static String getUserLocale() {
        Id userId = UserInfo.getUserId();
        User u = [select Id,Name,AccountId from User where Id=:userId];
        Account acc = [select Locale__c from Account where Id=:u.AccountId];
        Id localeId = acc.Locale__c;
        Locale__c locale = [select Name from Locale__c where Id=:localeId];
        String localeName = locale.Name;
        system.debug('Locale: '+localeName);
        String countryCode = localeName.substring(3);
        return countryCode;
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
            Id userId = UserInfo.getUserId();
            User u = [select Id,Name,AccountId from User where Id=:userId];
            Account acc = [select Locale__c from Account where Id=:u.AccountId];
            Id localeId = acc.Locale__c;
            Locale__c locale = [select Name from Locale__c where Id=:localeId];
            String localeName = locale.Name;
            String countryCode = localeName.substring(3);
            System.debug(countryCode);
            zqu__HostedPageLiteSetting__c paymentPage = Database.query('SELECT Id, zqu__PageId__c, Name FROM zqu__HostedPageLiteSetting__c where Country_Code__c=\''+countryCode+'\' and zqu__PaymentMethodType__c=\''+sfPageRef+'\' and Name like '+'\'%Community%\'');
            // get and set parameters for this reference
            //sfPageRef = sfPageRef.replace(' ','');
            //System.debug(sfPageRef);
            ZuoraPaymentPageSetting__c zPageSetting=paymentPageSettingMap.get('ZuoraLoginDetails');
            System.debug(zPageSetting);
            //String pageId=zPageSetting.ppPageID__c;
            String pageId = paymentPage.zqu__PageId__c;
            System.debug(pageId);
            String apiAccessID=zPageSetting.apiAccessID__c;
            String apiAccessKey=zPageSetting.apiAccessKey__c;
            String sigEndpoint=zPageSetting.ppDomain__c+zPageSetting.ppSignaturePath__c;
            String pageURI=zPageSetting.ppDomain__c+zPageSetting.ppPageRef__c;
/*
            String pageId= '2c92c0f954cd0e2e0154e3f1007e2c1c';
            String apiAccessID='sageapiuser@sage.com';
            String apiAccessKey= 'zuora201&Z';
            String sigEndpoint='https://apisandbox-api.zuora.com/rest/v1/rsa-signatures';
            String pageURI='https://apisandbox-api.zuora.com/apps/PublicHostedPageLite.do';
*/
            System.debug('pageId: '+pageId);
            System.debug('apiAccessID: '+apiAccessID);
            System.debug('apiAccessKey: '+apiAccessKey);
            System.debug('sigEndpoint: '+sigEndpoint);
            System.debug('pageURI: '+pageURI);
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
            ExceptionHandler.CatchException('ZuoraPaymentPageUtility','requestSignatureV2',e);
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
        requestQueryV2(String uri, String pageId, String method) {
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
        public String urlToken; //32 character random
        public String urlQueryString;
        public String urlSignature;
        //
        // constructor to create iFrame attributes from input page reference
        public zIFrameURL(String zPageRef) {
            system.debug('The zPageRef value from parameter is :'+ zPageRef);
            urlPageRef=zPageRef;
            ZuoraPaymentPageSetting__c zPageSetting=paymentPageSettingMap.get(zPageRef);
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
        	//return 1000;    
        }
    }

    @TestVisible static private Account ccAcc 
    {
        get {
            if( ccAcc == null ) {
                system.debug('1111 In ccAcc');
                Id userId = UserInfo.getUserId();
                system.debug('1111 In ccAcc :' + userId);
                List<Account> accs = [SELECT Zuora_Payment_Change_Last_Submit_Date__c, Zuora_Payment_Change_Submit_Count__c FROM Account WHERE Id IN (SELECT AccountId FROM User WHERE Id = :userId)];
                if( !accs.isEmpty() ) ccAcc = accs[0]; else System.debug( LoggingLevel.ERROR, 'No customer account found.');
            }
            return ccAcc;
        }
        set;
    }

    @AuraEnabled
    static global Boolean isSubmitLimitReached()     
    {
         system.debug('isSubmitLimitReached: enter ');
        if( ccAcc == null ) return true;
        Integer submitCount = ccAcc.Zuora_Payment_Change_Submit_Count__c == null ? 0 : ccAcc.Zuora_Payment_Change_Submit_Count__c.intValue();
         system.debug('isSubmitLimitReached: submitCount ' + submitCount);
        Datetime lastSubmittedOn = ccAcc.Zuora_Payment_Change_Last_Submit_Date__c;
         system.debug('isSubmitLimitReached: lastSubmittedOn ' + lastSubmittedOn);
         system.debug('isSubmitLimitReached: SUBMIT_LIMIT ' + SUBMIT_LIMIT);
        return lastSubmittedOn != null && lastSubmittedOn.date() == System.today() && submitCount >= SUBMIT_LIMIT;
      // return true;
    }

    @AuraEnabled
    static global Boolean incrementSubmitCount()
    {
        system.debug('1111 In incrementSubmitCount');
        if( ccAcc != null )
        {
              system.debug('1111 In incrementSubmitCount if ccAcc != null ');
            Integer submitCount = ccAcc.Zuora_Payment_Change_Submit_Count__c == null ? 0 : ccAcc.Zuora_Payment_Change_Submit_Count__c.intValue();
             system.debug('1111 In incrementSubmitCount : '+ submitCount);
            Datetime lastSubmittedOn = ccAcc.Zuora_Payment_Change_Last_Submit_Date__c;
             system.debug('1111 In incrementSubmitCount : '+ lastSubmittedOn);
            if( lastSubmittedOn != null && lastSubmittedOn.date() != System.today() ) {
                 system.debug('1111 If more than one day make it zero');
                submitCount = 0;
            }
            lastSubmittedOn = System.now();
            system.debug('1111 In incrementSubmitCount again : '+ lastSubmittedOn);
            submitCount++;
            system.debug('1111 In incrementSubmitCount again : '+ submitCount);

            ccAcc.Zuora_Payment_Change_Submit_Count__c = submitCount;
            ccAcc.Zuora_Payment_Change_Last_Submit_Date__c = lastSubmittedOn;
            update ccAcc;
        }
         system.debug('1111 Return to isSubmitLimitReached');
        return isSubmitLimitReached();
    }
    
    @AuraEnabled
    public static boolean hasPermission(String name) {

        List<CustomPermission> customPermissions =
            [SELECT Id, DeveloperName
             FROM CustomPermission
             WHERE DeveloperName = :name];

        System.debug('***********' + customPermissions);
        if (customPermissions.size() > 0) {

            List<Id> customPermissionSetIds = new List<Id>();
            for (CustomPermission p : customPermissions) {
                customPermissionSetIds.add(p.Id);
            }

            System.debug('***********' + customPermissionSetIds);

            List<SetupEntityAccess> setupEntities =
                [SELECT SetupEntityId
                 FROM SetupEntityAccess
                 WHERE SetupEntityId in :customPermissionSetIds AND
                 ParentId IN (SELECT PermissionSetId
                              FROM PermissionSetAssignment
                              WHERE AssigneeId = :UserInfo.getUserId())];

            if (setupEntities.size() > 0) {
                return true;

            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}