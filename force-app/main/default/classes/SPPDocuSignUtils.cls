/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/06/2017
    Company:       
    Description:    Utility Class for all SPP Docusign related module
    Inputs:         None
    History:        Lu, 10/24/2017, moved createDocuSignStatusRecord method
                    from SPPUtils, changed 'upload contract manully'button code as well,
                    added try-catch block for existing code
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

global class SPPDocuSignUtils {
    
    //Method to create a Sharing Rule IN Docusign Status Object 
    public static void createpartnerRoleSharingDocusignStatus(List<Partner_Terms_and_Condition__c> lstPTnC)
    {   
        List<dsfs__DocuSign_Status__Share> sharesToCreate = new List<dsfs__DocuSign_Status__Share>();
        Set<Id> setReferringAccount = new Set<Id>();
        Map<string,Id> mapPTCDocusignAccount = new Map<string,Id>();
        Map<Id,Id> mapAccountRole = new Map<Id,Id>();
        Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
        
        //Fetching all the leads
        List<Partner_Terms_and_Condition__c> lstPartnerTnC = [Select id,Account__c,DocuSign_Status_Object__c from Partner_Terms_and_Condition__c where Id in : lstPTnC];
        
        for(Partner_Terms_and_Condition__c obj : lstPartnerTnC)
        { 
            if(obj.Account__c!= null)
            { 
                system.debug('obj.Referring_Partner_Account__c'+obj.Account__c);
                
                setReferringAccount.add(obj.Account__c);
                
                mapPTCDocusignAccount.put(obj.DocuSign_Status_Object__c,obj.Account__c);//Map of Docusign Status Id and Account Id
            }
        }
        
        system.debug('mapPTCDocusignAccount'+mapPTCDocusignAccount);
        
        
        //Map of Partner User Role details it will always 1-1 based on community role setting
        Map<Id,UserRole> mapPartnerRole = new Map<Id,UserRole>([SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
                                                                PortalType, PortalRole,PortalAccountOwnerId FROM UserRole where PortalAccountId IN : setReferringAccount]);
        
        for(UserRole usrRole : mapPartnerRole.values())
        {
            system.debug('usrRole.PortalAccountId'+usrRole.PortalAccountId);
            
            mapAccountRole.put(usrRole.PortalAccountId,usrRole.Id);//Map of Account ID and User Role Id
        }
        
        
        //Fetch group Id based on User Role
        List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN : mapPartnerRole.keyset()];
        
        for(Group grp : lstGroup)
        {   
            if(grp.Type == 'RoleAndSubordinates')
            {
                system.debug('grp.RelatedId'+grp.RelatedId);
                mapUserRoleandGroup.put(grp.RelatedId,grp.Id);
            }
        }  
        
        system.debug('>>>>>>>'+mapUserRoleandGroup);
        
        for(Id DocusignId : mapPTCDocusignAccount.keyset())
        {
            //Get Group Id based on UserRole Id
            String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapPTCDocusignAccount.get(DocusignId)));
            
            system.debug('strgroupId '+strgroupId);
            
            //Creating Docusign Status Share record
            dsfs__DocuSign_Status__Share ObjDocusignStatus = new dsfs__DocuSign_Status__Share();
            ObjDocusignStatus.AccessLevel = 'Read';
            ObjDocusignStatus.UserOrGroupId =  strgroupId;
            ObjDocusignStatus.parentId= DocusignId;
            ObjDocusignStatus.RowCause = Schema.dsfs__DocuSign_Status__Share.RowCause.Access_to_all_Contact_under_Same_Partner__c;
            
            //adding to the sharing list to insert into Opportunity sharing table
            sharesToCreate.add(ObjDocusignStatus);
            
        }
        
        if (!sharesToCreate.isEmpty())
        {   
            Database.insert(sharesToCreate,false);//Inserting Sharing List 
        }
        
    }
    
    //Method to get DocuSign Request Object 
    public static HttpRequest getConfig(String endPoint , String methodType , String contentType)
    {
        
        //Soql to get DocuSign Accoutn User details from there custom Object 
        dsfs__DocuSignAccountConfiguration__c accConFig = [select id,name,  dsfs__AccountId__c,dsfs__DocuSignBaseURL__c,dsfs__DocuSignEnvironment__c, dsfs__DSProSFPassword__c,dsfs__DSProSFUsername__c from dsfs__DocuSignAccountConfiguration__c];
        String accountID = accConFig.dsfs__AccountId__c; 
        String userName = accConFig.dsfs__DSProSFUsername__c; 
        String passWord = accConFig.dsfs__DSProSFPassword__c;
        String integratorKey = System.Label.DocuSign_Integrator_Key;
        
        //Creating end point url
        String endPointBase =    accConFig.dsfs__DocuSignBaseURL__c+'restapi/v2/accounts/'+accountID+'/envelopes' + endPoint;
        //;
        System.debug('endPointBase'+ endPointBase);
        //Apex HTTP Method Initialization.
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointBase);
        req.setMethod(methodType); 
        
        //Authorization header generating using DocuSign credentials. 
        
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>';
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Length','162100');
        req.setHeader('Content-Type',contentType);
        req.setHeader('Content-Disposition','form-data');
        return req;
    }
    
    //Get the product list for all the Account
    public Static Map<String, String> getProductList(List<account> accIds)
    {
        Integer i = 0;
        String productList = '';
        Map<String, String> productStringMap = new Map<String , String>();
        
        List<Associated_Product__c> assList = [Select Id,Product__c,Account__c from Associated_Product__c where Account__c In :accIds];
        System.debug('!!! assList'+assList);
        for(Associated_Product__c obj : assList)
        {
            productList = productStringMap.get(obj.Account__c);
            if(productList == null)
            {
                productList = '';
                i=0;
            }  
            else
                i=1;
            if(i > 0)
            {
                
                productList += ' | ';
            }
            productList += obj.Product__c;
            productStringMap.put(obj.Account__c, productList);
            system.debug('!!! productList '+productList);
            i++;
        }
        system.debug('!!! productStringMap '+productStringMap);
        return productStringMap;
    }
    
    webservice static String createDocuSignStatusRecord(String accId)
    {
        system.debug(accId);
        dsfs__DocuSign_Status__c dStatus = new dsfs__DocuSign_Status__c();
        try{
            if(accId != null){
                dStatus.dsfs__DocuSign_Envelope_ID__c = GUIDHelper.generateGUID();
                dStatus.dsfs__Envelope_Status__c = 'Completed';
                dStatus.dsfs__Subject__c = 'System Created Record';
                dStatus.dsfs__Sent_Date_Time__c = DateTime.now();
                dStatus.dsfs__Completed_Date_Time__c = DateTime.now();
                dStatus.dsfs__Company__c = accId;
                dStatus.dsfs__Sender__c = UserInfo.getName();
                dStatus.dsfs__Sender_Email__c = UserInfo.getUserEmail();
                insert dStatus;
                //Create a dummy T&C object TCV-99999
                Partner_Terms_and_Condition__c objPLA =  new Partner_Terms_and_Condition__c();
                objPLA.Account__c = accId;
                objPLA.Terms_Conditions_Version__c = Label.SPPGenericT_C;
                objPLA.DocuSign_Status_Object__c  = dStatus.Id;
                objPLA.DocuSign_Status__c = 'Completed';
                
                
                insert objPLA;
                
            }
        }catch(Exception e){
            
            ExceptionHandler.CatchException('SPPDocuSignUtils', 'createDocuSignStatusRecord', e);
        }
        
        return dStatus.Id;
    }
    
}