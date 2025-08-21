@isTest
public class CommunityEmailLandingControllerTest {
    @isTest
    static void test1() {
        CommunityEmailLandingController celc = new CommunityEmailLandingController();
        celc.language='en_US';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'en_US');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test2() {
        CommunityEmailLandingController celc = new CommunityEmailLandingController();
        celc.language='fr_CA';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'fr_CA');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test3() {
        CommunityEmailLandingController celc = new CommunityEmailLandingController();
        celc.language='fr_US';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'fr_US');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test4() {
        CommunityEmailLandingController celc = new CommunityEmailLandingController();
        celc.language=null;
        celc.nameOfUser='Charles';
        celc.getEmailbody();
    }
}