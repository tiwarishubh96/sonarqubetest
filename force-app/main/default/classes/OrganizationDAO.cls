public with sharing class OrganizationDAO implements IOrganizationDAO{ 
	public interface IOrganizationDAO{
		Boolean isRunningInSandbox();
		Id getCurrentOrganizationId();
	}

	public Boolean isRunningInSandbox(){
		return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

	public Id getCurrentOrganizationId(){
		return UserInfo.getOrganizationId();
	}
}