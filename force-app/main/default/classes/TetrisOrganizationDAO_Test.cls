@isTest 
private class TetrisOrganizationDAO_Test {

    static testMethod void testIsRunningInSandbox() {
        TetrisOrganizationDAO tODAOObj = new TetrisOrganizationDAO();
        Boolean isSandbox = tODAOObj.isRunningInSandbox();
    }
    
    static testMethod void testGetCurrentOrganizationId() {
        TetrisOrganizationDAO tODAOObj = new TetrisOrganizationDAO();
        Id currentOrgId = tODAOObj.getCurrentOrganizationId();
    }
}