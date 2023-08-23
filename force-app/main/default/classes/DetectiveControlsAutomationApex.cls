/*
* @ Name        : DetectiveControlsAutomationApex
* @ Purpose     : Controller class for DetectiveControlsAutomation.
* @ Test Class  : DetectiveControlsAutomationApexTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 08-06-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version
* 26-02-2021	| external.debasmita.rawooth@absyz.com       | 1.1       | Modified the query to fix search issue
*******************************************************************************************************/

public without sharing class DetectiveControlsAutomationApex {
    
    @auraEnabled
    Public static SlotWrapper fetchCount(){
        id loggedInUserId=UserInfo.getUserId();
        SlotWrapper slotwrap;
        try{
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
            system.debug('recordTypeId> inside try>'+recordTypeId);
            integer totalCount,totalCountSubmitted;
            string query='select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId= \''+recordTypeId +'\'';
            if(showProcessingButton())
            {
                totalCount  = Database.countQuery('SELECT count() FROM Contact where recordTypeId= \''+recordTypeId +'\' and (DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\')');
                totalCountSubmitted=Database.countQuery('SELECT count() FROM Contact where recordTypeId= \''+recordTypeId +'\' and DCA_Status__c= \'Processed\'');
                
            }
            else
            {
                totalCount  = Database.countQuery('SELECT count() FROM Contact where recordTypeId= \''+recordTypeId +'\' and  DCA_Status__c= \'Pending\' and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'');
                totalCountSubmitted=Database.countQuery('SELECT count() FROM Contact where recordTypeId= \''+recordTypeId +'\' and (DCA_Status__c= \'Approved\' or DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\') and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'');
            }
            
            slotwrap=new SlotWrapper();
            slotwrap.NoOfRecords=totalCount;
            slotwrap.NoOfRecordsSubmitted=totalCountSubmitted;
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotwrap;
        
        
    }
    
    @auraEnabled
    Public static List<SlotWrapper> fetchDetailsNext(Integer LimitSize, Id recId, String Orderby, String OrderDir){
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
        id loggedInUserId=UserInfo.getUserId();
        try{
            list<Contact> allDCA=new List<Contact>();
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
            system.debug('recordTypeId> inside try>'+recordTypeId);
            LimitSize = Integer.valueOf(LimitSize);
            integer totalCount;
            string query='select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId= \''+recordTypeId +'\'';
            if(showProcessingButton())
            {
                query=query+' and (DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\')'; 
            }
            else
            {
                query=query+' and DCA_Status__c= \'Pending\' and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'';   
            }
            if(recId!=null)
                query=query+' and id >: recId ';
            /*
if(Orderby!=null)
query=query+' ORDER BY '+Orderby+' '+OrderDir; */
            allDCA=Database.query(query+' ORDER BY id ASC'+' limit '+LimitSize);
            //  System.debug('totalCount>>'+totalCount);
            /*
if(showProcessingButton())
allDCA=[select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId=:recordTypeId and (DCA_Status__c='Rejected' or DCA_Status__c='Delete User' or DCA_Status__c='Department Change' ) ];
else
allDCA=[select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId=:recordTypeId and DCA_Status__c='Pending' and DCA_DisciplinaryManager__c=:loggedInUserId ];
system.debug('allDCA list> inside try>'+allDCA); */
            for(Contact contactRecord:allDCA)
            {
                SlotWrapper slotwrap=new SlotWrapper();
                slotwrap.Id=contactRecord.Id;
                slotwrap.Name=contactRecord.Name;
                slotwrap.recordLink='/'+contactRecord.Id;
                slotwrap.DCA_NameofSAPSystem=contactRecord.DCA_NameofSAPSystem__c;
                slotwrap.DCA_AuthType=contactRecord.DCA_AuthType__c;
                slotwrap.DCA_Authorization=contactRecord.DCA_Authorization__c;
                slotwrap.DCA_AuthorizationDescription=contactRecord.DCA_AuthorizationDescription__c;
                slotwrap.DCA_Function=contactRecord.DCA_Function__c;
                slotwrap.DCA_BusinessCase=contactRecord.DCA_BusinessCase__c;
                slotwrap.UserName=contactRecord.DCA_User__r.NT_User__c;
                slotwrap.LastName=contactRecord.DCA_User__r.Name;
                slotwrap.DCA_Risk=contactRecord.DCA_Risk__c;
                slotwrap.DCA_Role=contactRecord.DCA_Role__c;
                slotwrap.DCA_RoleDescription=contactRecord.DCA_RoleDescription__c;
                slotwrap.DCA_LockedBy=contactRecord.DCA_LockedBy__c;
                slotwrap.DCA_ValidFrom=contactRecord.DCA_ValidFrom__c;
                slotwrap.DCA_ValidTo=contactRecord.DCA_ValidTo__c;
                slotwrap.DCA_Department=contactRecord.DCA_Department__c;
                slotwrap.DCA_DepartmentActive=contactRecord.DCA_DepartmentActive__c;
                slotwrap.DCA_Location=contactRecord.DCA_Location__c;
                slotwrap.DCA_Company=contactRecord.DCA_Company__c;
                slotwrap.DCA_Status=contactRecord.DCA_Status__c;
                slotwrap.DCA_ApprovalComment=contactRecord.DCA_ApprovalComment__c;
                slotwrap.DCA_ApprovalDate=contactRecord.DCA_ApprovalDate__c;
                slotwrap.DCA_Approver=contactRecord.DCA_Approver__r.Name;
                slotwrap.UpdateStatusDisabled=false;
                //slotwrap.NoOfRecords=totalCount;
                slotWrapperList.add(slotwrap);
                
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotWrapperList;
        
        
    }
    
    @auraEnabled
    Public static List<SlotWrapper> SearchData(String searchName, String searchAuth,String searchRole,String Orderby, String OrderDir){
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
        id loggedInUserId=UserInfo.getUserId();
        try{
            list<Contact> allDCA=new List<Contact>();
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
            system.debug('recordTypeId> inside try>'+recordTypeId);
            integer totalCount;
            
            string query='select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId= \''+recordTypeId +'\'';
            
            if(showProcessingButton())
            {
                query=query+' and (DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\')'; 
            }
            else
            {
                query=query+' and DCA_Status__c= \'Pending\' and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'';   
            }
            if(searchName!=null)
                query=query+' and (FirstName LIKE \'%' + searchName + '%\''+ 'or LastName  LIKE \'%'+searchName+'%\') ';
            if(searchAuth!=null)
                query=query+' and DCA_AuthType__c LIKE \'%'+String.escapeSingleQuotes(searchAuth)+'%\'';
            if(searchRole!=null)
                query=query+' and DCA_Role__c LIKE \'%'+String.escapeSingleQuotes(searchRole)+'%\'';
            /*
if(Orderby!=null)
query=query+' ORDER BY '+Orderby+' '+OrderDir; */
            System.debug('query::::'+query);
            allDCA=Database.query(query);
            for(Contact contactRecord:allDCA)
            {
                SlotWrapper slotwrap=new SlotWrapper();
                slotwrap.Id=contactRecord.Id;
                slotwrap.Name=contactRecord.Name;
                slotwrap.recordLink='/'+contactRecord.Id;
                slotwrap.DCA_NameofSAPSystem=contactRecord.DCA_NameofSAPSystem__c;
                slotwrap.DCA_AuthType=contactRecord.DCA_AuthType__c;
                slotwrap.DCA_Authorization=contactRecord.DCA_Authorization__c;
                slotwrap.DCA_AuthorizationDescription=contactRecord.DCA_AuthorizationDescription__c;
                slotwrap.DCA_Function=contactRecord.DCA_Function__c;
                slotwrap.DCA_BusinessCase=contactRecord.DCA_BusinessCase__c;
                slotwrap.UserName=contactRecord.DCA_User__r.NT_User__c;
                slotwrap.LastName=contactRecord.DCA_User__r.Name;
                slotwrap.DCA_Risk=contactRecord.DCA_Risk__c;
                slotwrap.DCA_Role=contactRecord.DCA_Role__c;
                slotwrap.DCA_RoleDescription=contactRecord.DCA_RoleDescription__c;
                slotwrap.DCA_LockedBy=contactRecord.DCA_LockedBy__c;
                slotwrap.DCA_ValidFrom=contactRecord.DCA_ValidFrom__c;
                slotwrap.DCA_ValidTo=contactRecord.DCA_ValidTo__c;
                slotwrap.DCA_Department=contactRecord.DCA_Department__c;
                slotwrap.DCA_DepartmentActive=contactRecord.DCA_DepartmentActive__c;
                slotwrap.DCA_Location=contactRecord.DCA_Location__c;
                slotwrap.DCA_Company=contactRecord.DCA_Company__c;
                slotwrap.DCA_Status=contactRecord.DCA_Status__c;
                slotwrap.DCA_ApprovalComment=contactRecord.DCA_ApprovalComment__c;
                slotwrap.DCA_ApprovalDate=contactRecord.DCA_ApprovalDate__c;
                slotwrap.DCA_Approver=contactRecord.DCA_Approver__r.Name;
                slotwrap.UpdateStatusDisabled=false;
                //slotwrap.NoOfRecords=totalCount;
                slotWrapperList.add(slotwrap);
                
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotWrapperList;
        
        
    }
    
    
    @auraEnabled
    Public static List<SlotWrapper> SearchSubmittedData(String searchName, String searchAuth,String searchRole,String Orderby, String OrderDir){
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
            id loggedInUserId=UserInfo.getUserId();
            try{
                list<Contact> allDCA=new List<Contact>();
                Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
                system.debug('recordTypeId> inside try>'+recordTypeId);
                 integer totalCount;
                string query='select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c from Contact where recordTypeId= \''+recordTypeId +'\'';
                if(showProcessingButton())
                {
                    query=query+' and (DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\''; 
                }
                else
                {
                    query=query+' and DCA_Status__c!= \'Pending\' and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'';   
                }
                if(searchName!=null)
                    query=query+' and (FirstName LIKE \'%' + searchName + '%\''+ 'or LastName  LIKE \'%'+searchName+'%\') ';
                if(searchAuth!=null)
                    query=query+' and DCA_AuthType__c LIKE \'%'+String.escapeSingleQuotes(searchAuth)+'%\'';
                if(searchRole!=null)
                    query=query+' and DCA_Role__c LIKE \'%'+String.escapeSingleQuotes(searchRole)+'%\'';
                /*
                if(Orderby!=null)
                    query=query+' ORDER BY '+Orderby+' '+OrderDir; */
                allDCA=Database.query(query);
                for(Contact contactRecord:allDCA)
                {
                    SlotWrapper slotwrap=new SlotWrapper();
                    slotwrap.Id=contactRecord.Id;
                    slotwrap.Name=contactRecord.Name;
                    slotwrap.recordLink='/'+contactRecord.Id;
                    slotwrap.DCA_NameofSAPSystem=contactRecord.DCA_NameofSAPSystem__c;
                    slotwrap.DCA_AuthType=contactRecord.DCA_AuthType__c;
                    slotwrap.DCA_Authorization=contactRecord.DCA_Authorization__c;
                    slotwrap.DCA_AuthorizationDescription=contactRecord.DCA_AuthorizationDescription__c;
                    slotwrap.DCA_Function=contactRecord.DCA_Function__c;
                    slotwrap.DCA_BusinessCase=contactRecord.DCA_BusinessCase__c;
                    slotwrap.UserName=contactRecord.DCA_User__r.NT_User__c;
                    slotwrap.LastName=contactRecord.DCA_User__r.Name;
                    slotwrap.DCA_Risk=contactRecord.DCA_Risk__c;
                    slotwrap.DCA_Role=contactRecord.DCA_Role__c;
                    slotwrap.DCA_RoleDescription=contactRecord.DCA_RoleDescription__c;
                    slotwrap.DCA_LockedBy=contactRecord.DCA_LockedBy__c;
                    slotwrap.DCA_ValidFrom=contactRecord.DCA_ValidFrom__c;
                    slotwrap.DCA_ValidTo=contactRecord.DCA_ValidTo__c;
                    slotwrap.DCA_Department=contactRecord.DCA_Department__c;
                    slotwrap.DCA_DepartmentActive=contactRecord.DCA_DepartmentActive__c;
                    slotwrap.DCA_Location=contactRecord.DCA_Location__c;
                    slotwrap.DCA_Company=contactRecord.DCA_Company__c;
                    slotwrap.DCA_Status=contactRecord.DCA_Status__c;
                    slotwrap.DCA_ApprovalComment=contactRecord.DCA_ApprovalComment__c;
                    slotwrap.DCA_ApprovalDate=contactRecord.DCA_ApprovalDate__c;
                    slotwrap.DCA_Approver=contactRecord.DCA_Approver__r.Name;
                    slotwrap.UpdateStatusDisabled=false;
                   // slotwrap.NoOfRecords=totalCount;
                    slotWrapperList.add(slotwrap);
                    
                }
                
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
            return slotWrapperList;  
    }
    
    @AuraEnabled        
    public static List<String> getPicklistvalues(String field_apiname){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Contact');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(field_apiname).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        boolean showprocess=showProcessingButton();
        for( Schema.PicklistEntry pickListVal : ple){
            if(showprocess && pickListVal.getLabel()=='Processed')
                pickListValuesList.add(pickListVal.getLabel());
            else if(!showprocess && pickListVal.getLabel()!='Processed')
                pickListValuesList.add(pickListVal.getLabel());
        }     
        
        return pickListValuesList;
    }
    
    @auraEnabled
    Public static List<SlotWrapper> fetchSubmittedDetailsNext(Integer LimitSize, Id recId, String Orderby, String OrderDir){
        System.debug('alteast inside');
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
        id loggedInUserId=UserInfo.getUserId();
        try{
            list<Contact> allDCA=new list<contact>();
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
            system.debug('recordTypeId> inside try>'+recordTypeId);
            LimitSize = Integer.valueOf(LimitSize);
            integer totalCount;
            string query='select Id,Name,DCA_NameofSAPSystem__c,DCA_AuthType__c,DCA_Authorization__c,DCA_AuthorizationDescription__c,DCA_Function__c,DCA_BusinessCase__c,DCA_User__r.Name,DCA_User__r.NT_User__c,DCA_Risk__c,DCA_Role__c,DCA_RoleDescription__c,DCA_LockedBy__c,DCA_ValidFrom__c,DCA_ValidTo__c,DCA_Department__c,DCA_DepartmentActive__c,DCA_Location__c,DCA_Company__c,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId= \''+recordTypeId +'\'';
            if(showProcessingButton())
            {   
                query=query+' and DCA_Status__c= \'Processed\'';      
            }
            else
            {
                query=query+' and (DCA_Status__c= \'Approved\' or DCA_Status__c= \'Rejected\' or DCA_Status__c= \'Delete User\' or DCA_Status__c= \'Department Change\') and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\'';
            }
            if(recId!=null)
                query=query+' and id >: recId ';
            /*
if(Orderby!=null)
query=query+' ORDER BY '+Orderby+' '+OrderDir; */
            allDCA=Database.query(query+' limit '+LimitSize);                
            system.debug('allDCA list> inside try>'+allDCA);
            for(Contact contactRecord:allDCA)
            {
                SlotWrapper slotwrap=new SlotWrapper();
                slotwrap.Id=contactRecord.Id;
                slotwrap.Name=contactRecord.Name;
                slotwrap.recordLink='/'+contactRecord.Id;
                slotwrap.DCA_NameofSAPSystem=contactRecord.DCA_NameofSAPSystem__c;
                slotwrap.DCA_AuthType=contactRecord.DCA_AuthType__c;
                slotwrap.DCA_Authorization=contactRecord.DCA_Authorization__c;
                slotwrap.DCA_AuthorizationDescription=contactRecord.DCA_AuthorizationDescription__c;
                slotwrap.DCA_Function=contactRecord.DCA_Function__c;
                slotwrap.DCA_BusinessCase=contactRecord.DCA_BusinessCase__c;
                slotwrap.UserName=contactRecord.DCA_User__r.NT_User__c;
                slotwrap.LastName=contactRecord.DCA_User__r.Name;
                slotwrap.DCA_Risk=contactRecord.DCA_Risk__c;
                slotwrap.DCA_Role=contactRecord.DCA_Role__c;
                slotwrap.DCA_RoleDescription=contactRecord.DCA_RoleDescription__c;
                slotwrap.DCA_LockedBy=contactRecord.DCA_LockedBy__c;
                slotwrap.DCA_ValidFrom=contactRecord.DCA_ValidFrom__c;
                slotwrap.DCA_ValidTo=contactRecord.DCA_ValidTo__c;
                slotwrap.DCA_Department=contactRecord.DCA_Department__c;
                slotwrap.DCA_DepartmentActive=contactRecord.DCA_DepartmentActive__c;
                slotwrap.DCA_Location=contactRecord.DCA_Location__c;
                slotwrap.DCA_Company=contactRecord.DCA_Company__c;
                slotwrap.DCA_Status=contactRecord.DCA_Status__c;
                slotwrap.DCA_ApprovalComment=contactRecord.DCA_ApprovalComment__c;
                slotwrap.DCA_ProcessingComment=contactRecord.DCA_ProcessingComment__c;
                slotwrap.DCA_ApprovalDate=contactRecord.DCA_ApprovalDate__c;
                slotwrap.DCA_Approver=contactRecord.DCA_Approver__r.Name;
                slotwrap.UpdateStatusDisabled=false;
                slotWrapperList.add(slotwrap);
                
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotWrapperList;
        
        
    }
    
    @auraEnabled
    Public static SlotWrapper fetchRecordForUpdateComp(Id recordId){
        SlotWrapper slotwrap=new SlotWrapper();
        try{
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
            system.debug('recordTypeId> inside try>'+recordTypeId);
            Contact contactRecord=[select Id,Name,DCA_Status__c,DCA_ApprovalDate__c,DCA_Approver__r.Name,DCA_ApprovalComment__c,DCA_ProcessingComment__c from Contact where recordTypeId=:recordTypeId and id=:recordId limit 1 ];
            slotwrap.Id=contactRecord.Id;
            slotwrap.Name=contactRecord.Name;
            slotwrap.recordLink='/'+contactRecord.Id;
            slotwrap.DCA_Status=contactRecord.DCA_Status__c;
            slotwrap.DCA_ApprovalComment=contactRecord.DCA_ApprovalComment__c;
            slotwrap.DCA_ProcessingComment=contactRecord.DCA_ProcessingComment__c;
            slotwrap.DCA_ApprovalDate=contactRecord.DCA_ApprovalDate__c;
            slotwrap.DCA_Approver=contactRecord.DCA_Approver__r.Name;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotwrap;
        
        
    }
    @AuraEnabled
    public static string submitRecord(String sheet) {
        String message='SUCCESS';
        try{
            SlotWrapper obj = (SlotWrapper) Json.deserialize(sheet, SlotWrapper.class);
            System.debug('obj>'+obj);
            List<SlotWrapper>userList=obj.userList;
            List<Contact>updateList=new List<Contact>();
            For(SlotWrapper wrapper_record:userList)
            {
                Contact record=new Contact();
                record.DCA_Status__c=obj.DCA_Status;
                if(obj.DCA_Status=='Processed')
                    record.DCA_ProcessingComment__c=obj.DCA_ProcessingComment;
                else
                    record.DCA_ApprovalComment__c=obj.DCA_ApprovalComment;
                
                record.Id=wrapper_record.id;
                updateList.add(record);
            }
            if(updateList.size()>0)
            {
                System.debug('contact list>'+updateList);
                update(updateList); 
            }
            
        }Catch(Exception e)
        {
            System.debug('Error>'+e.getMessage());
            message='Someting went wrong'; 
        }
        return message;
    }
    
    @AuraEnabled
    public static string submitRecordForUpdateComp(String sheet) {
        String message='SUCCESS';
        try{
            SlotWrapper obj = (SlotWrapper) Json.deserialize(sheet, SlotWrapper.class);
            Contact record=new Contact();
            //System.debug('obj>>'+obj.Id+'>>'+obj.DCA_Status+'>>'+obj.DCA_ProcessingComment+'>>'+obj.DCA_ApprovalComment);
            record.DCA_Status__c=obj.DCA_Status;
            if(obj.DCA_Status=='Processed')
                record.DCA_ProcessingComment__c=obj.DCA_ProcessingComment;
            else
                record.DCA_ApprovalComment__c=obj.DCA_ApprovalComment;
            record.Id=obj.Id;
            System.debug('record>>'+record);
            update(record);
            
        }Catch(Exception e)
        {
            System.debug('Error>'+e.getMessage());
            if(e.getMessage().contains(Label.DCA_error6))
                message=Label.DCA_error6; 
            else if(e.getMessage().contains(Label.DCA_error5))
                message=Label.DCA_error5;
            else if(e.getMessage().contains(Label.DCA_error4))
                message=Label.DCA_error4;
            else
                message=Label.DCA_error1;
        }
        return message;
    }
    @auraEnabled
    Public static Boolean showProcessingButton(){
        Boolean showButton=false;
        try{
            List<id> groupUserIds=GetGroupAdminUserList();
            id loggedInUserId=UserInfo.getUserId();
            if(groupUserIds.contains(loggedInUserId))
                showButton=true;              
        }Catch(Exception e)
        {
            System.debug('addBooking>'+e.getMessage());
        }
        return showButton;
    }
    
    public static List<Id> GetGroupAdminUserList()
    {
        List<Id> usersIdsInGroup= new List<Id>();
        Id groupId = [select id,name from Group where name='DCA_ViewUpdatedRecords' limit 1].id;
        List<GroupMember> groupMembers=[Select Id, group.type, UserOrGroupId From GroupMember where group.id=:groupId];
        for(GroupMember gm : groupMembers)
        {
            usersIdsInGroup.add(gm.UserOrGroupId);
        }
        /*  for(User user:[select id,name from user where profile.name=:Label.CLIFv20008 and IsActive=true])
{
usersIdsInGroup.add(user.id);
}
for(user user:[select id,name from user where id in:usersIdsInGroup])
{
System.debug('user name>'+user.name+ ':: userId>'+user.id);
} */
        //   System.debug('current user name>'+[select id,name from user where id=:UserInfo.getUserId()].name+':: id>'+UserInfo.getUserId()); 
        return usersIdsInGroup;
    }
    
    
    public class SlotWrapper {
        
        @AuraEnabled
        public List<SlotWrapper> userList;
        @AuraEnabled
        public String DCA_NameofSAPSystem;
        @AuraEnabled
        public String DCA_AuthType;
        @AuraEnabled
        public String DCA_Authorization;
        @AuraEnabled
        public String DCA_AuthorizationDescription;
        @AuraEnabled
        public String DCA_Function;
        @AuraEnabled
        public String DCA_BusinessCase;
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String recordLink;
        
        @AuraEnabled
        public String DCA_Risk;
        @AuraEnabled
        public String DCA_Role;
        @AuraEnabled
        public String DCA_RoleDescription;
        @AuraEnabled
        public String DCA_LockedBy;
        @AuraEnabled
        public Date DCA_ValidFrom;
        @AuraEnabled
        public Date DCA_ValidTo;
        @AuraEnabled
        public String DCA_Department;
        @AuraEnabled
        public String DCA_DepartmentActive;
        @AuraEnabled
        public String DCA_Location;
        @AuraEnabled
        public String DCA_Company;
        @AuraEnabled
        public String DCA_Status;  
        @AuraEnabled
        public String DCA_ApprovalComment;
        @AuraEnabled
        public String DCA_ProcessingComment;
        @AuraEnabled
        public Date DCA_ApprovalDate;
        
        @AuraEnabled
        public String DCA_Approver; 
        @AuraEnabled
        public Boolean UpdateStatusDisabled;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String ErrorMessage;
        @AuraEnabled
        public Integer NoOfRecords;
        @AuraEnabled
        public Integer NoOfRecordsSubmitted;
        
        
    }
    
    
}