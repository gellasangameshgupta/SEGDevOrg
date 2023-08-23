({
    doInit: function(component, event, helper) {
        helper.fetchCountryPicklist(component); // fetches PickList Values of Rating Field
        helper.fetchTypeOfRightPicklist(component); // fetches PickList Values of Locality Field
        helper.fetchRelationshipToParentPicklist(component); // fetches PickList Values of Generic Field
        helper.fetchProductClassPicklist(component);
    },
    dohandleSearchEvent : function(component, event, helper){
        var searchKey = event.getParam('searchText');
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': searchKey,
            'fieldInsearch' :component.get("v.SearchField"),
            'ObjectName': component.get("v.selectedObject")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.SearchedResult", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSave : function(component, event, helper) {
        var recId = component.get("v.recordId");
        helper.updateIPRight(component); 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!",
                              "message": "IP Right record is created successfully ",
                              "type": "success"});
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    handleNext : function(component, event, helper){
        var country = component.get("v.NewIPRight").IP_Country__c;
        if(country == null || country == ''){
            component.set("v.NewIPRight.IP_Country__c", 'DE');
        }
        var typeOfRight = component.get("v.NewIPRight").IP_Type_of_Right__c;
        if(typeOfRight == null || typeOfRight == ''){
            component.set("v.NewIPRight.IP_Type_of_Right__c", 'Patent');
        }
        component.set("v.NewIPRight.ParentId", component.get("v.selectedRecord").Id);
        var selectedValues = component.get("v.selectedProductList");
        var selectVal = '';
        console.log('length--',selectedValues.length);
        if(selectedValues.length > 0){
            for(var i in selectedValues){
                selectVal += selectedValues[i] + ';';
            }
            component.set("v.NewIPRight.IP_ProductClass__c", selectVal);
            helper.getInventionDetails(component);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({"title": "error!",
                                  "message": "Product class is Mandatory ",
                                  "type": "error"});
            toastEvent.fire();
        }
        
		
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
     onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        component.set("v.SearchKeyWord", component.get("v.selectedRecord").IP_Right_ID__c);
          //  $A.util.addClass(lookUpTarget, 'slds-hide');
          //  $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
    
    handleProductChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.selectedProductList", selectedValues);
    },
     
    /*getSelectedProduct : function(component, event, helper){
        //Get selected Genre List on button click 
        var selectedValues = component.get("v.selectedProductList");
        console.log('Selectd Genre-' + selectedValues);
    }*/
})