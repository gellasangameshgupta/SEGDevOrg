/*******************************************************************************************************
* 
* @ Name        : 	B2B_FooterControllerTest
* @ Purpose     : 	Test class for B2B_FooterController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_FooterController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   02-06-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_FooterControllerTest {
    
    @isTest
    static void testFetchMetadata() {
        Test.startTest();
        B2B_FooterController.FooterComponentWrapper objResponse = 
            B2B_FooterController.fetchMetadata();
        
        System.assertEquals(!objResponse.list_SocialMediaComponents.isEmpty(), true);
        Test.stopTest();
    }
}