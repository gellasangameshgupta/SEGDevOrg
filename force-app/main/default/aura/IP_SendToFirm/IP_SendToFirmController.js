({
	/** Loads Spinner **/
	handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
	},
    
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.today', today);
        event.preventDefault(); 
        var fields = event.getParam("fields");
        fields["SendOut_Date__c"] = component.get('v.today');
        component.set("v.showSpinner", true);
        component.find('editForm').submit(fields); // Submit form
	},
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "Send to Firm sent successfully",
                              "type": "success"});
        toastEvent.fire();
        component.set("v.showSpinner", false);
        $A.get("e.force:closeQuickAction").fire();
	},
    
    /** Cancels the popup **/
    handleCancel : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire();
       component.find('field').forEach(function(f) {
       		//f.reset();
       });
        
    },
    
})