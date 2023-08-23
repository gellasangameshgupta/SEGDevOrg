/*******************************************************************************************************
* 
* @ Name        : 	B2B_NavigationMenuItemsControllerTest
* @ Purpose     : 	Test class for B2B_NavigationMenuItemsController
* @ Author      : 	Pradeep Chary
* @ Class Name  : 	B2B_NavigationMenuItemsController
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   20-07-2021  |  pradeep.chary@absyz.com     |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_NavigationMenuItemsControllerTest {
    
    @TestSetup
    static void createData() {
        
        Profile objProfile = [SELECT
                              Id,
                              Name
                              FROM Profile
                              WHERE Name = 'Standard User'
                              LIMIT 1
                             ];
        
        User objUser = new User(
            ProfileId = objProfile.Id,
            UserName = 'testemailabc@gmail.com',
            Email = 'testemail@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LocalesIdKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles', 
            Alias = 'cspu',
            Lastname = 'lastname'
        );
        
        Database.insert(objUser);
        
        List<NetworkMember> membership = [SELECT 
                                          Network.Name,
                                          NetworkId,
                                          MemberId 
                                          FROM NetworkMember
                                          WHERE MemberId = :objUser.Id
                                         ];
        
        List<NavigationLinkSet> list_NavigationLinkSet = new List<NavigationLinkSet>();
        NavigationLinkSet objNavigationLinkSet = new NavigationLinkSet();
        objNavigationLinkSet.DeveloperName = 'objNavigation';
        objNavigationLinkSet.Language = 'en_US';
        objNavigationLinkSet.MasterLabel = 'Test';
        list_NavigationLinkSet.add(objNavigationLinkSet);
        
        List<NavigationMenuItem> list_NavigationMenuItem = new List<NavigationMenuItem>();
        NavigationMenuItem objNavigationMenuItem = new NavigationMenuItem();
        objNavigationMenuItem.Label = 'Test';
        objNavigationMenuItem.Position = 12;
        objNavigationMenuItem.Status = 'Live';
        objNavigationMenuItem.Target = 'Navigate'; 
        objNavigationMenuItem.Type = 'ExternalLink';
        objNavigationMenuItem.AccessRestriction = 'LoginRequired';
        objNavigationMenuItem.TargetPrefs = 'None';
        objNavigationMenuItem.NavigationLinkSetId = objNavigationLinkSet.Id;
        
        list_NavigationMenuItem.add(objNavigationMenuItem);
    }
    
    @isTest
    static void testNavigationMenuItemsController() {
        B2B_NavigationMenuItemsController objB2B_NavigationMenuItemsController = new B2B_NavigationMenuItemsController();
        B2B_NavigationMenuItemsController.getNavigationMenuItems('objNavigation', 'Live');
    }
    
    @isTest
    static void testB2B_NavigationMenuItemsController() {
        B2B_NavigationMenuItemsController.getNavigationMenuItems('', 'Live');
    }
}