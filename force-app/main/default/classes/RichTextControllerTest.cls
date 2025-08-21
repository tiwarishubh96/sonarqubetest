@isTest
private class RichTextControllerTest {

    @isTest
    static void saveSettingsTest() {
        
        RichTextController.saveRichTextSettings('', 'RichText Component', 'Rich Text Component', 'Sage:Test', '');
    }
    
     @isTest(SeeAllData=true)
    static void getCountriesListTest() {
        String config = 'Sage Customer Community';
        RichTextController.getCountriesList(config);
    }
    
    @isTest
    static void getComponentConfigTest() {
        RichTextController.getComponentConfig('RichText', 'Rich Text Component', 'Sage:admin');
    }
    
    
    
}