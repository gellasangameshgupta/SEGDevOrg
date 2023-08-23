/*******************************************************************************************************
* 
* @ Name    :   IP_InventionImageUploadCtrl
* @ Purpose :   Extension for IP_InventionImageUpload VF Page
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_InventionImageUploadCtrlTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public with sharing class IP_InventionImageUploadCtrl {
    
    private ApexPages.standardController controller;
    private Case objCase;
    private List<Id> photoIds;
    
    public IP_InventionImageUploadCtrl(ApexPages.StandardController controller) {
        this.controller = controller;
        this.objCase = (Case)controller.getRecord();
    }
    
    public static String imageURL{get;set;}
    public List<Id> photos {
        get {
            if(photoIds == null) {
                photoIds = new List<Id>();
                Set<Id> setIds = new set<Id>();
                setIds.add('5003O0000080EDlQAM');
                for(ContentDocumentLink att : [select Id,ContentDocumentID from ContentDocumentLink where LinkedEntityId IN: setIds ]) {
                    photoIds.Add(att.Id);
                }
            }      
            return photoIds;
        }
    }
    
    public Integer totalPhotos {
        get {
            return photos.size();
        }
    }
    
    @AuraEnabled
    public static string getContents(Id parentId) {
        // imageURL = '/servlet/servlet.FileDownload?file=';
        imageURL =  '0693O000001ER5yQAG';
        return imageURL;
    }
}