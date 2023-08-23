({
    fetchData : function(component, event, helper) {
          
        var action = component.get("c.testSpec");
        var testSpecId = component.get("v.recordId");
        action.setParams({
            tid:testSpecId
        });
         
        action.setCallback(this, function(response) {
           var state = response.getState();
            if(state === 'SUCCESS') {
                var testSpec = response.getReturnValue();
                //testSpec.Version_No__c=1;
        		//testSpec.Status__c='Draft';
                component.set("v.editCondition",testSpec);
                
            }
            
        });
        // Adding the action variable to the global action queue
        $A.enqueueAction(action);
          //alert('helper called');
      },
    updateStatusVal : function(component, event, helper){
        var objRecordId = component.get("v.recordId");
        // create a server side action 
        var action = component.get("c.updateStatusVal"); 
        // set the parameters to method
        action.setParams({
            "TestSpecID" : objRecordId
        });
         // set a call back 
        action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS") {
                       $A.get("e.force:closeQuickAction").fire();
                                    $A.get('e.force:refreshView').fire();
                }
            });
          // enqueue the action 
            $A.enqueueAction(action);
        }
})