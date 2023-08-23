({
    getData : function(component, event, helper) {
        helper.fetchData(component, event, helper);	
	},
    OkCall : function(component, event, helper) {
        helper.updateStatusVal(component, event, helper);	
	},
    CancelCall : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
	}
})