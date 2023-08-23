({
	getApprovalRequestsCount: function(component,appName) {
        var action = component.get("c.getApprovalRequestsCount");
        action.setParams({
        	"appName": appName            
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.totalItems", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})