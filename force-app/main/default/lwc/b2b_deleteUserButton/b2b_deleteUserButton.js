import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CLB2B00023 from "@salesforce/label/c.CLB2B00023"; //Delete User Confirmation Text
import USER_ID from "@salesforce/user/Id"; // This gets the logged in user
import updateContact from "@salesforce/apex/B2B_DeleteUserButtonController.updateDeleteStatusAtContact";
import getContactStatus from "@salesforce/apex/B2B_DeleteUserButtonController.getContactStatusByUserId";

export default class B2b_deleteUserButton extends LightningElement {
    // Variables
    strStatusMessage;
    strErrorMessage; //holds the exception message
    blnError; //true when an exception occurs
    blnIsModalOpen = false;
    blnIsRendered = false;
    blnShowButton = false;
    blnShowLoading = true;

    // Expose the labels to use in the template.
    label = {
        CLB2B00023
    };

    @wire(getContactStatus, { strUserId: USER_ID })
    getContactStatus({ error, data }) {
        this.blnShowLoading = false;
        if (data) {
            if (data == "Delete User") {
                this.strStatusMessage = "Delete user request raised!";
            } else {
                this.blnShowButton = true;
            }

            this.handleException(false, "");
        } else if (error) {
            this.handleException(true, error);
        }
    }

    handlePositiveAction() {
        const blnAllValid = [...this.template.querySelectorAll("lightning-textarea")].reduce(
            (validSoFar, inputCmp) => {
                if (inputCmp.value) {
                    inputCmp.value = inputCmp.value.trim();
                }

                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );

        if (blnAllValid) {
            this.blnShowLoading = true;
            let strInputReason = this.template.querySelector("lightning-textarea").value;

            updateContact({
                strUserId: USER_ID,
                strReason: strInputReason
            })
                .then((data) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "User Deleted!",
                            variant: "success"
                        })
                    );

                    this.blnShowButton = false;
                    this.strStatusMessage = "Delete user request raised!";
                    this.handleException(false, "");
                })
                .catch((error) => {
                    this.handleException(true, error);
                })
                .finally(() => {
                    this.blnShowLoading = false;
                    this.handleButtonClick();
                });
        }
    }

    handleNegativeAction() {
        this.handleButtonClick();
    }

    handleButtonClick() {
        this.blnIsModalOpen = this.blnIsModalOpen ? false : true;
    }

    handleException(blnError, error) {
        if (blnError) {
            this.blnError = true;
            if (error && error.body && Array.isArray(error.body)) {
                this.strErrorMessage = error.body.map((e) => e.message).join(", ");
            } else if (error && error.body && typeof error.body.message === "string") {
                this.strErrorMessage = error.body.message;
            } else {
                this.strErrorMessage = "Unknown error";
            }
        } else {
            this.blnError = false;
            this.strErrorMessage = undefined;
        }
    }

    renderedCallback() {
        if (this.blnIsRendered) return;

        if (this.blnShowButton) {
            this.blnIsRendered = true;
            const style = document.createElement("style");
            style.innerText = `
                .b2b-button button {
                    border-radius: 20px !important;
                }
            `;
            this.template.querySelector("lightning-button").appendChild(style);
        }
    }
}