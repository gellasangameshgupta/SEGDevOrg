({
    fetchCountryPicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'field_apiname': component.get("v.Country"),
            'nullRequired': false // includes --None--
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var cntryMap = [];
                cntryMap.push({key: 'DE', value: 'DE', selected: true});
                for(var key in result){
                    cntryMap.push({key: key, value: result[key]});
                }
                component.set("v.countryMap", cntryMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchTypeOfRightPicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'field_apiname': component.get("v.TypeOfRight"),
            'nullRequired': false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var rightMap = [];
                for(var key in result){
                    rightMap.push({key: key, value: result[key]});
                }
                component.set("v.typeOfRightMap", rightMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchRelationshipToParentPicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'field_apiname': component.get("v.RelationToParent"),
            'nullRequired': true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var parentMap = [];
                for(var key in result){
                    parentMap.push({key: key, value: result[key]});
                }
                component.set("v.relationToParentMap", parentMap);
            } 
        });
        $A.enqueueAction(action);
    },
    
    getInventionDetails: function(component){
        var recId = component.get("v.recordId");
       	component.set("v.flag", false);
        component.set("v.flag1", true);
        var action = component.get('c.getInvention'); 
        action.setParams({
            "InventionId" : recId
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                component.set('v.sObjList', a.getReturnValue());
            }
            var InvetionObjRec= component.get("v.sObjList");
            var pFamilyID = 'P'+InvetionObjRec.IP_IDFNumber__c.split("-")[1];
        	component.set("v.NewIPRight.IP_Patent_Family__c", pFamilyID);
            component.set("v.NewIPRight.IP_Right_ID__c", pFamilyID+'-'+component.get("v.NewIPRight.IP_Country__c"));
        });
        $A.enqueueAction(action);
    },
    updateIPRight: function(component) {
        var ipRightObj = component.get("v.NewIPRight");
        var action = component.get('c.insertIPRightandPatentFamily'); 
        action.setParams({
            "InventionId" : component.get('v.recordId'),
            "ipRight"   :	ipRightObj
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
              //  component.set('v.sObjList', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    
    fetchProductClassPicklist: function(component){
        var action = component.get("c.getPiklistValues");
        action.setCallback(this, function(response) {
            console.log('response---',response);
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.ProductList", plValues);
            }
        });
        $A.enqueueAction(action);
    }

})