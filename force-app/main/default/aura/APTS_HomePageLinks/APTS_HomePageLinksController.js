({
    doInit : function(component, event, helper) {
        helper.getListViewDetail(component, 'Apttus__APTS_Agreement__c','APTS_My_Agreements','myAgreementsList');               
        //helper.getListViewDetail(component, 'Apttus__APTS_Template__c','Clauses','clausesList');               
	},
	createWizard: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus__AgreementStoreExecuted'}).fire();
    },
    NewAgreement: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/new?nooverride=1&useRecordTypeCheck=1'}).fire();
    },    
    gotoMyAgreements: function(component, event, helper) {       
       // var listId = component.get("v.myAgreementsList");
       // $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listId}).fire();
       helper.goToMyAgreements(component);
    },
    gotoMyDashBoard: function(component, event, helper) {       
         $A.get("e.force:navigateToURL").setParams({"url": '/lightning/r/Dashboard/01Z3i000000956eEAA/view?queryScope=userFolders'}).fire();
    },
    MyQueueAgreements: function(component, event, helper) {
        helper.navigateToMyQueue(component);
    }
   
})