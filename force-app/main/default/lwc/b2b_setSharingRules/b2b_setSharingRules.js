import { LightningElement, api } from "lwc";
import setAccountSharing from "@salesforce/apex/B2B_AccountSharingController.setAccountSharing";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class B2b_setSharingRules extends LightningElement {
    @api recordId;
    @api setAccountSharing() {
        setAccountSharing({
            strContactId: this.recordId
        })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Permission and Sharing Set Successfully!",
                        variant: "success"
                    })
                );
            })
            .catch((error) => {
                this.handleException(error);
            });
    }

    handleException(error) {
        let strMessage = "Unknown error";

        if (error && error.body && Array.isArray(error.body)) {
            strMessage = error.body.map((e) => e.message).join(", ");
        } else if (error && error.body && typeof error.body.message === "string") {
            strMessage = error.body.message;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message: strMessage,
                variant: "error"
            })
        );
    }
}