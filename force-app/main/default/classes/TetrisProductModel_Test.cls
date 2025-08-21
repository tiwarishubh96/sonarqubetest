@isTest(SeeAllData=false) 
private class TetrisProductModel_Test {
    
    static testMethod void testTetrisProductModel() {
        TetrisProductModel tetrisProductModel = new TetrisProductModel();
        //core set of attributes related to product
        
        tetrisProductModel.productId = 'a3r0E000000D63S';
        System.assertEquals(tetrisProductModel.productId, 'a3r0E000000D63S');
        
        tetrisProductModel.productType = 'Product';
        System.assertEquals(tetrisProductModel.productType, 'Product');
        
        tetrisProductModel.productName = 'Sage One Payroll_UK';
        System.assertEquals(tetrisProductModel.productName, 'Sage One Payroll_UK');
        
        tetrisProductModel.productSKU = 'sageone-uk-payroll';
        System.assertEquals(tetrisProductModel.productSKU, 'sageone-uk-payroll');
        
        tetrisProductModel.alternateName = 'sageone-uk-payroll';
        System.assertEquals(tetrisProductModel.alternateName, 'sageone-uk-payroll');
        
        tetrisProductModel.status = 'Released';
        System.assertEquals(tetrisProductModel.status, 'Released');
        
        tetrisProductModel.market = 'UKI';
        System.assertEquals(tetrisProductModel.market, 'UKI');
        
        tetrisProductModel.productFamily = 'Sage One';
        System.assertEquals(tetrisProductModel.productFamily, 'Sage One');
        
        tetrisProductModel.businessSize = 'Midsized';
        System.assertEquals(tetrisProductModel.businessSize, 'Midsized');
        
        
        List<String> lstCategories = new List<String>();
        lstCategories.add('HR and Payroll');
        
        tetrisProductModel.categories = lstCategories;
        System.assertNotEquals(tetrisProductModel.categories, null);
        
        tetrisProductModel.industry = 'Retail';
        System.assertEquals(tetrisProductModel.industry, 'Retail');

        List<String> lstSegment = new List<String>();
        lstSegment.add('Accountant segment');
        tetrisProductModel.segment = lstSegment;
        
        system.assertNotEquals(null, tetrisProductModel.segment);
        
        tetrisProductModel.startDate = system.today();
        system.assertNotEquals(null, tetrisProductModel.startDate);
        
        tetrisProductModel.endDate = system.today().addYears(100);
        system.assertNotEquals(null, tetrisProductModel.endDate);
        
        tetrisProductModel.productLongDescription = 'This is Sage One Payroll Product for UK';
        System.assertEquals(tetrisProductModel.productLongDescription, 'This is Sage One Payroll Product for UK');
        
        tetrisProductModel.productShortDescription = 'Product Short Description';
        System.assertEquals(tetrisProductModel.productShortDescription, 'Product Short Description');
        
        tetrisProductModel.uom = 'Each';
        System.assertEquals(tetrisProductModel.uom, 'Each');
        
        tetrisProductModel.quantityPerUnit = 1.0;
        System.assertEquals(tetrisProductModel.quantityPerUnit, 1.0);
        
        tetrisProductModel.trial = false;
        System.assertEquals(tetrisProductModel.trial, false);
        
        tetrisProductModel.trialLength = 10;
        System.assertEquals(tetrisProductModel.trialLength, 10);
        
        tetrisProductModel.soldBy = 'DefaultStore';
        System.assertEquals(tetrisProductModel.soldBy, 'DefaultStore');
        
        tetrisProductModel.taxable = false;
        System.assertEquals(tetrisProductModel.taxable, false);
        
        tetrisProductModel.vatRule = ' ';
        
        tetrisProductModel.feeType = '';
        
        tetrisProductModel.priceType = '';
        
        tetrisProductModel.periodOrFrequency = '';
         
        tetrisProductModel.vatTaxExemptId = false;
        
        
        tetrisProductModel.currencyUnit = '';
         
        tetrisProductModel.termsAndConditions = '';
        
        tetrisProductModel.individuallySold = true;
          
        tetrisProductModel.cancellationPeriod = 90.0;
         
        tetrisProductModel.contractDuration = 365.0;
        
        tetrisProductModel.billingProductId = '';
         
        tetrisProductModel.ratePlanId = ' '; 

        tetrisProductModel.subscriptionDisclaimer = ' '; 
        
        //tetrisProductModel.subscriptionDuration = 365;
         
        //tetrisProductModel.subscriptionFrequency = '';
         
        //tetrisProductModel.subscriptionAutoRenewal = true;
        
        //tetrisProductModel.availableForSubscription = true;

        //related products
        //global List<TetrisProductModel> crossSellProducts {get;set;} 
        //global List<TetrisProductModel> upSellProducts {get;set;} 
        //global List<TetrisProductModel> bundledProducts {get;set;} 
        //global TetrisPriceModel price {get;set;}
        
        tetrisProductModel.isBundledProduct = true;
        
        tetrisProductModel.bundleListPrice = 10.99;
         
        tetrisProductModel.bundleDiscountedPrice = 2.99;     

        tetrisProductModel.bundleSavingsPercentage = 10; 

        tetrisProductModel.bundleComponentIsOptional = false;
        
        tetrisProductModel.bundleComponentDescription = '';

        tetrisProductModel.tieredPricing = true;  
        
    }
}