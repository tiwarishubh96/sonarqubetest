public abstract class AccountKIBaseSvc implements IAccountKISvc{

    public static String PASSWORD_TYPE = 'Password';
    public static String CREDIT_TYPE = 'Credit';
    public static String EXPORT_TYPE = 'Export';
    public static String PARTNER_TYPE = 'Partners';
    public static String PROMPT_TYPE = 'Prompts';
    public static String OTHER_TYPE = 'Other';
    public static String COMPLAINT_TYPE = 'Complaints';
    public static String INCIDENT_TYPE = 'Incidents';

    
    public AccountKIBaseSvc() {

    }
    
    abstract List<AccountKeyInfoWrapper> getKeyData(String recordId);

  
}