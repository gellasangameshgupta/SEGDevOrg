import { LightningElement, api } from "lwc";
/** Apex server call to confirm the Recaptcha */
import verifyRecaptcha from "@salesforce/apex/B2B_Recaptcha.confirmRecaptcha";

export default class B2b_googleRecaptcha extends LightningElement {

    // blnIsVerified - when the user is verified this variable will be set to true
    blnIsRendered = false;
    blnIsSuccess = false;

    @api get blnIsVerified() {
        return this.blnIsSuccess;
    }
    set blnIsVerified(value) {
        this.blnIsSuccess = value;
    }

    connectedCallback() {
        this.doInit();
    }

    doInit() {
        document.addEventListener("grecaptchaVerified", function(element) {
            verifyRecaptcha({ 
                objRecord: null, // TODO: map UI fields to sobject
                strRecaptchaResponse: element.detail.response
            })
                .then(result => {
                    if (result) {
                        console.log(result);
                        this.blnIsSuccess = true;
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }.bind(this), false);
    }

    renderedCallback() {
        if (!this.blnIsRendered) {
            var divElement = this.template.querySelector("div.recaptchaCheckbox");
            // valide values for badge: bottomright bottomleft inline
            var payload = { element: divElement, badge: "bottomright" };
            document.dispatchEvent(new CustomEvent("grecaptchaRender", { "detail": payload }));

            this.blnIsRendered = true;
        }
    }
}