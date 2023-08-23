/*
* @ Name        : DCA_ContactTriggerHandler
* @ Purpose     : Handler for Trigger on Contact
* @ Test Class  : DetectiveControlsAutomationApexTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 08-06-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version

*******************************************************************************************************/
public class DCA_ContactTriggerHandler {
    
    public static void UpdateRecordDetails(List<Contact> Triggernew)
    {
        id loggedInUserId=UserInfo.getUserId();
        for(Contact record:Triggernew)
        {
            record.DCA_Approver__c=loggedInUserId;
            record.DCA_ApprovalDate__c=System.today();
        }
    }
    
    public static void updateDCAHRroleDetails(List<Contact> ContactList)
    {
        List<DCA_HR_Roles__c> HRroleList = [SELECT Id, Name, For_CCA_in_App__c, For_CCA_with_role__c, HR_App__c, Risk_Assessment_Type__c, 
                                            Role_Id__c, Role_Name__c, Role_Description__c FROM DCA_HR_Roles__c];
        system.debug('HRroleList '+HRroleList);
        map<string,string> roleNameMap = new map<string,string>();
        map<string,string> roleDescmap = new map<string,string>();
        map<string,string> roleRiskMap = new map<string,string>();
        if(HRroleList.size() >0)
        {
            for(DCA_HR_Roles__c RoleObj : HRroleList )
            {
                if(RoleObj.Role_Id__c != NULL && RoleObj.Role_Name__c != NULL )
                    roleNameMap.put(RoleObj.Role_Id__c,RoleObj.Role_Name__c) ;
                if(RoleObj.Role_Id__c != NULL && RoleObj.Role_Description__c != NULL )
                    roleDescmap.put(RoleObj.Role_Id__c,RoleObj.Role_Description__c) ;
                if(RoleObj.Role_Id__c != NULL && RoleObj.Risk_Assessment_Type__c != NULL )
                    roleRiskMap.put(RoleObj.Role_Id__c,RoleObj.Risk_Assessment_Type__c) ;
            }
        }
        
        system.debug('roleNameMap '+roleNameMap);
        system.debug('roleDescmap '+roleDescmap);
        system.debug('roleRiskMap '+roleRiskMap);
        for(Contact contactObj :ContactList )
        {
            contactObj.DCA_Role__c = roleNameMap.get(contactObj.DCA_Hr_Role_Id__c);
            contactObj.DCA_RoleDescription__c = roleDescmap.get(contactObj.DCA_Hr_Role_Id__c);
            contactObj.DCA_Risk__c  = roleRiskMap.get(contactObj.DCA_Hr_Role_Id__c);
        }
    }
    
    public static void updateDCAHRStatus(List<Contact> ContactList)
    {
        string HRappName = ContactList[0].DCA_NameofSAPSystem__c;
        string status = '';
        set<string>emailSet = new set<string>();
        set<id>idSet = new set<id>();
        for(Contact cObj:ContactList)
        {
            emailSet.add(cObj.Email);
            idSet.add(cObj.id);
        }
        system.debug('idSet '+idSet);
        list<contact> cList = [select id, name,DCA_Status__c,DCA_ApprovalComment__c,DCA_NameofSAPSystem__c,Email from contact where
                               email in :emailSet and DCA_NameofSAPSystem__c =:HRappName and id not in :idSet ];
         system.debug('cList '+cList.size());
        for(Contact cObj:cList)
        {
           
          cObj.DCA_Status__c = status;
        }system.debug('cList '+cList);
        update cList;       
    }
}