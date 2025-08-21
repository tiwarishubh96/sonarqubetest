/**
 * @author cjbradshaw
 * @date June 2019
 * Dummy service for the AccountKeyInfo LEX component
 * Can be used in the Key Info custom metadata to serve dummy data instead of having to rely on Ext objects.
 */

public with sharing class AccountKIDummySvcImpl extends AccountKIBaseSvc{

    public List<AccountKeyInfoWrapper> getKeyData(String recordId) {
        List<AccountKeyInfoWrapper> results = new List<AccountKeyInfoWrapper>();
        getPassword(results);
        getComplaints(results);
        getCredit(results);
        getExport(results);
        getPartner(results);
        getPrompts(results);
        getIndicents(results);
        getComplaints(results);
        return results;
    }



    private void getPassword( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(PASSWORD_TYPE,new String[]{'FITZG3RalD'},1);
        results.add(wrap1);
    }

    private void getPartner( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(PARTNER_TYPE,new String[]{'039094094'},1);
        results.add(wrap1);
    }    
    
    private void getCredit( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(CREDIT_TYPE,new String[]{'Good'},1);
        results.add(wrap1);
    }    
    private void getExport( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(EXPORT_TYPE,new String[]{'true'},1);
        results.add(wrap1);
    }        

    private void getComplaints( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(COMPLAINT_TYPE,new String[]{'I bet all my monet and don\'t have a receipt'},2);
        AccountKeyInfoWrapper wrap2 = new AccountKeyInfoWrapper(COMPLAINT_TYPE,new String[]{'My invoices are wrong'},2);
        results.add(wrap1);
        results.add(wrap2);
    }    

    private void getPrompts( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(PROMPT_TYPE,new String[]{'Be aware Custoner is talking about leaveing Sage'},2);
        results.add(wrap1);        
    }
    private void getIndicents( List<AccountKeyInfoWrapper> results){
        AccountKeyInfoWrapper wrap1 = new AccountKeyInfoWrapper(INCIDENT_TYPE,new String[]{'Customer locked out of product for a week'},2);
        results.add(wrap1);           
    }    

    
}