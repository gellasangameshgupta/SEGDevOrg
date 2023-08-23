({
	/** Loads Spinner **/
	handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
	},
    
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var fields = event.getParam("fields");
        component.set("v.showSpinner", true);
        component.find('editForm').submit(fields); // Submit form
	},
    handleError: function (component, event, helper) {
        component.set('v.showSpinner', false);
        component.find('ErrorMessage').setError('Allowance Date should be Less Than or Equal to Today');
    },
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "Request sent successfully",
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