public class PartnerTypeTier {
	@AuraEnabled
   	public String partnerTypeName;
    @AuraEnabled
   	public list<PartnerTier> partnerTierList;
    
    public class PartnerTier{
        @AuraEnabled
   		public String partnerTierName;
        @AuraEnabled
   		public boolean isSelected;
    }
}