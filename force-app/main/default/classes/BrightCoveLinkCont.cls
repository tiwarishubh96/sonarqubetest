public class BrightCoveLinkCont{

    public String iFrameLink {get; set;}
    public String finaliFrameLink {get; set;}
    
    public static final String ERROR_MSG = 'INVALID IFRAME LINK. PLEASE VALIDATE';

    public BrightCoveLinkCont(){
        iFrameLink = '';
        finaliFrameLink  = '';
        
    }
    
    public void Save(){
        
        try{
            if(String.isNotBlank(iFrameLink)){
                finaliFrameLink = '';
                String accountId = iFrameLink.substringBetween('.net/', '/');
                String videoId = iFrameLink.substringBetween('videoId=' , '"');
                if(String.isBlank(videoId)){
                    videoId = iFrameLink.substringBetween('videoId=', '\'');
                }
    
                String link =  URL.getSalesforceBaseUrl().toExternalForm();
                String srcLink = iFrameLink.substringBetween('src="', '"');
                if(String.isBlank(srcLink)){
                    srcLink = iFrameLink.substringBetween('src=\'', '\'');
                }
                
                String dummfinaliFrameLink = link + '/apex/BrightCoveEmbed?accountId=' + accountId +'&videoId=' + videoId;
                
                finaliFrameLink = iFrameLink.replace(srcLink, dummfinaliFrameLink );                         
            }
        }catch(Exception e){
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR, ERROR_MSG );
            ApexPages.addMessage(myMsg); 
        }
        
        
    }
}