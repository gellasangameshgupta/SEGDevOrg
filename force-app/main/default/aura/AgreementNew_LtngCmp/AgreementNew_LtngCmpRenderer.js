({
    // Your renderer method overrides go here
    rerender : function(component, helper) {
        this.superRerender();
        let recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set("v.recordTypeId", recordTypeId);
        //component.set("v.recordId", '');
        
    },
    
})