({
    doInit : function(component, event, helper) {
        var action=component.get("c.fetchInventionDisclosures");
        action.setCallback(this,function(resp){
            var state=resp.getState();
            if(state==="SUCCESS"){
                var candrecords = resp.getReturnValue()
               /* candrecords.forEach(function(candrecord){
                    candrecord.IDFNumber = '/'+candrecord.Id;
                });*/
                component.set("v.listofcases",candrecords);
                component.set("v.FilteredData",candrecords)
                helper.displayobject(component,event,candrecords);
            }
            var columns=[
                {label: 'IDF ID', fieldName: 'IP_IDFNumber__c', sortable: true, type: 'text'},
                {label: 'Title', fieldName: 'Subject', sortable: true, type: 'text'},
                {label: 'Status', fieldName: 'IP_Status__c', sortable: true, type: 'text'},
                {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'View', name: 'view_details', title: 'Click to View Details'}},
            ]
                component.set("v.columns",columns);
                });
                $A.enqueueAction(action);
                
                },
                handleRowAction:function(component, event, helper){
                var row = event.getParam('row');
                //alert(JSON.stringify(row));
                component.set("v.myInventionRec",row);
               // if(row.Status=='Draft'||row.Status=='Further Info Needed'){
                if(row.IP_Status__c=='Draft'||row.IP_Status__c=='Further Info Needed'){
                component.set("v.isDisabled",false);
                }else{ component.set("v.isDisabled",true)};
                //alert('row'+row.Fill_Form_or_Upload_IDF__c);
                if(row.IP_Fill_Form_or_Upload_IDF__c=='I want to enter my invention details in this form'){
                component.set("v.fillOrUploadFormrow",true);
                }else{
                component.set("v.fillOrUploadFormrow",false);
                }
                //alert(component.get("v.fillOrUploadFormrow"));
                component.set("v.myInvention",true);
                
                },
                filter:function(component, event, helper){
                var searchval = component.get("v.filter");
                var oplist = component.get("v.listofcases");debugger;
                var finallist = [];
            for(var i = 0; i < oplist.length; i++){
                var Subject = oplist[i].Subject.toLowerCase();
                var IdfNumber = oplist[i].IP_IDFNumber__c.toLowerCase();
                searchval = searchval.toLowerCase();
                if(Subject.includes(searchval) )
                {
                   finallist.push(oplist[i]); 
                }
                else if(IdfNumber.includes(searchval) )
                {
                   finallist.push(oplist[i]); 
                }
                //if(oplist[i].Subject.includes(searchval)){
                    //finallist.push(oplist[i]);
               // }
            }debugger;
            helper.displayobject(component, event, finallist);
        },
                           handleNext : function (component, event, helper) {
            if(component.get("v.FilteredData")!=undefined && component.get("v.FilteredData").length>0){
                var pageNumber = component.get("v.pageNumber");
                component.set("v.pageNumber", pageNumber+1);
                helper.displayobject(component, event, component.get("v.listofcases"));
            }
        },
            handlePrev : function(component, event, helper) {  
                if(component.get("v.FilteredData")!=undefined && component.get("v.FilteredData").length>0){
                    var pageNumber = component.get("v.pageNumber");
                    component.set("v.pageNumber", pageNumber-1);
                    helper.displayobject(component, event, component.get("v.listofcases"));
                }
            },
    handleColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    })