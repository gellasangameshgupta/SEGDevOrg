({
	getMyTaskObject: function(component){
	    var action = component.get("c.getMyObjects");
        action.setParams({ recordId : component.get("v.recordId") });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if (state === "SUCCESS") {
	            component.set("v.whatId", response.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
        console.log(component.get("v.whatId"));
	},
    createRecord : function(component) {
        var createRecordEvent = $A.get("e.force:createRecord");
	    createRecordEvent.setParams({
	        "entityApiName": "Task",
            "defaultFieldValues" : {
                'ParentId__c' : component.get('v.recordId'),
                'WhatId' : component.get('v.whatId')
            }
	    });
	    createRecordEvent.fire();
        console.log(component.get("v.whatId"));
    }
})