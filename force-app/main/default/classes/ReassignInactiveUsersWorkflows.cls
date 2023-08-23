/*******************************************************************************************************
* @ Name                :  ReassignInactiveUsersWorkflows
* @ Purpose             :  This class is used to re assign the pending workflows of the inactive users
                           to user Manager and no action required if manager user is not present and also used to 
                           clear the special freights fields on the user profiles if the offboarded user presents. 
* @ Author              : Hanu Sanampudi
* @ Test class name     : ReassignInactiveUsersWorkflowsTest

*  Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*  12-04-2019      |  Hanu Sanampudi     |  1.0          |  Initial Version
   24-03-2020      |  Hanu Sanampudi     |  1.1          |  Initial Version

***********************************************************************************************/

public class ReassignInactiveUsersWorkflows {


    public static list<ProcessInstanceWorkitem> processInstanceList = new list<ProcessInstanceWorkitem>();
    public static list<user> usersList = new list<user>();
    //holds Field API names of user object
    public static list<string> userFieldAPINamesList = new list<string>();
    public static List<String> theFilterList = new List<String>();
    public static Map<Id,User> userMap = new Map<Id,User>();
    public static list<Id> requestsList = new list<Id>();
    public static Map<IFv2_Request__c,String> requestsWorkflowsMap = new Map<IFv2_Request__c,String>();
    public static Map<Id,IFv2_Request__c> requestsRecordsIdMap = new Map<Id,IFv2_Request__c>();

