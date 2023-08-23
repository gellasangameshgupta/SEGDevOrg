import { LightningElement, api, track } from "lwc";
import searchProducts from "@salesforce/apex/AQT_QuotationTool.searchProducts";
import { showToast, duplicateRecordExist, label } from "c/aqt_utils";
const objColumnProductNotFound = [
  { label: "Part Number", fieldName: "PartNumber" },
  { label: "Quantity", fieldName: "Quantity" },
  { label: "Target Price", fieldName: "TargetPrice" },
  { label: "Comment", fieldName: "Comment", editable: true }
];

export default class Aqt_selectProductDetails extends LightningElement {
  objColumnProductNotFound = objColumnProductNotFound;
  @api objSearchProductResult;
  @api strSelectedAccountId;
  @api strSelectedAccountName;
  @api strSelectedContactId;
  @api strSelectedContactName;
  @api strContentVersionId;
  @api blnQuoteRecord;
  @api strGenerateQuoteLabel;

  @track list_productFound;
  @track list_previousOfferedPrice;
  list_productNotFound;

  @track productRecordById = new Map(); //Map to store the product id and the related details.
  @track intIndex = 0; //Index to iterate.
  @track blnGenerateQuoteDisable = false; //Disable the quote button.
  @track blnSpinner = false;
  @track list_searchProductResult;
  @track blnSearchProductDataExist = false;
  @track _columnClass;
  @track _columnWrapClass;
  @track blnIsParentChecked = false;
  @track list_selectedRecordIndex = [];
  customLabel = label;

  //Modal Variable

  blnModalVisible; //used to hide/show dialog
  strTitle; //modal title
  strName; //reference name of the component
  strMessage; //modal message
  strConfirmLabel; //confirm button label

  decTotalPrice = 0;
  decTotalDiscount = 0;
  decNetAmount = 0;
  strSelectedProductId;
  intProductNotFoundCount;
  recordIds = [];
  gridMetadata = [];
  gridColumns = [
    {
      apiName: "PartNumber",
      label: "Product Number",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "SEGIAMNumber",
      label: "SEG IAM Number",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "StandardListPrice",
      label: "Standard List Price",
      fieldType: "Currency",
      editable: "false"
    },
    {
      apiName: "UnitPrice",
      label: "Base Price-1 pcs",
      fieldType: "Currency",
      editable: "false"
    },
    {
      apiName: "Quantity",
      label: "Quantity Requested",
      fieldType: "Number",
      editable: "false"
    },
    {
      apiName: "QuantityFinal",
      label: "Quantity(final)",
      fieldType: "Number",
      editable: "true"
    },
    {
      apiName: "Discount",
      label: "Discount on Standard List Price",
      fieldType: "Decimal",
      editable: "true"
    },
    {
      apiName: "EndPrice",
      label: "Discounted Quotation Price - 1pcs",
      fieldType: "Currency"
    },
    {
      apiName: "NetAmount",
      label: "Total Sales",
      fieldType: "Currency",
      editable: "false"
    },
    {
      apiName: "EBIT",
      label: "EBIT",
      fieldType: "Percentage",
      editable: "false"
    }
  ];

  gridChildColumns = [
    {
      apiName: "SEGAlreadyOfferedPrice",
      label: "Last price sold",
      fieldType: "Currency",
      editable: "false"
    },
    {
      apiName: "ProductType",
      label: "Product Type",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "Name",
      label: "Product",
      fieldType: "Reference",
      editable: "false"
    },
    {
      apiName: "ProductionLocation",
      label: "Production Location",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "LeadTime",
      label: "Lead Time",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "MOQ",
      label: "MOQ",
      fieldType: "text",
      editable: "false"
    },
    {
      apiName: "TargetPrice",
      label: "Customer Target Price",
      fieldType: "Currency",
      editable: "false"
    },
    
    {
      apiName: "QuantityRemaining",
      label: "Quantity In Stock",
      fieldType: "Number",
      editable: "false"
    }
  ];

  gridLevelChild2Column = [
    {
      apiName: "AccountName",
      label : "Account Name",
      fieldType : 'text',
      editable : "false"
    },
    {
      apiName : "UnitPrice",
      label : 'Unit Price',
      fieldType : 'Currency',
      editable : "false"
    }

  ];

