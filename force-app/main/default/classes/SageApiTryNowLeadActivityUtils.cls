public class SageApiTryNowLeadActivityUtils {
    //TODO: may need a custom setting to store the list of message codes
    public static Boolean validatePayload(SageApiActivity__c activity, SageApiActivityStep step, List<Product_Tier__c> productTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (activity == null || step == null)
            return false;

        SageApiTryNowLeadActivityRequest req = null;
        try {
            req = (SageApiTryNowLeadActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowLeadActivityRequest.class);
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

       // validate root-level attributes
       if (String.isBlank(req.firstName)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required');
       }

       if (String.isBlank(req.lastName)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required');
       }

       if (String.isBlank(req.email)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'email', 'Email is required');
       }

        // validate products
        List<SageApiActivityRequestObjects.Product> products = req.products;
        if (products == null || products.size() == 0) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'products', 'Products is required');
        }
        else {
            if (products.size() > 1)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.ValueOutOfRange, 'tierCode', 'Only one Product Tier Code is supported');
            
            if (String.IsBlank(products[0].tierCode))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code is required');

            Boolean hasMatchingPt = false;
            for (Product_Tier__c pt : productTiers) {
                if (pt != null && pt.Product_Tier_Code__c == products[0].tierCode) {
                    hasMatchingPt = true;
                    break;
                }
            }

            if (!hasMatchingPt)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code not found');
            
            if (!String.IsBlank(products[0].tierRatePlanCode))
            {          
                if (errors.size() == 0)
                {
                    Boolean hasMatchingPtrp = false;
                    for (Product_Tier_Rate_Plan__c ptrp : productTierRatePlans) {
                        if (ptrp != null && ptrp.Product_Tier__r.Product_Tier_Code__c == products[0].tierCode && ptrp.name == products[0].tierRatePlanCode) {
                            hasMatchingPtrp = true;
                            break;
                        }
                    }
                    
                    if (!hasMatchingPtrp)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code not found');
                }
            }
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        } 

        SageApiActivityUtils.setSuccess(activity, step);
        SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        return true;
    }
    
    public static void createLead(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<Lead> leads = new List<Lead>();
        List<SageApiActivity__c> activitiesForLead = new List<SageApiActivity__c>();
        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();

        for (SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiTryNowLeadActivityRequest req = null;
            try {
                req = (SageApiTryNowLeadActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowLeadActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead creation. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            activitiesForLead.add(activity);

            if (req.products != null && req.products.size() > 0)
                products.add(req.products[0]);
            else
                products.add(new SageApiActivityRequestObjects.Product());
                
            Lead lead = new Lead(
                            firstName = req.firstName, 
                            lastName = req.lastName, 
                            company = string.isBlank(req.companyName) ? req.firstName + ' ' + req.lastName : req.companyName, 
                            email = req.email, 
                            phone = req.phone,
                            //status = 'New', leadSource = 'Other', 
                            Street = req.address1+(String.isBlank(req.address2) ? '' : '\n'+req.address2),
                            City = req.city, 
                            StateCode = req.state, 
                            PostalCode = req.postalCode , 
                            CountryCode = req.countryCode,
                            RecordTypeId = recordTypeId
                        );
            leads.add(lead);
        }

        List<Product_Tier__c> listTierData = SageApiActivityUtils.getProductTiers(products);
        Integer leadIndex = -1;
        for (Lead l : leads) {
            leadIndex++;
            SageApiActivityRequestObjects.Product product = products[leadIndex];
            for (Product_Tier__c tierData : listTierData) {
                if (product != null && product.tierCode == tierData.Product_Tier_Code__c) {
                    l.Product__c = tierData.SageProduct__c;
                    continue;
                }
            }
        }
        
        saveLeads(step, activitiesForLead, leads);
    }

    private static void saveLeads(SageApiActivityStep step, List<SageApiActivity__c> activities, List<Lead> leads) {
        //process batch save results
        Database.SaveResult [] leadResults = Database.insert(leads, false);
        Integer index = 0;

        for(Database.SaveResult result : leadResults){
            SageApiActivity__c activity = activities.get(index);
            Lead lead = leads.get(index);
            index++;
            if (result.isSuccess()) {
                activity.Lead__c = result.id;
                SageApiActivityUtils.setSuccess(activity, step);
                SageApiActivityUtils.debug('updateArtifact: '+JSON.serialize(activity));
                continue;
            }
            
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'SaveLead', 'Saving lead failed. Detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }        
    }
    
    private static SageApiTryNowLeadActivityResponse createResponse() {
        SageApiTryNowLeadActivityResponse response = new SageApiTryNowLeadActivityResponse();
        response.data = new SageApiTryNowLeadActivityResponse.ResponseData();
        SageApiActivityUtils.debug('createResponse: '+JSON.serialize(response));
        return response;
    }

    public static void updateArtifact(SageApiActivity__c activity, List<SageApiActivityError> errors) {
        SageApiTryNowLeadActivityResponse response = null;
        if (String.isNotBlank(activity.Artifacts__c))
            response = (SageApiTryNowLeadActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiTryNowLeadActivityResponse.class);
        if (response == null)
            response = createResponse();
        
        response.activityId = activity.ActivityID__c;
        response.status = activity.ActivityStatus__c;
        response.errors = errors;
        response.data.leadId = String.ValueOf(activity.Lead__c);
        
        string artifact = JSON.serialize(response);
        if (artifact.length() > 131072)
            artifact = artifact.substring(0, 131060) + '.TRUNCATED.';
        activity.Artifacts__c = artifact;
        SageApiActivityUtils.debug('activity.Artifacts__c: '+activity.Artifacts__c);
    }
}