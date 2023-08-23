/*******************************************************************************************************
* 
* @ Name    :   IFv2_RequestTrigger
* @ Purpose :   To Send email notification for eSignature and Special Frieght and to make rejection comments mandatory.
* @ Author  :   Kanchan
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   28-10-2018      |  Kachan.baghle@absyz.com      |  1.0          |  Initial Version
*   12-03-2019      |  vivek.kothalanka@absyz.com   |  2.0          |  Add logic for APM workflows, to send callout
*   15-03-2019      |  pradeep.chary@absyz.com      |  2.1          |  Trigger SAP callout on SCAN record creation/updation
*   08-04-2019      |  pradeep.chary@absyz.com      |  2.2          |  Removed SCAN logic from IFv2_Request__c object
*   25-07-2019      |  vivek.kothalanka@absyz.com   |  2.3          |  Add logic to allow admin to cancel the request
*********************************************************************************************************************/

trigger IFv2_RequestTrigger on IFv2_Request__c(after update, before update, before delete) {
    
    //parameter used to prevent trigger from being called from atFuture method
    boolean calledFromAtFuture = false; 
    Boolean dontExecuteTrigger = false;// for time being 
    public final static List<String> list_ICO6CompanyCodes = Label.CLIFv20340.split(',');
    
    if(trigger.isAfter && Trigger.isupdate) {
        set<id>userId = new set<id>();
        id recId ;
        for(IFv2_Request__c req: trigger.new){
            if(req.ConcessionErrorResponse__c!=null && req.Workflow__c == 'Concession' && req.ConcessionErrorResponse__c!=system.trigger.oldMap.get(req.Id).ConcessionErrorResponse__c){
                //Send email to the appropriate template
                system.debug('++control is inside++');
                userId.add(req.ownerId);
                recId = req.id;
                // chatterUserIdSET.addall(userId);
                IFv2_sendNotificationEmail.sendConcessionerrorAlert(userId,recId);
                
            }
            
        }
        
        /* Code for giving access to approver while approver is changed */
        List<IFv2_Request__c> ApproverChangedRequests=new List<IFv2_Request__c>();
        System.debug('Entering trigger');
        for(IFv2_Request__c request: Trigger.New)
        {
            if(Trigger.oldmap.get(request.id).Status__c=='Submitted' && request.Status__c=='Submitted')
            {
                ApproverChangedRequests.add(request);
            }
        }
        if(ApproverChangedRequests.size()>0)
        {
            IFv2_TriggerHandler.recordShareForUpdatedApprover(ApproverChangedRequests,trigger.newmap,trigger.oldmap);
        }
        /*For creating MGP child request on parent approve - Start*/        
        LIST<IFv2_Request__c> mgpReqLIST = new LIST<IFv2_Request__c>();
        for (IFv2_Request__c request: Trigger.New) {
            if(request.Workflow__c == Label.CLIFv20199 && request.Status__c == 'Approved' && Trigger.oldMap.get(request.Id).Status__c != request.Status__c && request.ChallanTypeofGatePass__c == 'Returnable')
                mgpReqLIST.add(request);
        }
        if(!mgpReqLIST.isEmpty()){
            IFv2_TriggerHandler.createMGPChild(mgpReqLIST);
        }
        /*For creating MGP child request on parent approve - End*/
        /*Start  -  Code block for Sending Notification Email on Approval or Rejection (Anoop)*/
        list < IFv2_Request__c > notifyApprovedRequestList = new list < IFv2_Request__c > ();
        list < IFv2_Request__c > notifyRejectedRequestList = new list < IFv2_Request__c > ();
        list < IFv2_Request__c > notifySubmittedRequestList = new list < IFv2_Request__c > ();
        
        /* Start of Iteration 3, Added list to send request Ids*/
        LIST<Id> requestIdList = new LIST<Id>();
        List<String> requestIdsForConcessionInterface = new List<String>();
        /* END of Iteration 3 addition */
        //Idea
        list < ID > requestIdeaList = new list < ID > ();
        //Idea End
        
        for (IFv2_Request__c request: Trigger.New) {
            if (Trigger.oldMap.get(request.Id).Status__c != request.Status__c && request.Status__c != 'Draft') {
                /* ITERATION 3 - START added one more field */
                if (request.Status__c == 'Approved')  {
                    notifyApprovedRequestList.add(request);
                } else if (request.Status__c == 'Rejected')  {
                    notifyRejectedRequestList.add(request);
                    /*ITERATION 3 - END*/
                } 
                if(request.Status__c == 'Approved' && request.Workflow__c == label.CLIFv20049) {
                    notifySubmittedRequestList.add(request);
                }
            }
            String workflowCustomLabel = System.Label.CLIFv20255;
            LIST<String> workflow_List = new LIST<String>();     // worklfows for which you want to give cancel permission to Admin.
            
            if(!String.isBlank(workflowCustomLabel)){
                workflow_List.addAll(workflowCustomLabel.split(','));
            }
            // logic to allow admin to update request status to canceled
            if((request.Workflow__c != null &&  request.OldRequest__c == NULL && workflow_List.contains(request.Workflow__c)) && (Trigger.oldMAP.get(request.Id).Status__c != 'Approved' && Trigger.oldMAP.get(request.Id).Status__c != 'Rejected' &&  request.Status__c == 'Cancelled')) {
                
                //Get ProcessInstance Items
                Map<ID,ProcessInstance> piMap = New Map<ID,ProcessInstance>([Select Id from ProcessInstance 
                                                                             where TargetObjectId=:request.Id]); 
                for(ProcessInstanceWorkItem pp : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :piMap.keySet()]){
                    
                    // if there's a work item, set the action to 'removed' and execute
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setAction('Removed');
                    req2.setWorkitemId(pp.Id);
                    Approval.ProcessResult processResult = Approval.process(req2, true);
                }
            }
            
            
            /* Addition for Iteration 3, to send rquest Ids to handler */
            if ((request.Workflow__c != null &&  request.OldRequest__c == NULL && (request.Workflow__c.containsIgnoreCase(system.label.CLIFv20136))) && ((Trigger.oldMAP.get(request.Id).Status__c == 'Submitted' && request.Status__c == 'Approved') || (Trigger.oldMAP.get(request.Id).Status__c == 'Submitted' && request.Status__c == 'Rejected') ||(Trigger.oldMAP.get(request.Id).Status__c == 'Submitted' && request.Status__c == 'Cancelled'))) {
                requestIdList.add(request.Id);
            }
            /* End of Iteartion 3 changes */
            
            if(calledFromAtFuture == false) {
                
                if(request.Status__c == 'Approved' && request.Workflow__c == 'Concession' &&  request.OldRequest__c == NULL && Trigger.OldMap.get(request.Id).Status__c != 'Approved') {
                    
                    requestIdsForConcessionInterface.add(request.Id);
                }
                String partnerMissing = 'Enter a partner';
                String isArchivedString = 'Y';
                if (request.Account__r.IFv2_SAPUPDATERESULT__c != null && request.Status__c == 'Approved') {
                    if(request.Status__c == 'Approved'  
                       && String.valueOf(request.Account__r.IFv2_SAPUPDATERESULT__c).contains(partnerMissing)) {
                           if (!String.isBlank(request.ArchivalStatus__c)) {
                               if (request.ArchivalStatus__c.equalsIgnoreCase('Archived')) {
                                   request.addError('Please check if applicant is a valid NT user on SAP and check if supplier and/ or customer are also valid.');
                               }        
                           } 
                           
                       }  
                }
            }
            //Idea
            
            if ((request.Workflow__c != null &&  (request.Workflow__c == 'My Idea')) && ((Trigger.oldMAP.get(request.Id).Status__c == 'Submitted' && request.Status__c == 'Approved') || (Trigger.oldMAP.get(request.Id).Status__c == 'Submitted' && request.Status__c == 'Rejected'))) {
                requestIdeaList.add(request.id);
            }
            
            //Idea End
        }
        
        if(!requestIdsForConcessionInterface.isEmpty() && System.isFuture() == false) {
            try {
                Map<String, String> headers = new Map<String, String>();
                
                //Authentication
                String username = Label.SAP_User.split(';')[0];
                String password = Label.SAP_User.split(';')[1];
                Blob headerValue = Blob.valueOf(username+':'+password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                headers.put('KeyId', Label.SAP_Key_Id);
                headers.put('Authorization', authorizationHeader);
                system.debug('before callout handler');
                IFv2_ConcessionWorkflowHandler.createNotificationWrapper(requestIdsForConcessionInterface, headers);
            } catch (exception e) {
                System.debug(e.getMessage());
                system.debug(e.getStackTraceString());
                calledFromAtFuture = true;
            }
        }
        /*//Idea
if(!requestIdeaList.isEmpty()) {
IFv2_TriggerHandler.ideaStatusUpdate(requestIdeaList);
}
//Idea End*/
        
        /* Start of Iteartion 3 changes, to call handler if size of list is greater that 0 */
        if(!requestIdList.isEmpty()) {
            IFv2_SAPCalloutHandler.soapUpdateSapStatus(requestIdList);
        }
        /* End of Iteartion 3 changes */
        if (!notifyApprovedRequestList.isEmpty())
            IFv2_TriggerHandler.sendEmailNotification(notifyApprovedRequestList, 'Approved');
        if (!notifyRejectedRequestList.isEmpty())
            IFv2_TriggerHandler.sendEmailNotification(notifyRejectedRequestList, 'Rejected');
        if (!notifySubmittedRequestList.isEmpty())
            IFv2_TriggerHandler.sendEmailNotification_Submit(notifySubmittedRequestList);
        /*End    -  Code block for Sending Notification Email on Approval or Rejection (Anoop)*/
        
        
        
    }
    
    if(trigger.isBefore && Trigger.isupdate) {
        Map < Id, IFv2_Request__c > rejectedStatements = new Map < Id, IFv2_Request__c > {};
            //Added by Nirmal from Marlabs
            List<IFv2_Request__c> failedConcessionRequests = new List <IFv2_Request__c>();
        set<id>userId = new set<id>();
        List<IFv2_Request__Share> reqsharelist = new List<IFv2_Request__Share>();
        id recId ;
        set<id> chatterUserIdSET = new set<id>();
        
        for(IFv2_Request__c req: trigger.new){
            if(req.ConcessionErrorResponse__c!=null && req.Workflow__c == 'Concession' && req.ConcessionErrorResponse__c!=system.trigger.oldMap.get(req.Id).ConcessionErrorResponse__c){
                //Send email to the appropriate template
                system.debug('++control is inside++');
                userId.add(req.ownerId);
                recId = req.id;
                chatterUserIdSET.addall(userId);
                //  IFv2_sendNotificationEmail.sendConcessionerrorAlert(userId,recId);
                
            }
            
        }
        
        
        
        for (IFv2_Request__c inv: trigger.new) {
            //Get the old object record, and check if the approval status 
            //field has been updated to rejected. If so, put it in a map 
            //so we only have to use 1 SOQL query to do all checks.
            if (inv.Status__c == 'Rejected' && System.Trigger.oldMap.get(inv.Id).Status__c != 'Rejected') {
                rejectedStatements.put(inv.Id, inv);
            }
            IFv2_request__c oldRequest = Trigger.oldMap.get(inv.Id);
            
            if(inv.Status__c == 'Draft' && inv.MaterialNo__c != oldRequest.MaterialNo__c) {
                inv.AreAllMaterialsValidated__c = false;
            }
        }
        
        if(!rejectedStatements.isEmpty()) {
            List < Id > processInstanceIds = new List < Id > {};
                for (IFv2_Request__c invs: [SELECT(SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                                            FROM IFv2_Request__c
                                            WHERE ID IN: rejectedStatements.keySet()
                                           ]) {
                                               processInstanceIds.add(invs.ProcessInstances[0].Id);
                                           }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments.  
            for (ProcessInstance pi: [SELECT TargetObjectId,
                                      (SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1)
                                      FROM ProcessInstance
                                      WHERE Id IN: processInstanceIds
                                      ORDER BY CreatedDate DESC
                                     ]) {
                                         if ((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0)) {
                                             rejectedStatements.get(pi.TargetObjectId).addError(Label.CLIFv20026);
                                         }
                                     }
        }
    }
    
    
    if(trigger.isBefore && Trigger.isupdate)
    {  
        list<IFv2_Request__c> requestList = new list<IFv2_Request__c>();
        
        //added for Vendor master validation _040423
        /*for(IFv2_Request__c  req : trigger.new){
System.debug('req.IFv2_Postal_code__c-->'+req.IFv2_Postal_code__c);
System.debug('Trigger.oldmap-->'+Trigger.oldmap.get(req.id).IFv2_Postal_code__c);
if(req.IFv2_Postal_code__c != null && Trigger.oldmap.get(req.id).IFv2_Postal_code__c != req.IFv2_Postal_code__c){
System.debug('Trigger in Postal Vendor');
IFv2_TriggerHandler.postalCodeValidations(Trigger.new);
}

if(req.IFv2_VAT_TAX_nr__c != null && Trigger.oldmap.get(req.id).IFv2_VAT_TAX_nr__c != req.IFv2_VAT_TAX_nr__c){
System.debug('Trigger in vatValidations');
IFv2_TriggerHandler.vatValidations(Trigger.new);
}

if(req.IFv2_IBAN__c != null && Trigger.oldmap.get(req.id).IFv2_IBAN__c != req.IFv2_IBAN__c){
System.debug('Trigger in IBAN Vendor');
IFv2_TriggerHandler.ibanValidations(Trigger.new);
}

if(req.IFv2_Bank_Key__c != null && Trigger.oldmap.get(req.id).IFv2_Bank_Key__c != req.IFv2_Bank_Key__c){
System.debug('Trigger in IBAN Vendor');
IFv2_TriggerHandler.bankKeyValidations(Trigger.new);
}

if(req.IFv2_Other_TAX_nr_GST_Steuer__c != null && Trigger.oldmap.get(req.id).IFv2_Other_TAX_nr_GST_Steuer__c != req.IFv2_Other_TAX_nr_GST_Steuer__c){
System.debug('Trigger in Other Tax Vendor');
IFv2_TriggerHandler.otherTaxValidations(Trigger.new);
}


}*/
        //added for Vendor master validation_040423
        
        for(IFv2_Request__c  reqObject : trigger.new)
        {   
            
            /*String workflowNameLabel = System.Label.IFv2_WorkflowName;
            List<String> workflowNameLabels = new List<String>();
            workflowNameLabels = workflowNameLabel.split(',');*/
            
            String draftStatus = System.Label.CLIFv20140;
            
            
            //Filering for only Germany ICO requests in Draft Status
            //Filering for only ICO requests in Draft Status for Germany,France,Hungary and Spain
            if(reqObject.Workflow__c == System.Label.CLIFv20250 && reqObject.Status__c == draftStatus && list_ICO6CompanyCodes.contains(reqObject.CompanyCode__c))
            {
                requestList.add(reqObject);
            } 
            else if((reqObject.Workflow__c == System.Label.IFv2_VendorPUOrganizationExtension || reqObject.Workflow__c == System.Label.IFv2_VendorPUUnBlockandDeletionFlag)  && reqObject.Status__c == draftStatus) {
                if(reqObject.IFv2_VAT_TAX_nr__c != null && Trigger.oldmap.get(reqObject.id).IFv2_VAT_TAX_nr__c != reqObject.IFv2_VAT_TAX_nr__c){
                    System.debug('Trigger in vatValidations');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_VAT_TAX_nr__c');
                }
            }
            else if(reqObject.Workflow__c == System.Label.IFv2_WorkflowName && reqObject.Status__c == draftStatus) {
                if(reqObject.IFv2_Postal_code__c != null && Trigger.oldmap.get(reqObject.id).IFv2_Postal_code__c != reqObject.IFv2_Postal_code__c){
                    System.debug('Trigger in Postal Vendor');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_Postal_code__c');
                }
                
                if(reqObject.Company_Code_Department__c != null & Trigger.oldmap.get(reqObject.Id).Company_Code_Department__c != reqObject.Company_Code_Department__c || reqObject.Purchase_Organization_Office__c != null & Trigger.oldmap.get(reqObject.Id).Purchase_Organization_Office__c != reqObject.Purchase_Organization_Office__c || reqObject.Material_Field__c != null & Trigger.oldmap.get(reqObject.Id).Material_Field__c != reqObject.Material_Field__c) {
                    //IFv2_TriggerHandler.vendorMappingUpdates(Trigger.new);
                }
                
                if(reqObject.IFv2_VAT_TAX_nr__c != null && Trigger.oldmap.get(reqObject.id).IFv2_VAT_TAX_nr__c != reqObject.IFv2_VAT_TAX_nr__c){
                    System.debug('Trigger in vatValidations');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_VAT_TAX_nr__c');
                }
                
                if(reqObject.IFv2_IBAN__c != null && Trigger.oldmap.get(reqObject.id).IFv2_IBAN__c != reqObject.IFv2_IBAN__c){
                    System.debug('Trigger in IBAN Vendor');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_IBAN__c');
                }
                
                if(reqObject.IFv2_Bank_Key__c != null && Trigger.oldmap.get(reqObject.id).IFv2_Bank_Key__c != reqObject.IFv2_Bank_Key__c){
                    System.debug('Trigger in IBAN Vendor');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_Bank_Key__c');
                }
                if(reqObject.IFv2_Bank_Account__c != null && Trigger.oldmap.get(reqObject.id).IFv2_Bank_Account__c != reqObject.IFv2_Bank_Account__c){
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_Bank_Account__c');
                }
                
                if(reqObject.IFv2_Other_TAX_nr_GST_Steuer__c != null && Trigger.oldmap.get(reqObject.id).IFv2_Other_TAX_nr_GST_Steuer__c != reqObject.IFv2_Other_TAX_nr_GST_Steuer__c){
                    System.debug('Trigger in Other Tax Vendor');
                    IFv2_TriggerHandler.countryBasedValidations(Trigger.new, 'IFv2_Other_TAX_nr_GST_Steuer__c');
                }
                
            }
        }
        
        if(requestList.size() > 0)
            IFv2_TriggerHandler.checkApproverLevel(requestList);
        
    }
    
    
    if(trigger.isBefore && Trigger.isDelete) {
        /*For deleting extension and related records whie deleting a request record*/        
        if(!Trigger.Old.isEmpty()){
            IFv2_TriggerHandler.deleteRelatedRecords(Trigger.OldMap);
        }
    }
}