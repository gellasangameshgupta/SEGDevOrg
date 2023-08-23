trigger ContentDocument on ContentDocument  (before delete,before update,before insert,after update,after insert,after delete) {
    
    If((trigger.isbefore) && ( trigger.isupdate || trigger.isdelete))
    {
        system.debug('inside new block update delete');
        system.debug('trigger.new '+trigger.new);
        system.debug('trigger.old '+trigger.old);
        ContentDocumentHandler handlerObj = new ContentDocumentHandler();
        if(trigger.isdelete)
        {system.debug('inside delete');
           handlerObj.checkParentstatus(trigger.old); 
        }
        else
        {system.debug('inside update');
			handlerObj.checkParentstatus(trigger.new);            
        }
            
    }
    /*If(trigger.isafter && trigger.isinsert)
    {
        system.debug('trigger.new '+trigger.new);
        system.debug('trigger.old '+trigger.old);
        system.debug('inside new insert block');
        ContentDocumentHandler handlerObj = new ContentDocumentHandler();
        handlerObj.checkParentstatus(trigger.new);
    }*/
    
    
    ContentDocumentHandler handler = new ContentDocumentHandler();
    if(Trigger.isBefore && Trigger.isDelete){
        system.debug('>>inside before delete--'+'>>'+trigger.old);
        if(String.isBlank(IFv2_TriggerHandler.fromTrigger) || IFv2_TriggerHandler.fromTrigger!='true' )
        {
            system.debug('>>inside before delete if>>'+IFv2_TriggerHandler.fromTrigger);
            handler.OnBeforeDelete(Trigger.old);
        }
        
    }
    /*if(trigger.isDelete&&trigger.isAfter){
        system.debug('CD trigger fired on delete');
        
        set<id> contdocids=new set<id>();
        for(ContentDocument cd : trigger.old){
            contdocids.add(cd.id);
        }
        if(contdocids.size()>0){
        //handler.OnAfterDelete(contdocids);
        }
    }*/
    
    /*  if(Trigger.isBefore && Trigger.isUpdate){
system.debug('called when new file is inserted');
List<contentdocument> cdlist = new list<contentdocument>();
handler.OnBeforeUpdate(trigger.new);
} */
}