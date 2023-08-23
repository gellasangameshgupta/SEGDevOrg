/**
* @Name: APTS_AgreementTriggerHelper
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: TriggerHelper for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/
public class APTS_AgreementTriggerHelper{
    public static void activateFullySignedAgreement(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        System.debug('Came Into Agreement Trigger Helper');
        Map<Id, ContentVersion> agmtSignedDocs = new Map<Id, ContentVersion>() ;
        Map<id,id> contDocIdMap = new Map<Id,Id>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        Map<Id,ContentVersion> signedAtmts = new Map<Id,ContentVersion>();
        if (newList != null && newList.size()==1){        
            Set<Id> agmtIds = new Set<Id>();
            for(Apttus__APTS_Agreement__c agmt: newList)
                if (agmt.Apttus__Status__c == APTS_Constants.AGMT_STATUS_FULLY_SIGNED && oldMap.get(agmt.Id).Apttus__Status__c != agmt.Apttus__Status__c &&
                    agmt.APTS_Type_of_Signature__c == APTS_Constants.AGMT_TYPE_OF_SIGNATURE)
                agmtIds.add(agmt.Id);
            System.debug('agmtIds-'+agmtIds);
            //Querying the Fully Sogned agreement attahments 
            if(!agmtIds.isEmpty()){             
                //cdlList = [select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:agmtIds];
                cdlList = [select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:agmtIds order by SystemModstamp  DESC];
                for(ContentDocumentLink cdLink : cdlList){
                    contDocIdMap.put(cdLink.ContentDocumentId,cdLink.LinkedEntityId);
                    System.debug('Content Document Id:' + cdLink.ContentDocumentId);
                }
                System.debug('contDocIdMap: ' + contDocIdMap);
                System.debug('Fully Signed Agreement Attachments Found:'+!contDocIdMap.isEmpty());
                ContentVersion signedAtmt;
                if(!contDocIdMap.isEmpty()){
                    String attName = '';
                    //for(ContentVersion cv : [select id,VersionData,ContentDocumentId,Title, ReasonForChange from ContentVersion where ContentDocumentId IN:contDocIdMap.keySet() order by SystemModstamp  DESC]){
                    for(ContentVersion cv : [select id,VersionData,ContentDocumentId,Title from ContentVersion where ContentDocumentId IN:contDocIdMap.keySet()and ReasonForChange ='Final Signed' order by SystemModstamp]){
                        System.debug('Fully Signed Agreement doc found with reason final signed');
                        attName = cv.Title.toLowerCase();
                        //if((attName).contains(APTS_Constants.AGMT_SIGNED_DOC_KEY)){
                        signedAtmt = new ContentVersion();
                        agmtSignedDocs.put(contDocIdMap.get(cv.ContentDocumentId),cv);
                        signedAtmt.VersionData = cv.VersionData;
                        signedAtmt.PathOnClient = cv.Title+'.PDF';
                        signedAtmts.put(cv.ContentDocumentId,signedAtmt);
                        //}
                    }
                }
            }
            System.debug('agmtSignedDocs-'+agmtSignedDocs);
            if(!agmtSignedDocs.isEmpty()){
                try{
                    for(Apttus__APTS_Agreement__c agmt: newList){
                        //If the agreement has Signed documnt calling Activate and publish to repositary API's
                        if(agmtSignedDocs.containsKey(agmt.Id)){
                            Id attmtId = agmtSignedDocs.get(agmt.Id).ContentDocumentId;
                            List<Id> selectedDocIds = new List<Id> ();
                            List<Id> removableDocIds = new List<Id> ();
                            selectedDocIds.add(attmtId);
                            if(!Test.isRunningTest()){
                                Boolean res = Apttus.AgreementWebService.activateAgreement(agmt.Id, selectedDocIds, removableDocIds);
                                system.debug('Activation Result:' + res);
                                if(res){
                                    //Boolean publishRes = Apttus.AgreementWebService.publishToDocumentRepository(agmt.Id, attmtId);
                                    Boolean publishRes = Apttus.AgreementWebService.publishToChatterRepository(agmt.Id, attmtId);
                                    if(!publishRes)
                                        agmt.addError('Publishing documents to chatter failed');
                                }else
                                    agmt.addError('Agreement Activation failed');
                            }
                        }
                    }
                    
                    //Creating signed docuemnts back to agreement attachments because after activation signed copies are getting deleted from attachments
                    
                    insert signedAtmts.values();
                    System.debug('  '+agmtSignedDocs);
                    List<ContentDocumentLink> contDocLinks = new List<ContentDocumentLink>();
                    ContentDocumentLink contDocLink = null;
                    Map<id,ContentVersion> cvMap = new Map<Id,ContentVersion>([select id,ContentDocumentId from ContentVersion where Id IN:signedAtmts.values()]);
                    for(Id cd : signedAtmts.keySet()){
                        contDocLink = new ContentDocumentLink();
                        contDocLink.ShareType ='V';
                        contDocLink.LinkedEntityId = contDocIdMap.get(cd);
                        contDocLink.ContentDocumentId = cvMap.get(signedAtmts.get(cd).Id).ContentDocumentId;
                        contDocLinks.add(contDocLink);
                    }
                    
                    insert contDocLinks;
                }catch(Exception ex){
                    System.debug(ex.getMessage()+ex.getCause()+ex.getLineNumber());
                }
            }
        }
    }
    
    public static void AgreementActive(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        for(Apttus__APTS_Agreement__c agr :newList){
            system.debug('record pushed>>>'+agr);
            if(agr.Apttus__Status__c == 'Activated' && oldMap.get(agr.Id).Apttus__Status__c != agr.Apttus__Status__c){
                //if(!system.isBatch()){
                //APTS_IntegrationController.submitRequest(agr.Id);
                System.enqueueJob(new APTS_IntegrationController(agr.Id));
                //}
            }
        }
    }
    
    public static void AgreementDocFormatInsert(List<Apttus__APTS_Agreement__c> newList){
        if(newList.size()>0){
           // update newList;
        }
    }
    
    public static void AgreementDocFormatUpdate(List<Apttus__APTS_Agreement__c> newList){
        Agreement_Process_Flow_Setting__mdt[] threatMappings = [SELECT DeveloperName,Agreement_Process_Flow_Short_Name__c,AgreementOutputFormats__c,Agreement_Record_Type__c,Agreement_Process_Flow__c FROM Agreement_Process_Flow_Setting__mdt];
        if(threatMappings.size()>0 && threatMappings != null){
            Map<string,string> processFlowMap = new Map<String, String>();
            for(Agreement_Process_Flow_Setting__mdt apfs:threatMappings){
                if(apfs != null && apfs.Agreement_Process_Flow_Short_Name__c != null)
                    processFlowMap.put(apfs.Agreement_Process_Flow_Short_Name__c,apfs.AgreementOutputFormats__c);
            }
            for(Apttus__APTS_Agreement__c agr :newList){
                if(processFlowMap.size()>0 && processFlowMap != null && agr.APTS_Process_Flow__c != null){
                    agr.Apttus__AllowableOutputFormats__c = processFlowMap.get(agr.APTS_Process_Flow__c); 
                }
            }
        }
    }
    
    //Set Term (Years) to 10 and Agreement End Date = Agreement Start Date + 10 yrs
    public static void SetAgreementEndDate(List<Apttus__APTS_Agreement__c> newList){
        map<Id, Apttus__APTS_Agreement__c> newMap = new map<Id, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c a:newList)
        {
            newMap.put(a.Apttus__Account__c , a);
        }

        Map<ID, Schema.RecordTypeInfo> recTypeMap = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();

        Map<Id,Account> accList = new Map<Id,Account> ([SELECT Id, Name FROM Account WHERE Id IN :newMap.keyset()]);
        for(Apttus__APTS_Agreement__c apts :newMap.values() ){
            
            String recTypeName = recTypeMap.get(apts.RecordTypeId).getName();
            apts.Name = recTypeName;
            if(apts.Apttus__Account__c!=null)
            {
                apts.Name = apts.Name+'--' + accList.get(apts.Apttus__Account__c).Name;
            }
            if(apts.Apttus__Contract_Start_Date__c!=NULL)
            {
                    apts.Name = apts.Name+'--' +apts.Apttus__Contract_Start_Date__c.month() + '-' + apts.Apttus__Contract_Start_Date__c.day() + '-' + apts.Apttus__Contract_Start_Date__c.year();
            }
            /* if((apts.Name=='Corporate Agreement' || apts.Name=='NDA') && apts.Apttus__Contract_Start_Date__c!=NULL && apts.Apttus__Account__c!=null)
             {
                 //apts.Name = apts.Name+'--' + accList.get(apts.Apttus__Account__c).Name+'--'+apts.Apttus__Contract_Start_Date__c.date();
                 apts.Name = apts.Name+'--' + accList.get(apts.Apttus__Account__c).Name+'--'+apts.Apttus__Contract_Start_Date__c.month() + '-' + apts.Apttus__Contract_Start_Date__c.day() + '-' + apts.Apttus__Contract_Start_Date__c.year();
                 system.debug(accList.get(apts.Apttus__Account__c).Name);
                 system.debug(apts.Name);
             }*/
        }
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();
        for(Apttus__APTS_Agreement__c agree : newList) {
            //system.debug('Record Type Name: ' + rtMap.get(agree.RecordTypeId).getName());
            if(rtMap.get(agree.RecordTypeId)!=null && rtMap.get(agree.RecordTypeId).getName()=='Corporate Agreement')
            {
                agree.Apttus__Perpetual__c= True;
            }        
        }
    }
    public static void setApprovalStatus(List<Apttus__APTS_Agreement__c> newList){
        for(Apttus__APTS_Agreement__c a:newList)
        {
            /*if(a.APTS_WarrantyPeriod__c<24 && a.Apttus_Approval__Approval_Status__c == 'Not Submitted'){
                a.Apttus_Approval__Approval_Status__c = 'Approval Required';
                a.Apttus__Status_Category__c = 'In Authoring';
                a.Apttus__Status__c = 'Author Contract';
            }*/
            system.debug('Agreement Status:' + a.Apttus__Status__c);
            //if(a.Apttus_Approval__Approval_Status__c == 'Approved' && a.Apttus__Status__c !='Fully Signed'){
            if(a.Apttus_Approval__Approval_Status__c == 'Approved'){
                /*a.Apttus__Status_Category__c = 'In Signatures';
                a.Apttus__Status__c = 'Ready for Signatures';*/
                //a.Apttus__Status_Category__c = 'In Authoring';
                //a.Apttus__Status__c = 'Author Contract';oa
                if(newList.size()==1){
                    List<Apttus__MergeEvent__c> lstMergeEvent = [select id, Apttus__Action__c, Apttus__DocumentInfo__c from Apttus__MergeEvent__c where Apttus__AgreementId__c=:newList[0].ID ];
                    for (Apttus__MergeEvent__c obj:lstMergeEvent){
                        if(obj.Apttus__Action__c=='Check In' && obj.Apttus__DocumentInfo__c=='Final' && a.APTS_Final_Checked_In__c == False){
                            a.Apttus__Status_Category__c = 'In Signatures';
                            a.Apttus__Status__c = 'Ready for Signatures';
                            a.APTS_Final_Checked_In__c = True;
                            break;
                        }
                        else{
                            //a.Apttus__Status_Category__c = 'In Authoring';
                            //a.Apttus__Status__c = 'Author Contract';
                        }
                    }
                }
            }
        }        
    }
}