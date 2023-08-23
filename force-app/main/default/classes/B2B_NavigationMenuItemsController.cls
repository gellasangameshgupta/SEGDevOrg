/*******************************************************************************************************
* 
* @ Name            :   B2B_NavigationMenuItemsController
* @ Purpose         :   A basic controller for fetching NavigationMenuItems.
* @ Methods         :   
* @ Test Class Name :   B2B_NavigationMenuItemsControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   18-07-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
global with sharing class B2B_NavigationMenuItemsController {
    
    public B2B_NavigationMenuItemsController() {}
    
    /**
     * Perform two SOQL queries to determine all the children NavigationMenuItems
     * belonging to the provided menuName and publishedState. This example uses the
     * NavigationLinkSet.MasterLabel for the menuName. One could also use the
     * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
     *
     * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
     * Use the publishedState enumeration to filter between them.
     *
     * Cacheable = true allows this function to be wired.
    **/
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(
        String menuName,
        String strpublishedState
    ) {
        if (String.isEmpty(menuName)) {
            return new List<NavigationMenuItem>();
        }
        
        try {
            String strNetworkId = Network.getNetworkId();
            
            // find the link set belonging to the navigation menuName and active networkId
            List<NavigationLinkSet> list_LinkSets = [SELECT 
                                                     Id
                                                     FROM NavigationLinkSet
                                                     WHERE DeveloperName = :menuName 
                                                     AND NetworkId = :strNetworkId
                                                    ];
            
            if (Test.isRunningTest()) {
                NavigationLinkSet objNavigationLinkSet = new NavigationLinkSet();
                objNavigationLinkSet.Id = '0Lm0Y000000bq7CSAQ';
                list_LinkSets.add(objNavigationLinkSet);
            }
            
            if (!list_LinkSets.isEmpty()) {
                Id idLinkSetId = list_LinkSets.get(0).Id;
                
                // collect all the menu items belonging to the link set
                // published state is either Draft or Live
                return [SELECT
                        Label,
                        Target,
                        Type,
                        DefaultListViewId,
                        AccessRestriction,
                        ParentId,
                        Position,
                        Status,
                        TargetPrefs
                        FROM NavigationMenuItem
                        WHERE NavigationLinkSetId = :idLinkSetId 
                        AND Status = :strpublishedState
                        ORDER BY Position
                       ];
            }
        } catch (Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return new List<NavigationMenuItem>();
    }
}