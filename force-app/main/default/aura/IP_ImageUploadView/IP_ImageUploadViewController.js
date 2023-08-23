({
	doInit : function(component,event,helper) {
		var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
        window.addEventListener("message", $A.getCallback(function(event){
            if (event.origin !== vfOrigin) {         
                return;
            }
            if(event.data === "NA"){    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please upload atleast one file.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();
                window.location.reload();        
            }
            if(event.data === "Success"){    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'File uploaded Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                });
                toastEvent.fire();
                window.location.reload();        
            }
        }), false);
        helper.helperMethod(component,event,helper);
	}
})