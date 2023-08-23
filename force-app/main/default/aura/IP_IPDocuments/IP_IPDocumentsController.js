({
	doInit : function(component) {
		var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
        window.addEventListener("message", $A.getCallback(function(event){
            if (event.origin !== vfOrigin) {         
                return;
            }
            if(!event.data.__grammarly){        
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
	}
})