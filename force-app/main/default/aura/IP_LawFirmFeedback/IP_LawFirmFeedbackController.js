({
	/** Loads Spinner **/
	handleLoad : function(component, event, helper) {
		component.set("v.IsUpdated", true);
        component.set("v.showSpinner", false);
	},
    fetchmessages : function(component) {
        var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
        window.addEventListener("message", $A.getCallback(function(event){
            if (event.origin !== vfOrigin) {         
                return;
            }
            if (event.data === "attached") {
                //var isAttachmentValid = component.get("v.isAttachmentValid");
                //console.log('Inside event attached ', isAttachmentValid);
                //isAttachmentValid = event.data;
                //console.log('Update ', isAttachmentValid);
                //component.set("v.isAttachmentValid",isAttachmentValid);
                console.log('event ', event.data);
                component.set("v.saveWithFile",true);
            }
        }), false);
    },
    /** Submits the record to update **/
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); 
        var fields = event.getParam("fields");
        component.set("v.showSpinner", true);
        component.find('editForm').submit(fields); // Submit form
	},
    
    /** shows success message **/
	handleSuccess : function(component, event, helper) {
        
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "Law firm Feedback Successfully Submitted",
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
    handleSaveWithFile : function(component,event,helper){
        console.log('calling VF');
        var vfOrigin = $A.get("$Label.c.IP_IDFFileUploadURL");
        var vfWindow = document.getElementById("vfFrame").contentWindow;
        vfWindow.postMessage(component.get("v.recordId"), vfOrigin);
    },
})