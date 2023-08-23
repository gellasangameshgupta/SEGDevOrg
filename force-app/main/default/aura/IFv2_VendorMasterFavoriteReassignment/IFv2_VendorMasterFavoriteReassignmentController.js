({
    retrieveUsers : function(component, event, helper) {
        var action = component.get("c.getUsersFromPublicGroup");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})