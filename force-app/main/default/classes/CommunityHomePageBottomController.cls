public class CommunityHomePageBottomController {
    public String lang{get;set;}
    public String userId{get;set;}
    public CommunityHomePageBottomController() {
        lang=UserInfo.getLanguage();
        userId=UserInfo.getUserId();
    }
}