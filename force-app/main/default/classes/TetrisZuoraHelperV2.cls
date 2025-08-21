public class TetrisZuoraHelperV2 {

    //Created for Test Classes
    public static Zuora.zObject createZuoraObject(String objName, String id, Map<String, Object> fieldValueByNameMap)
    {
        Zuora.zObject obj;
        try
        {
            obj = new Zuora.zObject(objName);
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('TetrisZuoraHelperV2','createZuoraObject',e);
        }
        try
        {
            if (id != null && id != '')
            {
                for (String field : fieldValueByNameMap.keySet())
                {
                    obj.setValue(field,fieldValueByNameMap.get(field));
                }
            }
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('TetrisZuoraHelperV2','createZuoraObject',e);
        }

        return obj;
    }

    public Static TetrisZuoraModel getZuoraNextInvoiceDate(String zuoraSubcriptionId) {
        TetrisZuoraModel zuoraModel = new TetrisZuoraModel();
        //Date nextInvoiceDate;
        try {
            Zuora.zApi zApiInstance = new Zuora.zApi();
            List<Zuora__SubscriptionProductCharge__c> ratePlanChargelst= [SELECT Zuora__RatePlanId__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__Zuora_Id__c =:zuoraSubcriptionId and (NOT Zuora__Model__c like: '%Discount%')];
            If (ratePlanChargelst.size()>0) {
                String ratePlanChargeQuery =  'SELECT Id,Name,ProductRatePlanChargeId,ChargeModel,ChargedThroughDate,EffectiveEndDate,EffectiveStartDate FROM RatePlanCharge WHERE RatePlanId=\''+ratePlanChargelst[0].Zuora__RatePlanId__c+'\'';
                List<Zuora.zObject> zRatePlanChargeobjs=new List<Zuora.zObject>();
                If (!Test.isRunningtest()) {
                    zApiInstance.zlogin();
                    zRatePlanChargeobjs = zApiInstance.zquery(ratePlanChargeQuery);
                }
                else
                {
                    Zuora.zObject productRatePlan_1 = createZuoraObject('RatePlanCharge', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'Name'=>'Accounting GB','Id'=>'2c92c0f85ec6e9f4015ec92f41a64754','ChargeModel' => 'Flat-fee','ChargedThroughDate'=>System.Today(),'EffectiveEndDate'=> System.Today(), 'EffectiveStartDate' => System.Today()});
                    Zuora.zObject productRatePlan_2 = createZuoraObject('RatePlanCharge', '2c92c0f94e2401bb014e2a4547e15b44', new Map<String, Object> { 'Name'=>'Accounting GB Discount Percentage','Id'=>'2c92c0f85ec6e9f4015ec92f41a64752','ChargeModel' => 'Flat-fee','ChargedThroughDate'=>System.Today(),'EffectiveEndDate'=> System.Today(), 'EffectiveStartDate' => System.Today()});
                    zRatePlanChargeobjs = new List<Zuora.zObject> { productRatePlan_1,productRatePlan_2};
                }
                for (Zuora.zObject objRatePlanCharge : zRatePlanChargeobjs)
                {
                    String ChargeName=(String)objRatePlanCharge.getValue('Name');
                    if(!ChargeName.contains('Discount')){
                        System.debug('ChargeName'+ChargeName);
                        zuoraModel.effectiveStartDate= ((DateTime)objRatePlanCharge.getValue('EffectiveStartDate')).date();
                        System.debug('ChargeName'+((DateTime)objRatePlanCharge.getValue('EffectiveStartDate')).date());

                        //ECOM-1137 add null check for subscriptions that have not been invoiced yet
                        if(objRatePlanCharge.getValue('ChargedThroughDate') != null) {
                            zuoraModel.nextInvoiceDate = ((DateTime) objRatePlanCharge.getValue('ChargedThroughDate')).date();
                        }
                    }

                    if(ChargeName.contains('Discount')){
                        zuoraModel.discountEndDate =((DateTime)objRatePlanCharge.getValue('EffectiveEndDate')).date();
                        //    nextInvoiceDate = (Date)objRatePlanCharge.getValue('ChargedThroughDate');
                    }

                }
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
        } catch(Exception e){
            ExceptionHandler.CatchException('TetrisZuoraHelperV2','getZuoraNextInvoiceDate',e);
        }
        return zuoraModel;
        //   return nextInvoiceDate;
    }

}