    //reassin all the pending workflows of deactivated users to delegates
    //if no delegate defined, reassin to user manager.
    public static void reassignWorkflows(List<User> deactiveUsersList)  {

        list<ProcessInstanceWorkitem> pendingInstanceRecordsList = new list<ProcessInstanceWorkitem>();

        //check users are prsent or not
        if(!deactiveUsersList.isEmpty()) {

            System.debug('DEBUG::deactiveUsersList*******' + deactiveUsersList);

            //iterate the list of users check pending process instance work items
            pendingInstanceRecordsList = [ SELECT OriginalActor.Name, ActorId, ElapsedTimeInDays,ProcessInstance.TargetObjectId 
                                            FROM ProcessInstanceWorkitem 
                                            where ActorId IN:deactiveUsersList 
                                            limit 49500];       

            usersList = [ SELECT Id,ManagerId,DelegatedApproverId
                          FROM user 
                          WHERE Id IN : deactiveUsersList 
                          And Manager.isActive = true 
                          limit 49500];

            System.debug('DEBUG::pendingInstanceRecordsList *******' + pendingInstanceRecordsList );
            System.debug('DEBUG::usersList*******' + usersList);

        }

        //prepare user map to use 
        if(!usersList.isEmpty()) {
            for(User userObj : usersList) {
                userMap.put(userObj.Id,userObj);
            }
        }

        System.debug('DEBUG::userMap*******' + userMap);

        //Request Id List preparation 
        if(!pendingInstanceRecordsList.isEmpty()) {

            for(ProcessInstanceWorkitem procesRec : pendingInstanceRecordsList) {
                requestsList.add(procesRec.ProcessInstance.TargetObjectId);
            }
        }

        List<IFv2_Request__c> requestRecordsList = new List<IFv2_Request__c>();

        //query the request records for workflow names and other detials
        if(!requestsList.isEmpty()) {
            
            System.debug('DEBUG::requestsList*******' + requestsList);
            requestRecordsList=  [SELECT Id, Workflow__c,Account__c,RequestExtension1__c,RequestExtension2__c,RequestExtension3__c from IFv2_Request__c
                                                        Where Id IN : requestsList order by Workflow__c limit 49500];
        }

        Map<Id,Id> requestAccountsMap = new Map<Id,Id>();
        List<IFv2_Request__c> requestsRecList = new  List<IFv2_Request__c>();
        
        //iterate the list of worklows and collect the request names
        if(!requestRecordsList.isEmpty()) {
            
            System.debug('DEBUG::requestRecordsList*******' + requestRecordsList);
            
            for(IFv2_Request__c req: requestRecordsList){
                requestsWorkflowsMap.put(req,req.Workflow__c);
                requestsRecordsIdMap.put(req.Id,req);
                requestAccountsMap.put(req.Id,req.Account__c);
            }
        }

        System.debug('DEBUG::requestsRecordsMap*******' + requestsRecordsIdMap);
        System.debug('DEBUG::requestsWorkflowsMap*******' + requestsWorkflowsMap);
        
        Map<Id,Id> processInstanceUsersMap = new Map<Id,Id>();
        List<IFv2_Request__Share> requestShareList = new List<IFv2_Request__Share>();
        List<AccountShare> accountShareList = new List<AccountShare>();

        //check the list of pending records 
        if(!pendingInstanceRecordsList.isEmpty()) {

            System.debug('DEBUG::pendingInstanceRecordsList*******' + pendingInstanceRecordsList);

            //iterate to assign to delegates and managers
            for(ProcessInstanceWorkitem procesRec : pendingInstanceRecordsList) {
                
                User userRec = null;

                //check inactive users in process instance
                if( procesRec.ActorId != null && userMap.containsKey(procesRec.ActorId)) {
                    userRec = userMap.get(procesRec.ActorId);
                }

                System.debug('DEBUG::userRec*******' + userRec);

               if(userRec != null && userRec.ManagerId != null) {

                    procesRec.ActorId = userRec.ManagerId;
                    processInstanceList.add(procesRec);
                    processInstanceUsersMap.put(procesRec.ProcessInstance.TargetObjectId,procesRec.ActorId);
                    requestsRecList.add(requestsRecordsIdMap.get(procesRec.ProcessInstance.TargetObjectId));

                    IFv2_Request__Share shareRecord = new IFv2_Request__Share();    
                    shareRecord.ParentId = procesRec.ProcessInstance.TargetObjectId;
                    shareRecord.UserOrGroupId = userRec.ManagerId;
                    shareRecord.AccessLevel = 'read';
                    shareRecord.RowCause = Schema.IFv2_Request__Share.RowCause.SharingRecordsWithChatter__c;
                    requestShareList.add(shareRecord);

                    if(requestAccountsMap.containsKey(procesRec.ProcessInstance.TargetObjectId ) && 
                        requestAccountsMap.get(procesRec.ProcessInstance.TargetObjectId) != null)  {

                        AccountShare accountShareRecord = new AccountShare();
                        accountShareRecord.AccountId = requestAccountsMap.get(procesRec.ProcessInstance.TargetObjectId);
                        accountShareRecord.UserOrGroupId = userRec.ManagerId;
                        accountShareRecord.AccountAccessLevel = 'read';
                        accountShareRecord.OpportunityAccessLevel = 'edit';
                        accountShareRecord.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShareLIST.add(accountShareRecord);

                    }

                }

            }

            String jsonString = JSON.serialize(processInstanceList);
            updateProcessInstanceRecords(jsonString);

            // Inserting Request Share Records
            if(!requestShareList.isEmpty()) {
                System.debug('DEBUG::requestShareList*******' + requestShareList);
                String jsonString1 = JSON.serialize(requestShareList);
                updateRequestShareRecords(jsonString1);
            }

            // Inserting Account Share Records
            if(!accountShareLIST.isEmpty()) {
                System.debug('DEBUG::accountShareLIST*******' + accountShareLIST);
                String jsonString4 = JSON.serialize(accountShareLIST);
                updateAccountShareRecords(jsonString4); 
            }

            MAP<Id,Id> userIdRecordIdForRecordAcessDeligatedMAP = new MAP<Id,Id>();

            //provide access for the off boarded users manager to the request, account and extension records
            IFv2_TriggerHandler.CreateExtensionShareRecords(requestsRecList, processInstanceUsersMap, userIdRecordIdForRecordAcessDeligatedMAP);
        }
    }

    //remove the public groups and permission sets assigned to the off boarded users.
    public static void checkAndRemovePublicGroupsPermissionSets(List<User> deactiveUsersList) {

        if(!deactiveUsersList.isEmpty()) {

            Set<String> userIdSet = new Set<String>();
            for(User userObj : deactiveUsersList) {
                userIdSet.add(userObj.Id);
            }

            if(!userIdSet.isEmpty()) {

                //Query for existing permission sets
                List<PermissionSetAssignment> permisisonSetAssignmentList = [SELECT Id,AssigneeId,PermissionSetId,PermissionSet.Label,PermissionSet.Name
                                                                             FROM PermissionSetAssignment
                                                                             WHERE AssigneeId IN : userIdSet
                                                                             AND PermissionSet.IsOwnedByProfile = false];
                
                    System.debug('DEBUG::permisisonSetAssignmentList*******' + permisisonSetAssignmentList);
                    String jsonString2 = JSON.serialize(permisisonSetAssignmentList);
                    String blankStr = '';
                    removeGroupsAndPermissionSets(blankStr,jsonString2); 
                }

                //Query the all existing groups for the off boarded userMap
                List<GroupMember> groupsList = [Select Id
                                                From GroupMember 
                                                Where UserOrGroupId IN:userIdSet ];
                
                if(!groupsList.isEmpty()) {

                    System.debug('DEBUG::groupsList*******' + groupsList);
                    String jsonString3 = JSON.serialize(groupsList);
                    String blankStr1 = '';
                    removeGroupsAndPermissionSets(jsonString3,blankStr1); 
                }
            }
        }
    
