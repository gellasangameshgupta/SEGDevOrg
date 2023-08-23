/**
*
* @ Purpose : Trigger for Delegated Approver per Workflow
*            
*
* @ Author: Aaron Klinge
*
*
*       Date                |   Developer Name                  |   Version     |   Changes
* ===========================================================================================================
*   (1.0) 21.11.2017        |   aaron.klinge@t-systems.com      |   1.0         |   Initial Version
*   (1.1) 22.11.2017        |   aaron.klinge@t-systems.com      |   1.1         |   expanded logic to update process instance work items
*   (1.2) 22.11.2017        |   raphael.rugova@t-systems.com    |   1.2         |   added SendEmail Logic if Delegate is Inactive
*   (1.3) 06.12.2017        |   aaron.klinge@t-systems.com      |   1.3         |   added email notification if user email is changed; added custom setting logic
*   (1.4) 30.01.2018        |   aaron.klinge@t-systems.com      |   1.4         |   added reassignment log logic - prevents chained reassignments 
*   (1.5) 27.02.2018        |   aaron.klinge@t-systems.com      |   1.5         |   prepared trigger for reassignment batch 
*   (1.6) 01.03.2018        |   aaron.klinge@t-systems.com      |   1.6         |   added skip approver check 
*   (1.6) 28.11.2018        |   nagasai.chalamalasetti@absyz.com|   1.7         |   added Invoking Out of office logic for IFv2_Request Object and modified validation for Inactive user emails as a delagate.The change is only the user records which dont have active user emails as delegates will not be updated
*   (1.7) 27.02.2019        |   external.debasmita.rawooth@seg-automotive.com   |   1.7         |   moved update process instance logic to BatchUserAssignToDelegated batch class to handle new requests coming after out of office is already checked
*/

/**
* A trigger that calls methods to changes NT User to uppperCase, federationIdentifier and assign permission set.
* Modified By: Chitranjan Chetkar
* Modified On: 16/05/2018 
*/

