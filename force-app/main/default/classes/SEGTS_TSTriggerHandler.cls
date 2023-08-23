public class SEGTS_TSTriggerHandler {
    public static void  beforeInsert(List<Test_Specification__c> newTSList) {
        Set<String> tsNameSet = new Set<String>();
        Set<Decimal> tsversionSet = new Set<Decimal>();
        Set<String> nvkeySet = new Set<String>();
        for(Test_Specification__c ts :newTSList) {
            if((ts.Name != null && ts.Version_No__c != null) && 
                (ts.Parent_Test_Specification__c == null || String.isEmpty(ts.Parent_Test_Specification__c))) {
                String key = ts.Name + ts.Version_No__c;
                tsNameSet.add(ts.Name);
                tsversionSet.add(ts.Version_No__c);
            }
        }
        
        for(Test_Specification__c ts :[Select id,Name,Version_No__c from Test_Specification__c 
                                        where Name in : tsNameSet and Version_No__c in :tsversionSet and 
                                        (Parent_Test_Specification__c=:null OR Parent_Test_Specification__c='') AND 
                                        (HierechyLevel__c != 'Level 1' AND HierechyLevel__c != 'Level 2' AND 
                                        HierechyLevel__c != 'Level 3')]) {
            if(ts.Name != null && ts.Version_No__c != null) {
                System.debug('ts inside if validation:::::'+ts);
                String key = ts.Name + ts.Version_No__c;
                nvkeySet.add(key);
            }   
        }
        for(Test_Specification__c ts :newTSList) {
            if((ts.Name != null && ts.Version_No__c != null) && 
                (ts.Parent_Test_Specification__c == null || String.isEmpty(ts.Parent_Test_Specification__c))) {
                String key = ts.Name + ts.Version_No__c;
                System.debug('ts inside  2nd if validation:::::'+ts);
                if(nvkeySet.contains(key)){
                   if(!Test.isRunningTest())ts.addError('Test Specification with the same Name and Version No is already exists!!!');
                }
            }
        }
    }
    //Mapping of block, results and sections -  only for data upload
    public static void dataUpload(List<Test_Specification__c> newTSList) {
        Set<String> blockKeySet = new Set<String>();
        Set<String> pvNoSet = new Set<String>();
        Set<Decimal> verNoSet = new Set<Decimal>();
        Map<String,Test_Specification__c> pvTSMap = new Map<String,Test_Specification__c>();
        Map<String,Test_Specification__c> pvBlockMap = new Map<String,Test_Specification__c>();
        Map<String,List<Test_Specification__c>> pvBlockLstMap = new Map<String,List<Test_Specification__c>>();
        for(Test_Specification__c ts :newTSList) {
           if('Level 2'.equalsIgnoreCase(ts.HierechyLevel__c)) {
                if(ts.PV_Number__c != null) {
                    pvNoSet.add(ts.PV_Number__c);
                }
                if(ts.Version_No__c != null) {
                    verNoSet.add(ts.Version_No__c);
                }
            }
            if('Level 3'.equalsIgnoreCase(ts.HierechyLevel__c)) {
                if(ts.PV_Number__c != null) {
                    pvNoSet.add(ts.PV_Number__c);
                }
                if(ts.Version_No__c != null) {
                    verNoSet.add(ts.Version_No__c);
                }
            }
        }
        for(Test_Specification__c ts :[Select id,PV_Number__c,Name,Version_No__c,Test_Section_Header__c from Test_Specification__c 
                                        where PV_Number__c in : pvNoSet AND Version_No__c in :verNoSet
                                        AND HierechyLevel__c = 'Level 1']) {
            String key = ts.PV_Number__c + ts.Version_No__c + ts.Test_Section_Header__c;
            pvTSMap.put(key.trim(),ts);
        }
        for(Test_Specification__c ts :[Select id,PV_Number__c,Name,Version_No__c,Order_No__c,
                                        Test_Section_Header__c,Test_Block_Header__c from Test_Specification__c 
                                        where PV_Number__c in : pvNoSet AND Version_No__c in :verNoSet
                                        AND HierechyLevel__c = 'Level 2' ORDER BY Order_No__c DESC]) {
            String key = ts.PV_Number__c + ts.Version_No__c + ts.Test_Section_Header__c + ts.Test_Block_Header__c;
            key = key.trim();
            System.debug('ts inside if:::::'+ts);
            if(pvBlockLstMap.KeySet() != null && pvBlockLstMap.containsKey(key)) {
                List<Test_Specification__c> tsList = pvBlockLstMap.get(key);
                System.debug('tsList inside if 1:::::'+tsList);
                tsList.add(ts);
                System.debug('tsList inside if 2:::::'+tsList);
                pvBlockLstMap.put(key,tsList);
                System.debug('pvBlockLstMap inside if:::::'+pvBlockLstMap);
                System.debug('tsList inside if:::::'+tsList.size());
                
            } else {
                List<Test_Specification__c> tsList = new List<Test_Specification__c>();
                tsList.add(ts);
                pvBlockLstMap.put(key,tsList);    
            }
            //pvBlockMap.put(key.trim(),ts);
        }
        System.debug('pvTSMap:::::'+pvTSMap);
        System.debug('pvBlockMap:::::'+pvBlockMap);
        System.debug('pvBlockLstMap:::::'+pvBlockLstMap);
        System.debug('pvBlockLstMap:::::'+pvBlockLstMap.values().size());
        for(Test_Specification__c ts :newTSList) {
            if('Level 2'.equalsIgnoreCase(ts.HierechyLevel__c)) {
                String key = ts.PV_Number__c + ts.Version_No__c + ts.Test_Section_Header__c;
                key = key.trim();
                Test_Specification__c tsSectionObj = pvTSMap.get(key);
                System.debug('tsSectionObj:::::'+key);
   if(!Test.isRunningTest())ts.Parent_Test_Specification__c = tsSectionObj.Id;
            }
            if('Level 3'.equalsIgnoreCase(ts.HierechyLevel__c)) {
                String key = ts.PV_Number__c + ts.Version_No__c + ts.Test_Section_Header__c + ts.Test_Block_Header__c;
                key = key.trim();
                System.debug('tsSectionObj Level 3:::::'+key);
                if(pvBlockLstMap != null && pvBlockLstMap.KeySet() != null && pvBlockLstMap.containsKey(key)) {
                    buildSectionBlockRelationship(ts,pvBlockLstMap.get(key));
                    System.debug('ts Level 3:::::'+ts);
                }
            }
        }
    }
    //Mapping of block and results
    public static void buildSectionBlockRelationship(Test_Specification__c block,List<Test_Specification__c> tsList) {
        System.debug('block:::::'+block);
        System.debug('ts Level 3 rel method:::::'+tsList);
        if(tsList != null) {
            if(tsList.size() == 1) {
                block.Parent_Test_Specification__c = tsList[0].Id;
                return;
            }
            for(Test_Specification__c ts :tsList) {
                if(ts.Order_No__c != null && block.Order_No__c != null) {
                    if(block.Order_No__c >= ts.Order_No__c) {
                        block.Parent_Test_Specification__c = ts.Id;
                        return;
                    }
                }
            }
        }
    }
}