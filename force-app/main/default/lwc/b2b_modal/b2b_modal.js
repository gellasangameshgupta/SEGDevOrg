import { LightningElement, api } from "lwc";

export default class B2b_modal extends LightningElement {
    @api strPositiveButtonLabel;
    @api strNegativeButtonLabel;
    @api strOptionalButtonLabel; // to display optinal button in the footer
    @api strCheckboxLabel; // to display checkbox in the footer
    @api strHeaderText;
    @api blnShowModal;
    @api blnShowFooter = false;
    @api blnShowLoading = false;
    @api blnShowCloseIcon = false;
    @api blnDisablePositiveButton = false; // to enable and disable positive button based on conditions
    @api blnDisableOptionalButton = false; // to enable and disable optinal button based on conditions
    @api strSelectedRecordId;

    //passing control to parent on click of positive button
    handlePositive() {
        this.dispatchEvent(new CustomEvent("positive"));
    }

    //passing control to parent on click of negative button
    handleNegative() {
        this.dispatchEvent(new CustomEvent("negative"));
    }

    //passing control to parent on click of checkbox
    handleCheckbox(event) {
        this.dispatchEvent(new CustomEvent("checkbox", { detail: event.target.checked }));
    }

    //passing control to parent on click of optional button
    handleOptionalButton() {
        this.dispatchEvent(new CustomEvent("optional"));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent("close"));
    }
}