({
	/*doInit : function(component,event,helper) {
		var action = component.get("c.fetchsearch");
        action.setParams({
            invDisclosureId: component.get("v.recordId")      
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var outputresponse = response.getReturnValue();
            if(state === "SUCCESS" && outputresponse){ 
                component.set("v.idf",outputresponse);
            }
        });
        $A.enqueueAction(action);
	},
    goBack : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    updateRFIcontroller : function(component, event, helper) {
		var action = component.get("c.updatesearch");
        action.setParams({
            invDisclosureId: component.get("v.recordId"),
            Comments: component.get("v.idf").Search_Comments__c,
            searchid: component.get("v.selectedLookUpRecords")[0].Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Search details updated successfully",
                    "duration": "5000"
                });
                toastEvent.fire();
                window.location.reload();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},*/
    /** Loads Spinner **/
	handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.today', today);
	},
    
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
      //	var today = $A.localizationService.formatDate(new Date(), "DD/MM/YYYY");
        var fields = event.getParam("fields");
        fields["IP_Status__c"] = 'Legal Evaluation';
        component.set("v.showSpinner", true);
     	//alert('Fields '+ fields["IP_Status__c"]);
        component.find('editForm').submit(fields); // Submit form
	},
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "Legal Evaluation updated successfully",
                              "type": "success"});
        toastEvent.fire();
        component.set("v.showSpinner", false);
        $A.get("e.force:closeQuickAction").fire();
	},
    
    /** Cancels the popup **/
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
       component.find('field').forEach(function(f) {
       		f.reset();
       });
        
    },
})