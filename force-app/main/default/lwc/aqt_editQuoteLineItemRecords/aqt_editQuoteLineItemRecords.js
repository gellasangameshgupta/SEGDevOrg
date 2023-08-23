import { LightningElement, api, track } from "lwc";
import fetchQuoteLineItemRecords from "@salesforce/apex/AQT_QuotationTool.fetchQuoteLineItemRecords";
import updateQuoteLineItemRecords from "@salesforce/apex/AQT_QuotationTool.updateQuoteLineItemRecords";
import { CloseActionScreenEvent } from "lightning/actions";
import deleteQuoteLineItem from "@salesforce/apex/AQT_QuotationTool.deleteQuoteLineItem";
import { loadStyle } from "lightning/platformResourceLoader";
import ModalWidth from "@salesforce/resourceUrl/SRAQT00002";
import { showToast, label } from "c/aqt_utils";
import { NavigationMixin } from "lightning/navigation";
import quotePDFCacheStore from "@salesforce/apex/AQT_QuotationTool.quotePDFCacheStore";

export default class aqt_editQuoteLineItemRecords extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objEditLineItemDetails;
  @track objQuoteLineItemRecords;
  strQuoteId;
  blnSpinner = false;
  blnQuoteLineItemRecordExist = false;
  customLabel = label;
  blnQuoteRecord = true;
  strSelectedAccountId;
  strSelectedContactId;
  strSelectedAccountName;
  strSelectedContactName;

  connectedCallback() {
    if (this.objEditLineItemDetails != undefined) {
      this.blnSpinner = true;
      this.strSelectedAccountId = this.objEditLineItemDetails.selectedAccountId;
      this.strSelectedContactId = this.objEditLineItemDetails.selectedContactId;
      this.strSelectedAccountName =
        this.objEditLineItemDetails.selectedAccountName;
      this.strSelectedContactName =
        this.objEditLineItemDetails.selectedContactName;
      this.fetchQuoteLineItemRecords(this.objEditLineItemDetails.strQuoteId);
      this.blnQuoteRecord = false;
      this.strQuoteId = this.objEditLineItemDetails.strQuoteId;
      this.blnSpinner = false;
    }
  }

  //Get the quote lineItem record and load the css to increase the modal width
  renderedCallback() {
    Promise.all([loadStyle(this, ModalWidth)])
      .then(() => {})
      .catch((error) => {
        showToast(this, "Error", this.customLabel.CLAQT00003, "error");
      });
    if (!this.blnRetrievedRecordId && this.recordId) {
      this.blnSpinner = true;
      this.blnRetrievedRecordId = true; // Escape case from recursion
      this.fetchQuoteLineItemRecords(this.recordId);
      this.strQuoteId = this.recordId;
    }
  }

  fetchQuoteLineItemRecords(strQuoteId) {
    fetchQuoteLineItemRecords({ strQuoteId: strQuoteId })
      .then((result) => {
        if (result.length === 0) {
          this.blnSpinner = false;
          showToast(this, "Error", this.customLabel.CLAQT00007, "error");
          this.dispatchEvent(new CloseActionScreenEvent());
        }
        if (result.length > 0) {
          this.blnSpinner = false;
          this.objQuoteLineItemRecords = result;
          this.blnQuoteLineItemRecordExist = true;
        }
      })
      .catch((error) => {
        this.blnSpinner = false;
        showToast(this, "Error", this.customLabel.CLAQT00003, "error");
      });
  }

  handleGenerateQuote(event) {
    this.blnSpinner = true;
    if (event.detail) {
      const objProductSelectedDetails = event.detail;
      for (const key in objProductSelectedDetails.productFoundData) {
        if (
          objProductSelectedDetails.productFoundData[key].QuoteId === undefined
        ) {
          objProductSelectedDetails.productFoundData[key].QuoteId =
            this.strQuoteId;
        }
      }
      updateQuoteLineItemRecords({
        list_quoteLineItemRecord: JSON.stringify(
          objProductSelectedDetails.productFoundData
        ),
        decTotalAmount: objProductSelectedDetails.totalAmount,
        decTotalDiscount: objProductSelectedDetails.totalDiscount,
        blnCreateRequestRecord: objProductSelectedDetails.createRequestRecord
      })
        .then((result) => {
          this.blnSpinner = false;
          if (this.blnQuoteRecord == false) {
            this.dispatchEvent(
              new CustomEvent("success", {
                detail: result
              })
            );
          } else {
            showToast(
              this,
              "Success",
              "Record has been saveed successfully.!",
              "success"
            );
            this.dispatchEvent(new CloseActionScreenEvent());
            eval("$A.get('e.force:refreshView').fire();");
          }
        })
        .catch((error) => {
          this.blnSpinner = false;
          showToast(this, "Error", this.customLabel.CLAQT00003, "error");
          this.dispatchEvent(new CloseActionScreenEvent());
        });
    }
  }

  handleGeneratePDF(event) {
    if (event.detail) {
      const objProductSelectedDetails = event.detail;
      this.blnSpinner = true;
      quotePDFCacheStore({
        strProductFoundData: JSON.stringify(
          objProductSelectedDetails.productFoundData
        ),
        decTotalPrice: objProductSelectedDetails.netAmount,
        decTotalDiscount: objProductSelectedDetails.totalDiscount * 100,
        strAccountName: objProductSelectedDetails.strSelectedAccountName,
        strContactName: objProductSelectedDetails.strSelectedContactName
      })
        .then((result) => {
          this.blnSpinner = false;
          const urlWithParameters = "/apex/AQT_QuotePDF";
          ``;
          this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
              url: urlWithParameters
            }
          }).then((generatedUrl) => {
            window.open(generatedUrl);
          });
        })
        .catch((error) => {
          this.blnSpinner = false;
          showToast(
            this,
            "Error",
            "An error occurred,please try again later",
            "error"
          );
        });
    }
  }

  handleRemoveSelected(event) {
    if (event.detail) {
      const objProductSelectedDetails = JSON.parse(
        JSON.stringify(event.detail)
      );
      if (objProductSelectedDetails.list_quoteLineItem.length > 0) {
        deleteQuoteLineItem({
          list_SObjects: objProductSelectedDetails.list_quoteLineItem
        })
          .then((result) => {
            this.modalVisible = false;
          })
          .catch((error) => {
            showToast(this, "Error", this.customLabel.CLAQT00003, "error");
          });
      } else {
        this.modalVisible = false;
      }
    }
  }

  handlePreviousScreen(event) {
    if (this.objEditLineItemDetails != undefined) {
      this.dispatchEvent(
        new CustomEvent("previousscreen", {
          detail: {
            strSelectedAccountId: this.objEditLineItemDetails.selectedAccountId,
            strSelectedContactId: this.objEditLineItemDetails.selectedContactId,
            strSelectedAccountName:
              this.objEditLineItemDetails.selectedAccountName,
            strSelectedContactName:
              this.objEditLineItemDetails.selectedContactName
          }
        })
      );
    }
    else{
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  }
}