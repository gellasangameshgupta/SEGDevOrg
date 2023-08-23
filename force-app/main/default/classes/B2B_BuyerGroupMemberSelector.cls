/*******************************************************************************************************
* 
* @ Name            :   B2B_BuyerGroupMemberSelector
* @ Purpose         :   Includes method to query BuyerGroupMember data
* @ Methods         :   1) getBuyerGroupMembersByBuyerId - Returns true if BuyerGroupMembers exist for the buyer account id
*                           params - strAccountId
* @ Author          :   Monal Kumar
* @ Usage           :   1) Identifies the status of the account setup
* @ Test Class Name :   
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   07-07-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public without sharing class B2B_BuyerGroupMemberSelector {
    @AuraEnabled
    public static List<BuyerGroupMember> getBuyerGroupMembersByBuyerId(Id strAccountId) {
        return [SELECT
                Id,
                BuyerGroupId,
                BuyerGroup.Name
                FROM
                BuyerGroupMember
                WHERE
                BuyerId = :strAccountId
               ];
    }
}