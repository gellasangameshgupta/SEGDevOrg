/*******************************************************************************************************
* 
* @ Name            :   B2B_AccountSelector
* @ Purpose         :   Includes method to query Account data
* @ Methods         :   1) getAccountById - Returns Account for the account id
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

public with sharing class B2B_AccountSelector {
    
    public static List<Account> getAccountById(Id strAccountId) {
        return [SELECT
                Id,
                Name,
                (SELECT 
                 Id 
                 FROM 
                 BuyerAccounts
                 LIMIT 1
                ),
                (SELECT
                 Id,
                 AddressType 
                 FROM
                 ContactPointAddresses
                )
                FROM
                Account
                WHERE
                Id = :strAccountId
               ];
    }
}