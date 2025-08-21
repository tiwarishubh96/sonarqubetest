trigger SagePricingCodeChargeTrigger on PricingCodeCharge__c (before insert, before update, after insert, after update, after delete) {
    if (Application_Control__c.getOrgDefaults().Run_Triggers__c &&
        CBC_Application_Control__c.getOrgDefaults().Run_Triggers__c) {

    	List<PricingCode__c> pricingCodes = new List<PricingCode__c>();

        /* Before Insert or Update */
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            for (PricingCodeCharge__c c : Trigger.new)
                if (c.DiscountPrice__c != null && c.DiscountPercent__c != null)
                    c.addError('Please enter only Discount Amount or Discount Percentage, but not both.');

        /* After Insert or Update */
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PricingCodeCharge__c.fields.getMap();
			Set<String> fieldNames = new Set<String>();
			PricingCodeCharge__c chargeObj = Trigger.new[0];
			for (String fieldName: schemaFieldMap.keySet())
			    fieldNames.add(fieldName);

        	for (PricingCodeCharge__c pcc:Trigger.new) {
        		System.debug('**********PCC ID: ' + pcc.Id);
			    Set<String> changedFields  = new Set<String>();
			    // for new record
			    if (Trigger.oldMap == null || Trigger.oldMap.get(pcc.Id) == null)
			    	changedFields.addAll(fieldNames);
			    else {
                    PricingCodeCharge__c occ = Trigger.oldMap.get(pcc.Id);
                    if (pcc.DiscountPrice__c == null && pcc.DiscountPercent__c == null)
                        continue;

				    for(string s: fieldNames)
				        if(pcc.get(s) != trigger.oldMap.get(pcc.Id).get(s))
				            changedFields.add(s);
                }

			    if(changedFields.size()>0)
	        		pricingCodes.add(new PricingCode__c(id = pcc.Pricing_Code__c));
        	}
        }

        if (Trigger.isAfter && Trigger.isDelete) {
			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PricingCodeCharge__c.fields.getMap();
			Set<String> fieldNames = new Set<String>();
			PricingCodeCharge__c chargeObj = Trigger.old[0];
			for (String fieldName: schemaFieldMap.keySet())
				fieldNames.add(fieldName);

        	for (PricingCodeCharge__c pcc:Trigger.old)
        		pricingCodes.add(new PricingCode__c(id = pcc.Pricing_Code__c));
        }

	    System.debug('Pricing codes modified? ' + (pricingCodes.size() > 0));

    	if (pricingCodes.size() > 0) {
        	pricingCodes = [SELECT Id,SyncStatus__c FROM PricingCode__c WHERE ID IN :pricingCodes AND IsDeleted = false];
        	if (pricingCodes != null) {
        		for (PricingCode__c pc:pricingCodes)
        			pc.SyncStatus__c = 'is modified';

        		update pricingCodes;
        	}
        }
    }
}