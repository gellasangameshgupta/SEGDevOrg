/*******************************************************************************************************
* 
* @ Name    :   IP_IDFTriggerHelper
* @ Purpose :   Trigger Helper for IP_IDFTrigger. To share IDF records with IP Managerand PRC Member.
*				To update IP Right status.
* @TestClass:	IP_IDFTriggerHelperTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  madhuravani.b@absyz.com      |  1.0          |  Initial Version
*********************************************************************************************************************/
public without sharing class IP_IDFTriggerHelper {
    
    //Creates CaseShare records to share IDF record access with IP Managers, PRC Members and Law Firm Users
    public static void createsharingrecords(list<Case> newcases, Map<Id, Case> oldcases){
        list<CaseShare> insertCaseList = new list<CaseShare>();
        List<Id> caseIdList = new List<Id>();
        list<CaseShare> caseShareList = new list<CaseShare>();
        Map<String,List<String>> caseUserMap = new Map<String,List<String>>();
        
        if(newcases!=NULL && newcases.size()>0){
            for(Case c : newCases){
                caseIdList.add(c.Id);
            }
        }
        caseShareList = [Select UserOrGroupId,CaseId from CaseShare where CaseId IN :caseIdList];
        
        if(caseShareList.size() > 0){
            for(CaseShare cs : caseShareList){
                if(caseUserMap.containskey(cs.Id)){
                    List<String> userList = caseUserMap.get(cs.Id);
                    userList.add(cs.UserOrGroupId);
                    caseUserMap.put(cs.Id,userList);
                }
                else{
                    caseUserMap.put(cs.Id,new List<String>{cs.UserOrGroupId});
                }
            }
        }
        if(newcases!=NULL && newcases.size()>0){
            for(Case cs: newcases){
                if(cs.IP_Manager__c!=NULL && oldcases!=NULL && oldcases.size()>0 && oldcases.get(cs.Id).IP_Manager__c!=cs.IP_Manager__c){
                    System.debug('inside IP Mgr if');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_Manager__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                }else if(oldcases==NULL && cs.IP_Manager__c!=NULL){
                    System.debug('inside IP Mgr else');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_Manager__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                    
                }
                
                if(cs.IP_PRC_Member__c!=NULL && oldcases!=NULL && oldcases.size()>0 && oldcases.get(cs.Id).IP_PRC_Member__c!=cs.IP_PRC_Member__c){
                    System.debug('inside PRC if');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_PRC_Member__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                    
                }else if(oldcases==NULL && cs.IP_PRC_Member__c!=NULL){
                    System.debug('inside PRC else');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_PRC_Member__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                    
                }
                
                //access to Lawfirm users
                if(cs.IP_Law_Firm__c!=NULL && oldcases!=NULL && oldcases.size()>0 && oldcases.get(cs.Id).IP_Law_Firm__c!=cs.IP_Law_Firm__c){
                    System.debug('inside Law Firm if');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_Law_Firm__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                    
                }else if(oldcases==NULL && cs.IP_Law_Firm__c!=NULL){
                    System.debug('inside Law Firm else');
                    if(!caseUserMap.containskey(cs.Id)){
                        CaseShare cshare = new CaseShare(CaseAccessLevel='Edit',UserOrGroupId=cs.IP_Law_Firm__c, CaseId=cs.Id);
                        insertCaseList.add(cshare);
                    }
                    
                }
            }
        }
        
        if(insertCaseList.size()>0){
            try {
                database.insert(insertCaseList, false);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
        
    }
    
    
    //Sends email to IP Manager with Law Firm's Feedback
    /*public static void sendEmailtoIPManager(List<Case> newCasesList, Map<ID,Case> oldCasesMap){
        
        List<Id> newCaseIds = new List<Id>();
        list<Case> newCaseQueryList = new List<Case>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<String> emailAddress = new List<String>();
        List<Id> contentDocumentIdList = new List<Id>();
        Map<Id,List<Id>> caseCDLIdMap = new Map<Id,List<Id>>();
        Map<Id,ContentVersion> cvMap = new Map<Id,ContentVersion>();
        
        EmailTemplate templateId = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                    from EmailTemplate where Name = 'IP Confirmation from Law Firm'];
        
        
        for(Case cse : newCasesList){
            if(cse.IP_Is_Law_Firm_Feedback_Updated__c == true && oldCasesMap.get(cse.Id).IP_Is_Law_Firm_Feedback_Updated__c != true && cse.IP_Comments_to_OC__c != null){
                newCaseIds.add(cse.Id);
            }
        }
        
        if(newCaseIds.size() > 0){
            for(ContentDocumentLink cdLink : [SELECT LinkedEntityId, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityId IN :newCaseIds])
            {
                contentDocumentIdList.add(cdLink.ContentDocumentid);
                if(caseCDLIdMap.containskey(cdLink.LinkedEntityid)){
                    List<Id> cdlIdList = caseCDLIdMap.get(cdLink.LinkedEntityid);
                    cdlIdList.add(cdLink.ContentDocumentid);
                    caseCDLIdMap.put(cdLink.LinkedEntityid,cdlIdList);
                }
                else{
                    caseCDLIdMap.put(cdLink.LinkedEntityid,new List<Id> { cdLink.ContentDocumentid });
                }
            }
        }    
        newCaseQueryList = [Select Id,IP_Is_Law_Firm_Feedback_Updated__c,IP_Comments_to_OC__c,IP_Manager__c,IP_Manager__r.email from Case where Id IN :newCaseIds];
        
        for(Case cse : newCaseQueryList){
            List<Messaging.Emailfileattachment> fileList = new List<Messaging.Emailfileattachment>();
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId.Id, null, cse.Id);
            mail.setTargetObjectId(UserInfo.getUserId()); 
            mail.setSenderDisplayName('SEG Patents Team');
            mail.setUseSignature(false); 
            mail.setBccSender(false); 
            mail.setSaveAsActivity(false);
            mail.toAddresses = new String[] {cse.IP_Manager__r.email};
                
                List<ContentVersion> cvList = new List<ContentVersion>();
            
            if(caseCDLIdMap.containskey(cse.Id)){
                cvList = [SELECT Title, PathOnClient, FileType, Versiondata, ContentDocumentId
                          FROM ContentVersion 
                          WHERE ContentDocumentId IN :caseCDLIdMap.get(cse.Id)  
                          AND IP_LawFirmAttachment__c = true];
            }
            if(cvList.size() > 0){
                for(ContentVersion cv : cvList){
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setBody(cv.VersionData);
                    efa.setFileName(Cv.Title);
                    mail.fileattachments.add(efa);
                }
            }
            allmsg.add(mail);
        }
        
        if(allmsg.size() > 0)
        {
            try {
                Messaging.SendEmailResult[] results= Messaging.SendEmail(allmsg);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }*/
    
    //Updates Patent Family Status based on IP Right Status
    public static void updateFamilyStatus(List<Case> insertUpdateIpRight){
        
        set<String> addFamilyVal= new set<String>();
        Id ipRightRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IP Right').getRecordTypeId();
        List<Case> insertUpdateCase=[Select Id, Status,IP_Status__c, IP_Right_Status__c, IP_Patent_Family__c, IP_Patent_Family__r.Id,
                                     IP_Patent_Family__r.IP_Family_Status__c, RecordtypeId, Recordtype.Name
                                     from Case Where ID IN: insertUpdateIpRight AND IP_Patent_Family__c != null AND RecordtypeId =:ipRightRecTypeId];
        for(Case cs:insertUpdateCase)
        {
            addFamilyVal.add(cs.IP_Patent_Family__r.Id);
        }
        Map<String, List<Case>> addIPRightMap= new Map<String, List<Case>>();
        for(Case cs:[Select Id, Status,IP_Status__c, IP_Right_Status__c, IP_Patent_Family__c, IP_Patent_Family__r.Id,IP_Patent_Family__r.IP_Family_Status__c 
                     from Case Where IP_Patent_Family__r.Id IN:addFamilyVal])
        {
            if (addIPRightMap.containsKey(cs.IP_Patent_Family__r.Id)) {
                addIPRightMap.get(cs.IP_Patent_Family__r.Id).add(cs);
            }
            else {
                addIPRightMap.put(cs.IP_Patent_Family__r.Id, new List<Case>{cs});
            }
        }
        
        Map<Id, String> familyMap = new Map<Id, String>();
        if(addIPRightMap.size() > 0){
            for (String str:addIPRightMap.keyset())
            {
                integer intVal = addIPRightMap.get(str).size();
                integer countOfIpRightNotFiled= 0;
                integer countOfIpRightLapsed= 0;
                for(Case cs:addIPRightMap.get(str))
                {
                    if(cs.IP_Right_Status__c == 'In Force'){
                        familyMap.put(cs.IP_Patent_Family__c, cs.IP_Right_Status__c);
                    }else if(cs.IP_Right_Status__c == 'Pending' && familyMap.get(cs.IP_Patent_Family__c) != 'In Force'){
                        familyMap.put(cs.IP_Patent_Family__c, cs.IP_Right_Status__c);
                    }else if(cs.IP_Right_Status__c == 'Not Filed' && (familyMap.get(cs.IP_Patent_Family__c) != 'In Force' || familyMap.get(cs.IP_Patent_Family__c) != 'Pending')){
                        countOfIpRightNotFiled = countOfIpRightNotFiled +1;
                    }else if(cs.IP_Right_Status__c == 'Lapsed' && (familyMap.get(cs.IP_Patent_Family__c) != 'In Force' || familyMap.get(cs.IP_Patent_Family__c) != 'Pending')){
                        countOfIpRightLapsed = countOfIpRightLapsed + 1;
                    }
                    if(countOfIpRightNotFiled == intVal || countOfIpRightLapsed == intVal)
                        familyMap.put(cs.IP_Patent_Family__c, cs.IP_Right_Status__c);
                } 
            }
        }
        List<Case> updateFamilyList = new List<Case>();
        
        if(familyMap.size() > 0)
        {
            for(Case cs:[Select Id, IP_Family_Status__c from Case Where ID IN:familyMap.keySet()])
            {
                cs.IP_Family_Status__c = familyMap.get(cs.Id);
                updateFamilyList.add(cs);
            }
            try {
                Database.update(updateFamilyList, false);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
}