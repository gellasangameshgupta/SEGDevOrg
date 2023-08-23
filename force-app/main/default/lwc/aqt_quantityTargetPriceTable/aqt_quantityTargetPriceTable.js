import { LightningElement, api, track } from "lwc";
import { showToast, duplicateRecordExist } from "c/aqt_utils";

export default class Aqt_quantityTargetPriceTable extends LightningElement {
    @api searchProductData;
    @api strButtonLabel; //Label for the button in order to move to next screen
    intRowIndex = 0;
    blnSpinner = false;
    isParentChecked = false;
    @track searchedProductData;

    connectedCallback() {
        this.searchedProductData = JSON.parse(JSON.stringify(this.searchProductData));
    }

    @api
    handleProductAdd(event) {
        this.searchedProductData.push(JSON.parse(JSON.stringify(event[0])));
    }

    handleCheckboxChange(event) {
        const toogleList = [];
        var totalSeachProduct = Object.keys(this.searchedProductData).length;

        for (var key = 0; key < totalSeachProduct; key++) {
            toogleList.push(this.template.querySelector('[data-id="' + key + '"]'));
        }
        for (const toggleElement of toogleList) {
            toggleElement.checked = false;
        }
    }

    handleAllSelectionChange(event) {
        this.isParentChecked = event.target.checked;
    }
    handleRemoveSelectedData(event) {
        this.removeValIndex = [...this.template.querySelectorAll("lightning-input")]
            .filter((element) => element.checked)
            .map((element) => element.dataset.id);

        if (this.removeValIndex.length === 0) {
            showToast(this, "Error", "Please select products to remove.!", "error");
        } else {
            for (var i = this.removeValIndex.length - 1; i >= 0; i--)
                this.searchedProductData.splice(this.removeValIndex[i], 1);
            this.handleCheckboxChange();
            const selectedEvent = new CustomEvent("removeproduct", {
                detail: this.searchedProductData
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleQuantityChange(event) {
        var quantity = 1;
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        const tempSearchedProductData = JSON.parse(JSON.stringify(this.searchedProductData));
        if (event.target.value != "") {
            quantity = event.target.value;
        }
        tempSearchedProductData[key].Quantity = quantity;
        this.searchedProductData = JSON.parse(JSON.stringify(tempSearchedProductData));
    }

    handleTargetPriceChange(event) {
        var TargetPrice = 0;
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        const tempSearchedProductData = JSON.parse(JSON.stringify(this.searchedProductData));
        if (event.target.value != "") {
            TargetPrice = event.target.value;
        }
        tempSearchedProductData[key].TargetPrice = TargetPrice;
        this.searchedProductData = JSON.parse(JSON.stringify(tempSearchedProductData));
    }

    handleAddProduct(event) {
        if (this.searchedProductData.length > 0) {
            const selectedEvent = new CustomEvent("addproduct", {
                detail: this.searchedProductData
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.searchProductData = [];
            // }
        }
        if (this.searchedProductData.length === 0) {
            showToast(this, "Error", "Please select products to add.", "error");
        }
    }
}