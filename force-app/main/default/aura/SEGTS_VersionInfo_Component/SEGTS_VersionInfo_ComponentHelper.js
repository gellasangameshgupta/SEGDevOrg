({
	fetchtestSpec : function(component, event, helper) {
          
        var action = component.get("c.getTestSpec");
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
                component.set("v.testSpec",testSpec);
            }
            });
          $A.enqueueAction(action);
    },
        helperFun : function(component,event,sectionId) {
          var acc = component.find(sectionId);
                for(var cmp in acc) {
                $A.util.toggleClass(acc[cmp], 'slds-hide');  
           }
        },  
})