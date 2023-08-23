/**
* @description Utility class to separate the Accounts which needs to be Updated vs Inserted
* @createdDate Jan 28, 2022
*/
public with sharing class CLM_AccountListToInsertOrUpdate {
    List<Account> accountsToInsert = new List<Account>();
    List<Account> accountsToUpdate = new List<Account>();

    /**
    * @description Divides the accounts for update and insert operation based on existing external id value
    * @createdDate Jan 28, 2022
    * @param accountList, externalIds
    */
    public CLM_AccountListToInsertOrUpdate(List<Account> accountList, Set<String> externalIds) {
        List<Account> accountsWithExternalId = [SELECT Id, Name, External_Id__c FROM Account WHERE External_Id__c IN:externalIds FOR UPDATE];
        if(accountsWithExternalId != null && !accountsWithExternalId.isEmpty()){
            for(Account accObj : accountList){
                Boolean present = false;
                for(Account accObjWithExternalId : accountsWithExternalId){
                    Boolean externalIdCheck = !String.isBlank(accObjWithExternalId.External_Id__c) 
                        && !String.isBlank(accObj.External_Id__c) 
                        && accObjWithExternalId.External_Id__c.equals(accObj.External_Id__c);
                    if(externalIdCheck){
                        present = true;
                        accObj.Id = accObjWithExternalId.Id;
                        accountsToUpdate.add(accObj);
                        break;
                    }
                }
                if(!present){
                    accountsToInsert.add(accObj);
                }
            }
        }else{
            accountsToInsert = accountList;
        }
    }

    public List<Account> getAccountsToInsert(){
        return accountsToInsert;
	}

	public List<Account> getAccountsToUpdate(){
        return accountsToUpdate;
	}
}