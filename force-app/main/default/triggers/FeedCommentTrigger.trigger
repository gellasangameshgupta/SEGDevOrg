/*******************************************************************************************************
* 
* @ Name    :   FeedCommentTrigger
* @ Purpose :   Trigger on FeedComment standard object which is used for customisation on chatter comments.
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   03-12-2019      |  external.debasmita.rawooth@seg-automotive.com|  Added changes for chatter comment deletion restriction for non-admin users
*********************************************************************************************************************/

trigger FeedCommentTrigger on FeedComment (before insert, before update, after insert,after delete,after update, before delete) {
    
    
     if(trigger.isbefore && (trigger.isInsert || trigger.isupdate) )
    {
        Map<Id, FeedComment> contentversionIdToFeedItemMap = new Map<Id, FeedComment>();
        for(FeedComment fi : trigger.new){
            if(fi.CommentType == 'ContentComment')
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
    /*if(Trigger.IsAfter&&trigger.isInsert){
        List<FeedComment> fclist = new list<FeedComment>();
        for(FeedComment fc : trigger.new){
            fclist.add(fc);
        }
        if(fclist.size()>0){
            FeedCommentHandler.FeedCommentCount(fclist);
        }
    }
    if(Trigger.isAfter&&trigger.isDelete){
        List<Feedcomment> fclist = new list<Feedcomment>();
        for(FeedComment fc : trigger.old){
            fclist.add(fc);
        }
        system.debug('fclist--'+fclist);
        if(fclist.size()>0){
            FeedCommentHandler.CountafterDelete(fclist);
        }
    }*/
    //added for chatter sharing records
    if(trigger.isAfter && (trigger.isInsert||Trigger.isUpdate) && !Trigger.new.isEmpty() ) {
        if(trigger.isInsert || Trigger.isUpdate ){
            /* Logic Added for trigger Insightflow version 2.0 */
            IFv2_TriggerHandler.chatterSharingRecordsFeedComments(Trigger.new);
        }
        //if(Trigger.isUpdate && !Trigger.new.isEmpty()){
           // ChatterRecordAccess.provideRecordAccesWithChatterFeedComments(Trigger.new);
        //}
        
    }
    
    if(trigger.isBefore && trigger.isDelete){
        Boolean isAdmin = IFv2_HeaderController.checkUserIsAdmin();
        String errorMsg = System.Label.CLIFv20314;
        for(FeedComment comment : Trigger.old){
            if(!isAdmin){
                if(comment.ParentId.getSObjectType().getDescribe().getName()=='Ifv2_Request__c'){
                    comment.addError(errorMsg); 
                }
            }
        }
    }
    
}