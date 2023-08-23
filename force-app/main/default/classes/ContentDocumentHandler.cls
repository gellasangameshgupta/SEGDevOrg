public class ContentDocumentHandler{
    ContentDocumentContoller controller = new ContentDocumentContoller();
    public void OnBeforeDelete(List<ContentDocument> ContentDocumentList){
        system.debug('inside contentDocumentHandler before delete--'+ContentDocumentList);
        if(ContentDocumentList.size()>0){
            //controller.restrictContentDocumentDeletion(ContentDocumentList);
            controller.subtractFileCount(ContentDocumentList);
        }
    }
    
    public void checkParentstatus(List<ContentDocument> ContentDocumentList)
    {
        system.debug('inside handler method');
        system.debug('ContentDocumentList '+ContentDocumentList);
        set<id> cdIdset = new set<id>();
        set<id> requestIdset = new set<id>();
        List<id> requestIdListupdate = new List<id>();
        map<id,string> errorMap = new map<id,string>();
        map<id,id> cdclMap = new map<id,id>();
        list<ProcessInstanceWorkitem> piList = new list<ProcessInstanceWorkitem>();
        list<IFv2_Request__c> updateReqList = new list<IFv2_Request__c>();
        for(ContentDocument cdObj : ContentDocumentList)
        {
            cdIdset.add(cdObj.id);
        }
        system.debug('cdIdset = '+cdIdset);
        list<ContentDocumentLink>cdlinkList = [SELECT id, ContentDocumentID, LinkedEntity.type, LinkedEntityId 
                                               FROM ContentDocumentLink 
                                               WHERE ContentDocumentID IN: cdIdset];
        system.debug('cdlinkList '+cdlinkList);
        if(!cdlinkList.isEmpty())
        {system.debug('not empty 1');
         for(ContentDocumentLink clObj : cdlinkList)
         {
             if(clObj.LinkedEntity.type == 'ifv2_request__c')
             {
                 requestIdset.add(clObj.LinkedEntityId);
                 cdclMap.put(clObj.LinkedEntityId,clObj.ContentDocumentId);   
             }
             
         }
         List<Ifv2_request__c> reqList = [select id, status__c,Workflow__c from ifv2_request__c where id IN:requestIdset];
         if(!reqList.isEmpty())
         {system.debug('not empty 2');
          for(Ifv2_request__c reqObj : reqList)
          {
              system.debug('reqObj.Workflow__c = '+reqObj.Workflow__c);
              system.debug('Approval.isLocked(reqObj.id) '+Approval.isLocked(reqObj.id));
              if(Approval.isLocked(reqObj.id)&& reqObj.Workflow__c == 'Design Verification Process Approval')
              {system.debug('locked');
               //reqObj.Status__c = 'Draft';
               updateReqList.add(reqObj);
               requestIdListupdate.add(reqObj.id);
              }
              /*else if(reqObj.status__c == 'Approved')
{
errorMap.put(cdclMap.get(reqObj.id),'Error'); 
}*/
          }  
         }
         if(!requestIdListupdate.isEmpty())
         {system.debug('requestIdListupdate not empty'+requestIdListupdate);
          piList = [Select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN:requestIdListupdate];
         }
        }
        
        /* for(ContentDocument cdObj : ContentDocumentList)
{
if(errorMap.get(cdObj.id) == 'Error')
{
system.debug('pidichu mone');
cdObj.addError('Cannot modify or insert new attachments after the request is approved');
}

}*/
        if(!updateReqList.isEmpty())
        {system.debug('updateReqList not empty');
         //update updateReqList;system.debug('updated !!!!!!!!');
         /* for(IFv2_Request__c reqObj : updateReqList)
{
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
req.setComments('Restarting approval process because the attachments were modified');        
req.setObjectId(reqObj.id);
Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
req2.setComments('mRequest.');
req2.setAction('Reject');
// Submit the approval request for the request        
Approval.ProcessResult result = Approval.process(req); system.debug('process restarted'); 
}*/
         List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>();
         List<Approval.ProcessSubmitRequest> allReqSubmit = new List<Approval.ProcessSubmitRequest>();
         if(!piList.isEmpty())
         {set<id>pinstanceId = new set<id>();
          system.debug('piList '+piList);
          for (ProcessInstanceWorkitem piObj:piList){
              system.debug('pinstanceId  '+pinstanceId);
              system.debug('piObj.ProcessInstanceId ='+piObj.ProcessInstanceId);
              system.debug('pinstanceId.contains(piObj.ProcessInstanceId)'+pinstanceId.contains(piObj.ProcessInstanceId));
              if(!pinstanceId.contains(piObj.ProcessInstanceId))
              {
                  system.debug('inside loop');
                  Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                  Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                  req2.setComments('attachments were modified');
                  req2.setAction('Reject');
                  system.debug('req2 '+req2);
                  req2.setWorkitemId(piObj.id);
                  req1.setObjectId(piObj.ProcessInstance.TargetObjectId);
                  req1.setComments('Restarting approval process because the attachments were modified');
                  // Add the request for approval
                  allReq.add(req2);system.debug('allReq '+allReq);
                  allReqSubmit.add(req1);
                  pinstanceId.add(piObj.ProcessInstanceId);
              }
              
          }
          Approval.ProcessResult[] result2 =  Approval.process(allReq);system.debug('result2 '+result2);
          Approval.ProcessResult[] result1 =  Approval.process(allReqSubmit);
          
          
         }
         else
         {system.debug('inside else');
          for(IFv2_Request__c reqObj : updateReqList)
          {
              Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
              req.setComments('Restarting approval process because the attachments were modified');        
              req.setObjectId(reqObj.id);  
              allReqSubmit.add(req);
              
          }
          Approval.ProcessResult[] result1 =  Approval.process(allReqSubmit); system.debug('process restarted');
         }
         
        }
        
    }
    
    /*public void OnBeforeUpdate(List<ContentDocument> ContentDocumentList){
if(ContentDocumentList.size()>0){
controller.restrictContentDocumentUpdation(ContentDocumentList);
}
}*/
}