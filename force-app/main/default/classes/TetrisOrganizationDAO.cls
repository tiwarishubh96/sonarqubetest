global class TetrisOrganizationDAO implements ITetrisOrganizationDAO{ 
	
	global Boolean isRunningInSandbox(){
		return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

	global Id getCurrentOrganizationId(){
		return UserInfo.getOrganizationId();
	}
}