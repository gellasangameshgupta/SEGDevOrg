/*******************************************************************************************************
* 
* @ Name    :   IP_InventionDisclosureController
* @ Purpose :   Controller for IP_InventionDisclosure Component
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_InventionDisclosureControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public with sharing class IP_InventionDisclosureController {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues( ) {
        id userId = userInfo.getUserId();            
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select id,Name,Email from user  where id =:userId';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @auraEnabled
    public static string createInventionDisclosure(Case invDisclosure, String inventors){
        if(invDisclosure!=NULL){
            String encryptedFields = Label.IP_EncryptedFields;
            list<String> encryptedFieldsList = encryptedFields.split(',');
            for(String enc: encryptedFieldsList){
                if(invDisclosure.get(enc)!=NULL &&invDisclosure.get(enc)!=''){
                    String encryptDataString = encryptData((String)invDisclosure.get(enc));
                    invDisclosure.put(enc, encryptDataString);
                }
            }
            invDisclosure.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invention Disclosure').getRecordTypeId();
            
            database.saveresult res = database.insert(invDisclosure,false);
            if(res.isSuccess()){
                System.debug('Inside Success ');
                list<String> inventorList = (List<String>)JSON.deserialize(inventors, list<String>.class);
                List<User> inventorUserList = [Select Id,Name,Email from User where Id IN :inventorList];
                list<Case> insertInventorList = new list<Case>();
                if(inventorUserList.size()>0){
                    for(User inv : inventorUserList){
                        Case inventor = new Case();
                        inventor.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inventor').getRecordTypeId();
                        inventor.IDF_Name__c = res.getId();
                        inventor.IP_Inventor_User__c = inv.Id;
                        inventor.IP_Inventor_Name__c = inv.Name;
                        inventor.IP_Inventor_Email__c = inv.Email;
                        
                        list<String> inventionTech = invDisclosure.IP_Inventors_Technical__c.split(';');
                        
                        for(String stt: inventionTech){
                            list<string> sts = stt.split(':');
                            if(inv.Id ==sts[0])
                            {
                                Decimal shareval= Decimal.valueOf(sts[1]);
                                inventor.IP_Invention_Share__c= shareval;  
                            }
                            sts.clear();
                        }
                        insertInventorList.add(inventor);
                    }
                }
                if(insertInventorList.size()>0){
                    try {
                        database.insert(insertInventorList, false);
                    } catch(Exception e) {
                        IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                    }
                }
                return res.getId();
            }else{
                return null;
            }
        }
        return null;
    }
    @auraEnabled
    public static string updateInventionDisclosure(Case invDisclosure, String inventors){
        if(invDisclosure!=NULL){
            String encryptedFields = Label.IP_EncryptedFields;
            list<String> encryptedFieldsList = encryptedFields.split(',');
            for(String enc: encryptedFieldsList){
                if(invDisclosure.get(enc)!=NULL &&invDisclosure.get(enc)!=''){
                    String encryptDataString = encryptData((String)invDisclosure.get(enc));
                    invDisclosure.put(enc, encryptDataString);
                }
            }
            database.saveresult res = database.update(invDisclosure,false);
            if(res.isSuccess()){
                if(String.isNotBlank(inventors)){
                    list<String> inventorList = (List<String>)JSON.deserialize(inventors, list<String>.class);
                    String shareString = invDisclosure.IP_Inventors_Technical__c;
                    List<case> deleteInventorList=[select id, IDF_Name__c, IP_Inventor_User__c, IP_Inventor_Name__c, IP_Inventor_Email__c ,IP_Invention_Share__c from case where IDF_Name__c=:res.getId() AND RecordType.name='Inventor'];
                    
                    if(deleteInventorList.size()>0)
                    {
                        try {
                            database.delete(deleteInventorList, false);
                        } catch(Exception e) {
                            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                        }
                    }
                    List<User> inventorUserList = [Select Id,Name,Email from User where Id IN :inventorList];
                    list<Case> insertInventorList = new list<Case>();
                    if(inventorUserList!=NULL && inventorUserList.size()>0 && inventorList.size()>0){
                        
                        for(User inv : inventorUserList){
                            Case inventor = new Case();
                            inventor.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inventor').getRecordTypeId();
                            inventor.IDF_Name__c = res.getId();
                            inventor.IP_Inventor_User__c = inv.Id;
                            inventor.IP_Inventor_Name__c = inv.Name;
                            inventor.IP_Inventor_Email__c = inv.Email;
                            
                            list<String> inventionTech = shareString.split(';');
                            for(String stt: inventionTech){
                                list<string> sts = stt.split(':');
                                if(inv.Id ==sts[0])
                                {
                                    Decimal shareval= Decimal.valueOf(sts[1]);
                                    inventor.IP_Invention_Share__c= shareval;  
                                }
                                sts.clear();
                            }
                            insertInventorList.add(inventor);
                        }
                        if(insertInventorList.size()>0){
                            try {
                                database.insert(insertInventorList, false);
                            } catch(Exception e) {
                                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                            }
                        }
                    }
                }
                return invDisclosure.Id;
            }else{
                return null;
            }
        }
        return null;
    }
    
    @auraEnabled
    public static Case getInventionDisclosure(String recid){
        String encryptedFields = Label.IP_EncryptedFields;
        list<String> encryptedFieldsList = encryptedFields.split(',');
        Case cs = [Select Id, IP_Comment_on_RFI__c,
                   Subject,IP_Invention_Created_as_Part_of_Work__c,IP_Product_Type__c,
                   IP_Product_Subcategories__c,IP_Inventors__c,IP_Who_Initiated_the_Subject__c,Origin,
                   IP_Reason_for_Working_on_That_Subject__c,Priority,IP_Special_Points_to_be_Considered__c, 
                   IP_Is_there_Contribution_of_the_Company__c, IP_Explanation_of_Special_Points__c, 
                   IP_Fill_Form_or_Upload_IDF__c from Case where Id=:recid];
        for(String enc: encryptedFieldsList){
            if(cs.get(enc)!=NULL){
                // blob csvBody = EncodingUtil.base64Decode((String)cs.get(enc));
                String decryptedDataString = decryptData((String)cs.get(enc));
                cs.put(enc, decryptedDataString);
            }
        }
        return cs;
    }
    
    @auraEnabled
    public static Integer getAttachmentCount(String recid){
        Integer count;
        List<ContentDocumentLink> cdlList = [select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recid];
        count = cdlList.size();
        return count;
    }
    
    @auraEnabled
    public static list<inventors> fetchInventors(String recid){
        Set<Id> useridSet = new set<Id>();
        List<inventors> inventorsList = new list<inventors>();
        //list<User> userList = new list<User>();
        List < sObject > returnList = new List < sObject > ();
        Map<String, Decimal> caseMap = new map<String, Decimal>(); 
        Case css = [Select Id, IP_Inventors_Technical__c from Case where Id=:recid];
        if(String.isNotBlank(css.IP_Inventors_Technical__c)){
            list<String> invtech = css.IP_Inventors_Technical__c.split(';');
            for(String st: invtech){
                list<string> stt = st.split(':');
                Decimal shareval= Decimal.valueOf(stt[1]);
                caseMap.put(stt[0], shareval);
            } 
        }
        List<case> newInventorList=[select id, IDF_Name__c, IP_Inventor_User__c, IP_Inventor_Name__c, IP_Inventor_Email__c ,IP_Invention_Share__c from case where IDF_Name__c=:recid];
        for(case us: newInventorList){
            inventors inv = new inventors();
            inv.Name = us.IP_Inventor_Name__c;
            inv.Email = us.IP_Inventor_Email__c;
            inv.Id = us.IP_Inventor_User__c;
            inv.share = us.IP_Invention_Share__c;
            inventorsList.add(inv);
        }
        return inventorsList;
    }
    
    @auraEnabled
    public static list<Case> fetchInventionDisclosures(){
        String encryptedFields = Label.IP_EncryptedFields;
        List<String> encryptedFieldsList = encryptedFields.split(',');
        List<Case> caselist = new List<Case>();
        Id invDisclosureRecordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invention Disclosure').getRecordTypeId();
        for(Case cs: [Select Id,IP_IDFNumber__c,IP_Invention_Part_of_Entrusted_Research__c,IP_am_employed_at_SEG_Automotive_Germany__c, 
                      IP_Prior_Art__c,IP_Problem_Solved__c,IP_Invention_Description__c,
                      IP_Proveof_Invention_onCompetitorProduct__c,IP_Use_of_Invention_by_Us__c,
                      IP_Invention_Created_as_Part_of_Work__c,Status,CaseNumber,Subject,IP_Product_Type__c,IP_Status__c,
                      IP_Product_Subcategories__c,IP_Inventors__c,IP_Who_Initiated_the_Subject__c,Origin,
                      IP_Reason_for_Working_on_That_Subject__c,Priority,
                      IP_Special_Points_to_be_Considered__c, IP_Is_there_Contribution_of_the_Company__c, 
                      IP_Explanation_of_Special_Points__c, IP_Fill_Form_or_Upload_IDF__c, IP_Comment_on_RFI__c from Case where recordtypeId=:invDisclosureRecordtype AND OwnerId=:userinfo.getUserId() order by createddate desc]){
                          for(String enc: encryptedFieldsList){
                              if(cs.get(enc)!=NULL){
                                  // blob csvBody = EncodingUtil.base64Decode((String)cs.get(enc));
                                  String decryptedDataString = decryptData((String)cs.get(enc));
                                  cs.put(enc, decryptedDataString);
                              }
                          }
                          caselist.add(cs);
                      }
        return caselist;
    }
    
    public static String encryptData(String data){
        Blob key = Blob.valueOf(Label.IP_SEGPrivateKey);
        Blob blobdata = Blob.valueOf(data);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, blobdata);
        String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
        return encryptedDataString;
    }
    
    public static String decryptData(String dataval){
        try{
            blob data = EncodingUtil.base64Decode(dataval);
            Blob key = Blob.valueOf(Label.IP_SEGPrivateKey);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, data);
            String decryptedDataString = decryptedData.toString();
            return decryptedDataString;
        }catch(exception e){
            return dataval;
        }
    }
    
    @AuraEnabled
    public static fieldLabelAndHelpText getProductTypeOptions(){
        fieldLabelAndHelpText wrp=new fieldLabelAndHelpText();
        List<String> options = new List<String>();
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        Schema.DescribeFieldResult fieldResult = Case.IP_Product_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry: pList) {
            options.add(entry.getLabel()); 
        }
        wrp.productTypeOptions=options;
        dependentPicklistValues = getFieldDependencies('Case', 'IP_Product_Type__c', 'IP_Product_Subcategories__c');
        
        wrp.contorlingAnddependentvalues=dependentPicklistValues;
        wrp.titleLabel=Case.Subject.getDescribe().getLabel();
        wrp.titleHelptext=Case.Subject.getDescribe().getInlineHelpText();
        wrp.productTypeLabel=Case.IP_Product_Type__c.getDescribe().getLabel(); 
        wrp.inventionCreatedasPartofWorkLabel=Case.IP_Invention_Created_as_Part_of_Work__c.getDescribe().getLabel();
        wrp.inventionCreatedasPartofWorkHelptext=Case.IP_Invention_Created_as_Part_of_Work__c.getDescribe().getInlineHelpText();
        wrp.whoInitiatedtheSubjectLabel=Case.IP_Who_Initiated_the_Subject__c.getDescribe().getLabel();
        wrp.whoInitiatedtheSubjectHelptext=Case.IP_Who_Initiated_the_Subject__c.getDescribe().getInlineHelpText();
        wrp.reasonforWorkingonThatSubjectLabel=Case.IP_Reason_for_Working_on_That_Subject__c.getDescribe().getLabel();
        wrp.reasonforWorkingonThatSubjectHelptext=Case.IP_Reason_for_Working_on_That_Subject__c.getDescribe().getInlineHelpText();
        wrp.isthereContributionoftheCompanyLabel=Case.IP_Is_there_Contribution_of_the_Company__c.getDescribe().getLabel();
        wrp.isthereContributionoftheCompanyHelptext=Case.IP_Is_there_Contribution_of_the_Company__c.getDescribe().getInlineHelpText();
        wrp.specialPointstobeConsideredLabel=Case.IP_Special_Points_to_be_Considered__c.getDescribe().getLabel();
        wrp.specialPointstobeConsideredHelptext=Case.IP_Special_Points_to_be_Considered__c.getDescribe().getInlineHelpText();
        wrp.explanationofSpecialPointsLabel=Case.IP_Explanation_of_Special_Points__c.getDescribe().getLabel();
        wrp.explanationofSpecialPointsHelptext=Case.IP_Explanation_of_Special_Points__c.getDescribe().getInlineHelpText();
        wrp.explanationofSpecialPointsPlaceholderText=Label.IP_Explanation_of_Special_Points;
        wrp.InventorsLabel=Case.IP_Inventors__c.getDescribe().getLabel();
        wrp.InventorsHelptext=Case.IP_Inventors__c.getDescribe().getInlineHelpText();
        wrp.IamemployedatSEGAutomotiveGermanyLabel=Case.IP_am_employed_at_SEG_Automotive_Germany__c.getDescribe().getLabel();
        wrp.priorartLabel=Case.IP_Prior_Art__c.getDescribe().getLabel();
        wrp.priorartHelptext=Case.IP_Prior_Art__c.getDescribe().getInlineHelpText();
        wrp.problemSolvedLabel=Case.IP_Problem_Solved__c.getDescribe().getLabel();
        wrp.problemSolvedHelptext=Case.IP_Problem_Solved__c.getDescribe().getInlineHelpText();
        wrp.inventionDescriptionLabel=Case.IP_Invention_Description__c.getDescribe().getLabel();
        wrp.inventionDescriptionHelptext=Case.IP_Invention_Description__c.getDescribe().getInlineHelpText();
        wrp.proveofInventiononCompetitorProductLabel=Case.IP_Proveof_Invention_onCompetitorProduct__c.getDescribe().getLabel();
        wrp.proveofInventiononCompetitorProductHelptext=Case.IP_Proveof_Invention_onCompetitorProduct__c.getDescribe().getInlineHelpText();
        wrp.useofInventionbyUsLabel=Case.IP_Use_of_Invention_by_Us__c.getDescribe().getLabel();
        wrp.useofInventionbyUsHelptext=Case.IP_Use_of_Invention_by_Us__c.getDescribe().getInlineHelpText();
        wrp.inventionPartofEntrustedResearchLabel=Case.IP_Invention_Part_of_Entrusted_Research__c.getDescribe().getLabel();
        wrp.inventionPartofEntrustedResearchHelptext=Case.IP_Invention_Part_of_Entrusted_Research__c.getDescribe().getInlineHelpText();
        return wrp;
    }
    
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        }
        
        return controllingInfo;
    }
    
    public class fieldLabelAndHelpText{
        @auraEnabled
        public list<string> productTypeOptions{get;set;}
        @auraEnabled public string titleLabel{get;set;}
        @auraEnabled public string titleHelptext{get;set;}
        @auraEnabled public string productTypeLabel{get;set;}
        @auraEnabled public string inventionCreatedasPartofWorkLabel{get;set;}
        @auraEnabled public string inventionCreatedasPartofWorkHelptext{get;set;}
        @auraEnabled public string whoInitiatedtheSubjectLabel{get;set;}
        @auraEnabled public string whoInitiatedtheSubjectHelptext{get;set;}
        @auraEnabled public string reasonforWorkingonThatSubjectLabel{get;set;}
        @auraEnabled public string reasonforWorkingonThatSubjectHelptext{get;set;}
        @auraEnabled public string isthereContributionoftheCompanyLabel{get;set;}
        @auraEnabled public string isthereContributionoftheCompanyHelptext{get;set;}
        @auraEnabled public string specialPointstobeConsideredLabel{get;set;}
        @auraEnabled public string specialPointstobeConsideredHelptext{get;set;}
        @auraEnabled public string explanationofSpecialPointsLabel{get;set;}
        @auraEnabled public string explanationofSpecialPointsHelptext{get;set;}
        @auraEnabled public string explanationofSpecialPointsPlaceholderText{get;set;}
        @auraEnabled public string InventorsLabel{get;set;}
        @auraEnabled public string InventorsHelptext{get;set;}
        @auraEnabled public string IamemployedatSEGAutomotiveGermanyLabel{get;set;}
        @auraEnabled public string priorartLabel{get;set;}
        @auraEnabled public string priorartHelptext{get;set;}
        @auraEnabled public string problemSolvedLabel{get;set;}
        @auraEnabled public string problemSolvedHelptext{get;set;}
        @auraEnabled public string inventionDescriptionLabel{get;set;}
        @auraEnabled public string inventionDescriptionHelptext{get;set;}
        @auraEnabled public string proveofInventiononCompetitorProductLabel{get;set;}
        @auraEnabled public string proveofInventiononCompetitorProductHelptext{get;set;}
        @auraEnabled public string useofInventionbyUsLabel{get;set;}
        @auraEnabled public string useofInventionbyUsHelptext{get;set;}
        @auraEnabled public String inventionPartofEntrustedResearchLabel{get;set;}
        @auraEnabled public String inventionPartofEntrustedResearchHelptext{get;set;}
        @auraEnabled public Map<String,list<string>> contorlingAnddependentvalues{get;set;}
        
    }
    
    public class MyPickListInfo{
        public String validFor;
    }
    
    public class inventors{
        @auraEnabled
        public String Name;
        @auraEnabled
        public String Email;
        @auraEnabled
        public String Id;
        @auraEnabled
        public Decimal share;
    }
}