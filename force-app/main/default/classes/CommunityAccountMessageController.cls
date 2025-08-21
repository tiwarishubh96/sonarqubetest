public class CommunityAccountMessageController {
    public String lang{get;set;}
    public CommunityAccountMessageController(ApexPages.StandardController controller) {
        lang=UserInfo.getLanguage();
    }
}