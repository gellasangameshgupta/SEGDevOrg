import { LightningElement, api, track } from "lwc";

export default class vps_treeDataTableCell extends LightningElement {
    @api record;
    @api field;
    @api displayFieldName;
    @api columnWrapClass;

    @track recordId;
    @track approvalRequiredColor;
    @track blnIsLoaded = false;
    index;

    connectedCallback() {
        this.blnIsLoaded = true;
    }

    get isTextField() {
        let field = this.field;
        if (field.fieldType === "text") {
            return true;
        } else {
            return false;
        }
    }

    get isCurrencyField() {
        let field = this.field;
        if (field.fieldType === "Currency") {
            return true;
        } else {
            return false;
        }
    }

    get isEditableField() {
        let field = this.field;
        if (field.editable === "true" && field.fieldType === "Number") {
            return true;
        } else {
            return false;
        }
    }

    get isNumberField() {
        let field = this.field;
        if (field.fieldType === "Number" && field.editable === "false") {
            return true;
        } else {
            return false;
        }
    }

    get isPercentageField() {
        let field = this.field;
        if (field.fieldType === "Percentage") {
            return true;
        } else {
            return false;
        }
    }

    get isReferenceField() {
        let field = this.field;
        if (field.fieldType === "Reference") {
            return true;
        } else {
            return false;
        }
    }

    get isDecimalFieldEditable(){
        let field = this.field;
        if (field.editable === "true" && field.fieldType === "Decimal") {
            return true;
        } else {
            return false;
        }
    }

    get isApprovalRequired() {
        let record = JSON.parse(JSON.stringify(this.record));
        if (parseFloat(record.EndPrice) < parseFloat(record.UnitPrice)) {
            this.approvalRequiredColor = "red";
            record.approvalRequired = true;
        } else {
            this.approvalRequiredColor = "green";
            record.approvalRequired = false;
        }
        const selectedEvent = new CustomEvent("approvalrequired", {
            detail: {
                approvalRecordDetail: record
            }
        });
        this.dispatchEvent(selectedEvent);
        return true;
    }

    get cellDetail() {
        let record = JSON.parse(JSON.stringify(this.record));
        let field = this.field;
        let fieldApi = field.apiName;
        let cellValue;
        cellValue = record[fieldApi];
        this.recordId = record.ProductId;
        return cellValue;
    }

    redirectCall(event) {
        const redirectURL = window.location.origin + "/" + this.recordId;
        window.open(redirectURL, "_blank");
    }

    handleDiscountQuantityChange(event) {
        let isValid = true;
        if (this.field.apiName === "QuantityFinal") {
            if (event.target.value === "") {
                event.target.value = 1;
            }
        }
        if (event.target.value < 0) {
            isValid = false;
        }
        if (this.field.apiName === "Discount") {
            if (event.target.value > 0 && event.target.value > 100) {
                isValid = false;
            }
        }

        if (isValid === true) {
            var selectedRow = event.currentTarget;
            if (this.field.apiName === "QuantityFinal") {
                if (event.target.value === "") {
                    event.target.value = 1;
                }
            }
            //Pass data to aqt_treeDataTableRow
            const selectedEvent = new CustomEvent("discountchange", {
                detail: {
                    key: selectedRow.dataset.id,
                    selectedValue: event.target.value,
                    selectedField: this.field.apiName
                }
            });
            this.dispatchEvent(selectedEvent);
        }
    }
}