({
    validateFields : function(cmp,event,helper) {
        console.log('inside validateFields');
        var shareInvention=cmp.get("v.shareArray"); 
        console.log('inside validate check shareArray::'+JSON.stringify(shareInvention));
        console.log('check selected inventors from event::'+JSON.stringify(cmp.get("v.selectedInventors")));
        var newShareArray=[];
        if(shareInvention!='' && shareInvention!=undefined && shareInvention.length>0){
            
            var userRecors=cmp.get("v.selectedLookUpRecords");  
            for(var j=0;j<userRecors.length;j++){
                for(var i=0;i<shareInvention.length;i++){
                    if(shareInvention[i].Email==userRecors[j].Email){
                        newShareArray.push(shareInvention[i]);
                    }
                }
            }
            cmp.set("v.shareArray",newShareArray);
        }
        var title = cmp.find('title').get("v.value");
        if(title != ''){
            var titleError = cmp.find("title");
            $A.util.removeClass(titleError, "slds-has-error"); 
            
        }
        
        var productType=cmp.find('productType').get("v.value");
        if(productType != ''){
            var productError = cmp.find("productType");
            $A.util.removeClass(productError, "slds-has-error"); 
        }        
        var inventionCreatedasPartofWork=cmp.find('inventionCreatedasPartofWork').get("v.value");
        if(inventionCreatedasPartofWork != ''){
            var inventionError = cmp.find("inventionCreatedasPartofWork");
            $A.util.removeClass(inventionError, "slds-has-error"); 
        }
        var whoInitiatedtheSubject=cmp.find('whoInitiatedtheSubject').get("v.value");
        if(whoInitiatedtheSubject != ''){
            var whoError = cmp.find("whoInitiatedtheSubject");
            $A.util.removeClass(whoError, "slds-has-error"); 
        }
        
        var reasonforWorkingonThatSubject=cmp.find('reasonforWorkingonThatSubject').get("v.value");
        if(reasonforWorkingonThatSubject != ''){
            var reasonError = cmp.find("reasonforWorkingonThatSubject");
            $A.util.removeClass(reasonError, "slds-has-error"); 
        }
        
        var isthereContributionoftheCompany=cmp.find('isthereContributionoftheCompany').get("v.value");
        if(isthereContributionoftheCompany != ''){
            var contributionError = cmp.find("isthereContributionoftheCompany");
            $A.util.removeClass(contributionError, "slds-has-error"); 
        }
        
        var specialPointstobeConsidered=cmp.find('specialPointstobeConsidered').get("v.value");
        if(specialPointstobeConsidered != ''){
            var specialError = cmp.find("specialPointstobeConsidered");
            $A.util.removeClass(specialError, "slds-has-error"); 
        }
        
        if(cmp.get("v.selected") == 'Yes'){
            var explanationofSpecialPoints=cmp.find('explanationofSpecialPoints').get("v.value");
            if(explanationofSpecialPoints != ''){
                var explanationError = cmp.find("explanationofSpecialPoints");
                $A.util.removeClass(explanationError, "slds-has-error");
            }
        } else {
            var explanationofSpecialPoints= '';
        }
        
        var InventionPartofEntrustedResearchHelptext=cmp.find('inventionPartofEntrustedResearch').get("v.value");
        if(InventionPartofEntrustedResearchHelptext != ''){
            var entrustedError = cmp.find("inventionPartofEntrustedResearch");
            $A.util.removeClass(entrustedError, "slds-has-error"); 
        }
        
        var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
        if(fillOrUploadForm != ''){
            var fillError = cmp.find("fillOrUploadForm");
            $A.util.removeClass(fillError, "slds-has-error"); 
        }
        
        var InventorRecords=cmp.get("v.selectedLookUpRecords");
        var validateFields=[];
        var validateSelect=[];
        
        if(fillOrUploadForm!=undefined && fillOrUploadForm=="I want to enter my invention details in this form"){
            var priorart=cmp.find('priorart').get("v.value");
            if(priorart != ''){
                var priorError = cmp.find("priorart");
                $A.util.removeClass(priorError, "slds-has-error"); 
            }
            
            var problemSolved=cmp.find('problemSolved').get("v.value");
            if(problemSolved != ''){
                var problemSolvedError = cmp.find("problemSolved");
                $A.util.removeClass(problemSolvedError, "slds-has-error"); 
            }
            
            var inventionDescription=cmp.find('inventionDescription').get("v.value");
            if(inventionDescription != ''){
                var invenError = cmp.find("inventionDescription");
                $A.util.removeClass(invenError, "slds-has-error"); 
            }
            
            var proveofInventiononCompetitorProduct=cmp.find('proveofInventiononCompetitorProduct').get("v.value");
            if(proveofInventiononCompetitorProduct != ''){
                var proveError = cmp.find("proveofInventiononCompetitorProduct");
                $A.util.removeClass(proveError, "slds-has-error"); 
            }
            
            var useofInventionbyUs=cmp.find('useofInventionbyUs').get("v.value");
            if(useofInventionbyUs != ''){
                var useError = cmp.find("useofInventionbyUs");
                $A.util.removeClass(useError, "slds-has-error"); 
            }
            validateFields.push({auraId:cmp.find('priorart'),value:priorart});
            validateFields.push({auraId:cmp.find('problemSolved'),value:problemSolved});
            validateFields.push({auraId:cmp.find('inventionDescription'),value:inventionDescription});
            validateFields.push({auraId:cmp.find('proveofInventiononCompetitorProduct'),value:proveofInventiononCompetitorProduct});
            validateFields.push({auraId:cmp.find('useofInventionbyUs'),value:useofInventionbyUs});
        }
        
        validateFields.push({auraId:cmp.find('title'),value:title});
        validateSelect.push({auraId:cmp.find('productType'),value:productType});
        validateSelect.push({auraId:cmp.find('inventionCreatedasPartofWork'),value:inventionCreatedasPartofWork});
        validateFields.push({auraId:cmp.find('whoInitiatedtheSubject'),value:whoInitiatedtheSubject});
        validateFields.push({auraId:cmp.find('reasonforWorkingonThatSubject'),value:reasonforWorkingonThatSubject});
        validateSelect.push({auraId:cmp.find('isthereContributionoftheCompany'),value:isthereContributionoftheCompany});
        validateSelect.push({auraId:cmp.find('specialPointstobeConsidered'),value:specialPointstobeConsidered});
        if(cmp.get("v.selected") == 'Yes'){
            validateFields.push({auraId:cmp.find('explanationofSpecialPoints'),value:explanationofSpecialPoints}); 
        }
        //validateFields.push({auraId:cmp.find('explanationofSpecialPoints'),value:explanationofSpecialPoints});
        validateSelect.push({auraId:cmp.find('fillOrUploadForm'),value:fillOrUploadForm});
        console.log('validateFields'+validateFields);
        validateSelect.push({auraId:cmp.find('inventionPartofEntrustedResearch'),value:InventionPartofEntrustedResearchHelptext});
        
        var subCateogory=cmp.find('subCateogory').get("v.value");
        if(subCateogory != ''){
            var subCateogoryError = cmp.find("subCateogory");
            $A.util.removeClass(subCateogoryError, "slds-has-error"); 
        }
        
        /*if(cmp.get("v.bDisabledDependentFld")==false){
            validateFields.push({auraId:cmp.find('subCateogory'),value:subCateogory}); 
        }*/
        // if(isUpload == true){
        cmp.set("v.isAllFieldsValid",true);
        // }
        
        for (var i=0;i<validateFields.length;i++){    
            if(validateFields[i].value=='' || validateFields[i].value== undefined || validateFields[i].value==null){
                cmp.set("v.isAllFieldsValid",false);
                var id=validateFields[i].auraId;
                id.setCustomValidity(" ");
                id.reportValidity();
            }
        }
        for (var i=0;i<validateSelect.length;i++){   
            if(validateSelect[i].value=='' || validateSelect[i].value== undefined || validateSelect[i].value==null){
                var id=validateSelect[i].auraId;
                $A.util.addClass(id, "slds-has-error");
                cmp.set("v.isAllFieldsValid",false);
            }
        }
        if(!cmp.get("v.isAllFieldsValid")){
            console.log('At 168: ', cmp.get("v.isAllFieldsValid"));
            cmp.set("v.isAllFieldsValid",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please enter All required fields',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
            });
            toastEvent.fire();
        }else {
            console.log('At 180: ', cmp.get("v.isAllFieldsValid"));
            cmp.set("v.isAllFieldsValid",true);
        }
        
        if(cmp.get("v.isAllFieldsValid")){
            console.log('At 185: ', cmp.get("v.isAllFieldsValid"));
            if(cmp.get("v.bDisabledDependentFld")==false){
                var val=cmp.find("subCateogory").get("v.value");
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
                }else { //cmp.set("v.isAllFieldsValid",true);
                }        
            }
        }
        var checkSelectedInventorsEvent =  cmp.get("v.selectedInventors");
        var checkShareArray =  cmp.get("v.shareArray");
        console.log('checkShareArray ---',checkShareArray);
        if(title != '' && productType != '' && inventionCreatedasPartofWork != '' && whoInitiatedtheSubject != '' &&
           reasonforWorkingonThatSubject != '' && isthereContributionoftheCompany != '' && specialPointstobeConsidered != '' &&
           InventionPartofEntrustedResearchHelptext != '' && fillOrUploadForm != '' && subCateogory != '' && subCateogory != '--None--'){
            console.log('inside 1st if ---');
            if((checkShareArray == '' && checkSelectedInventorsEvent == '')
               ||(checkShareArray == '' && checkSelectedInventorsEvent != '')){
                console.log('inside 2nd if ---');
                cmp.set("v.isAllFieldsValid",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please add at least one Inventor and enter the % share for all selected Inventors.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();
            }
            else if(checkShareArray != '' && checkSelectedInventorsEvent != '' && (checkShareArray.length != checkSelectedInventorsEvent.length)){
                cmp.set("v.isAllFieldsValid",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please enter the % share for all selected Inventors.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                });
                toastEvent.fire();
            }
                else if(checkShareArray != '' && checkSelectedInventorsEvent != '' && (checkShareArray.length == checkSelectedInventorsEvent.length)){
                    console.log('inside else-if ---');
                    var percentage=0;
                    var nopercentage = 'false';
                    for(var i=0;i<checkShareArray.length;i++){
                        console.log('inside for ---');
                        if(checkShareArray[i].share != undefined){
                            percentage=parseInt(percentage)+parseInt(checkShareArray[i].share);
                            console.log('percentage ---',percentage);
                        }else{
                            var nopercentage = 'true';
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Please enter share for all selected Inventors.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }
                    }
                    if(nopercentage == 'false'){
                        if(percentage>100){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be more than 100%',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }else if(percentage<100){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be less than 100%',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }else if(isNaN(percentage) || percentage == ''){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be empty',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }else{
                            console.log('At 292: ', cmp.get("v.isAllFieldsValid"));
                            cmp.set("v.isAllFieldsValid",true);
                        }
                    }
                }
                    else if(checkShareArray != '' && checkShareArray.length == 1 && checkSelectedInventorsEvent == ''){
                        var percentage=0;
                        for(var i=0;i<checkShareArray.length;i++){
                            console.log('inside for ---');
                            if(checkShareArray[i].share != undefined){
                                percentage=parseInt(percentage)+parseInt(checkShareArray[i].share);
                                console.log('percentage ---',percentage);
                            }else{
                                cmp.set("v.isAllFieldsValid",false);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'Please enter share for all selected Inventors.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                });
                                toastEvent.fire();
                            }
                        }
                        if(percentage>100){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be more than 100%',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }else if(percentage<100){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be less than 100%',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }else if(isNaN(percentage) || percentage == ''){
                            cmp.set("v.isAllFieldsValid",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'Share of invention should not be empty',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                            });
                            toastEvent.fire();
                        }/*else{
                            console.log('At 353: ', cmp.get("v.isAllFieldsValid"));
                            cmp.set("v.isAllFieldsValid",true);
                        }*/
                    }
        }
    },
    
    saveData : function(cmp){
        console.log('inside savedata');
        var title = cmp.find('title').get("v.value");
        var productType=cmp.find('productType').get("v.value");
        var inventionCreatedasPartofWork=cmp.find('inventionCreatedasPartofWork').get("v.value");
        var whoInitiatedtheSubject=cmp.find('whoInitiatedtheSubject').get("v.value");
        var reasonforWorkingonThatSubject=cmp.find('reasonforWorkingonThatSubject').get("v.value");
        var isthereContributionoftheCompany=cmp.find('isthereContributionoftheCompany').get("v.value");
        var specialPointstobeConsidered=cmp.find('specialPointstobeConsidered').get("v.value");
        // Changes Line No: 73
        if(cmp.get("v.selected") == 'Yes'){
            var explanationofSpecialPoints=cmp.find('explanationofSpecialPoints').get("v.value");
        } else {
            var explanationofSpecialPoints= '';
        }
        var Inventors='';
        var invid='';
        var IamemployedatSEGAutomotiveGermanyLabel=cmp.find("IamemployedatSEGAutomotiveGermanyLabel").get("v.checked");
        var InventionPartofEntrustedResearch =cmp.find('inventionPartofEntrustedResearch').get("v.value");
        var listofUserRecords=cmp.get("v.shareArray");
        if(listofUserRecords && listofUserRecords.length>0){
            for(var i=0;i<listofUserRecords.length;i++){
                if(Inventors==undefined || Inventors==''){
                    Inventors=listofUserRecords[i].name+'('+listofUserRecords[i].share+'%)';
                }else{
                    Inventors=Inventors+','+listofUserRecords[i].name+'('+listofUserRecords[i].share+'%)';
                }
                if(invid==undefined || invid==''){
                    invid = listofUserRecords[i].id+':'+listofUserRecords[i].share;
                }else{
                    invid = invid+';'+listofUserRecords[i].id+':'+listofUserRecords[i].share;
                }
            }
        }
        var useridlist=cmp.get("v.selectedLookUpRecords");
        var invidlist = [];
        if(useridlist && useridlist.length>0){
            for(var i=0;i<useridlist.length;i++){
                invidlist.push(useridlist[i].Id);//chnaged here (.ID added)
            }
        }
        var fillOrUploadForm=cmp.find('fillOrUploadForm').get("v.value");
        var priorart='';
        var problemSolved='';
        var inventionDescription='';
        var proveofInventiononCompetitorProduct='';
        var useofInventionbyUs='';
        var subCateogory='';
        if(fillOrUploadForm!=undefined && fillOrUploadForm=="I want to enter my invention details in this form"){
            priorart=cmp.find('title').get("v.value");
            problemSolved=cmp.find('problemSolved').get("v.value");
            inventionDescription=cmp.find('inventionDescription').get("v.value");
            proveofInventiononCompetitorProduct=cmp.find('proveofInventiononCompetitorProduct').get("v.value");
            useofInventionbyUs=cmp.find('useofInventionbyUs').get("v.value");
        }
        if(cmp.get("v.bDisabledDependentFld")==false){
            subCateogory=cmp.find("subCateogory").get("v.value");
        }
        if(cmp.get("v.isAllFieldsValid")){
            var caseObj={
                sObjectType	:'Case',
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
                IP_Status__c:	"Draft",
                IP_Product_Subcategories__c:subCateogory,
                IP_am_employed_at_SEG_Automotive_Germany__c:IamemployedatSEGAutomotiveGermanyLabel,
                IP_Invention_Part_of_Entrusted_Research__c:InventionPartofEntrustedResearch,
                IP_Inventors_Technical__c: invid
            }
            var action =cmp.get("c.createInventionDisclosure");
            action.setParams({"invDisclosure":caseObj,"inventors":JSON.stringify(invidlist)});
            action.setCallback(this,function(resp){
                var state = resp.getState();
                var outputresponse = resp.getReturnValue();
                if(state === "SUCCESS" && outputresponse){
                    var message = outputresponse;
                    if(cmp.get("v.isAttachmentValid") === "attached"){
                        cmp.set("v.saveRecord",message);
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
                }
            });
            $A.enqueueAction(action);
        }
        else{
            cmp.set("v.IsSpinner", false);
        }
    },
    submitData : function(cmp){
        console.log('inside submit data');
        var title = cmp.find('title').get("v.value");
        var productType=cmp.find('productType').get("v.value");
        var inventionCreatedasPartofWork=cmp.find('inventionCreatedasPartofWork').get("v.value");
        var whoInitiatedtheSubject=cmp.find('whoInitiatedtheSubject').get("v.value");
        var reasonforWorkingonThatSubject=cmp.find('reasonforWorkingonThatSubject').get("v.value");
        var isthereContributionoftheCompany=cmp.find('isthereContributionoftheCompany').get("v.value");
        var specialPointstobeConsidered=cmp.find('specialPointstobeConsidered').get("v.value");
        // Changes Line No: 73
        if(cmp.get("v.selected") == 'Yes'){
            var explanationofSpecialPoints=cmp.find('explanationofSpecialPoints').get("v.value");
        } else {
            var explanationofSpecialPoints= '';
        }
        var Inventors='';
        var invid='';
        var IamemployedatSEGAutomotiveGermanyLabel=cmp.find("IamemployedatSEGAutomotiveGermanyLabel").get("v.checked");
        var InventionPartofEntrustedResearch =cmp.find('inventionPartofEntrustedResearch').get("v.value");
        var listofUserRecords=cmp.get("v.shareArray");
        if(listofUserRecords && listofUserRecords.length>0){
            for(var i=0;i<listofUserRecords.length;i++){
                if(Inventors==undefined || Inventors==''){
                    Inventors=listofUserRecords[i].name+'('+listofUserRecords[i].share+'%)';
                }else{
                    Inventors=Inventors+','+listofUserRecords[i].name+'('+listofUserRecords[i].share+'%)';
                }
                if(invid==undefined || invid==''){
                    invid = listofUserRecords[i].id+':'+listofUserRecords[i].share;
                }else{
                    invid = invid+';'+listofUserRecords[i].id+':'+listofUserRecords[i].share;
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
        var subCateogory='';
        if(fillOrUploadForm!=undefined && fillOrUploadForm=="I want to enter my invention details in this form"){
            priorart=cmp.find('title').get("v.value");
            problemSolved=cmp.find('problemSolved').get("v.value");
            inventionDescription=cmp.find('inventionDescription').get("v.value");
            proveofInventiononCompetitorProduct=cmp.find('proveofInventiononCompetitorProduct').get("v.value");
            useofInventionbyUs=cmp.find('useofInventionbyUs').get("v.value");
        }
        subCateogory=cmp.find("subCateogory").get("v.value");
        if(cmp.get("v.isAllFieldsValid")){
            var caseObj={
                sObjectType	:'Case',
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
                IP_Status__c:	"Submitted for Review",
                IP_Product_Subcategories__c:subCateogory,
                IP_am_employed_at_SEG_Automotive_Germany__c:IamemployedatSEGAutomotiveGermanyLabel,
                IP_Invention_Part_of_Entrusted_Research__c:InventionPartofEntrustedResearch,
                IP_Inventors_Technical__c: invid
            }
            var action =cmp.get("c.createInventionDisclosure");
            action.setParams({"invDisclosure":caseObj,"inventors":JSON.stringify(invidlist),"userList":listofUserRecords});
            action.setCallback(this,function(resp){
                var state = resp.getState();
                var outputresponse = resp.getReturnValue();
                if(state === "SUCCESS" && outputresponse){
                    var message = outputresponse;
                    cmp.set("v.submitRecord",message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'IDF Submitted Successfully!',
                        duration:' 5000',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            cmp.set("v.IsSpinner", false);
        }
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);        
    },
})