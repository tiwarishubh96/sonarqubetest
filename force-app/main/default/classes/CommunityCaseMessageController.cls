public class CommunityCaseMessageController {
    public String lang{get;set;}
    public CommunityCaseMessageController() {
        lang=UserInfo.getLanguage();
    }
}