  connectedCallback() {
    this.blnSpinner = true;
    this.setColumnWidth();

    const selectedProductData = JSON.parse(
      JSON.stringify(this.objSearchProductResult)
    );

    this.list_previousOfferedPrice = selectedProductData.previousOfferedPrice;
      console.log(this.list_previousOfferedPrice);
      console.log(JSON.stringify(this.objSearchProductResult));
    if (
      selectedProductData.productFoundData ||
      selectedProductData.productNotFoundData
    ) {
      let tempProductNotFoundDataList = [];
      let tempProductFoundList = JSON.parse(
        JSON.stringify(selectedProductData.productFoundData)
      );
      tempProductNotFoundDataList = JSON.parse(
        JSON.stringify(selectedProductData.productNotFoundData)
      );
      if (tempProductNotFoundDataList.length > 0) {
        this.list_productNotFound = tempProductNotFoundDataList;
        this.intProductNotFoundCount = this.list_productNotFound.length;
      }
      if (tempProductNotFoundDataList.length === 0) {
        this.handleTabActive();
      }
      this.handleUpdateTableData(tempProductFoundList);
    } else {
      this.handleTabActive();
      this.list_productFound = selectedProductData;
      if (this.list_productFound) {
        (this.strSelectedAccountId = this.list_productFound[0].AccountId),
          (this.strSelectedContactId = this.list_productFound[0].ContactId);
      }
      this.handleUpdateTableData(this.list_productFound);
    }
    this.handleCalculateTotalPrice();
    this.blnSpinner = false;
  }

  handleTabActive() {
    setTimeout(
      () =>
        (this.template.querySelector("lightning-tabset").activeTabValue =
          "ProductFound")
    );
  }

  handleSaveNotFoundData(event) {
    const productNotFound = event.detail.draftValues;
    for (var key in productNotFound) {
      this.list_productNotFound[key].Comment = productNotFound[key].Comment;
    }
    showToast(
      this,
      "Success",
      "Product comments have been saved successfully.",
      "success"
    );
  }

  handleUpdateTableData(event) {
    const productFoundRecordId = [];
    const tempProductFoundList = JSON.parse(JSON.stringify(event));
    for (var i in tempProductFoundList) {
      productFoundRecordId.push(tempProductFoundList[i].ProductId);
      this.productRecordById.set(
        tempProductFoundList[i].ProductId,
        tempProductFoundList[i]
      );
    }
    if (tempProductFoundList.length > 0) {
      this.list_productFound = tempProductFoundList;
      this.gridMetadata = tempProductFoundList;
      this.recordIds = productFoundRecordId;
    } else {
      this.list_productFound = undefined;
      this.gridMetadata = undefined;
      this.recordIds = undefined;
    }
  }

  handleAllSelectionChange(event) {
    this.blnIsParentChecked = event.target.checked;
    let childComponents = [];
    childComponents = this.template.querySelectorAll(
      "c-aqt_tree-structure-data-table"
    );
    for (let i = 0; i < childComponents.length; i++) {
      childComponents[i].handleSelectionChangeParent(event.target.checked);
      if (event.target.checked) {
        this.list_selectedRecordIndex.push(i);
      }
    }
    if (event.target.checked === false) {
      this.list_selectedRecordIndex = [];
    }
  }

  handleRemoveSelected(event) {
    if (this.list_selectedRecordIndex.length) {
      if (
        this.list_selectedRecordIndex.length === this.list_productFound.length
      ) {
        this.blnModalVisible = true;
        this.strTitle = "Confirmation";
        this.strMessage =
          "Do you want to delete all the selected records from quote.!";
        this.strConfirmLabel = "Confirm";
      } else {
        this.blnModalVisible = true;
        this.strTitle = "Confirmation";
        this.strMessage =
          "Do you want to delete the selected records from quote.!";
        this.strConfirmLabel = "Confirm";
      }
    } else {
      showToast(this, "Error", "Please select a row to remove.", "error");
    }
  }

