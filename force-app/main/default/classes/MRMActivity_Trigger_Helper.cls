public class MRMActivity_Trigger_Helper {
    public static void populateRegionBasedOnCountry(List<MRM_Activity__c> newObjects){
        for(MRM_Activity__c mrmactivity: newObjects){
            String countryName = mrmactivity.Country__c;
            System.debug('countryName:= '+countryName);
            if (countryName != null) {
                String cname=countryName.substring(countryName.indexOf('-') + 2, countryName.length());
                Map<String, String> countryToRegion=CountriesTORegionMappingUtils.mapCountriestoRegions(new set<String>{
                    cname});
                mrmactivity.Region__c= countryToRegion.get(cname);
            }    
        }
    }
    public static void populateRegionBasedOnCountry(List<MRM_Activity__c> newObjects, Map<Id,MRM_Activity__c> oldObjects){
        for(MRM_Activity__c mrmactivity: newObjects){
            String countryName = mrmactivity.Country__c;
            System.debug('countryName:= '+countryName);
            if (countryName != null) {
                String cname=countryName.substring(countryName.indexOf('-') + 2, countryName.length());
                Map<String, String> countryToRegion=CountriesTORegionMappingUtils.mapCountriestoRegions(new set<String>{
                    cname});
                mrmactivity.Region__c= countryToRegion.get(cname);
            }    
        }
    }
}