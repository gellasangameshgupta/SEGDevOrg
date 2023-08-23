/** 
* Description  - Test class for ContentDocumentLinkTrigger
* Created by   - snpl
**/
@isTest(seeAllData=true)
private class ContentDocumentLinkTriggerTest {
    //Commenting for Insight deprecation
    /*static testMethod void testTriggerNews() {
        
        Test.StartTest();
        List<User> userlist = [Select Id from user Limit 1];
        
        // Create News record
        News_Announcements__c news = TestData.createNews(userlist[0].Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = news.id );
        
        insert contDoc;
        delete contDoc;
        
        news = [Select Id, ImageAttachmentId__c From News_Announcements__c where Id =: news.Id][0];
        
        // Check if ImageAttachmentId__c is modified
        //System.assertEquals(news.ImageAttachmentId__c, contentVer.Id );
        
        Test.StopTest();
    }
    
    static testMethod void testTriggerNewsImageRestrict() {
        
        Test.StartTest();
        List<User> userlist = [Select Id from user Limit 1];
        
        // Create News record
        News_Announcements__c news = TestData.createNews(userlist[0].Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        // Create ContentVersion
        // ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        
        
        ContentVersion contentVer = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            Origin='C',
            IsMajorVersion = true
        );
        insert contentVer;
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = news.id );
        
        insert contDoc;
        delete contDoc;
        
        news = [Select Id, ImageAttachmentId__c From News_Announcements__c where Id =: news.Id][0];
        
        // Check if ImageAttachmentId__c is modified
        //System.assertEquals(news.ImageAttachmentId__c, contentVer.Id );
        
        Test.StopTest();
    }*/
    
    static testMethod void testTriggerRequest() {
        
        Test.StartTest();
        List<User> userlist = [Select Id from user Limit 1];
        
        // Create Request record
        list<IFv2_Request__c> lstRequest = IFv2_testDataUtility.createRequest();  //inserting Request  
        lstRequest[0].Status__c = 'Draft' ;
        lstRequest[0].Workflow__c = 'IFE Process Workflow'; 
        insert lstRequest;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = lstRequest[0].id );
        
        insert contDoc;
        delete contDoc;
        
        Test.StopTest();
    }
    
    /**
     * Author       : Pradeep Chary
     * Date         : 05-26-2021
     * Description  : Test method to check the logic when ContentVersion is created for OrderSummary
    **/
    @isTest
    public static void testUpdateVisibiltyAsAllUsers() {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;

        Contact objContact = new Contact();
        objContact.LastName = 'Test Contact';
        objContact.Email = 'standarduser@testorg.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Order objOrder = new Order(
            AccountId = objAccount.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert objOrder;
        
        Product2 objProduct = new Product2(
            Name = 'Test Product',
            B2B_SEGIAMProductNumber__c = '1234'
        );
        insert objProduct;
        
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod(
            Name = 'Test'
        );
        insert objOrderDeliveryMethod;
        
        OrderDeliveryGroup objOrderDeliveryGroup = new OrderDeliveryGroup(
            DeliverToName = 'Test',
            OrderId = objOrder.Id,
            OrderDeliveryMethodId = objOrderDeliveryMethod.Id
        );
        insert objOrderDeliveryGroup;
        
        OrderItem objOrderProduct = new OrderItem(
            Product2Id = objProduct.Id,
            OrderId = objOrder.Id,
            UnitPrice = 15,
            Quantity = 21,
            ListPrice = 10,
            TotalLineAmount = 10,
            OrderDeliveryGroupId = objOrderDeliveryGroup.Id
        );
        insert objOrderProduct;
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        ConnectApi.OrderSummaryInputRepresentation objOrderSummary = new ConnectApi.OrderSummaryInputRepresentation();
        objOrderSummary.OrderId = objOrder.Id;
        objOrderSummary.Status = 'Created';
        ConnectApi.OrderSummaryOutputRepresentation objOrderSummaryId = ConnectApi.OrderSummaryCreation.createOrderSummary(objOrderSummary);
        
        OrderSummary objOrderSummaryInserted = [SELECT Id FROM OrderSummary WHERE Id = :String.valueOf(objOrderSummaryId.OrderSummaryId) LIMIT 1];
        
        ContentVersion objContentVersion = new ContentVersion(
            Title = 'news news',
            ContentURL = 'http://www.google.com' 
        );
        insert objContentVersion;
        objContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :objContentVersion.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink objContentDocumentLink =  new ContentDocumentLink(
            ContentDocumentId = objContentVersion.ContentDocumentId,
            ShareType = 'I',
            LinkedEntityId = objOrder.Id
        );

        String strUniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile objProfile = [SELECT 
                              Id 
                              FROM Profile 
                              WHERE Name = 'System Administrator'
                             ];
        
        User objUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = objProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = strUniqueUserName
        );
        insert objUser;

      // System.runAs(objUser) {
            insert objContentDocumentLink;
       // }
        
        ContentDocumentLink objUpdatedContentDocumentLink = [SELECT 
                                                             Id, 
                                                             Visibility 
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId = :objOrderSummaryInserted.Id
                                                             LIMIT 1
                                                            ];
        System.assertEquals('AllUsers', objUpdatedContentDocumentLink.Visibility);
    }
}