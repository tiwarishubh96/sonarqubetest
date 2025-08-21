/*********************************************************************
Name    : SppSendTemplateWithDocuSign
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This class is used to perform operation on Account to send Templates to Client based on Locale , partner type and tiers.
**********************************************************************/
global class SPPDocuSignSendTemplate
{
    
    webservice Static Result sendTemplates(String accId,Contact con)
    {
        Result res = new Result();
        res.isSuccess = false;
        
        SPPTnCValidationsStrings validateMsg = new SPPTnCValidationsStrings();
        String returnString = '';
        List<Partner_Terms_and_Condition__c> pTnCList = new List<Partner_Terms_and_Condition__c>();
        AccountAndTemplatesDetailsList accAndTempDetListObj;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        
        accAndTempDetListObj = getTemplateList(accId,conList);  
        System.debug('accAndTempDetListObj :'+accAndTempDetListObj);
        
         if(accAndTempDetListObj != null)
        {
            if(accAndTempDetListObj.errorMessage != null )
            {
                res.message =  accAndTempDetListObj.errorMessage;
            }
            else
            {
                
                List<accountAndTemplatesDetails> accountAndTemplatesDetailsList = accAndTempDetListObj.accountAndTemplatesDetailsList;
                
                Account acc = accAndTempDetListObj.acc;
                
                //accAndTempDetListObj.conList;
                SPPDocuSignRest docuSignRest = new SPPDocuSignRest();
                SPPWrapperDocuSign response;
                
                
                for(accountAndTemplatesDetails accTempObj: accountAndTemplatesDetailsList)
                {
                    if(accTempObj.errorMessage == null || accTempObj.errorMessage == '')
                    {
                        map<Integer , String> templateMap = accTempObj.templateMap;
                        List<Terms_Conditions_Version__c> tnCVersList = accTempObj.tnCVersList;
                        String partnerType = accTempObj.partnerType;
                        response = docuSignRest.sendEnvelope(conList , templateMap ,acc ,partnerType);
                        System.debug('response : '+response);
                        if(response != null){
                            if(response.errorCode != null)
                            {
                                returnString = response.message;
                               
                            }else
                            {
                                pTnCList.add(PreparePartnerJunction(response.envelopeId , tnCVersList[0] , acc , conList) );
                                
                            }
                        }else
                        {
                            System.debug('Error While Sending Partner Type : '+partnerType);
                        }
                    }
                }
                
                if(!pTnCList.isEmpty())
                {
                    system.debug('pTnCList :'+pTnCList);
                    insert pTnCList;
                    res.message = 'Partner Legal Agreements Sent Successfully';
                    res.isSuccess = true;
                }else
                {
                    res.message = 'Error While Sending agreement ' + returnString;
                    res.isSuccess = false;
                }
                 
            }
        }
        system.debug('result : '+res);
        return res;
    }
        
    public Static AccountAndTemplatesDetailsList getTemplateList(String accId,List<Contact> con)
    {
        //Class to get validation Messages 
        SPPTnCValidationsStrings validateMsg = new SPPTnCValidationsStrings();
        
        List<Terms_Conditions_Community__c> lstcomm;
        AccountAndTemplatesDetailsList accTemp = new AccountAndTemplatesDetailsList();
        map<String , String > tempSet = new map<String , String>();
        List<Terms_Conditions_Version__c> tnCVersList = new List<Terms_Conditions_Version__c>();
        
        //To all Account Fields 
        String fieldsAPIname = SPPUtils.ObjectFields('Account');
        System.debug('fieldsAPIname : '+ fieldsAPIname);
        
        Account acc = Database.query('Select Locale__r.Name,Owner.Email, Owner.Name, Owner.Username,Owner.title,'+fieldsAPIname+' from Account WHERE Id = \'' + String.escapeSingleQuotes(accId) + '\' limit 1');
        /*
        if(acc.Bespoke_Partner__c == true)
        {
            accTemp.errorMessage = validateMsg.bespokeMsg;
            return accTemp;
        }*/
        System.debug('acc :'+ acc);
        /*List<Contact> con = [Select id,Name , email ,Phone from contact where Account.Id = :acc.Id and Legal_Contact__c = true];
        if(con.isEmpty() )
        {
            accTemp.errorMessage = validateMsg.noLegal;
            return accTemp;
        }*/
        
        //Access custom metadatatype
        Partner_Field__mdt[] partnerfieldMapping = [SELECT MasterLabel, QualifiedApiName,DeveloperName, Partners__c ,Partner_Tier__c,Partner_TnC_Accepted__c FROM Partner_Field__mdt];
        
        String strPartnerTypes ='';
        String strPartnerTier = '';
        Set<string> setPartnerTypes = new Set<string>();
        List<string> setPartnerTiers = new List<string>();
        Map<string,string> mappartnerNameTnC = new Map<string,string>();
        
        if(!partnerfieldMapping.Isempty() )
        {
            
            for(Partner_Field__mdt objPfield : partnerfieldMapping)
            {
                System.debug('objPfield : '+ objPfield);
                //Condition to check if Partner and Partner Tier has some values 
                //and Partner_TnC_Accepted__c false to show the latest Attachments
                if(acc.get(objPfield.Partners__c) == true && acc.get(objPfield.Partner_Tier__c) != null && 
                   acc.get(objPfield.Partner_TnC_Accepted__c) == false)
                {
                    
                    //isLegalContact = true; // show tnc changed message 
                    
                    setPartnerTypes.add(objPfield.MasterLabel);
                    setPartnerTiers.add(String.ValueOf(acc.get(objPfield.Partner_Tier__c)));
                    //lstacc[0].put(String.ValueOf(objPfield.Partner_TnC_Accepted__c),true);
                    
                    mappartnerNameTnC.put(objPfield.MasterLabel,objPfield.Partner_TnC_Accepted__c);
                    System.debug('mappartnerNameTnC : '+ mappartnerNameTnC);
                }
            }
            
            strPartnerTier  = returnpartnertiers(setPartnerTiers);}
        
        system.debug('strPartnerTier  '+strPartnerTier  );
        system.debug('strPartnerTipes  '+setPartnerTypes);
        List<accountAndTemplatesDetails> accWrapperList = new List<accountAndTemplatesDetails>();
        for(String partnerType : setPartnerTypes)
        {
            accountAndTemplatesDetails accTempObj = getTemplateListForPartnerType(acc,partnerType,strPartnerTier,acc.Locale__r.Name,con);
            if(accTempObj.errorMessage == '' || accTempObj.errorMessage == NULL)
                accWrapperList.add(accTempObj);
            
        }
        if(accWrapperList.isEmpty())
           accTemp.errorMessage = SPPTnCValidationsStrings.noTemplates;
        accTemp.accountAndTemplatesDetailsList = accWrapperList;
        accTemp.acc = acc;
        //accTemp.conList = con;
        return accTemp;

    }
    public Static accountAndTemplatesDetails getTemplateListForPartnerType(Account acc,String partnerType,String strPartnerTiers,String local,List<contact> conList)
    {
        accountAndTemplatesDetails accTemp = new accountAndTemplatesDetails();
        
        //Store Oder and Template Id
        map<Integer , String> tempMap = new map<Integer , String>();
        List<Terms_Conditions_Version__c> tnCVersList = new List<Terms_Conditions_Version__c>();
        try{
            TnCwrapper tnc = getTemplateMapWithOrder(partnerType, strPartnerTiers,local,acc);
            if(tnc.errorMessage != '' || tnc.TemplateOrderAndValue == null || tnc.TnCGlobalValues == null)
            {
                accTemp.errorMessage = tnc.errorMessage;
            }else
            {
                
                System.debug('tnc : '+tnc);
                System.debug('tnc 2: '+tnc.TemplateOrderAndValue);//Value , MetaData Label
                System.debug('tnc 3: '+tnc.TnCGlobalValues);
                map<String,String> templateOrderAndValue = tnc.TemplateOrderAndValue;
                for(Terms_Conditions_Community__c objTrmCond : tnc.TnCGlobalValues)
                {
                    
                    Integer order = integer.valueof( templateOrderAndValue.get(objTrmCond.Document_Type__c) );
                    for(Terms_Conditions_Version__c objTrmVer : objTrmCond.Terms_Conditions_Versions__r)
                    {
                        //if(objTrmVer.Partner_Types__c == mappartnerNameTnC.get(objTrmVer.Partner_Types__c))
                        if(objTrmVer.Docusign_Template_ID__c != null)
                        {
                            tempMap.put(order,objTrmVer.Docusign_Template_ID__c);
                            
                            
                            //tempMap.put(objTrmVer.Docusign_Template_ID__c , objTrmVer.Partner_Type__c);
                            if(objTrmCond.Document_Type__c == 'Enrollment Forms')
                            {
                                
                                tnCVersList.add(objTrmVer);
                            }
                            
                        }
                        
                    }
                }//End Of for Loop
                
            }
            accTemp.templateMap = tempMap;
            accTemp.tnCVersList = tnCVersList;
            accTemp.partnerType = partnerType;
        }catch(Exception ex)
        {
            accTemp.errorMessage = 'Error While Creating Template List';
            ExceptionHandler.CatchException('SppTemplateOrder', 'getTemplateListForPartnerType Method', ex);
        }
        
        
        return accTemp;
        
    }
    
    public static TnCwrapper getTemplateMapWithOrder(String setPartnerType , String strPartnerTier , String loc,Account acc)
    {
        String patAgreement = acc.Partner_Agreement__c;
        String mes = '';
        System.debug('setPartnerType :'+setPartnerType);
        System.debug('strPartnerTier :'+strPartnerTier);
        System.debug('patAgreement :'+patAgreement);
        System.debug('loc :'+loc);
        Map<String , String> orderValues;
         // string strPartnerName = 'Sage Partner Community';   
        string strpartnerQuery = 'Select Partner_Tiers__c, Document_Type__c, Partner_Types__c,Isglobal__c, (Select Id, Name, Version_Number__c, Start_Date_Active__c, End_Date_Active__c,';
        strpartnerQuery += 'Approved_Date__c, Locale__c, Active__c,Terms_Conditions__c,Partner_Type__c,';
        strpartnerQuery += 'Terms_Conditions_Community__c, Docusign_Template_ID__c From Terms_Conditions_Versions__r where Active__c = true and Start_Date_Active__c != null and End_Date_Active__c = null Limit 1) From Terms_Conditions_Community__c';
        strpartnerQuery += ' where Active__c = true and Partner_Types__c  = :setPartnerType and Partner_Tiers__c INCLUDES ('+strPartnerTier+')';
        strpartnerQuery += ' and Partner_Locale__r.Name = :loc and Partner_Agreement__c = :patAgreement and isGlobal__c = false and Community_Only__c  = false';
        
        system.debug('strpartnerQuery '+strpartnerQuery );
        List<Terms_Conditions_Community__c> lstcomm = Database.query(strpartnerQuery);
        system.debug('lstcomm '+lstcomm );
        
        
        if(!lstcomm.isEmpty())
        {
            orderValues = getTemplateOder(setPartnerType);
            Set<String> listValues = orderValues.keySet();
            string strpartnerQueryIsGlobal = 'Select Partner_Tiers__c,  Document_Type__c ,Partner_Types__c,Isglobal__c, (Select Id, Name, Version_Number__c, Start_Date_Active__c, End_Date_Active__c,';
            strpartnerQueryIsGlobal += 'Approved_Date__c, Locale__c, Active__c,Terms_Conditions__c,Partner_Type__c,';
            strpartnerQueryIsGlobal += 'Terms_Conditions_Community__c, Docusign_Template_ID__c From Terms_Conditions_Versions__r where Active__c = true and Start_Date_Active__c != null and End_Date_Active__c = null Limit 1) From Terms_Conditions_Community__c';
            strpartnerQueryIsGlobal += ' where Active__c = true and Partner_Agreement__c = :patAgreement and Partner_Locale__r.Name = :loc and isGlobal__c = true and Document_Type__c In :listValues and Community_Only__c  = false';
            
            List<Terms_Conditions_Community__c> lstCommGlobal = Database.query(strpartnerQueryIsGlobal);
            system.debug('strPartnerTipes strpartnerQueryIsGlobal '+string.valueOf(lstCommGlobal ));
            lstcomm.addAll(lstCommGlobal);
        }else
        {
            System.debug('There are no Templates to display..');
            mes = SPPTnCValidationsStrings.noTemplates;
        }
        TnCwrapper tncObj = new TnCwrapper();
        tncObj.TemplateOrderAndValue = orderValues;
        tncObj.TnCGlobalValues= lstcomm;
        tncObj.errorMessage = mes;
        return tncObj;
    }
    
    public Static String returnpartnertiers(List<String> strings)
    {
       String partnertiers= '\'';
       partnertiers+= String.join(strings, '\',\'');
       partnertiers += '\'';
       return partnertiers;
    }
    
    public static Map<String , String> getTemplateOder(String label)
    {
        String metaDataName = 'Docusign_Templates_Order__mdt';
        Map<String , String> metaDataFieldsApiLabel = ObjectFields(metaDataName);
        
        String fields = ListToString( metaDataFieldsApiLabel.values() );
        
        Docusign_Templates_Order__mdt[] DocuSignMetaDataOrder = Database.query('SELECT '+fields+' FROM Docusign_Templates_Order__mdt where MasterLabel =:label');
        Map<String , String> orderValu = mapOderAndValue(DocuSignMetaDataOrder[0] , metaDataFieldsApiLabel);
        
        return orderValu;
    }
    
    //Prepare the map with value and order
    public static Map<String , String> mapOderAndValue(Docusign_Templates_Order__mdt objTemp ,Map<String , String> mapApiLabel)
    {
        Map<String , String> mapOrderValue = new Map<String , String>();
        
        for(String apiName : mapApiLabel.keySet() )
        {
            String val = (String)objTemp.get( mapApiLabel.get(apiName) );
            if(val != null && val != '')
                mapOrderValue.put(val,apiName); 
        }
        
        return mapOrderValue;
    }
    
    //Method to convert from list of string to string comma seperated.
    public static String ListToString(List<String> metaDataFieldsList)
    {
        String fieldsVal ='';
        for(string f : metaDataFieldsList)
        {
           fieldsVal += f +',';
        }   
        if(fieldsVal.endsWith(','))
            fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
        return fieldsVal;
    }
    
    //Method to get map of object field Label and api name. 
    public static Map<String , String> ObjectFields(String ObjectNameval)
     {
         string fieldsVal = '';
         SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);
         DescribeSObjectResult objDef = objToken.getDescribe();
         Map<String, SObjectField> fields = objDef.fields.getMap();
         
         Map<String , String> fieldsApiLabel = new Map<String , String>();
         Set<String> fieldSet = fields.keySet();
         
         System.debug('fieldSet : '+fieldSet);
         for(String fieldName : fieldSet)
         {
             fieldsApiLabel.put(fields.get(fieldName).getDescribe().getLabel() ,fieldName);
             
         }
         
         List<String> checkFields = new List<String>();
         Map<String , String> OrderApiLabel = new Map<String , String>();
         
         for(integer i=1 ; i< fieldsApiLabel.size() ;i++)
         {
             checkFields.add(''+i+'');
         }
         
         for(String fieldsName : checkFields)
         {
             String fApi = fieldsApiLabel.get( fieldsName );
             if(fApi != null)
                OrderApiLabel.put(fieldsName,fApi);
         }
         
        return OrderApiLabel;
     }
    class TnCwrapper
    {
        Map<String , String> TemplateOrderAndValue;
        List<Terms_Conditions_Community__c> TnCGlobalValues;
        String errorMessage;
    }
    
     /*Wrapper class to get Account Details and Template Set*/ 
    public class accountAndTemplatesDetails
    {
        public map<Integer , String> templateMap;
        public List<Terms_Conditions_Version__c> tnCVersList;
        public String partnerType;
        public String errorMessage ;
    }
    
    public class AccountAndTemplatesDetailsList
    {
        public List<accountAndTemplatesDetails> accountAndTemplatesDetailsList;
        public Account acc;
        public List<Contact> conList;
        public String errorMessage ;
    }
    global class Result 
    {
        webservice String message;
        webservice Boolean isSuccess;
    }
    /*
    public Static Boolean isTemplateVersionPending(String accId)
    {

        List<String> statusList = new List<String>();
        statusList.add('Pending');
        statusList.add('Sent');
        Boolean isTrue ;
        List<Partner_Terms_and_Condition__c> partnerList;
        try{
            partnerList= [Select id,Docusign_Status__c from Partner_Terms_and_Condition__c where Account__c =:accId and Docusign_Status__c IN :statusList];
            isTrue = !partnerList.isEmpty();
        }catch(Exception ex)
        {
            isTrue = true;
            ExceptionHandler.CatchException('SPPSendTnCWithDocuSignController', 'isTemplateVersionPending Method', ex);
        }
        system.debug('partnerList : '+partnerList);
        return isTrue;
    }*/
    public Static Partner_Terms_and_Condition__c PreparePartnerJunction(String envId , Terms_Conditions_Version__c termVerObj , Account acc,List<Contact> conList)
    {
       // List<Partner_Terms_and_Condition__c pTnCList = new List<Partner_Terms_and_Condition__c>();

        Partner_Terms_and_Condition__c pTnCObj = new Partner_Terms_and_Condition__c();
        pTnCObj.DocuSign_EnvelopeId__c = envId;
        pTnCObj.Terms_Conditions_Version__c = termVerObj.Id;
        pTnCObj.Docusign_Status__c = 'Pending';
        pTnCObj.Account__c = acc.Id;
        pTnCObj.Contact__c = conList[0].id;
        //pTnCList.add(pTnCObj);
        
        //System.debug('pTnCList : '+pTnCList);
        return pTnCObj;
    }
}