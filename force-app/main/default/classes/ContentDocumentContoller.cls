public class ContentDocumentContoller{
    public void subtractFileCount(List<ContentDocument> ContentDocumentList){
        
        /*Start of IFE Logic*/
        system.debug('start of ife');
        system.debug('get trigger::'+ContentDocumentList);
        Set<Id> docSet = new Set<Id>();
        for(ContentDocument cd: ContentDocumentList){
                docSet.add(cd.id);
        }
        System.Debug('SetOfCd' +docSet);
        List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:docSet];
        system.debug('cdlist size--'+cdlList.size());  
        system.debug('cdlList----'+cdlList);
        
        List<IFv2_Request__c> ifeList = new List<IFv2_Request__c>();
        Map<Id,List<Id>> cdlReqMap = new Map<Id,List<Id>>();
        for(ContentDocumentLink cdl : cdlList) {
            if(cdl.LinkedEntityId.getSobjectType() == IFv2_Request__c.SobjectType){
                if(cdlReqMap.containsKey(cdl.LinkedEntityId)){
                    List<Id> cdlIdList= cdlReqMap.get(cdl.LinkedEntityId);
                    cdlIdList.add(cdl.Id);
                    cdlReqMap.put(cdl.LinkedEntityId,cdlIdList);
                }
                else{
                    cdlReqMap.put(cdl.LinkedEntityId,new List<Id> { cdl.Id });
                }
            }
        }
        System.debug('print cdlMap::'+cdlReqMap);
        
        List<IFv2_Request__c> reqList= [Select Id,Name,Workflow__c,FileCount__c from IFv2_Request__c where Id IN :cdlReqMap.keySet()];
        system.debug('print request::'+reqList);
        List<IFv2_Request__c> reqUpdList = new List<IFv2_Request__c>();
        for(IFv2_Request__c req : reqList){
            if(req.Workflow__c == label.CLIFv20301){
                if(cdlReqMap.containsKey(req.Id)){
                    System.debug('get current value::'+req.FileCount__c);
                    System.debug('get size value::'+cdlReqMap.get(req.Id).size());
                    Decimal i = req.FileCount__c - cdlReqMap.get(req.Id).size();
                    req.FileCount__c = i;
                    reqUpdList.add(req);
                    System.debug('print request new::'+reqUpdList);
                }
            }
        }
        if(!reqUpdList.isEmpty()){
            System.debug('print update::'+reqUpdList);
            update reqUpdList;
        }
        /*End of IFE Logic*/
    }
    /*public void restrictContentDocumentDeletion(List<ContentDocument> ContentDocumentList){
        system.debug('inside contentDocument deletion'+ContentDocumentList.size());
        System.Debug('ContentDocumentList' +ContentDocumentList);
        Set<Id> SetOfReq = new Set<Id>();
        Set<Id> SetOfReqAPAC = new Set<Id>();
        Set<Id> SetOfReqEMEA = new Set<Id>();
        Set<Id> SetOfReqNALA = new Set<Id>();
        Set<Id> SetOfCd = new Set<Id>();
        string cdlentityId;
        if(!ContentDocumentList.isEmpty() || ContentDocumentList!= null){
            for(ContentDocument conDocList: ContentDocumentList){
                system.debug('inside CDL--'+conDocList);
                SetOfCd.add(conDocList.id);
            }
        }
        System.Debug('SetOfCd' +SetOfCd);
        List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:SetOfCd];
        system.debug('cdlist size--'+cdlList.size());  
        system.debug('cdlList----'+cdlList);
        for(ContentDocumentLink cdl: cdlList){
            System.Debug('Enter For loop');
            if(String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0J'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0A'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0B'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0D')
                cdlentityId = cdl.LinkedEntityId;
            
        }
        //if the linked entity is request object
        if (cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0J') {
            SetOfReq.add(cdlentityId);  
            system.Debug('cdlentityId1' + cdlentityId);
            List<WF_Request__c> reqRecList = [Select id, Status__c from WF_Request__c where id =:SetOfReq];
            System.Debug('reqRecList' +reqRecList.size());
            for(WF_Request__c wfReq: reqRecList){
                if(wfReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be deleted only for Draft Requests');
                    }       
                }
            }       
        }
        //if the linked entity is request apac
        else if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0A'){
            SetOfReqAPAC.add(cdlentityId); 
            List<Request_APAC__c> reqAPACList = [Select id, Status__c from Request_APAC__c where id =:SetOfReqAPAC];
            System.Debug('reqAPACList' +reqAPACList.size());
            for(Request_APAC__c apacReq: reqAPACList){
                if(apacReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be deleted only for  Draft Request APAC');
                    }       
                }
            }           
        }
        
        //if the linked entity is request EMEA
        else if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0B'){
            system.debug('inside req emea');
            system.debug('cdlentityId---'+cdlentityId);
            SetOfReqEMEA.add(cdlentityId); 
            List<Request_EMEA__c> reqEMEAList = [Select id, Status__c from Request_EMEA__c where id =:SetOfReqEMEA];
            system.debug('reqEMEAList'+reqEMEAList);
            system.debug('reqEMEAList'+reqEMEAList[0].Status__c);
            System.Debug('reqEMEAList' +reqEMEAList.size());
            for(Request_EMEA__c emeaReq: reqEMEAList){
                if(emeaReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be deleted only for  Draft Request EMEA');
                    }       
                }
            }           
        }
        //if the linked entity is request NALA
        else if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0D'){
            SetOfReqNALA.add(cdlentityId); 
            List<Request_NALA__c> reqNALAList = [Select id, Status__c from Request_NALA__c where id =:SetOfReqNALA];
            System.Debug('reqNALAList' +reqNALAList.size());
            for(Request_NALA__c nalaReq: reqNALAList){
                if(nalaReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be deleted only for  Draft Request NALA');
                    }       
                }
            }           
        }
        
        
    }*/
    
    
    /*public void restrictContentDocumentUpdation(List<ContentDocument> ContentDocumentList){
        Set<Id> SetOfReq = new Set<Id>();
        Set<Id> SetOfReqAPAC = new Set<Id>();
        Set<Id> SetOfReqEMEA = new Set<Id>();
        Set<Id> SetOfReqNALA = new Set<Id>();
        Set<Id> SetOfCd = new Set<Id>();
        string cdlentityId;
        if(!ContentDocumentList.isEmpty() || ContentDocumentList!= null){
            for(ContentDocument conDocList: ContentDocumentList){
                SetOfCd.add(conDocList.id);
            }
        }
        System.Debug('SetOfCd' +SetOfCd);
        List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:SetOfCd];
        for(ContentDocumentLink cdl: cdlList){
            if(String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0J'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0A'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0B'||String.valueOf(cdl.LinkedEntityId).substring(0,3)=='a0D')
                cdlentityId = cdl.LinkedEntityId;
        }
        //if the linked entity is request object
        if (cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0J') {
            SetOfReq.add(cdlentityId);  
            List<WF_Request__c> reqRecList = [Select id, Status__c from WF_Request__c where id =:SetOfReq];
            System.Debug('reqRecList' +reqRecList.size());
            for(WF_Request__c wfReq: reqRecList){
                if(wfReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be updated only for Draft Requests');
                    }       
                }
            }       
        }
        //if the linked entity is request apac
        if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0A'){
            SetOfReqAPAC.add(cdlentityId); 
            List<Request_APAC__c> reqAPACList = [Select id, Status__c from Request_APAC__c where id =:SetOfReqAPAC];
            System.Debug('reqAPACList' +reqAPACList.size());
            for(Request_APAC__c apacReq: reqAPACList){
                if(apacReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be updated only for  Draft Request APAC');
                    }       
                }
            }           
        }
        //if the linked entity is request EMEA
        if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0B'){
            system.debug('inside aob');
            SetOfReqEMEA.add(cdlentityId); 
            List<Request_EMEA__c> reqEMEAList = [Select id, Status__c from Request_EMEA__c where id =:SetOfReqEMEA];
            System.Debug('reqEMEAList' +reqEMEAList.size());
            for(Request_EMEA__c emeaReq: reqEMEAList){
                system.debug('inside 1st loop before if');
                if(emeaReq.status__c != 'Draft'){
                    system.debug('inside 1st loop after if');
                    for(ContentDocument conList: ContentDocumentList){
                        system.debug('inside 2nd for loop');
                        system.debug('conlist.size---'+conList.contentversions);
                        system.debug('conlist.size---'+conList.contentversions.size());
                        
                        // if(conList.contentversions.size()>0){
                        conList.adderror('Attachment can be updated only for  Draft Request EMEA');
                        //  }
                    }       
                }
            }           
        }
        //if the linked entity is request NALA
        else if(cdlentityId!=null&&cdlentityId.substring(0,3) == 'a0D'){
            SetOfReqNALA.add(cdlentityId); 
            List<Request_NALA__c> reqNALAList = [Select id, Status__c from Request_NALA__c where id =:SetOfReqNALA];
            System.Debug('reqNALAList' +reqNALAList.size());
            for(Request_NALA__c nalaReq: reqNALAList){
                if(nalaReq.status__c != 'Draft'){
                    for(ContentDocument conList: ContentDocumentList){
                        conList.adderror('Attachment can be updated only for  Draft Request NALA');
                    }       
                }
            }           
        }
        
        
        
    }*/
}