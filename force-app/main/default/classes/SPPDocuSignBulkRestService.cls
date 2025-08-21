/*********************************************************************
Name    : SPPDocuSignBulkRestService
Company : Docmation LLC 
Author  : Lakshman Jaasti
Date    : 06/15/2017
Description :  Utility Class for Docusign SPP Bulk Integration 
**********************************************************************/
public class SPPDocuSignBulkRestService  {
   
    
     //Method called from activate button controller processTnC 
    public BulkResponse onActivateTnCVersions(String TemplateVersionId , List<Account> accList )
    {
         //Class to get validation Messages 
        SPPTnCValidationsStrings validateMsg = new SPPTnCValidationsStrings();
        
        BulkResponse res = new BulkResponse();
        String mes ;
        Boolean isSuccess = true;
        Terms_Conditions_Version__c tncv = [Select Id,DocuSign_Bulk_Template_Id__c,Partner_Type__c from Terms_Conditions_Version__c Where Id =:TemplateVersionId limit 1]; 
        if(tncv.DocuSign_Bulk_Template_Id__c != null)
        {

            accListObject accObj = divideAccountsBasedOnPartnerCount(accList , tncv);
            //accList = accObj.SingleAccList;
            
            try
            {   
                SPPWrapperDocuSign reponseDraft = SPPDocuSignBulkRest.CreateEnvelopDraftWithTemplate(tncv.DocuSign_Bulk_Template_Id__c);
                SPPWrapperDocuSign reponseRecip;
                SPPWrapperDocuSign reponseUpdate ;
                CsvAndMap  csvAndMap ;
                if(reponseDraft != null && reponseDraft.errorCode == null)
                {
                    System.debug('accList :: '+accList);
                    csvAndMap = getCsvString(TemplateVersionId,accList,tncv);
                    System.debug('csvAndMap :'+csvAndMap);
                    if(csvAndMap != null)
                    {
                        reponseRecip = SPPDocuSignBulkRest.createBulkRecipientsFromCSV(reponseDraft.envelopeId , csvAndMap.csv);
                    }
                }else
                {
                    ExceptionHandler.CatchException('SPPTnCUtils1', 'Error While Creating Draft line 184', null,csvAndMap.toString() );
                    
                }
                
                if(reponseRecip != null && reponseRecip.errorCode == null)
                {
                    reponseUpdate = SPPDocuSignBulkRest.updateEnvelope(reponseDraft.envelopeId);
                    system.debug('reponseUpdate : '+reponseUpdate);
                    if(reponseUpdate.errorCode == null)
                    {
                        String batchId = reponseUpdate.BulkEnvelopeStatus.batchId;
                        if(batchId != null)
                        {
                            try 
                            {
                                //insertBulkJunctionObj(batchId,  csvAndMap.conAccMap , csvAndMap.contactMap, TemplateVersionId);
                                SPPScheduleDocuSignBulkWrapper sppWrapper = new SPPScheduleDocuSignBulkWrapper();
                                sppWrapper.batchId = batchId;
                                sppWrapper.templateVersId = TemplateVersionId;
                                sppWrapper.accAndConMap = csvAndMap.conAccMap;
                                sppWrapper.conMap = csvAndMap.contactMap;
                                String sppSchedule = JSON.serialize(sppWrapper);

                                SPPBulkScheduleDocuSign sppf = new SPPBulkScheduleDocuSign(sppSchedule);
                                Datetime dateT = Datetime.now();

                                Datetime d = dateT.addMinutes(2);
                                String hour = String.valueOf(d.hour());
                                String min = String.valueOf(d.minute()); 

                                String ss = String.valueOf(d.second());

                                //parse to cron expression
                                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                                String name = 'TermsAndConditions'+Datetime.Now().millisecond();

                                system.schedule(name, nextFireTime, sppf);
                                mes = validateMsg.BulkSentSuccess;
                                
                                isSuccess = true;
                                if(accObj.parJuncUpdateList != null && !accObj.parJuncUpdateList.isEmpty() )
                                    updatePartnerJunction( accObj.parJuncUpdateList );
                            }catch(Exception ex)
                            {
                                System.debug('Error while update Draft : '+ex.getMessage()); 
                                ExceptionHandler.CatchException('SPPTnCUtils1', 'onActivateTnCVersions Method', ex,csvAndMap.toString() );
                            }
                        }
                        else
                        {
                            //ExceptionHandler.CatchException('SPPTnCUtils1', 'Error While schedule Apx Job', null,csvAndMap.toString() );
                    
                        }
                            
                        

                    }else
                    {
                        //ExceptionHandler.CatchException('SPPTnCUtils1', reponseUpdate.message, null,csvAndMap.toString() );
                        
                    }
               }else
               {
                    //if(mes == null || mes == '')
                        //ExceptionHandler.CatchException('SPPTnCUtils1', 'Error While Adding Recipients ', null,csvAndMap.toString() );
                    
                    
               }
               
            }catch(Exception ex)
            {
                system.debug('Error onActivateTnCVersions: '+ex.getMessage());
                
                ExceptionHandler.CatchException('SPPTnCUtils', 'onActivateTnCVersions Method', ex);    
            }

        }
        else
        {
            //ExceptionHandler.CatchException('SPPTnCUtils', 'onActivateTnCVersions Method', null,validateMsg.bulkTempEmpty);
           
        }

        res.status = isSuccess;
        if(mes == '' || mes == null)
            mes = 'Activated Successfully but error while Sending Bulk';
        res.message = mes;
        system.debug('res : '+ res);
        return res;
    }

