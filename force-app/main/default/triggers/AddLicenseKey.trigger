trigger AddLicenseKey on Bulk_License__c (before insert, before update) {
for (Bulk_License__c f : trigger.new){
  if (f.License_Key__c == null)
        f.License_Key__c = GuidUtil.NewGuid();
}
}