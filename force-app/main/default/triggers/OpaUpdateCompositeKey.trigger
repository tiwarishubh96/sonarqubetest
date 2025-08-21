trigger OpaUpdateCompositeKey on OpaEndpointInfo__c (before insert, before update) 
{
    for(OpaEndpointInfo__c endpoint: Trigger.new)
    {
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate ))
        {
            String recordKey = endpoint.OpaCountry__c + endpoint.OpaEnvironmentType__c;
            recordKey = recordKey .trim();
            recordKey = recordKey .replaceAll('(\\s+)', '');
            endpoint.OpaCompoundKey__c = recordKey;
        }
    }
}