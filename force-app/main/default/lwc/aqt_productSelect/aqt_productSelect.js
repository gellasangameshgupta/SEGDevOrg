import { LightningElement, api, track, wire } from "lwc";
import quoteCreate from "@salesforce/apex/AQT_QuotationTool.createQuoteRecord";
import quotePDFCacheStore from "@salesforce/apex/AQT_QuotationTool.quotePDFCacheStore";

import { NavigationMixin } from "lightning/navigation";
import { showToast } from "c/aqt_utils";

export default class aqt_productSelect extends NavigationMixin(
  LightningElement
) {
  @api selectedProductData;
  @track objSearchProductResult; //List to store product found data.

  blnSpinner = false;
  strSelectedAccountId;
  strSelectedAccountName;
  strSelectedContactId;
  strSelectedContactName;
  strContentVersionId;

  connectedCallback() {
    this.objSearchProductResult = JSON.parse(
      JSON.stringify(this.selectedProductData.searchedProductResult)
    );

    this.strSelectedAccountId = this.selectedProductData.selectedAccountId;
    this.strSelectedAccountName = this.selectedProductData.selectedAccountName;
    this.strSelectedContactId = this.selectedProductData.selectedContactId;
    this.strSelectedContactName = this.selectedProductData.selectedContactName;
    this.strContentVersionId = this.selectedProductData.strContentVersionId;
  }

  handleGenerateQuote(event) {
    if (event.detail) {
      const objProductSelectedDetails = event.detail;
      const objQuoteDetail = {};
      objQuoteDetail.blnCreateRequestRecord = objProductSelectedDetails.createRequestRecord;
      objQuoteDetail.decTotalAmount = objProductSelectedDetails.totalAmount;
      objQuoteDetail.decNetAmount = objProductSelectedDetails.netAmount;
      objQuoteDetail.decTotalDiscount = objProductSelectedDetails.totalDiscount;
      objQuoteDetail.strAccountId = objProductSelectedDetails.strAccountId;
      objQuoteDetail.strContactId = objProductSelectedDetails.strContactId;
      objQuoteDetail.strContentVersionId = this.strContentVersionId;
      objQuoteDetail.strProductFoundDataWrapper = JSON.stringify(
          objProductSelectedDetails.productFoundData
      );
      objQuoteDetail.strProductNotFoundWrapper = JSON.stringify(
          objProductSelectedDetails.productNotFoundData
      );
      objQuoteDetail.blnSaveAsDraft = objProductSelectedDetails.blnSaveAsDraft

      this.blnSpinner = true;
      quoteCreate({
        strQuoteDetail: JSON.stringify(objQuoteDetail)
      })
        .then((result) => {
          this.blnSpinner = false;
          this.dispatchEvent(
            new CustomEvent("success", {
              detail: result
            })
          );
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
    } else {
      this.blnSpinner = false;
      showToast(
        this,
        "Error",
        "An error occurred,please try again later",
        "error"
      );
    }
  }

  handleGeneratePDF(event) {
    this.blnSpinner = true;
    const objProductSelectedDetails = event.detail;
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

  handlePreviousScreen(event) {
    let tempList_Partnumber;
    if(this.selectedProductData.list_partNumber !== undefined){
      tempList_Partnumber = this.selectedProductData.list_partNumber.replace(/["']/g, "");
    }
    this.dispatchEvent(
      new CustomEvent("previousscreen", {
        detail: {
          strSelectedAccountId: this.selectedProductData.selectedAccountId,
          strSelectedContactId: this.selectedProductData.selectedContactId,
          strSelectedAccountName: this.selectedProductData.selectedAccountName,
          strSelectedContactName: this.selectedProductData.selectedContactName,
          list_partNumber: tempList_Partnumber,
          objUploadExcelFile: this.selectedProductData.objUploadExcelFile
        }
      })
    );
  }
}