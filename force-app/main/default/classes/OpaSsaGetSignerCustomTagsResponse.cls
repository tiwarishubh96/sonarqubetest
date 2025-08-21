public class OpaSsaGetSignerCustomTagsResponse
{
    public List<TextTabs> textTabs {get;set;} 
   
    public class TextTabs 
    {
        public Integer height {get;set;} 
        public String validationPattern {get;set;} 
        public String validationMessage {get;set;} 
        public String shared {get;set;} 
        public String requireInitialOnSharedChange {get;set;} 
        public String requireAll {get;set;} 
        public String value {get;set;} 
        public String originalValue {get;set;} 
        public Integer width {get;set;} 
        public String required {get;set;} 
        public String locked {get;set;} 
        public String concealValueOnDocument {get;set;} 
        public String disableAutoSize {get;set;} 
        public Integer maxLength {get;set;} 
        public String tabLabel {get;set;} 
        public String font {get;set;} 
        public String bold {get;set;} 
        public String italic {get;set;} 
        public String underline {get;set;} 
        public String fontColor {get;set;} 
        public String fontSize {get;set;} 
        public String documentId {get;set;} 
        public String recipientId {get;set;} 
        public String pageNumber {get;set;} 
        public String xPosition {get;set;} 
        public String yPosition {get;set;} 
        public String tabId {get;set;} 
        public String templateLocked {get;set;} 
        public String templateRequired {get;set;} 
    }
        
    public static OpaSsaGetSignerCustomTagsResponse parse(String json) 
    {
        return (OpaSsaGetSignerCustomTagsResponse) System.JSON.deserialize(json, OpaSsaGetSignerCustomTagsResponse.class);
    }
    
    public static List<TextTabs> parseSignerTextTabs(String json)
    {
        List<TextTabs> textTabs = parse(json).TextTabs;
        return textTabs;
    } 
    
    public static Map<String, String> parseSigner1CustomTags(String json) 
    {
        Map<String, String> signerTagsMap = new Map<String, String>();
        List<TextTabs> textTabs = parse(json).TextTabs;
        for(TextTabs tt: textTabs)
        {
          if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[0] )                 
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[0] , tt.value );   
          }   
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[1] )    
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[1], tt.value );
          }      
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[2] )   
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[2] , tt.value );
          }   
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[3] )   
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[3], tt.value );
          }
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[4] )    
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[4], tt.value );
          }  
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[5] )    
          {
            signerTagsMap.put( OpaSsaStaticVariables.firstSignerTags[5], tt.value );
          }        
          else if ( tt.tabLabel == OpaSsaStaticVariables.firstSignerTags[6] )    
          {
            signerTagsMap.put(OpaSsaStaticVariables.firstSignerTags[6], tt.value );
          }                    
        }
        return signerTagsMap;
    }  
    
    
    public static Map<String, String> parseSigner2CustomTags(String json) 
    {
        Map<String, String> signerTagsMap = new Map<String, String>();
        List<TextTabs> textTabs = parse(json).TextTabs;
        for(TextTabs tt: textTabs)
        {
          if ( tt.tabLabel == OpaSsaStaticVariables.secondSignerTags[0])    
          {
            signerTagsMap.put( OpaSsaStaticVariables.secondSignerTags[0], tt.value );
          } 
          else if ( tt.tabLabel == OpaSsaStaticVariables.secondSignerTags[1])    
          {
            signerTagsMap.put( OpaSsaStaticVariables.secondSignerTags[1], tt.value );
          }         
        }
        return signerTagsMap;
    } 

}