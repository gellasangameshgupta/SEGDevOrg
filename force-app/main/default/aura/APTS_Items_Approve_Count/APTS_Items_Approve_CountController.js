({
	doInit : function(component, event, helper) {
        var parts = window.location.toString().split('/');
        var lastSegment = parts.pop() || parts.pop();
        
        helper.getApprovalRequestsCount(component,lastSegment); 
		      
	},
    gotoList: function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToComponent");
        navigateEvent.setParams({
            componentDef: "c:APTS_ItemsToApprove"
            //You can pass attribute value from Component1 to Component2
            //componentAttributes :{ }
        });
        navigateEvent.fire();
    } 
})