import { LightningElement, api } from "lwc";

import { loadScript, loadStyle } from "lightning/platformResourceLoader"; //Load the script to the component
/**Static resource */
import aqt_uploadExcel from "@salesforce/resourceUrl/SRAQT00001"; //Read the excel uploaded data
import ModalWidth from "@salesforce/resourceUrl/SRAQT00002";

/**Apex class */
import searchProducts from "@salesforce/apex/AQT_QuotationTool.searchProducts";
import getCustomSettings from "@salesforce/apex/AQT_QuotationTool.getCustomSettings";
import fetchQuoteDetails from "@salesforce/apex/AQT_QuotationToolSelector.getQuoteRecord";

/**Utils component to show toast message  and check duplicate line item*/
import { showToast, duplicateRecordExist, label } from "c/aqt_utils";
/*Custom labels*/
import CLAQT00001 from "@salesforce/label/c.CLAQT00001"; //Help text for Enter PartNumber textarea
import CLAQT00004 from "@salesforce/label/c.CLAQT00004"; //Error message

//Wire adapters to create content version
import { createRecord } from "lightning/uiRecordApi";

let XLS = {};
export default class aqt_createAccount extends LightningElement {
    // Expose the labels to use in the template.
    label = {
        CLAQT00001,
        CLAQT00004
    };

    @api selectedDetails;
    customLabel = label;
    blnSpinner = true; //Spinner
    blnAccountRequired = true; //Boolean to specifiy if account is required.
    blnContactRequired = false; //Boolean to specifiy if contact is required.
    blnDisableAnalyzeButton = false; //Boolean to disable the anaylze button.
    blnShowQuantityPartNumberTable = false; //Boolean to show the part number table.
    blnShowExistingQuoteRecord = false;
    blnShowModal = false;
    strAcceptedFormats = ".xlsx";
    strSelectedAccountId; //Store the selected account id
    strSelectedContactId; //Store the selected contact id
    strSelectedAccountName; //Store the selected account name
    strSelectedContactName; //Store the selected contact name
    strAccountRecordType; //Store the account record type name from custom setting
    strContactFilter; //Store the contact filter as selected account id
    strSampleOrderTemplateDownload; //Store the download link for the sample order file
    strUploadFileName; //Store the upload file name
    strContentVersionId; //Store the record id for the content version record
    strModalHeader;
    strPartnumber; //Store the manually entered partnumbers
    list_requestPartNumber = []; //Store the partNumbers which are entered manually
    objExcelToJSON; //Store the partNumber,TargetPrice,Quantity uploaded via excel or entered manually
    objUploadExcelFile; //Store the excel file which is uploaded by user

    /*This function get the account record type from the custom setting and
   use the record type as filter for the lookup field.*/
    connectedCallback() {
        if (this.selectedDetails != undefined) {
            this.strSelectedAccountId = this.selectedDetails.strSelectedAccountId;
            this.strSelectedContactId = this.selectedDetails.strSelectedContactId;
            this.strSelectedAccountName = this.selectedDetails.strSelectedAccountName;
            this.strSelectedContactName = this.selectedDetails.strSelectedContactName;
            this.strPartnumber = this.selectedDetails.list_partNumber;
        }

        getCustomSettings()
            .then((result) => {
                this.blnSpinner = false;
                this.strAccountRecordType =
                    "RecordType.Name=" + "'" + result.AccountRecordType__c + "'";
                this.strAccountRecordTypeId = result.AccountRecordTypeId__c;
                this.strSampleOrderTemplateDownload =
                    "/sfc/servlet.shepherd/document/download/" + result.UploadFileTemplate__c;
            })
            .catch((error) => {
                showToast(this, "Error", this.customLabel.CLAQT00003, "error");
            });
    }

    //Load static resource in the component to read excel file data.
    renderedCallback() {
        Promise.all([loadStyle(this, ModalWidth), loadScript(this, aqt_uploadExcel)])
            .then(() => {
                XLS = XLSX;
            })
            .catch((error) => {
                showToast(this, "Error", this.customLabel.CLAQT00003, "error");
            });
    }

    //Stores the selected Account Id and create lookup filter for the contact.
    handleAccountSelection(event) {
        this.strSelectedAccountId = event.detail.selectedRecordId;
        this.strSelectedAccountName = event.detail.selectedRecordName;
        this.strContactFilter = "AccountId=" + "'" + this.strSelectedAccountId + "'";
    }

    //This function get the selected contact id
    handleContactSelection(event) {
        this.strSelectedContactId = event.detail.selectedRecordId;
        this.strSelectedContactName = event.detail.selectedRecordName;
    }

