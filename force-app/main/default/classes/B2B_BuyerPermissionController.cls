/*******************************************************************************************************
* 
* @ Name            :   B2B_BuyerPermissionController
* @ Purpose         :   Controller for assigning B2B Buyer Permisson set to Shop Me Users. 
* @ Author          :   Mridul Nathani
* @ Test Class Name :   B2B_BuyerPermissionControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    18-01-2023      |  mridul.nathani@absyz.com     |  1.0          |  Initial Version
*    26-01-2023      | prathiksha.suvarna@absyz.com  |  1.1          |  Updated Version
*******************************************************************************************************/
public with sharing class B2B_BuyerPermissionController {
    
    @AuraEnabled
    public static void permisson() {
        Id idUserId = UserInfo.getUserId();
        // CLB2B00066 = B2B_Buyer (Permisson Set Name)
        PermissionSet objPermissionSet = [SELECT 
                                          Id, 
                                          Name, 
                                          Label, 
                                          ProfileId, 
                                          LicenseId 
                                          FROM PermissionSet 
                                          WHERE Name = :System.Label.CLB2B00066]; 
        
        List<PermissionSetAssignment> list_Assignments = [SELECT 
                                                          PermissionSetId 
                                                          FROM PermissionSetAssignment 
                                                          WHERE PermissionSetId = :objPermissionSet.Id];
        
        User objUser = [SELECT 
                        Id,
                        Name,
                        Profile.Name,
                        Profile.UserLicenseId 
                        FROM User 
                        WHERE Id = :idUserId];	
        
        if(list_Assignments.size() < 1 && objUser.Profile.UserLicenseId == objPermissionSet.LicenseId) {
            PermissionSetAssignment objAssignment = new PermissionSetAssignment();
            objAssignment.AssigneeId = idUserId;
            objAssignment.PermissionSetId = objPermissionSet.Id;
            insert objAssignment;   
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isPermissonAlreadyAssigned() {
        Id idUserId = UserInfo.getUserId();
        // CLB2B00066 = B2B_Buyer (Permisson Set Name)
        PermissionSet objPermissionSet = [SELECT 
                                          Id, 
                                          Name, 
                                          Label, 
                                          ProfileId, 
                                          LicenseId 
                                          FROM PermissionSet 
                                          WHERE Name = :System.Label.CLB2B00066];
        
        List<PermissionSetAssignment> list_Assignments = [SELECT 
                                                          PermissionSetId 
                                                          FROM PermissionSetAssignment 
                                                          WHERE PermissionSetId = :objPermissionSet.Id];
        
        Boolean blnIsPermissonAlreadyAssigned = list_Assignments.size() < 1;
        return blnIsPermissonAlreadyAssigned;
    }
}