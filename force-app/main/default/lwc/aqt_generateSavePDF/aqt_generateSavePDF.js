import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import savePDF from "@salesforce/apex/AQT_QuotePDF.savePDF";
import { CloseActionScreenEvent } from "lightning/actions";
import getQuoteDetails from "@salesforce/apex/AQT_QuotationToolSelector.getQuoteDetails";
import { showToast, label } from "c/aqt_utils";

export default class Aqt_generateSavePDF extends NavigationMixin(LightningElement) {
    @api recordId;
    retrievedRecordId = false;
    list_quoteRecord;
    customLabel = label;
    
    renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            getQuoteDetails({ strQuoteId: this.recordId })
                .then((result) => {
                    this.list_quoteRecord = result;
                })
                .catch((error) => {
                    showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                });
        }
    }

    handleViewPDF() {
        const urlWithParameters = "/apex/AQT_QuotePDF?id=" + this.recordId;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
                url: urlWithParameters
            }
        }).then((generatedUrl) => {
            window.open(generatedUrl);
        });
    }

    handleSavePDF() {
        this.spinner = true;
        savePDF({
            strQuoteId: this.recordId
        })
            .then((result) => {
                if (result == true) {
                    this.spinner = false;
                    showToast(this, "Success", "Record has been saved successfully", "success");
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();");
                }
            })

            .catch((error) => {
                showToast(this, "Error", this.customLabel.CLAQT00003, "error");
                this.dispatchEvent(new CloseActionScreenEvent());
                eval("$A.get('e.force:refreshView').fire();");
            });
    }
}