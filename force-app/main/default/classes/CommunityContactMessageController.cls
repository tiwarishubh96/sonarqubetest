public class CommunityContactMessageController {
    public String lang{get;set;}
    public CommunityContactMessageController(ApexPages.StandardController controller) {
        lang=UserInfo.getLanguage();
    }
}