    //Remove the selected value from the lookup field
    handleLookupRemove(event) {
        let strLookupFilter;
        if (event.detail === "Account") {
            this.strSelectedAccountId = "";
            this.strSelectedAccountName = "";
            this.strContactFilter = strLookupFilter;
        }
        if (event.detail === "Contact") {
            this.strSelectedContactId = "";
            this.strSelectedContactName = "";
        }
    }

    //Fetch the exisiting quote records and show in data table
    async handleFetchQuoteRecord(event) {
        this.blnSpinner = true;
        this.strModalHeader = "Quote Records";
        this.blnShowExistingQuoteRecord = true;
        await this.fetchQuoteDetails();
        this.blnSpinner = false;
        this.blnShowQuantityPartNumberTable = false;
        this.blnShowModal = true;
    }

    //Fetch quote records.
    async fetchQuoteDetails() {
        await fetchQuoteDetails()
            .then((result) => {
                let tempQuoteRecords = JSON.parse(JSON.stringify(result));
                tempQuoteRecords.forEach((record) => {
                    record.AccountName = record.Account__r.Name;
                    if (record.Contact__c != undefined) {
                        record.ContactName = record.Contact__r.Name;
                    }
                });
                this.data = tempQuoteRecords;
            })
            .catch((error) => {
                showToast(this, "Error", this.customLabel.CLAQT00003, "error");
            });
    }

    handleQuoteRecordAnalyze() {
        this.blnSpinner = true;
        let strQuoteId;
        let radioCheckbox = this.template.querySelectorAll("[name='radionButton']");
        for (var i = 0; i < radioCheckbox.length; i++) {
            if (radioCheckbox[i].checked === true) {
                strQuoteId = radioCheckbox[i].value;
            }
        }

        if (strQuoteId === undefined || strQuoteId === "") {
            this.blnSpinner = false;
            showToast(this, "Error", "Kindly choose a record.", "error");
        }
        if (strQuoteId) {
            this.data.map((currElement, index) => {
                if (currElement.Id === strQuoteId) {
                    this.strSelectedAccountId = currElement.Account__c;
                    this.strSelectedContactId = currElement.Contact__c;
                    this.strSelectedAccountName = currElement.AccountName;
                    this.strSelectedContactName = currElement.ContactName;
                }
            });
            this.dispatchEvent(
                new CustomEvent("editquotelineitem", {
                    detail: {
                        strQuoteId: strQuoteId,
                        selectedAccountId: this.strSelectedAccountId,
                        selectedAccountName: this.strSelectedAccountName,
                        selectedContactId: this.strSelectedContactId,
                        selectedContactName: this.strSelectedContactName
                    }
                })
            );
        }
    }

    //Displays the uploaded file name and store the file data in object.
    handleUploadFinished(event) {
        const strUploadedFile = event.detail.files;
        if (strUploadedFile.length && strUploadedFile != "") {
            this.strUploadFileName = strUploadedFile[0].name;
            this.objUploadExcelFile = strUploadedFile[0];
            this.handleProcessExcelFile(strUploadedFile[0]);
        }
    }

