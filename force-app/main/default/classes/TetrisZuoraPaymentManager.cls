global without sharing class TetrisZuoraPaymentManager {
    
    private static final String PAYMENT_PAGE_NAME = 'Tetris R2';
    
    @RemoteAction
    global static ZPaymentPage loadPage(String pageName , String countryLocale)
    {
        
        return requestSignatureV2(pageName , countryLocale);
    }
    /**
    * Fetch payment page parameters for given SF page reference
    * @param sfPageRef
    **/
    public static ZPaymentPage requestSignatureV2(String sfPageRef , String countryLocale) {
        try {
            String countryCode = countryLocale.substring(3);
            System.debug(countryCode);
            zqu__HostedPageLiteSetting__c paymentPage = Database.query('SELECT Id, zqu__PageId__c, Name FROM zqu__HostedPageLiteSetting__c'+
                                                                        ' where Country_Code__c=\''+countryCode+'\' and zqu__PaymentMethodType__c=\''+
                                                                        sfPageRef+'\' and Name like \'%'+PAYMENT_PAGE_NAME+'%\'');
            // get and set parameters for this reference
            //sfPageRef = sfPageRef.replace(' ','');
            system.debug('----------paymentPage----------'+paymentPage);
            ZuoraPaymentPageSetting__c zPageSetting= paymentPageSettingMap.get('ZuoraLoginDetails');
            System.debug('----------zPageSetting----------'+zPageSetting);
            //String pageId=zPageSetting.ppPageID__c;
            String pageId = paymentPage.zqu__PageId__c;
            System.debug('----------pageId----------'+pageId);
            String apiAccessID = zPageSetting.apiAccessID__c;
            String apiAccessKey = zPageSetting.apiAccessKey__c;
            String sigEndpoint = zPageSetting.ppDomain__c+zPageSetting.ppSignaturePath__c;
            String pageURI = zPageSetting.ppDomain__c+zPageSetting.ppPageRef__c;

            System.debug('pageURI: '+pageURI);
            System.debug('apiAccessID: '+apiAccessID);
            System.debug('apiAccessKey: '+apiAccessKey);
            System.debug('sigEndpoint: '+sigEndpoint);
            System.debug('pageURI: '+pageURI);

            // build request query object
            requestQueryV2 reqObj = new requestQueryV2(pageURI, pageId, 'POST');
            // callout request for parameters
            ZClient.RESTCalloutResult sigResult=ZClient.restCallout(sigEndpoint,'POST', reqObj,
                                                                    apiAccessID, apiAccessKey);
            system.debug('REST response final body :'+sigResult.responseBody);
            //
            // parse results and return all required iframe payment page parameters
            return new ZPaymentPage(sigResult, pageURI, pageId , countryLocale);
            //
        }catch(exception e){
            System.debug('ERROR:' + e);
            ExceptionHandler.CatchException('ZuoraPaymentPageUtility','requestSignatureV2',e);
        }
        return new ZPaymentPage('ERROR');
    }
    
    /** 
    * Map of all Payment Page custom settings for the required domain
    **/
    private static Map<String, ZuoraPaymentPageSetting__c> paymentPageSettingMap {
        get {
            system.debug('-------came in pageURI');
            if (paymentPageSettingMap == null) {
                paymentPageSettingMap = new Map<String, ZuoraPaymentPageSetting__c>();
                for(ZuoraPaymentPageSetting__c zif : ZuoraPaymentPageSetting__c.getAll().values()) {
                    if(zif.ppDomain__c==System.Label.ZAPI_DOMAIN) {
                        paymentPageSettingMap.put(zif.SFPageKey__c, zif);
                        System.debug('----paymentPageSettingMap---------'+paymentPageSettingMap);
                    } else {
                        if(Test.IsRunningTest())
                        {
                            paymentPageSettingMap.put(zif.SFPageKey__c, zif);
                        }
                    }
                }
            }
            return paymentPageSettingMap;
        }set;
    }
    
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
        public ZPaymentPage(ZClient.RESTCalloutResult sigResult, String pageURI, String pageId , String countryLocale) {
            system.debug('constructor:'+sigResult);
            if((boolean)sigResult.responseMap.get('success')) {
                //zppLocale = localeName.substring(0,2);
                //zppFieldcurrency=acc.CurrencyIsoCode;
                status='SUCCESS';
                zppTenantId=(String)sigResult.responseMap.get('tenantId');
                zppToken=(String)sigResult.responseMap.get('token');
                zppKey=(String)sigResult.responseMap.get('key');
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
}