({
    doInit : function(component, event, helper) {
        helper.getActionRequiredCount(component);
         //change or pass only valid List view API name in place of Sample
		helper.getListViewDetail(component,'Apttus__APTS_Agreement__c','Sample','myAgreementsList');        
	},
	gotoList: function(component, event, helper) {
        var listId = component.get("v.myAgreementsList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listId}).fire();
    } 
})