public class CommunitySuccessPlanMessageController {
    public String lang{get;set;}
    public CommunitySuccessPlanMessageController() {
        lang=UserInfo.getLanguage();
    }
}