  handleConfirm() {
    let list_deleteQuoteLineItemRecords = [];
    this.list_selectedRecordIndex.sort(function (a, b) {
      return a - b;
    });
    const removeValIndex = this.list_selectedRecordIndex;
    for (var i = removeValIndex.length - 1; i >= 0; i--) {
      if (this.list_productFound[removeValIndex[i]].Id !== undefined) {
        list_deleteQuoteLineItemRecords.push(
          this.list_productFound[removeValIndex[i]]
        );
      }
    }
    for (var i = removeValIndex.length - 1; i >= 0; i--) {
      this.list_productFound.splice(removeValIndex[i], 1);
    }

    const selectedEvent = new CustomEvent("removequoterecord", {
      detail: {
        list_quoteLineItem: list_deleteQuoteLineItemRecords
      }
    });
    this.dispatchEvent(selectedEvent);

    this.handleCalculateTotalPrice();
    this.blnModalVisible = false;
    this.handleUpdateTableData(this.list_productFound);
  }

  handleCancel() {
    this.blnModalVisible = false;
  }

  handleGridRecordSelection(event) {
    const selectedRecordIndex = JSON.parse(JSON.stringify(event.detail.index));
    let checked = event.detail.checked;
    if (checked) {
      this.list_selectedRecordIndex.push(
        JSON.parse(JSON.stringify(selectedRecordIndex))
      ); //Add records in the List if checkbox is selected
    } else {
      const index = this.list_selectedRecordIndex.indexOf(
        parseInt(selectedRecordIndex)
      );
      this.list_selectedRecordIndex.splice(index, 1);
    }
  }

  handleListPriceChange(event) {
    const editedField = JSON.parse(JSON.stringify(event.detail.editedField));
    const rowDetail = JSON.parse(JSON.stringify(event.detail.rowDetail));
    this.list_productFound.forEach(function (result) {
      if (result.ProductId === rowDetail.ProductId) {
        result[editedField] = rowDetail[editedField];
        result.EndPrice = rowDetail.EndPrice;
        result.NetAmount = rowDetail.NetAmount;
        result.EBIT = rowDetail.EBIT;
      }
    });
    this.handleCalculateTotalPrice();
  }

  redirectAccountRecord(event) {
    const redirectURL =
      window.location.origin + "/" + this.strSelectedAccountId;
    window.open(redirectURL, "_blank");
  }

  redirectContactRecord(event) {
    const redirectURL =
      window.location.origin + "/" + this.strSelectedContactId;
    window.open(redirectURL, "_blank");
  }

  handleGenerateQuote(event) {
    let blnSaveAsDraft = false;
    let blnCreateRequestRecord = false;
    blnCreateRequestRecord = this.blnGenerateQuoteDisable;
    if (event.target.name === "SaveAsDraft") {
      blnSaveAsDraft = true;
      blnCreateRequestRecord = false;
    }
    const selectedEvent = new CustomEvent("generatequote", {
      detail: {
        productFoundData: this.list_productFound,
        productNotFoundData: this.list_productNotFound,
        createRequestRecord: blnCreateRequestRecord,
        totalAmount: this.decTotalPrice,
        totalDiscount: this.decTotalDiscount,
        netAmount : this.decNetAmount,
        strAccountId: this.strSelectedAccountId,
        strContactId: this.strSelectedContactId,
        strContentDocumentId: this.strContentDocumentId,
        blnSaveAsDraft: blnSaveAsDraft
      }
    });
    this.dispatchEvent(selectedEvent);
  }

  handleGeneratePDF(event) {
    const selectedEvent = new CustomEvent("generatepdf", {
      detail: {
        productFoundData: this.list_productFound,
        netAmount: this.decNetAmount,
        totalDiscount: this.decTotalDiscount,
        strSelectedAccountName: this.strSelectedAccountName,
        strSelectedContactName: this.strSelectedContactName
      }
    });
    this.dispatchEvent(selectedEvent);
  }

  handleQuoteApprovalRequired(event) {
    if (this.blnQuoteRecord !== "true" && this.list_productFound) {
      let tempBlnGenerateQuoteDisable = false;
      const tempRowDetail = event.detail.rowDetail;
      this.list_productFound.forEach(function (result) {
        if (result.ProductId === tempRowDetail.ProductId) {
          result.approvalRequired = tempRowDetail.approvalRequired;
        }
      });
      for (let key in this.list_productFound) {
        if (this.list_productFound[key].approvalRequired == true) {
          tempBlnGenerateQuoteDisable = true;
          break;
        }
      }
      this.blnGenerateQuoteDisable = tempBlnGenerateQuoteDisable;
    }
  }

