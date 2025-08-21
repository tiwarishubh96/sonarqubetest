public class SageApiTryNowConvertActivityUtils {
    public static Boolean validatePayload(SageApiActivity__c activity, SageApiActivityStep step, List<Product_Tier__c> productTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans, List<PayNowToken__c> tokens, Map<String, List<SageApiActivityRequestObjects.Product>> tokenProductsMap, Map<String, SageApiActivity__c> tokenTryNowActivityMap, Map<String, Subscription_Master__c> subscriptionMasterMap) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (activity == null || step == null)
            return false;

        SageApiTryNowConvertActivityRequest req = null;
        try {
            req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowConvertActivityRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        if (req == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid: null value resulted from deserialization');
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        SageApiActivityUtils.debug('validatePayload req: ['+ req + ']');

        if (String.isBlank(req.cbcTrialId))
            return validateTryNowConvertPayload(activity, step, productTiers, productTierRatePlans, tokens, tokenProductsMap, tokenTryNowActivityMap);

        return validateTetrisConvertTrialPayload(activity, step, subscriptionMasterMap);
    }

    @TestVisible
    private static Boolean validateTryNowConvertPayload(SageApiActivity__c activity, SageApiActivityStep step, List<Product_Tier__c> productTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans, List<PayNowToken__c> tokens, Map<String, List<SageApiActivityRequestObjects.Product>> tokenProductsMap, Map<String, SageApiActivity__c> tokenTryNowActivityMap) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();
        SageApiTryNowConvertActivityRequest req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowConvertActivityRequest.class);

        // validate root-level attributes
        if (String.isBlank(req.accountId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'accountId', 'accountId must not be null');

        if (String.isBlank(req.payNowToken) && String.isBlank(req.quoteId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'quoteId', 'quoteId must not be null');

        activity.Account__c = req.accountId;
        activity.Quote__c = req.quoteId;
        activity.QuoteMetricsCalculated__c = true;
        if (tokens != null)
            for (PayNowToken__c token : tokens)
                if (token.Name == req.payNowToken) {
                    activity.PayNowToken__c = token.Id;
                    break;
                }

        // validate products
        if (String.isNotBlank(activity.PayNowToken__c)) {
            if (tokenTryNowActivityMap != null && tokenTryNowActivityMap.size() > 0) {
                SageApiActivity__c tryNowActivity = tokenTryNowActivityMap.get(req.payNowToken);
                if (tryNowActivity != null) {
                    activity.Opportunity__c = tryNowActivity.Opportunity__c;
                    activity.Contact__c = tryNowActivity.Contact__c;
                }
            }

            List<SageApiActivityRequestObjects.Product> products = tokenProductsMap.get(req.payNowToken);
            if (products == null || products.size() == 0)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'products', 'Products is required (not found in PayNowToken record)');

            if (products != null) {
                if (products.size() > 1)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.ValueOutOfRange, 'tierCode', 'Only one Product Tier Code is supported (in PayNowToken record)');

                if (products.size() > 0 && String.IsBlank(products[0].tierCode))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code is required (in PayNowToken record)');

                if (products.size() > 0 && String.IsBlank(products[0].tierRatePlanCode))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code is required (in PayNowToken record)');

                Boolean hasMatchingPt = false;
                for (Product_Tier__c pt : productTiers) {
                    if (pt.Product_Tier_Code__c == products[0].tierCode) {
                        hasMatchingPt = true;
                        break;
                    }
                }

                if (!hasMatchingPt)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code not found (in PayNowToken record)');

                Boolean hasMatchingPtrp = false;
                for (Product_Tier_Rate_Plan__c ptrp : productTierRatePlans) {
                    if (ptrp == null) continue;
                    if (ptrp.Product_Tier__r.Product_Tier_Code__c == products[0].tierCode && ptrp.name == products[0].tierRatePlanCode) {
                        hasMatchingPtrp = true;
                        activity.ProductTierRatePlan__c = ptrp.Id;
                        // if has valid product config in token, quote will be reset for recreation
                        activity.QuoteMetricsCalculated__c = false;
                        break;
                    }
                }

                if (!hasMatchingPtrp)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code not found (in PayNowToken record)');
            }
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityUtils.setSuccess(activity, step);
        SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        return true;
    }

    private static Boolean validateTetrisConvertTrialPayload(SageApiActivity__c activity, SageApiActivityStep step, Map<String, Subscription_Master__c> subscriptionMasterMap) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        SageApiTryNowConvertActivityRequest req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowConvertActivityRequest.class);

        // validate root-level attributes
        if (String.isBlank(req.cbcTrialId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'cbcTrialId', 'cbcTrialId must not be null');

        if (String.isBlank(req.zuoraSubscriptionId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'zuoraSubscriptionId', 'zuoraSubscriptionId must not be null');

        if (subscriptionMasterMap == null || subscriptionMasterMap.size() == 0)
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'cbcTrialId', 'cbcTrialId is not valid');

        if (String.isNotBlank(req.cbcTrialId)) {
            SageApiActivityUtils.debug('sm: ' + JSON.serialize(subscriptionMasterMap));
            Subscription_Master__c sm = subscriptionMasterMap.get(req.cbcTrialId);
            if (sm == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'cbcTrialId', 'cbcTrialId is not valid, no matching found');
            else {
                activity.Account__c = sm.Account__c;
                activity.SubscriptionMaster__c = sm.Id;
                activity.Opportunity__c = sm.Sage_API_Activity__r.Opportunity__c;
            }
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        activity.ZuoraSubscriptionId__c = req.zuoraSubscriptionId;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityUtils.setSuccess(activity, step);
        SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        return true;
    }

    public static void updateQuote(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        SageApiActivityUtils.debug('SageApiTryNowConvertActivityUtils.upateQuote starts: '+JSON.serialize(activities));
        if (activities == null || activities.size() == 0) return;

        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        Map<ID, zqu__Quote__c> activityQuoteMap = new Map<ID, zqu__Quote__c>();
        List<zqu__Quote__c> quotesToUpdate = null;

        for (SageApiActivity__c activity : activities) {
            SageApiTryNowConvertActivityRequest req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowConvertActivityRequest.class);

            if (String.IsNotBlank(activity.ZuoraSubscriptionId__c) || String.IsNotBlank(activity.Quote__c) && activity.QuoteMetricsCalculated__c) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            activityQuoteMap.put(activity.Id, new zqu__Quote__c(ID=activity.Quote__c));
            candidateActivities.add(activity);
        }

        if (candidateActivities.size() == 0) return;
        quotesToUpdate = [SELECT ID, zqu__Account__r.Name, zqu__StartDate__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE ID IN: activityQuoteMap.values()];
        List<PayNowToken__c> tokens = SageApiBuyNowActivityUtils.getPayNowTokens(candidateActivities);
        //Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = SageApiBuyNowActivityUtils.getPayNowTokens(candidateActivities);
        //List<PayNowToken__c> tokens = (tokenActivityMap == null ? null : new List<PayNowToken__c>(tokenActivityMap.keySet()));

        Map<ID, PayNowToken__c> tokenMap = new Map<ID, PayNowToken__c>();
        List<SageApiActivityRequestObjects.Product> allProducts = new List<SageApiActivityRequestObjects.Product>();
        Map<ID, List<SageApiActivityRequestObjects.Product>> tokenProductsMap = new Map<ID, List<SageApiActivityRequestObjects.Product>>();
        Map<String, String> tierCodeMap = new Map<String, String>();

        if (tokens != null)
            for (PayNowToken__c token : tokens) {
                tokenMap.put(token.Id, token);
                if (String.isBlank(token.Products__c)) continue;

                List<SageApiActivityRequestObjects.ProductConfig> productConfigs = (List<SageApiActivityRequestObjects.ProductConfig>) JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                if (productConfigs == null || productConfigs.size() == 0) continue;

                List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
                for (SageApiActivityRequestObjects.ProductConfig productConfig : productConfigs) {
                    SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                    product.tierCode = productConfig.tierCode;
                    product.pricingCode = productConfig.pricingCode;
                    if (String.isBlank(product.pricingCode))
                        product.pricingCode = '_LIST';
                    if (productConfig.tierRatePlanCodes!=null && productConfig.tierRatePlanCodes.size()>0)
                        product.tierRatePlanCode = productConfig.tierRatePlanCodes[0].tierRatePlanCode;
                    products.add(product);
                    allProducts.add(product);
                    tierCodeMap.put(product.tierCode, product.tierCode);
                }
                tokenProductsMap.put(token.Id, products);
            }

        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(allProducts);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(allProducts);
        Map<ID, Account> accountMap = new Map<ID, Account>();
        if (tierCodeMap.size() > 0)
            for (Product_Tier__c tierCode : [SELECT Id, Product_Tier_Code__c, Product__r.Name FROM Product_Tier__c WHERE Product_Tier_Code__c IN: tierCodeMap.keyset()])
                tierCodeMap.put(tierCode.Product_Tier_Code__c, tierCode.Product__r.Name);

        Integer index = 0;
        for (SageApiActivity__c activity : candidateActivities) {
            try {
                PayNowToken__c token = tokenMap.get(activity.PayNowToken__c);
                zqu__Quote__c quote = quotesToUpdate[index];
                quote.zqu__PaymentMethod__c = token.PaymentMethodType__c;
                quote.zqu__ElectronicPaymentMethodId__c = token.Quote_Payment_Method_ID__c;

                List<SageApiActivityRequestObjects.Product> products = tokenProductsMap.get(activity.PayNowToken__c);
                string productName = tierCodeMap.get(products[0].tierCode);
                Product_Tier_Rate_Plan__c tierData = listTierMap.get(products[0].tierCode+':'+products[0].tierRatePlanCode);
                String name = quote.zqu__Account__r.Name;
                if ((name + ' - ' + productName).length() > 80)
                    name = name.substring(0, 80 - (' - ' + productName).length());
                quote.Name = name + ' - ' + productName;
                quote.zqu__Currency__c = tierData.CurrencyIsoCode;

                if (quote.zqu__StartDate__c < Date.today())
                    quote.zqu__StartDate__c = Date.today();

                accountMap.put(activity.Account__c, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowConvertActivityUtils', 'upateQuotes', ex);
                continue;
            }
        }

        SageApiActivityUtils.debug('quotes to be processed: ' + quotesToUpdate);

        //process batch save results
        Database.UpsertResult [] quoteResults = Database.upsert(quotesToUpdate, false);
        SageApiActivityUtils.debug('quotes updated: '+quotesToUpdate);
        List<SageApiActivity__c> QuoteRatePlanChargeActivities = new List<SageApiActivity__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(allProducts, true);
        SageApiActivityUtils.debug('pricingChargeMap: '+pricingChargeMap);
        index = 0;
        for(Database.UpsertResult result : quoteResults) {
            SageApiActivity__c activity = candidateActivities[index];
            index++;
            List<SageApiActivityRequestObjects.Product> products = tokenProductsMap.get(activity.PayNowToken__c);
            SageApiActivityRequestObjects.Product product = products[0];

            if (result.isSuccess()) {
                ID quoteId = result.getId();
                SageApiActivityUtils.debug('quote updated: '+quoteId);

                //this should be done on seprate unit to be idemopotent
                zqu.zChargeGroup chargeGroup = null;
                try {
                    List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
                    SageApiActivityUtils.debug('chargeGroups: ' + chargeGroups);
                    if (chargeGroups != null && chargeGroups.size() > 0)
                        zqu.zQuoteUtil.deleteChargeGroups(chargeGroups);
                    SageApiActivityUtils.debug('after deleting chargeGroups');

                    Product_Tier_Rate_Plan__c tierData = listTierMap.get(product.tierCode+':'+product.tierRatePlanCode);
                    SageApiActivityUtils.debug( 'tierData.Product_Rate_Plan__c:'+ tierData.Product_Rate_Plan__c);

                    chargeGroup = zqu.zQuoteUtil.getChargeGroup(quoteId, tierData.Product_Rate_Plan__c);
                    List<PricingCodeCharge__c> pricingCharges = pricingChargeMap.get(product.tierCode+':'+product.tierRatePlanCode+':'+product.pricingCode);
                    if (pricingCharges != null && pricingCharges.size()>0) {
                        Boolean hasEffectivePriceChange = false;
                        //Boolean hasDiscountChange = false;
                        for (zqu.zCharge charge : chargeGroup.zCharges) {
                            SageApiActivityUtils.debug( 'charge before:'+ charge);
                            if( charge.CHARGE_TYPE != 'Recurring') continue;
                            SageApiActivityUtils.debug( 'charge.MODEL:'+ charge.MODEL);

                            for (PricingCodeCharge__c pricingCharge : pricingCharges) {
                                SageApiActivityUtils.debug( 'charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID:'+ charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                                if (charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID != pricingCharge.Product_Rate_Plan_Charge__c) continue;
                                SageApiActivityUtils.debug( 'charge.EFFECTIVE_PRICE:'+ charge.EFFECTIVE_PRICE);
                                SageApiActivityUtils.debug( 'pricingCharge.PublishedDiscountPrice__c:'+ pricingCharge.PublishedDiscountPrice__c);
                                SageApiActivityUtils.debug( 'charge.discount:'+ charge.discount);
                                SageApiActivityUtils.debug( 'pricingCharge.PublishedDiscountPercent__c:'+ pricingCharge.PublishedDiscountPercent__c);
                                ////* NOT supported with this version of Zuora
                                //charge.UPTO_PERIODS = String.valueOf(pricingCharge.NumberOfPeriods__c);
                                if (charge.MODEL == 'Discount-Fixed Amount' || charge.MODEL == 'Flat Fee Pricing') {
                                    if (pricingCharge.PublishedDiscountPrice__c == null || charge.EFFECTIVE_PRICE == String.valueOf(pricingCharge.PublishedDiscountPrice__c)) continue;
                                    charge.EFFECTIVE_PRICE = String.valueOf(pricingCharge.PublishedDiscountPrice__c);
                                    hasEffectivePriceChange = true;
                                    if (charge.isListPriceEditable())
                                        charge.overrideListPrice(pricingCharge.PublishedDiscountPrice__c);
                                } else if (charge.MODEL == 'Discount-Percentage') {
                                    if (pricingCharge.PublishedDiscountPercent__c == null || charge.EFFECTIVE_PRICE == String.valueOf(pricingCharge.PublishedDiscountPercent__c)) continue;
                                    charge.EFFECTIVE_PRICE = String.valueOf(pricingCharge.PublishedDiscountPercent__c);
                                    hasEffectivePriceChange = true;
                                }
                                if (charge.isUpToPeriodsEditable) {
                                    if (pricingCharge.PublishedNumberOfPeriods__c > 0) {
                                        charge.END_DATE_CONDITION = 'Fixed Period';
                                        charge.UPTO_PERIODS_TYPE = 'Billing Periods';
                                        charge.UPTO_PERIODS = String.valueOf(pricingCharge.PublishedNumberOfPeriods__c);
                                    } else if (charge.isEndDateConditionEditable){
                                        charge.END_DATE_CONDITION = 'Subscription End Date';
                                    }
                                }
                                SageApiActivityUtils.debug( 'charge after:'+ charge);
                            }
                        }
                        SageApiActivityUtils.debug( 'hasEffectivePriceChange:'+ hasEffectivePriceChange);
                        //SageApiActivityUtils.debug( 'hasDiscountChange:'+ hasDiscountChange);

                        if (hasEffectivePriceChange)
                            zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
                        //if (hasDiscountChange)
                        //    zqu.zQuoteUtil.calculateChargesOnDiscountChange(chargeGroup.zCharges);
                    }
                } catch(Exception ex) {
                    SageApiActivityUtils.debug('Error when getChargeGroup: '+ex);
                    ExceptionHandler.CatchException('SageApiTryNowConvertActivityUtils', 'upateQuotes', ex);
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'upateQuotes', 'Quote getChargeGroup failed. More detail: ' + ex);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    continue;
                }

                try {
                    chargeGroup = zqu.ZQuoteUtil.addChargeGroup(chargeGroup);
                    activity.QuoteMetricsCalculated__c = true;
                    SageApiActivityUtils.setSuccess(activity, step);
                    SageApiActivityUtils.debug('chargeGroup after zqu.zQuoteUtil.addChargeGroup: ' + chargeGroup);
                } catch(Exception ex) {
                    SageApiActivityUtils.debug('Error when addChargeGroup: '+ex);
                    ExceptionHandler.CatchException('SageApiTryNowConvertActivityUtils', 'upateQuotes', ex);
                    activity.QuoteMetricsCalculated__c = false;
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'upateQuotes', 'Quote addChargeGroup failed. More detail: ' + ex);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                }

                SageApiActivityUtils.debug('SageApiTryNowConvertActivityUtils.upateQuotes: pricing preview preparation completed');
                continue;
            }
            //if (!result.isSuccess() && errStr.contains('The Quote metrics value is the latest'))
            //    continue;
            Boolean retryable = true;
            String detailMsg = '';
            for (Database.Error err : result.getErrors()) {
                SageApiActivityUtils.debug('err: ' + err);
                if (err.getStatusCode() != StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY)
                    continue;
                detailMsg = 'Please verify Zuora Quote Template ID (Salesforce ID) is correct for this org.';
                retryable = false;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'upateQuotes', 'Quote creation failed. ' + detailMsg + ' More detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.debug('SageApiTryNowConvertActivityUtils.upateQuote');
    }

    public static void updateArtifact(SageApiActivity__c activity, List<SageApiActivityError> errors) {
        SageApiBuyNowActivityResponse response = null;
        if (String.isNotBlank(activity.Artifacts__c))
            response = (SageApiBuyNowActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiBuyNowActivityResponse.class);
        if (response == null)
            response = SageApiBuyNowActivityUtils.createResponse();

        response.activityId = activity.ActivityID__c;
        response.status = activity.ActivityStatus__c;
        response.errors = errors;
        response.data.accountId = String.ValueOf(activity.Account__c);
        response.data.quoteId = String.ValueOf(activity.Quote__c);
        response.data.assetId = activity.SubscriptionMaster__c;
        response.data.subscriptionId = activity.ZuoraSubscriptionId__c;
        response.data.cbcTrialId = activity.SubscriptionMaster__r.cbcSubscriptionId__c;
        response.data.cbcSubscriptionId = activity.SubscriptionMaster__r.cbcSubscriptionId__c;
        if (activity.ActivityStatus__c == SageApiStatus.Success)
            response.errors = null;

        string artifact = JSON.serialize(response);
        if (artifact.length() > 131072)
            artifact = artifact.substring(0, 131060) + '.TRUNCATED.';
        activity.Artifacts__c = artifact;
        SageApiActivityUtils.debug('activity.Artifacts__c: '+activity.Artifacts__c);
    }
}