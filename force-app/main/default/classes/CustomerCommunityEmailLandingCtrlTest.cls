@isTest
public class CustomerCommunityEmailLandingCtrlTest {
    @isTest
    static void test1() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language='en';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'en');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test2() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language='fr';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'fr');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test3() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language='es';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'es');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test5() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language='de';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'de');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test6() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language='it';
        celc.nameOfUser='Charles';
        celc.getEmailbody();
        System.assertEquals(celc.language, 'it');
        System.assertEquals(celc.nameOfUser, 'Charles');
    }
    
    @isTest
    static void test4() {
        CustomerCommunityEmailLandingController celc = new CustomerCommunityEmailLandingController();
        celc.language=null;
        celc.nameOfUser='Charles';
        celc.getEmailbody();
    }
}