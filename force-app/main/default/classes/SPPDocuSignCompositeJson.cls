/*********************************************************************
Name    : SPPDocuSignCompositeJson
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This class is used to generate DocuSign Composit envelops json and Other operations related Rest.
History : Raja Patnaik,10/19/2017 ,SPP - 726 AS A DocuSign Admin I WANT to set-up on each template the Sage Legal counter-signer 
SO THAT the agreements are sent to the right person to sign on Sage side - Stop sending PAM Details aka Sage Signer to Docusign
**********************************************************************/

public class SPPDocuSignCompositeJson {
    
    
    public String emailSubject;
    public String emailBlurb;
    public String status;
    public List<CompositeTemplates> compositeTemplates;
    
    
    public class InlineTemplates {
        public Integer sequence;
        public Recipients recipients;
    }
    
    public class Recipients {
        public List<signer> signers;
    }
    
    public class ServerTemplates {
        public Integer sequence;
        public String templateId;
    }
    
    public class signer {
        public String email;
        public String name;
        public Integer recipientId;
        public String roleName;
        public Tabs tabs;
    }
    
    public class Tabs {
        public List<TextTabs> textTabs;
    }
    
    public class TextTabs {
        public String tabLabel;
        public String value;
    }
    
    public class CompositeTemplates {
        public List<ServerTemplates> serverTemplates;
        public List<InlineTemplates> inlineTemplates;
    }
    public static SPPDocuSignCompositeJson parse(String json) {
        return (SPPDocuSignCompositeJson) System.JSON.deserialize(json, SPPDocuSignCompositeJson.class);
    }

    public class RestAPIServices {

        TextTabs getTextTabsObj( String tabLabel , String value)
        {
            TextTabs tx = new TextTabs();
            tx.tabLabel = tabLabel;
            tx.value = value;

            return tx;

        }

        Tabs getTabsObj (List<TextTabs> tabs)
        {

            Tabs t = new Tabs();
            t.textTabs = tabs;

            return t;

        }
        signer getSignerObj(String email , String name , Integer recipientId , String roleName , Tabs tabs)
        {
            signer s = new signer();
            s.email = email;
            s.name = name;
            s.recipientId = recipientId;
            s.roleName = roleName;
            s.tabs = tabs;

            return s;
        }

        ServerTemplates getServerTemplates(Integer sequence, String templateId)
        {
            ServerTemplates ser = new ServerTemplates();

            ser.sequence = sequence;
            ser.templateId = templateId;

            return ser;
        }

        Recipients getArrayOfSigners(List<signer> signers)
        {
            Recipients rec = new Recipients();
            rec.signers = signers;
            return rec;
        }

        InlineTemplates getInlineTemplates(Integer sequence, Recipients recipients)
        {
            InlineTemplates inline = new InlineTemplates();

            inline.sequence = sequence;
            inline.recipients = recipients;

            return inline;
        }

        CompositeTemplates getCompositeTemplates(List<ServerTemplates> serverTemplates, List<InlineTemplates> inlineTemplates)
        {
            CompositeTemplates comp = new CompositeTemplates();
            comp.serverTemplates = serverTemplates;
            comp.inlineTemplates = inlineTemplates;

            return comp;
        }
        

        Tabs mergeDataWithCustomTags(map<String , String> customFieldValue)
        {

            List<TextTabs> textTabs = new List<TextTabs>();

            for(String str: customFieldValue.keySet())
            {

                textTabs.add( getTextTabsObj( str, customFieldValue.get(str) ) );

            }

            return getTabsObj( textTabs );
        }

