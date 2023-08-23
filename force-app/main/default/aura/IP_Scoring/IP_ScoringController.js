({
	/** Loads Spinner **/
	handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.today', today);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set('v.loggedInUser', userId);
        
	},
    
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var fields = event.getParam("fields");
        //fields["Status"] = 'Scoring Completed';
        fields["IP_Status__c"] = "Scoring Completed";
        component.set("v.showSpinner", true);
        component.find('editForm').submit(fields); // Submit form
	},
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "Scoring Successfully Submitted",
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