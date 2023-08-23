({
    doInit: function(component, event, helper) {
        var action = component.get("c.getIPRight");
        action.setParams({
            'IPRightId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentIPRightRec", result);
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.getCountOfChildCountry");
        action.setParams({
            'IPRightId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.countryCountMap", result); debugger;
            }
        })
        $A.enqueueAction(action);
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
    handleComponentEvent : function(component, event, helper) {
        component.set("v.noOfRecordsSelected", component.get("v.noOfRecordsSelected")+1);
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        //Store Selected Country List
        var selectedIds =component.get("v.selectedListOfCountries");
        selectedIds.push(selectedAccountGetFromEvent.Id);
        component.set("v.selectedListOfCountries", selectedIds);
        //alert('Selected IDs ' + component.get("v.selectedListOfCountries"));
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        component.set("v.SearchKeyWord", '');
        //     component.set(component.get("v.NewIPRight").IP_Country__c, component.get("v.selectedRecord").IP_Country__c); 
        helper.fetchTypeOfRightPicklist(component); // fetches PickList Values of Locality Field
        helper.fetchRelationshipToParentPicklist(component);
        helper.createObjectData(component);
    },
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.childIPRightList");
        AllRowsList.splice(index, 1);
        
        var selectedIds = component.get("v.selectedListOfCountries");
        selectedIds.splice(index, 1);
        component.set("v.selectedListOfCountries", selectedIds);
      
        // set the contactList after remove selected row element  
        component.set("v.childIPRightList", AllRowsList);
    },
    
    handleCreateChild: function(component, event, helper){
        var itemsList = component.get("v.childIPRightList");
        var flag= true;
        for(var i in itemsList){
            console.log('Checking Values'+ JSON.stringify(itemsList[i]));
            if(itemsList[i].IP_Type_of_Right__c =='' || itemsList[i].IP_Type_of_Right__c =='--None--'){
                flag = false;
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "Error",
                                          "message": "Please Select Type of Right field at Country "+itemsList[i].IP_Country__c,
                                          "type": "Error"});
                    toastEvent.fire();
                    component.set("v.showSpinner", false);
            }
        }
        //    $A.util.addClass(component.find('card'), 'hide');
        if(flag == true){
        var action = component.get("c.getInsertChildIPRight");
        action.setParams({
            'IPRecordId': component.get("v.recordId"),
            'insertList': component.get("v.childIPRightList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "Success!",
                                          "message": "Patent Child Record(s) is/are Created Successfully",
                                          "type": "success"});
                    toastEvent.fire();
                    component.set("v.showSpinner", false);
                    component.set("v.responseChildIPRightList", result);
                    component.set("v.flag1", false);
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            }
        });
        
        $A.enqueueAction(action);
        }
    },
    
    handleCancel:function(component, event){
        $A.get("e.force:closeQuickAction").fire();
    }
})