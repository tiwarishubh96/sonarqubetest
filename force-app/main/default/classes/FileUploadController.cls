public class FileUploadController {
       
    @AuraEnabled
    public static String uploadDocument(String fileName, String base64Data, String contentType, String folderName) { 
		String status = 'success';
        String documentId = '';
        String documentUrl = '';
        String message = '';
        String folderQuery = '';
        
        try {
            System.debug('FileUploadController: uploadDocument: enter ');      
            folderQuery = 'SELECT id FROM Folder WHERE name = \'' + String.escapeSingleQuotes(folderName) + '\' LIMIT 1';
            System.debug('folder query ' + folderQuery);
           	SObject folder = Database.query(folderQuery);
            String folderId = (String)folder.get('id');
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');    
            
            Document document = new Document();
            document.Body = EncodingUtil.base64Decode(base64Data);
            document.ContentType = contentType;
            document.DeveloperName = getUniqueFileName(fileName);
            document.IsPublic = true;
            document.Name = fileName;
            document.FolderId = folderId;
            insert document;
                    
            String orgId = UserInfo.getOrganizationId();
            documentId = document.id;        
            documentUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/community/servlet/servlet.ImageServer?id=' + documentId + '&oid=' + orgId;
            
            System.debug('FileUploadController: uploadDocument: document url is ' + documentUrl);        
            System.debug('FileUploadController: uploadDocument: document id is ' + documentId);        
            System.debug('salesforce base url ' + URL.getSalesforceBaseUrl());
            System.debug('salesforce base url external form ' + URL.getSalesforceBaseUrl().toExternalForm());        
        }
        catch (System.DmlException ex) {
            System.debug('~~~~~~~~~~~~~~~~~~DML Exception ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
	          System.debug('Exception type is ' + ex.getTypeName());
            message = ex.getMessage(); 
            if (message.indexOf('DUPLICATE_DEVELOPER_NAME') > 0) {
                message = 'Error uploading File. Another document with the same Name exists. Duplicate File Upload unsuccessful.';
            }
            status = 'error';
        }
        catch (System.Exception ex) {
            System.debug('~~~~~~~~~~~~~~~~~~Exception ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            System.debug('Exception type is ' + ex.getTypeName());
            message = 'Error uploading File. ' + ex.getTypeName() + ': ' + String.escapeSingleQuotes(ex.getMessage()); 
            status = 'error';
        }
        String result = '{"result": "' + status + '", "id":"' + documentId + '", "imageUrl":"' + documentUrl + '", "message": "' + message.replaceAll('"', '') + '"}';
        return result;    

    }
    
    public static String getUniqueFileName(String fileName) {
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
		Matcher matcher = nonAlphanumeric.matcher(fileName);
		return matcher.replaceAll(''); 
    }

}