import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/** Apex */
import updateOrderSummary from "@salesforce/apex/B2B_OrderButtonController.updateOrderSummaryFields";

import CLB2B00022 from "@salesforce/label/c.CLB2B00022"; // Cancel Order Confirmation Text
import CLB2B00024 from "@salesforce/label/c.CLB2B00024"; // Return Order Confirmation Text
import CLB2B00025 from "@salesforce/label/c.CLB2B00025"; // Order Status values
import ID_FIELD from "@salesforce/schema/OrderSummary.Id";
import STATUS_FIELD from "@salesforce/schema/OrderSummary.Status";
import ORDER_ACTION_REASON from "@salesforce/schema/OrderSummary.B2B_OrderActionReason__c";

export default class B2b_orderControlButton extends LightningElement {
    // Variables
    @api strRecordId; // record id from record detail page
    strOrderStatus; // Order Status to show msg if buttons are not applicable
    blnIsReturnModalOpen = false; // Return Order Modal Visiblity
    blnIsCancelModalOpen = false; // Cancel Order Modal Visiblity
    blnIsRendered = false;
    blnShowLoading = false;

    // Expose the labels to use in the template.
    label = {
        CLB2B00022,
        CLB2B00024,
        CLB2B00025
    };

    @wire(getRecord, { recordId: "$strRecordId", fields: [STATUS_FIELD] })
    getOrderStatus({ error, data }) {
        if (error) {
            this.handleException(error);
        } else if (data) {
            this.strOrderStatus = data.fields.Status.value;
        }
    }

    get blnIsButtonVisible() {
        return this.blnIsCancelButtonVisible || this.blnIsReturnButtonVisible ? true : false;
    }

    get blnIsReturnButtonVisible() {
        return this.strOrderStatus == "Delivered" ? true : false;
    }

    get blnIsCancelButtonVisible() {
        if (this.label.CLB2B00025) {
            let list_Statuses = this.label.CLB2B00025.split(",");
            return list_Statuses.indexOf(this.strOrderStatus) > -1 ? true : false;
        }
    }

    get strStatusMessage() {
        if (this.strOrderStatus) {
            return "Order " + this.strOrderStatus;
        }
    }

    handlePositiveReturnAction() {
        this.handlePositiveAction("Return Request", "Return Requested!");
    }

    handlePositiveCancelAction() {
        this.handlePositiveAction("Cancel Request", "Cancellation Requested!");
    }

    handlePositiveAction(strStatus, strMessage) {
        const blnAllValid = [...this.template.querySelectorAll("lightning-textarea")].reduce(
            (validSoFar, inputCmp) => {
                if (inputCmp.value) {
                    inputCmp.value = inputCmp.value.trim();
                }

                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );

        if (blnAllValid) {
            this.blnShowLoading = true;

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.strRecordId;
            fields[STATUS_FIELD.fieldApiName] = strStatus;
            fields[ORDER_ACTION_REASON.fieldApiName] = this.template.querySelector(
                "lightning-textarea"
            ).value;

            const recordInput = { fields };
            updateOrderSummary({
                strOrderSummaryID: this.strRecordId,
                strStatusValue: strStatus,
                strReason: this.template.querySelector("lightning-textarea").value
            })
                .then(() => {
                    strStatus === "Return Request" ? this.toggleReturnModal() : this.toggleCancelModal();
                    this.strOrderStatus = strStatus;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: strMessage,
                            variant: "success"
                        })
                    );
                })
                .catch((error) => {
                    this.handleException(error);
                })
                .finally(() => {
                    this.blnShowLoading = false;
                });
        }
    }

    toggleReturnModal() {
        this.blnIsReturnModalOpen = this.blnIsReturnModalOpen ? false : true;
    }

    toggleCancelModal() {
        this.blnIsCancelModalOpen = this.blnIsCancelModalOpen ? false : true;
    }

    handleException(error) {
        let strMessage = "Unknown error";

        if (error && error.body && Array.isArray(error.body)) {
            strMessage = error.body.map((e) => e.message).join(", ");
        } else if (error && error.body && typeof error.body.message === "string") {
            strMessage = error.body.message;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                strMessage,
                variant: "error"
            })
        );
    }

    renderedCallback() {
        if (this.blnIsRendered) return;

        if (
            this.blnIsButtonVisible &&
            (this.blnIsReturnButtonVisible || this.blnIsCancelButtonVisible)
        ) {
            this.blnIsRendered = true;
            const style = document.createElement("style");
            style.innerText = `
                .b2b-button button {
                    border-radius: 20px !important;
                }
            `;
            this.template.querySelector("lightning-button").appendChild(style);
        }
    }
}