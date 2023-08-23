import { LightningElement, api, track } from "lwc";
import requestCreate from "@salesforce/apex/AQT_QuotationTool.submitForApproval";
import { showToast, label } from "c/aqt_utils";

export default class Aqt_quoteSubmitForApproval extends LightningElement {
    @api recordId;
    @track blnSpinner = false;
    customLabel = label;
    @api
    invoke() {
        this.blnSpinner = true;
        requestCreate({ QuoteId: this.recordId })
            .then((result) => {
                if (result === true) {
                    this.blnSpinner = false;
                    showToast(
                        this,
                        "Success",
                        "Record has been submitted for approval.",
                        "success"
                    );
                    eval("$A.get('e.force:refreshView').fire();");
                }
                if (result === false) {
                    this.blnSpinner = false;
                    showToast(this, "Error", this.customLabel.CLAQT00007, "error");
                }
            })
            .catch((error) => {
                showToast(this, "Error", this.customLabel.CLAQT00003, "error");
            });
    }
}