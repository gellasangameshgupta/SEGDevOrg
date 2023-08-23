({	
    handleApplicationEvent : function(cmp, event) {
        var details = event.getParam("details");
		cmp.set("v.DepartmentDetails", details);        
    }
})