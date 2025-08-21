trigger OpaMindoProvisioning on OpaCustomerSite__c (after update) 
{
    System.debug('mindo provisioning trigger called! ');
    
    for (OpaCustomerSite__c site : Trigger.new) 
    {
        //OpaCustomerSite__c oldSite = Trigger.oldmap.get(site.id);
            
        if (site.OpaProvisioningStatus__c == 'Ready' && !Test.isRunningTest()) 
        {
            //immediately change OpaProvisioningStatus__c to ensure another trigger will not make a duplicate callout
            OpaCustomerSite__c[] targetSites = [select 
                                                    OpaCustomerSite__c.Name,
                                                    OpaCustomerSite__c.OpaProvisioningStatus__c
                                                from 
                                                    OpaCustomerSite__c 
                                                where 
                                                    OpaCustomerSite__c.Name = :site.Name];
            
            if (targetSites.size() > 0)                                
            {
                //System.debug('Setting the provisioning status before the callout is made to ensure no duplicate callouts for site: ' + site.Name);
                targetSites[0].OpaProvisioningStatus__c = 'In progress';
                update targetSites[0];
            }
        
            System.debug('SiteId from trigger : ' + site.Name);
            OpaProvisionCustomerSite.provisionCustomerSite(site.Name);
        }
    }        
}