  handleProductSelection(event) {
    this.strSelectedProductId = event.detail.selectedRecordId;
  }

  handleProductRemove(event) {
    this.strSelectedProductId = "";
  }

  handleSearchProduct(event) {
    if (this.strSelectedProductId) {
      this.blnSpinner = true;
      let childComponents = [];
      searchProducts({
        strAccountId: this.strSelectedAccountId,
        strContactId: this.strSelectedContactId,
        strRequestedData: "",
        strProductId: this.strSelectedProductId
      })
        .then((result) => {
          this.blnSpinner = false;
          if (result.productFoundData.length > 0) {
            this.blnSearchProductDataExist = true;
            this.list_searchProductResult = JSON.parse(
              JSON.stringify(result.productFoundData)
            );
            childComponents = this.template.querySelectorAll(
              "c-aqt_quantity-target-price-table"
            );
            for (let i = 0; i < childComponents.length; i++) {
              childComponents[i].handleProductAdd(
                this.list_searchProductResult
              );
            }
          }
          if (result.productNotFoundData.length > 0) {
            this.blnSpinner = false;
            showToast(
              this,
              "Error",
              "Please add the product with base price.",
              "error"
            );
            this.dispatchEvent(event);
          }
        })
        .catch((error) => {
          this.blnSpinner = false;
          showToast(this, "Error", this.customLabel.CLAQT00003, "error");
        });
    } else {
      this.blnSpinner = false;
      showToast(this, "Error", "Please choose the product to search.", "error");
    }
  }

  handleAddProduct(event) {
    this.blnSpinner = true;
    const searchProductResultData = JSON.parse(JSON.stringify(event.detail));
    let tempListProductFound;
    if (this.list_productFound) {
      tempListProductFound = JSON.parse(JSON.stringify(this.list_productFound));
    } else {
      tempListProductFound = [];
    }
    for (const key in searchProductResultData) {
      searchProductResultData[key].QuantityFinal =
        searchProductResultData[key].Quantity;
      searchProductResultData[key].NetAmount =
        searchProductResultData[key].Quantity *
        searchProductResultData[key].StandardListPrice;
      tempListProductFound.push(searchProductResultData[key]);
    }
    if (duplicateRecordExist(tempListProductFound)) {
      this.blnSpinner = false;
      showToast(this, "Error", this.customLabel.CLAQT00002, "error");
    } else {
      this.list_searchProductResult = [];
      this.handleUpdateTableData(tempListProductFound);
      this.blnSearchProductDataExist = false;
      this.template
        .querySelector("c-aqt_custom-lookup")
        .handleRemoveSelectedValue();
      this.template.querySelector("lightning-tabset").activeTabValue =
        "ProductFound";
      this.blnSpinner = false;
      showToast(
        this,
        "Success",
        "Products has been added successfully.!",
        "success"
      );
      this.handleCalculateTotalPrice();
    }
  }

  handleRecordExpandAll(event) {
    let childComponents = [];
    let iconName = event.target.iconName;
    if (iconName === "utility:chevronright") {
      childComponents = this.template.querySelectorAll(
        "c-aqt_tree-structure-data-table"
      );
      for (let i = 0; i < childComponents.length; i++) {
        childComponents[i].handleExpandAllRecord(iconName);
      }
      event.target.iconName = "utility:chevrondown";
    } else {
      childComponents = this.template.querySelectorAll(
        "c-aqt_tree-structure-data-table"
      );
      for (let i = 0; i < childComponents.length; i++) {
        childComponents[i].handleExpandAllRecord(iconName);
      }
      event.target.iconName = "utility:chevronright";
    }
  }

