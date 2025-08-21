@IsTest
public class OpaTestSsaGetTemplateIdResponse
{    
    static testMethod void testParse() 
    {
        String json =  '{'
                           +'"envelopeTemplates": ['
                               +'{'
                                    +'"templateId": "b3dcb808-2f23-4299-904b-c8534e85022b",'
                                    +'"name": "SSA template for X3-United States",'
                                    +'"shared": "true",'
                                    +'"password": "",'
                                    +'"description": "This is the subscription services agreement template for United States.",'
                                    +'"lastModified": "2018-03-30T19:12:03.5330000Z",'
                                    +'"created": "0001-01-01T00:00:00.0000000Z",'
                                    +'"pageCount": 1,'
                                    +'"uri": "/templates/b3dcb808-2f23-4299-904b-c8534e85022b",'
                                    +'"folderName": "United States",'
                                    +'"folderId": "638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"folderUri": "/folders/638aec0d-a47f-4cf8-83c0-7aec5a01f6e1",'
                                    +'"owner": {'
                                        +'"userName": "Alfred Kay",'
                                        +'"userId": "214820a5-27bc-4d11-baeb-d68add71edfd",'
                                        +'"email": "alfredkay+opadev1@gmail.com"'
                                    +'},'
                                    +'"emailSubject": "Please DocuSign: SSA_UnitedStates.pdf",'
                                    +'"emailBlurb": "Hi, Please sign the SSA. \\n\\nthank you\\nSage team",'
                                    +'"signingLocation": "Online",'
                                    +'"authoritativeCopy": "false",'
                                    +'"enforceSignerVisibility": "false",'
                                    +'"enableWetSign": "true",'
                                    +'"allowMarkup": "false",'
                                    +'"allowReassign": "true"'
                                +'}'
                            +'],'
                            +'"resultSetSize": "1",'
                            +'"startPosition": "0",'
                            +'"endPosition": "0",'
                            +'"totalSetSize": "1"'
                        +'}';
                        
        OpaSsaGetTemplateIdResponse r = OpaSsaGetTemplateIdResponse.parse(json);
        System.assert(r != null);
        System.assertEquals(r.resultSetSize, '1');
        System.assertEquals(r.startPosition, '0');
        System.assertEquals(r.endPosition, '0');
        System.assertEquals(r.totalSetSize, '1');        
        
        List<OpaSsaGetTemplateIdResponse.EnvelopeTemplates> ets = OpaSsaGetTemplateIdResponse.parse(json).envelopeTemplates;
        for(OpaSsaGetTemplateIdResponse.EnvelopeTemplates et : ets)
        {   
            System.assertEquals(et.templateId, 'b3dcb808-2f23-4299-904b-c8534e85022b');
            System.assertEquals(et.name, 'SSA template for X3-United States');
            System.assertEquals(et.shared, 'true');
            System.assertEquals(et.password, '');
            System.assertEquals(et.description, 'This is the subscription services agreement template for United States.');
            System.assertEquals(et.lastModified, '2018-03-30T19:12:03.5330000Z');
            System.assertEquals(et.pageCount, 1);
            System.assertEquals(et.uri, '/templates/b3dcb808-2f23-4299-904b-c8534e85022b');
            System.assertEquals(et.folderName, 'United States');
            System.assertEquals(et.folderId, '638aec0d-a47f-4cf8-83c0-7aec5a01f6e1');
            System.assertEquals(et.folderUri, '/folders/638aec0d-a47f-4cf8-83c0-7aec5a01f6e1');
            System.assertEquals(et.owner.userName, 'Alfred Kay');
            System.assertEquals(et.owner.userId, '214820a5-27bc-4d11-baeb-d68add71edfd');
            System.assertEquals(et.owner.email, 'alfredkay+opadev1@gmail.com');            
            System.assertEquals(et.emailSubject, 'Please DocuSign: SSA_UnitedStates.pdf');    
            System.assertEquals(et.emailBlurb, 'Hi, Please sign the SSA. \n\nthank you\nSage team');
            System.assertEquals(et.signingLocation, 'Online');
            System.assertEquals(et.authoritativeCopy, 'false');   
            System.assertEquals(et.enforceSignerVisibility, 'false');    
            System.assertEquals(et.enableWetSign, 'true');
            System.assertEquals(et.allowMarkup, 'false');
            System.assertEquals(et.allowReassign, 'true');              
        }     
        
        String templateId = OpaSsaGetTemplateIdResponse.parseTemplateId(json);
        System.assertEquals(templateId, 'b3dcb808-2f23-4299-904b-c8534e85022b');

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        OpaSsaGetTemplateIdResponse r2 = OpaSsaGetTemplateIdResponse.parse(json);
        System.assert(r != null);
   }
}