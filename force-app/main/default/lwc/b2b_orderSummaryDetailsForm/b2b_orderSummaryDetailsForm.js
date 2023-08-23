import { LightningElement, track, api, wire } from "lwc";
import getFieldNames from "@salesforce/apex/B2B_OrderSummaryFormController.getFieldNames";
import getRecord from "@salesforce/apex/B2B_OrderSummaryFormController.getRecord";
import saveRecord from "@salesforce/apex/B2B_OrderSummaryFormController.saveRecord";

export default class B2b_orderSummaryDetailsForm extends LightningElement {
    @api recordId;
    @api strObjectApiName;
    @api strFieldsetName;
    blnIsLoaded = false;
    fieldNames;
    @track fields;
    recordValues = {};

    @wire(getFieldNames, { objectName: "$strObjectApiName", fieldSetName: "$strFieldsetName" })
    wiredFieldNames({ error, data }) {
        if (data) {
            this.fieldNames = data;
            if (this.recordId) {
                this.loadRecordValues();
            }
        } else if (error) {
            console.error(error);
        }
    }

    loadRecordValues() {
        getRecord({ recordId: this.recordId, fieldNames: this.fieldNames })
            .then((result) => {
                this.blnIsLoaded = true;
                this.recordValues = result;
                this.handleDefaultClick();
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleInputChange(event) {
        this.fields.forEach((field) => {
            if (field.fieldName == event.target.fieldName) {
                field.value = event.target.value;
            }
        });
    }

    handleSaveClick() {
        let record = {};
        record.Id = this.recordId;
        this.fields.forEach((field) => {
            record[field.fieldName] = field.value;
        });
        saveRecord({ record: record })
            .then(() => {
                console.log("Record saved successfully!");
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleDefaultClick() {
        let fields = [];
        this.fieldNames.forEach((fieldName) => {
            let field = {};
            field.fieldName = fieldName;
            field.value = this.recordValues[fieldName];
            fields.push(field);
        });
        this.fields = fields;
    }
}