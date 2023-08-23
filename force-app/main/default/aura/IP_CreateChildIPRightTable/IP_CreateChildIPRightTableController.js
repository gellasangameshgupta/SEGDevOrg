({
    removeRow : function(component, event, helper){
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
       component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
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
        component.set("v.listOfFirmAttorneyRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchFirmAttorney");
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
             component.set("v.listOfFirmAttorneyRecords", null ); 
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
    //    component.set("v.noOfRecordsSelected", component.get("v.noOfRecordsSelected")+1);
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        component.set("v.caseInstance.IP_Law_Firm__c" , selectedAccountGetFromEvent.Id); 
       console.log('Selected record '+ JSON.stringify(component.get("v.selectedRecord")));
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        component.set("v.SearchFirmAttorney", component.get("v.selectedRecord").Name);
	},
    
    changeIPRightId : function(component, event, helper){
        var selectedVal = component.get("v.caseInstance").IP_Relationship_to_Parent__c;
        var iprightnum = component.get("v.caseInstance").IP_Right_ID__c; 
        
        var currentIPRight = component.get("v.parentIPRight");
        var splitVals=currentIPRight.IP_Right_ID__c.split("-");
        var apendval='';
        for(var i in splitVals){
            if(i>2){
                apendval = apendval+'-'+splitVals[i];
            }else if(i>1)
            {
                apendval = splitVals[i];
            }
        }debugger;console.log('map value'+component.get('v.countryCountMap'))
        var cnt = component.get("v.caseInstance").IP_Country__c;
        var mapObject= component.get('v.countryCountMap');// alert('mapObject[cnt]'+mapObject[cnt])
        var count ='';
        if(mapObject[cnt] >= 0)
            count = mapObject[cnt]; 
        if(count != 0 && count !='')
            count= count+1;
        if (count == 0 || count == '')
            var currentIPRightIDVal = currentIPRight.IP_Right_ID__c.split("-")[0]+'-'+component.get("v.caseInstance").IP_Country__c;
        else
            var currentIPRightIDVal = currentIPRight.IP_Right_ID__c.split("-")[0]+'-'+component.get("v.caseInstance").IP_Country__c+count;   
    	if(apendval.length > 0)
        {
            currentIPRightIDVal = currentIPRightIDVal +'-'+apendval;
        }
        var action = component.get("c.getAppendValue");
        action.setParams({
            'SelectedVal': selectedVal
        });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
             //   alert('Val of Return'+ storeResponse);
                if(storeResponse == null){
  					component.set("v.caseInstance.IP_Right_ID__c", currentIPRightIDVal);
                }else if(storeResponse.length > 0){
                    iprightnum = currentIPRightIDVal+'-'+storeResponse;
                    component.set("v.caseInstance.IP_Right_ID__c", iprightnum);
                }
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
		        
    }
  
})