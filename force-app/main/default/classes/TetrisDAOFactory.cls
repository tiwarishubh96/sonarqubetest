global class TetrisDAOFactory {

    global static ITetrisCustomMetadataTypeDAO getCustomMetadataTypeDAO(){
        if (new TetrisOrganizationDAO().isRunningInSandbox()) {
            return new TetrisCustomMetadataTypeDAO_DEV();
        } else {
            return new TetrisCustomMetadataTypeDAO_PROD();
        }
    }
    
}