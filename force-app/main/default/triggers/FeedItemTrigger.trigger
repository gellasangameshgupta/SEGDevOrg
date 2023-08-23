trigger FeedItemTrigger on FeedItem (after insert,after delete,before delete, after undelete, before Insert,after update, before update ) { 
       
    if(trigger.isbefore && (trigger.isInsert || trigger.isupdate) )
    {
        Map<Id, FeedItem> contentversionIdToFeedItemMap = new Map<Id, FeedItem>();
        for(FeedItem fi : trigger.new){
            if(fi.type == 'ContentPost')
                contentversionIdToFeedItemMap.put(fi.RelatedRecordId, fi);
        }
        List<string>extensions=(Label.CLIFv20320).toLowerCase().split(',');
        for(ContentVersion cv : [SELECT Id, FileExtension,FileType FROM ContentVersion where Id IN :contentversionIdToFeedItemMap.keySet()])
        {
            if(extensions.contains(cv.FileExtension))
            {
                contentversionIdToFeedItemMap.get(cv.Id).addError(Label.CLIFv20321);
            }
        }
    }
    
    //Commenting for Insight deprecation
    //FeedItemHandler fdHandler = new FeedItemHandler ();
    
    /* To make visibility to all users */
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !Trigger.new.isEmpty()){
        
        for(FeedItem chatterRecords : Trigger.new){
            chatterRecords.Visibility='AllUsers';
        }
    }
    if(trigger.isAfter && (trigger.isInsert||trigger.isUndelete || Trigger.isUpdate) && !Trigger.new.isEmpty() ) {
        //Commenting for Insight deprecation
        /*if(trigger.isInsert||trigger.isUndelete){
           fdHandler.OnAfterInsert(Trigger.new); 
        }*/
        
        if(trigger.isInsert || Trigger.isUpdate ){
            /* Logic Added for trigger Insightflow version 2.0 */
           IFv2_TriggerHandler.chatterSharingRecords(Trigger.new);
        }
        
        //if(Trigger.isUpdate && !Trigger.new.isEmpty()){
        
            //ChatterRecordAccess.provideRecordAccesWithChatter(Trigger.new);
        //}
        
    }
    
    if(trigger.isBefore && trigger.isDelete){
        Boolean isAdmin = IFv2_HeaderController.checkUserIsAdmin();
        String errorMsg = System.Label.CLIFv20314;
        for(FeedItem post : Trigger.old){
            if(!isAdmin){
                if(post.ParentId.getSObjectType().getDescribe().getName()=='Ifv2_Request__c'){
                    post.addError(errorMsg); 
                }
            }
        }
    }
    //Commenting for Insight deprecation
    /*if(trigger.isAfter&&trigger.isDelete){
        fdHandler.OnAfterDelete(trigger.old);
        system.debug('old size--'+trigger.old.size());
    }*/
    
}