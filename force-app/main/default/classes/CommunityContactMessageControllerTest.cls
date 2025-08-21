@isTest
public class CommunityContactMessageControllerTest {
    static testmethod void test() {
        CommunityContactMessageController camcObj = new CommunityContactMessageController(new ApexPages.StandardController(new Contact()));
    }
}