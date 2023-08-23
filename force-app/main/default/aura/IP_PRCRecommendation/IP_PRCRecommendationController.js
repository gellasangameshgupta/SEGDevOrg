({
	/** Loads Spinner **/
	handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
	},
    
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
      //	var today = $A.localizationService.formatDate(new Date(), "DD/MM/YYYY");
        var fields = event.getParam("fields");
        fields["IP_Status__c"] = 'PRC Recommendation Received';
        component.set("v.showSpinner", true);
     	//alert('Fields '+ fields["IP_Status__c"]);
        component.find('editForm').submit(fields); // Submit form
	},
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "PRC Recommendation sent successfully",
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