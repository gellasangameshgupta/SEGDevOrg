({
	doInit : function(component, event, helper) {
        helper.helperfetchStatusPicklist(component, event, helper);
        helper.helperShowProcessButton(component, event, helper);
        
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    SubmitDCA: function(component, event, helper) {
        helper.helperSubmitRecord(component, event, helper);
    },
})