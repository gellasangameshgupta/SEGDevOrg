({
	doInit : function(component,event,helper) {
        
		var action = component.get("c.fetchRFI");
        action.setParams({
            invDisclosureId: component.get("v.recordId")      
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var outputresponse = response.getReturnValue();
            if(state === "SUCCESS" && outputresponse){ 
                component.set("v.RFIComments",outputresponse);
            }
        });
        $A.enqueueAction(action);
	},
    goBack : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    updateRFIcontroller : function(component, event, helper) {
		var action = component.get("c.updateRFI");
        action.setParams({
            invDisclosureId: component.get("v.recordId"),
            Comments: component.get("v.RFIComments")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Submitted Successfully",
                    "duration": "5000"
                });
                toastEvent.fire();
                window.location.reload();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},
})