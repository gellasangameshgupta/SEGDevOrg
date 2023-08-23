import { LightningElement, track, api, wire } from "lwc";
import getFieldNames from "@salesforce/apex/B2B_DynamicSobjectFormController.getFieldsetFields";
import getRecord from "@salesforce/apex/B2B_DynamicSobjectFormController.getRecord";
import saveRecord from "@salesforce/apex/B2B_DynamicSobjectFormController.saveRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class B2b_dynamicSobjectForm extends LightningElement {
    @api recordId;
    @api strObjectApiName;
    @api strFieldsetName;
    blnIsLoaded = false;
    blnIsSpinner = true;
    fieldNames;
    @track fields;
    recordValues = {};

    @wire(getFieldNames, { objectName: "$strObjectApiName", fieldsetName: "$strFieldsetName" })
    wiredFieldNames({ error, data }) {
        if (data) {
            this.fieldNames = data;
            let fieldApis = [];
            this.fieldNames.forEach((current) => {
                fieldApis.push(current.strApiName);
            });
            if (this.recordId && fieldApis.length) {
                this.loadRecordValues(fieldApis);
            }
        } else if (error) {
            console.error(error);
        }
    }

    loadRecordValues(fieldApis) {
        getRecord({ recordId: this.recordId, fieldNames: fieldApis })
            .then((result) => {
                this.blnIsLoaded = true;
                this.recordValues = result;
                this.handleDefaultClick();
            })
            .catch((error) => {
                console.error(error);
            })
            .finally(() => {
                this.blnIsSpinner = false;
            });
    }

    handleInputChange(event) {
        this.fields.forEach((field) => {
            if (field.strApiName === event.detail.strApiName) {
                field.value = event.detail.value;
            }
        });
    }

    handleSaveClick() {
        this.blnIsSpinner = true;
        let record = {};
        record.Id = this.recordId;
        this.fields.forEach((field) => {
            record[field.strApiName] = field.value;
        });
        saveRecord({ record: record })
            .then(() => {
                this.showToastMessage("Success", "Record saved successfully", "success");
            })
            .catch((error) => {
                console.error(error);
            })
            .finally(() => {
                this.blnIsSpinner = false;
            });;
    }

    handleDefaultClick() {
        let fields = [];
        this.fieldNames.forEach((current) => {
            let field = {};
            field.strApiName = current.strApiName;
            field.strLabel = current.strLabel;
            field.strDataType = current.strDataType;
            field.value = this.recordValues[field.strApiName];
            if (current.list_PicklistValues && current.list_PicklistValues.length) {
                let options = [];
                current.list_PicklistValues.forEach((picklist) => {
                    options.push({
                        label: picklist,
                        value: picklist
                    })
                })
                field.list_PicklistValues = options;
            }
            fields.push(field);
        });
        this.fields = fields;
    }

    showToastMessage(strTitle, strMessage, strVariant) {
        const event = new ShowToastEvent({
            title: strTitle,
            variant: strVariant,
            message: strMessage
        });
        this.dispatchEvent(event);
    }
}