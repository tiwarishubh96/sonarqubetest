@isTest
public class CommunityAccountMessageControllerTest {
    static testmethod void test() {
        CommunityAccountMessageController camcObj = new CommunityAccountMessageController(new ApexPages.StandardController(new Account()));
    }
}