({
	doInit : function(component, event, helper) {
		// Load News records
    	var action = component.get("c.getTopic");
        //pass number of news articles to display to apex method
        action.setParams({
            "topicId" : component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.topic", response.getReturnValue());
            }
        });       
        $A.enqueueAction(action);  	
	}
})