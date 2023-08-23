/**
 * Created by - snpa
 * Description - Handler for AccountTrigger
 *
 */
public with sharing class AccountHandler {
	
	private static final String DEPARTMENT_RT = 'Department';
	private static final String LOCATION_RT = 'Location';
	
	private Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType> ([SELECT Id, 
																				  DeveloperName 
																			FROM RecordType 
																			WHERE RecordType.DeveloperName = :DEPARTMENT_RT OR
																				  RecordType.DeveloperName = :LOCATION_RT]);
	
    public void OnBeforeInsert(List<Account> accountList) {
    	copyValuesOnInsert(accountList);		
	}
	
	public void OnBeforeUpdate(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) {
		copyValuesOnUpdate(newAccountMap, oldAccountMap);	
	}
	
	private void copyValuesOnUpdate(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) {
		Set<Id> idSet = new Set<Id>();
		List<Account> updatedAccountList = new List<Account>();

		if(recordTypeMap != null) {
	    	for(Account accnt : newAccountMap.Values()) {
	    		if(recordTypeMap.containsKey(accnt.RecordTypeId) 
	    				&& accnt.MMS_Translation_of__c == null 
	    				&& 
						 (oldAccountMap.get(accnt.id).Name != accnt.Name ||
	    				  oldAccountMap.get(accnt.id).MMS_Manager__c != accnt.MMS_Manager__c ||
	    				  oldAccountMap.get(accnt.id).MMS_Parent_Department__c != accnt.MMS_Parent_Department__c ||
	    				  oldAccountMap.get(accnt.id).MMS_Contact_Person__c != accnt.MMS_Contact_Person__c ||
	    				  oldAccountMap.get(accnt.id).MMS_Location_Title__c != accnt.MMS_Location_Title__c 
	    				 )
	    		  ) {
	    			idSet.add(accnt.Id);		
	    		}	
	    	}
	    	
	    	if(idSet != null) {
	    		for ( Account translatedAccount : [SELECT Id,Name,
														  MMS_Manager__c,
														  MMS_Parent_Department__c,
														  MMS_Translation_of__c,
														  MMS_Contact_Person__c,
														  RecordTypeId,
														  MMS_Location_Title__c
												   FROM Account WHERE MMS_Translation_of__c IN : idSet]	) {
												   	
			    	updatedAccountList.add(copyValuesToTranslation(translatedAccount, 
			    												   newAccountMap.get(translatedAccount.MMS_Translation_of__c)));
			    }
			    
			    if(updatedAccountList != null && updatedAccountList.size() > 0) {
			    	update updatedAccountList;
			    }
	    	}
		}		
	}
	private void copyValuesOnInsert(List<Account> accountList) {
		Set<Id> idSet = new Set<Id>();
    	
    	if(recordTypeMap != null) {
	    	for(Account accnt : accountList) {
	    		if(recordTypeMap.containsKey(accnt.RecordTypeId) && accnt.MMS_Translation_of__c != null) {
	    			idSet.add(accnt.MMS_Translation_of__c);		
	    		}
	    	}
	    	
	    	if(idSet != null && idSet.size() > 0) {
		    	
		    	Map<Id, Account> parentAccountMap = new Map<Id, Account> ([SELECT Id,
		    																Name,
		    																MMS_Manager__c,
		    																MMS_Parent_Department__c,
		    																MMS_Contact_Person__c,
		    																MMS_Location_Title__c
		    														 FROM Account WHERE Id IN : idSet]);
		    	for(Account accnt : accountList) {
		    		if(recordTypeMap != null 
		    				&& recordTypeMap.containsKey(accnt.RecordTypeId) 
		    				&& accnt.MMS_Translation_of__c != null 
		    				&& parentAccountMap.containsKey(accnt.MMS_Translation_of__c)) {
		    					
						accnt = copyValuesToTranslation(accnt, parentAccountMap.get(accnt.MMS_Translation_of__c));		    			
		    		}
		    	}
	    	}
    	}	
	}
	
	/**
	 * Method copies common values from Parent Account to Translations
	 */
	private Account copyValuesToTranslation(Account translatedAccount, Account parentAccount) {
		
		translatedAccount.name = parentAccount.Name;
		if(recordTypeMap != null 
				&& recordTypeMap.containsKey(translatedAccount.RecordTypeId) 
				&& recordTypeMap.get(translatedAccount.RecordTypeId).DeveloperName ==  DEPARTMENT_RT) {
			
			translatedAccount.MMS_Manager__c = parentAccount.MMS_Manager__c;
			translatedAccount.MMS_Parent_Department__c = parentAccount.MMS_Parent_Department__c;
		} else {
			translatedAccount.MMS_Contact_Person__c = parentAccount.MMS_Contact_Person__c;	
		}
		return translatedAccount;		
	}
}