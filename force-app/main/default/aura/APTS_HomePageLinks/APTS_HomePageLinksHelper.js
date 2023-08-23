({
	getListViewDetail: function(component, objectName , viewName,compId) {        
        var action = component.get("c.getListViewDetail");
        action.setParams({
        	"objectName": objectName,
            "viewName": viewName
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+compId, response.getReturnValue());                
        	}
        });
        $A.enqueueAction(action);
    },
    navigateToMyQueue:function(component){
        var action = component.get("c.getListViewDetail");
        action.setParams({
        	"objectName": 'Apttus__APTS_Agreement__c',
            "viewName": 'APTS_My_Queue_Agreements'
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
                var listViewId = response.getReturnValue();
                $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listViewId}).fire();                
        	}
        });
        $A.enqueueAction(action);        
    },
    goToMyAgreements:function(component){
        var action = component.get("c.getListViewDetail");
        action.setParams({
        	"objectName": 'Apttus__APTS_Agreement__c',
            "viewName": 'myAgreementsList'
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
                var listViewId = response.getReturnValue();
                $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listViewId}).fire();                
        	}
        });
        $A.enqueueAction(action);        
    }
})