  handleQuantityAllChange(event) {
    if (event.target.value > 0) {
      this.list_selectedRecordIndex.sort(function (a, b) {
        return a - b;
      });
      const updateIndex = this.list_selectedRecordIndex;
      if (updateIndex.length != 0) {
        for (const i in updateIndex) {
          this.list_productFound[updateIndex[i]].QuantityFinal =
            event.target.value;
            this.list_productFound[updateIndex[i]].EndPrice =
            this.list_productFound[updateIndex[i]].StandardListPrice -
              this.list_productFound[updateIndex[i]].StandardListPrice *
                (this.list_productFound[updateIndex[i]].Discount / 100);
          /*this.list_productFound[updateIndex[i]].EndPrice = Math.round(
            this.list_productFound[updateIndex[i]].StandardListPrice -
              this.list_productFound[updateIndex[i]].StandardListPrice *
                (this.list_productFound[updateIndex[i]].Discount / 100)
          );*/
          this.list_productFound[updateIndex[i]].NetAmount =
            this.list_productFound[updateIndex[i]].EndPrice *
            this.list_productFound[updateIndex[i]].QuantityFinal;
        }
        this.handleUpdateTableData(this.list_productFound);
        let tempGridMetaData = this.gridMetadata;
        let childComponents = this.template.querySelectorAll(
          "c-aqt_tree-structure-data-table"
        );
        for (var i = updateIndex.length - 1; i >= 0; i--)
          childComponents[updateIndex[i]].handleQuantityAllChange(
            tempGridMetaData[[updateIndex[i]]]
          );
        this.handleCalculateTotalPrice();
      } else {
        showToast(
          this,
          "Error",
          "Kindly choose any of the row to apply quantity.!",
          "error"
        );
      }
    }
  }

  handleDiscountAllChange(event) {
    if (event.target.value >= 0 && event.target.value <= 100) {
      this.list_selectedRecordIndex.sort(function (a, b) {
        return a - b;
      });
      const updateIndex = this.list_selectedRecordIndex;

      if (updateIndex.length != 0) {
        for (const i in updateIndex) {
          this.list_productFound[updateIndex[i]].Discount = event.target.value;
          this.list_productFound[updateIndex[i]].EndPrice =
          this.list_productFound[updateIndex[i]].StandardListPrice -
            this.list_productFound[updateIndex[i]].StandardListPrice *
              (this.list_productFound[updateIndex[i]].Discount / 100);
          /*this.list_productFound[updateIndex[i]].EndPrice = Math.round(
            this.list_productFound[updateIndex[i]].StandardListPrice -
              this.list_productFound[updateIndex[i]].StandardListPrice *
                (this.list_productFound[updateIndex[i]].Discount / 100)
          );*/
          this.list_productFound[updateIndex[i]].NetAmount =
            this.list_productFound[updateIndex[i]].EndPrice *
            this.list_productFound[updateIndex[i]].QuantityFinal;

          let decimalEBIT;
          if (this.list_productFound[updateIndex[i]].EndPrice !== 0) {
           decimalEBIT =
            ((this.list_productFound[updateIndex[i]].EndPrice -
              this.list_productFound[updateIndex[i]].PPCPrice *
              (1 + this.list_productFound[updateIndex[i]].SG_A)) /
            this.list_productFound[updateIndex[i]].EndPrice)*100;
            
          }
          else{
            decimalEBIT = 0;
          }
          this.list_productFound[updateIndex[i]].EBIT = (
            Math.round(decimalEBIT * 100) / 100
          ).toFixed(2);
        }
        this.handleUpdateTableData(this.list_productFound);
        let tempGridMetaData = this.gridMetadata;
        let childComponents = this.template.querySelectorAll(
          "c-aqt_tree-structure-data-table"
        );
        for (var i = updateIndex.length - 1; i >= 0; i--)
          childComponents[updateIndex[i]].handleQuantityAllChange(
            tempGridMetaData[[updateIndex[i]]]
          );
        this.handleCalculateTotalPrice();
      } else {
        showToast(
          this,
          "Error",
          "Kindly choose any of the row to apply discount.!",
          "error"
        );
      }
    }
  }

