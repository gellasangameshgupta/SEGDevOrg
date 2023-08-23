({
    doInit : function(component, event, helper) {
        component.set("v.IsSpinner", true);
     //    alert('selected Sub ' + component.find("subCateogory").get("v.value"));
        var dependentFields = [];
        if(component.get("v.myInventionRec").IP_Product_Subcategories__c != undefined||component.get("v.myInventionRec").IP_Product_Subcategories__c != ''||component.get("v.myInventionRec").IP_Product_Subcategories__c != null){
            dependentFields.push(component.get("v.myInventionRec").IP_Product_Subcategories__c);
        }else {
            dependentFields.push('--- None ---');
        }
        component.set("v.listDependingValues", dependentFields)
        var action=component.get("c.getProductTypeOptions");
        action.setCallback(this,function(resp){
            var opts=[];
            component.set("v.mapOfControlanddependent",resp.getReturnValue().contorlingAnddependentvalues)
            for(var i=0;i< resp.getReturnValue().productTypeOptions.length;i++){
                opts.push({"class": "optionClass", label: resp.getReturnValue().productTypeOptions[i], value: resp.getReturnValue().productTypeOptions[i]});
            }
            component.set("v.ProductTypeOptions",opts);
            var pOptions=component.get("v.ProductTypeOptions");
            for(var i=0;i<pOptions.length;i++){
                if(pOptions[i].value==component.get("v.myInventionRec").IP_Product_Type__c){
                    var index=pOptions.indexOf(pOptions[i]);
                    pOptions.splice(index,1);
                    pOptions[0]=({"class": "optionClass", label: component.get("v.myInventionRec").IP_Product_Type__c, value: component.get("v.myInventionRec").IP_Product_Type__c});
                    
                }
                component.set("v.ProductTypeOptions",pOptions); 
            }
            var myArry=resp.getReturnValue();
            component.set("v.data",myArry);
            var inventionCreatedasPartofWork=[];
            if(component.get("v.myInventionRec").IP_Invention_Created_as_Part_of_Work__c=='Yes'){
                inventionCreatedasPartofWork.push(component.get("v.myInventionRec").IP_Invention_Created_as_Part_of_Work__c);
                inventionCreatedasPartofWork.push('No');
            }else{
                inventionCreatedasPartofWork.push(component.get("v.myInventionRec").IP_Invention_Created_as_Part_of_Work__c);
                inventionCreatedasPartofWork.push('Yes');
            } 
            component.set("v.inventionCreatedasPartofWork",inventionCreatedasPartofWork);
            var isthereContributionoftheCompany=[];
            //console.log('Value before if is: ', component.get("v.myInventionRec").IP_Is_there_Contribution_of_the_Company__c);
            if(component.get("v.myInventionRec").IP_Is_there_Contribution_of_the_Company__c=='Yes'){
                //console.log('Value after if is: ', component.get("v.myInventionRec").IP_Is_there_Contribution_of_the_Company__c);
                isthereContributionoftheCompany.push(component.get("v.myInventionRec").IP_Is_there_Contribution_of_the_Company__c);
                isthereContributionoftheCompany.push('No');
            }else{
                isthereContributionoftheCompany.push(component.get("v.myInventionRec").IP_Is_there_Contribution_of_the_Company__c);
                isthereContributionoftheCompany.push('Yes');
            } 
            component.set("v.isthereContributionoftheCompany",isthereContributionoftheCompany);
            var inventionPartofEntrustedResearchOptions=[];
            if(component.get("v.myInventionRec").IP_Invention_Part_of_Entrusted_Research__c=='Yes'){
                inventionPartofEntrustedResearchOptions.push(component.get("v.myInventionRec").IP_Invention_Part_of_Entrusted_Research__c);
                inventionPartofEntrustedResearchOptions.push('No');
            }else{
                inventionPartofEntrustedResearchOptions.push(component.get("v.myInventionRec").IP_Invention_Part_of_Entrusted_Research__c);
                inventionPartofEntrustedResearchOptions.push('Yes');
            } 
            component.set("v.inventionPartofEntrustedResearchOptions",inventionPartofEntrustedResearchOptions);
            var specialPointstobeConsidered=[];
            if(component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c=='Yes'){
                //Added Line No:61
                component.set("v.selected", component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
                specialPointstobeConsidered.push(component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
                specialPointstobeConsidered.push('No');
            }else{
                //Added Line No:66
                component.set("v.selected", component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
                specialPointstobeConsidered.push(component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
                specialPointstobeConsidered.push('Yes');
            } 
            component.set("v.specialPointstobeConsidered",specialPointstobeConsidered);
            var fillOrUploadFormopts=[];
            if(component.get("v.myInventionRec").IP_Fill_Form_or_Upload_IDF__c=='I want to enter my invention details in this form'){
                fillOrUploadFormopts[1]=('I have summarized my invention in a document and would like to upload it below');
                fillOrUploadFormopts[0]=(component.get("v.myInventionRec").IP_Fill_Form_or_Upload_IDF__c);
            }else{
                fillOrUploadFormopts[0]=(component.get("v.myInventionRec").IP_Fill_Form_or_Upload_IDF__c);
                fillOrUploadFormopts[1]=('I want to enter my invention details in this form');
            } 
            component.set("v.fillOrUploadFormopts",fillOrUploadFormopts);
            
            var dOpts=[];
            if(component.get("v.myInventionRec").IP_Product_Subcategories__c!=''||component.get("v.myInventionRec").IP_Product_Subcategories__c!=undefined){
                dOpts.push(component.get("v.myInventionRec").IP_Product_Subcategories__c);
            }else{
                dOpts[i].push('--- NONE ---');
            }
            var fromrow=component.get("v.fillOrUploadFormrow");
            component.set("v.fillOrUploadForm",fromrow);
            
            if(component.get("v.myInventionRec").IP_Inventors__c!=undefined){
                //  alert('Value '+ component.get("v.myInventionRec").IP_Inventors__c);
                component.set("v.inventorsTable",true);      
            }
            component.set("v.IsSpinner", false);
        });
        $A.enqueueAction(action);
        
        var countaction=component.get("c.getAttachmentCount");
        countaction.setParams({"recid":component.get("v.myInventionRec").Id});
        countaction.setCallback(this,function(resp){
            if(resp.getState()=='SUCCESS' && resp.getReturnValue()){
                var count= resp.getReturnValue();
                console.log('Count ', count);
                component.set("v.attachmentCount",count);
            }
        });
        $A.enqueueAction(countaction);
    },
    fetchmessages : function(component) {
        var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
        window.addEventListener("message", $A.getCallback(function(event){
            if (event.origin !== vfOrigin) {         
                return;
            }
            if(event.data === "Success"){
                component.set("v.IsSpinner", false);
                $A.get('e.force:refreshView').fire();
                //alert('Attachment Uploaded.');
            }
            if (event.data === "attached") {
                var isAttachmentValid = component.get("v.isAttachmentValid");
               // console.log('Inside event attached ', isAttachmentValid);
                isAttachmentValid = event.data;
               // console.log('Update ', isAttachmentValid);
                component.set("v.isAttachmentValid",isAttachmentValid);
            }
            //component.set("v.IsSpinner", false);
            //$A.get('e.force:refreshView').fire(); 
            //component.set("v.myInvention",false);
        }), false);
    },
    goback: function(component, event, helper){
       component.set("v.myInvention",false);
    },
    getinventors :function(component, event, helper) {
        var oplist=[];
        var action=component.get("c.fetchInventors");
        action.setParams({"recid":component.get("v.myInventionRec").Id});
        action.setCallback(this,function(resp){
            if(resp.getState()=='SUCCESS' && resp.getReturnValue()){
                var op= resp.getReturnValue();
                console.log('Valeus ip ', JSON.stringify(op));
                for(var i=0;i<op.length;i++){
                    oplist.push({Name:op[i].Name, Email:op[i].Email, share:op[i].share});
                    component.set("v.ShareOnLoad",op[i].share);
                }
                component.set("v.selectedLookUpRecords",op);
            }
        });
        $A.enqueueAction(action);
        
    },
    productTypeChange:function(component, event, helper) {
        component.find("subCateogory").set("v.value", "");
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.mapOfControlanddependent");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields!=undefined && ListOfDependentFields.length > 0){
                console.log('ListOfDependentFields', ListOfDependentFields);
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
    fillOrUploadForm:function(component, event, helper){
        var val=component.find("fillOrUploadForm").get("v.value");
        if(val=="I want to enter my invention details in this form"){
            component.set("v.fillOrUploadForm",true);
        }else{
            component.set("v.fillOrUploadForm",false);
        }
    },
    handleSubmit:function(cmp, event, helper){
        cmp.set("v.IsSpinner", true);
        console.log('inside handleSubmit');
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
        if(cmp.get("v.isAllFieldsValid")){
            var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
            if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below"){
                var vfOrigin = $A.get("$Label.c.IP_IDFVFURL");
                
                if((cmp.get("v.isAttachmentValid") === "blank" || cmp.get("v.isAttachmentValid") === undefined) && cmp.get("v.attachmentCount") === 0){
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
                helper.submitData(cmp);
            }
            else if(fillOrUploadForm!=undefined && fillOrUploadForm=="I have summarized my invention in a document and would like to upload it below" && (cmp.get("v.isAttachmentValid") === "attached" || cmp.get("v.attachmentCount") > 0)){
                helper.submitData(cmp);
            }
            else{
                cmp.set("v.IsSpinner", false);
            }
        }
        else{
            cmp.set("v.IsSpinner", false);
        }
    },
    handleSave:function(cmp,event,helper){
        cmp.set("v.IsSpinner", true);
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
        var title = cmp.find('title').get("v.value");
        var productType=cmp.find('productType').get("v.value");
        var inventionCreatedasPartofWork=cmp.find('inventionCreatedasPartofWork').get("v.value");
        var whoInitiatedtheSubject=cmp.find('whoInitiatedtheSubject').get("v.value");
        var reasonforWorkingonThatSubject=cmp.find('reasonforWorkingonThatSubject').get("v.value");
        var isthereContributionoftheCompany=cmp.find('isthereContributionoftheCompany').get("v.value");
        var inventionPartofEntrustedResearch=cmp.find('inventionPartofEntrustedResearch').get('v.value');
        var specialPointstobeConsidered=cmp.find('specialPointstobeConsidered').get("v.value");
        if(cmp.get("v.selected") == 'Yes'){
            var explanationofSpecialPoints=cmp.find('explanationofSpecialPoints').get("v.value");
        } else {
            var explanationofSpecialPoints= '';
        }
        //var explanationofSpecialPoints=cmp.find('explanationofSpecialPoints').get("v.value");
        var Inventors='';
        var invid='';
        var IamemployedatSEGAutomotiveGermanyLabel=cmp.find("IamemployedatSEGAutomotiveGermanyLabel").get("v.checked");
        var listofUserRecords='';
        if(cmp.get("v.shareArray") && cmp.get("v.shareArray").length > 0)
        {
            listofUserRecords = cmp.get("v.shareArray");
        }else
        {
            listofUserRecords = cmp.get("v.selectedLookUpRecords");
        }
        if(listofUserRecords && listofUserRecords.length>0){
            for(var i=0;i<listofUserRecords.length;i++){
                if(Inventors==undefined || Inventors==''){
                    Inventors=listofUserRecords[i].Name+'('+listofUserRecords[i].share+'%)';
                }else{
                    Inventors=Inventors+','+listofUserRecords[i].Name+'('+listofUserRecords[i].share+'%)';
                }
                if(invid==undefined || invid==''){
                    invid = listofUserRecords[i].Id+':'+listofUserRecords[i].share;
                }else{
                    invid = invid+';'+listofUserRecords[i].Id+':'+listofUserRecords[i].share;
                }
            }
        }
        var useridlist=cmp.get("v.selectedLookUpRecords");
        var invidlist = [];
        if(useridlist && useridlist.length>0){
            for(var i=0;i<useridlist.length;i++){
                invidlist.push(useridlist[i].Id);
            }
        }
        var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
        var priorart='';
        var problemSolved='';
        var inventionDescription='';
        var proveofInventiononCompetitorProduct='';
        var useofInventionbyUs='';
        var subCateogory=cmp.find("subCateogory").get("v.value");
        if(fillOrUploadForm=="I want to enter my invention details in this form"){
            priorart=cmp.find('title').get("v.value");
            problemSolved=cmp.find('problemSolved').get("v.value");
            inventionDescription=cmp.find('inventionDescription').get("v.value");
            proveofInventiononCompetitorProduct=cmp.find('proveofInventiononCompetitorProduct').get("v.value");
            useofInventionbyUs=cmp.find('useofInventionbyUs').get("v.value");
        }
        if(cmp.get("v.isAllFieldsValid")){
            var caseObj={
                sObjectType	:'Case',
                Id:cmp.get("v.myInventionRec").Id,
                Subject:title,
                IP_Product_Type__c:productType,
                IP_Invention_Created_as_Part_of_Work__c:inventionCreatedasPartofWork,
                IP_Who_Initiated_the_Subject__c:whoInitiatedtheSubject,
                IP_Reason_for_Working_on_That_Subject__c:reasonforWorkingonThatSubject,
                IP_Is_there_Contribution_of_the_Company__c	:isthereContributionoftheCompany,
                IP_Special_Points_to_be_Considered__c:specialPointstobeConsidered,
                IP_Explanation_of_Special_Points__c:explanationofSpecialPoints,
                IP_Inventors__c:Inventors,
                IP_Fill_Form_or_Upload_IDF__c:fillOrUploadForm,
                IP_Prior_Art__c:priorart,
                IP_Problem_Solved__c:problemSolved,
                IP_Invention_Description__c:inventionDescription,
                IP_Proveof_Invention_onCompetitorProduct__c:proveofInventiononCompetitorProduct,
                IP_Use_of_Invention_by_Us__c:useofInventionbyUs,
                IP_Status__c:	cmp.get("v.myInventionRec").Status,
                IP_Product_Subcategories__c:subCateogory,
                IP_Invention_Part_of_Entrusted_Research__c:inventionPartofEntrustedResearch,
                IP_am_employed_at_SEG_Automotive_Germany__c:IamemployedatSEGAutomotiveGermanyLabel,
                IP_Inventors_Technical__c:invid
            }
            var action =cmp.get("c.updateInventionDisclosure");
            action.setParams({"invDisclosure":caseObj, "inventors":JSON.stringify(invidlist)});
            action.setCallback(this,function(resp){
                var state = resp.getState();
                var outputresponse = resp.getReturnValue();
                if(state === "SUCCESS" && outputresponse){
                    var messageval = outputresponse;
                    if(cmp.get("v.isAttachmentValid") != undefined && cmp.get("v.isAttachmentValid") != "blank"){
                        cmp.set("v.saveRecord",messageval);
                        cmp.set("v.saveWithFile",true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'IDF Saved Successfully!',
                            duration:' 5000',
                            type: 'success'
                        });
                        toastEvent.fire();
                    }
                    else{
                        cmp.set("v.saveWithoutFile",true);
                    }
                    //cmp.set("v.saveRecord",messageval);
                    //cmp.set("v.IsSpinner", false);
            		//$A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            cmp.set("v.IsSpinner", false);
        }
    },    
    handleNewUpload : function(component,event,helper){
        var vfOrigin = $A.get('$Label.c.IP_IDFFileUploadURL');
        var vfWindow = document.getElementById("vfFrame").contentWindow;
        vfWindow.postMessage(component.get("v.submitRecord"), vfOrigin);
    },
    handleOnlySave : function(component,event,helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'IDF Saved Successfully!',
            duration:' 5000',
            type: 'success'
        });
        toastEvent.fire();
       // component.set("v.IsSpinner", false);
       // $A.get('e.force:refreshView').fire();
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
    /***
   * To Display Explanation of Special Points
   * */  
    onChangeValue: function(component,event,helper){
        if(component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c=='Yes'){
            component.set("v.selected", component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
        }else{
            component.set("v.selected", component.get("v.myInventionRec").IP_Special_Points_to_be_Considered__c);
        } 
    },
    
    inventionShareChange:function(component,event,helper){
       helper.inventionShareChangeHlpr(component,event,helper);
    },
    // Handles event from Selected Lookup Record.   
    handleComponentEvent : function(component, event, helper) {
        component.set("v.selectedInventors" , event.getParam("inventorsList"));
    }
})