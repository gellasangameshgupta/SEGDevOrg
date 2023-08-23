/**
* @description Wrapper class to hold json response of Companies Jagger API
* @createdDate Dec 1, 2021
*/
public class CLM_CompaniesWrapper {

	public List<Items> items { get; set;}

	public class Items {
		public String id { get; set;}
		public Boolean isMember { get; set;}
		public String name { get; set;}
		public String city { get; set;}
		public String country { get; set;}
		public String partnerNumber { get; set;}
	}

	/**
    * @description Parses json string into CLM_CompaniesWrapper class to be used for creating Account records
    * @createdDate Dec 1, 2021
    * @param offset
    * @return CLM_CompaniesWrapper
    */
	public static CLM_CompaniesWrapper parse(String json) {
		return (CLM_CompaniesWrapper) System.JSON.deserialize(json, CLM_CompaniesWrapper.class);
	}

	/**
    * @description Forms Account objects using the Items class
    * @createdDate Dec 8, 2021
    * @return List<Account>
    */
	public CLM_AccountListToInsertOrUpdate getAccounts(){
        List<Account> accountList = new List<Account>();
		/* Avoid duplicate external ids in single transaction */
		Set<String> externalIds = new Set<String>();
		/* Considering only Supplier Account Record Type */
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
        /* Discard missing partner numbers, assume duplicates are removed, inconsistent partner numbering is fine */
		for(Items item : this.items){
			if(!String.isBlank(item.partnerNumber) && !externalIds.contains(item.partnerNumber.trim())){
				Account accObj = new Account(
					RecordTypeId = recordTypeId,
					External_Id__c = item.partnerNumber.trim(),
					Name = item.name,
					IFv2_Country__c = item.country,
					BillingCity = item.city,
					BillingCountry = item.country,
					IFv2_SupplierClassification__c = 'General',
                    CLM_JAGGAER_Id__c = item.id
				);
				accountList.add(accObj);
				externalIds.add(item.partnerNumber.trim());
			}
        }
		CLM_AccountListToInsertOrUpdate accountListWrapper = new CLM_AccountListToInsertOrUpdate(accountList, externalIds);
        return accountListWrapper;
    }

}