import { LightningElement, api } from "lwc";

export default class B2b_dynamicSobjectField extends LightningElement {
    @api objField;

    get datatypeString() {
        return this.objField.strDataType === "STRING" ? true : false;
    }

    get datatypeNumber() {
        return this.objField.strDataType === "DOUBLE" || this.objField.strDataType === "INTEGER"
            ? true
            : false;
    }

    get datatypeDate() {
        return this.objField.strDataType === "DATE" ? true : false;
    }

    get datatypeDateTime() {
        return this.objField.strDataType === "DATETIME" ? true : false;
    }

    get datatypePicklist() {
        return this.objField.strDataType === "PICKLIST" ? true : false;
    }

    get datatypeEmail() {
        return this.objField.strDataType === "EMAIL" ? true : false;
    }

    get datatypePhone() {
        return this.objField.strDataType === "PHONE" ? true : false;
    }

    get datatypeCheckbox() {
        return this.objField.strDataType === "BOOLEAN" ? true : false;
    }

    handleChange(event) {
        let objField = {};
        objField.value = event.target.value;
        objField.strApiName = this.objField.strApiName;
        this.dispatchEvent(
            new CustomEvent("inputchange", {
                detail: objField
            })
        );
    }
}