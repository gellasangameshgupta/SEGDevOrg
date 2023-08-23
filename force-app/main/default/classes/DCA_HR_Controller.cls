public class DCA_HR_Controller {
    
    @auraenabled
    public static list<SlotWrapper> returncontact()
    {   Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
        list<Contact> clist = [SELECT Id, Name,DCA_Role__c, DCA_RoleDescription__c, DCA_Risk__c, 
                               DCA_Department__c, DCA_Authorization__c, DCA_AuthorizationDescription__c,
                               DCA_AuthType__c, DCA_Location__c FROM Contact where recordtypeId = :recordTypeId];
        system.debug('data'+cList);
        list<SlotWrapper> returnList = new list<SlotWrapper>();
        for(Contact conObj : clist)
        {
            SlotWrapper wrapperObj = new SlotWrapper();
            wrapperObj.Name = conObj.Name;
            wrapperObj.DCA_Role = ConObj.DCA_Role__c;
            wrapperObj.DCA_RoleDescription = conObj.DCA_RoleDescription__c;
            wrapperObj.DCA_Risk = ConObj.DCA_Risk__c;
            wrapperObj.DCA_Department = conObj.DCA_Department__c;
            wrapperObj.DCA_Authorization = ConObj.DCA_Authorization__c;
            wrapperObj.DCA_AuthorizationDescription = conObj.DCA_AuthorizationDescription__c;
            wrapperObj.DCA_AuthType = ConObj.DCA_AuthType__c;
            wrapperObj.recordLink = '/'+ConObj.Id;
            wrapperObj.DCA_Location = ConObj.DCA_Location__c;
            returnList.add(wrapperObj);
        }
        return returnList;
    }
    
    @auraenabled
    public static list<SlotWrapper> returncontactGeneral(string appName)
    {system.debug('appName '+appName);
     id loggedInUserId=UserInfo.getUserId();
     Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
     list<Contact> clist = [SELECT Id, Name,DCA_Role__c, DCA_RoleDescription__c, DCA_Risk__c,DCA_NameofSAPSystem__c,Creation_Date_HR__c, 
                            DCA_Department__c, DCA_Authorization__c, DCA_AuthorizationDescription__c,DCA_Status__c,
                            DCA_AuthType__c, DCA_Location__c, DCA_Hr_User_Id__c,DCA_Hr_Role_Id__c, DCA_Hr_Target_Population__c,
                            DCA_Hr_Granted_Population__c, DCA_Hr_Country__c, DCA_Hr_Scope__c, DCA_Hr_Function_Access_Profile__c,
                            DCA_Hr_Person_Type__c,DCA_Hr_Products__c,Email,DCA_Hr_Scope_Level__c,DCA_ValidTo__c,DCA_ValidFrom__c
                            FROM Contact where recordtypeId = :recordTypeId
                            and DCA_NameofSAPSystem__c =:appName and DCA_DisciplinaryManager__c=:loggedInUserId order by lastmodifieddate ];
     system.debug('data'+cList);
     list<SlotWrapper> returnList = new list<SlotWrapper>();
     for(Contact conObj : clist)
     {
         SlotWrapper wrapperObj = new SlotWrapper();
         wrapperObj.Id = conObj.Id;
         wrapperObj.Name = conObj.Name;
         wrapperObj.DCA_Role = ConObj.DCA_Role__c;
         wrapperObj.DCA_RoleDescription = conObj.DCA_RoleDescription__c;
         wrapperObj.DCA_Risk = ConObj.DCA_Risk__c;
         wrapperObj.DCA_Department = conObj.DCA_Department__c;
         wrapperObj.DCA_Authorization = ConObj.DCA_Authorization__c;
         wrapperObj.DCA_AuthorizationDescription = conObj.DCA_AuthorizationDescription__c;
         wrapperObj.DCA_AuthType = ConObj.DCA_AuthType__c;
         wrapperObj.recordLink = '/'+ConObj.Id;
         wrapperObj.DCA_Location = ConObj.DCA_Location__c;
         wrapperObj.DCA_Status = ConObj.DCA_Status__c;
         wrapperObj.DCA_Hr_User_Id = conObj.DCA_Hr_User_Id__c;
         wrapperObj.DCA_Hr_Role_Id = ConObj.DCA_Hr_Role_Id__c;
         wrapperObj.DCA_Hr_Target_Population = conObj.DCA_Hr_Target_Population__c;
         wrapperObj.DCA_Hr_Granted_Population = ConObj.DCA_Hr_Granted_Population__c;
         wrapperObj.DCA_Hr_Country = conObj.DCA_Hr_Country__c;
         wrapperObj.DCA_Hr_Scope = ConObj.DCA_Hr_Scope__c;
         wrapperObj.DCA_Hr_Scope_Level = ConObj.DCA_Hr_Scope_Level__c;
         wrapperObj.DCA_Hr_Function_Access_Profile = conObj.DCA_Hr_Function_Access_Profile__c;
         wrapperObj.DCA_Hr_Products = ConObj.DCA_Hr_Products__c;
         wrapperObj.DCA_Hr_Person_Type = ConObj.DCA_Hr_Person_Type__c;
         wrapperObj.Email = ConObj.Email;
         wrapperObj.DCA_ValidFrom = ConObj.DCA_ValidFrom__c;
         wrapperObj.DCA_ValidTo = ConObj.DCA_ValidTo__c;
         wrapperObj.DCA_CreationDate=ConObj.Creation_Date_HR__c;
         returnList.add(wrapperObj);
     }
     return returnList;
    }
    
    @auraenabled
    Public static List<SlotWrapper> SearchData(String searchName, String searchStatus,String searchRole,String Orderby, String OrderDir,string appName){
        List<SlotWrapper> slotWrapperList=new List<SlotWrapper>();
        id loggedInUserId=UserInfo.getUserId();
        try{
            list<Contact> allDCA=new List<Contact>();
             Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
          //  Id recordTypeId = '0129E000000j81EQAQ';
            system.debug('recordTypeId> inside try>'+recordTypeId);
            integer totalCount;
            string query='SELECT Id, Name,DCA_Role__c, DCA_RoleDescription__c,DCA_Status__c,Creation_Date_HR__c, DCA_Risk__c,DCA_NameofSAPSystem__c,DCA_Department__c,'+
                ' DCA_Authorization__c, DCA_AuthorizationDescription__c, DCA_AuthType__c, DCA_Location__c,'+
                'DCA_Hr_User_Id__c,DCA_Hr_Role_Id__c, DCA_Hr_Target_Population__c, DCA_Hr_Granted_Population__c, DCA_Hr_Country__c, DCA_Hr_Scope__c, DCA_Hr_Function_Access_Profile__c,DCA_Hr_Person_Type__c,DCA_Hr_Products__c,Email,DCA_Hr_Scope_Level__c,DCA_ValidTo__c,DCA_ValidFrom__c'
                +' FROM Contact where recordtypeId = \''+recordTypeId +'\'';
            query=query+'and DCA_DisciplinaryManager__c=\''+loggedInUserId +'\''+'and DCA_NameofSAPSystem__c=\''+appName +'\'';   
            
            if(searchName!=null)
                query=query+' and (FirstName LIKE \'%' + searchName + '%\''+ 'or LastName  LIKE \'%'+searchName+'%\') ';
            if(searchStatus!=null)
                query=query+' and DCA_Status__c LIKE \'%'+String.escapeSingleQuotes(searchStatus)+'%\'';
            if(searchRole!=null)
                query=query+' and DCA_Role__c LIKE \'%'+String.escapeSingleQuotes(searchRole)+'%\'';
            system.debug('query '+query);
            allDCA=Database.query(query);
            for(Contact conObj:allDCA)
            {
                SlotWrapper wrapperObj = new SlotWrapper();
                wrapperObj.Name = conObj.Name;
                wrapperObj.Id = conObj.Id;
                wrapperObj.DCA_Role = ConObj.DCA_Role__c;
                wrapperObj.DCA_RoleDescription = conObj.DCA_RoleDescription__c;
                wrapperObj.DCA_Risk = ConObj.DCA_Risk__c;
                wrapperObj.DCA_Department = conObj.DCA_Department__c;
                wrapperObj.DCA_Authorization = ConObj.DCA_Authorization__c;
                wrapperObj.DCA_AuthorizationDescription = conObj.DCA_AuthorizationDescription__c;
                wrapperObj.DCA_AuthType = ConObj.DCA_AuthType__c;
                wrapperObj.recordLink = '/'+ConObj.Id;
                wrapperObj.DCA_Location = ConObj.DCA_Location__c;
                wrapperObj.DCA_Status = ConObj.DCA_Status__c;
                wrapperObj.DCA_Hr_User_Id = conObj.DCA_Hr_User_Id__c;
                wrapperObj.DCA_Hr_Role_Id = ConObj.DCA_Hr_Role_Id__c;
                wrapperObj.DCA_Hr_Target_Population = conObj.DCA_Hr_Target_Population__c;
                wrapperObj.DCA_Hr_Granted_Population = ConObj.DCA_Hr_Granted_Population__c;
                wrapperObj.DCA_Hr_Country = conObj.DCA_Hr_Country__c;
                wrapperObj.DCA_Hr_Scope = ConObj.DCA_Hr_Scope__c;
                wrapperObj.DCA_Hr_Scope_Level = ConObj.DCA_Hr_Scope_Level__c;
                wrapperObj.DCA_Hr_Function_Access_Profile = conObj.DCA_Hr_Function_Access_Profile__c;
                wrapperObj.DCA_Hr_Products = ConObj.DCA_Hr_Products__c;
                wrapperObj.DCA_Hr_Person_Type = ConObj.DCA_Hr_Person_Type__c;
                wrapperObj.Email = ConObj.Email;
                wrapperObj.DCA_ValidFrom = ConObj.DCA_ValidFrom__c;
                wrapperObj.DCA_ValidTo = ConObj.DCA_ValidTo__c;
                wrapperObj.DCA_CreationDate=ConObj.Creation_Date_HR__c;
                slotWrapperList.add(wrapperObj);
                
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return slotWrapperList;
        
        
    }
    
    @auraenabled        
    public static List<String> getPicklistvalues(String field_apiname){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Contact');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(field_apiname).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //  boolean showprocess=showProcessingButton();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        
        return pickListValuesList;
    }
    
    @auraenabled  
    public static string submitRecord(String sheet,string appName) {
        system.debug('inside eeehaaaaaa');
        String message='SUCCESS';
        try{
            set<string>emailSet = new set<string>();
            SlotWrapper obj = (SlotWrapper) Json.deserialize(sheet, SlotWrapper.class);
            System.debug('obj>'+obj);
            system.debug('obj.DCA_Status '+obj.DCA_Status);
            List<SlotWrapper>userList=obj.userList;system.debug('newsize '+userList.size());
            if(obj.DCA_Status == 'Delete User')
            {
                for(SlotWrapper wrapper_record:userList)
                {
                    emailSet.add(wrapper_record.Email);
                }
                list<contact> cList = [select id, name,DCA_Status__c,DCA_ApprovalComment__c,DCA_NameofSAPSystem__c,Email from contact where email in :emailSet and DCA_NameofSAPSystem__c =:appName ];
                list<SlotWrapper> deletSlotWrapperList = new list<SlotWrapper>();
                for(Contact conObj:cList)
                {
                    SlotWrapper wrapperObj = new SlotWrapper();
                    wrapperObj.Name = conObj.Name;
                    wrapperObj.Id = conObj.Id;
                    deletSlotWrapperList.add(wrapperObj);
                }
                system.debug('newsize '+deletSlotWrapperList.size());
                // userList.addAll(deletSlotWrapperList);
                userList = deletSlotWrapperList;
            }system.debug('newsize '+userList.size());
            List<Contact>updateList=new List<Contact>();
            For(SlotWrapper wrapper_record:userList)
            {
                Contact record=new Contact();
                record.DCA_Status__c=obj.DCA_Status;
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
    
    public class SlotWrapper {
        
        @AuraEnabled
        public List<SlotWrapper> userList;
        @AuraEnabled
        public List<SlotWrapper> recordSlotWrapper;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String DCA_Role;
        @AuraEnabled
        public String DCA_RoleDescription;
        @AuraEnabled
        public String DCA_Risk;
        @AuraEnabled
        public String DCA_Department;
        @AuraEnabled
        public String DCA_Authorization;
        @AuraEnabled
        public String DCA_AuthorizationDescription;
        @AuraEnabled
        public String DCA_AuthType;
        @AuraEnabled
        public String recordLink;
        @AuraEnabled
        public String DCA_Location ;
        @AuraEnabled
        public String DCA_Status ;
        @AuraEnabled
        public String DCA_ApprovalComment;
        @AuraEnabled
        public String Id;
        
        
        @AuraEnabled
        public String DCA_Hr_User_Id;
        @AuraEnabled
        public String DCA_Hr_Role_Id;
        @AuraEnabled
        public String DCA_Hr_Target_Population ;
        @AuraEnabled
        public String DCA_Hr_Granted_Population ;
        @AuraEnabled
        public String DCA_Hr_Country;
        @AuraEnabled
        public String DCA_Hr_Scope;
        @AuraEnabled
        public String DCA_Hr_Scope_Level;
        @AuraEnabled
        public String DCA_Hr_Function_Access_Profile ;
        @AuraEnabled
        public String DCA_Hr_Person_Type ;
        @AuraEnabled
        public String DCA_Hr_Products;
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public Date DCA_ValidFrom;
        @AuraEnabled
        public Date DCA_ValidTo;
        @AuraEnabled
        public Date DCA_CreationDate;
        
        
    }
    
    
    
}