/*******************************************************************************************************
* 
* @ Name            :   B2B_NavigationLinkSetPickList
* @ Purpose         :   A basic controller for fetching NavigationMenuItems.
* @ Methods         :   
* @ Test Class Name :   B2B_NavigationLinkSetPickListTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   18-07-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/

global class B2B_NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            'Default Navigation',
            'Default Navigation'
        );
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> list_NavigationLinkSet = [SELECT 
                                                          MasterLabel, 
                                                          DeveloperName
                                                          FROM NavigationLinkSet
                                                         ];
        
        for (NavigationLinkSet objNavigationLinkSet : list_NavigationLinkSet) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                objNavigationLinkSet.MasterLabel,
                objNavigationLinkSet.DeveloperName
            );
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}