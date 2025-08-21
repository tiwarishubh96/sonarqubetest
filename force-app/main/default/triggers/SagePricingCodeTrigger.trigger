trigger SagePricingCodeTrigger on PricingCode__c (before insert, before update, before delete, after update) {
    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {

        /* Before Delete */
        if (Trigger.isBefore && Trigger.isDelete)
            for (PricingCode__c c : Trigger.old)
                if (c.IsDeleted__c == false)
                    c.addError('If you really want to delete this record, please go to record detail and click on Delete button.');
            
        /* Before Insert or Update */
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            List<ID> productTierRatePlanIds = new List<ID>();
            for (PricingCode__c c : Trigger.new)
                productTierRatePlanIds.add(c.ProductTierRatePlanCode__c);
            
            List<Product_Tier_Rate_Plan__c> tierRatePlans = [SELECT Product_Tier__r.Product_Tier_Code__c,Name,Product_Rate_Plan__c,Id,Product_Tier__c FROM Product_Tier_Rate_Plan__c WHERE ID IN:productTierRatePlanIds];
            List<ID> productRatePlanIds = new List<ID>();
            for (Product_Tier_Rate_Plan__c r : tierRatePlans)
                productRatePlanIds.add(r.Product_Rate_Plan__c);
            List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = [SELECT Id,Name,zqu__ProductRatePlan__c,zqu__RecurringPeriod__c,zqu__Type__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN:productRatePlanIds];

            //1. when status is set to inSync from Azure side, not doing anything
            //2. when status is flipped to modified, revision will be updated
            //3. how to rollback when update is abandoned
            //4. cannot publish if no charge
            for (PricingCode__c c : Trigger.new)  {
                system.debug('status: ' + c.SyncStatus__c);

                // new record
                if (String.isBlank(c.Id)) {
                    c.SyncStatus__c = 'is modified';
                } else {
                    PricingCode__c old = Trigger.oldMap.get(c.Id);
                    // coming from payment URL demo, do nothing
                    if (old.PaymentUrl__c != c.PaymentUrl__c) continue;
                    // coming from Azure or sync button, do nothing
                    if ((old.SyncStatus__c != 'publish requested' && c.SyncStatus__c == 'publish requested') || (old.SyncStatus__c != 'publish in progress' && c.SyncStatus__c == 'publish in progress') || (old.SyncStatus__c != 'published' && c.SyncStatus__c == 'published') || (old.NumberOfViews__c != c.NumberOfViews__c))
                        continue;

                    c.SyncStatus__c = 'is modified';
                }

                system.debug('status: ' + c.SyncStatus__c);

                // update JSON
                SagePricingJsonObject.PricingCode pc = new SagePricingJsonObject.PricingCode();
                pc.pricingCode=c.Name;
                pc.isCustomerPromo=c.Is_Customer_Promo__c;
                for(Product_Tier_Rate_Plan__c rp : tierRatePlans) {
                    if (rp.ID != c.ProductTierRatePlanCode__c) continue;                 
                    pc.tierCode=rp.Product_Tier__r.Product_Tier_Code__c;
                    pc.tierRatePlanCode=rp.Name;
                }
                pc.startDate=String.valueOf(c.Start_Date__c);
                pc.endDate=String.valueOf(c.End_Date__c);
                pc.description=c.Description__c;
                pc.currencyCode=c.CurrencyIsoCode;
                pc.originalPriceTotal=c.OriginalPriceTotal__c;
                pc.promotionalPriceTotal=c.PromotionalPriceTotal__c;
                pc.promotionalPriceDiscount=c.promotionalPriceDiscount__c;
                pc.promotionalDiscountMonths=c.Promotional_Discount_Months__c > 0 ? Integer.valueOf(c.Promotional_Discount_Months__c) : null;
                pc.includesTax=c.IncludesTax__c;
                pc.isDeleted=c.IsDeleted__c;
                if (String.isNotBlank(c.ValidFor__c))
                    pc.validFor = c.ValidFor__c.split(';');

                //pc.syncId=GenericUtilities.getRandomUUIDv4();
                //c.SyncId__c = pc.syncId;
                List<PricingCodeCharge__c> codeCharges = [SELECT Product_Rate_Plan_Charge__r.zqu__Model__c,Product_Rate_Plan_Charge__r.zqu__RecurringPeriod__c,Product_Rate_Plan_Charge__r.Name,DiscountPercent__c,DiscountPrice__c,Id,IsDeleted,Name,NumberOfPeriods__c,Pricing_Code__c,ProductTierRatePlan__c,ProductTier__c,Product_Rate_Plan_Charge__c,Product_Rate_Plan__c,RatePlanName__c,ZProduct__c,ZuoraRatePlanId__c FROM PricingCodeCharge__c WHERE Pricing_Code__c =: c.Id AND IsDeleted = false];
                if (codeCharges != null && codeCharges.size() > 0) {
                    List<SagePricingJsonObject.PricingCodeCharge> pccs = new List<SagePricingJsonObject.PricingCodeCharge>();
                    for (PricingCodeCharge__c pcc : codeCharges) {
                        SagePricingJsonObject.PricingCodeCharge cc = new SagePricingJsonObject.PricingCodeCharge();
                        cc.pricingCodeChargeName = pcc.Name;
                        cc.productRatePlanCharge = pcc.Product_Rate_Plan_Charge__r.Name;
                        cc.chargeModel = pcc.Product_Rate_Plan_Charge__r.zqu__Model__c;
                        cc.billingPeriod = pcc.Product_Rate_Plan_Charge__r.zqu__RecurringPeriod__c;
                        cc.discountPrice = String.valueOf(pcc.DiscountPrice__c);
                        cc.discountPrice = String.valueOf(pcc.DiscountPrice__c);
                        cc.discountPercent = String.valueOf(pcc.DiscountPercent__c);
                        cc.numberOfPeriods = String.valueOf(pcc.NumberOfPeriods__c);
                        pccs.add(cc);
                    }
                    //pc.pricingCodeCharges = pccs;
                }
                c.JsonRepresentation__c = JSON.serialize(pc);
            }
        }

        /* After Update */
        if (Trigger.isAfter && Trigger.isUpdate) {
            system.debug('after update trigger');
            List<PricingCode__c> codes = new List<PricingCode__c>();
            for (PricingCode__c c : Trigger.new) {
                system.debug('c.SyncStatus__c = ' + c.SyncStatus__c);
                PricingCode__c old = Trigger.oldMap.get(c.Id);
                if (old.SyncStatus__c != 'published' && c.SyncStatus__c == 'published')
                    codes.add(c);
            }

            if (codes.size() > 0) {
                List<PricingCodeCharge__c> charges = [SELECT Id, DiscountPrice__c, DiscountPercent__c, NumberOfPeriods__c, PublishedDiscountPrice__c, PublishedDiscountPercent__c, PublishedNumberOfPeriods__c FROM PricingCodeCharge__c WHERE Pricing_Code__c IN: codes];
                for (PricingCodeCharge__c charge : charges) {
                    if (charge.DiscountPrice__c > 0) {
                        charge.PublishedDiscountPrice__c = charge.DiscountPrice__c;
                        charge.DiscountPrice__c = null;
                    }
                    if (charge.DiscountPercent__c > 0) {
                        charge.PublishedDiscountPercent__c = charge.DiscountPercent__c;
                        charge.DiscountPercent__c = null;
                    }
                    if (charge.NumberOfPeriods__c > 0) {
                        charge.PublishedNumberOfPeriods__c = charge.NumberOfPeriods__c;
                        charge.NumberOfPeriods__c = null;
                    }
                }
                update charges;
            }
        }
    }
}