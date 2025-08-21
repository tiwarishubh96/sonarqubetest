public with sharing class OpaTokenGenerator 
{   
    public static String getBearerToken(OpaEndpointInfo__c endpointInfo)
    {
        long currentTime = (dateTime.now().getTime()/1000) - 1;
        
        //System.debug(LoggingLevel.DEBUG, 'Started getBearerToken call for user(' + endpointInfo.OpaTokenSubject__c + ') and expirationDate(' + expirationDate + ')');
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();  
            gen.writeStringField('iss', endpointInfo.OpaClientId__c);
            gen.writeStringField('sub', endpointInfo.OpaTokenSubject__c);
            gen.writeStringField('aud', ''); //this causes error if not sent
            gen.writeNumberField('iat', currentTime);
            gen.writeNumberField('exp', currentTime + endpointInfo.OpaTokenExpiration__c.longValue());
        gen.writeEndObject();   
        
        String claimSet = gen.getAsString().trim();
        
        String signatureInput = OpaUtils.base64URLencode(blob.valueOf(OpaStaticVariables.jwtHeader)) + '.' + OpaUtils.base64URLencode(blob.valueOf(claimSet));
        
        //System.debug(LoggingLevel.DEBUG, 'inside generateJWTToken call, claimset( ' + claimset + ') and signatureInput(' + signatureInput + ')');
        
        //for unit testing the name of the jwtCertificateName is chosen to be mindo_authentication which should correspond to a real certificate name in the SF org, otherwise the test will fail at this line
        //Blob signature = crypto.signWithCertificate(OpaStaticVariables.jwtSigningAlgorithm, blob.valueOf(signatureInput), OpaStaticVariables.jwtCertificateName == '' ? 'mindo_authentication' : OpaStaticVariables.jwtCertificateName);
        Blob signature = crypto.generateMac(OpaStaticVariables.jwtSigningAlgorithm, Blob.valueOf(signatureInput), Blob.valueOf(endpointInfo.OpaConsumerKey__c));
          
        String jwt = signatureInput + '.' + OpaUtils.base64URLencode(signature);        
        //System.debug(LoggingLevel.DEBUG, 'JWT token: ' + jwt);
        return jwt;        
    }
}