trigger User on User (before Insert, before update, after Insert, after update, before delete) {
    //To prevent recursion
    List<Profile> profileList = [select id,Name  from profile where Name  = 'Customer Community Plus Login User' Limit 1];
    public string Profileid = profileList[0].id;
    public static Boolean IFv2_PreventRecursion=False;
    UserRole userRoleId = [SELECT Id, Name, DeveloperName FROM UserRole WHERE name = 'all_users' limit 1];
    if((trigger.isBefore && Trigger.isUpdate &&  !Trigger.oldMap.isEmpty() && !Trigger.newMap.isEmpty() )) { 
        for(User userObj: Trigger.newMap.values()) {system.debug('profile '+Trigger.oldMap.get(userObj.Id).ProfileId);
            if(Trigger.oldMap.containsKey(userObj.Id) && 
               Trigger.oldMap.get(userObj.Id).isActive == true && 
               Trigger.newMap.get(userObj.Id).isActive == false && Trigger.oldMap.get(userObj.Id).ProfileId != Profileid ) {
                   system.debug('called the reassignment');
                   userObj.iFreight_Approver_Level_1__c = null;
                   userObj.iFreight_Approver_Level_1_Proxy__c = null; 
                   userObj.iFreight_Approver_Level_2__c = null;
                   userObj.iFreight_Approver_Level_2_Proxy__c = null;
                   userObj.iFreight_Approver_Level_3__c = null;
                   userObj.iFreight_Approver_Level_3_Proxy__c = null;
                   userObj.Ifv2_iFreight_Approver_Level_4__c = null;
                   userObj.Ifv2_iFreight_Approver_Level_4_Proxy__c = null;
                   userObj.Ifv2_iFreight_Approver_Level_3_2__c = null;
                   userObj.Ifv2_iFreight_Approver_Level_3_2_proxy__c = null;
                   userObj.UserRoleId = userRoleId.Id;
                   ReassignInactiveUsersWorkflows.updateSpecialfrightRecords(userObj);          
               }
        }   
    }
    
    //AssignPermissionSetKey__c setting = AssignPermissionSetKey__c.getAll().values(); 
    //if(setting.Active__c == True) {
    if(trigger.isBefore && Trigger.isInsert) {
        AssignPermissionSet.userBeforeInsert(trigger.new);
    }
    
    if(trigger.isAfter && Trigger.isInsert) {   
        List<Id> userIdList=new List<Id>();
        for(User u : trigger.new) {
            userIdList.add(u.Id);
        }
        AssignPermissionSet.AssignPermissionSetToUsers(userIdList);
        /* Assign permission sets to users on user creation  for version 2.0 */
        if(IFv2_TriggerHandler.firstTime){
            IFv2_TriggerHandler.firstTime = false;
            IFv2_TriggerHandler.AssignPermissisonSetOnInsert(trigger.new);
        }
    }
    
    /* Code for sharing record access while changing delegated approver */
    if(trigger.isUpdate && trigger.isAfter)
    {
        map<id,User>Userlist=new map<id,User>();
        for(User user:Trigger.new)
        {
            if(user.DelegatedApproverId!=Trigger.oldMap.get(user.id).DelegatedApproverId && user.DelegatedApproverId!=null)
            {
                Userlist.put(user.id,user);
            }
        }
        if(Userlist.size()>0)
        {
            map<id,Ifv2_request__c>userRecordMap=new map<id,Ifv2_request__c>();
            map<id,List<id>>userRecordIdsMap=new map<id,List<id>>();
            List<id>userIDs=new List<id>();
            List<id>rcdIds=new List<id>();
            set<id>rcdIdsQuerry=new set<id>();
            List<ProcessInstanceWorkitem> pendingRecords=[select id,ProcessInstanceId,ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ActorId IN : Userlist.keySet()];
            System.debug('user>pendingRecords>'+pendingRecords);
            For(ProcessInstanceWorkitem item:[select id,ProcessInstanceId,ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ActorId IN : Userlist.keySet()])
            {
                rcdIdsQuerry.add(item.ProcessInstance.TargetObjectId);
                if(!userRecordIdsMap.containsKey(item.ActorId))
                {
                    rcdIds=new List<id>();
                    rcdIds.add(item.ProcessInstance.TargetObjectId);
                }
                else
                {
                    rcdIds.add(item.ProcessInstance.TargetObjectId);
                }
                userRecordIdsMap.put(item.ActorId,rcdIds);
            }
            System.debug('user>userRecordIdsMap>'+userRecordIdsMap);
            List<Ifv2_request__c> RequestRecords=new List<Ifv2_request__c>();
            if(!userRecordIdsMap.isEmpty())
                RequestRecords=[Select id,name,RequestExtension1__c,RequestExtension2__c,RequestExtension3__c,Account__c,Workflow__c from Ifv2_request__c where id IN : rcdIdsQuerry];
            System.debug('user>RequestRecords>'+RequestRecords);
            For(Ifv2_request__c request:RequestRecords)
            {
                for(Id userId : userRecordIdsMap.keySet())
                {
                    for(Id rcdId:userRecordIdsMap.get(userId))
                    {
                        if(request.id==rcdId)
                        {
                            System.debug('user>recordShare');
                            set<id>deligatedIdList=new set<id>();
                            deligatedIdList.add(Userlist.get(userId).DelegatedApproverId);
                            IFv2_UtilsController.RecordShare(deligatedIdList,rcdId,(String)request.RequestExtension1__c,(String)request.RequestExtension2__c,
                                                             (String)request.RequestExtension3__c,request.Account__c,request.Workflow__c);
                        }
                        
                    }
                }
            }            
        }
    }
    /* Ends: Code for sharing record access while changing delegated approver */
    
    if(trigger.isAfter && Trigger.isUpdate && !Trigger.oldMap.isEmpty() && !Trigger.newMap.isEmpty() ) { 
        List<Id> userRecList = new List<Id>();
        for(User userRecObj: Trigger.newMap.values()) {
            if(Trigger.oldMap.containsKey(userRecObj.Id) && 
               Trigger.oldMap.get(userRecObj.Id).isActive == false && 
               Trigger.newMap.get(userRecObj.Id).isActive == true) {
                   system.debug('reactivate the user and assigning the permission sets****');
                   userRecList.add(userRecObj.Id);
                   AssignPermissionSet.AssignPermissionSetToUsers(userRecList);     
               }
        }   
    }
    
    //BEFORE UPDATE
    if(trigger.isUpdate && trigger.isBefore) {
        
        List<user> deactiveUsersList = new List<user>();    
        List<Id> inactiveUserIdList = new List<Id>();   
        //check whether user is about to deactivate or not  
        
        if(!Trigger.oldMap.isEmpty() && !Trigger.newMap.isEmpty()) {    
            for(User userObj: Trigger.newMap.values()) {    
                if(Trigger.oldMap.containsKey(userObj.Id) &&    
                   Trigger.oldMap.get(userObj.Id).isActive == true &&   
                   Trigger.newMap.get(userObj.Id).isActive == false) {  
                       deactiveUsersList.add(userObj);  
                       inactiveUserIdList.add(userObj.Id);                  
                   }    
            }   
        }   
        
        if(!deactiveUsersList.isEmpty()) {
            
            //reassign workflows when the users off boarded.
            ReassignInactiveUsersWorkflows.reassignWorkflows(deactiveUsersList);
            
            //remove the public groups and permission sets assigned to the off boarded users.
            ReassignInactiveUsersWorkflows.checkAndRemovePublicGroupsPermissionSets(deactiveUsersList);
            
            //Added for SEG Contact Portal  
            //SEGCP_SendEmailForInactiveContacts.sendEmailtoEditors(inactiveUserIdList);  
        }
        
        //check if skip approver checkbox selection is valid
        for(User u : Trigger.new) {
            if(u.Skip_Approver_1__c == false && u.Skip_Approver_2__c == true){
                u.addError('It is not allowed to skip iFreight Approver 2 if iFreight Approver 1 is not skipped.');
            }
        }
        
        //get request object prefixes 
        /*commented for cleaning up of Insightflow 1.0 components
String requestPrefix = WF_Request__c.sObjectType.getDescribe().getKeyPrefix();
String requestApacPrefix = Request_APAC__c.sObjectType.getDescribe().getKeyPrefix();
String requestNalaPrefix = Request_NALA__c.sObjectType.getDescribe().getKeyPrefix();
String requestEmeaPrefix = Request_EMEA__c.sObjectType.getDescribe().getKeyPrefix();

// get Object FieldMap from User via Describe Schema
List<String> objectNameList = new List<String>();
objectNameList.add('User');
Schema.DescribeSObjectResult[] descObj = Schema.describeSObjects(objectNameList);
Map<String, Schema.sObjectField> fieldMap = descObj.get(0).fields.getMap();
system.debug('fieldmap---'+fieldMap);

// Iterate over fieldMap
Map<String, String> delegatesFieldNames = new Map<String, String>();
for (Schema.sObjectField s: fieldMap.values()) {
String fieldName = String.valueOf(s.getDescribe().getLabel());
String fieldApiName = String.valueOf(s.getDescribe().getName());
// Map Building of delegatesFieldNames
if (fieldApiName.startsWith('Delegate_')) {
delegatesFieldNames.put(fieldApiName, fieldName.removeStart('Delegate '));
}
}
*/
        //add wf fields mapped by custom setting 
        /*commented for cleaning up of Insightflow 1.0 components
Map<String,DelegateApproverWorkflowNameMapping__c> wfcs = DelegateApproverWorkflowNameMapping__c.getAll();
for(String csName : wfcs.keySet()){
delegatesFieldNames.put(wfcs.get(csName).Workflow_API_Name__c, wfcs.get(csName).Workflow_Name__c);
} */
        
        //iterate over users which are active AND outOfOffice
        List<Id> userIdList = new List<Id>();
        List<User> userList = new List<User>();
        for (User user : Trigger.new) { 
            //if(user.LastModifiedBy.Id == user.Id) {
            if (user.IsActive && user.Out_Of_Office__c) {
                userIdList.add(user.Id);
                userList.add(user);
            }
            /** Author:NagaSai, Date:28-11-2018, Invoking Out of office logic for IFv2_Request Object **/
            /**if (user.IsActive && user.Out_Of_Office__c &&  trigger.oldmap.get(user.id).Out_Of_Office__c!=True) {
IFv2userList.add(user);
}**/
            //}
            /** Author:NagaSai, Date:23-03-2019, purpose: making outofoffice as true when user is inactive **/
            if(user.IsActive==False && user.IsActive!=trigger.oldmap.get(user.id).IsActive && IFv2_PreventRecursion!=True){
                user.Out_Of_Office__c=True;
                IFv2_PreventRecursion=True;//To prevent recursion 
            }
        }
        /*Commenting below code as this will be handled in BatchUserAssignToDelegated batch class
system.debug('test running??'+!Test.isRunningTest());
if(!Test.isRunningTest()) { //if no test class is running/invoking this code
system.debug('test not running');

if(system.isBatch() == false) { //if no batch is running/invoking the code at the same trigger event
if(!System.isFuture()){ //if a future is not running at same time
//moved the below logic as setup and non setup objects update happened in same transaction
//  UpdateProcessInstancetoDelegatedUser.updatePiw(userIdList, delegatesFieldNames);
}
}
}*/
        
        //get map with valid users by email and reassignment logs by userId 
        /*commented for cleaning up of Insightflow 1.0 components
Map<String, User> validDelegateUsersByEmail = new Map<String, User>();

try{ 
//check if there are users to be validated
if(userList.size() > 0){
validDelegateUsersByEmail = SG_WF_UserTriggerHelper.validateUserEmails(userList, delegatesFieldNames);
}
} catch(SG_WF_UserTriggerHelper.UserForEmailException ex) {
for (User user : Trigger.new) {
user.addError('One or more emails are not valid / belong to inactive users.');
}  
}
*/
        
        /*Below code is commented and moved to UpdateProcessInstancetoDelegatedUser as setup and non setup objects update happened in same transaction which caused mixed DML exception
//get processInstanceWorkItems
List<ProcessInstanceWorkitem> proWorkItemList = new List<ProcessInstanceWorkitem>();
if(validDelegateUsersByEmail.size() > 0) {
system.debug('valid delegate size gt 0'+validDelegateUsersByEmail );
if (userIdList.size() > 0) {
String soqlProWork = 'SELECT Id, ActorId, ProcessInstanceId, p.ProcessInstance.TargetObject.Name,'; 
soqlProWork += ' p.ProcessInstance.TargetObject.Id, CreatedDate '; 
soqlProWork += ' FROM ProcessInstanceWorkItem p ';
soqlProWork += ' WHERE ( ';
soqlProWork += ' ActorId IN : userIdList '; 
soqlProWork += ') ';
soqlProWork += ' AND (';
soqlProWork += ' p.ProcessInstance.Status != \'Approved\' ';
soqlProWork += ' OR p.ProcessInstance.Status != \'Rejected\' ';
soqlProWork += ') ';
soqlProWork += ' Order By CreatedDate Desc ';
proWorkItemList = Database.query(soqlProWork);
system.debug('soqlProWork: ' + soqlProWork);
}
}

system.debug('proWorkItemList size' + proWorkItemList.size());

//check if items already have been changed
List<String> piwIdList = new List<String>();
if(proWorkItemList.size() > 0) {
for(ProcessInstanceWorkitem piw : proWorkItemList) {
piwIdList.add(String.valueOf(piw.Id));
}
}

//get reassignment Logs for piw Ids
Map<Id, ReassignmentLog__c> reassignmentLogsByPiwId = new Map <Id, ReassignmentLog__c>();
if(piwIdList.size() > 0){
//query reassignment logs
List<ReassignmentLog__c> ralList = new List<ReassignmentLog__c>();
try{
ralList = [select Id, ProcessInstanceWorkItemId__c, UserId__c from ReassignmentLog__c where ProcessInstanceWorkItemId__c IN : piwIdList];
} catch(Exception ex) {
//Ok here - no reassignment logs found
}

//iterate over reassignmentLogs and build map 
if(ralList.size() > 0) {
for(ReassignmentLog__c ral : ralList) {
reassignmentLogsByPiwId.put(ral.ProcessInstanceWorkItemId__c, ral);
}
}
}


//if there are work items to be changes, get corresponding workflow names 
Map<String, String> workflowNamesForTargetObjMap = new Map<String, String>();
if(proWorkItemList.size() > 0) {
workflowNamesForTargetObjMap = SG_WF_UserTriggerHelper.getWorkflowNamesForPiw(proWorkItemList);
}
system.debug('workflowNamesForTargetObjMap size' + workflowNamesForTargetObjMap.size());
//update workItems
List<ProcessInstanceWorkitem> updatedPiwList = new List<ProcessInstanceWorkitem>();
List<ReassignmentLog__c> reassignmentLogList = new List<ReassignmentLog__c>();
if(workflowNamesForTargetObjMap.size() > 0 ) {

for(ProcessInstanceWorkitem piw : proWorkItemList){
String newActorEmail = null;
Id userIdLogged = null;
for(User user : Trigger.new) {
if(piw.ActorId == user.Id) {
String wfName = workflowNamesForTargetObjMap.get(piw.ProcessInstance.TargetObject.Id);
system.debug('workflowname--'+wfName);
for(String fieldNameApi : delegatesFieldNames.keySet()) {
String fieldLabel = delegatesFieldNames.get(fieldNameApi);
if(fieldLabel == wfName) {
try {
//check for reassignment log containing the piw Id to be modified. if there is one, do not reassign again
try{
if(reassignmentLogsByPiwId.get(piw.Id) != null) {
system.debug('Reassignment already happened. No further automatic reassignment allowed.');
} else {
//get new actor email and log user Id for reassignment log
newActorEmail = String.valueOf(user.get(fieldNameApi));
system.debug('newActorEmail'+newActorEmail);
userIdLogged = user.Id;
}
} catch (Exception ex) {
system.debug('Exception occured during reassignment log check.');
}
} catch (Exception e) {
newActorEmail = null; 
}
}                           
}
}
}
if(newActorEmail != null) {

//create ReassignmentLog__c
//   ReassignmentLog__c ral = SG_WF_UserTriggerHelper.createReassignmentLog(piw, userIdLogged, requestPrefix, requestApacPrefix, requestNalaPrefix, requestEmeaPrefix); 
reassignmentLogList.add(ral);

//set new actor Id 
piw.ActorId = validDelegateUsersByEmail.get(newActorEmail).Id;
updatedPiwList.add(piw);
}
}
}
system.debug('updatedPiwList size:' + updatedPiwList.size());
//update process instance work items
if(updatedPiwList.size() > 0) {
system.debug('updatedPiwList--'+updatedPiwList);
update updatedPiwList;
}
//create reassignment logs
if(reassignmentLogList.size() > 0){
insert reassignmentLogList;
}
*/
        
        /** Author:NagaSai ,Date:28-11-2018
Invoking Out of office logic for IFv2_Request Object
**/
        /**  if(IFv2userList.size()>0)
IFv2_TriggerHandler.TransferApproverToDelegatedUser(IFv2userList);  
**/ 
        
        ///////////////////////////////////////////////
        //back to office part - logic handled in batch 
        
        //List with users who came back to office
        List<Id> userIdListBackInOffice = new List<Id>();
        List<User> userListBackInOffice = new List<User>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            system.debug('back to office executed');
            if(Trigger.new[i].Out_Of_Office__c == false && Trigger.old[i].Out_Of_Office__c == true && Trigger.new[i].IsActive == true) {
                
                //flag record for batch 
                Trigger.new[i].ConsiderInReassignmentBatch__c = true;
                system.debug('back to office false');
                //userIdListBackInOffice.add(Trigger.new[i].Id);
                //userListBackInOffice.add(Trigger.new[i]);
            }
        }
        
        //call helper method to reassign back based on reassignment logs
        /*List<ProcessInstanceWorkItem> reassignedPiwList = new List<ProcessInstanceWorkItem>(); 
if(userIdListBackInOffice.size() > 0) {
reassignedPiwList = SG_WF_UserTriggerHelper.assignRequestsBack(userIdListBackInOffice);
}*/
        
        //if there are piws to be reassigned back, update them
        /*if(reassignedPiwList.size() > 0) {
update reassignedPiwList;
}*/
        
    }
    
    //AFTER UPDATE
    if(trigger.isUpdate && trigger.isAfter) {
        //get inactive users and send emails to inform other users 
        List<String> userIdListInactive = new List<String>();
        for(User u:Trigger.new) {
            if(!u.IsActive) {
                userIdListInactive.add(u.Id);
            }
        }
        /*commented for cleaning up of Insightflow 1.0 components
if (userIdListInactive.size() > 0) {
SG_WF_UserTriggerHelper.sendEmailByInactiveDelegate(userIdListInactive);
} */
        
        /* Re-Assign permission sets to users on user record updation for Version 2.0  */
        if(IFv2_TriggerHandler.firstTime){
            IFv2_TriggerHandler.firstTime = FALSE;
            IFv2_TriggerHandler.updatePermissionSets(Trigger.new, Trigger.oldmap); 
        }
        
        //get users with changed email and send emails to inform other users
        List<String> userIdListEmailChanged = new List<String>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if(Trigger.new[i].Email != Trigger.old[i].Email) {
                userIdListEmailChanged.add(Trigger.new[i].Id);
            }
        }
        /*commented for cleaning up of Insightflow 1.0 components
if(userIdListEmailChanged.size() > 0) {
SG_WF_UserTriggerHelper.sendEmailByChangedEmailDelegate(userIdListEmailChanged);
} */
        
    }
    
    
    //BEFORE DELETE
    /*commented for cleaning up of Insightflow 1.0 components
if(trigger.isDelete && trigger.isBefore) {

//get user Ids
List<Id> userIdListToDelete = new List<Id>();
for(User u:Trigger.new) {
userIdListToDelete.add(u.Id);
}
//call helper class to delete old reassignment logs 
SG_WF_UserTriggerHelper.deleteReassignmentLogsForDeletedUsers(userIdListToDelete);
} */
}