global class SageApiActivityAjaxController
{
    webService static String resumeActivity(String activityId){
        if (String.isBlank(activityId)) return Label.ApiActivity_ActivityID_Required;

        SageApiActivity__c activity = [SELECT ID, ActivityStatus__c, ActivitySteps__c, LockedForProcess__c FROM SageApiActivity__c WHERE ID=:activityId AND ActivityStatus__c !=: SageApiStatus.Success];
        if (activity == null) return Label.ApiActivity_ActivityID_Invalid;
        if (activity.LockedForProcess__c == SageApiProcessLocks.Restarting)
            return Label.ApiActivity_Activity_Being_Restarted;

        if (activity.ActivityStatus__c == SageApiStatus.Restarting) {
            activity.ActivityStatus__c = null;
            activity.LockedForProcess__c = SageApiProcessLocks.None;
            update activity;
        }
        activity.ActivityStatus__c = SageApiStatus.Restarting;
        activity.LockedForProcess__c = SageApiProcessLocks.None;
        update activity;
        return Label.ApiActivity_Activity_Resumed;
    }

    webService static String abandonActivity(String activityId){
        if (String.isBlank(activityId)) 
            return Label.ApiActivity_ActivityID_Required;

        List<SageApiActivity__c> activities = [SELECT ID, ActivityType__c, Artifacts__c, ActivityStatus__c, ActivitySteps__c FROM SageApiActivity__c WHERE ID=:activityId AND ActivityStatus__c !=: SageApiStatus.Success];
        if (activities.isEmpty()) 
            return Label.ApiActivity_ActivityID_Invalid;
        SageApiActivity__c activity = activities[0];
        activity.ActivityStatus__c = SageApiStatus.Abandoned;
        activity.LockedForProcess__c = SageApiProcessLocks.None;

        if (String.isNotBlank(activity.Artifacts__c))
            if (activity.ActivityType__c == SageApiActivityTriggerHandler.TryNowActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisStartTrialActivityType) {
                SageApiTryNowActivityResponse res = (SageApiTryNowActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiTryNowActivityResponse.class);
                if (res != null) {
                    res.status = SageApiStatus.Abandoned;
                    activity.Artifacts__c = JSON.serialize(res);
                }
            }
            else if (activity.ActivityType__c == SageApiActivityTriggerHandler.BuyNowActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TryNowConvertActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisConvertTrialActivityType) {
                SageApiBuyNowActivityResponse res = (SageApiBuyNowActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiBuyNowActivityResponse.class);
                if (res != null) {
                    res.status = SageApiStatus.Abandoned;
                    activity.Artifacts__c = JSON.serialize(res);
                }
            }
            else if (activity.ActivityType__c == SageApiActivityTriggerHandler.LeadActivityType) {
                SageApiTryNowLeadActivityResponse res = (SageApiTryNowLeadActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiTryNowLeadActivityResponse.class);
                if (res != null) {
                    res.status = SageApiStatus.Abandoned;
                    activity.Artifacts__c = JSON.serialize(res);
                }
            }
            else if (activity.ActivityType__c == SageApiActivityTriggerHandler.AddCommunityUserType) {
                SageApiAddCommUserActivityResponse res = (SageApiAddCommUserActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiAddCommUserActivityResponse.class);
                if (res != null) {
                    res.status = SageApiStatus.Abandoned;
                    activity.Artifacts__c = JSON.serialize(res);
                }
            }
            else if (activity.ActivityType__c == SageApiActivityTriggerHandler.CreateSubscriptionActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.UpdateSubscriptionActivityType) {
                SageApiBuyNowActivityResponse res = (SageApiBuyNowActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiBuyNowActivityResponse.class);
                if (res != null) {
                    res.status = SageApiStatus.Abandoned;
                    activity.Artifacts__c = JSON.serialize(res);
                }
            }

        update activity;
        return Label.ApiActivity_Activity_Abandoned;
    }

    webService static String deletePricingCode(String pricingCodeId) {
        if (String.isBlank(pricingCodeId)) 
            return Label.PricingCode_IdRequired;

        List<PricingCode__c> pricingCodes = [SELECT Description__c,End_Date__c,Id,IncludesTax__c,IsDeleted,Is_Customer_Promo__c,JsonRepresentation__c,Name,OriginalPriceTotal__c,ProductTierRatePlanCode__c,Product_Tier__c,PromotionalPriceTotal__c,Start_Date__c,SyncId__c,SyncStatus__c,ZuoraRatePlan__c FROM PricingCode__c WHERE ID=:pricingCodeId];
        if (pricingCodes == null || pricingCodes.size() == 0) 
            return Label.PricingCode_NotValid;

        for (PricingCode__c pc : pricingCodes)
            pc.IsDeleted__c = true;

        update pricingCodes;
        return Label.PricingCode_Deleted;
    }

    webService static String syncPricingCodeWithAzure(String pricingCodeId){
        if (String.isBlank(pricingCodeId)) 
            return Label.PricingCode_IdRequired;

        List<PricingCode__c> pricingCodes = [SELECT Description__c,End_Date__c,Id,IncludesTax__c,IsDeleted,Is_Customer_Promo__c,JsonRepresentation__c,Name,OriginalPriceTotal__c,ProductTierRatePlanCode__c,Product_Tier__c,PromotionalPriceTotal__c,Start_Date__c,SyncId__c,SyncStatus__c,ZuoraRatePlan__c FROM PricingCode__c WHERE ID=:pricingCodeId];
        if (pricingCodes == null || pricingCodes.size() == 0) 
            return Label.PricingCode_NotValid;

        PricingCode__c pricingCode = pricingCodes[0];

        if (pricingCode.Name != '_LIST') {
            List<PricingCodeCharge__c> codeCharges = [SELECT CurrencyIsoCode,DiscountPercent__c,DiscountPrice__c,Id,IsDeleted,ListPrice__c,Name,NumberOfPeriods__c,Pricing_Code__c,ProductTierRatePlan__c,ProductTier__c,Product_Rate_Plan_Charge__c,Product_Rate_Plan__c,RatePlanName__c,Product__c,ZuoraRatePlanId__c FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCodeId];
            if (codeCharges==null || codeCharges.size() == 0)
                return Label.PricingCode_NotConfigured;
        }

        //List<PricingCodeCharge__c> pricingCodeCharge = [SELECT CurrencyIsoCode,DiscountPercent__c,DiscountPrice__c,Id,IsDeleted,Name,NumberOfPeriods__c,Pricing_Code__c,ProductTierRatePlan__c,ProductTier__c,Product_Rate_Plan_Charge__c,Product_Rate_Plan__c,RatePlanName__c,Product__c,ZuoraRatePlanId__c FROM PricingCodeCharge__c WHERE Pricing_Code__c=:pricingCodeId];
        //if (pricingCodeCharge == null || pricingCodeCharge.size()==0) 
        //    return 'No valid pricing code charges are found in the selected pricing code.';

        if (pricingCode.SyncStatus__c != 'is modified') 
            return Label.PricingCode_NotModified;

        pricingCode.SyncStatus__c = 'publish requested';
        update pricingCode;

        return Label.PricingCode_PublishRequested;
    }

    webService static String createPaymentUrl(String pricingCodeId, String productTierCode, String productTierRatePlanCode){
        if (String.isBlank(productTierCode)) 
            return Label.PricingCode_TierCodeRequired;

        if (String.isBlank(productTierRatePlanCode)) 
            return Label.PricingCode_TierRatePlanCodeRequired;

        List<PricingCode__c> pricingCodes = [SELECT Id, Name FROM PricingCode__c WHERE ID=:pricingCodeId];
        if (pricingCodes == null || pricingCodes.size() == 0) return Label.PricingCode_NotExist + pricingCodeId;
        PricingCode__c pricingCode = pricingCodes[0];

/*
        List<PricingCodeCharge__c> pricingCodeCharges = [SELECT Name,Product_Rate_Plan_Charge__r.zqu__Model__c FROM PricingCodeCharge__c WHERE Pricing_Code__c=:pricingCodeId];

        Date theDate = Date.today().addDays(30);
        PaymentPayload payload = new PaymentPayload();
        payload.endDate = theDate.year() + '-' + theDate.month() + '-' + theDate.day();
        payload.products = new List<Product>();
        Product product = new Product();
        product.tierCode = productTierCode;
        product.tierRatePlanCode = productTierRatePlanCode;
        product.pricingCode = pricingCode.Name;
        //if (pricingCodeCharges != null && pricingCodeCharges.size()>0)
        //    for (PricingCodeCharge__c charge : pricingCodeCharges)
        //        if (charge.Product_Rate_Plan_Charge__r.zqu__Model__c.indexOfIgnoreCase('Discount') == 0) {
        //            product.pricingCode = charge.Name;
        //            break;
        //        }
                     
        payload.products.add(product);
        payload.successRedirectUrl = 'https://sage-commerce-dev-a.azurewebsites.net/Demo/PaymentSuccess';
        payload.errorRedirectUrl = 'https://sage-commerce-dev-a.azurewebsites.net/Demo/PaymentFailure';

        string baseUrl = 'https://sage-commerce-dev-a.azurewebsites.net';
        string userName = 'sageone-dev1';
        string password = 's@ge615!';
        string paymentUrl = null;
        
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        
        req.setEndpoint(baseUrl + '/api/PaymentMethods');
        req.setMethod('POST');
        req.setBody(JSON.serialize(payload));
        System.debug('payload: ' + JSON.serialize(payload));
        //req.setCompressed(true); // otherwise we hit a limit of 32000
            
        try {
            res = http.send(req);
            String jsonValue = res.getBody();
            System.debug(jsonValue);
            JSONParser parser = JSON.createParser(jsonValue);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'paymentUrl') {
                        paymentUrl = parser.getText();
                        break;
                    }
                }
            }
            
            System.debug(paymentUrl);
        } catch(Exception e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            ExceptionHandler.CatchException('SageApiActivityAjaxController', 'createPaymentUrl', e);
            return 'Error when creating Payment URL: ' + e;
        }

        pricingCode.PaymentUrl__c = paymentUrl;
*/
        pricingCode.PaymentUrl__c = PayNowSetting__c.getInstance('payNowBaseUrl').value__c + '/en/BuyNow/product/'+productTierCode+'/'+productTierRatePlanCode+'/'+pricingCode.Name;
        update pricingCode;
        return Label.PricingCode_PaymentUrlCreated;
    }

    webService static String createPricingCodeCharge(String pricingCodeId){
        if (String.isBlank(pricingCodeId)) 
            return Label.PricingCode_IdRequired;

        List<PricingCode__c> pricingCodes = [SELECT Id, Name, ProductTierRatePlanCode__c, Product_Tier__c, ProductTierRatePlanCode__r.Product_Rate_Plan__c, ProductTierRatePlanCode__r.Product_Rate_Plan__r.zqu__Product__c FROM PricingCode__c WHERE ID=:pricingCodeId];
        if (pricingCodes == null || pricingCodes.size() == 0) return Label.PricingCode_NotExist + pricingCodeId;
        PricingCode__c pricingCode = pricingCodes[0];

        List<PricingCodeCharge__c> codeCharges = [SELECT CurrencyIsoCode,DiscountPercent__c,DiscountPrice__c,Id,IsDeleted,ListPrice__c,Name,NumberOfPeriods__c,Pricing_Code__c,ProductTierRatePlan__c,ProductTier__c,Product_Rate_Plan_Charge__c,Product_Rate_Plan__c,RatePlanName__c,Product__c,ZuoraRatePlanId__c FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCodeId];

        if (codeCharges!=null && codeCharges.size() > 0)
            return Label.PricingCode_ChargesExist;

        List<zqu__ProductRatePlanCharge__c> planCharges = [SELECT CurrencyIsoCode,Id,IsDeleted,Name,zqu__AccountingCode__c,zqu__Deleted__c,zqu__Discount_Apply_Type__c,zqu__Discount_Level__c,zqu__ListPrice__c,zqu__Model__c,zqu__ProductRatePlan__c,zqu__ProductRatePlan__r.Name,zqu__RecurringPeriod__c,zqu__Type__c,zqu__Upto_How_Many_Periods__c,zqu__ZUnitOfMeasure__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__Deleted__c = false AND zqu__ProductRatePlan__c =: pricingCode.ProductTierRatePlanCode__r.Product_Rate_Plan__c];

        if (planCharges==null || planCharges.size()==0)
            return Label.PricingCode_ZuoraRatePlanChargesNotExist;

        List<zqu__ProductRatePlanChargeTier__c> planChargeTiers = [SELECT Id,IsDeleted,Name,zqu__Currency__c,zqu__Deleted__c,zqu__EndingUnit__c,zqu__IsOveragePrice__c,zqu__PriceFormat__c,zqu__Price__c,zqu__ProductRatePlanCharge__c,zqu__StartingUnit__c,zqu__Tier__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanChargeTier__c WHERE zqu__Deleted__c = false AND zqu__ProductRatePlanCharge__c =: planCharges];

        // https://knowledgecenter.zuora.com/DC_Developers/SOAP_API/E1_SOAP_API_Object_Reference/ProductRatePlanCharge
        // http://community.zuora.com/t5/Zuora-for-Salesforce/How-can-I-find-out-what-charge-type-a-discount-charge-is-mapped/td-p/8130
        // apply type: NULL(0), ONETIME(1), RECURRING(2), USAGE(4), ONETIMERECURRING(3), ONETIMEUSAGE(5), RECURRINGUSAGE(6), ONETIMERECURRINGUSAGE(7)
        codeCharges = new List<PricingCodeCharge__c>();
        for (zqu__ProductRatePlanCharge__c planCharge : planCharges) {
            PricingCodeCharge__c codeCharge = new PricingCodeCharge__c();
            codeCharge.Name = planCharge.Name;
            codeCharge.Product_Rate_Plan__c = planCharge.zqu__ProductRatePlan__c;
            codeCharge.Product_Rate_Plan_Charge__c = planCharge.Id;
            codeCharge.ProductTier__c = pricingCode.Product_Tier__c;
            codeCharge.ProductTierRatePlan__c = pricingCode.ProductTierRatePlanCode__c;
            codeCharge.Pricing_Code__c = pricingCode.Id;
            // formula fields
            //codeCharge.RatePlanName__c = planCharge.zqu__ProductRatePlan__r.Name;
            //codeCharge.ZuoraRatePlanId__c = planCharge.zqu__ZuoraId__c;
            //codeCharge.ListPrice__c = planCharge.zqu__ListPrice__c;
            codeCharge.Product__c = pricingCode.ProductTierRatePlanCode__r.Product_Rate_Plan__r.zqu__Product__c;
            codeCharge.NumberOfPeriods__c = planCharge.zqu__Upto_How_Many_Periods__c;

            List<zqu__ProductRatePlanChargeTier__c> tiers = new List<zqu__ProductRatePlanChargeTier__c>();
            for (zqu__ProductRatePlanChargeTier__c planChargeTier : planChargeTiers) {
                System.debug('compare: ' + planChargeTier.zqu__ProductRatePlanCharge__c + ' : ' + planCharge.Id);
                if (planChargeTier.zqu__ProductRatePlanCharge__c == planCharge.Id)
                    tiers.add(planChargeTier);
            }
            
            System.debug('tiers: ' + tiers);

            if (tiers.size() == 1) {
                codeCharge.CurrencyIsoCode = tiers[0].zqu__Currency__c;
                if (planCharge.zqu__Model__c == 'Discount-Percentage') 
                    codeCharge.DiscountPercent__c = tiers[0].zqu__Price__c;
                else //if (planCharge.zqu__Model__c == 'Discount-Fixed Amount')
                    codeCharge.DiscountPrice__c = tiers[0].zqu__Price__c;
            } else if (tiers.size() > 1) {
                for (zqu__ProductRatePlanChargeTier__c tier : tiers) {
                    if (tier.zqu__Currency__c == 'USD') continue;

                    codeCharge.CurrencyIsoCode = tier.zqu__Currency__c;
                    if (planCharge.zqu__Model__c == 'Discount-Percentage') 
                        codeCharge.DiscountPercent__c = tier.zqu__Price__c;
                    else //if (planCharge.zqu__Model__c == 'Discount-Fixed Amount')
                        codeCharge.DiscountPrice__c = tier.zqu__Price__c;
                }
            }

            codeCharges.add(codeCharge);
            System.debug('codeCharge: ' + codeCharge);
        }

        insert codeCharges;

        return Label.PricingCode_ChargesCreated;
    }

    webService static String createProductTierRatePlan(String productTierId) {
        if (String.isBlank(productTierId)) 
            return Label.ProductTier_IdRequired;

        List<Product_Tier__c> tiers = [SELECT Id,Name,Product_Tier_Code__c,Product_Use_Region__c,SageProduct__c,Product__c FROM Product_Tier__c WHERE Id =: productTierId];
        if (tiers==null || tiers.size()==0)
            return Label.ProductTier_TierNotExist;

        List<Product_Tier_Rate_Plan__c> tierRatePlans = [SELECT Id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c=:productTierId];
        if (tierRatePlans!=null && tierRatePlans.size()>0)
            return Label.ProductTier_TierRatePlansExist;

        Product_Tier__c tier = tiers[0];
        List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Id,Name,zqu__Description__c,zqu__EffectiveEndDate__c,zqu__EffectiveStartDate__c,zqu__Product__c,zqu__Product__r.Name,zqu__ZuoraId__c FROM zqu__ProductRatePlan__c WHERE zqu__Product__c =: tier.Product__c AND zqu__Deleted__c = false AND zqu__EffectiveEndDate__c >: System.Today()];
        if (productRatePlans==null || productRatePlans.size()==0)
            return Label.ProductTier_NoProductRatePlans;

        List<Locale__c> locales = [SELECT Country_Code__c,Country__c,Default_Locale__c,Id,LanguageLocaleKey__c,Language__c,Name,TimeZone__c FROM Locale__c WHERE Default_Locale__c='Yes' AND Country__c=:tier.Product_Use_Region__c]; 

        tierRatePlans = new List<Product_Tier_Rate_Plan__c>();
        for(zqu__ProductRatePlan__c prp : productRatePlans) {
            Product_Tier_Rate_Plan__c trp = new Product_Tier_Rate_Plan__c();
            trp.Name = '_TEMPLATE_'+prp.Name;
            trp.Start_Date__c = prp.zqu__EffectiveStartDate__c;
            trp.End_Date__c = prp.zqu__EffectiveEndDate__c;
            trp.Product_Rate_Plan__c = prp.Id;
            trp.Product_Tier__c = tier.Id;
            if (locales!=null && locales.size()>0)
                trp.Locale__c = locales[0].Id;
            tierRatePlans.add(trp);
        }
        insert tierRatePlans;

        return Label.ProductTier_RatePlanCreated;
    }

    class PaymentPayload {
        public String endDate;
        public List<Product> products;
        public String completionNotifyUrl;
        public String successRedirectUrl;
        public String errorRedirectUrl;
    }

    class Product {
        public String tierCode;
        public String tierRatePlanCode;
        public String pricingCode;
    }

    class PaymentResponse {
        public String paymentUrl;
    }

}