/**
* @Name: CLM_AgreementTriggerHelper
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: TriggerHelper for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/
public without sharing class CLM_AgreementTriggerHelper {
    public static void HelperPlantDetails(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap){
        Set<String> agreecheck = new Set<String>();
        Set<Id> agreeIdSet = new Set<Id>();
        Map<String,Id> agreetoplant = new Map<String,Id>();
        Map<Id,Apttus__APTS_Agreement__c> agreeMap = new Map<Id,Apttus__APTS_Agreement__c>();
        Map<String,CLM_Plant__mdt> plantMap = new  Map<String,CLM_Plant__mdt>();
        Map<Id,List<String>> agreeMapToPlntLst = new Map<Id,List<String>>();
        
        
        for (CLM_Plant__mdt mdPlant:[SELECT Id,Label,Plant_Name__c,Plant_Code__c,Address__c FROM CLM_Plant__mdt])
        {
            plantMap.put(mdPlant.Label,mdPlant);
        }
        
        for(Apttus__APTS_Agreement__c agree : newList) {
            agreeIdSet.add(agree.Id);
            List<String> lstStrng = new List<String>();
            if(!string.isBlank(agree.Plant__c))
            {
                for(string s:agree.Plant__c.split(';'))
                {                      	                    
                    lstStrng.add(s);                
                    agreeMap.put(agree.Id,agree);  
                }
                agreeMapToPlntLst.put(agree.Id,lstStrng);
            }
        }
        
        for(Account acc:[SELECT Id,CLM_Agreement__c,CLM_PlantName__c FROM Account where CLM_Agreement__c IN:agreeIdSet])
        {
            agreecheck.add(acc.CLM_Agreement__c+'_'+acc.CLM_PlantName__c);
        }
        
        
        List<Account> newAccountRecord = new List<Account>(); 
        if(!agreeMapToPlntLst.keySet().isEmpty())
        {
            for(Id agreeId: agreeMapToPlntLst.KeySet()){
                for(String plntKey : agreeMapToPlntLst.get(agreeId)){                                  
                    Apttus__APTS_Agreement__c agr=agreeMap.get(agreeId);
                    CLM_Plant__mdt plnt=plantMap.get(plntKey); 
                    string check=agr.Id+'_'+plnt.Plant_Name__c;
                    if(!agreecheck.contains(check))
                    {
                        Account acc = new Account();                          
                        acc.CLM_PlantName__c = plnt.Plant_Name__c;
                        acc.CLM_PlantCode__c = plnt.Plant_Code__c;
                        acc.CLM_Address__c = plnt.Address__c;
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Price Agreement Plant').getRecordTypeId();
                        acc.Name = agr.APTS_Agreement_Number__c+ ' ' + plnt.Plant_Name__c;
                        acc.CLM_Agreement__c= agr.Id;
                        newAccountRecord.add(acc);
                    }
                    
                }
            } 
        }                      
        if(!newAccountRecord.isEmpty()){        
            insert newAccountRecord;
        }
    }
    
}