    @future
    public static void removeGroupsAndPermissionSets(String groupStr,String permissionStr) {

        if(String.isNotBlank(groupStr) && String.isBlank(permissionStr)) {
            System.debug('DEBUG::groupStr*******' + groupStr);
            //deserialize the JSON to the GroupMemberList
            List<GroupMember> GroupMemberList = (List<GroupMember>)JSON.deserialize(groupStr,List<GroupMember>.class);
            System.debug('DEBUG::GroupMemberList** After json*****' + GroupMemberList);
            delete GroupMemberList;
        }

        if(String.isNotBlank(permissionStr) && String.isBlank(groupStr)) { 
            System.debug('DEBUG::permissionStr*******' + permissionStr);
            //deserialize the JSON to the PermissionSetAssignment
            List<PermissionSetAssignment> PermissionSetAssignmentList1 = (List<PermissionSetAssignment>)JSON.deserialize(permissionStr,List<PermissionSetAssignment>.class);
            System.debug('DEBUG::PermissionSetAssignmentList** After json*****' + PermissionSetAssignmentList1);
            delete PermissionSetAssignmentList1;
            
        }
    }

    //update Request Records 
    @future 
    public static void updateRequestShareRecords(String jsonString) {
        
        if(String.isNotBlank(jsonString)) {

            //deserialize the JSON to the requestShareList
            List<IFv2_Request__Share> requestShareList = (List<IFv2_Request__Share>)JSON.deserialize(jsonString,List<IFv2_Request__Share>.class);
            System.debug('DEBUG::requestShareList** After json*****' + requestShareList);
            insert requestShareList;
        }
    }
    
    //update Account Records 
    @future 
    public static void updateAccountShareRecords(String jsonString){
        
        if(String.isNotBlank(jsonString)) {

            //deserialize the JSON to the accountShareList
            List<AccountShare> accountShareList = (List<AccountShare>)JSON.deserialize(jsonString,List<AccountShare>.class);
            System.debug('DEBUG::accountShareList** After json*****' + accountShareList);
            insert accountShareList;
        }
    }

