/**
 * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
 * @date    26-Jul-2018
 * @description     Util DAC class to query all necessary custom settings and custom metadata types
 *
 */

public class Settings_DAC {

    //singleton variables
    private static List<SalesOffice__mdt> salesOffices = null;
    private static List<Country_Lanugage__mdt> languages = null;
    private static List<LocalCRM__c> localCRMS = null;
    //private static List<ZoomInfoMapping__mdt> zoomInfoMappings = null;  10/03/2019 bphan EAD-906 Remove ZoomInfo
    private static List<Intacct_to_NA_CBC_Lead_Transfer__mdt> leadTransfers = null;
    private static List<CountryProduct__mdt> productCrmMapping = null;


    /**
     * @description query to retrieve zoom info mappings metadata type
     *
     * @return list of queried zoom info mappings
     */
    // 10/03/2019 bphan EAD-906 Remove ZoomInfo
    /*
    public static List<ZoomInfoMapping__mdt> getZoomInfoMap(){

        if (zoomInfoMappings == null){
            zoomInfoMappings = [
                    SELECT
                            DeveloperName,
                            HigherLimit__c,
                            Id,
                            Industry__c,
                            Label,
                            Language,
                            LowerLimit__c,
                            MasterLabel,
                            NamespacePrefix,
                            QualifiedApiName,
                            SfFieldName__c,
                            SfPicklistValue__c
                    FROM ZoomInfoMapping__mdt];
        }

        return zoomInfoMappings;
    }

    /**
     * @description query to Product local crm mappings metadata type
     *
     * @return list of Product local crm mappings
     */
    public static List<CountryProduct__mdt> getProductCrmMapping() {
        if (productCrmMapping == null){
            productCrmMapping = [   SELECT  Id
                                        ,   MasterLabel
                                        ,   DeveloperName
                                        ,   Language
                                        ,   QualifiedApiName
                                        ,   NamespacePrefix
                                        ,   ProductMapping__r.MasterLabel
                                        ,   ProductMapping__r.LocalCRMName__c
                                        ,   CountryMapping__r.CountryCode__c
                                    FROM CountryProduct__mdt ];
        }

        return productCrmMapping;
    }

    /**
     * @description query to Product local crm mappings metadata type
     *
     * @return map of country code and map of product and local crm name
     */
    public static Map<String, Map<String, String>> getCrmMappingByProductByCountry() {

        // BUILD A MAP OF LOCAL CRM MAPPING BY PRODUCT BY COUNTRY
        Map<String, Map<String, String>> retVal = new Map<String, Map<String, String>>();

        for (CountryProduct__mdt eachMapping : Settings_DAC.getProductCrmMapping()) {
            retVal.put(eachMapping.CountryMapping__r.CountryCode__c
                    , new Map<String, String> { eachMapping.ProductMapping__r.MasterLabel => eachMapping.ProductMapping__r.LocalCRMName__c });
        }

        return retVal;
    }

    /**
     * @author Bhushan Sukumar
     * @date    26-Jul-2018
     * @description  query to retreive Salesoffices metadata type
     *
     * @return  list of salesoffices metadata types
     */
    public static List<SalesOffice__mdt> getSalesOffices() {

        //lazy loading the salesoffices
        if (salesOffices == null) {
            salesOffices = [
                    select id,
                            SalesOffice__c,Label,
                            RecordTypeName__c,
                            CountryCode__c,
                            Product__c,
                            Country__c
                    from SalesOffice__mdt
            ];

        }
        return salesOffices;
    }

    /**
     * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
     * @date 27-Jul-2018
     * @description query to retrieve languages metadata type
     *
     * @return  list of languages metadata types
     */
    public static List<Country_Lanugage__mdt> getLanguages() {

        //lazy loading languages
        if (languages == null) {
            languages = [
                    select EloquaLanguage__c,
                            Language__c
                    from Country_Lanugage__mdt
            ];
        }

        return languages;
    }

    /**
     * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
     * @date 27-Jul-2018
     * @description query to retrieve local CRM custom settings
     *
     * @return  list of local CRMs custom settings
     */
    public static List<LocalCRM__c> getLocalCRMS(){

        //lazy loading local CRMs
        if (localCRMS == null){
            localCRMS = [
                    SELECT
                            Country__c,
                            CurrencyIsoCode,
                            Default_CRM__c,
                            Id,
                            Name,
                            Region__c,
                            SetupOwnerId,
                            SQSName__c
                    FROM LocalCRM__c];
        }

        return localCRMS;
    }

    public static List<Intacct_to_NA_CBC_Lead_Transfer__mdt> getNacbcLeadTransfers(){

        if (leadTransfers == null) {
            leadTransfers = [
                    SELECT
                            DeveloperName,
                            Id,
                            Label,
                            Language,
                            MasterLabel,
                            NamespacePrefix,
                            Outbound_Queue__c,
                            QualifiedApiName,
                            User_Name__c
                    FROM Intacct_to_NA_CBC_Lead_Transfer__mdt
                    WHERE DeveloperName = 'Lead_Transfer'
                    LIMIT 1
            ];
        }

        return leadTransfers;
    }
} //end of class