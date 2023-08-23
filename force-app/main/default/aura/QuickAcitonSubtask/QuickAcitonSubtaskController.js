({
	doInit : function (component, event, helper) {
        helper.getMyTaskObject(component);
        //helper.createRecord(component);
	},
    createRecordEvent : function (component, event, helper) {
        helper.createRecord(component);
    }
})