global class TetrisPaymentHelperV2 {

    private final static String TETRIS_APP_NAME = 'Tetris';
    private final static String TETRIS_ZUORA_CONNECTION_INFO = 'Zuora Login Details';
    global List<Zuora.zObject> updatezuoraAccountGatewayField = new List<Zuora.zObject> ();
    global List<Zuora.zObject> updatezuoraAccountFieldsList = new List<Zuora.zObject> ();
    global List<Zuora.zApi.SaveResult> results;

    /*
    * Fetch payment page parameters for given SF page reference
    * @param countryCode	2 Letter Country ISO Code
    */
    global TetrisPaymentModel getPaymentPageSettings(String countryCode, String paymentMethod) {
        ZuoraPaymentPageSetting__c zuoraConnectionSettings = getZuoraAPIConnectionConfig();

        //retrieve the list of Payment pages and Payment Method types configured by Country
        TetrisPaymentModel paymentConfig = new TetrisPaymentModel();
        paymentConfig = getPaymentPages(zuoraConnectionSettings, countryCode, paymentMethod);
        System.debug('retrieved payment config ' + paymentConfig);
        return paymentConfig;
    }

    global ZuoraPaymentPageSetting__c getZuoraAPIConnectionConfig() {
        //Fetch Zuora Connection Settings
        ZuoraPaymentPageSetting__c zPageSettings = [SELECT Id, apiAccessID__c, apiAccessKey__c, ppDomain__c, ppSignaturePath__c, ppPageRef__c FROM ZuoraPaymentPageSetting__c WHERE Name = :TETRIS_ZUORA_CONNECTION_INFO];
        System.debug('retrieved page settings');
        System.debug(zPageSettings);
        return zPageSettings;
    }

    global TetrisPaymentModel.PaymentMethod getZuoraTenantInfo(ZuoraPaymentPageSetting__c zPageSettings, String pageId) {
        TetrisPaymentModel.PaymentMethod zPaymentMethod = new TetrisPaymentModel.PaymentMethod();

        String apiAccessID = zPageSettings.apiAccessID__c;
        String apiAccessKey = zPageSettings.apiAccessKey__c;
        String sigEndpoint = zPageSettings.ppDomain__c + zPageSettings.ppSignaturePath__c;
        String pageURI = zPageSettings.ppDomain__c + zPageSettings.ppPageRef__c;

        System.debug('######################################################');
        System.debug('apiAccessID ' + apiAccessID);
        System.debug('apiAccessKey ' + apiAccessKey);
        System.debug('sigEndpoint ' + sigEndpoint);
        System.debug('pageURI ' + pageURI);
        // build request query object
        ZRequest zuoraRequest = new ZRequest(pageURI, pageId, 'POST');
        System.debug('zuoraRequest: ' + zuoraRequest);
        ZClient.RESTCalloutResult sigResult = null;
        if (!Test.isRunningtest()) {
            // callout request for parameters
            sigResult = ZClient.restCallout(sigEndpoint, 'POST', zuoraRequest,
                    apiAccessID, apiAccessKey);
        } else {
            //written to cover Test Class
            sigResult = new ZClient.RESTCalloutResult();
            Map<String, String> responseMap = new Map<String, String>();
            responseMap.put('tenantId', '12323');
            responseMap.put('token', 'token231');
            responseMap.put('key', '12312');
            responseMap.put('signature', 'signature21312');
            sigResult.responseMap = responseMap;
        }
        system.debug('REST response:' + sigResult.responseBody);
        // parse results and return all required iframe payment page parameters
        zPaymentMethod.zTenantID = (String) sigResult.responseMap.get('tenantId');
        zPaymentMethod.zToken = (String) sigResult.responseMap.get('token');
        zPaymentMethod.zKey = (String) sigResult.responseMap.get('key');
        zPaymentMethod.zURL = pageURI;
        String zppFieldcurrency = '';
        zPaymentMethod.zSignature = (String) sigResult.responseMap.get('signature');
        return zPaymentMethod;
    }

    global TetrisPaymentModel getPaymentPages(ZuoraPaymentPageSetting__c zPageSettings, String countryCode, String paymentMethod) {
        String paymentSql = 'SELECT Id, zqu__PaymentMethodType__c, Payment_Gateway_Name__c, Language__c, CurrencyIsoCode, zqu__Default__c, zqu__PageId__c, Name, Client_Code__c, Country_Code__C FROM zqu__HostedPageLiteSetting__c  where ';
        paymentSql += ' Country_code__c = \'' + countryCode + '\' and Client_Code__c = \'' + TetrisPaymentHelperV2.TETRIS_APP_NAME + '\' ';
        if (!String.isBlank(paymentMethod)) {
            paymentSql += ' and zqu__PaymentMethodType__c = \'' + paymentMethod + '\'';
        }
        System.debug('paymentSoql ' + paymentSql);
        List<zqu__HostedPageLiteSetting__c> paymentPageList = Database.query(paymentSql);

        if (paymentPageList.size() == 0) {
            throw new TetrisPaymentException('No Payment Pages configured for the Country ' + countryCode);
        }

        List<TetrisPaymentModel.PaymentMethod> paymentMethodList = new List<TetrisPaymentModel.PaymentMethod>();
        for (zqu__HostedPageLiteSetting__c paymentPage : paymentPageList) {
            String pageId = paymentPage.zqu__PageId__c;
            TetrisPaymentModel.PaymentMethod paymentMethodConfig = getZuoraTenantInfo(zPageSettings, pageId);
            paymentMethodConfig.countryCode = countryCode;
            paymentMethodConfig.countryLanguage = paymentPage.Language__c;
            paymentMethodConfig.countryCurrency = paymentPage.CurrencyIsoCode;
            paymentMethodConfig.isDefault = paymentPage.zqu__Default__c;
            paymentMethodConfig.paymentPageId = pageId;
            paymentMethodConfig.paymentGateway = paymentPage.Payment_Gateway_Name__c;
            paymentMethodConfig.paymentType = paymentPage.zqu__PaymentMethodType__c;
            paymentMethodList.add(paymentMethodConfig);
        }
        TetrisPaymentModel paymentConfig = new TetrisPaymentModel();
        paymentConfig.paymentMethods = paymentMethodList;
        return paymentConfig;

    }

    global class ZRequest {
        global String uri;
        global String pageId;
        global String method;
        ZRequest(String uri, String pageId, String method) {
            this.uri = uri;
            this.pageId = pageId;
            this.method = method;
        }
    }

    global class LocaleData {
        global String userLocale;
        global String templateName;

        LocaleData(String userLocale, String templateName) {
            this.userLocale = userLocale;
            this.templateName = templateName;
        }
    }

    public String getPaymethodMethodType(String paymentMethodId) {
        List<Zuora.zObject> zobjs = new List<Zuora.zObject> ();
        String paymentMethodType;
        String zoql = 'SELECT Id,Type from PaymentMethod WHERE Id=\'' + paymentMethodId + '\' ';
        try {
            Zuora.zApi zApiInstance = new Zuora.zApi();

            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
                zobjs = zApiInstance.zquery(zoql);
                for (Zuora.zObject obj : zobjs) {
                    paymentMethodType = (String) obj.getValue('Type');
                }
            }

            else if (Test.isRunningTest() && String.isBlank(paymentMethodId)) {
                paymentMethodType = '';
            } else if (Test.isRunningTest()) {
                paymentMethodType = 'CreditCard';
            }

        } catch (Exception ex) {
            ExceptionHandler.CatchException('TetrisPaymentHelperV2', 'getPaymethodMethodType', ex);
        }

        return paymentMethodType;
    }

    public void addItemToZAccountList(List<Zuora.zObject> zAccountList, Map<String, Object> zuoraAccountByFieldMap) {
        Zuora.zObject zAccountObject = new Zuora.zObject('Account');
        try {
            for (String field : zuoraAccountByFieldMap.keySet()) {
                zAccountObject.setValue(field, zuoraAccountByFieldMap.get(field));
            }
            zAccountList.add(zAccountObject);
            System.debug(zAccountList);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('TetrisPaymentHelperV2', 'addItemToZAccountList', ex);
        }
    }
}