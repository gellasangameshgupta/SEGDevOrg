({
	    helperfetchStatusPicklist : function(component, event, helper){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'field_apiname': 'DCA_Status__c'
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.StatusPicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
        helperShowProcessButton : function(component, event, helper){
        var action = component.get("c.showProcessingButton");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.showProcessing", a.getReturnValue());
                helper.helperfetchRecordDetails(component, event, helper);
            } 
        });
        $A.enqueueAction(action);
    },
    helperfetchRecordDetails : function(component, event, helper){
        var action = component.get("c.fetchRecordForUpdateComp");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var returnRcd=a.getReturnValue();
                var DCA_record=component.get("v.DCA_Update");
                if(component.get("v.showProcessing")===true)
                    DCA_record.DCA_Status__c='Processed';
                else
                	DCA_record.DCA_Status__c=returnRcd.DCA_Status;
                DCA_record.DCA_ApprovalComment__c=returnRcd.DCA_ApprovalComment;
                DCA_record.DCA_ProcessingComment__c=returnRcd.DCA_ProcessingComment;
                
                DCA_record.Id=returnRcd.Id;
                component.set("v.DCA_Update",DCA_record);
               // component.set("v.DCA_Update.DCA_Status__c",returnRcd.DCA_Status);
             //   alert(JSON.stringify(DCA_record.DCA_Status__c));
            } 
        });
        $A.enqueueAction(action);
    },
        helperSubmitRecord : function(component, event, helper) {
        var action = component.get('c.submitRecordForUpdateComp'); 
        var DCA=component.get("v.DCA_Update");
        var person = {
            Id:DCA.Id,
            DCA_Status: DCA.DCA_Status__c,
            DCA_ProcessingComment: DCA.DCA_ProcessingComment__c,
            DCA_ApprovalComment: DCA.DCA_ApprovalComment__c
        };
        action.setParams({
            'sheet': JSON.stringify(person)
        }); 
        
        if(DCA.DCA_Status__c===null || DCA.DCA_Status__c==='None' || DCA.DCA_Status__c===undefined)
        {
            helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error2"),"error") 
        }
        else if(DCA.DCA_Status__c==='Department Change' && DCA.DCA_ApprovalComment__c===undefined)
        {
            helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error7"),"error") 
        }
        else{
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS" && response.getReturnValue()==="SUCCESS") {  
                    helper.ToastMethod("Success!",$A.get("$Label.c.DCA_success1"),"success");
                     $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                else
                {
                    
                    helper.ToastMethod("Error!",response.getReturnValue(),"error")
                }
            
        });
        $A.enqueueAction(action);
        }
    },
     ToastMethod : function(title,message,type) {
		 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type":type
                    });
                    toastEvent.fire();
	}
})