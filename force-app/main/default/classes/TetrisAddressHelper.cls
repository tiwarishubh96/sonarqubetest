global without sharing class TetrisAddressHelper {
    
    global static void retrieveStateList(String countryISOCode)
    {
        /*
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        System.debug('fieldResult::'+fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        System.debug('Picklist::'+ple.size());
        for( Schema.PicklistEntry f : ple){
            System.debug(f.getLabel() +'::'+ f.getValue());
        }
        */
        Map<String,String> maplabelVal=new Map<String,String>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = Account.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get('BillingStateCode').getDescribe().getPickListValues();
        system.debug('values: '+values);
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){
            system.debug('a.getLabel(): '+a.getLabel());
            system.debug('a.getValue(): '+a.getValue());
            maplabelVal.put(a.getLabel(), a.getValue());
        }
        system.debug('MAP: '+maplabelVal);
        system.debug('ISO CODE: '+maplabelVal.get('Aberdeenshire'));
    }
}