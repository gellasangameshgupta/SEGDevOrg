/*******************************************************************************************************
* 
* @ Name        : B2B_RegistrationControllerTest
* @ Purpose     : Test class for B2B_RegistrationController
* @ Author      : Aseem Doddamani
* @ Class Name  : B2B_RegistrationController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   24-05-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version

*******************************************************************************************************/
@isTest
public class B2B_RegistrationControllerTest {
    
    @TestSetup
    static void createData() {
        
        IFv2_Workflow__c objWorkflow = new IFv2_Workflow__c(
            Workflow__c = 'ShopMe',
            Name = 'Test'
        );
        
        insert objWorkflow;
    }
    
    @isTest
    public static void testSaveContactDetails() {
        Test.startTest();
        
        String strContactRecordTypeId = 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId();
        
        Contact objContact = new Contact(
            LastName = 'LName',
            RecordTypeId = strContactRecordTypeId
        );
        
        List<Contact> list_Contacts = new List<Contact>();
        list_Contacts.add(objContact);
        
        // Executing of method saveContactDetails
        B2B_RegistrationController.saveContactDetails(list_Contacts);
        
        List<Contact> list_InsertedContacts = [SELECT Id FROM Contact LIMIT 1];
        
        Test.stopTest();
        System.assertEquals(!list_InsertedContacts.isEmpty(), true);
    }
    
    @isTest
    public static void testCreateRequests() {
        Test.startTest();
        
        String strContactRecordTypeId = 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId();
        
        Contact objContact = new Contact(
            LastName = 'LName',
            RecordTypeId = strContactRecordTypeId,
            MailingStreet = 'Street 10',
            MailingCity = 'Stuttgart',
            MailingState = 'Stuttgart',
            MailingCountry = 'Germany',
            MailingPostalCode = '12',
            OtherStreet = 'Street 10',
            OtherCity = 'Stuttgart',
            OtherState = 'Stuttgart',
            OtherCountry = 'Germany',
            OtherPostalCode = '12'
        );
        
        List<Contact> list_Contacts = new List<Contact>();
        list_Contacts.add(objContact);
        
        B2B_RegistrationController.createRequests(list_Contacts);
        
        List<IFv2_Request__c> list_Requests = [SELECT Id FROM IFv2_Request__c WHERE Workflow__c = 'ShopMe'];
        
        Test.stopTest();
        
        System.assertEquals(!list_Requests.isEmpty(), true);
    }
}