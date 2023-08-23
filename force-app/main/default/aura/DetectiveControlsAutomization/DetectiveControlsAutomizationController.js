({
    doInit : function(component, event, helper) {
         component.set("v.Spinner",true);
        helper.helperShowProcessButton(component, event, helper);
        helper.helperfetchStatusPicklist(component, event, helper);
        helper.helperfetchCount(component, event, helper);
    },
    /*
    handleRowAction :function(component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('*****row:'+JSON.stringify(row));
        switch (action.name) {
            case 'Update Status':
                helper.helperUpdateModal(component, event, helper, row);
                break;
           
        }
    },  */
    SubmitDCA: function(component, event, helper) {
        helper.helperSubmitRecord(component, event, helper);  
    },
    closeModal: function(component, event, helper) {
        component.set("v.ShowDCAUpdate",false);
    },
   ApproveModal: function(component, event, helper) {
       var selectedRows = component.get("v.rowsForUpdate");
       if(selectedRows.length>0)
       {
           component.set("v.DCA_Update.DCA_Status__c","Approved");
           component.set("v.DCA_Update.DCA_ApprovalComment__c","");
           helper.helperUpdateModal(component, event, helper);           
       }
       else
           helper.ToastMethod("Error!",'Select atleast one row',"error");
       
    },
    RejectModal: function(component, event, helper) {
        var selectedRows = component.get("v.rowsForUpdate");
        if(selectedRows.length>0)
        {
            component.set("v.DCA_Update.DCA_Status__c","Rejected");
            component.set("v.DCA_Update.DCA_ApprovalComment__c","");
            helper.helperUpdateModal(component, event, helper);
        }
        else
           helper.ToastMethod("Error!",'Select atleast one row',"error");
    },
    DeleteModal: function(component, event, helper) {
        var selectedRows = component.get("v.rowsForUpdate");
        if(selectedRows.length>0)
        {
            component.set("v.DCA_Update.DCA_Status__c","Delete User");
            component.set("v.DCA_Update.DCA_ApprovalComment__c","");
            helper.helperUpdateModal(component, event, helper);
        }
        else
            helper.ToastMethod("Error!",'Select atleast one row',"error");
    },
    DepartmentChangeModal: function(component, event, helper) {
        var selectedRows = component.get("v.rowsForUpdate");
        if(selectedRows.length>0)
        {
            component.set("v.DCA_Update.DCA_Status__c","Department Change");
            component.set("v.DCA_Update.DCA_ApprovalComment__c","");
            helper.helperUpdateModal(component, event, helper);
        }
        else
            helper.ToastMethod("Error!",'Select atleast one row',"error");
    },
    
    ProcessedModal: function(component, event, helper) {
        var selectedRows = component.get("v.rowsForUpdate");
        if(selectedRows.length>0)
        {
            component.set("v.DCA_Update.DCA_Status__c","Processed");
            component.set("v.DCA_Update.DCA_ApprovalComment__c","");
            helper.helperUpdateModal(component, event, helper);
        }
        else
            helper.ToastMethod("Error!",'Select atleast one row',"error");
    },
    getSelectedRec: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
       // alert("0::"+JSON.stringify(selectedRows));
        component.set("v.rowsForUpdate",selectedRows);
                
    },
    handleSort : function(component,event,helper){
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        //var selectedRows = event.getParam('selectedRows');
        var selected = component.find('myTable').getSelectedRows();
        
        var allSelectedRows = [];
        
        selected.forEach(function(row) {
                allSelectedRows.push(row.Id);
            });
        
        var data = component.get("v.slotData");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        if(fieldName == 'recordLink'){ 
            key = function(a) { return a['Name']; }            
        }
        data.sort(function(a,b){ 
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });  
        
        //setting the data table variables after sorting
        component.set("v.slotData",data);
        component.set("v.sortBy",fieldName);
        component.set("v.sortDirection",sortDirection);
        
        //setting the selectedRows back after sorting
        component.set("v.selectedData", allSelectedRows);
    },
    handleSortSubmitted : function(component,event,helper){
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBySubmitted",fieldName);
        component.set("v.sortDirectionSubmitted",sortDirection);
         var data = component.get("v.submittedData");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
         if(fieldName == 'recordLink'){ 
             key = function(a) { return a['Name']; }            
         }
          data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });  
           
           
          component.set("v.submittedData",data);
    },
    loadMoreData: function (component,event,helper) {
        var rowsToLoad = component.get('v.rowsToLoad');
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchDataNext(component, event, component.get("v.slotData").length);
    },
    
    loadMoreDataSubmitted: function (component,event,helper) {
        var rowsToLoad = component.get('v.rowsToLoadSub');
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatusSub', 'Loading');
        helper.fetchDataNextSub(component, event, component.get("v.submittedData").length);
    },
    ViewAllData: function (component,event,helper) {
        //alert($A.get("$Label.c.DCA_RecordLoadLimit"));
        if(component.get("v.totalNumberOfRows") > $A.get("$Label.c.DCA_RecordLoadLimit") || component.get("v.totalNumberOfRowsSub") > $A.get("$Label.c.DCA_RecordLoadLimit"))
            helper.ToastMethod("Info!",$A.get("$Label.c.DCA_info4"),"Info");
            else{
                component.set("v.Spinner",true);
                var rowsToLoad = component.get('v.rowsToLoadSub');
                component.set('v.loadMoreStatusSub', '');
                component.set('v.loadMoreStatus', '');
                component.set("v.rowsToLoadSub",component.get("v.totalNumberOfRowsSub"));
                component.set("v.rowsToLoad",component.get("v.totalNumberOfRows"));
                component.set("v.searchName",'');
                component.set("v.searchAuth",'');
                component.set("v.searchRole",'');
                helper.helperInit(component, event, helper);
            }
        
        //helper.fetchDataNextSub(component, event, component.get("v.submittedData").length);
       // helper.fetchDataNext(component, event, component.get("v.slotData").length);
    },
     Search: function (component,event,helper) {
        //alert($A.get("$Label.c.DCA_RecordLoadLimit"));
        var searchName=component.get("v.searchName");
        var searchAuth=component.get("v.searchAuth");
        var searchRole=component.get("v.searchRole");
        if( (searchName=== undefined || searchName==='') && (searchAuth===undefined || searchAuth=='') && (searchRole==undefined || searchRole=='') )
        {
            component.set('v.enableInfiniteLoading', true);
            component.set('v.loadMoreStatus', 'Loading');
            component.set("v.rowsToLoad",component.get("v.rowsToLoadInit"));
             component.set("v.Spinner",true);
            helper.helperInit(component, event, helper);
        }
            else{
                component.set("v.Spinner",true);
                var rowsToLoad = component.get('v.rowsToLoadSub');
              //  component.set('v.loadMoreStatusSub', '');
                component.set('v.loadMoreStatus', '');
              //  component.set("v.rowsToLoadSub",component.get("v.totalNumberOfRowsSub"));
              //  component.set("v.rowsToLoad",component.get("v.totalNumberOfRows"));
                helper.helperSearch(component, event, helper);
            }
    },
    ClearFilters: function (component,event,helper) {
        component.set("v.searchName","");
        component.set("v.searchAuth","");
        component.set("v.searchRole","");
        component.set('v.enableInfiniteLoading', true);
        component.set('v.loadMoreStatus', 'Loading');
        component.set("v.rowsToLoad",component.get("v.rowsToLoadInit"));
        component.set("v.Spinner",true);
        helper.helperInit(component, event, helper);
    },
})