    //Method Used to Create CSV file data.
    public CsvAndMap getCsvString(String TemplateVersionId , List<Account> accList ,Terms_Conditions_Version__c tncv)
    {

        //String fieldsAPIname = ObjectFields('Account');
        //List<Account> accList  = Database.query('Select Locale__r.Name,'+fieldsAPIname+' from Account limit 10');
        CsvAndMap csvObj = new CsvAndMap();
        //Terms_Conditions_Version__c tncv = [Select Id,Docusign_Template_ID__c,Partner_Type__c from Terms_Conditions_Version__c Where Id =:TemplateVersionId limit 1]; 
        DocuSign_Field__mdt[] docuSignField = [SELECT DocuSign_Custom_Label__c, Object_Name__c , SF_API_Field_Name__c FROM DocuSign_Field__mdt where Object_Name__c = 'Account'];
        // Map to store contact email Id and account object to insert Junction Objects records with Envelope Id
        Map<String , Account> juncMap = new Map<String , Account>();
        Map<String , Contact> juncConMap = new Map<String , Contact>();
        //List<Partner_Terms_and_Condition__c> pTnCList = new List<Partner_Terms_and_Condition__c>();
        
        Map<String, DocuSign_Field__mdt> mapDocuSignField =new Map<String,DocuSign_Field__mdt>();
        mapDocuSignField.put('Name',null);
        mapDocuSignField.put('Email',null);
        mapDocuSignField.put('SppTitle',null);
        for(DocuSign_Field__mdt obj : docuSignField){
            mapDocuSignField.put(obj.DocuSign_Custom_Label__c ,obj);//This is map and hence it will always have unique values 
        }
         mapDocuSignField.put('SageProduct',null);

        String csvFileString = ''; 
        for( String headerValues : mapDocuSignField.keySet() )
        {
            if(csvFileString != '')
            {
                csvFileString += ',';
                
            }
            csvFileString += headerValues;

        } 
        
        csvFileString += '\n';
        String testcsvFileString = csvFileString;
        system.debug('csvFileString : '+csvFileString);
        
        map<String , Contact> conMap = getLegalContact(accList);
        /*Testing Bulk Fake Data
        accList.clear();
        conMap.clear();
        for(Integer i=0; i<101;i++)
        {
            Account acc =new Account();
            String idString; 
            if(i<10)
                idString = '0017E00000Zzon'+i;
            else if(i<100)
                idString = '0017E00000Zzo'+i;
            else if(i<1000)
                idString = '0017E00000Zz'+i;
            
            //acc.id = idString;
            acc.Name = 'Test'+i;
            acc.Partner_Accountant__c = true;
            acc.Accountant_Partner_Tier__c = 'Authorized';
            acc.Locale_Billing_CC__c = 'US';
            acc.Company_Registration_Number__c = '12122';
            
            acc.Partner_Account_ID__c = '1212';
            acc.recordtypeid='01224000000LEwm';
            acc.Sales_Office__c='Atlanta CBC';
            acc.BillingCity='Austin';
            acc.BillingPostalCode='78666';
            acc.BillingCountry='United States';
            acc.BillingState='Texas';
            acc.BillingStreet='test';
            acc.Partner_Reseller__c = false;
            acc.Partner_Implementation__c = false;
            acc.Partner_ISV__c = false;
            acc.Partner_Alliance__c = false;
            
            acc.SI_Partner_Tier__c = '';
            acc.Alliance_Partner_Tier__c = '';
            acc.ISV_Partner_Tier__c = '';
            acc.Reseller_Partner_Tier__c = '';
            Contact con = new Contact(lastName='TestUser',FirstName='TestCon'+i,Email='ljaasti+'+i+'@gmail.com',Title='Developer');
            accList.add(acc);
            conMap.put(acc.Id, con);
            
        }
        system.debug('AccList: '+accList);
        system.debug('conMap: '+conMap);*/
        Map<String, String> accountProductMap = SPPDocuSignUtils.getProductList(accList);
        for(Account acc : accList)
        {
            system.debug('acc :'+acc);
            Contact con = conMap.get(acc.Id);
            system.debug('con :'+con);
            if(con != null)
            {
                system.debug('con :'+con);
                String dataCsvString = '';
                SPPDocuSignCompositeJson.RestAPIServices obj = new SPPDocuSignCompositeJson.RestAPIServices();
                map<String , String > mapCustTags =  obj.getCustomTagsMap(acc , tncv.Partner_Type__c,accountProductMap.get(acc.Id));
                system.debug('mapCustTags :'+mapCustTags);
                juncMap.put(con.Email, acc);
                juncConMap.put(con.Email, con);
                //pTnCList.add( getPartnerTCObject(acc , con , TemplateVersionId) );

                for( String headerValues : mapDocuSignField.keySet() )
                {
                    if(dataCsvString != '')
                    {
                        dataCsvString += ',';
                        
                    }
                    if(headerValues == 'Name')
                        dataCsvString += con.Name;

                    else if(headerValues == 'Email')
                        dataCsvString += con.Email;
                    else if(headerValues == 'SPPTitle')
                        dataCsvString += con.Title;
                    else
                    dataCsvString += mapCustTags.get(headerValues);

                }
                dataCsvString += '\n';
                csvFileString += dataCsvString;
            }

        }
        system.debug('csvFileString outSide for Loop : '+csvFileString);
        system.debug('testcsvFileString outSide for Loop : '+testcsvFileString);
        if(!testcsvFileString.equals(csvFileString))
        {

            system.debug('csvFileString outSide for Loop : '+csvFileString);
            csvObj.csv = csvFileString;
            csvObj.conAccMap = juncMap;
            csvObj.contactMap = juncConMap;
            //csvObj.pTnCList = pTnCList;
            system.debug('String csvObj : '+csvObj);
        }else
        {
            csvObj = null;
        }
        return csvObj;
    }
    
