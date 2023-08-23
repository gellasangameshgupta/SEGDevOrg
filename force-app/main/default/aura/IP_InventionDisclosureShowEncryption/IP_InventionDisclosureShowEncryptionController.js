({
	doInit : function(component,event,helper) {
		var action = component.get("c.getInventionDisclosure");
        action.setParams({
            recid: component.get("v.recordId")      
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var outputresponse = response.getReturnValue();
            if(state === "SUCCESS" && outputresponse){ 
                component.set("v.caserecord",outputresponse);
            }
        });
        $A.enqueueAction(action);
	},
})