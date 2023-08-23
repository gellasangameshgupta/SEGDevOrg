import { LightningElement } from "lwc";
// To Navigate pages, import NavigationMixin
import { NavigationMixin } from "lightning/navigation";
// importing Custom Label
// CLB2B00011 = Your request for registration has been sent.
// Please note that your request needs to be validated, you will receive an email acknowledgement shortly.
import CLB2B00011 from "@salesforce/label/c.CLB2B00011";
import CLB2B00012 from "@salesforce/label/c.CLB2B00012"; // CLB2B00012 = FINISH

export default class B2b_finishRegistration extends NavigationMixin(LightningElement) {
    label = {
        CLB2B00011,
        CLB2B00012
    };

    // Navigate to B2B Portal Login Page
    redirectToLogin() {
        this[NavigationMixin.Navigate]({
            type: "comm__loginPage",
            attributes: {
                actionName: "login"
            }
        });
    }
}