({
    fetchTypeOfRightPicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'field_apiname': component.get("v.TypeOfRight"),
            'nullRequired': true
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
    searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'selectedList' : component.get("v.selectedListOfCountries"),
            'recordID'  : component.get("v.recordId")
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
    createObjectData: function(component, event) {
        var mapObject= component.get('v.countryCountMap');
        // get the contactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.childIPRightList");
        var cnt = component.get("v.selectedRecord").DeveloperName;
        var splitVals=component.get("v.currentIPRightRec").IP_Right_ID__c.split("-");
    //    alert('Split Values '+JSON.stringify(splitVals));
        var apendval='';
        for(var i in splitVals){
            if(i>2){
                apendval = apendval+'-'+splitVals[i];
            }else if(i>1)
            {
                apendval = splitVals[i];
            }
        }
        var count = '';//alert('mapObject[cnt] 11 '+mapObject[cnt])
        if(mapObject[cnt] >= 0)
        count = mapObject[cnt]; 
        if(count != 0 && count !='')
           count= count+1;
        if (count == 0 || count == '')
            var currentIdNum = component.get("v.currentIPRightRec").IP_Right_ID__c.split("-")[0]+'-'+cnt;
        else 
            var currentIdNum = component.get("v.currentIPRightRec").IP_Right_ID__c.split("-")[0]+'-'+cnt+count; 
        
        if(apendval.length > 0)
        {
            currentIdNum = currentIdNum +'-'+apendval;
        }
        RowItemList.push({
            'sobjectType': 'Case',
            'IP_Country__c': cnt,
            'IP_Type_of_Right__c': '',
            'IP_Relationship_to_Parent__c': '',
            'IP_Right_ID__c': currentIdNum,
            'IP_Law_Firm_Reference__c': component.get("v.currentIPRightRec").IP_Law_Firm_Reference__c,
            'IP_Law_Firm__c': '',
            'IP_Law_Firm_Text__c': ''
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.childIPRightList", RowItemList);
    },
})