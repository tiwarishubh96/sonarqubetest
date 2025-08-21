@IsTest
public class OpaTestSsaDocuSignResponse
{    
    static testMethod void testParse() {
        String json = '{'
                        +' \"errorCode\" : \"INVALID_REQUEST_PARAMETER\",'
                        +' \"message\" : \"The request contained at least one invalid parameter. Invalid value specified for folder.\"'
                        +'}';
                      
        OpaSsaDocuSignResponse r = OpaSsaDocuSignResponse.parse(json);
        System.assert(r != null);
        System.assertEquals(r.errorCode, 'INVALID_REQUEST_PARAMETER');
        System.assertEquals(r.message, 'The request contained at least one invalid parameter. Invalid value specified for folder.');
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        OpaSsaDocuSignResponse r2 = OpaSsaDocuSignResponse.parse(json);
        System.assert(r2 != null);
        System.assert(r2.errorCode == null);
        System.assert(r2.message == null);
    }
}