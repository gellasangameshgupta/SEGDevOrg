/****************************************************************************
    Trigger Name    :SEGTS_TestSpecificationTrigger
    Purpose         :To delete Test Spec with child records
    Created By      :RBEI
    Created Date    :Jan 2019
*****************************************************************************/
trigger SEGTS_TestSpecificationDeleteTrigger on Test_Specification__c (before delete) {
        set<Id> level0Id=new set<Id>();
        set<Id> level1Id=new set<Id>();
        set<Id> level2Id=new set<Id>();
        List<Test_Specification__c> specList=new List<Test_Specification__c>();
        List<Test_Specification__c> sectionList=new List<Test_Specification__c>();
        List<Test_Specification__c> blockList=new List<Test_Specification__c>();
        List<Test_Specification__c> resultList=new List<Test_Specification__c>();
        for(Test_Specification__c t:trigger.old){
            if(t.Status__c=='Approved'){
                t.addError('You cannot delete this Test Specification!!!');
            }
        }
           for(Test_Specification__c testSpec:[Select id from Test_Specification__c where Parent_Test_Specification__c in:Trigger.Old]){
                sectionList.add(testSpec);
                level1Id.add(testSpec.id);
            }
            System.debug('section----'+sectionList);
            delete sectionList;
        
        if(!level1Id.isEmpty()){
            System.debug('Level 2');
            for(Test_Specification__c testSpec:[Select id from Test_Specification__c where Parent_Test_Specification__c in:level1Id]){blockList.add(testSpec);
                level2Id.add(testSpec.id);
            }
            delete blockList;
        }
        System.debug('blockid----'+level2ID);
        if(!level2ID.isEmpty()){
            for(Test_Specification__c testSpec:[Select id from Test_Specification__c where Parent_Test_Specification__c in:level2Id]){
                resultList.add(testSpec);
            }
            delete resultList;
        }
        
}