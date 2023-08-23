({
	getColumnDefinitions: function (component, event, helper) {
        var columns = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
            {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Granted Population', fieldName: 'DCA_Hr_Granted_Population', type: 'text', sortable: true},
            {label: 'Target Population', fieldName: 'DCA_Hr_Target_Population', type: 'text', sortable: true},
            {label: 'Country', fieldName: 'DCA_Location', type: 'text',sortable : true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
        
        var columnsSAP = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
            {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Valid From', fieldName: 'DCA_ValidFrom', type: 'text', sortable: true},
            {label: 'Valid To', fieldName: 'DCA_ValidTo', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
        
         var columnsESS = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
             {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Valid From', fieldName: 'DCA_ValidFrom', type: 'text', sortable: true},
            {label: 'Valid To', fieldName: 'DCA_ValidTo', type: 'text', sortable: true},
            {label: 'Creation Date', fieldName: 'DCA_CreationDate', type: 'text', sortable: true},
            {label: 'Country', fieldName: 'DCA_Hr_Country', type: 'text',sortable : true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
        var columnseTime = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
             {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Function Access Profile', fieldName: 'DCA_Hr_Function_Access_Profile', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
        
        var columnsSPM = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
            {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Scope', fieldName: 'DCA_Hr_Scope', type: 'text', sortable: true},
            {label: 'Scope Level', fieldName: 'DCA_Hr_Scope_Level', type: 'text',sortable : true},
            {label: 'Country', fieldName: 'DCA_Hr_Country', type: 'text',sortable : true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
              
        var columnsEsevice = [
            {label: 'Name', fieldName: 'recordLink', type: 'url', sortable : true, typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
            {label: 'User Id', fieldName: 'DCA_Hr_User_Id', type: 'text', sortable: true},
            {label: 'Email', fieldName: 'Email', type: 'text', sortable: true},
            {label: 'Role Id', fieldName: 'DCA_Hr_Role_Id', type: 'text', sortable: true},
            {label: 'Role Name', fieldName: 'DCA_Role', type: 'text', sortable: true},
            {label: 'Risk Assessment', fieldName: 'DCA_Risk', type: 'text', sortable: true},
            {label: 'Country', fieldName: 'DCA_Location', type: 'text',sortable : true},
            {label: 'Product', fieldName: 'DCA_Hr_Products', type: 'text',sortable : true},
            {label: 'Status', fieldName: 'DCA_Status', type: 'text',sortable : true}
        ];
        component.set("v.columns",columns);
        component.set("v.columnsSAP",columnsSAP);
        component.set("v.columnsESS",columnsESS);
        component.set("v.columnseTime",columnseTime);
        component.set("v.columnsSPM",columnsSPM);
        component.set("v.columnsEsevice",columnsEsevice);
       // return columns;
    },
    
    getContactData: function (component, event, helper) {
         var action = component.get("c.returncontact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                component.set("v.data", records);
            }
        });
        $A.enqueueAction(action);
    },
    

     getContactDataGeneral: function (component, event, helper) {
         //alert('Helper');
         var HRApp = component.get("v.HRApp");
         var action = component.get("c.returncontactGeneral");
         action.setParams({
            appName : HRApp 
         });
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                component.set("v.data", records);
            }
            component.set("v.Spinner",false);
        });
        $A.enqueueAction(action);
    },
    helperSearch : function(component, event, helper) {
        var searchName=component.get("v.searchName");
        var searchStatus=component.get("v.searchStatus");
        var searchRole=component.get("v.searchRole");
        var HRApp = component.get("v.HRApp");
        //component.set("v.selectedData",[]);
          var action = component.get("c.SearchData");
         action.setParams({
            searchName : searchName,
            searchStatus : searchStatus,
            searchRole : searchRole,
            Orderby : null,
            OrderDir : null,
            appName : HRApp 
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
                        var records = response.getReturnValue();
                        component.set("v.data", records); 
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
               // component.set("v.showTimeSlots",false);  
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
           // component.set("v.Spinner",false);
        });
         $A.enqueueAction(action);
        //helper.helperFetchSubmitted(component, event, helper);
      
	},
    ToastMethod : function(title,message,type) {
		 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type":type
                    });
                    toastEvent.fire();
        
	},
     helperUpdateModal : function(component, event, helper) {
        component.set("v.ShowDCAUpdate",true);
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
      helperSubmitRecord : function(component, event, helper) {
         // alert('helper called');
        var action = component.get('c.submitRecord'); 
        var DCA=component.get("v.DCA_Update");
        var HRApp = component.get("v.HRApp");
        var person = {
            userList: component.get("v.rowsForUpdate"),
            DCA_Status: DCA.DCA_Status__c,
            DCA_ApprovalComment: DCA.DCA_ApprovalComment__c
        };
        action.setParams({
            'sheet': JSON.stringify(person),
            appName : HRApp
        }); 
        
        if(DCA.DCA_Status__c===null || DCA.DCA_Status__c==='None' || DCA.DCA_Status__c===undefined)
        {
            helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error2"),"error") 
        }
        else{
        action.setCallback(this, function(response) {
            var state = response.getState();
            var obj =[];
            if (state === "SUCCESS") {  
                	helper.ToastMethod("Success!",$A.get("$Label.c.DCA_success1"),"success");
                    component.set("v.rowsForUpdate",[]);
                    component.set("v.selectedData",obj);
               // alert('Selected Data '+component.get("v.selectedData"))
                	helper.getContactDataGeneral(component, event, helper);
                //$A.get('e.force:refreshView').fire();
                
            }
            else
            {
                helper.ToastMethod("Error!",$A.get("$Label.c.DCA_error1"),"error")
            }
            component.set("v.ShowDCAUpdate",false);
            
        });
        $A.enqueueAction(action);
        }
    }
})