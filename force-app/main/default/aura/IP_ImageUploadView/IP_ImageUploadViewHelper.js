({
	helperMethod : function(component) {
		var action = component.get("c.getContents"); 
        alert(component.get("v.recordId"));
        action.setParams({
            parentId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            alert(attachment);
            component.set('v.pictureSrc', '/sfc/servlet.shepherd/version/download/'+attachment);
        });
        alert(component.get('v.pictureSrc'));
        $A.enqueueAction(action);
	}
})