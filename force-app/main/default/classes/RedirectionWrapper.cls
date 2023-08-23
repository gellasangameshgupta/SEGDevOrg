public class RedirectionWrapper {
	@AuraEnabled
	public Account accountDetails{get;set;}
	@AuraEnabled
	public String siteUrl;
	@AuraEnabled
	public String recordTypeName;
	
	public RedirectionWrapper(Account pAccountDetails, String pSiteUrl, String pRecordTypeName){
		accountDetails = pAccountDetails;
	    siteUrl = pSiteUrl;
	    recordTypeName = pRecordTypeName;
	}
}