/*******************************************************************************************************
* 
* @ Name            :   SEG_B2BBuyerController
* @ Purpose         :   Controller for assigning B2B Buyer Permisson set to Shop Me Users. 
* @ Author          :   Mridul Nathani
* @ Test Class Name :   DEL_WorkflowListviewControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    18-01-2023     |  mridul.nathani@absyz.com     |  1.0          |  Initial Version
*  
*******************************************************************************************************/
public with sharing class SEG_B2BBuyerController {

    @AuraEnabled
    public static void permisson() {

        Id idUserId = UserInfo.getUserId();

        PermissionSet objPermissionSet = [SELECT 
                                          Id, 
                                          Name, 
                                          Label, 
                                          ProfileId, 
                                          LicenseId 
                                          FROM PermissionSet 
                                          WHERE Name = :System.Label.CLB2B00066]; // CLB2B00066 = B2B_Buyer (Permisson Set Name)

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
        
        if( list_Assignments.size() < 1 && objUser.Profile.UserLicenseId == objPermissionSet.LicenseId) {
            PermissionSetAssignment objAssignment = new PermissionSetAssignment();
            objAssignment.AssigneeId = idUserId;
            objAssignment.PermissionSetId = objPermissionSet.Id;
            insert objAssignment;   
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isPermissonAlreadyAssigned() {

        Id idUserId = UserInfo.getUserId();

        PermissionSet objPermissionSet = [SELECT 
                                          Id, 
                                          Name, 
                                          Label, 
                                          ProfileId, 
                                          LicenseId 
                                          FROM PermissionSet 
                                          WHERE Name = :System.Label.CLB2B00066]; // CLB2B00066 = B2B_Buyer (Permisson Set Name)

	    List<PermissionSetAssignment> list_Assignments = [SELECT 
                                                          PermissionSetId 
                                                          FROM PermissionSetAssignment 
                                                          WHERE PermissionSetId = :objPermissionSet.Id];

        Boolean blnIsPermissonAlreadyAssigned = list_Assignments.size() < 1;
        return blnIsPermissonAlreadyAssigned;
    }
}