    //This function reads the excel file and verify from apex that the data is readable
    handleProcessExcelFile(file) {
        this.blnSpinner = true;
        let isValid = true;
        let objFileReader = new FileReader();
        objFileReader.onload = (event) => {
            let objFiledata = event.target.result;
            let objFileWorkbook = XLS.read(objFiledata, {
                type: "binary"
            });
            this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                objFileWorkbook.Sheets["Sheet1"]
            );
            if (this.objExcelToJSON.length === 0) {
                this.blnSpinner = false;
                this.strUploadFileName = "";
                showToast(this, "Error", "Kindly upload the file with data.", "error");
            }
            if (this.objExcelToJSON.length > 0) {
                //Remove the whitespaces from the javascript object
                Object.keys(this.objExcelToJSON).forEach((key) => {
                    const replacedKey = key.trim().toUpperCase().replace(/\s\s+/g, "_");
                    if (key !== replacedKey) {
                        this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
                        delete this.objExcelToJSON[key];
                    }
                    if (this.objExcelToJSON[key].PartNumber === undefined) {
                        isValid = false;
                        this.blnSpinner = false;
                        showToast(
                            this,
                            "Error",
                            "PartNumber Missing,Kindly upload the data with PartNumbers.",
                            "error"
                        );
                    }
                });
                if (isValid === true) {
                    if (duplicateRecordExist(this.objExcelToJSON)) {
                        this.blnSpinner = false;
                        showToast(this, "Error", this.customLabel.CLAQT00002, "error");
                    } else {
                        this.blnSpinner = false;
                        this.handleCreateContentDocument();
                        showToast(this, "Success", "File proccessed successfully", "success");
                    }
                }
            }
        };
        objFileReader.onerror = function (error) {
            console.error(error);
        };
        objFileReader.readAsBinaryString(file);
    }

    //Store the excel file as content version
    handleCreateContentDocument() {
        let objUploadedFile = this.objUploadExcelFile; // Uploaded file object
        if (objUploadedFile) {
            let strTempUploadedFileName = this.strUploadFileName;
            new Promise(function (resolve, reject) {
                let objFileReader = new FileReader();
                // Closure to capture the file information.
                objFileReader.onload = (event) => {
                    let objFiledata = event.target.result;
                    var base64String = window.btoa(objFiledata); //Converting Binary Data to base 64

                    const fields = {};
                    fields.VersionData = base64String;
                    fields.Title = strTempUploadedFileName + ".xlsx";
                    fields.PathOnClient = strTempUploadedFileName;
                    fields.ContentLocation = "s";
                    const recordInput = { apiName: "ContentVersion", fields };
                    createRecord(recordInput)
                        .then((response) => {
                            resolve(response.id);
                        })
                        .catch((error) => {
                            showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                        });
                };
                objFileReader.onerror = function (error) {
                    showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                };
                objFileReader.readAsBinaryString(objUploadedFile);
            })
                .then((result) => {
                    this.strContentVersionId = result;
                })
                .catch((error) => {
                    showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                });
        }
    }

    //This function is to get the proucts found,not found from the apex
    handleAnalyze(event) {
        this.list_requestPartNumber = [];
        this.strPartnumber = this.template.querySelector("lightning-textarea").value;
        let list_PartNumbers = this.template.querySelector("lightning-textarea").value;
        if (list_PartNumbers != undefined && list_PartNumbers != "") {
            let arrPartNumberArray = list_PartNumbers.split(",");
            if (arrPartNumberArray) {
                for (let i = 0; i < arrPartNumberArray.length; i++) {
                    //Remove the whitespaces ,special characters and verify if the string length is greater than 0
                    if (arrPartNumberArray[i].replace(/\s/g, "").length) {
                        const list_requestedPartNumber = {
                            PartNumber: 0,
                            Quantity: 0,
                            TargetPrice: 0
                        };
                        (list_requestedPartNumber.PartNumber = arrPartNumberArray[i].replace(
                            /\n/g,
                            ""
                        )),
                            (list_requestedPartNumber.Quantity = 1);
                        list_requestedPartNumber.TargetPrice = 0;
                        this.list_requestPartNumber.push(list_requestedPartNumber);
                    }
                }
            }
            if (this.list_requestPartNumber.length !== 0) {
                this.blnShowModal = true;
                this.strModalHeader = "Enter Quantity and Part Number";
                this.blnShowQuantityPartNumberTable = true;
                this.blnShowExistingQuoteRecord = false;
            } else {
                this.blnSpinner = true;
                this.handleSearchProduct();
            }
        } else {
            this.blnSpinner = true;
            this.handleSearchProduct();
        }
    }

    //This function gets the entered data i.e quantity and partnumber and store in this.excelToJSON object.
    handleAddProduct(event) {
        if (event.detail) {
            this.blnSpinner = true;
            this.blnShowQuantityPartNumberTable = false;
            this.blnShowModal = false;
            const productDetails = JSON.parse(JSON.stringify(event.detail));
            if (productDetails.length === 0) {
                this.blnSpinner = false;
                showToast(this, "Error", this.label.CLAQT00004, "error");
            }
            if (productDetails.length > 0) {
                if (this.objExcelToJSON) {
                    this.blnSpinner = false;
                    const tempObjExcelToJSON = JSON.parse(JSON.stringify(this.objExcelToJSON));
                    for (const key in productDetails) {
                        tempObjExcelToJSON.push(productDetails[key]);
                    }
                    if (duplicateRecordExist(tempObjExcelToJSON)) {
                        this.blnShowModal = false;
                        showToast(this, "Error", this.customLabel.CLAQT00002, "error");
                    } else {
                        this.objExcelToJSON = JSON.parse(JSON.stringify(tempObjExcelToJSON));
                        this.blnSpinner = false;
                        this.handleSearchProduct();
                    }
                } else {
                    this.blnSpinner = false;
                    if (duplicateRecordExist(event.detail)) {
                        this.blnShowModal = false;
                        showToast(this, "Error", this.customLabel.CLAQT00002, "error");
                    } else {
                        this.objExcelToJSON = event.detail;
                        this.handleSearchProduct();
                    }
                }
            }
        }
    }

    //This function is to pass the entered/uploaded data to apex.
    handleSearchProduct() {
        this.blnSpinner = true;
        if (this.isInputValid()) {
            const tempObjExcelToJSON = JSON.parse(JSON.stringify(this.objExcelToJSON));
           //c/aqt_treeDataTableCell const intRepeatNumber = "0";
            //Remove if the part number has any extra spaces,append 0 if part number is less than 10.
            tempObjExcelToJSON.forEach(function (result) {
                if (result.PartNumber !== undefined) {
                    result.PartNumber = result.PartNumber.toString();
                    result.PartNumber = result.PartNumber.replace(/[^\w ]/g, "", "").replace(
                        /\s/g,
                        ""
                    );
                   /* if (result.PartNumber.length < 10) {
                        const strAddCharacters = 10 - result.PartNumber.length;
                        const strRepeatedString = intRepeatNumber.repeat(strAddCharacters);
                        result.PartNumber = strRepeatedString + result.PartNumber;
                    }*/
                    if (result.Quantity === undefined) {
                        result.Quantity = 1;
                    }
                    if (result.TargetPrice === undefined) {
                        result.TargetPrice = 0;
                    }
                }
            });
            this.objExcelToJSON = JSON.parse(JSON.stringify(tempObjExcelToJSON));
            searchProducts({
                strAccountId: this.strSelectedAccountId,
                strContactId: this.strSelectedContactId,
                strRequestedData: JSON.stringify(this.objExcelToJSON)
            })
                .then((result) => {
                    this.blnSpinner = false;
                    this.dispatchEvent(
                        new CustomEvent("productsearch", {
                            detail: {
                                searchedProductResult: result,
                                selectedAccountId: this.strSelectedAccountId,
                                selectedAccountName: this.strSelectedAccountName,
                                selectedContactId: this.strSelectedContactId,
                                selectedContactName: this.strSelectedContactName,
                                strContentVersionId: this.strContentVersionId,
                                list_partNumber: this.strPartnumber,
                                objUploadExcelFile: this.objUploadExcelFile
                            }
                        })
                    );
                })
                .catch((error) => {
                    this.blnSpinner = false;
                    showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                });
        }
    }

    //Validate the field values if required field exist
    isInputValid() {
        let blnIsValid = true;
        if (this.strSelectedAccountId === undefined || this.strSelectedAccountId === "") {
            showToast(this, "Error", "Kindly choose the account.", "error");
            blnIsValid = false;
            this.blnSpinner = false;
        }
        if (
            (this.objExcelToJSON === undefined || this.objExcelToJSON.length === 0) &&
            blnIsValid == true &&
            this.list_requestPartNumber.length === 0
        ) {
            showToast(this, "Error", this.label.CLAQT00004, "error");
            blnIsValid = false;
            this.blnSpinner = false;
        }
        if (this.objExcelToJSON && blnIsValid === true) {
            if (this.objExcelToJSON.length > 0) {
                Object.keys(this.objExcelToJSON).forEach((key) => {
                    if (this.objExcelToJSON[key].PartNumber === undefined) {
                        this.blnSpinner = false;
                        blnIsValid = false;
                        showToast(
                            this,
                            "Error",
                            "PartNumber Missing,Kindly upload the data with PartNumbers.",
                            "error"
                        );
                    }
                });
            }
        }

        if (blnIsValid == true) {
            if (duplicateRecordExist(this.objExcelToJSON)) {
                blnIsValid = false;
                this.blnSpinner = false;
                this.blnShowModal = false;
                showToast(this, "Error", this.customLabel.CLAQT00002, "error");
            }
        }
        return blnIsValid;
    }

    //On click of cancel refresh the component to allow users to reselect the values
    handleCancel() {
        eval("$A.get('e.force:refreshView').fire();");
    }

    //This function is to close the modal
    handleCloseModal(event) {
        this.blnShowModal = false;
    }

    //This function is to get the result for the selected removed partNumbers and update the same in partNumber textarea
    handleRemoveProduct(event) {
        let arr_selectedPartNumber = [];
        for (let tempListPartNumber in event.detail) {
            arr_selectedPartNumber.push(event.detail[tempListPartNumber].PartNumber);
        }
        this.template.querySelector("lightning-textarea").value = arr_selectedPartNumber;
        if (arr_selectedPartNumber.length === 0) {
            this.blnShowQuantityPartNumberTable = false;
        }

        this.strPartnumber = arr_selectedPartNumber;
    }
}