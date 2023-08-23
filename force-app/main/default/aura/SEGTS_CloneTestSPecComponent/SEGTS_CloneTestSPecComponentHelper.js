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
            else {
               	alert('Error in getting data');
            }
        });
        // Adding the action variable to the global action queue
        $A.enqueueAction(action);
          //alert('helper called');
              } ,
    helperFun : function(component,event,sectionId) {
	  var acc = component.find(sectionId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
    
	SaveTestSpec: function(component, event, helper) {
       
           var testSpecList = component.get("v.testSpec");
           var saveAction = component.get("c.saveTestSpec");
           var testSpecId = component.get("v.recordId");
        //var name = component.get("v.Name");
        //if(!name){
        //	return;    
        //}
        
           saveAction.setParams({ 
               testSpec: testSpecList,
               parentId:testSpecId
              
           });
             saveAction.setCallback(this, function(response) 
           {
               var state = response.getState();
               if(state === "SUCCESS") {
                   var dataMap = response.getReturnValue();
                   var recordId=response.getReturnValue();
                   var navEvt = $A.get("e.force:navigateToSObject");
        			navEvt.setParams({
            				"recordId": recordId,
                        	 "slideDevName": "detail"
        				});
        			navEvt.fire();
        	    }
                else if(state === "ERROR"){
                var errors = saveAction.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
          	}
        
         
        });
        $A.enqueueAction(saveAction);
    }        
        
})