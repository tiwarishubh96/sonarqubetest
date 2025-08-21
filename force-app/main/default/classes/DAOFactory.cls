public class DAOFactory {
	
    public static ICustomMetadataTypeDAO getCustomMetadataTypeDAO(){
        if (new OrganizationDAO().isRunningInSandbox()) {
            return new CustomMetadataTypeDAO_DEV();
        } else {
            return new CustomMetadataTypeDAO_PROD();
        }
    }
}