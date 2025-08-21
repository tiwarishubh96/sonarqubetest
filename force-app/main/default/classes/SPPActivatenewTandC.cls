/*********************************************************************
Name    : SPPActivatenewTandC
Author  : Raja Patnaik
Date    : 04/14/2017
Description :  This Class is used to activate/De-activate tnc and its associated partners TnCs
**********************************************************************/
global class SPPActivatenewTandC
{
    //Commenting all docusign Related Code
    
    webservice static Result activateTnC(Id tncID,String partnerType,boolean isglobal,String partnerTiers,String localeval,Id tcvId ) 
    { 
        //Class to get validation Messages 
        SPPTnCValidationsStrings validateMsg = new SPPTnCValidationsStrings();
        system.debug('tcvId: '+tcvId);
        Set<Id> setAccId = new Set<Id>();
        List<Partner_Field__mdt> partnerfieldMapping = new List<Partner_Field__mdt>();
        Map<String,Partner_Field__mdt> mapPartner = new Map<String,Partner_Field__mdt>();
        List<String> stpartnertiers = partnerTiers.split(';');//Split Partner Tiers and Put into a List of String
        Terms_Conditions_Version__c currentTnC = [Select id,End_Date_Active__c,Active__c, Terms_Conditions_Community__r.Community_Only__c ,Partner_Agreement__c from Terms_Conditions_Version__c where id =:tcvId];
        System.debug('currentTnC : '+currentTnC );
        Result res = new Result();
        res.issuccess = false;
        
        if(currentTnC.End_Date_Active__c != null )  
        {
            if(!currentTnC.Active__c)
            {
                res.message = validateMsg.validateDeActivated;
                return res;
            }else
            {
                res.message = validateMsg.validateActivated;
                return res;
            }
            
        }else
        {
            if(currentTnC.Active__c)
            {
                res.message = validateMsg.validateActivated;
                return res;
            }
        }
        
        List<Id> contactids = new List<Id>();
        //Pick the latest - 1 record to deactivate and put the end date
        List<Terms_Conditions_Version__c> lstTnCversion = [Select Id,End_Date_Active__c,Active__c,Version_Number__c from Terms_Conditions_Version__c 
                                                           where Terms_Conditions_Community__c =: tncID and Active__c = true and End_Date_Active__c = null and Terms_Conditions_Community__r.TnC_Versions_Count__c > 1 order by createddate asc limit 1];
        //Loop thru the Tnc Version record and De-activate the old one   
        for(Terms_Conditions_Version__c objTnCver : lstTnCversion)
        {
            //Adding 30 days as grace period to the TnC version and It's Configurable
            objTnCver.End_Date_Active__c = Date.Today().addDays(Integer.ValueOf(Label.TermsandConditionGraceDays));
            objTnCver.Active__c = false;
        }
        
        string fieldsAPIname = '';
        fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        List<String> statusList = new list<String>();
        statusList.add('Sent');
        statusList.add('Pending');
        
        //Query too fetch Account record details
        string strparentqry = 'Select (Select id,Account__c,DocuSign_Status__c,Partner_Type__c,Voided__c from Partner_Terms_and_Conditions__r where DocuSign_Status__c IN :statusList),Locale__r.Name ,'+fieldsAPIname+' from Account WHERE Locale__r.Name = \'' + localeval + '\' and Bespoke_Partner__c = false and ';
        
        strparentqry += ' Partner_Agreement__c = \'' +  currentTnC.Partner_Agreement__c  + '\' and ' ; 
        
        //SOQL on Partner Custom Meta Data to get the all the Field API names related to different Partner
        partnerfieldMapping = [SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,Partner_Tier__c,Partner_TnC_Accepted__c
                               FROM Partner_Field__mdt];
        
        strparentqry += '(' ;
        
        //Iterating Over Custom Meta Records
        
        for(Partner_Field__mdt obj : partnerfieldMapping)
        {
            mapPartner.put(obj.MasterLabel,obj);
            if(isglobal)
                strparentqry += obj.Partner_TnC_Accepted__c+' = true OR ';//This Query will executed in both Global and Non-Global(Particular Partner Type / Tiers) 
        }
        
        system.debug('isglobal'+isglobal);
        
        system.debug('strparentqry '+strparentqry );
        
        if(!isglobal)//Only applicable for Selected Partner Type and Tiers
        {
            Partner_Field__mdt pfield = mapPartner.get(partnerType);//pass accountant
            
            for(String strr :partnerTiers.split(';'))
            { 
                strparentqry += '('+Pfield.Partners__c +' = true and '+Pfield.Partner_TnC_Accepted__c +' = true and '+pfield.Partner_Tier__c ;
                strparentqry += ' = \'' + strr + '\') OR' ;
            }
        }
        
        strparentqry = strparentqry.trim().removeEnd('OR');
        strparentqry += ')' ;
        
        system.debug('Final query'+strparentqry );
        
        List<Account> lstacc = Database.query(strparentqry);// Execute the final SOQL query to retrive all the Accounts based on the above conditions
        
        Partner_Field__mdt pfield = mapPartner.get(partnerType);//pass Partner Type 
        
        Set<Id> selAccId =new Set<Id>();
        
        system.debug('lstacc : '+lstacc);
        // Update All the Accounts
        SPPDocuSignBulkRestService.BulkResponse bulkRes;
        if(!currentTnC.Terms_Conditions_Community__r.Community_Only__c)
        {
            SPPDocuSignBulkRestService sppTnCUtil = new SPPDocuSignBulkRestService();
            if(!lstacc.isEmpty())
            {
                bulkRes = sppTnCUtil.onActivateTnCVersions(tcvId , lstacc );
            }else
            {
                bulkRes = new SPPDocuSignBulkRestService.BulkResponse();
                bulkRes.status = true;
                bulkRes.message = 'There are No Accounts to Send Updated Agreement';
            }
            system.debug('lstTnCversion : ' +lstTnCversion);
            if(bulkRes.status)
            {
                System.debug('Templates send to all Contacts');
                if(!lstTnCversion.isEmpty())
                    update lstTnCversion;
                
            }
            res.message = bulkRes.message;
            res.issuccess = bulkRes.status;
            
        }else
        {
            if(!lstTnCversion.isEmpty())
                update lstTnCversion;
            res.message = validateMsg.activated;
            res.issuccess = true;
        }
        
        
        return res;
        
    }
    /*

webservice static Result activateTnC(Id tncID,String partnerType,boolean isglobal,String partnerTiers,String localeval,Id tcvId ) 
{ 
//Class to get validation Messages 
SPPTnCValidationsStrings validateMsg = new SPPTnCValidationsStrings();
system.debug('tcvId: '+tcvId);
//Set<Id> setAccId = new Set<Id>();
// List<Partner_Field__mdt> partnerfieldMapping = new List<Partner_Field__mdt>();
//Map<String,Partner_Field__mdt> mapPartner = new Map<String,Partner_Field__mdt>();
//List<String> stpartnertiers = partnerTiers.split(';');//Split Partner Tiers and Put into a List of String
Terms_Conditions_Version__c currentTnC = [Select id,End_Date_Active__c,Active__c, Terms_Conditions_Community__r.Community_Only__c ,Partner_Agreement__c from Terms_Conditions_Version__c where id =:tcvId];
System.debug('currentTnC : '+currentTnC );
Result res = new Result();
res.issuccess = false;

if(currentTnC.End_Date_Active__c != null )  
{
if(!currentTnC.Active__c)
{
res.message = validateMsg.validateDeActivated;
return res;
}else
{
res.message = validateMsg.validateActivated;
return res;
}

}else
{
if(currentTnC.Active__c)
{
res.message = validateMsg.validateActivated;
return res;
}
}

List<Id> contactids = new List<Id>();
//Pick the latest - 1 record to deactivate and put the end date
List<Terms_Conditions_Version__c> lstTnCversion = [Select Id,End_Date_Active__c,Active__c,Version_Number__c from Terms_Conditions_Version__c 
where Terms_Conditions_Community__c =: tncID and Active__c = true and End_Date_Active__c = null and Terms_Conditions_Community__r.TnC_Versions_Count__c > 1 order by createddate asc limit 1];
//Loop thru the Tnc Version record and De-activate the old one   
for(Terms_Conditions_Version__c objTnCver : lstTnCversion)
{
//Adding 30 days as grace period to the TnC version and It's Configurable
objTnCver.End_Date_Active__c = Date.Today().addDays(Integer.ValueOf(Label.TermsandConditionGraceDays));
objTnCver.Active__c = false;
}
/*
string fieldsAPIname = '';
fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 

List<String> statusList = new list<String>();
statusList.add('Sent');
statusList.add('Pending');

//Query too fetch Account record details
string strparentqry = 'Select (Select id,Account__c,DocuSign_Status__c,Partner_Type__c,Voided__c from Partner_Terms_and_Conditions__r where DocuSign_Status__c IN :statusList),Locale__r.Name ,'+fieldsAPIname+' from Account WHERE Locale__r.Name = \'' + localeval + '\' and Bespoke_Partner__c = false and ';

strparentqry += ' Partner_Agreement__c = \'' +  currentTnC.Partner_Agreement__c  + '\' and ' ; 

//SOQL on Partner Custom Meta Data to get the all the Field API names related to different Partner
partnerfieldMapping = [SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,Partner_Tier__c,Partner_TnC_Accepted__c
FROM Partner_Field__mdt];

strparentqry += '(' ;

//Iterating Over Custom Meta Records

for(Partner_Field__mdt obj : partnerfieldMapping)
{
mapPartner.put(obj.MasterLabel,obj);
if(isglobal)
strparentqry += obj.Partner_TnC_Accepted__c+' = true OR ';//This Query will executed in both Global and Non-Global(Particular Partner Type / Tiers) 
}

system.debug('isglobal'+isglobal);

system.debug('strparentqry '+strparentqry );

if(!isglobal)//Only applicable for Selected Partner Type and Tiers
{
Partner_Field__mdt pfield = mapPartner.get(partnerType);//pass accountant

for(String strr :partnerTiers.split(';'))
{ 
strparentqry += '('+Pfield.Partners__c +' = true and '+Pfield.Partner_TnC_Accepted__c +' = true and '+pfield.Partner_Tier__c ;
strparentqry += ' = \'' + strr + '\') OR' ;
}
}

strparentqry = strparentqry.trim().removeEnd('OR');
strparentqry += ')' ;

system.debug('Final query'+strparentqry );

List<Account> lstacc = Database.query(strparentqry);// Execute the final SOQL query to retrive all the Accounts based on the above conditions

Partner_Field__mdt pfield = mapPartner.get(partnerType);//pass Partner Type 

Set<Id> selAccId =new Set<Id>();

system.debug('lstacc : '+lstacc);
// Update All the Accounts
// 

SPPBulkTnCUtils.BulkResponse bulkRes;
if(!currentTnC.Terms_Conditions_Community__r.Community_Only__c)
{*/
    /*
SPPBulkTnCUtils sppTnCUtil = new SPPBulkTnCUtils();
if(!lstacc.isEmpty())
{
bulkRes = sppTnCUtil.onActivateTnCVersions(tcvId , lstacc );
}else
{
bulkRes = new SPPBulkTnCUtils.BulkResponse();
bulkRes.status = true;
bulkRes.message = 'There are No Accounts to Send Updated Agreement';
}


system.debug('lstTnCversion : ' +lstTnCversion);
if(bulkRes.status)
{
System.debug('Templates send to all Contacts');
if(!lstTnCversion.isEmpty())
update lstTnCversion;

}
res.message = bulkRes.message;
res.issuccess = bulkRes.status;

}else
{*-/
if(!lstTnCversion.isEmpty())
update lstTnCversion;
res.message = validateMsg.activated;
res.issuccess = true;
// }


return res;

}
*/
    global class Result 
    {
        webservice String message;
        webservice Boolean issuccess;
    }
    
}