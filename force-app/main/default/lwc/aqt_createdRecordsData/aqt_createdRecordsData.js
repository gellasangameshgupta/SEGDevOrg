import { LightningElement, api } from "lwc";

export default class Aqt_createdRecordsData extends LightningElement {
    @api createdRecordsData;
    quoteId;
    quoteName;
    requestId;
    requestName = "";
    accountId;
    accountName;

    connectedCallback() {
        this.quoteId = "/" + this.createdRecordsData.objQuoteDetails.Id;
        this.quoteName = this.createdRecordsData.objQuoteDetails.Name;
        if (this.createdRecordsData.objRequestDetails !== undefined) {
            this.requestId = "/" + this.createdRecordsData.objRequestDetails.Id;
            this.requestName = this.createdRecordsData.objRequestDetails.Name;
        }
        this.accountId = "/" + this.createdRecordsData.objAccountDetails.Id;
        this.accountName = this.createdRecordsData.objAccountDetails.Name;
    }

    handleNewQuote(event) {
        eval("$A.get('e.force:refreshView').fire();");
    }
}