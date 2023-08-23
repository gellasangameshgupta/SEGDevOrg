({
	helperInit : function(component, event, helper) {
        /*
        var action = component.get('c.fetchDetails');  
        action.setParams({
            LimitSize : 10,
            Orderby : component.get("v.sortBy"),
            OrderDir : component.set("v.sortDirection")
         }); */
          var action = component.get("c.fetchDetailsNext");
         action.setParams({
            LimitSize : component.get("v.rowsToLoad"),
            recId : null,
            Orderby : null,
            OrderDir : null
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
          //  alert(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {     
                if(response.getReturnValue()!=null && response.getReturnValue().length>0)
                {
                    component.set('v.slotData',response.getReturnValue());
                    component.set("v.showTimeSlots",true);
                    if (component.get('v.slotData').length >= component.get('v.totalNumberOfRows')) {
                        component.set('v.enableInfiniteLoading', false);
                        component.set('v.loadMoreStatus', '');
                    }
                    
                }
                else
                {
                    component.set("v.showTimeSlots",false);    
                 //   helper.ToastMethod("Info",$A.get("$Label.c.DCA_info1"),"info")
                }
                     
            }
            else
            {
                component.set("v.showTimeSlots",false);  
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
            component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
        helper.helperFetchSubmitted(component, event, helper);
      
	},
    helperFetchSubmitted : function(component, event, helper) {       
        /* fetch submitted details */
         var action = component.get("c.fetchSubmittedDetailsNext");
         action.setParams({
            LimitSize : component.get("v.rowsToLoadSub"),
            recId : null,
            Orderby : null,
            OrderDir : null
         });
      //  var action = component.get('c.fetchSubmittedDetails');   
        action.setCallback(this, function(response) {
            var state = response.getState();
          //  alert(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {     
                if(response.getReturnValue()!=null && response.getReturnValue().length>0)
                {
                    component.set('v.submittedData',response.getReturnValue());
                    //component.set("v.showSubmitted",true);
                    if (component.get('v.submittedData').length >= component.get('v.totalNumberOfRowsSub')) {
                    component.set('v.enableInfiniteLoadingSub', false);
                   // component.set('v.loadMoreStatusSub', 'No more data to load');
                } 
                }
                else
                {	
                    component.set("v.showSubmitted",false);    
                }
                     
            }
            else
            {
                component.set("v.showSubmitted",false);  
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
            
        });
         $A.enqueueAction(action);
	},
     helperUpdateModal : function(component, event, helper) {
        component.set("v.ShowDCAUpdate",true);
	},
        
    helperSubmitRecord : function(component, event, helper) {
        var action = component.get('c.submitRecord'); 
        var DCA=component.get("v.DCA_Update");
        var person = {
            userList: component.get("v.rowsForUpdate"),
            DCA_Status: DCA.DCA_Status__c,
            DCA_ApprovalComment: DCA.DCA_ApprovalComment__c
        };
        action.setParams({
            'sheet': JSON.stringify(person)
        }); 
        
        if(DCA.DCA_Status__c===null || DCA.DCA_Status__c==='None' || DCA.DCA_Status__c===undefined)
        {
            helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error2"),"error") 
        }
        else if(DCA.DCA_Status__c==='Department Change' && (DCA.DCA_ApprovalComment__c===undefined || DCA.DCA_ApprovalComment__c===''))
        {
            helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error7"),"error") 
        }
        else{
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                	helper.ToastMethod("Success!",$A.get("$Label.c.DCA_success1"),"success");
                    component.set("v.rowsForUpdate",null);
                	helper.helperInit(component, event, helper);
                $A.get('e.force:refreshView').fire();
                
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
            component.set("v.ShowDCAUpdate",false);
            
        });
        $A.enqueueAction(action);
        }
    },
    helperShowProcessButton : function(component, event, helper){
        var action = component.get("c.showProcessingButton");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.showProcessing", a.getReturnValue());
                    let columns = [
                        {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                        {label: 'Approval Status', fieldName: 'DCA_Status',sortable : true, type: 'text'},
                        {label: 'Approval Comment', fieldName: 'DCA_ApprovalComment',sortable : true, type: 'text'},
                        {label: 'Name of SAP System', fieldName: 'DCA_NameofSAPSystem',sortable : true, type: 'text'},
                        {label: 'Auth Type', fieldName: 'DCA_AuthType',sortable : true, type: 'text'},
                        {label: 'Authorization', fieldName: 'DCA_Authorization',sortable : true, type: 'text'},
                        {label: 'Authorization Description', fieldName: 'DCA_AuthorizationDescription',sortable : true, type: 'text'},
                        {label: 'Function', fieldName: 'DCA_Function',sortable : true, type: 'text'},
                        {label: 'Business Case', fieldName: 'DCA_BusinessCase',sortable : true, type: 'text'},
                        {label: 'Risk', fieldName: 'DCA_Risk',sortable : true, type: 'text'},
                        {label: 'Role', fieldName: 'DCA_Role',sortable : true, type: 'text'},
                        {label: 'Role Description', fieldName: 'DCA_RoleDescription',sortable : true, type: 'text'},
                        {label: 'Locked By', fieldName: 'DCA_LockedBy',sortable : true, type: 'text'},
                        {label: 'Valid From', fieldName: 'DCA_ValidFrom',sortable : true, type: 'text'},
                        {label: 'Valid To', fieldName: 'DCA_ValidTo',sortable : true, type: 'text'},
                        {label: 'Department (From SAP Data)', fieldName: 'DCA_Department',sortable : true, type: 'text'},
                        {label: 'Department (Active Directory)', fieldName: 'DCA_DepartmentActive',sortable : true, type: 'text'},
                        {label: 'Location', fieldName: 'DCA_Location',sortable : true, type: 'text'},
                        {label: 'Company', fieldName: 'DCA_Company',sortable : true, type: 'text'},
                    ];
                    let submittedColumns = [
                        {label: 'Name', fieldName: 'recordLink', type: 'url',sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
                        {label: 'Approval Status', fieldName: 'DCA_Status', sortable : true,type: 'text'},
                        {label: 'Approval Comment', fieldName: 'DCA_ApprovalComment',sortable : true, type: 'text'},
                        {label: 'Processing Comment', fieldName: 'DCA_ProcessingComment',sortable : true, type: 'text'},
                        {label: 'Name of SAP System', fieldName: 'DCA_NameofSAPSystem',sortable : true, type: 'text'},
                        {label: 'Auth Type', fieldName: 'DCA_AuthType',sortable : true, type: 'text'},
                        {label: 'Authorization', fieldName: 'DCA_Authorization',sortable : true, type: 'text'},
                        {label: 'Authorization Description', fieldName: 'DCA_AuthorizationDescription',sortable : true, type: 'text'},
                        {label: 'Function', fieldName: 'DCA_Function',sortable : true, type: 'text'},
                        {label: 'Business Case', fieldName: 'DCA_BusinessCase',sortable : true, type: 'text'},
                        {label: 'Risk', fieldName: 'DCA_Risk',sortable : true, type: 'text'},
                        {label: 'Role', fieldName: 'DCA_Role',sortable : true, type: 'text'},
                        {label: 'Role Description', fieldName: 'DCA_RoleDescription',sortable : true, type: 'text'},
                        {label: 'Locked By', fieldName: 'DCA_LockedBy',sortable : true, type: 'text'},
                        {label: 'Valid From', fieldName: 'DCA_ValidFrom',sortable : true, type: 'text'},
                        {label: 'Valid To', fieldName: 'DCA_ValidTo',sortable : true, type: 'text'},
                        {label: 'Department (From SAP Data)', fieldName: 'DCA_Department',sortable : true, type: 'text'},
                        {label: 'Department (Active Directory)', fieldName: 'DCA_DepartmentActive',sortable : true, type: 'text'},
                        {label: 'Location', fieldName: 'DCA_Location',sortable : true, type: 'text'},
                        {label: 'Company', fieldName: 'DCA_Company',sortable : true, type: 'text'},
                        {label: 'Approval Date', fieldName: 'DCA_ApprovalDate',sortable : true, type: 'text'},
                        {label: 'Approver', fieldName: 'DCA_Approver',sortable : true, type: 'text'},     
                    ];
                        if(a.getReturnValue()===false)
                        {
							let mycolumns = columns.filter(col => col.label !== 'Approval Comment');
                        	component.set('v.slotColumns',mycolumns);   
                            let submitcolumns = submittedColumns.filter(col => col.label !== 'Processing Comment');
                        	component.set('v.submittedColumns',submitcolumns); 
                        }
                        else
                        {
                            component.set('v.slotColumns',columns); 
                            component.set('v.submittedColumns',submittedColumns); 
                        }
                                      
               
                
                helper.helperInit(component, event, helper);
            } 
        });
        $A.enqueueAction(action);
    },

    helperfetchStatusPicklist : function(component, event, helper){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'field_apiname': 'DCA_Status__c'
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.StatusPicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    helperfetchCount : function(component, event, helper){
        var action = component.get("c.fetchCount");
        component.set("v.rowsToLoadInit",component.get("v.rowsToLoad"));
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var slot=a.getReturnValue();
               // alert('t='+slot.NoOfRecords+'  >sub:'+slot.NoOfRecordsSubmitted);
                if(slot===null || slot==='None' || slot===undefined)
                {
                    component.set("v.totalNumberOfRowsSub",0);
                    component.set("v.totalNumberOfRows",0);                    
                }
                else{
                    if(slot.NoOfRecordsSubmitted!==null || slot.NoOfRecordsSubmitted!=='None' || slot.NoOfRecordsSubmitted!==undefined)
                    component.set("v.totalNumberOfRowsSub",slot.NoOfRecordsSubmitted);
                    if(slot.NoOfRecords!==null || slot.NoOfRecords!=='None' || slot.NoOfRecords!==undefined)
                    component.set("v.totalNumberOfRows",slot.NoOfRecords);   
                }
                    
                
            } 
        });
        $A.enqueueAction(action);
    },
    fetchDataNext: function (component,  event, numberOfRecords) {
       
         //var dataPromise;
         var data = component.get("v.slotData");
         var dataSize = component.get("v.slotData").length;
         var lastId = data[dataSize - 1].Id;
        console.log('--lastId----'+lastId);
         var action = component.get("c.fetchDetailsNext");
         action.setParams({
            LimitSize : component.get("v.rowsToLoad"),
            recId : lastId,
            Orderby : component.get("v.sortedBy"),
            OrderDir : component.set("v.sortedDirection")
         });
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if (component.get('v.slotData').length >= component.get('v.totalNumberOfRows')) {
                    component.set('v.enableInfiniteLoading', false);
                    component.set('v.loadMoreStatus', 'No more data to load');
                } else {
                    var currentData = component.get('v.slotData');
                    var newData = currentData.concat(response.getReturnValue());
                    //////////////
                    var uniqueObjs = {};
                    newData.forEach(function(conItem){
                        uniqueObjs[conItem.Id] = conItem;
                    });
                    newData = [];
                    var keys = Object.keys(uniqueObjs);
                    keys.forEach(function(key){
                        newData.push(uniqueObjs[key]);
                    });
                    
                    /////////////// 
                    component.set('v.slotData', newData);
                    component.set('v.loadMoreStatus', '');
                 //   alert('loaded>:'+component.get('v.slotData').length+'>total:'+component.get('v.totalNumberOfRows'));
                    if (component.get('v.slotData').length >= component.get('v.totalNumberOfRows')) {
                    component.set('v.enableInfiniteLoading', false);
                    component.set('v.loadMoreStatus', '');
                } 
                }
                event.getSource().set("v.isLoading", false);
            }
             else if (state === "ERROR") {
                 helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
                 
             }
        });
        $A.enqueueAction(action);
    },
     fetchDataNextSub: function (component,  event, numberOfRecords) {
       
         //var dataPromise;
         var data = component.get("v.submittedData");
         var dataSize = component.get("v.submittedData").length;
         var lastId = data[dataSize - 1].Id;
        console.log('--lastId----'+lastId);
         var action = component.get("c.fetchSubmittedDetailsNext");
         action.setParams({
            LimitSize : component.get("v.rowsToLoadSub"),
            recId : lastId,
            Orderby : component.get("v.sortBySubmitted"),
            OrderDir : component.set("v.sortDirectionSubmitted")
         });
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if (component.get('v.submittedData').length >= component.get('v.totalNumberOfRowsSub')) {
                    component.set('v.enableInfiniteLoadingSub', false);
                    component.set('v.loadMoreStatusSub', 'No more data to load');
                } else {
                    var currentData = component.get('v.submittedData');
                    var newData = currentData.concat(response.getReturnValue());
                    //////////////
                    var uniqueObjs = {};
                    newData.forEach(function(conItem){
                        uniqueObjs[conItem.Id] = conItem;
                    });
                    newData = [];
                    var keys = Object.keys(uniqueObjs);
                    keys.forEach(function(key){
                        newData.push(uniqueObjs[key]);
                    });
                    
                    ///////////////
                    component.set('v.submittedData', newData);
                    component.set('v.loadMoreStatusSub', '');
                }
                event.getSource().set("v.isLoading", false);
            }
             else if (state === "ERROR") {
                 helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
                 
             }
        });
        $A.enqueueAction(action);
    },
    helperSearch : function(component, event, helper) {
        var searchName=component.get("v.searchName");
        var searchAuth=component.get("v.searchAuth");
        var searchRole=component.get("v.searchRole");
          var action = component.get("c.SearchData");
         action.setParams({
            searchName : searchName,
            searchAuth : searchAuth,
            searchRole : searchRole,
            Orderby : null,
            OrderDir : null
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
          //  alert(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {     
                if(response.getReturnValue()!=null && response.getReturnValue().length>0)
                {
                    if(response.getReturnValue().length > $A.get("$Label.c.DCA_RecordLoadLimit"))
                        helper.ToastMethod("Info!",$A.get("$Label.c.DCA_info2"),"Info");
                    else{
                        component.set('v.slotData',response.getReturnValue());
                        component.set("v.showTimeSlots",true);
                        component.set('v.enableInfiniteLoading', false);    
                    }                  
                }
                else
                {
                    component.set("v.showTimeSlots",false);    
                    helper.ToastMethod("Info","Sorry no search results found","info")
                }
                     
            }
            else
            {
                component.set("v.showTimeSlots",false);  
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
            component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
        helper.helperFetchSubmitted(component, event, helper);
      
	},
     ToastMethod : function(title,message,type) {
		 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type":type
                    });
                    toastEvent.fire();
	}
})