        public List<CompositeTemplates> builCompositTemplate(List<Contact> conList ,map<Integer , String> tempOrderMap  , Account acc, String mapTemp)
        {
            List<CompositeTemplates> comTempList = new List<CompositeTemplates>();
            Integer seqId = 1;
            
            String SPPSigner = System.Label.DocuSign_SPP_Signer;
            String SageSigner = System.Label.DocuSign_Sage_Signer;

            
            System.debug('tempOrderMap builCompositTemplate: '+ tempOrderMap);
            Set<Integer> keySetOrderSet = tempOrderMap.keySet();
            List<Integer> keySetOrderList = new List<Integer>();
            keySetOrderList.addAll(keySetOrderSet);
            keySetOrderList.sort();
            for(Integer i : keySetOrderList)
            {
                String tempId = tempOrderMap.get(i);
                if(tempId != null && tempId != '')
                {
                    map<String , String > accountProductMap = SPPDocuSignUtils.getProductList(new List<Account>{acc});
                    map<String , String > mapCust = getCustomTagsMap(acc , mapTemp,accountProductMap.get(acc.Id));
                    mapCust.put('SPPTitle', conList[0].title);
                    //mapCust.put('SageTitle', acc.owner.title);
                    Tabs tabs = mergeDataWithCustomTags(mapCust);

                    List<signer> sinList = new List<signer>();
                    
                    //sinList.add( getSignerObj(acc.Owner.Email , acc.Owner.Name , 1 , SageSigner , tabs) );
                    sinList.add( getSignerObj(conList[0].email , conList[0].name , 1 , SPPSigner , tabs) );
                    Recipients recObj = getArrayOfSigners( sinList );

                
                    List<InlineTemplates> inlineList = new List<InlineTemplates>();
                    inlineList.add( getInlineTemplates(seqId, recObj) );

                    List<ServerTemplates> serList = new List<ServerTemplates>();
                    ServerTemplates serObj =  getServerTemplates(seqId, tempId);
                    serList.add(serObj);
                    comTempList.add( getCompositeTemplates(serList , inlineList) );
                    seqId++;
                }
            }
            system.debug('comTempList :: '+comTempList);
            return comTempList;

        }

        public map<String , String > getCustomTagsMap(Account acc , String partnerType,String productList) 
        {
            //System.debug('Account :: '+ acc);
            //System.debug('partnerType : '+partnerType);
            map<String , String > m = new map<String , String >();
            DocuSign_Field__mdt[] docuSignField = [SELECT DocuSign_Custom_Label__c, SF_Partner_Label__c,Object_Name__c , SF_API_Field_Name__c FROM DocuSign_Field__mdt where Object_Name__c = 'Account'];
            
            m.put('SageProducts' , productList);

            for(DocuSign_Field__mdt docuObj : docuSignField )
            {
                String docuLabel = docuObj.DocuSign_Custom_Label__c;
                String accValue = '';
                String sfFieldName = docuObj.SF_API_Field_Name__c;
                String sfPartnerLabel = docuObj.SF_Partner_Label__c ;
                
                if(docuLabel == 'PartnerTier'  )
                {
                     if( sfPartnerLabel.contains(partnerType) )
                     {
                        accValue = (String)acc.get(sfFieldName);
                        if(accValue == null)
                            accValue = '';
                        m.put( docuLabel, accValue );
                     }
                        
                }else if(docuLabel == 'PartnerType' )
                {
                    if( sfPartnerLabel.contains(partnerType))
                    {
                        accValue = partnerType;
                        m.put( docuLabel, accValue );
                    }
                }
                else
                {
                    Object accValueObj = acc.get(sfFieldName);
                    if(accValueObj instanceof  Address)
                    {
                        Address addr = (Address)accValueObj;
                        if(addr.getStreet() != null)
                                accValue += addr.getStreet() +' ';
                        if(addr.getCity() != null)
                            accValue += addr.getCity() +' ';
                        if(addr.getState() != null)
                            accValue += addr.getState() +' ';
                        if(addr.getCountry() != null)
                            accValue += addr.getCountry() +' ';
                        if(addr.getPostalCode() != null)
                            accValue += addr.getPostalCode() ;
                        accValue = accValue.replace('\n','');
                        accValue = accValue.replace(',','');
                        //System.debug('accValue : '+accValue);
                    }else if(accValueObj instanceof String)
                    {
                        accValue = (String) accValueObj;

                    }else if(accValueObj instanceof Boolean)
                    {
                        accValue = '\'' + String.valueOf(accValueObj) + '\'';
                        
                    }else{

                    }
                    //System.debug('docuLabel : '+docuLabel);
                    //System.debug('accValue : '+accValue);
                    System.debug('-------------------------');
                    m.put( docuLabel, accValue );
                }

            }

            return m;
        }

     

    }
}