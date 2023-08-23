/*******************************************************************************************************
* 
* @ Name            :   B2B_ContactSelector
* @ Purpose         :   Includes method to query contact data
* @ Methods         :   1) getContactById - Returns contact for the contact id
*                           params - strContactId
* @ Author          :   Monal Kumar
* @ Usage           :   1) Identifies the status of the current contact setup
* @ Test Class Name :   
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   07-07-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
public with sharing class B2B_ContactSelector {
    
    public static List<Contact> getContactIdById(Id strContactId) {
        return [SELECT
                Id,
                AccountId,
                OwnerId,
                OtherAddress,
                MailingAddress,
                (SELECT 
                 Id 
                 FROM 
                 Users
                )
                FROM
                Contact
                WHERE
                Id = :strContactId
               ];
    }
}