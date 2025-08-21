/**
 * Created by cafe on 2/4/2021.
 */
@isTest
public class TetrisPaymentServiceV2_Test {

    private static final String BillingCountry = 'United States';
    private static final String BillingState = 'Georgia';
    private static final String BillingCity = 'Metropolis';
    private static final String BillingPostalCode = '23456';
    private static final String BillingAddress = 'addr 1';
    private static final String BillingEntityId = 'EntityId';
    private static final String BillingEntityName = 'EntityName';
    private static final String BillingName = 'TestBillingEntityName';

    private static final String paymentMethodType = 'Online';
    private static final String paymentMethodType2 = 'Offline';
    private static final String paymentGatewayName = 'Stripe';
    private static final String language = 'English ';
    private static final String currencyCode = 'GBP';
    private static final Boolean isDefault = true;
    private static final String pageId = 'TestPageId';
    private static final String pageId2 = 'TestPageId2';
    private static final String name = 'TestSetting';
    private static final String clientCode = 'Tetris';
    private static final String country = 'GB - United Kingdom';
    private static final String countryCode = 'GB';
    private static final String height = '200px';
    private static final String width = '200px';

    private static final String zuoraPaymentSettingName = 'Zuora Login Details';
    private static final String apiAccessId = 'TestPaymentAccessId';
    private static final String apiAccessKey = 'AccessKey';
    private static final String domain = 'Domain';
    private static final String signaturePath = 'SignaturePath';
    private static final String pageRef = 'PageRef';

    @testSetup static void setup() {
        ZuoraPaymentPageSetting__c zuoraPaymentSetting = new ZuoraPaymentPageSetting__c();
        zuoraPaymentSetting.apiAccessID__c = apiAccessId;
        zuoraPaymentSetting.apiAccessKey__c = apiAccessKey;
        zuoraPaymentSetting.ppDomain__c = domain;
        zuoraPaymentSetting.ppSignaturePath__c = signaturePath;
        zuoraPaymentSetting.ppPageRef__c = pageRef;
        zuoraPaymentSetting.Name = zuoraPaymentSettingName;
        insert zuoraPaymentSetting;
        System.debug('Test inserted zuora payment setting: ' + zuoraPaymentSetting);


        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.CurrencyIsoCode = currencyCode;
        billingEntity.Name = BillingName;
        billingEntity.zqu__Address1__c = BillingAddress;
        billingEntity.zqu__Address2__c = BillingAddress;
        billingEntity.zqu__City__c = BillingCity;
        billingEntity.zqu__Country__c = BillingCountry;
        billingEntity.zqu__EntityID__c = BillingEntityId;
        billingEntity.zqu__EntityName__c = BillingEntityName;
        billingEntity.zqu__GlobalEntityID__c = BillingEntityId;
        billingEntity.zqu__ParentEntityID__c = BillingEntityId;
        billingEntity.zqu__PostalCode__c = BillingPostalCode;
        billingEntity.zqu__State__c = BillingState;
        billingEntity.zqu__ZuoraId__c = BillingName;
        insert billingEntity;
        System.debug('Test inserted billing entity: ' + billingEntity);

        zqu__HostedPageLiteSetting__c paymentSetting = new zqu__HostedPageLiteSetting__c();
        paymentSetting.Client_Code__c = clientCode;
        paymentSetting.Country__c = country;
        paymentSetting.CurrencyIsoCode = currencyCode;
        paymentSetting.Language__c = language;
        paymentSetting.Payment_Gateway_Name__c = paymentGatewayName;
        paymentSetting.Name = name;
        paymentSetting.zqu__BillingEntity__c = billingEntity.Id;
        paymentSetting.zqu__ComponentName__c = name;
        paymentSetting.zqu__Default__c = isDefault;
        paymentSetting.zqu__PageId__c = pageId;
        paymentSetting.zqu__PaymentMethodType__c = paymentMethodType;
        paymentSetting.zqu__Height__c = height;
        paymentSetting.zqu__Width__c = width;
        insert paymentSetting;
        System.debug('Test inserted payment setting: ' + paymentSetting);

        zqu__HostedPageLiteSetting__c paymentSetting2 = new zqu__HostedPageLiteSetting__c();
        paymentSetting2.Client_Code__c = clientCode;
        paymentSetting2.Country__c = country;
        paymentSetting2.CurrencyIsoCode = currencyCode;
        paymentSetting2.Language__c = language;
        paymentSetting2.Payment_Gateway_Name__c = paymentGatewayName;
        paymentSetting2.Name = name;
        paymentSetting2.zqu__BillingEntity__c = billingEntity.Id;
        paymentSetting2.zqu__ComponentName__c = name;
        paymentSetting2.zqu__Default__c = isDefault;
        paymentSetting2.zqu__PageId__c = pageId2;
        paymentSetting2.zqu__PaymentMethodType__c = paymentMethodType2;
        paymentSetting2.zqu__Height__c = height;
        paymentSetting2.zqu__Width__c = width;
        insert paymentSetting2;
        System.debug('Test inserted payment setting2: ' + paymentSetting2);
    }

    @isTest static void testGetPaymentMethods() {
        TetrisPaymentModel tetrisPaymentModelObj = TetrisPaymentServiceV2.fetchPaymentMethods(countryCode, paymentMethodType);
        List<TetrisPaymentModel.PaymentMethod> listOfMethods = tetrisPaymentModelObj.paymentMethods;
        System.assertEquals(1, listOfMethods.size());
        TetrisPaymentModel.PaymentMethod paymentMethod = tetrisPaymentModelObj.paymentMethods[0];
        System.assertEquals(pageId, paymentMethod.paymentPageId);
        System.assertEquals(paymentMethodType, paymentMethod.paymentType);
        System.assertEquals(paymentGatewayName, paymentMethod.paymentGateway);
    }

    @isTest static void testGetPaymentMethodsException() {
        TetrisPaymentModel tetrisPaymentModelObj = TetrisPaymentServiceV2.fetchPaymentMethods('ABC', null);
        System.assertEquals('No Payment Pages configured for the Country ABC', tetrisPaymentModelObj.message);
    }

    @isTest static void testGetPaymentMethodsAll() {
        TetrisPaymentModel tetrisPaymentModelObj = TetrisPaymentServiceV2.fetchPaymentMethods(countryCode, '');
        List<TetrisPaymentModel.PaymentMethod> listOfMethods = tetrisPaymentModelObj.paymentMethods;
        System.assertEquals(2, listOfMethods.size());
    }
}