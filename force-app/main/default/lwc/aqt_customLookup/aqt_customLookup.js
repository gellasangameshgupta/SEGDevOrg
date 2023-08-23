import lookUpSearchResult from "@salesforce/apex/AQT_CustomLookupLWCController.search";
import { api, LightningElement, wire } from "lwc";

export default class customLookUp extends LightningElement {
  @api objectName; //Store the object name for lookup field
  @api iconName; //Store the icon name
  @api strfilter; //Store the filter for the lookup field
  @api searchPlaceholder = "Search...";
  @api strLabel; //Store the label for the lookup field
  @api blnRequired; //Store if the field is required
  @api strSelectedRecordId; //Store the selected record id;
  @api strSelectedRecordName; //Store the selected record name;
  selectedName; //selected name
  list_records; //list of records as result from apex
  isValueSelected; //Boolean to check if the value is selected
  blurTimeout;
  inputClass = "";
  lookupResultSpinner = true; //Loading the result for the lookup field
  searchTerm; //Search term entered by the user
  blnNoResultFound = false; //Boolean to store if no result is found

  @wire(lookUpSearchResult, {
    strSearchTerm: "$searchTerm",
    strObjectName: "$objectName",
    strFilter: "$strfilter"
  })
  wiredRecords({ error, data }) {
    if (data) {
      this.error = undefined;
      this.lookupResultSpinner = false;
      this.list_records = data;
      this.blnNoResultFound = false;
      if (data.length === 0) {
        this.blnNoResultFound = true;
      }
    } else if (error) {
      this.lookupResultSpinner = false;
      this.blnNoResultFound = true;
      this.error = error;
      this.list_records = undefined;
    }
  }

  connectedCallback(){
    if(this.strSelectedRecordId !== undefined){
      let strSelectedId = this.strSelectedRecordId;
      let strSelectedName = this.strSelectedRecordName;
      this.isValueSelected = true;
      this.selectedName = strSelectedName;
      const valueSelectedEvent = new CustomEvent("lookupselected", {
        detail: {
          selectedRecordId: strSelectedId,
          selectedRecordName: strSelectedName
        }
      });
      this.dispatchEvent(valueSelectedEvent);
      if (this.blurTimeout) {
        clearTimeout(this.blurTimeout);
      }
      this.boxClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    }
  }

  //Show the data fetched from apex
  handleClick(event) {
    if (this.strfilter !== undefined) {
      this.searchTerm = event.target.value;
      this.template
        .querySelector(".slds-dropdown-trigger")
        .classList.remove("slds-is-close");
      this.template
        .querySelector(".slds-dropdown-trigger")
        .classList.add("slds-is-open");
    }
  }

  handleKeyPress(event) {
    this.searchTerm = event.target.value;
    this.template
      .querySelector(".slds-dropdown-trigger")
      .classList.remove("slds-is-close");
    this.template
      .querySelector(".slds-dropdown-trigger")
      .classList.add("slds-is-open");
  }

  handleOnBlur() {
    this.blurTimeout = setTimeout(() => {
      this.boxClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-close";
    }, 100);
  }

  //Pass the selected value to the parent component
  handleOnSelect(event) {
    let strSelectedId = event.currentTarget.dataset.id;
    let strSelectedName = event.currentTarget.dataset.name;
    this.isValueSelected = true;
    this.selectedName = strSelectedName;
    const valueSelectedEvent = new CustomEvent("lookupselected", {
      detail: {
        selectedRecordId: strSelectedId,
        selectedRecordName: strSelectedName
      }
    });
    this.dispatchEvent(valueSelectedEvent);
    if (this.blurTimeout) {
      clearTimeout(this.blurTimeout);
    }
    this.boxClass =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
  }

  //Pass the removed value to the parent component
  handleRemovePill() {
    this.isValueSelected = false;
    const removeLookupValue = new CustomEvent("lookupremove", {
      detail: this.objectName
    });
    this.dispatchEvent(removeLookupValue);
  }

  //Show the result on the based of user entered details
  handleOnChange(event) {
    this.lookupResultSpinner = true;
    this.blnNoResultFound = false;

    if (event.target.value != "") {
      this.searchTerm = event.target.value;
      this.template
        .querySelector(".slds-dropdown-trigger")
        .classList.add("slds-is-open");
    } else {
      this.searchTerm = "";
    }
  }

  //Hide the dropdown when the mouse leaves the component
  handleMouseLeave(event) {
    this.blurTimeout = setTimeout(() => {
      this.template
        .querySelector(".slds-dropdown-trigger")
        .classList.remove("slds-is-open");
      this.template
        .querySelector(".slds-dropdown-trigger")
        .classList.add("slds-is-close");
    }, 2000);
  }

  @api
  handleRemoveSelectedValue(event) {
    this.isValueSelected = false;
  }
}