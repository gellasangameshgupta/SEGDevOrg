/*******************************************************************************************************
* 
* @ Name        : 	B2B_ContactSetupAssistantControllerTest
* @ Purpose     : 	Test class for B2B_ContactSetupAssistantController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_ContactSetupAssistantController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   02-07-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_ContactSetupAssistantControllerTest {
    
    @testSetup
    static void createData() {
        
        Account objAccount = new Account(
            Name = 'TestAccount',
            ShippingStreet = 'TestShippingStreet',
            ShippingCity = 'TestShippingCity',                                          
            ShippingState = 'TestShippingState',
            ShippingPostalCode = '123',
            ShippingCountry = 'TestShippingCountry',
            BillingStreet = 'TestBillingStreet',
            BillingCity = 'TestBillingCity',
            BillingState = 'TestBillingState',
            BillingPostalCode = '124',
            BillingCountry = 'TestBillingCountry'
        );
        insert objAccount;
        
        Contact objContact = new Contact(
            LastName = 'TestLastName',
            AccountId = objAccount.Id,
            MailingStreet = 'TestMailingStreet',
            MailingCity = 'TestMailingCity',
            MailingState = 'TestMailingState',
            MailingPostalCode = '125',
            MailingCountry = 'TestMailingCountry',
            OtherStreet = 'TestOtherStreet',
            OtherCity = 'TestOtherCity',
            OtherState = 'TestState',    
            OtherPostalCode = '126',
            OtherCountry = 'OtherCountry'
        );
        insert objContact;
        
        ContactPointAddress objContactPointAddress = new ContactPointAddress(
            Name = 'TestContactPointAddress',
            ParentId = objAccount.Id,
            AddressType = 'Shipping'
        );
        insert objContactPointAddress;
        
        ContactPointAddress objContactPointAddress1 = new ContactPointAddress(
            Name = 'TestContactPointAddress1',
            ParentId = objAccount.Id,
            AddressType = 'Billing'
        );
        insert objContactPointAddress1;
        
        BuyerGroup objBuyerGroup = new BuyerGroup(
            Name = 'TestBuyerGroup'   
        );
        insert objBuyerGroup;
    }
    
    @isTest
    public static void testGetStepInformation() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id
                              FROM Contact 
                              WHERE LastName = 'TestLastName'
                             ];
        
        Account objAccount = [SELECT 
                              Id
                              FROM Account
                              WHERE Name = 'TestAccount'
                             ];
        
        B2B_ContactSetupAssistantController.SetupData objSetupData = 
            B2B_ContactSetupAssistantController.getStepInformation(objContact.Id, objAccount.Id);
        
        Test.stopTest();
        
        System.assertEquals(objSetupData.blnAccountAvailable, true, 'Account available under Contact');
    }
    
    @isTest
    public static void testGetStepInformationUserEnabled() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id
                              FROM Contact 
                              WHERE LastName = 'TestLastName'
                             ];
        
        Account objAccount = [SELECT 
                              Id
                              FROM Account
                              WHERE Name = 'TestAccount'
                             ];
        
        Id idProfile = [SELECT 
                        Id 
                        FROM Profile 
                        WHERE Name = 'Customer Community Plus Login User'
                       ].Id;
        
        User objAdminUser = [SELECT 
                             Id 
                             FROM User 
                             WHERE Profile.Name = 'System Administrator'
                             AND IsActive = true
                             LIMIT 1
                            ];
        
        User objCommunityUser = new User(  
            FirstName = 'Test',  
            LastName = 'Community User',  
            Email = 'test' + Math.random() + '@test.com',  
            Username = 'test_' + Math.random() + '@test.com',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = String.valueOf(Math.random()).substring(0,6),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = idProfile,
            ContactId = objContact.Id
        );
        
        System.runAs(objAdminUser) {
            insert objCommunityUser;
        }
        
        B2B_ContactSetupAssistantController.SetupData objSetupData = 
            B2B_ContactSetupAssistantController.getStepInformation(objContact.Id, objAccount.Id);
        
        Test.stopTest();
        
        System.assertEquals(objSetupData.blnAccountAvailable, true, 'Account available under Contact');
    }
    
    @isTest
    public static void testEnableBuyerAccount() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id 
                              FROM Contact 
                              WHERE LastName = 'TestLastName'
                             ];
        
        Account objAccount = [SELECT 
                              Id
                              FROM Account
                              WHERE Name = 'TestAccount'
                             ];
        
        B2B_ContactSetupAssistantController.enableBuyerAccount(objAccount.Id, 'TestName');
        
        BuyerGroup objBuyerGroup = [SELECT 
                                    Id
                                    FROM BuyerGroup
                                    WHERE Name = 'TestBuyerGroup'
                                   ];
        
        B2B_ContactSetupAssistantController.addBuyerGroup(objAccount.Id, objBuyerGroup.Id);
        
        Test.stopTest();
        
        List<BuyerGroupMember> list_BuyerGroupMembers = [SELECT
                                                         Id
                                                         FROM BuyerGroupMember
                                                         WHERE BuyerGroupId = :objBuyerGroup.Id
                                                        ];
        
        System.assertEquals(list_BuyerGroupMembers.isEmpty(), false, 'Buyer Account added to Group');
    }
    
    @isTest
    public static void testGetContactPointAddresses() {
        Test.startTest();
        Account objAccount = [SELECT 
                              Id
                              FROM Account
                              WHERE Name = 'TestAccount'
                             ];
        
        List<ContactPointAddress> list_ContactPointAddresses = 
            B2B_ContactSetupAssistantController.getContactPointAddresses(objAccount.Id, 'Shipping');
        
        Test.stopTest();
        
        System.assertEquals(list_ContactPointAddresses.isEmpty(), false, 'Contact Point Address not empty');
    }
}