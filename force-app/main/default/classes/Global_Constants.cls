/**
 * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
 * @date 01-Aug-2018
 *
 * class to hold all the hard-coded strings that needs to be used in code
 *
 */
public without sharing class Global_Constants {

    //Lead Statuses
    public static final string LEAD_STATUS_ARCHIVED = 'Archived';
    public static final string LEAD_STATUS_QUALIFIED = 'Qualified';
    public static final string LEAD_STATUS_WORKING = 'Working';
    public static final string LEAD_STATUS_NEW = 'New';
    public static final string LEAD_STATUS_OPEN = 'Open';

    //Lead Playbook Statuses
    public static final string LEAD_PLAYSTATUS_INFLIGHT = 'In-Flight';
    public static final string LEAD_PLAYSTATUS_FAILURE = 'Failure';

    //Lead Status Reason
    public static final string LEAD_STATUREASON_NORESPONSE = 'No Response';

    //Lead Funnel Stages
    public static final string LEAD_FUNNEL_MQL = 'MQL';
    public static final string LEAD_FUNNEL_SQO = 'SQO';
    public static final string LEAD_FUNNEL_SAL = 'SAL';
    public static final string LEAD_FUNNEL_SUSPECT = 'Suspect';
    public static final string LEAD_FUNNEL_INQUIRY = 'Inquiry';

    //Lead Scores
    public static final Set<String> LEAD_MQL_SCORES = new Set<String>{
            'A1', 'A2', 'A3', 'B1', 'B2', 'C1'
    };
    public static final Set<String> LEAD_SUSPECT_SCORES = new Set<String>{
            'A4', 'B4', 'C4', 'D4'
    };
    public static final Set<String> LEAD_INQUIRY_SCORES = new Set<String>{
            'B3', 'C2', 'C3', 'D1', 'D2', 'D3'
    };

    //Lead Products
    public static final string LEAD_PRODUCT_SAGELIVE = 'Sage Live';
    public static final string LEAD_PRODUCT_SAGEONE = 'Sage One';
    public static final string LEAD_PRODUCT_FINANCIALS = 'Financials';
    public static final string LEAD_PRODUCT_ACCOUNTING = 'Accounting';
    public static final string LEAD_PRODUCT_NPLS = 'Non Product Line Specific';
    public static final string LEAD_PRODUCT_INTACCT = 'Intacct';

    //Lead status reasons
    public static final string LEAD_STATUSREASON_TRANSFER = 'Transfer';

    //Intacct Lead Transfer Status
    public static final string LEAD_TRANSSTATUS_TOBESENT = 'To be sent';

    //User Types
    public static final string USER_USERTYPE_POWERPARTNER = 'PowerPartner';
    
    
    //Adding constants for LockOpportunityTriggerHelper class
    
    public static final string OPP_IR_STATUS_PSTLS = 'Pending - Send to Local (Self)';
    public static final string OPP_IR_STATUS_PSTLRR = 'Pending - Send to Local (Round-Robin)';
    public static final string OPP_IR_STATUS_ETL = 'Extracted to Local';
    public static final string OPP_IR_STATUS_UFL = 'Updated from Local';
    public static final string OPP_IR_STATUS_CAOC = 'Closed – Auto Opportunity Created';
    public static final string OPP_IR_STATUS_LOL = 'Loaded to Local';
    
    //1084 Updated Opp Stages
    public static final string OPP_STAGE_CW = 'Closed Won';
    public static final string OPP_STAGE_CL = 'Closed Lost';
    public static final string OPP_STAGE_Q = 'Qualify';
    
    //Adding constants for LockOpportunityTriggerHelper class
    //
    // Constants for Contact Trigger
    public static final String USER_ELOQUA_FIRST_NAME = 'Eloqua';
    public static final String USER_ELOQUA_LAST_NAME = 'Integration';
    
    
    //External Apps Identification Constants
     public static final String TETRIS = 'Tetris';
     public static final String TETRIS_USER_ID = '00524000006v87i';
     public static final String TETRIS_SALES_CHANNEL_DIRECT = 'Direct';
     public static final String TETRIS_SALES_CHANNEL_DIGITAL = 'Digital';
    
    
    //Payment Methods
    public static final String DIRECT_DEBIT = 'Bank Transfer';
    public static final String CREDIT_CARD = 'Credit Card';

    // Event Statuses
    public static final string EVENT_STATUS_COMPLETED = 'Completed';
    
    // Task Statuses
    public static final string TASK_STATUS_COMPLETED = 'Completed';


    //Required for Mapping for the new Trading Model (TradingEntity)
    //Sales office (salesforce) 
    public static final string SALES_OFFICE_DUBLIN_CBC = 'Dublin CBC';
    public static final string SALES_OFFICE_ATLANTA_CBC = 'Atlanta CBC';
    public static final string SALES_OFFICE_US_SSI_INC = 'US SSI INC';
    public static final string SALES_OFFICE_CANADA_CBC = 'Canada CBC';

    //Required for Mapping for the new Trading Model (TradingEntity)
    //Trading Entity (Zuora)
    public static final string TRADING_ENTITY_SGS_LTD = 'SGS LTD';
    public static final string TRADING_ENTITY_SGS_Inc = 'SGS Inc';
    public static final string TRADING_ENTITY_SSI_Inc = 'SSI Inc';
    public static final string TRADING_ENTITY_SSC_LTD = 'SSC LTD';

}