/*******************************************************************************************************
* 
* @ Name    :   IP_CreateChildIPRightController
* @ Purpose :   Controller for CreateChildIPRightTable Component
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_CreateChildIPRightControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public without sharing Class IP_CreateChildIPRightController {
    
    @auraEnabled
    public static Case getIPRight(String IPRightId){
        system.debug('case Details ::: '+ IPRightId);
        Case ipRight=[select Id, Status, Subject, IP_Country__c, IP_Type_of_Right__c,IP_Right_ID__c,
                      ParentId,Parent.IP_Right_ID__c,
                      IP_Patent_Family__c,IP_Patent_Family__r.IP_Patent_Family_ID__c,
                      IP_Product_Type__c,IP_Product_Subcategories__c, 
                      IP_InventionName__c,IP_InventionName__r.IP_IDFNumber__c,
                      IP_Right_Status__c,IP_All_Inventors__c,IP_Relationship_to_Parent__c,
                      IP_Law_Firm_Reference__c,IP_Firm_Attorney__c,IP_Law_Firm__c,IP_Law_Firm_Text__c
                      from Case Where Id =:IPRightId AND IP_Right_ID__c != Null ];
        return ipRight;
    }
    @auraEnabled
    public static map<string, integer> getCountOfChildCountry(String IPRightId){
        system.debug('case Details ::: '+ IPRightId);
        Case ipRight=[select Id, Status, Subject, IP_Country__c,IP_InventionName__c
                      from Case Where Id =:IPRightId AND IP_Right_ID__c != Null ];
        string Invention = ipRight.IP_InventionName__c;
        map<string, integer> countryCountMap = new map<string,integer>();
        //string ParentCountry = ipRight.IP_Country__c;
        List<IP_Country__mdt> countryList= [select Id, IP_Country__c, MasterLabel, DeveloperName from IP_Country__mdt];
        //countryCountMap.put(ipRight.IP_Country__c, 0);
        for(IP_Country__mdt countryObj :countryList)
        {
            countryCountMap.put(countryObj.DeveloperName,0);
        }
        list<Case> ipRightChild=[select Id, Status, Subject, IP_Country__c,ParentId 
                                 from Case Where IP_InventionName__c  =:Invention AND IP_Country__c != Null ];
        system.debug('ipRightChild ::: '+ ipRightChild);
        if(!ipRightChild.isEmpty())
        {system.debug('inside');
         for(case caseObj : ipRightChild)
         {system.debug('countryCountMap.get(caseObj.IP_Country__c)'+countryCountMap.get(caseObj.IP_Country__c));
          if(countryCountMap.get(caseObj.IP_Country__c)!= NULL)
          {
              integer count = countryCountMap.get(caseObj.IP_Country__c) + 1;
              countryCountMap.put(caseObj.IP_Country__c , count);
          }
          else 
          {
              countryCountMap.put(caseObj.IP_Country__c , 1);
          }
         }
        }
        system.debug('countryCountMap '+countryCountMap);
        return countryCountMap;
    }
    
    @AuraEnabled
    public static String getAppendValue(String SelectedVal){
        // create map  
        Map<String,String> Mymap = new Map<String,String>();
        // put value in Map
        Mymap.put('Inter Partes Reexamination','IPR');
        Mymap.put('Ex Parte Reexamination','EPR');
        Mymap.put('Supplemental Examination','SUP');
        Mymap.put('Reissue','RE');
        Mymap.put('Divisional','DIV');
        Mymap.put('Continuation-in-part','CIP');
        Mymap.put('Continuation','CON');
        
        if(Mymap.containsKey(SelectedVal)){
            return Mymap.get(SelectedVal);
        }
        
        return null;
    }
    @AuraEnabled
    public static Map<String, String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        Map<String, String> options = new Map<String, String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            options.put('--None--','--None--');
        }
        for (Schema.PicklistEntry pv : picklistValues) {
            options.put(pv.getValue(), pv.getLabel());
        }
        return options;
    }
    
    @auraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<String> selectedList ,String recordID) {
        //  String searchKey = searchKeyWord + '%';
        Set<String> countryList= new Set<String>();
        Case newCase= [Select Id ,IP_Country__c, IP_Patent_Family__c ,IP_Patent_Family__r.Id ,IP_Patent_Family__r.IP_Patent_Family_ID__c , RecordTypeId,RecordType.name  from Case Where Id =:recordID];
        
        List <case> newList=[select Id , IP_Right_ID__c,IP_Country__c from case WHERE IP_Patent_Family__c = :newCase.IP_Patent_Family__c ];
        
        Set<Case> myset = new Set<Case>();
        List<String> result = new List<String>();
        myset.addAll(newList);
        
        for (Case css : myset)
        {
            countryList.add(css.IP_Country__c);
        }
        result.addAll(countryList);
        
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        if(ObjectName != null && ObjectName == 'IP_Country__mdt' && selectedList != null) 
        {
            String sQuery =  'select Id, IP_Country__c, MasterLabel, DeveloperName';
            sQuery += ' from ' +ObjectName;
            sQuery += ' where IP_Country__c LIKE \'%'+searchKeyWord+'%\' AND Id Not IN:selectedList order by DeveloperName DESC limit 5';
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }else if(ObjectName != null && ObjectName == 'User')
        {
            string roleName='IP_Law Firm';
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records   
            String sQuery =  'select id, Name,Email, UserRoleId, UserRole.Name ';
            sQuery += ' from ' +ObjectName;
            sQuery += ' where Name LIKE \'%'+searchKeyWord+'%\' And isActive=true AND UserRole.Name =:roleName order by createdDate DESC limit 5';  
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            } 
        }
        for(Integer i=0 ; i < result.size() ; i++)
        {
            for(Integer j=0 ; j < returnList.size() ; j++)
            {
                String qwe= String.valueOf(returnList.get(j).get('IP_Country__c')) ;
                String concat = qwe.substring(0,2);
                
                if ( concat == result.get(i))  {
                    //returnList.remove(j); 
                }
            }
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List<Case> getInsertChildIPRight(String IPRecordId, List<Case> insertList)
    {
        Id ipRightRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IP Right').getRecordTypeId();
        List<Case> insertIPRightChild = new List<Case>();
        if(!String.isBlank(IPRecordId) && insertList.size() > 0)
        {
            Case ipRight=[select Id, Status, Subject, IP_Country__c, IP_Type_of_Right__c,IP_Right_ID__c,
                          ParentId,IP_Patent_Family__c,IP_Patent_Family__r.Id,IP_Product_Type__c,IP_Product_Subcategories__c, 
                          IP_InventionName__c,IP_InventionName__r.Id, IP_Right_Status__c,IP_All_Inventors__c,IP_Relationship_to_Parent__c,IP_Provisional__c,
                          IP_Law_Firm_Reference__c,IP_Firm_Attorney__c,IP_Law_Firm__c,IP_ProductClass__c,IP_Law_Firm_Text__c
                          from Case Where Id =:IPRecordId AND IP_Right_ID__c != Null ];
            
            for(Case insertipRight:insertList)
            {
                insertipRight.ParentId = ipRight.Id;
                insertipRight.IP_Provisional__c = ipRight.IP_Provisional__c;
                insertipRight.RecordtypeId = ipRightRecType;
                insertipRight.Subject = ipRight.Subject;
                insertipRight.IP_Product_Type__c = ipRight.IP_Product_Type__c;
                insertipRight.IP_Product_Subcategories__c = ipRight.IP_Product_Subcategories__c;
                insertipRight.IP_Status__c = 'Approved for Filing';
                insertipRight.IP_InventionName__c = ipRight.IP_InventionName__r.Id;
                insertipRight.IP_Right_Status__c = 'Not Filed';
                insertipRight.IP_All_Inventors__c = ipRight.IP_All_Inventors__c;
                insertipRight.IP_Patent_Family__c = ipRight.IP_Patent_Family__r.Id;
                insertipRight.IP_ProductClass__c =  ipRight.IP_ProductClass__c;
                
                insertIPRightChild.add(insertipRight);
            }
            if(insertIPRightChild.size() > 0)
                try {
                    Database.Insert(insertIPRightChild, false);
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
            //Database.Insert(insertIPRightChild, false);
        }
        return insertIPRightChild;
    }
    
    @auraEnabled
    public static List<item> getFamilyTree(String IPRightId){
        // To Send this List of Items to Client Side Controller
        
        List<item> childIPRight1 = new List<item>();
        Map<Id, List<Case>> pMap= new Map<Id, List<Case>>();
        if(!string.isBlank(IPRightId))
        {
            Case ipRight = new Case();
            Case recordTypeCheck = [select Id, RecordTypeId, RecordType.Developername 
                                    from Case Where Id =:IPRightId];
            if(recordTypeCheck !=  null && recordTypeCheck.RecordType != null
               && recordTypeCheck.RecordType.Developername ==System.Label.IP_PatentFamily_RecordType_Name){
                   ipRight=[select Id, Status, ParentId,IP_Patent_Family__c, IP_Patent_Family__r.Id,  
                            recordTypeId, recordType.Developername
                            from Case Where IP_Patent_Family__c=:recordTypeCheck.Id AND IP_Right_ID__c != Null LIMIT 1 ];
               }else if(recordTypeCheck !=  null && recordTypeCheck.RecordType != null
                        && recordTypeCheck.RecordType.Developername ==System.Label.IP_IPRight_RecordType_Name)
               {
                   ipRight=[select Id, Status, ParentId,IP_Patent_Family__c, IP_Patent_Family__r.Id,  
                            recordTypeId, recordType.Developername
                            from Case Where Id =:IPRightId AND IP_Right_ID__c != Null ];
               }
            
            if(ipRight != null && ipRight.IP_Patent_Family__r.Id != null){
                
                for(Case pinfo:[Select Id, Subject, IP_Country__c,IP_Right_ID__c, IP_Status_Color__c,
                                ParentId,IP_Patent_Family__c,IP_Patent_Family__r.Id from case
                                Where IP_Patent_Family__r.Id =:ipRight.IP_Patent_Family__r.Id])
                {  
                    
                    if (pMap.containsKey(pinfo.ParentId)) {
                        pMap.get(pinfo.ParentId).add(pinfo);
                    }
                    else {
                        pMap.put(pinfo.ParentId, new List<Case>{pinfo});
                    }
                }
            }
            
            if(pMap.size() > 0){
                // Parent - Level 1 Query for Parent Record
                for(Case level1: [select Id, Status, ParentId,IP_Patent_Family__c,IP_Right_ID__c, IP_Patent_Family__r.Id, IP_Status_Color__c,IP_Country__c
                                  from Case Where ParentId = null AND IP_Patent_Family__r.Id =:ipRight.IP_Patent_Family__r.Id])
                {
                    List<item> childIPRight2= new List<item>();
                    // Level 2 - Parent has no of Childs
                    if(pMap.ContainsKey(level1.Id) && pMap.get(level1.id) != null){
                        for(Case level2: pMap.get(level1.Id)){
                            List<item> childIPRight3 = new List<item>();
                            // Level 3 - Parent has no of Childs
                            if(pMap.ContainsKey(level2.Id) && pMap.get(level2.id) != null){
                                for(Case level3:pMap.get(level2.id)){
                                    List<item> childIPRight4 = new List<item>();
                                    // Level 4 - Parent has no of Childs
                                    if(pMap.ContainsKey(level3.Id) && pMap.get(level3.id) != null){
                                        for(Case level4:pMap.get(level3.id)){
                                            List<item> childIPRight5 = new List<item>();
                                            // Level 5 - Parent has no of Childs
                                            if(pMap.ContainsKey(level4.Id) && pMap.get(level4.id) != null){
                                                for(Case level5:pMap.get(level4.id)){
                                                    if(level5.IP_Country__c != null)
                                                    {
                                                        item childIP5 = new item(level5.IP_Country__c+':'+level5.IP_Right_ID__c, String.valueOf(level5.Id), false, null);
                                                        childIPRight5.add(childIP5);
                                                    }
                                                    else{
                                                        item childIP5 = new item(level5.IP_Right_ID__c, String.valueOf(level5.Id), false, null);
                                                        childIPRight5.add(childIP5);
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            if(level4.IP_Country__c != null)
                                            {
                                                item childIP4 = new item(level4.IP_Country__c+':'+level4.IP_Right_ID__c, String.valueOf(level4.Id), false, childIPRight5);
                                                childIPRight4.add(childIP4);
                                            }
                                            else{
                                                item childIP4 = new item(level4.IP_Right_ID__c, String.valueOf(level4.Id), false, childIPRight5);
                                                childIPRight4.add(childIP4); 
                                            }
                                        }
                                    }
                                    if(level3.IP_Country__c != null)
                                    {
                                        item childIP3 = new item(level3.IP_Country__c+':'+level3.IP_Right_ID__c, String.valueOf(level3.Id), false, childIPRight4);
                                        childIPRight3.add(childIP3);
                                    }
                                    else{
                                        item childIP3 = new item(level3.IP_Right_ID__c, String.valueOf(level3.Id), false, childIPRight4);
                                        childIPRight3.add(childIP3);
                                        
                                    }
                                }
                            }
                            
                            //add contact items
                            if(level2.IP_Country__c != null)
                            {
                                item childIP2 = new item(level2.IP_Country__c+':'+level2.IP_Right_ID__c, String.valueOf(level2.Id), false, childIPRight3);
                                childIPRight2.add(childIP2);
                            }
                            else {
                                item childIP2 = new item(level2.IP_Right_ID__c, String.valueOf(level2.Id), false, childIPRight3);
                                childIPRight2.add(childIP2);
                                
                            }
                        }
                    }
                    //add account items
                    if(level1.IP_Country__c != null)
                    {
                        item childIP1 = new item(level1.IP_Country__c+':'+level1.IP_Right_ID__c, String.valueOf(level1.Id), true, childIPRight2);
                        childIPRight1.add(childIP1); 
                    }
                    else{
                        item childIP1 = new item(level1.IP_Right_ID__c, String.valueOf(level1.Id), true, childIPRight2);
                        childIPRight1.add(childIP1);
                        
                    }
                }
                
            }
        }
        return childIPRight1;
    }
    
    //Item Wrapper Class
    public class item{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
        @AuraEnabled
        public List<item> items {get; set;}
        
        public item(String label, String name, Boolean expanded, List<item> items){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            this.items = items;
        }
    }
}