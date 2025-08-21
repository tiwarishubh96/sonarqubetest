public with sharing class FlowUtilitiesGenerateGuid {

	@InvocableMethod(label='Generate Guid' description='Generate a GUID')
	public static List<string> generateGuid () {
		List<string> results = new List<string>();
		results.add(GenericUtilities.getRandomUUIDv4());
		return results;
	}
}