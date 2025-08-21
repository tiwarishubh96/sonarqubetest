public class getLocalevaluefromMapping {
    public static String getlocalefromMapping(String AccountLocale, String IsoCode) {
        
        String Locale;
        Integer count=0;
        //system.debug('test'+AccountLocale);
        //system.debug('test'+IsoCode);
        List<Partner_Community_Locale_Mapping__c> listB = Partner_Community_Locale_Mapping__c.getAll().values();
        //system.debug('test'+listB);
        for(Partner_Community_Locale_Mapping__c p : listB)
        {
            if(p.Account_Locale__c == AccountLocale && AccountLocale != null)
            {
                Locale=p.Contact_User_Locale__c;
                break;
            } 
            
            else if(p.ISO_Country_Code__c == IsoCode)
            {
                Locale=p.Contact_User_Locale__c;
            }
        }
        return Locale;
    }
}