    //Method to get all leagal contacts for accounts.
    map<String , Contact> getLegalContact(List<Account> accList )
    {

        List<String> accIds = new List<String>();
        map<String , Contact> conMap = new map<String , Contact>();

        for(Account acc : accList)
        {
            accIds.add(acc.Id);
        }
        List<Contact> conList = [Select id,Name , Account.Id,email ,Phone,title from contact where Legal_Contact__c = true and Account.Id In :accIds];

        for(Contact con : conList)
        {
            conMap.put(con.Account.Id , con);
        }
        
        return conMap;
    }

    public void updateAccountTiers(List<Partner_Terms_and_Condition__c> partnerTnCList)
    {
        List<Account> accUpdateList = new List<account>();
        List<String> accIds = new List<String>();
        Set<String> partIds = new Set<String>();
        if( (partnerTnCList == null) || partnerTnCList.isEmpty() )
        {
            return;
        }
        for(Partner_Terms_and_Condition__c objPart : partnerTnCList)
        {
            accIds.add(objPart.Account__c);
            partIds.add(objPart.Id);
        }
        List<Account> accList = [Select id, name,(select id,Name,Partner_Type__c from Partner_Terms_and_Conditions__r) , Partner_Accountant_TnC__c,Partner_Alliance_TnC__c,Partner_Implementation_TnC__c,Partner_ISV_TnC__c,Partner_Reseller_TnC__c,Bespoke_Partner__c from Account Where id IN : accIds];
        
        Partner_Field__mdt[] partnerFieldsList = [Select MasterLabel ,Partner_TnC_Accepted__c, Partner_Tier__c , Partners__c from Partner_Field__mdt ];
        
        map<String, String> partnerTypeAcc = new map<String, String>();
        
        for(Partner_Field__mdt docuObj : partnerFieldsList)
        {
            partnerTypeAcc.put(docuObj.MasterLabel , docuObj.Partner_TnC_Accepted__c);
        }
        
        for(Account acc: accList)
        {
            for(Partner_Terms_and_Condition__c partRelObj : acc.Partner_Terms_and_Conditions__r)
            {
                if( partIds.contains(partRelObj.Id) )
                {   
                    system.debug('>>>>>'+partRelObj.Partner_Type__c);
                    
                    system.debug('>>>>>'+partnerTypeAcc);
                
                    String partnerType = partRelObj.Partner_Type__c;
                    String str = partnerTypeAcc.get(partnerType);
                    
                    if(str != null)
                    {
                     acc.put(str , true);
                    }
                    
                }

            }//For 3
            accUpdateList.add(acc);
            
        }//For 2
        
        update accUpdateList;

    } 

