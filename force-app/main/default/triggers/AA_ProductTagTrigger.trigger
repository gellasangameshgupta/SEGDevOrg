/**
*
* @ Name: AA_ProductTagTrigger
* @ Purpose: Trigger to share Product tag records with Team member users
* @ Test Class Name: AA_AllTriggersTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_ProductTagTrigger on agf__ADM_Product_Tag__c (after insert,after update){
    if(trigger.isInsert&&trigger.isAfter){
        List<agf__ADM_Product_Tag__c> insertProductTagList = new List<agf__ADM_Product_Tag__c>();
        List<Id> insertProductTagIdList = new List<Id>();
        for(agf__ADM_Product_Tag__c ptg : trigger.new){
            if(ptg.agf__Team__c!=null){
                insertProductTagList.add(ptg);
                insertProductTagIdList.add(ptg.Id);
            }
        }
        //Call method to share producttag records with public group
        if(!insertProductTagList.isEmpty()){
            System.debug('Inside Product tag Insert trigger::' + insertProductTagList);
            //AA_ShareTriggerUtils.shareProductTag(insertProductTagList);
            AA_ShareTriggerUtils.shareProductTag(insertProductTagIdList);
        }
    }
    
    if(trigger.isUpdate&&trigger.isAfter){
        List<agf__ADM_Product_Tag__c> updateProductTagList = new List<agf__ADM_Product_Tag__c>();
        List<Id> updateProductTagIdList = new List<Id>();
        for(agf__ADM_Product_Tag__c ptg : trigger.new){
            if(trigger.oldMap.get(ptg.id).agf__Team__c!=ptg.agf__Team__c){
                updateProductTagList.add(ptg);
                updateProductTagIdList.add(ptg.Id);
            }
        }
       
        //Call method to share producttag records with new team
        if(!updateProductTagList.isEmpty()){
        	//AA_ShareTriggerUtils.shareProductTag(updateProductTagList);
            AA_ShareTriggerUtils.shareProductTag(updateProductTagIdList);
            //Call method to delete producttag share records for old team
            AA_ShareTriggerUtils.deleteProductTagShare(trigger.old);
        
        }
    }
}