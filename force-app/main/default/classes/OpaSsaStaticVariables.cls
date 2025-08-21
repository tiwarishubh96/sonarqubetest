public with sharing class OpaSsaStaticVariables 
{
    // START Auth Callout Class Variables       
    // public static Integer requestTimeout = 59900; //59.9 seconds in milliseconds
    public static String docuSignApiPath= 'restapi/v2/accounts/';
    public static String contentType = 'application/json'; 
    public static String sageBusinessCloud  = 'Sage Business Cloud';
    public static String emailSubject = 'Subscription Services Agreement';
    public static String voided = 'voided';
    public static String voidReason = 'Sending a new Subscription Services Agreement';
    
    public static Map<String, String> httpMethods = new Map<String, String> 
    {
        'Read'    => 'GET', 
        'Create'  => 'POST', 
        'Update'  => 'PUT'
    };     
    // END Callout Class Variables
    
    //START Opa-DocuSign Variables     
    public static String messageSendSsaInProgress = 'SSA button is clicked and DocuSign is processing the SSA request.';
    public static String messageWaitingForCustomerSignature = 'SSA was sent successfully, but not yet opened.';
    public static String messageDelivered = 'SSA was opened but not yet signed.';
    public static String messageVoided = 'SSA was voided.';
    public static String messageSignedByCustomer = 'SSA was signed and completed by the recipient.';
    

    public static String messageDeliveryFailure = 'Possible reasons: invalid email, bounce message received or mailbox is full.';
    public static String messageDeclined = 'SSA was declined.';
    public static String messageCompletedAndSent = 'SSA was signed by the first recipient. SSA was sent successfully, but not yet opened by second recipient.';
    public static String messageCompletedAndDelivered = 'SSA was signed by the first recipient. SSA was sent successfully, but not yet signed by second recipient.';
    public static String messageCompletedAndCreated = 'SSA was signed by the first recipient.';
    public static String messageCompletedAndCompleted = 'SSA was signed and completed by both recipients.';
    public static String messageAlreadyBeenSigned = 'SSA had already signed and completed by the recipient.';    
    public static String messageResent = 'SSA was resent.';  
    public static String messageSendSsaError = 'An error occured to send SSA. Please contact your System admin.';
    public static String messageSsaTemplateSetupError = 'SSA template is not setup properly. Please contact your System admin.';
    
    public static Map<String, String> dsStatusToSsaStatus = new Map<String, String> 
    {
        'Sent'           => 'SSA Sent', 
        'AutoResponded'  => 'Email Auto Response (first recipient)', 
        'Delivered'      => 'SSA Opened',
        'Completed'      => 'SSA Signed',
        'Voided'         => 'SSA Voided',
        'Declined'       => 'SSA Declined',
        'Declined,Created' => 'SSA Declined',
        'Sent,Created'     => 'SSA Sent',    
        'AutoResponded,Created'   => 'Email Auto Response (first recipient)',
        'Delivered,Created'       => 'SSA Opened',        
        'Completed,Created'       => 'SSA Partial',
        'Completed,Sent'          => 'SSA Partial',
        'Completed,AutoResponded' => 'SSA Partial. Email Auto Response (second recipient)',
        'Completed,Delivered'     => 'SSA Partial',
        'Completed,Completed'     => 'SSA Signed',
        'Completed,Voided'        => 'SSA Voided',
        'Completed,Declined'      => 'SSA Declined'         
    }; 
    
    public static Map<String, String> dsStatusToMessages = new Map<String, String> 
    {
        'Sent'          => messageWaitingForCustomerSignature, 
        'AutoResponded' => messageDeliveryFailure, 
        'Delivered'     => messageDelivered,                   
        'Completed'     => messageSignedByCustomer,            
        'Voided'        => messageVoided,
        'Declined'      => messageDeclined,
        'Declined,Created' => messageDeclined,
        'Sent,Created'            => messageWaitingForCustomerSignature, 
        'AutoResponded,Created'   => messageDeliveryFailure,
        'Delivered,Created'       => messageDelivered,        
        'Completed,Created'       => messageCompletedAndCreated,
        'Completed,Sent'          => messageCompletedAndSent,
        'Completed,AutoResponded' => messageDeliveryFailure,
        'Completed,Delivered'     => messageCompletedAndDelivered,
        'Completed,Completed'     => messageCompletedAndCompleted,   
        'Completed,Voided'        => messageVoided,
        'Completed,Declined'      => messageDeclined
    };     
    
    public static Set<string> recipientStatuses = new Set<String>{'Create',
                                                                  'Sent',
                                                                  'Delivered',
                                                                  'Signed',
                                                                  'Declined',
                                                                  'Completed',
                                                                  'FaxPending', 
                                                                  'AutoResponded'};  
    
    public static List<string> firstSignerTags = new List<String>{ 'SignerName',
                                                                   'SignerTitle',
                                                                   'CompanySigningSSA',
                                                                   'RegistrationNumber',
                                                                   'AddressLine1',
                                                                   'AddressLine2',
                                                                   'AddressLine3'};
                                                                  
    public static List<string> secondSignerTags = new List<String>{ 'SecondSigner',
                                                                    'SecondSignerTitle' }; 
                                                                  
    public enum SignerInfo { FIRST_SIGNER, SECOND_SIGNER }
    public static String OpaDocuSignIntegratorKey = '50b6ec22-6696-436e-859c-7a93868a27b7';
    //END Opa-DocuSign Variables    
    
}