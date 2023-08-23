({
	getTestSpecs : function(component, event, helper) {
        helper.fetchData(component, event, helper);
		
	},
    openTestDeatils:function(component, event, helper){
		var evt = $A.get("e.force:navigateToComponent");
		var testSpecId = component.get("v.recordId");
         evt.setParams({
            componentDef  : "c:SEGTS_CreateTestDetailsLC" ,
            componentAttributes : {
                accId : testSpecId
               
            }
         });
        evt.fire();
    },
	editTestDetails:function(component, event, helper){
		var evt = $A.get("e.force:navigateToComponent");
		var testSpecId = component.get("v.recordId");
         evt.setParams({
            componentDef  : "c:SEGTS_EditTestDeatilsLC" ,
            componentAttributes : {
                accId : testSpecId
               
            }
         });
        evt.fire();
    }        


})