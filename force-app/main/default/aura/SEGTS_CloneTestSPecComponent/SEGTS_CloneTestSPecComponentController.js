({
	getTestSpecs : function(component, event, helper) {
        // Helper function - fetchContacts called for interaction with server
        helper.fetchtestSpec(component, event, helper);
        //helper.getstartertype(component, event, helper);
       
        },
        sectionOne : function(component, event, helper) {
           helper.helperFun(component,event,'articleOne');
        },
        sectionTwo : function(component, event, helper) {
          helper.helperFun(component,event,'articleTwo');
        },
    	sectionThree : function(component, event, helper) {
          helper.helperFun(component,event,'articleThree');
        },
        getOppProcess: function(component, event, helper) {

    component.set("v.t.Starter__c", event.getParam('value'));
    component.set("v.t.Test_Spec_Type__c", event.getParam('value'));
    component.set("v.t.Starter_Type__c", event.getParam('value'));
    component.set("v.t.Stand__c", event.getParam('value'));
    
    component.set("v.t.Additional_Features__c", event.getParam('value').split(';'));
    component.set("v.t.SAP_Doc__c", event.getParam('value'));    
	},
    
    save : function(component, event, helper) {
       
        // Helper function - fetchContacts called for interaction with server
         var btn = event.getSource();
         var contactFields = component.find("nameVal");
         var blank=0;
         if(contactFields.length!=undefined) { 
             var allValid = contactFields.reduce(function (validSoFar, inputCmp) {
        	 inputCmp.showHelpMessageIfInvalid();
             return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
             if (!allValid) {
                    blank++;
                }
            } 
        
        if(blank==0)
        {
        	helper.SaveTestSpec(component, event, helper);           
        }
         	
        
    },
    cancel :function(component, event) {
    var btn = event.getSource();
 	var navEvt = $A.get("e.force:navigateToSObject");
    var recordId=component.get("v.recordId"); 
 	navEvt.setParams({
 	"recordId": recordId
 	});
 	navEvt.fire();
    },
    showRequiredFields: function(component, event, helper){
	$A.util.removeClass(component.find("sapdoc"), "none");
	}
})