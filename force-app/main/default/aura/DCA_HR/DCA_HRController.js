({
    doInit: function (component, event, helper) {
        //component.set('v.columns', helper.getColumnDefinitions());
        component.set("v.Spinner",true);
        helper.getColumnDefinitions(component, event, helper);
        component.set("v.HRApp", 'SFSFEC');
        helper.helperfetchStatusPicklist(component, event, helper);
        
        // helper.getContactData(component, event, helper);
        //helper.getContactDataGeneral(component, event, helper);
    },
    
    handleActiveSAPGV : function(component, event, helper) {
        //alert('Active SAPGV');
        component.set("v.HRApp", 'SAP GV GDMS');
         component.set("v.Spinner",true);
        //component.set("",)
        //alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    handleActiveSFSFEC : function(component, event, helper) {
        component.set("v.HRApp", 'SFSF EC');
         component.set("v.Spinner",true);
        //alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    handleActiveESSPORTAL : function(component, event, helper) {
        component.set("v.HRApp", 'ESS PORTAL');
         component.set("v.Spinner",true);
       // alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    handleActiveSPM : function(component, event, helper) {
        component.set("v.HRApp", 'SPM');
         component.set("v.Spinner",true);
       // alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    handleActiveeTime : function(component, event, helper) {
        component.set("v.HRApp", 'eTime');
         component.set("v.Spinner",true);
       // alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    handleActiveeServiceTicketing : function(component, event, helper) {
        component.set("v.HRApp", 'e service Ticketing');
         component.set("v.Spinner",true);
       // alert('app '+component.get("v.HRApp"));
        helper.getContactDataGeneral(component, event, helper);
    },
    
    loadMoreData: function (cmp, event, helper) {
        
    },
    
    Search: function (component,event,helper) {
               
        var searchName=component.get("v.searchName");
        var searchStatus=component.get("v.searchStatus");
        var searchRole=component.get("v.searchRole");
        if( (searchName=== undefined || searchName==='') && (searchStatus===undefined || searchStatus=='') && (searchRole==undefined || searchRole=='') )
        {   
            //component.set('v.enableInfiniteLoading', true);
            //component.set('v.loadMoreStatus', 'Loading');
            //component.set("v.rowsToLoad",component.get("v.rowsToLoadInit"));
            //component.set("v.Spinner",true);
            //helper.helperInit(component, event, helper);
            helper.getContactDataGeneral(component, event, helper);
        }
            else{ 
                //component.set("v.Spinner",true);
                //var rowsToLoad = component.get('v.rowsToLoadSub');
              //  component.set('v.loadMoreStatusSub', '');
               // component.set('v.loadMoreStatus', '');
              //  component.set("v.rowsToLoadSub",component.get("v.totalNumberOfRowsSub"));
              //  component.set("v.rowsToLoad",component.get("v.totalNumberOfRows"));
                helper.helperSearch(component, event, helper);
            }
    },
    
    ClearFilters: function (component,event,helper) {
        component.set("v.searchName",null);
        component.set("v.searchStatus",null);
        component.set("v.searchRole",null);
       // component.set('v.enableInfiniteLoading', true);
        //component.set('v.loadMoreStatus', 'Loading');
        //component.set("v.rowsToLoad",component.get("v.rowsToLoadInit"));
        //component.set("v.Spinner",true);
         helper.getContactDataGeneral(component, event, helper);
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
    getSelectedRec: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
       // alert("0::"+JSON.stringify(selectedRows));
        let obj =[];
        for(var i =0; i<selectedRows.length; i++){
            obj.push(selectedRows[i].Id);
            console.log('Selected rows name '+selectedRows[i].Id);
            
            //Here you can get all the needed fields output and print on the next page
        }
        component.set("v.selectedData",obj);
       // alert("selectedData::"+component.get("v.selectedData"));
        component.set("v.rowsForUpdate",selectedRows);
                
    },
      closeModal: function(component, event, helper) {
        component.set("v.ShowDCAUpdate",false);
    },
     SubmitDCA: function(component, event, helper) {
        helper.helperSubmitRecord(component, event, helper);  
    },
    handleSort : function(component,event,helper){
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        //var selectedRows = event.getParam('selectedRows');
        var HRApp = component.get("v.HRApp");
        if(HRApp == 'SFSF EC')
        var selected = component.find('SFSFEC').getSelectedRows();
        if(HRApp == 'SAP GV GDMS')
        var selected = component.find('SAPGVGDMS').getSelectedRows();
        if(HRApp == 'ESS PORTAL')
        var selected = component.find('ESSPORTAL').getSelectedRows();
        if(HRApp == 'eTime')
        var selected = component.find('eTime').getSelectedRows();
        if(HRApp == 'SPM')
        var selected = component.find('SPM').getSelectedRows();
        if(HRApp == 'e service Ticketing')
        var selected = component.find('eServiceTicketing').getSelectedRows();
        debugger;
        var allSelectedRows = [];
        
        selected.forEach(function(row) {
                allSelectedRows.push(row.Id);
            });
        
        var data = component.get("v.data");
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
        component.set("v.data",data);
        component.set("v.sortBy",fieldName);
        component.set("v.sortDirection",sortDirection);
        
        //setting the selectedRows back after sorting
        component.set("v.selectedData", allSelectedRows);
    }
    
    
})