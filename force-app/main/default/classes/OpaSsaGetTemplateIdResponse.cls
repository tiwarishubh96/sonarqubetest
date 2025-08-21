public class OpaSsaGetTemplateIdResponse
{
    public class Owner 
    {
        public String userName {get;set;} 
        public String userId {get;set;} 
        public String email {get;set;} 
    }
        
    public List<EnvelopeTemplates> envelopeTemplates {get;set;} 
    public String resultSetSize {get;set;} 
    public String startPosition {get;set;} 
    public String endPosition {get;set;} 
    public String totalSetSize {get;set;} 

    public class EnvelopeTemplates 
    {
        public String templateId {get;set;} 
        public String name {get;set;} 
        public String shared {get;set;} 
        public String password {get;set;} 
        public String description {get;set;} 
        public String lastModified {get;set;} 
        public Integer pageCount {get;set;} 
        public String uri {get;set;} 
        public String folderName {get;set;} 
        public String folderId {get;set;} 
        public String folderUri {get;set;} 
        public Owner owner {get;set;} 
        public String emailSubject {get;set;} 
        public String emailBlurb {get;set;} 
        public String signingLocation {get;set;} 
        public String authoritativeCopy {get;set;} 
        public String enforceSignerVisibility {get;set;} 
        public String enableWetSign {get;set;} 
        public String allowMarkup {get;set;} 
        public String allowReassign {get;set;} 
    }

    public static OpaSsaGetTemplateIdResponse parse(String json)
    {
         return (OpaSsaGetTemplateIdResponse) System.JSON.deserialize(json, OpaSsaGetTemplateIdResponse.class);
    }   
    
    public static String parseTemplateId(String json) 
    {
        String templateId = null;
        List<EnvelopeTemplates> ets = parse(json).envelopeTemplates;
        for(EnvelopeTemplates et : ets)
        {
            templateId = et.templateId;
            break;
        }
        return templateId;
    }        
            
}