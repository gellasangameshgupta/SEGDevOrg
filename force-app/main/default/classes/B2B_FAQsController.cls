/*******************************************************************************************************
* 
* @ Name            :   B2B_FAQsController
* @ Purpose         :   This class contains the controller methods for b2b_faqCmp LWC
* @ Author          :   Pradeep Chary
* @ Test Class Name :   B2B_FAQsControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   09-06-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public with sharing class B2B_FAQsController {
    
    /**
     * Author       : Pradeep Chary
     * Date         : 09-06-2021
     * Description  : To fetch all the articles to be displayed on the FAQs page.
    **/
    @AuraEnabled
    public static Map<String, List<FAQWrapper>> getAllFAQRecords() {
        Map<String, List<FAQWrapper>> map_FAQByCategory = new Map<String, List<FAQWrapper>>();
        try {
            Id strProfileId = UserInfo.getProfileId();
            List<Profile> list_Profiles = [SELECT 
                                           Name
                                           FROM Profile 
                                           WHERE Id = :strProfileId
                                          ];
            
            if (!list_Profiles.isEmpty()) {
                String strProfileName = list_Profiles[0].Name;
                String strDynamicQuery = 'SELECT Id, Active__c, Category__c, Description__c, Subject__c ' +
                    'FROM B2B_FAQ__c WHERE Active__c = true AND ';
                
                //CLB2B00049 = list of authorized users
                List<String> list_AuthorizedUsers = Label.CLB2B00049.split(',');
                if (list_AuthorizedUsers.indexOf(strProfileName) > -1) {
                    strDynamicQuery = strDynamicQuery + 'IsUserVisible__c = true ORDER BY Category__c';
                } else {
                    strDynamicQuery = strDynamicQuery + 'IsGuestVisible__c = true ORDER BY Category__c';
                }
                
                for (B2B_FAQ__c objFAQ : Database.query(strDynamicQuery)) {
                    if (!map_FAQByCategory.containsKey(objFAQ.Category__c)) {
                        map_FAQByCategory.put(objFAQ.Category__c, new List<FAQWrapper>());
                    }
                    
                    FAQWrapper objWrapper = new FAQWrapper();
                    objWrapper.strSubject = objFAQ.Subject__c;
                    objWrapper.strDescription = objFAQ.Description__c;
                    objWrapper.strCategory = objFAQ.Category__c;
                    objWrapper.strDisplayedDescription = '';
                    map_FAQByCategory.get(objFAQ.Category__c).add(objWrapper);
                }
            }
            
            return map_FAQByCategory;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class FAQWrapper {
        @AuraEnabled public String strCategory;
        @AuraEnabled public String strDescription;
        @AuraEnabled public String strSubject;
        @AuraEnabled public String strDisplayedDescription;
    }
}