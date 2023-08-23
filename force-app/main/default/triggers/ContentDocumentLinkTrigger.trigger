/*
trigger to give access to files when uploaded to news record - before insert
after insert - to change the imageattachedid on the news record
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, after delete) {
    
    /*if (Trigger.isbefore && Trigger.isinsert && !B2B_ContentDocumentLinkTriggerHandler.blnIsRecurssive) {
        
        Map<Id, ContentDocumentLink>mapNewsContentLink = new Map<Id, ContentDocumentLink>();
        List<Id> newsId = new List<Id>();
        Map<Id, ContentDocumentLink> mapcvwithid = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> list_ContentdocumentLinks = new List<ContentDocumentLink>();
        SET<Id> contentdocumentidset = new SET<Id>();
        
        for (ContentDocumentLink objContentDocumentLink : Trigger.new) {
            contentdocumentidset.add(objContentDocumentLink.ContentDocumentId);
            mapcvwithid.put(objContentDocumentLink.ContentDocumentId, objContentDocumentLink);
            
            String str_ObjectName = (objContentDocumentLink.LinkedEntityId).getSObjectType().getDescribe().getName();
            
            if (str_ObjectName == 'News_Announcements__c') {
                mapNewsContentLink.put(objContentDocumentLink.ContentDocumentId,objContentDocumentLink);
                newsId.add(objContentDocumentLink.LinkedEntityId);
            }
        }
        
        List<News_Announcements__c> newsAnnouncementRcd = [SELECT Id, Recordtype.Name FROM News_Announcements__c WHERE Id IN: newsId];
        List<string>extensions=(Label.CLIFv20320).toLowerCase().split(',');
        List<String>imageExtensions=(Label.NewsImageExtensions).toLowerCase().split(',');
        for (ContentVersion cd: [SELECT Id, ContentDocumentId, FileType, Fileextension, ContentSize, Origin FROM ContentVersion WHERE ContentDocumentId = :contentdocumentidset]) {
            
            if (extensions.contains(cd.FileExtension)) {
                mapcvwithid.get(cd.ContentDocumentId).adderror(Label.CLIFv20321);
            }
            
            if (!mapNewsContentLink.isEmpty()) {
                if (mapNewsContentLink.keySet().contains(cd.ContentDocumentId) && imageExtensions.contains(cd.FileExtension) && cd.Origin=='C') {
                    for (News_Announcements__c record:newsAnnouncementRcd) {
                        if (record.id == mapNewsContentLink.get(cd.ContentDocumentId).LinkedEntityId && record.Recordtype.Name == 'Local News' && cd.ContentSize>Integer.valueof(Label.NewsFileSizeRestrictionLocal)) {
                            mapNewsContentLink.get(cd.ContentDocumentId).adderror(Label.NewsValidationLocal);
                        } else if (record.id == mapNewsContentLink.get(cd.ContentDocumentId).LinkedEntityId && record.Recordtype.Name == 'Global News' && cd.ContentSize>Integer.valueof(Label.NewsFileSizeRestrictionGlobal)) {
                            mapNewsContentLink.get(cd.ContentDocumentId).adderror(Label.NewsValidationGlobal);
                        }
                    }
                }
            }
        }
        
        List<ContentDocumentLink> contentForUpdate = new List<ContentDocumentLink>();
        List<ContentDocumentLink> updateLinks = new List<ContentDocumentLink>();
        String orgId = UserInfo.getOrganizationId();
        
        List<ContentDocumentLink> cdlist2 = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE linkedentityid = :orgId AND contentdocumentid IN :contentdocumentidset];
        
        for (ContentDocumentLink content : Trigger.new) {
            if (content.LinkedEntityId  != null && cdlist2.size() == null &&
                content.LinkedEntityId.getSobjectType() == News_Announcements__c.SobjectType) {
                    ContentDocumentLink cdl = new ContentDocumentLink(
                        ContentDocumentId = content.ContentDocumentId,
                        LinkedEntityId = orgId, 
                        ShareType = 'C', 
                        Visibility = 'AllUsers'
                    );
                    
                    contentForUpdate.add(cdl);
                }
        }
        
        if (!contentForUpdate.isEmpty()) {
            insert contentForUpdate;
        }
    }*/
    
    if (Trigger.isAfter && Trigger.isInsert && !B2B_ContentDocumentLinkTriggerHandler.blnIsRecurssive) {
        //Commenting for Insight deprecation
        /*List<News_Announcements__c> newsAnnouncements = new List<News_Announcements__c>(); 
        SET<Id> newsAnnouncementsIds = new SET<Id>();  
        MAP<Id, Id> contentParentMap = new MAP<Id, Id>();
        SET<string> filetypes =  new SET<String>();*/
        LIST<ContentDocumentLink> list_ContentDocumentLinks = new LIST<ContentDocumentLink>();
        
        //Commenting for Insight deprecation
        /*List<video_format__mdt> vdf = [SELECT Id, DeveloperName FROM video_format__mdt];
        for (video_format__mdt vf : vdf) {
            filetypes.add(vf.DeveloperName);
        }*/
        
        for (ContentDocumentLink content : Trigger.new) {  
            //Check if uploaded attachment is related to News_Announcements__c Attachment and same record is already added  
            //Commenting for Insight deprecation
            /*if (content.LinkedEntityId  != null && 
                content.LinkedEntityId.getSobjectType() == News_Announcements__c.SobjectType && 
                (!newsAnnouncementsIds.contains(content.LinkedEntityId ))
               ) {
                   contentParentMap.put(content.ContentDocumentId,content.LinkedEntityId );
                   newsAnnouncementsIds.add(content.LinkedEntityId);
                }*/
            
            if (String.valueOf(content.LinkedEntityId).startsWith('801')) {
                list_ContentDocumentLinks.add(content);
            }
        }
        
        if (!list_ContentDocumentLinks.isEmpty()) {
            B2B_ContentDocumentLinkTriggerHandler.insertContentDocumentOnOrderSummary(list_ContentDocumentLinks);
        }
        
        /*for (ContentVersion contentVer : [SELECT Id, ContentDocumentId, filetype FROM ContentVersion WHERE ContentDocumentId IN :contentParentMap.keySet()]) {
            if (!filetypes.contains(contentVer.FileType)) {
                newsAnnouncements.add(  
                    new News_Announcements__c(  
                        Id = contentParentMap.get(contentVer.ContentDocumentId),  
                        ImageAttachmentId__c = contentVer.Id,
                        isAttachmentAFile__c = true
                    )
                );
            }
        }
        if (!newsAnnouncements.isEmpty()) {
            update newsAnnouncements;
        }*/
/*******************************************************************************************************
* 
* @ Purpose : code that invokes P28 functionality by using IFv2_p28Controller handler
* @ Author  : Naga Sai
* @ Test Class Name : 
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   18-03-2019  |  nagasai.chalamalasetti@absyz.com     |  1.0          |  Initial Version

*******************************************************************************************************/
        
        //Variables declaration
        /*SET<Id> contentdocumentids = new SET<Id>();
        MAP<string,string> cdAndLinkedEntityIdMap = new MAP<string,string>();
        MAP<string,string> cdIdAndCvNameMap = new MAP<string,string>();
        SET<Id> IFv2contentdocumentids = new SET<Id>();
        
        for (ContentDocumentLink cdl : trigger.new) {
            IFv2contentdocumentids.add(cdl.contentdocumentid);
        }
        for (contentversion cv:[select title,contentdocumentid from contentversion where contentdocumentid in:IFv2contentdocumentids]) {
            cdIdAndCvNameMap.put(cv.contentdocumentid,cv.title); 
        }
        for (ContentDocumentLink cdl:trigger.new) {
            if (cdl.LinkedEntityId.getSobjectType() == IFv2_AdminOnly__c.SobjectType && cdIdAndCvNameMap.get(cdl.contentdocumentid)!= label.CLIFv20152 && cdIdAndCvNameMap.get(cdl.contentdocumentid)!=label.CLIFv20151) {
                contentdocumentids.add(cdl.contentdocumentid);
                cdAndLinkedEntityIdMap.put(cdl.contentdocumentid, cdl.LinkedEntityId);
            }
        }
        
        List<contentversion> cvList = [SELECT Versiondata, title, contentdocumentid FROM contentversion WHERE contentdocumentid in:contentdocumentids];
        if (cvList.size()>0)   
            IFv2_p28Controller.CreateContact(cvList[0].versiondata.tostring(),cdAndLinkedEntityIdMap.get(cvList[0].contentdocumentid));
        */
        /*Start of IFE Logic*/
        List<Id> reqIdList = new List<Id>();
        List<IFv2_Request__c> ifeList = new List<IFv2_Request__c>();
        Map<Id, List<Id>> cdlReqMap = new Map<Id, List<Id>>();
        for (ContentDocumentLink cdl : trigger.new) {
            if (cdl.LinkedEntityId.getSobjectType() == IFv2_Request__c.SobjectType) {
                reqIdList.add(cdl.LinkedEntityId);
                if (cdlReqMap.containsKey(cdl.LinkedEntityId)) {
                    List<Id> cdlIdList= cdlReqMap.get(cdl.LinkedEntityId);
                    cdlIdList.add(cdl.Id);
                    cdlReqMap.put(cdl.LinkedEntityId,cdlIdList);
                } else {
                    cdlReqMap.put(cdl.LinkedEntityId,new List<Id> { cdl.Id });
                }
            }
        }
        
        List<IFv2_Request__c> reqList= [Select Id,Name,Workflow__c,FileCount__c from IFv2_Request__c where Id IN :cdlReqMap.keySet()];
        List<IFv2_Request__c> reqUpdList = new List<IFv2_Request__c>();
        for (IFv2_Request__c req : reqList) {
            if (req.Workflow__c == label.CLIFv20301) {
                if (cdlReqMap.containsKey(req.Id)) {
                    Decimal i = req.FileCount__c + cdlReqMap.get(req.Id).size();
                    req.FileCount__c = i;
                    reqUpdList.add(req);
                }
            }
        }
        if (!reqUpdList.isEmpty()) {
            update reqUpdList;
        }
        
        /*End of IFE Logic*/
    }
    //Delete Logic for IFE
    if (Trigger.isafter && Trigger.isdelete) {
        /*Start of IFE Logic*/
        List<Id> reqIdList = new List<Id>();
        List<IFv2_Request__c> ifeList = new List<IFv2_Request__c>();
        Map<Id, List<Id>> cdlReqMap = new Map<Id, List<Id>>();
        for (ContentDocumentLink cdl : trigger.old) {
            if (cdl.LinkedEntityId.getSobjectType() == IFv2_Request__c.SobjectType) {
                reqIdList.add(cdl.LinkedEntityId);
                if (cdlReqMap.containsKey(cdl.LinkedEntityId)) {
                    List<Id> cdlIdList= cdlReqMap.get(cdl.LinkedEntityId);
                    cdlIdList.add(cdl.Id);
                    cdlReqMap.put(cdl.LinkedEntityId,cdlIdList);
                }
                else{
                    cdlReqMap.put(cdl.LinkedEntityId,new List<Id> { cdl.Id });
                }
            }
        }
        
        List<IFv2_Request__c> reqList= [Select Id,Name,Workflow__c,FileCount__c from IFv2_Request__c where Id IN :cdlReqMap.keySet()];
        List<IFv2_Request__c> reqUpdList = new List<IFv2_Request__c>();
        for (IFv2_Request__c req : reqList) {
            if (req.Workflow__c == Label.CLIFv20301) {
                if (cdlReqMap.containsKey(req.Id)) {
                    Decimal i = req.FileCount__c - cdlReqMap.get(req.Id).size();
                    req.FileCount__c = i;
                    reqUpdList.add(req);
                }
            }
        }
        if (!reqUpdList.isEmpty()) {
            update reqUpdList;
        }
        /*End of IFE Logic*/
    }
}