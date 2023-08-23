({
	fetchData : function(component, event, helper) {
        var action = component.get("c.getData");
        var testSpecId = component.get("v.recordId");
        action.setParams({
            pageId:testSpecId
        });
        action.setCallback(this, function(response) {
           var state = response.getState();
            if(state === 'SUCCESS') {
                var testSpec = response.getReturnValue();
                //testSpec.Version_No__c=1;
        		//testSpec.Status__c='Draft';
                component.set("v.wrapperList",testSpec);
            }
            
        });
        var action1=component.get("c.gettestSpec");
        var tid=component.get("v.recordId");
        action1.setParams({
            pageId:tid
        });
        action1.setCallback(this, function(response) {
           var state = response.getState();
            if(state === 'SUCCESS') {
                var testSpec = response.getReturnValue();
                //testSpec.Version_No__c=1;
        		//testSpec.Status__c='Draft';
        		//alert(testSpec);
                component.set("v.editCondition",testSpec);
            }
            
        });
        
        // Adding the action variable to the global action queue
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        
          //alert('helper called');
              } 
		
	
})