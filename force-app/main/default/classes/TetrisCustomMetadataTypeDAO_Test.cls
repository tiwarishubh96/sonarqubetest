@isTest(SeeAllData=false) 
private class TetrisCustomMetadataTypeDAO_Test {
    private static final String DEVELOPER_NAME = 'DEV_Mule_Tetris_Info360_Addr_Val';

    static testMethod void testGetResourceInfo() {
        Callout_Configuration__mdt callOutObject = TetrisCustomMetadataTypeDAO.getResourceInfo(DEVELOPER_NAME);
        
    }
}