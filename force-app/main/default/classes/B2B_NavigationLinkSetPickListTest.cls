/*******************************************************************************************************
* 
* @ Name        : 	B2B_NavigationLinkSetPickListTest
* @ Purpose     : 	Test class for B2B_NavigationLinkSetPickList
* @ Author      : 	Pradeep Chary
* @ Class Name  : 	B2B_NavigationLinkSetPickList
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   09-08-2021  |  pradeep.chary@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_NavigationLinkSetPickListTest {
    
    @TestSetup
    static void createData() {
        List<NavigationLinkSet> list_NavigationLinkSet = new List<NavigationLinkSet>();
        NavigationLinkSet objNavigationLinkSet = new NavigationLinkSet();
        objNavigationLinkSet.DeveloperName = 'objNavigation';
        objNavigationLinkSet.Language = 'en_US';
        objNavigationLinkSet.MasterLabel = 'Test';
        list_NavigationLinkSet.add(objNavigationLinkSet);
    }
    
    @isTest
    static void testNavigationLinkSetPickList() {
        B2B_NavigationLinkSetPickList objB2B_NavigationLinkSetPickList = new B2B_NavigationLinkSetPickList();
        objB2B_NavigationLinkSetPickList.getDefaultValue();
        objB2B_NavigationLinkSetPickList.getValues();
    }
}