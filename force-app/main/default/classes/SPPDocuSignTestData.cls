@isTest
public  class SPPDocuSignTestData {
    
     public static void CreateDocuSignStatus()
    {
        dsfs__DocuSign_Status__c doc = new dsfs__DocuSign_Status__c(dsfs__DocuSign_Envelope_ID__c='TestId');
        insert doc;
        
    }
    public static void CreatePartnerTandCond(Account acc, Terms_Conditions_Version__c tnv,dsfs__DocuSign_Status__c doc,Contact con)
    {
        
        Partner_Terms_and_Condition__c part = new Partner_Terms_and_Condition__c(Account__c= acc.id,DocuSign_Status_Object__c=doc.id, Terms_Conditions_Version__c= tnv.id , Contact__c =con.id);
        
        insert part;
    }
    
}