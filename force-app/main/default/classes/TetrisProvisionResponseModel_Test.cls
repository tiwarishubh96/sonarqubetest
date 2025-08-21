@isTest
public class TetrisProvisionResponseModel_Test {
    
    public static testmethod void testProvision(){
       
        TetrisProvisionResponseModel obj = new TetrisProvisionResponseModel();
        obj.channelPlatform='test';
        obj.tetrisSubscriptionId='testId';
        obj.isTrial=true;
        TetrisProvisionResponseModel.CustomObject customObj = new TetrisProvisionResponseModel.CustomObject();
        customObj.id='test';
        
        TetrisProvisionResponseModel.SubscriptionDateRange subs = new TetrisProvisionResponseModel.SubscriptionDateRange();
        subs.notAfter='yes';
        subs.notBefore='no';
        obj.effectivePeriod = subs;
        obj.entitledAccount  = customObj;
        obj.customerContact   =  customObj;    
        TetrisProvisionResponseModel.FeatureProperties featureProp = new  TetrisProvisionResponseModel.FeatureProperties();
        featureProp.name='feat prop';
        featureProp.value ='fet val';
        List<TetrisProvisionResponseModel.FeatureProperties> featurePropLst = new List<TetrisProvisionResponseModel.FeatureProperties>();
        featurePropLst.add(featureProp);
        TetrisProvisionResponseModel.FeatureInfo featureInfo = new  TetrisProvisionResponseModel.FeatureInfo();
        featureInfo.name='feat Info';
        featureInfo.properties = featurePropLst;
        List<TetrisProvisionResponseModel.FeatureInfo> featureInfoLst = new List<TetrisProvisionResponseModel.FeatureInfo>();
        featureInfoLst.add(featureInfo);
        TetrisProvisionResponseModel.ProductInfo prod = new  TetrisProvisionResponseModel.ProductInfo();
        prod.product='test';
        prod.features= featureInfoLst;
        TetrisProvisionResponseModel.IdentityInfo idInfo = new TetrisProvisionResponseModel.IdentityInfo();
        idInfo.idp='test';
        idInfo.idpId='test';
        TetrisProvisionResponseModel.ProductUserInfo prodUserInfo = new TetrisProvisionResponseModel.ProductUserInfo();
        prodUserInfo.product='prod';
        prodUserInfo.role='test role';
        List<TetrisProvisionResponseModel.ProductUserInfo> prodUserInfoLst =new List<TetrisProvisionResponseModel.ProductUserInfo>();
        prodUserInfoLst.add(prodUserInfo);
        TetrisProvisionResponseModel.ProductUsersInfo prodUsersInfo = new TetrisProvisionResponseModel.ProductUsersInfo();
        prodUsersInfo.identity= idInfo;
        prodUsersInfo.products = prodUserInfoLst;
        TetrisProvisionResponseModel.CustomerCommunityUsersInfo cust = new TetrisProvisionResponseModel.CustomerCommunityUsersInfo();
        cust.contactId='1234';
        cust.role='test';
        cust.identity = idInfo;
        
        
        
    }
}