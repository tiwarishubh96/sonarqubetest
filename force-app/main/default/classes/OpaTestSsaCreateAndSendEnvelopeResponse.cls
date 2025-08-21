@IsTest
public class OpaTestSsaCreateAndSendEnvelopeResponse 
{
    static testMethod void testParse() 
    {
        String json ='{'
                      +'"envelopeId": "3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f",'
                      +'"uri": "/envelopes/3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f",'
                      +'"statusDateTime": "2018-04-04T22:09:08.2389426Z",'
                      +'"status": "sent"'
                      +'}';        
                         
        OpaSsaCreateAndSendEnvelopeResponse r = OpaSsaCreateAndSendEnvelopeResponse.parse(json);
        System.assert(r != null);
        System.assertEquals(r.envelopeId, '3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f');
        System.assertEquals(r.uri, '/envelopes/3c8fbbca-6f4c-4c5c-aaed-d10b2549ac0f');
        System.assertEquals(r.statusDateTime, '2018-04-04T22:09:08.2389426Z');
        System.assertEquals(r.status, 'sent');

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        OpaSsaCreateAndSendEnvelopeResponse r2 = OpaSsaCreateAndSendEnvelopeResponse.parse(json);
        System.assert(r2 != null);
        System.assert(r2.envelopeId == null);
        System.assert(r2.uri == null);
        System.assert(r2.statusDateTime == null);
        System.assert(r2.status == null);
    }
}