  handleUpdateMaxDiscount(event) {
    this.list_selectedRecordIndex.sort(function (a, b) {
      return a - b;
    });
    const updateIndex = this.list_selectedRecordIndex;

    if (updateIndex.length != 0) {
      for (const i in updateIndex) {
        let discount =
          ((this.list_productFound[updateIndex[i]].StandardListPrice -
            this.list_productFound[updateIndex[i]].UnitPrice) /
            this.list_productFound[updateIndex[i]].StandardListPrice) *
          100;

        if (Math.sign(discount) === 1) {
          this.list_productFound[updateIndex[i]].Discount = discount.toFixed(4);
          this.list_productFound[updateIndex[i]].EndPrice =
            this.list_productFound[updateIndex[i]].StandardListPrice -
              this.list_productFound[updateIndex[i]].StandardListPrice *
                (this.list_productFound[updateIndex[i]].Discount / 100);
         /* this.list_productFound[updateIndex[i]].Discount = (
            Math.floor(discount * 100) / 100
          ).toFixed(4);*/
       /*   this.list_productFound[updateIndex[i]].EndPrice = Math.round(
            this.list_productFound[updateIndex[i]].StandardListPrice -
              this.list_productFound[updateIndex[i]].StandardListPrice *
                (this.list_productFound[updateIndex[i]].Discount / 100)
          );*/
          this.list_productFound[updateIndex[i]].NetAmount =
            this.list_productFound[updateIndex[i]].EndPrice *
            this.list_productFound[updateIndex[i]].QuantityFinal;

          let decimalEBIT =
          ((this.list_productFound[updateIndex[i]].EndPrice -
            this.list_productFound[updateIndex[i]].PPCPrice *
            (1 + this.list_productFound[updateIndex[i]].SG_A)) /
          this.list_productFound[updateIndex[i]].EndPrice)*100;
          this.list_productFound[updateIndex[i]].EBIT = (
            Math.round(decimalEBIT * 100) / 100
          ).toFixed(2);
        }
        this.handleUpdateTableData(this.list_productFound);
        let tempGridMetaData = this.gridMetadata;
        let childComponents = this.template.querySelectorAll(
          "c-aqt_tree-structure-data-table"
        );
        for (var j = updateIndex.length - 1; j >= 0; j--)
          childComponents[updateIndex[j]].handleQuantityAllChange(
            tempGridMetaData[[updateIndex[j]]]
          );
        this.handleCalculateTotalPrice();
      }
    }
    else{
        showToast(
          this,
          "Error",
          "Kindly choose any of the row to apply discount.!",
          "error"
          );
        }
  }

  handleCalculateTotalPrice() {
    let decTotalPrice = 0.0;
    let decNetAmount = 0.0;
    if (this.list_productFound) {
      this.list_productFound.forEach(function (result) {
        decTotalPrice =
          decTotalPrice + result.StandardListPrice * result.QuantityFinal;
        decNetAmount = decNetAmount + result.NetAmount;
      });

      if (decTotalPrice === decNetAmount) {
        this.decTotalPrice = decTotalPrice;
        this.decNetAmount = decNetAmount;
        this.decTotalDiscount = 0;
      } else {
        this.decTotalPrice = decTotalPrice;
        this.decTotalDiscount = (decTotalPrice - decNetAmount )/ decTotalPrice;
        this.decNetAmount =
          decTotalPrice - decTotalPrice * this.decTotalDiscount;
      }
    }
  }

  handlePreviousScreen(event){
    const selectedEvent = new CustomEvent("previousscreen", {
    });
    this.dispatchEvent(selectedEvent);
  }

  get headerColumnClass() {
    return (
      "slds-var-p-horizontal_x-small " +
      this._columnClass +
      " " +
      this._columnWrapClass
    );
  }

  get bodyColumnClass() {
    return "slds-var-p-horizontal_x-small " + this._columnClass;
  }
  setColumnWidth() {
    let numberOfColumns = this.gridColumns.length;
    let columnWidth = 100 / numberOfColumns;
    if (columnWidth < 12.5) {
      this._columnClass = "vps-width-11";
    } else if (columnWidth >= 12.5 && columnWidth < 15) {
      this._columnClass = "vps-width-12";
    } else if (columnWidth >= 15 && columnWidth < 20) {
      this._columnClass = "vps-width-15";
    } else if (columnWidth >= 20 && columnWidth < 25) {
      this._columnClass = "vps-width-20";
    } else if (columnWidth >= 25 && columnWidth < 30) {
      this._columnClass = "vps-width-25";
    } else if (columnWidth >= 30 && columnWidth < 40) {
      this._columnClass = "vps-width-30";
    } else if (columnWidth >= 40) {
      this._columnClass = "vps-width-40";
    }
    this._columnWrapClass = "slds-truncate";
  }
}