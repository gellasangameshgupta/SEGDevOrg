({
    doInit : function(component, event, helper) {
        component.set("v.IsSpinner", true);  
        var action=component.get("c.getProductTypeOptions");
        action.setCallback(this,function(resp){
            var opts=[];
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            component.set("v.mapOfControlanddependent",resp.getReturnValue().contorlingAnddependentvalues);
            for(var i=0;i< resp.getReturnValue().productTypeOptions.length;i++){
                opts.push({"class": "optionClass", label: resp.getReturnValue().productTypeOptions[i], value: resp.getReturnValue().productTypeOptions[i]});
            }
            component.set("v.ProductTypeOptions",opts);
            var myArry=resp.getReturnValue();
            component.set("v.data",myArry);   
            component.set("v.IsSpinner", false);  
        });
        $A.enqueueAction(action);
        
        var action1=component.get("c.fetchLookUpValues");
        action1.setCallback(this,function(resp){
            
            var selRec=resp.getReturnValue();
            component.set("v.selectedLookUpRecords",selRec);
        });
        $A.enqueueAction(action1);
    },
    onChange: function (component, evt, helper) {
        console.log(component.find('specialPointstobeConsidered').get('v.value'));
        component.set("v.selected",component.find('specialPointstobeConsidered').get('v.value'));
    },
    fetchmessages : function(component) {
        var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
        window.addEventListener("message", $A.getCallback(function(event){
            console.log('VF origin', vfOrigin);
            console.log('Origin: ', event.origin);
            if(event.origin !== vfOrigin){
                console.log('VF origin', vfOrigin);
                console.log('Origin: ', event.origin);
                return;
            }
            console.log('event data: ',event.data);
            /*if(event.data === "NA"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please upload atleast one file.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();   
            }*/
            if(event.data === "Success"){
                component.set("v.IsSpinner", false);
                $A.get('e.force:refreshView').fire();      
            }
            if (event.data === "attached") {
                var isAttachmentValid = component.get("v.isAttachmentValid");
                isAttachmentValid = event.data;
                component.set("v.isAttachmentValid",isAttachmentValid);
            }
        }), false);
    },
    fillOrUploadForm:function(component, event, helper){
        var val=component.find("fillOrUploadForm").get("v.value");
        if(val=="I want to enter my invention details in this form"){
            component.set("v.fillOrUploadForm",true);
        }else{
            component.set("v.fillOrUploadForm",false);
        }
    },
    handleSubmit:function(cmp, event, helper){
        console.log('handle submit');
        cmp.set("v.IsSpinner", true);
        cmp.set("v.isSubmit", true);
        var subCateogory=cmp.find('subCateogory').get("v.value");
        if(cmp.get("v.bDisabledDependentFld")==false) {
            var val=cmp.find("subCateogory").get("v.value");
            console.log('Inside if at 85');
            if(val=="--- None ---"){
                cmp.set("v.isAllFieldsValid",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please enter Product Subcategories',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();
            }
        }
        if(subCateogory != "--- None ---" || cmp.get("v.bDisabledDependentFld")==true) {
            helper.validateFields(cmp, event, helper);
        }
        console.log('after  validateFields',cmp.get("v.isAllFieldsValid"));
        console.log('after  validateAttachments',cmp.get("v.isAttachmentValid"));
        if(cmp.get("v.isAllFieldsValid")){
            console.log('inside if');
            /*var subCateogory=cmp.find('subCateogory').get("v.value");
            if(cmp.get("v.bDisabledDependentFld")==false) {
                var val=cmp.find("subCateogory").get("v.value");
                console.log('Inside if at 85');
                if(val=="--- None ---"){
                    cmp.set("v.isAllFieldsValid",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please enter Product Subcategories',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
            }
            }*/
            var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
            if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below"){
                console.log('inside second if');
                if(cmp.get("v.isAttachmentValid") === "blank"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please upload atleast one attachment!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
                }
            }
            
            if(fillOrUploadForm!=undefined && fillOrUploadForm=="I want to enter my invention details in this form"){
                console.log('inside 3rd if');
                helper.submitData(cmp);
            }
            else if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below" && cmp.get("v.isAttachmentValid") === "attached"){
                console.log('inside else if');
                helper.submitData(cmp);
            }
                else{
                    console.log('inside else');
                    cmp.set("v.IsSpinner", false);
                }
        }
        else{
            console.log('not valid');
            cmp.set("v.IsSpinner", false);
        }
    },
    handleSave:function(cmp,event,helper){
        cmp.set("v.IsSpinner", true);
        cmp.set("v.isSave", true);
        var subCateogory=cmp.find('subCateogory').get("v.value");
        if(cmp.get("v.bDisabledDependentFld")==false) {
            var val=cmp.find("subCateogory").get("v.value");
            console.log('Inside if at 85');
            if(val=="--- None ---"){
                cmp.set("v.isAllFieldsValid",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please enter Product Subcategories',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();
            }
        }
        if(subCateogory != "--- None ---" || cmp.get("v.bDisabledDependentFld")==true) {
            helper.validateFields(cmp, event, helper);
        }
        console.log('after validation');
        if(cmp.get("v.isAllFieldsValid")){
            console.log('inside if before saveData function call');
            helper.saveData(cmp);
            
            /*var subCateogory=cmp.find('subCateogory').get("v.value");
            if(cmp.get("v.bDisabledDependentFld")==false) {
                var val=cmp.find("subCateogory").get("v.value");
                console.log('Inside if at 85');
                if(val=="--- None ---"){
                    cmp.set("v.isAllFieldsValid",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please enter Product Subcategories',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
            }
            }*/
            //var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
            /*if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below"){
                
                if(cmp.get("v.isAttachmentValid") === "blank"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please upload atleast one attachment!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
                }
            }
            
            if(fillOrUploadForm!=undefined && fillOrUploadForm=="I want to enter my invention details in this form"){
                helper.saveData(cmp);
            }*/
            //else if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below" && cmp.get("v.isAttachmentValid") === "attached"){
        }
        else{
            cmp.set("v.IsSpinner", false);
        }
        /*}
        else{
            cmp.set("v.IsSpinner", false);
        }*/
    },
    handleNewUpload : function(component,event,helper){
        var vfOrigin = $A.get("$Label.c.IP_IDFFileUploadURL");
        var vfWindow = document.getElementById("vfFrame").contentWindow;
        vfWindow.postMessage(component.get("v.submitRecord"), vfOrigin);
    },
    handleSaveWithFile : function(component,event,helper){
        var vfOrigin = $A.get("$Label.c.IP_IDFFileUploadURL");
        var vfWindow = document.getElementById("vfFrame").contentWindow;
        vfWindow.postMessage(component.get("v.saveRecord"), vfOrigin);
    },
    handleSaveWithoutFile : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'IDF Saved Successfully!',
            duration:' 5000',
            type: 'success'
        });
        toastEvent.fire();
        component.set("v.IsSpinner", false);
        $A.get('e.force:refreshView').fire();
    },
    productTypeChange:function(component,event,helper){
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.mapOfControlanddependent");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields!=undefined && ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    handleUserRecordChange:function(component,event,helper){
        console.log('records '+component.get("v.selectedLookUpRecords"));
        var userRecors=component.get("v.selectedLookUpRecords");
        if(userRecors!=''&& userRecors!=undefined && userRecors.length>0){
            component.set("v.inventorsTable",true);
            
        }else{
            component.set("v.inventorsTable",false);
        }
    },
    inventionShareChange:function(component,event,helper){
        var share=component.get("v.shareArray");
        var finalArray=[];
        var nameval = event.getSource().get('v.name');
        var namevallist = nameval.split(';');
        var shareArray={
            Email:namevallist[1],
            share:event.getSource().get('v.value'),
            name: namevallist[0],
            id: namevallist[2]
        }
        
        if(share==undefined ||share.length==0||share==''){
            share=shareArray;
        }else{
            for(var i=0;i<share.length;i++){
                if(shareArray.Email==share[i].Email){
                    share.push({id: share[i].id, name:share[i].name, Email:share[i].Email,share:shareArray.share});
                    var index=share.indexOf(share[i]);
                    share.splice(index, 1);
                    break;
                }else{
                    if(i==(share.length)-1){
                        share.push(shareArray);
                    }
                }
            }
        }
        component.set("v.shareArray",share);
    },
    // Handles event from Selected Lookup Record. 
    handleComponentEvent : function(component, event, helper) {
        component.set("v.selectedInventors" , event.getParam("inventorsList"));
    }
})