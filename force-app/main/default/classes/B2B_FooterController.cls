/*******************************************************************************************************
* 
* @ Name            :   B2B_FooterController
* @ Purpose         :   Controller for LWC b2b_footer, b2b_termsAndConditions and b2b_privacyStatement
* @ Methods         :   1) fetchMetadata - To return the custom metadata type values
* @ Author          :   Aseem Doddamani
* @ Usage           :   1) To display custom meta data type values which are active and
*                           use it on the custom icon diplayed in the footer section from b2b_footer lwc component
* @ Test Class Name :   B2B_FooterControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   27-05-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class B2B_FooterController {
    
    @AuraEnabled(cacheable=true)
    public static FooterComponentWrapper fetchMetadata() {
        List<B2B_FooterComponent__mdt> list_FooterComponents = new List<B2B_FooterComponent__mdt>();
        FooterComponentWrapper objWrapper = new FooterComponentWrapper();
        
        try {
            list_FooterComponents = [SELECT 
                                     MasterLabel,
                                     ComponentIcon__c,
                                     ComponentURL__c,
                                     Category__c,
                                     IsActive__c,
                                     GridColumnSize__c,
                                     Order__c
                                     FROM B2B_FooterComponent__mdt
                                     WHERE IsActive__c = true
                                     ORDER BY Order__c ASC];
            
            for (B2B_FooterComponent__mdt objFooterComponent : list_FooterComponents) {
                if (objFooterComponent.Category__c == 'Social Media') {
                    objWrapper.list_SocialMediaComponents.add(objFooterComponent);
                } else if (objFooterComponent.Category__c == 'Document') {
                    objWrapper.list_DocumentComponents.add(objFooterComponent);
                }
            }                   
        } catch(Exception ex) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
        }
        
        return objWrapper;
    }
    
    public class FooterComponentWrapper {
        @AuraEnabled
        public List<B2B_FooterComponent__mdt> list_SocialMediaComponents = new List<B2B_FooterComponent__mdt>();
        @AuraEnabled
        public List<B2B_FooterComponent__mdt> list_DocumentComponents = new List<B2B_FooterComponent__mdt>();
    }
}