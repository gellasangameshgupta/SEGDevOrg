({
	doInit : function(component, event, helper) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set("v.recordTypeId", recordTypeId);
        helper.callToServer(component,
                            "c.fetchFieldSet",
                            function(response){
                                component.set("v.fieldList",response);
                                console.log("response from fetchFieldSet",response);
                            },
                            {
                                fieldsetName : component.get("v.fieldSetName")
                            },
                            false
                           );
        
        
	},
    handleSubmit : function(component,event,helper){
        component.set("v.showSpinner",true);
    },

    handleSuccess : function(component,event,helper){
        var response = event.getParam("response");
        console.log("record Id:",response.id);
        console.log("response",response);
        component.set("v.recordId",response.id);

        component.addEventHandler("force:recordChange", component.getReference("c.navigateTorecordDetail"));

        var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": response.id
                });
                editRecordEvent.fire();
        
        component.set("v.showSpinner",false);
    },

    navigateTorecordDetail :function(component,event,helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "details"
        });
        component.set("v.recordId",null);
        component.set("v.recordTyopeId",null);
        navEvt.fire();
        
    },
    handleCancel : function(component,event,helper){
        helper.callToServer(
            component,
            "c.deleteRecord",
            function(response){
                console.log("deleted");
                component.set("v.recordId",null);
                component.set("v.recordTyopeId",null);
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "Apttus__APTS_Agreement__c"
                });
                homeEvent.fire();
            },
            {
                "recordId" : component.get("v.recordId")
            },
            false
            )
    }
})