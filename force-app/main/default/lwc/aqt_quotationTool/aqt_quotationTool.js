import { LightningElement } from "lwc";

export default class Aqt_quotationTool extends LightningElement {
  intCurrentStep = "s1";
  blnScreen1 = true;
  blnSelectedProductExist = false;
  blnRecordsCreated = false;
  blnQuoteLineItemRecord = false;
  objEditLineItemDetails;
  selectedDetails;

  handleProductSearch(event) {
    this.intCurrentStep = "s2";
    this.objSelectedProduct = event.detail;
    this.blnSelectedProductExist =
      Object.keys(this.objSelectedProduct).length != 0;
    this.blnScreen1 = false;
    this.template
      .querySelector("[data-id=s1]")
      .classList.remove("slds-is-active");
  }

  handleEditQuoteLineItems(event) {
    this.objEditLineItemDetails = event.detail;
    this.intCurrentStep = "s2";
    this.blnQuoteLineItemRecord = true;
    this.blnScreen1 = false;
    this.template
      .querySelector("[data-id=s1]")
      .classList.remove("slds-is-active");
  }

  handleProductSelectLoad(event) {
    this.template
      .querySelector("[data-id=s1]")
      .classList.remove("slds-is-active");
    this.template.querySelector("[data-id=s2]").classList.add("slds-is-active");
  }

  fetchResultData(event) {
    this.intCurrentStep = "s3";
    this.objCreatedRecords = event.detail;
    this.blnRecordsCreated = Object.keys(this.objCreatedRecords).length != 0;
    this.blnScreen1 = false;
    this.blnSelectedProductExist = false;
    this.blnQuoteLineItemRecord = false;
  }

  handlePreviousScreen(event) {
    this.selectedDetails = JSON.parse(JSON.stringify(event.detail));
    this.intCurrentStep = "s1";
    this.blnScreen1 = true;
    this.blnSelectedProductExist = false;
    this.blnQuoteLineItemRecord = false;
  }
}