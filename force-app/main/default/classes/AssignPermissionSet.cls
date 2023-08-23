/**
* A class which holds methods to changes NT User to uppperCase and assign permission set.
* Created By: Chitranjan Chetkar
* Created On: 16/05/2018 
*/
global with sharing class AssignPermissionSet {
    
    // Method to change NT UserID to Uppercase.
    public static void userBeforeInsert(List<User> UserList) {
		if(!UserList.isEmpty()) {
			for (User userObj : UserList) {
				if(userObj.sysUserCreationApp__c == True && userObj.NT_User__c != null) {
						userObj.NT_User__c = userObj.NT_User__c.toUpperCase();
				}                
			}
		}
	}
    
    // Method to assign permission set on user creation and federationidentifier.
    @future
    public static void AssignPermissionSetToUsers (List<Id> userIdList) {
		
		if(!userIdList.isEmpty()) {

			string permSetId = [SELECT Id FROM PermissionSet WHERE Label =: Label.Permission_Set_SG_01_Intranet_User_Only LIMIT 1].Id;
			List<User> userList = [SELECT ID,NT_User__c,FederationIdentifier,sysUserCreationApp__c FROM USER WHERE ID=: userIdList];
			List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
			
			for (User u : userList) {
				
				PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permSetId, AssigneeId = u.Id);
				permissionSetList.add(psa);
				
				if(u.NT_User__c != '' || u.NT_User__c != null) {
					u.FederationIdentifier = u.NT_User__c;
				}            
			}
			
			update userList;
			
			if(!test.isRunningTest()) {
				upsert permissionSetList;
			}      
		}
	}
}