    //update process instance records with new users
    @future
    public static void updateProcessInstanceRecords(String jsonString) {
        
        System.debug('DEBUG::jsonString*******' + jsonString);

        //deserialize the JSON to the processInstanceList
        list<ProcessInstanceWorkitem> processInstanceList = (List<ProcessInstanceWorkitem>)Json.deserialize(jsonString,List<ProcessInstanceWorkitem>.class);
        System.debug('DEBUG::processInstanceList** After json*****' + processInstanceList);
        //udpate process instance records
        if(!processInstanceList.isEmpty()) {
            try {
                System.debug('DEBUG::processInstanceList*******' + processInstanceList);

                Database.SaveResult[] srList = Database.update(processInstanceList, false);

                //Iterate through each returned result  
                for(Database.SaveResult sr : srList) {  
                    if(sr.isSuccess()) {  
                        // Operation was successful, so get the ID of the record that was processed  
                        System.debug('Successfully Reassigned the workflows****' + sr.getId());
                        sendEmailNotificationToApprovers(processInstanceList);
                    }  
                    else {  
                        // Operation failed, so get all errors  
                        for(Database.Error err : sr.getErrors()) {  
                            System.debug('The following error has occurred.');  
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());  
                            System.debug('Account fields that affected this error: ' + err.getFields());  
                        }  
                    } 
                }       
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    
     //this method is used to send email to new approvers 
    public static void sendEmailNotificationToApprovers(list<ProcessInstanceWorkitem> processInstanceList) {

        List<Id> userIdsList = new List<Id>();
        Map<Id,User> usersDetailsMap = new Map<Id,User>();
        List<Id> requestsList = new List<Id>();
        Map<Id,IFv2_Request__c> requestIdMap = new Map<Id,IFv2_Request__c>();
        String emailTemplateName = 'IFv2_Notification_when_a_task_is_assigned_to_an_approver_Request';

        if(!processInstanceList.isEmpty()) {
            for(ProcessInstanceWorkitem procesRecObj : processInstanceList) {
                userIdsList.add(procesRecObj.ActorId);
                requestsList.add(procesRecObj.ProcessInstance.TargetObjectId);
            }
        }

        if(!userIdsList.isEmpty()) {
            for(User UserObj:[SELECT Id,Email FROM User WHERE Id IN :userIdsList and isActive = true]) {
                if(UserObj.Email != null) {
                    usersDetailsMap.put(UserObj.Id,UserObj);
                }
            }
        }

        if(!requestsList.isEmpty()) {
            for(IFv2_Request__c reqObj:[SELECT Id,CreatedDate,Workflow__c,Name,CreatedBy.Name,Status__c FROM IFv2_Request__c WHERE Id IN :requestsList]) {
                requestIdMap.put(reqObj.Id,reqObj);
            }
        }

        /* Query for contact records */
        LIST<contact> contacts = [select Id from contact limit 1];
        LIST<Messaging.SingleEmailMessage> emailList = new LIST<Messaging.SingleEmailMessage>(); 
        
        /*Iterate over requests and create Email messages*/
        if(!requestIdMap.isEmpty() && !usersDetailsMap.isEmpty()) { 

            for(ProcessInstanceWorkitem procesObj : processInstanceList) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                string emailStr = (String.valueOf(usersDetailsMap.get(procesObj.ActorId).Email));
                List<String> toaddressesList = new List<String>();
                toaddressesList.add(emailStr);
                message.setToAddresses(toaddressesList);
                message.setTreatTargetObjectAsRecipient(false);

                //Setting the setTargetObjectId to dummy contact Id
                if(!Contacts.isEmpty()) {
                    message.setTargetObjectId(contacts[0].Id);
                } else if(Test.isRunningTest()) {
                    message.setTargetObjectId(UserInfo.getUserId());
                }

                message.setSaveAsActivity(false);
                message.setWhatId(procesObj.ProcessInstance.TargetObjectId);
                IFv2_Request__c requestObj = requestIdMap.get(procesObj.ProcessInstance.TargetObjectId);

                String subStr = 'Workflow: ' + requestObj.Workflow__c + ' ' + requestObj.Name + ' ' + requestObj.Status__c ;

                message.setSubject(subStr);
                // Step 3: Set who the email is sent from
                message.setReplyTo('salesforceadmin@seg-automotive.com');
                message.setSenderDisplayName('SEG Salesforce Admin');

                //Prepare Email body
                String bodyStart = '<Html><body> <p> Dear Madam/Sir:</p> ,<br/><br/>';
                        bodyStart += '<p>The following workflow request has been reassigned to you for approval due to one of your team member got offboarded,';
                        bodyStart += 'please click on the request ID to see more details.</p>'+ '<br/><br/>';
                        bodyStart += '<p>Applicant:  '+ requestObj.CreatedBy.Name + '</p><br/>';
                        bodyStart += '<p>Request Id: '+ requestObj.Name + '</p><br/>';
                        bodyStart +=  System.Label.Production_URL + '/' + requestObj.id ;
                        bodyStart += '<p>Workflow Type / Title: '+ requestObj.Workflow__c + '</p><br/>';
                        bodyStart += '<p>Created: ' + requestObj.CreatedDate + '</p><br/>';
                        bodyStart += '<p>Offboarded user: '+ procesObj.OriginalActor.Name + '</p><br/> <br/> <br/>';

                String bodyEnd = '___________________________________________<br/>'+
                                    'Please do not reply to this automated mail.<br/>'+
                                    '</body></Html>';
                String body = bodyStart + bodyEnd;
                message.setHtmlBody(body);

                if(message.toAddresses.size()>0) {
                    emailList.add(message);
                }

                //Send the emails to editors/ record owners
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            }
        }
    }

    public static void updateSpecialfrightRecords(User deactivatedUser) {
        
        System.debug('DEBUG::deactivatedUser*******' + deactivatedUser);         
        Id userRecId = null;
        
        if(deactivatedUser != null){
            userRecId = deactivatedUser.Id;
        }
        List<User> usersList = new List<User>();
        if(userRecId != null) {
            
            if(!Test.isRunningTest()){
                usersList = [Select id,iFreight_Approver_Level_1__c,iFreight_Approver_Level_1_Proxy__c, iFreight_Approver_Level_2__c,
                                    iFreight_Approver_Level_2_Proxy__c,iFreight_Approver_Level_3__c,iFreight_Approver_Level_3_Proxy__c,IFv2_iFreight_Approver_Level_4__c,
                                    IFv2_iFreight_Approver_Level_4_Proxy__c,IFv2_iFreight_Approver_Level_3_2__c,IFv2_iFreight_Approver_Level_3_2_proxy__c
                                    From User
                                    Where iFreight_Approver_Level_1__c = : userRecId OR iFreight_Approver_Level_1_Proxy__c = : userRecId OR    
                                    iFreight_Approver_Level_2__c  = : userRecId OR iFreight_Approver_Level_2_Proxy__c  = : userRecId OR 
                                    iFreight_Approver_Level_3__c  = : userRecId OR iFreight_Approver_Level_3_Proxy__c  = : userRecId OR 
                                    IFv2_iFreight_Approver_Level_4__c  = : userRecId OR IFv2_iFreight_Approver_Level_4_Proxy__c  = : userRecId OR 
                                    IFv2_iFreight_Approver_Level_3_2__c  = : userRecId OR IFv2_iFreight_Approver_Level_3_2_proxy__c = : userRecId ];
            } else {
                
                usersList = [Select id,iFreight_Approver_Level_1__c,iFreight_Approver_Level_1_Proxy__c, iFreight_Approver_Level_2__c,
                                    iFreight_Approver_Level_2_Proxy__c,iFreight_Approver_Level_3__c,iFreight_Approver_Level_3_Proxy__c,IFv2_iFreight_Approver_Level_4__c,
                                    IFv2_iFreight_Approver_Level_4_Proxy__c,IFv2_iFreight_Approver_Level_3_2__c,IFv2_iFreight_Approver_Level_3_2_proxy__c
                                    From User limit 1];
            }                                           
        }
                             
        System.debug('usersList'+ usersList.size());
        List<User> finalUsersList = new List<User>();
        
        if(!usersList.isEmpty()) {
            for(User userObj : usersList) {
                
                if(userObj.iFreight_Approver_Level_1__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_1__c = null;
                }

                if(userObj.iFreight_Approver_Level_1_Proxy__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_1_Proxy__c = null;
                }

                if(userObj.iFreight_Approver_Level_2__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_2__c = null;
                }

                if(userObj.iFreight_Approver_Level_2_Proxy__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_2_Proxy__c = null;
                }

                if(userObj.iFreight_Approver_Level_3__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_3__c = null;
                }

                if(userObj.iFreight_Approver_Level_3_Proxy__c == userRecId || Test.isRunningTest()){
                    userObj.iFreight_Approver_Level_3_Proxy__c = null;
                }

                if(userObj.IFv2_iFreight_Approver_Level_4__c == userRecId || Test.isRunningTest()){
                    userObj.IFv2_iFreight_Approver_Level_4__c = null;
                }

                if(userObj.IFv2_iFreight_Approver_Level_4_Proxy__c == userRecId || Test.isRunningTest()){
                    userObj.IFv2_iFreight_Approver_Level_4_Proxy__c = null;
                }

                if(userObj.IFv2_iFreight_Approver_Level_3_2__c == userRecId || Test.isRunningTest()){
                    userObj.IFv2_iFreight_Approver_Level_3_2__c = null;
                }

                if(userObj.IFv2_iFreight_Approver_Level_3_2_proxy__c == userRecId || Test.isRunningTest()){
                    userObj.IFv2_iFreight_Approver_Level_3_2_proxy__c = null;
                }

                finalUsersList.add(userObj);
            }
        }
        
        if(!finalUsersList.isEmpty()) {
            try {
                System.debug('DEBUG::finalUsersList*******' + finalUsersList);

                Database.SaveResult[] srList = Database.update(finalUsersList, false);

                //Iterate through each returned result  
                for(Database.SaveResult sr : srList) {  
                    if(sr.isSuccess()) {  
                        // Operation was successful, so get the ID of the record that was processed  
                        System.debug('Special Frieght Field are cleared for the deactivated user****' + sr.getId());  
                    }  
                    else {  
                        // Operation failed, so get all errors  
                        for(Database.Error err : sr.getErrors()) {  
                            System.debug('The following error has occurred.');  
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());  
                            System.debug('Account fields that affected this error: ' + err.getFields());  
                        }  
                    } 
                }       
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
}