    // For updated t&c Versions To update junction object for pending and Sent 
    public void updatePartnerJunction (List<Partner_Terms_and_Condition__c> parJuncUpdateList)
    {
        system.debug('updatePartnerJunction : '+parJuncUpdateList);
        if(!parJuncUpdateList.isEmpty())
        {
            update parJuncUpdateList;
            
            integer parsize = parJuncUpdateList.size();
            Integer count = 1;

            Datetime dateT = Datetime.now();

            if(parsize > = 100)
            {
                count = parsize / 100;
                if(math.mod(parsize , 100) != 0)
                    count++;
            }

            for(integer i = 1 ; i <= count ; i++)
            {
                Datetime d = dateT.addMinutes(2);
                String hour = String.valueOf(d.hour());
                String min = String.valueOf(d.minute()); 

                String ss = String.valueOf(d.second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                
                System.schedule('TermsAndConditionsVoid'+i, nextFireTime, new SPPscheduleBulkVoid());
                
            }

            
        }

    }

    
    public accListObject divideAccountsBasedOnPartnerCount(List<Account> accList , Terms_Conditions_Version__c currentTnC)
    {
        List<Account> SingleAccList = new List<Account>();
        List<Partner_Terms_and_Condition__c> parJuncUpdateList = new List<Partner_Terms_and_Condition__c>();
        
        accListObject accObj = new accListObject();
        
        for(Account acc : accList)
        {
            List<Partner_Terms_and_Condition__c> parJuncList = acc.Partner_Terms_and_Conditions__r;
            if(parJuncList != null || !parJuncList.isEmpty())
            {
                
                for(Partner_Terms_and_Condition__c part : parJuncList)
                {
                   if(part.Partner_Type__c == currentTnC.Partner_Type__c)
                   {
                       part.Voided__c = true;
                       SingleAccList.add(acc);
                       parJuncUpdateList.add(part);
                   }
                }
            }
        }
        
        accObj.AllaccList = accList;
        accObj.SingleAccList = SingleAccList;
        accObj.parJuncUpdateList = parJuncUpdateList;
        
        system.debug('123AllaccList '+ accList);
        system.debug('123SingleAccList : '+SingleAccList);
        system.debug('123parJuncUpdateList : '+parJuncUpdateList);
        
        return accObj;
        
    }
    
    public class accListObject 
    {
        List<Account> AllaccList;
        List<Account> SingleAccList;  
        List<Partner_Terms_and_Condition__c> parJuncUpdateList;

    }
    
    public class CsvAndMap 
    {
        public String csv;
        public map<String , Account> conAccMap ;
        public Map<String , Contact> contactMap ;
    }   

    public class BulkResponse 
    {
        public Boolean status;
        public String message;
    }

}