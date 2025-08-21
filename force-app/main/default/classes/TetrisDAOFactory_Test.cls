@isTest(SeeAllData=false) 
private class TetrisDAOFactory_Test {

    static testMethod void testGetCustomMetadataTypeDAO() {
        ITetrisCustomMetadataTypeDAO iTetrisObject = TetrisDAOFactory.getCustomMetadataTypeDAO();
    }
}