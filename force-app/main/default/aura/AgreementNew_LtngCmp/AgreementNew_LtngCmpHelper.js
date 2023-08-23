({
	/* Call to server */
    callToServer: function(component, method, callback, params, storable) {
        component.set("v.showSpinner", true);
        component.set("v.isAlert", false);
        component.set("v.alertMessage", []);
        var action = component.get(method);
        action.setBackground(true);
        if (storable) {
            action.setStorable();
        }
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isAlert", false);
                component.set("v.alertMessage", []);
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0]) {
                    if(errors[0].message) {
                        var messages = component.get("v.alertMessage");
                        if(messages === undefined){
                            messages=[];
                        }
                        messages.push(errors[0].message);
                        component.set("v.alertMessage", messages);
                        component.set("v.isAlert", true);
                    }
                    var pageError = errors[0].pageErrors;
                    
                    if (pageError && pageError[0] && pageError[0].message) {
                        var messages = component.get("v.alertMessage");
                        messages.push("Error message: " + pageError[0].message);
                        component.set("v.alertMessage", messages);
                        component.set("v.isAlert", true);
                    }
                    var fieldError = errors[0].fieldErrors;
                    if (fieldError && fieldError.Name && fieldError.Name[0] &&  fieldError.Name[0].message) {
                        var messages = component.get("v.alertMessage");
                        messages.push("Error message: " + fieldError.Name[0].message);
                        component.set("v.alertMessage", messages);
                        component.set("v.isAlert", true);
                    }
                }
            } else {
                var messages = component.get("v.alertMessage");
                component.set("v.alertMessage", messages);
                component.set("v.isAlert", true);
            }
        });
        $A.enqueueAction(action);
    }
})