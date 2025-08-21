@isTest
public class ZuoraUpdateHelper_Test {
    
    @isTest
    static void testHelper(){
        String correlationId = 'cid-test-1234567';
    
        Map<String,Object> parameters = new Map<String,Object>();
        //caller info
        Map<String,String> callerInfo = new Map<String,String>{'exectingclass'=>'ZuoraUpdateHelper_Test', 'correlationId'=>correlationId};
        parameters.put('CallerInfo',callerInfo);
        Map<String,String> udateParams = new Map<String, String>{
            'Id' => 'zuoraBillToId',
            'AccountId' => 'zuoraAccountId',
            'WorkEmail' => 'updatedEmail'
          };
        parameters.put('FieldValues',udateParams);
        
        ZuoraUpdateHelper helper = new ZuoraUpdateHelper(parameters);
        System.assertEquals(correlationId,helper.getCorrelationId());
        System.assertEquals('ZuoraUpdateHelper_Test',helper.getExecutingClass());
        System.assert(helper.getFieldValueMap() != null);
        System.assertEquals('zuoraBillToId', helper.getFieldValueMap().get('Id'));
        System.assertEquals('zuoraAccountId', helper.getFieldValueMap().get('AccountId'));
        System.assertEquals('updatedEmail', helper.getFieldValueMap().get('WorkEmail'));
    }
}