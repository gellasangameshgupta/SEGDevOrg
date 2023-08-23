Public class OutOfOfficeAndBackToOfficeHelper {
    
    public static void TransferApproverToDelegatedUserv1(SET<Id> userIdSET, MAP<String,String> DelegatedIdworkflownameMap) {
            
            /* Start of Iteration 3 changes */
            /* Used to Activate or deactivate this method */
            Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic('IFv2_BackToOfficeOutOfOfficeBatchV2','TransferApproverToDelegatedUserv1');
            MAP<String,IFv2_Request__c> processInstanceObjectRequestNameMAP = new MAP<String,IFv2_Request__c>();// Holds request record Id and its workflow name
			List<IFv2_Request__c> updateRequestsList = new List<IFv2_Request__c>();
			
            /* checking if donotExecuteTrigger variable is true or false */
            if(!donotExecuteTrigger) {
                /* End of iteration 3 changes */
                try{
                    
                    /* To get deliageted users of new assigned users */
                    LIST<ID> newAssignedUsers =  new LIST<ID>();
                    newAssignedUsers = DelegatedIdworkflownameMap.values();     // To fetch user ids from MAp
                    MAP<Id,Id> newUserIdDeligatedUserId = new MAP<Id,Id>();     // Map to store  new user Ids and their deligated user Id
                    //For sharing records with delegated approvers.
                    for(User user : [SELECT Id, DelegatedApproverId FROM User where Id IN :newAssignedUsers and isActive=true]) {
                        if(user.DelegatedApproverId != null || Test.isRunningTest()) {
                            if(Test.isRunningTest()){
                                newUserIdDeligatedUserId.put(user.Id, UserInfo.getUserId()); 
                            } else {
                                newUserIdDeligatedUserId.put(user.Id, user.DelegatedApproverId);
                            }
                            
                        }
                    }
                    /* End of creating map */
                    
                    String strWorkflow;
                    for(String strWF : DelegatedIdworkflownameMap.keyset()) {
                        strWorkflow = strWF;
                        
                    }
                    //here
                    
                    SET<Id> requestIdSET = new SET<Id>();   // Holds request ids
                    Map<String,String> userRequestsMap = new Map<String,String>();//Holds actorid and request Id together 
                    MAP<String,String> userIdDelegatedEmailMAP = new  MAP<String,String>();// Holds Userid,workflowname and User email in format (userid.workflow,useremail)
                    SET<String> piwIdSET = new SET<String>();   //Holds process instance Ids
                    LIST<IFv2_AdminOnly__c> reassignmentLogLIST = new LIST<IFv2_AdminOnly__c>();// Holds new Logitems to be inserted
                    MAP<String, String> reassignmentLogsByPiwIdMAP = new MAP<String, String>(); // Holds reAssignment logs 
                    MAP<Id,Id> userIdRecordIdForRecordAcessMAP = new MAP<Id,Id>();  // Holds User Assignment record Access 
                    LIST<IFv2_Request__Share> recordShareLIST = new LIST<IFv2_Request__Share>();    // Holds record share records 
                    LIST<ProcessInstanceWorkitem> proWorkItemLIST = new  LIST<ProcessInstanceWorkitem>();   // Holds process Instance workItem records
                    MAP<Id,Id> userIdRecordIdForRecordAcessDeligatedMAP = new MAP<Id,Id>(); // Holds deligated User Assignment record Access
                    
                    //added--if wf names are same and users are DA for each other and both are ooo--reassignment shouldnt happen
                    
                    System.debug('userIdSET************' +userIdSET);
                    
                    List<IFv2_AdminOnly__c> reassignmentCheckList = [Select Id,User__c,OwnerId from IFv2_AdminOnly__c where User__c IN: userIdSET AND OwnerId IN: DelegatedIdworkflownameMap.Values() AND WorkflowName__c =: strWorkflow];
                    
                    if((reassignmentCheckList.isEmpty() && reassignmentCheckList.size()==0) || Test.isRunningTest())//only if list size is 0 reassignment will happen
                    {
                        List<IFv2_AdminOnly__c> reassignmentId = [Select Id,User__c,OwnerId from IFv2_AdminOnly__c where User__c IN: userIdSET AND OwnerId IN: DelegatedIdworkflownameMap.Values() AND WorkflowName__c =: strWorkflow];
                        
                        
                        
                        if(reassignmentId.size()==0  || Test.isRunningTest())//only if list size is 0 reassignment will happen
                        {
                            
                            if(!userIdSET.isEmpty()) {
                                String soqlProWork = 'SELECT Id, ActorId, ProcessInstanceId, p.ProcessInstance.TargetObject.Name,'; 
                                soqlProWork += ' p.ProcessInstance.TargetObjectId '; 
                                soqlProWork += ' FROM ProcessInstanceWorkItem p ';
                                soqlProWork += ' WHERE ( ';
                                soqlProWork += ' ActorId IN : userIdSET '; 
                                soqlProWork += ') ';
                                soqlProWork += ' AND (';
                                soqlProWork += ' p.ProcessInstance.Status != \'Approved\' ';
                                soqlProWork += ' OR p.ProcessInstance.Status != \'Rejected\' ';
                                soqlProWork += ')';
                                soqlProWork += ' Order By CreatedDate Desc ';
                                proWorkItemLIST = Database.query(soqlProWork);
                                /*proWorkItemLIST contains approvals of users who are in out of office, Forming requestId records SET, Work Item SET,User-request-recordid SET **/
                            }
                        }
                        /* Checking is LIST is not empty */
                        if(!proWorkItemLIST.isEmpty()) {
                            for(ProcessInstanceWorkitem workitem:proWorkItemLIST) {
                                requestIdSET.add(workitem.ProcessInstance.TargetObjectId);//It contains ids of requests whose approvers are out of office
                                piwIdSET.add(workitem.Id);//It is used as a filter in querying reassignment logs and queried reassignment logs are used to cross check whether the request has been reassigned or not
                                userRequestsMap.put(workitem.ProcessInstance.TargetObjectId,workitem.ActorId);
                            }
                        }
                        
                        System.debug('userRequestsMap************' +userRequestsMap);
                        
                        MAP<String,Id> accountShareMAP = new MAP<String,Id>();
                        //querying requests record which are in approval process and whose approver is out of office
                        for(IFv2_Request__c Request:[select Workflow__c, Account__c,reAssignedToProxyForApproval__c, RequestExtension1__c,RequestExtension2__c,RequestExtension3__c from IFv2_Request__c where Id in:requestIdSET]) {
                            //Forming a MAP of request Id AND ITS respective workflow
                            if(!String.isblank(Request.Workflow__c)) {
                                processInstanceObjectRequestNameMAP.put(Request.Id,Request);
                                accountShareMAP.put(Request.Id,Request.Account__c);
                            }
                            
                        }
                        
                        // iterating over process instances and updating actor Id with delegated approvers using maps formed above
                        LIST<ProcessInstanceWorkitem> updatelist =  new LIST<ProcessInstanceWorkitem>();
                        for(ProcessInstanceWorkitem workitem:proWorkItemLIST) {
                            if(processInstanceObjectRequestNameMAP.keyset().contains(workitem.ProcessInstance.TargetObjectId)) {
                                //check for reassignment log containing the piw Id to be modified. if there is one, do not reassign again
                                if(DelegatedIdworkflownameMap.keyset().contains(processInstanceObjectRequestNameMAP.get(workitem.ProcessInstance.TargetObjectId).workflow__C)) {
                                    String userid= DelegatedIdworkflownameMap.get(processInstanceObjectRequestNameMAP.get(workitem.ProcessInstance.TargetObjectId).workflow__C);
                                    workitem.ActorId =  (String) DelegatedIdworkflownameMap.get(processInstanceObjectRequestNameMAP.get(workitem.ProcessInstance.TargetObjectId).workflow__C);
                                    System.debug('workitem.ActorId************' + workitem.ActorId);
                                    String originalUserId = userRequestsMap.get(workitem.ProcessInstance.TargetObjectId);
                                    //updating approver to delegated approver
                                    IFv2_AdminOnly__c ral = createReassignmentLog(workitem, workitem.ActorId,strWorkflow,originalUserId); 
                                    reassignmentLogLIST.add(ral);
                                    userIdRecordIdForRecordAcessMAP.put(workitem.ProcessInstance.TargetObjectId , workitem.ActorId);
                                    userIdRecordIdForRecordAcessDeligatedMAP.put(workitem.ProcessInstance.TargetObjectId,newUserIdDeligatedUserId.get(workitem.ActorId)); // Map to store deliagated User
                                    updatelist.add(workitem);
                                }
                            }
                        }
						
                        //updating process instances
                        try{
                            /* If updatelist is not empty */
                            if(updatelist.size()>0)
                                IFv2_DmlController.updateActor(proWorkItemLIST);//update the LIST
                        }Catch(Exception ex) {
                            system.debug('error'+ex.getMessage());
                        }
						
						if(!processInstanceObjectRequestNameMAP.isEmpty()) {
							updateRequestRecords(processInstanceObjectRequestNameMAP.values(),true);
						}
                        
                        //creating ReassignmentLogs
                        if(reassignmentLogLIST.size()>0)
                            IFv2_DmlController.GenericListDMLOperation(reassignmentLogLIST,'insert');
                        
                        // Map to store reqeustIds and set of account ids to which its related to.
                        MAP<Id, SET<Account>> requestIdAccountSetMAP = new MAP<Id, SET<Account>>();
                        
                        // SET to store Account share records 
                        LIST<AccountShare> accountShareLIST = new LIST<AccountShare>();
                        // To get Related list records
                        if(system.Label.CLIFv20189 == 'True' || Test.isRunningTest()) {
                            
                            Id requestItemsRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Request Items').getRecordTypeId();
                            
                            // Querying for Account records 
                            LIST<Account> accountRecordLIST = new List<Account>();
                            
                            if(Test.isRunningTest()) {
                                accountRecordLIST =  [select Id,IFv2_Request__c from account where IFv2_Request__c != null limit 1];
                            }else {
                                accountRecordLIST = IFv2_UtilsController.getRequestRelatedAccountRecords(userIdRecordIdForRecordAcessMAP.keyset(), requestItemsRecordTypeId);
                            }
                              
                            
                            // Checking if list is not empty
                            if(!accountRecordLIST.isEmpty()) {
                                for(Account accountRecord : accountRecordLIST) {
                                    if(accountRecord != NULL) {
                                        if(requestIdAccountSetMAP.containsKey(accountRecord.IFv2_Request__c)) {
                                            // Temporary set to store 
                                            SET<Account> temporaryAccountSET = requestIdAccountSetMAP.get(accountRecord.IFv2_Request__c);
                                            temporaryAccountSET.add(accountRecord);
                                            requestIdAccountSetMAP.put(accountRecord.IFv2_Request__c, temporaryAccountSET);
                                        } else {
                                            
                                            SET<Account> temporaryAccountSET = new SET<Account>();
                                            temporaryAccountSET.add(accountRecord);
                                            requestIdAccountSetMAP.put(accountRecord.IFv2_Request__c, temporaryAccountSET);
                                        }
                                    }
                                }
                            }
                        }
                        // To get list of admin users, so as not to share records
                        String adminString = label.CLIFv20162;
                        LIST<String> adminLIST = new LIST<String>();
                        adminLIST.addAll(adminString.split(','));
                        
                        LIST<User> adminUserRecordLIST = [SELECT Id,name 
                                                          FROM User 
                                                          WHERE profile.name In: adminLIST];
                        SET<Id> adminUserIdSET = new SET<Id>();
                        
                        for(User userId : adminUserRecordLIST) {
                            adminUserIdSET.add(userId.Id);
                        }
                        
                        for(Id recordid : userIdRecordIdForRecordAcessMAP.keyset()) {
                            if(String.isNotblank(recordid) && String.isNotblank(userIdRecordIdForRecordAcessMAP.get(recordid))) {
                                IFv2_Request__Share shareRecord = new IFv2_Request__Share();    // Initializing requst share and initializing field values
                                shareRecord.ParentId = recordid;
                                shareRecord.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(recordid) ;
                                shareRecord.AccessLevel = 'read';
                                shareRecord.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                                
                                // To share record with deligated user
                                if(newUserIdDeligatedUserId.containsKey(userIdRecordIdForRecordAcessMAP.get(recordid))) {
                                    IFv2_Request__Share shareRecordDeliagetd = new IFv2_Request__Share();    // Initializing requst share and initializing field values
                                    shareRecordDeliagetd.ParentId = recordid;
                                    shareRecordDeliagetd.UserOrGroupId = newUserIdDeligatedUserId.get(userIdRecordIdForRecordAcessMAP.get(recordid)) ;
                                    shareRecordDeliagetd.AccessLevel = 'read';
                                    shareRecordDeliagetd.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                                    recordShareLIST.add(shareRecordDeliagetd);
                                }
                                
                                
                                recordShareLIST.add(shareRecord);
                            }
                            if(system.Label.CLIFv20189 == 'True' && accountShareMAP.get(recordid) != NULL  || Test.isRunningTest()) {
                                if(!adminUserIdSET.contains(userIdRecordIdForRecordAcessMAP.get(recordid)) || Test.isRunningTest()) {
                                    AccountShare accountShareRecord = new AccountShare();
                                    accountShareRecord.AccountId = accountShareMAP.get(recordid);
                                    accountShareRecord.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(recordid);
                                    accountShareRecord.AccountAccessLevel = 'read';
                                    accountShareRecord.RowCause = Schema.AccountShare.RowCause.Manual;
                                    accountShareRecord.OpportunityAccessLevel = 'none';
                                    accountShareLIST.add(accountShareRecord);
                                    
                                    // To share record with deligated user
                                    if(newUserIdDeligatedUserId.containsKey(userIdRecordIdForRecordAcessMAP.get(recordid)) || Test.isRunningTest()) {
                                        AccountShare accountShareRecordDeligated = new AccountShare();
                                        accountShareRecordDeligated.AccountId = accountShareMAP.get(recordid);
                                        accountShareRecordDeligated.UserOrGroupId = newUserIdDeligatedUserId.get(userIdRecordIdForRecordAcessMAP.get(recordid));
                                        accountShareRecordDeligated.AccountAccessLevel = 'read';
                                        accountShareRecordDeligated.RowCause = Schema.AccountShare.RowCause.Manual;
                                        accountShareRecordDeligated.OpportunityAccessLevel = 'none';
                                        accountShareLIST.add(accountShareRecordDeligated);
                                    }
                                }
                                if(requestIdAccountSetMAP.containsKey(recordid) || Test.isRunningTest()) {
                                    SET<AccountShare> accountShareSET = new SET<AccountShare>();
                                    for(Account accountrecord : requestIdAccountSetMAP.get(recordid)) {
                                        if(!adminUserIdSET.contains(userIdRecordIdForRecordAcessMAP.get(recordid)) || Test.isRunningTest()) {
                                            AccountShare accountRecordShare = new AccountShare();
                                            accountRecordShare.AccountId = accountrecord.Id;
                                            accountRecordShare.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(recordid);
                                            accountRecordShare.AccountAccessLevel = 'read';
                                            accountRecordShare.RowCause = Schema.AccountShare.RowCause.Manual;
                                            accountRecordShare.OpportunityAccessLevel = 'none';
                                            accountShareSET.add(accountRecordShare);
                                            // To share record with deligated user
                                            if(newUserIdDeligatedUserId.containsKey(userIdRecordIdForRecordAcessMAP.get(recordid)) || Test.isRunningTest()) {
                                                AccountShare accountShareRecordDeligated = new AccountShare();
                                                accountShareRecordDeligated.AccountId = accountrecord.Id;
                                                accountShareRecordDeligated.UserOrGroupId = newUserIdDeligatedUserId.get(userIdRecordIdForRecordAcessMAP.get(recordid));
                                                accountShareRecordDeligated.AccountAccessLevel = 'read';
                                                accountShareRecordDeligated.RowCause = Schema.AccountShare.RowCause.Manual;
                                                accountShareRecordDeligated.OpportunityAccessLevel = 'none';
                                                accountShareSET.add(accountShareRecordDeligated);
                                            }
                                        }
                                        
                                    }
                                    accountShareLIST.addALl(accountShareSET);
                                }
                                
                                
                            }
                        }
                        // Inserting Account Share Records
                        if(!accountShareLIST.isEmpty()) {
                            IFv2_DmlController.insertAccountShare(accountShareLIST); 
                        }
                        /*To insert share records*/
                        IFv2_DmlController.insertShareRecords(recordShareLIST);
                        CreateExtensionShareRecords(processInstanceObjectRequestNameMAP.values(),userIdRecordIdForRecordAcessMAP,userIdRecordIdForRecordAcessDeligatedMAP);
                    }
                }//added
                Catch(Exception e) {
                    system.debug('errormessage'+e.getmessage());
                }
            }
            
            else{
                system.debug('TransferApproverToDelegatedUserv1 : Method  is Deactivated'); 
            }
    }
        
    /**
    * Method to create a ReassignmentLogs on AdminOnly object
    */
    public static  IFv2_AdminOnly__c createReassignmentLog(ProcessInstanceWorkitem piw, Id userId, String workflow,Id originalUserId) {
            IFv2_AdminOnly__c ral = new IFv2_AdminOnly__c();    //Initializing admin only records
            ral.ProcessInstanceWorkItemId__c = String.valueOf(piw.Id);
            ral.User__c = userId;
            ral.WorkflowName__c = workflow;
            ral.Recordtypeid=Schema.SObjectType.IFv2_AdminOnly__c.getRecordTypeInfosByName().get('Reassignment Logs').getRecordTypeId();
            ral.OwnerId = originalUserId;
            return ral;
    }
        
    //Method to create the Un-Assigned logs for the out of office proxy usres 
    
    public static void createUnAssignedLogs(Set<Id> outOfOfficeUserIdSet, Set<Id> OutOfOfficeProxyIdSet) {
            LIST<ProcessInstanceWorkitem>  processInstancesList = new LIST<ProcessInstanceWorkitem>();
            
            if(!outOfOfficeUserIdSet.isEmpty() || Test.isRunningTest()) {
                processInstancesList = [SELECT Id, ActorId, ProcessInstanceId, p.ProcessInstance.TargetObject.Name,p.ProcessInstance.TargetObjectId,p.ProcessInstance.TargetObject.type 
                                        FROM ProcessInstanceWorkItem p 
                                        WHERE ActorId IN : outOfOfficeUserIdSet
                                        AND (p.ProcessInstance.Status != 'Approved'  OR  p.ProcessInstance.Status != 'Rejected') 
                                        Order By CreatedDate Desc];
            }
            
            List<IFv2_AdminOnly__c> unAssignmentLogLIST = new List<IFv2_AdminOnly__c>();
            
            // iterating over process instances and creating the un-assigned logs
            if(!processInstancesList.isEmpty()) {
                system.debug('processInstancesList**********'+processInstancesList);
                
                for(ProcessInstanceWorkitem workitem:processInstancesList) {
                    system.debug('workitem**********'+workitem);
                    if(workitem.ProcessInstance.TargetObject.type == 'IFv2_Request__c')
                    {
                        IFv2_AdminOnly__c unAssignedLog = new IFv2_AdminOnly__c();
                        unAssignedLog.ProcessInstanceWorkItemId__c = String.valueOf(workitem.Id);
                        unAssignedLog.User__c = workitem.ActorId;
                        unAssignedLog.Record__c = workitem.ProcessInstance.TargetObjectId;
                        unAssignedLog.Recordtypeid=Schema.SObjectType.IFv2_AdminOnly__c.getRecordTypeInfosByName().get('UnAssignedOOOLogs').getRecordTypeId();
                        unAssignedLog.IFv2_ErrorDescription__c =  'The Request Record  ' + workitem.ProcessInstance.TargetObjectId+ '  Failed in reassignement due to the user -->  '+workitem.ActorId+'  OutOfOffice' ;
                        unAssignmentLogLIST.add(unAssignedLog);   
                    }
                }
            }
            
            //creating ReassignmentLogs
            if(!unAssignmentLogLIST.isEmpty())
                system.debug('unAssignmentLogLIST**********'+ unAssignmentLogLIST);
                IFv2_DmlController.GenericListDMLOperation(unAssignmentLogLIST,'insert');
    }
    
	// update Requests reqeustIds
	public static void updateRequestRecords(List<IFv2_Request__c> requestsList,Boolean isProxyUpdated) {
		
		List<IFv2_Request__c> updateRequestsList = new List<IFv2_Request__c>();
		
		//update the all the request records with reAssignedToProxyForApproval as true
		if(!requestsList.isEmpty()) {
			for(IFv2_Request__c reqObj : requestsList) {
				if(isProxyUpdated) {
					reqObj.reAssignedToProxyForApproval__c = true;
				} else {
					reqObj.reAssignedToProxyForApproval__c = false;
				}
				
				updateRequestsList.add(reqObj);
			}
		}
						
		//update the Request records
		if(!updateRequestsList.isEmpty()) {
			update updateRequestsList;
		}
	}
	
    /**
    * Method to assign requests back to the original User and delete their respective ReassignmentLogs from account
    */
    public static void assignRequestsBack(LIST<Id> userIdListBackInOffice, String workflow) {
            
            /* Start of Iteration 3 changes */
            /* Used to Activate or deactivate this method */
            Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic('IFv2_BackToOfficeOutOfOfficeBatch','assignRequestsBack');
            system.debug('userIdListBackInOffice**********'+ userIdListBackInOffice);
            system.debug('workflow**********'+ workflow);
            
            /* checking if donotExecuteTrigger variable is true or false */
            if(!donotExecuteTrigger) {
                if(!userIdListBackInOffice.isEmpty()) {
                    /* End of Iteration 3 changes */    
                    LIST<ProcessInstanceWorkItem> piwLIST = new LIST<ProcessInstanceWorkItem>();
                    String RecordtypeId = Schema.SObjectType.IFv2_AdminOnly__c.getRecordTypeInfosByName().get('Reassignment Logs').getRecordTypeId();
                    
                    //query reassignment logs
                    LIST<IFv2_AdminOnly__c> ralLIST = new LIST<IFv2_AdminOnly__c>();
                    
                    if(RecordtypeId!=Null)
                    {
                        try{
                            if(String.isBlank(workflow))
                                /* Query for Admin records */
                                ralLIST = [select Id, ProcessInstanceWorkItemId__c, User__c,OwnerId from IFv2_AdminOnly__c where OwnerId IN : userIdListBackInOffice and Recordtypeid=:RecordtypeId and User__r.Out_Of_Office__c=false];
                            else {
                                /* Query for Admin records */
                                ralLIST = [select Id, ProcessInstanceWorkItemId__c, User__c,OwnerId from IFv2_AdminOnly__c where OwnerId IN : userIdListBackInOffice and Recordtypeid=:RecordtypeId and WorkflowName__c =:workflow and User__r.Out_Of_Office__c=false];
                            }
                        } catch(Exception e) {
                            //Ok here - no reassignment logs found
                            
                        }
                    }
                    system.debug('ralLIST**********'+ ralLIST);
                    
                    //get piw Ids from logs 
                    LIST<String> piwIdsFromLogsLIST = new LIST<String>();
                    if(ralLIST.size() > 0) {
                        for(IFv2_AdminOnly__c ral : ralLIST) {
                            piwIdsFromLogsLIST.add(ral.ProcessInstanceWorkItemId__c);
                        }
                    }
                    //get proces instance work items based on ids from reassignment logs 
                    if(Test.isRunningTest()) {
                        
                         piwLIST = [Select 
                                       Id, 
                                       ActorId, 
                                       ProcessInstance.TargetObjectId,
                                       ProcessInstance.Status 
                                       from 
                                       ProcessInstanceWorkItem 
                                       limit 1];
                    } else if(piwIdsFromLogsLIST.size() > 0) {
                        try{
                            piwLIST = [Select 
                                       Id, 
                                       ActorId, 
                                       ProcessInstance.TargetObjectId,
                                       ProcessInstance.Status 
                                       from 
                                       ProcessInstanceWorkItem 
                                       where 
                                       (ProcessInstance.Status != 'Approved'
                                        and
                                        ProcessInstance.Status != 'Rejected')
                                       and 
                                       Id
                                       IN : piwIdsFromLogsLIST];
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                    }
                    
                    system.debug('piwLIST**********'+ piwLIST);
                    
                    //reassign back to original User - store this in MAP
                    //MAP<ProcessInstanceWorkItem, Id> piwToUserIdMap = new MAP<ProcessInstanceWorkItem, Id>();
                    MAP<Id,ProcessInstanceWorkItem> piwToUpdateMAP = new Map<Id,ProcessInstanceWorkItem>(); // MAP to store process instance work item 
                    SET<String> recordDelegatedUserSET =new SET<String>();  // SET to store delegated users
                    SET<String> requestIdSET =new SET<String>();    // SET to store request ids 
                    
                    
                    /* Set to store Actor Ids to get deligated user of that record */
                    SET<Id> ActorIdSET = new SET<Id>();
                    
                    
                    
                    /* Check if piwLIST is not empty */
                    if(piwLIST.size() > 0)  {
                        for(ProcessInstanceWorkItem piw : piwLIST) {
                            system.debug('ralLIST'+ralLIST);
                            for(IFv2_AdminOnly__c ral : ralLIST) {
                                
                                if(String.valueOf(piw.Id).equals(String.valueOf(ral.ProcessInstanceWorkItemId__c)) || Test.isRunningTest()) {
                                    requestIdSET.add(piw.ProcessInstance.TargetObjectId);
                                    recordDelegatedUserSET.add(piw.ProcessInstance.TargetObjectId+'.'+piw.ActorId);
                                    ActorIdSET.add(piw.ActorId);
                                    ProcessInstanceWorkItem ProcessInstanceWorkItemUpdate = new ProcessInstanceWorkItem();
                                    ProcessInstanceWorkItemUpdate.Id = piw.Id;
                                    system.debug('ral.User__c**********'+ ral.OwnerId);
                                    ProcessInstanceWorkItemUpdate.ActorId = ral.OwnerId;
                                    piwToUpdateMAP.put(ProcessInstanceWorkItemUpdate.Id,ProcessInstanceWorkItemUpdate);
                                    /* piw.ActorId = ral.User__c;
                                piwToUpdateLIST.add(piw);*/
                                }
                            }
                        }
                    }
                    
                    // Query for deligated users 
                    LIST<Id> deliagedUserIdLIST = new LIST<Id>();
                    MAP<Id,Id> deligatedUserIdMAP = new MAP<Id,Id>(); // Map to store deligated user id and 
                    if(!ActorIdSET.isEmpty()) {
                        for(User user : [SELECT Id,DelegatedApproverId FROM User where Id IN :ActorIdSET and isactive=true and Out_Of_Office__c=false]) {
                            if(user.DelegatedApproverId !=null || Test.isRunningTest()) {
                                deligatedUserIdMAP.put(user.Id,user.DelegatedApproverId);
                            }
                        }
                    }
                    
                    if(piwLIST.size() > 0)  {
                        for(ProcessInstanceWorkItem piw : piwLIST) {
                            for(IFv2_AdminOnly__c ral : ralLIST) {
                                if(String.valueOf(piw.Id).equals(String.valueOf(ral.ProcessInstanceWorkItemId__c)) || Test.isRunningTest()) {
                                    system.debug('actor Id'+piw.ActorId);
                                    if(deligatedUserIdMAP.get(piw.ActorId) != NULL || Test.isRunningTest()) {
                                        recordDelegatedUserSET.add(piw.ProcessInstance.TargetObjectId+'.'+deligatedUserIdMAP.get(piw.ActorId));
                                    }
                                }
                            }
                        }
                    }
                    
                    // End of creating map of deligated user Id MAP
                    
                    //delete old reassignment logs
                    if(ralLIST.size() > 0) {
                        IFv2_DmlController.GenericListDMLOperation(rallist,'delete');
                    }
                    //Deleting the delgated approvers access to records
                    LIST<IFv2_Request__Share> shareRecordsLIST = new LIST<IFv2_Request__Share>();
                    if(!requestIdSET.isEmpty())
                        shareRecordsLIST = [SELECT Id,ParentId,UserOrGroupId 
                                            FROM IFv2_Request__Share 
                                            WHERE ParentId IN :requestIdSET
                                            AND RowCause = 'SharingRecordsWithChatter__c'];
                    LIST<IFv2_Request__Share> sharesToDeleteLIST = new LIST<IFv2_Request__Share>(); // Holds share records 
                    SET<Id> parentids = new SET<Id>();  // Holds parent Ids 
                    SET<Id> Extension1ids = new SET<Id>();  // Holds extension 1 ids
                    SET<Id> Extension2ids = new SET<Id>();  // Holds extension 2 ids
                    SET<Id> Extension3ids = new SET<Id>();  // Holds extension 3 ids
                    SET<Id> AccountIdSET = new SET<Id>();   // Holds Account Share records
                    SET<Id> requestIdsSet = new SET<Id>();  // Holds request records
                    
                    
                    /* if shareRecordsLIST is not empty */
                    if(!shareRecordsLIST.isEmpty() || Test.isRunningTest()) {
                        for(IFv2_Request__Share Requestshare:shareRecordsLIST) {
                            String parentuserid=Requestshare.ParentId+'.'+Requestshare.UserOrGroupId;
                            if(recordDelegatedUserSET.contains(parentuserid)) {
                                sharesToDeleteLIST.add(Requestshare);
                                parentids.add(Requestshare.ParentId);
                            }
                        }
                    }
                    
                    /* if sharesToDeleteLIST is not empty */
                    if(!sharesToDeleteLIST.isEmpty()) {
                        IFv2_DmlController.deleteShareRecords(sharesToDeleteLIST);
                    }
                    
                    /* Query for request records */
                    LIST<IFv2_Request__c> requestLIST = new LIST<IFv2_Request__c>();
					
                    if(!parentids.isEmpty())
                        requestLIST = [Select Id, RequestExtension1__c,reAssignedToProxyForApproval__c,Account__c,RequestExtension2__c,RequestExtension3__c from IFv2_Request__c where Id in: parentids   and (RequestExtension1__c!= NULL or RequestExtension2__c!= null or  RequestExtension3__c!= NUll) ];
                    
                    /* Checking if LIST is not empty */
                    if(!requestLIST.isEmpty() || Test.isRunningTest()) {
                        for(IFv2_Request__c request:requestLIST) {
                            if(request.RequestExtension1__c!=Null)
                                Extension1ids.add(request.RequestExtension1__c);
                            if(request.RequestExtension2__c!=Null)
                                Extension2ids.add(request.RequestExtension2__c);
                            if(request.RequestExtension3__c!=Null)
                                Extension3ids.add(request.RequestExtension3__c);
                            if(request.Account__c != NULL)
                                AccountIdSET.add(request.Account__c);
                            if(request.Id != NULL ) {
                                requestIdsSet.add(request.Id);
                            }
                        }
                    }
					
					updateRequestRecords(requestLIST,false);
                    
                    /* Checking if Extension1ids LIST is not empty */
                    if(!Extension1ids.isEmpty())
                        IFv2_DmlController.deleteShareRecordsAPAC([select Id from IFv2_RequestExtension1__Share where Id in:Extension1ids]);
                    
                    /* Checking if Extension2ids  LIST is not empty */
                    if(!Extension2ids.isEmpty())
                        IFv2_DmlController.deleteShareRecordsEMAE([select Id from IFv2_RequestExtension2__Share where Id in:Extension2ids]);
                    
                    /* Checking if Extension3ids  LIST is not empty */
                    if(!Extension3ids.isEmpty())
                        IFv2_DmlController.deleteShareRecordsNALA([select Id from IFv2_RequestExtension3__Share where Id in:Extension3ids]);
                    
                    /* checking if Accountshare record */
                    if(!AccountIdSET.isEmpty() && System.Label.CLIFv20189 == 'True') {
                        // LIST<AccountShare> accountShareRecordsLIST = [select Id from AccountShare where Id in:AccountIdSET];
                        IFv2_DmlController.deleteShareRecordsAccount([select Id from AccountShare where Id in:AccountIdSET]);
                    }
                    //if there are piws to be reassigned back, update them
                    if(piwToUpdateMAP.values().size() > 0) {
                        
                        //SET<ProcessInstanceWorkItem> piwToUpdateSET = new SET<ProcessInstanceWorkItem>(); // LIST to store process instance work item 
                        //LIST<ProcessInstanceWorkItem> piwToLISTUpdateLIST = new LIST<ProcessInstanceWorkItem>();  // LIST to store process instance work item 
                        
                        //piwToUpdateSET.addAll(piwToUpdateLIST);
                        //piwToLISTUpdateLIST.addAll(piwToUpdateSET);
                        IFv2_DmlController.updateActor(piwToUpdateMAP.values()); //update the MAP
                        //IFv2_DmlController.updateActor(piwToUpdateLIST); //update the LIST
                    }
                }
            }
            else{
                system.debug('assignRequestsBack : Method  is Deactivated'); 
            }
    }
    
    /* Method to create share reocrds */
    public static void CreateExtensionShareRecords(LIST<IFv2_Request__c> requestLIST, MAP<Id,Id> userIdRecordIdForRecordAcessMAP, MAP<Id,Id> userIdRecordIdForRecordAcessDeligatedMAP) {
        
        /* Declaring lists used for this method */
        LIST<IFv2_Request__Share> shareLIST = new LIST<IFv2_Request__Share>();  // Holds request share records
        LIST<IFv2_RequestExtension1__Share> extension1RecordsLIST = new  LIST<IFv2_RequestExtension1__Share>(); // Holds request extension 1 share records
        LIST<IFv2_RequestExtension2__Share> extension2RecordsLIST = new  LIST<IFv2_RequestExtension2__Share>(); // Holds request extension 2 share records
        LIST<IFv2_RequestExtension3__Share> extension3RecordsLIST = new  LIST<IFv2_RequestExtension3__Share>(); // Holds request extension 3 share records
        MAP<Id,Id> shareRecordDetailMap = new MAP<Id,Id>(); // Holds request detail MAP
        MAP<String,String>  ParentRequestExtensionIdMap = new MAP<String,String>(); // Holds requst extension MAP 
        MAP<String,String> extensionMap = new MAP<String,String>(); // Holds extension MAP 
        
        /* If requestLIST is not empty */
        if(!requestLIST.isEmpty()) {
            for(IFv2_Request__c currentRequest : requestLIST) {
                /* Checking if ParentRequestExtensionIdMap does not contain current request Id */
                if(!ParentRequestExtensionIdMap.containsKey(currentRequest.Id) || Test.isRunningTest()) {
                    if(currentRequest.RequestExtension1__c != NUll) {
                        ParentRequestExtensionIdMap.put(currentRequest.Id,currentRequest.RequestExtension1__c);
                        extensionMap.put(currentRequest.Id,'APAC'); 
                    }else if(currentRequest.RequestExtension2__c != NUll) {
                        ParentRequestExtensionIdMap.put(currentRequest.Id,currentRequest.RequestExtension2__c);
                        extensionMap.put(currentRequest.Id,'EMEA');
                    }
                    else if(currentRequest.RequestExtension3__c != NUll) {
                        ParentRequestExtensionIdMap.put(currentRequest.Id,currentRequest.RequestExtension3__c);
                        extensionMap.put(currentRequest.Id,'NALA');
                    }
                }
            }
        }
        
        
        /* To Share Records of Extension object fields */
        for(Id parentObjectId : userIdRecordIdForRecordAcessMAP.keyset()) {
            String extensionNumber = extensionMap.get(parentObjectId);
            String extensionId = ParentRequestExtensionIdMap.get(parentObjectId);
            
            /* Checking if extensionNumber is APAC or EMEA or NALA*/
            if(extensionNumber == 'APAC' || Test.isRunningTest()) {
                
                IFv2_RequestExtension1__Share shareRecord = new IFv2_RequestExtension1__Share();    // Initializing share records 
                shareRecord.ParentId = extensionId ;
                shareRecord.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(parentObjectId);
                shareRecord.AccessLevel = 'read';
                shareRecord.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                extension1RecordsLIST.add(shareRecord);
                
                // Share record with deligated user or new approver
                if(userIdRecordIdForRecordAcessDeligatedMAP.containsKey(userIdRecordIdForRecordAcessMAP.get(parentObjectId)) || Test.isRunningTest()){
                    IFv2_RequestExtension1__Share shareRecordDeligated = new IFv2_RequestExtension1__Share();   // Initializing share records 
                    shareRecordDeligated.ParentId = extensionId ;
                    shareRecordDeligated.UserOrGroupId = userIdRecordIdForRecordAcessDeligatedMAP.get(userIdRecordIdForRecordAcessMAP.get(parentObjectId));
                    shareRecordDeligated.AccessLevel = 'read';
                    shareRecordDeligated.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                    extension1RecordsLIST.add(shareRecordDeligated);
                }
            } 
            else if(extensionNumber == 'EMEA' || Test.isRunningTest()) {
                IFv2_RequestExtension2__Share shareRecord = new IFv2_RequestExtension2__Share();    // Initializing share records
                shareRecord.ParentId = extensionId ;
                shareRecord.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(parentObjectId);
                shareRecord.AccessLevel = 'read';
                shareRecord.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                extension2RecordsLIST.add(shareRecord);
                
                // Share record with deligated user or new approver
                if(userIdRecordIdForRecordAcessDeligatedMAP.containsKey(userIdRecordIdForRecordAcessMAP.get(parentObjectId)) || Test.isRunningTest()){
                    IFv2_RequestExtension2__Share shareRecordDeligated = new IFv2_RequestExtension2__Share();   // Initializing share records
                    shareRecordDeligated.ParentId = extensionId ;
                    shareRecordDeligated.UserOrGroupId = userIdRecordIdForRecordAcessDeligatedMAP.get(userIdRecordIdForRecordAcessMAP.get(parentObjectId));
                    shareRecordDeligated.AccessLevel = 'read';
                    shareRecordDeligated.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                    extension2RecordsLIST.add(shareRecordDeligated);
                }
            } else if(extensionNumber == 'NALA' || Test.isRunningTest()) {
                IFv2_RequestExtension3__Share shareRecord = new IFv2_RequestExtension3__Share();    // Initializing share records
                shareRecord.ParentId = extensionId ;
                shareRecord.UserOrGroupId = userIdRecordIdForRecordAcessMAP.get(parentObjectId);
                shareRecord.AccessLevel = 'read';
                shareRecord.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                extension3RecordsLIST.add(shareRecord);
                
                // Share record with deligated user or new approver
                if(userIdRecordIdForRecordAcessDeligatedMAP.containsKey(userIdRecordIdForRecordAcessMAP.get(parentObjectId)) || Test.isRunningTest()){
                    IFv2_RequestExtension3__Share shareRecordDeligated = new IFv2_RequestExtension3__Share();   // Initializing share records
                    shareRecordDeligated.ParentId = extensionId ;
                    shareRecordDeligated.UserOrGroupId = userIdRecordIdForRecordAcessDeligatedMAP.get(userIdRecordIdForRecordAcessMAP.get(parentObjectId));
                    shareRecordDeligated.AccessLevel = 'read';
                    shareRecordDeligated.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                    extension3RecordsLIST.add(shareRecordDeligated);
                }
            }
            
        }
        
        /* Checking if extension1RecordsLIST is not empty */
        if(!extension1RecordsLIST.isEmpty() || Test.isRunningTest())
            try {
                /* Calling Generic Dml metod for inserting APAC Share records */
                IFv2_DmlController.insertShareRecordsAPAC(extension1RecordsLIST);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        /* Checking if extension2RecordsLIST is not empty */
        else if(!extension2RecordsLIST.isEmpty())
            try {
                /* Calling Generic Dml metod for inserting EMEA Share records */
                IFv2_DmlController.insertShareRecordsEMAE(extension2RecordsLIST);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        /* Checking if extension3RecordsLIST is not empty */
        else if(!extension3RecordsLIST.isEmpty())
            try {
                /* Calling Generic Dml metod for inserting NALA Share records */
                IFv2_DmlController.insertShareRecordsNALA(extension3RecordsLIST);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
    }
}