({
    init :function(component, event, helper) {
    
        var action = component.get("c.getFiles");
        action.setParams({
            "objectId": component.get("v.recordId")
    	 });
        action.setCallback(this, function(response){
    
        var name = response.getState();
    
            if (name === "SUCCESS") {
            
            component.set("v.reg", response.getReturnValue());
            
            }
    
        });
    
    $A.enqueueAction(action);
    
    },

})