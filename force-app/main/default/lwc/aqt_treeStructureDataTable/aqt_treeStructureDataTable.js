import { LightningElement, api, track } from "lwc";

export default class Aqt_treeStructureDataTable extends LightningElement {
    @api key;
    @api recordId;
    @api fieldsInformation;
    @api isParentChecked;
    @api columnClass;
    @api columnWrapClass;
    @api gridChildHeader;
    @api gridLevelChild2Header;
    @api gridHeader;
    @api gridChildData;
    @api index;
    @track rowDetail;
    @track childRecord;
    @track iconName = "utility:chevronright";
    showChildData = false;
    showChildLevel1Data = false;
    blnNoRecordAvailable = false;

    connectedCallback() {
        this.rowDetail = JSON.parse(JSON.stringify(this.fieldsInformation.get(this.recordId)));
    }

    handleRecordExpand(event) {
        let recordId = event.target.name;
        if (event.target.iconName === "utility:chevronright") {
            event.target.iconName = "utility:chevrondown";
            this.showChildData = true;
            this.childRecord = JSON.parse(JSON.stringify(this.fieldsInformation.get(recordId)));
        } else {
            event.target.iconName = "utility:chevronright";
            this.childRecord = [];
            this.gridChildData = [];
            this.showChildLevel1Data = false;
            this.blnNoRecordAvailable = false;
            this.showChildData = false;
            this.isLoading = false;
        }
    }

    handleChildRecordExpand(event) {
        if (event.target.iconName === "utility:chevronright") {
            event.target.iconName = "utility:chevrondown";
            if (this.rowDetail.previousOfferedPrice != undefined) {
                this.showChildLevel1Data = true;
                this.gridChildData = JSON.parse(
                    JSON.stringify(this.rowDetail.previousOfferedPrice)
                );
            } else {
                this.blnNoRecordAvailable = true;
            }
        } else {
            event.target.iconName = "utility:chevronright";
            this.gridChildData = [];
            this.showChildLevel1Data = false;
            this.blnNoRecordAvailable = false;
            this.isLoading = false;
        }
    }

    @api
    handleSelectionChangeParent(isChecked) {}

    handleApprovalRequired(event) {
        const selectedEvent = new CustomEvent("approvalrequired", {
            detail: {
                rowDetail: JSON.parse(JSON.stringify(event.detail.approvalRecordDetail))
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleDiscountChange(event) {
        let editedField = event.detail.selectedField;
        this.rowDetail[editedField] = event.detail.selectedValue;
        this.rowDetail.EndPrice =
            this.rowDetail.StandardListPrice -
            this.rowDetail.StandardListPrice * (this.rowDetail.Discount / 100);
        /* this.rowDetail.EndPrice = Math.round(
      this.rowDetail.StandardListPrice -
        this.rowDetail.StandardListPrice * (this.rowDetail.Discount / 100)
    );*/

        this.rowDetail.NetAmount = this.rowDetail.EndPrice * this.rowDetail.QuantityFinal;
        let decimalEBIT;
        if (this.rowDetail.EndPrice !== 0) {
            decimalEBIT =
                ((this.rowDetail.EndPrice - this.rowDetail.PPCPrice * (1 + this.rowDetail.SG_A)) /
                    this.rowDetail.EndPrice) *
                100;
        } else {
            decimalEBIT = 0;
        }
        this.rowDetail.EBIT = (Math.round(decimalEBIT * 100) / 100).toFixed(2);

        const selectedEvent = new CustomEvent("updatelistprice", {
            detail: {
                rowDetail: this.rowDetail,
                editedField: editedField,
                key: event.detail.key
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleSelectionChange(event) {
        const gridrecordselected = new CustomEvent("gridrecordselected", {
            detail: {
                index: event.target.dataset.index,
                checked: event.target.checked
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(gridrecordselected);
    }

    @api
    handleExpandAllRecord(iconName) {
        if (iconName === "utility:chevronright") {
            this.showChildData = true;
            this.childRecord = JSON.parse(
                JSON.stringify(this.fieldsInformation.get(this.recordId))
            );
            this.iconName = "utility:chevrondown";
            if (this.childRecord.previousOfferedPrice != undefined) {
                this.showChildLevel1Data = true;
                this.gridChildData = JSON.parse(
                    JSON.stringify(this.childRecord.previousOfferedPrice)
                );
            } else {
                this.blnNoRecordAvailable = true;
            }
        } else {
            this.childRecord = [];
            this.showChildData = false;
            this.showChildLevel1Data = false;
            this.gridChildData = [];
            this.blnNoRecordAvailable = false;
            this.iconName = "utility:chevronright";
        }
    }

    @api
    handleQuantityAllChange(gridMetaData) {
        this.rowDetail = gridMetaData;
        this.rowDetail.EndPrice =
            this.rowDetail.StandardListPrice -
            this.rowDetail.StandardListPrice * (this.rowDetail.Discount / 100);
        this.rowDetail.NetAmount = this.rowDetail.EndPrice * this.rowDetail.QuantityFinal;
    }
}