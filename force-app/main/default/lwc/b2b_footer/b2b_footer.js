import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
//Get the custom metadata values which are used for icons
import getMetadata from "@salesforce/apex/B2B_FooterController.fetchMetadata";
//import static resources for logo
import SEG_LOGO from "@salesforce/resourceUrl/B2B_SEGlogo";

export default class B2b_footer extends NavigationMixin(LightningElement) {
    @api strSupportPhoneNumber;
    @api strSupportEmail;
    @api blnShowPhoneNumber;
    @api blnShowEmail;
    @api blnShowSocialLinks;

    strSegLogoUrl = SEG_LOGO;
    list_SocialMedias;
    list_Documents;
    blnError; //true when an exception occurs
    strErrorMessage; //holds the exception message

    get blnSocialMedia() {
        if (this.blnShowSocialLinks) {
            this.fetchMetadata();
        }

        return this.blnShowSocialLinks;
    }

    fetchMetadata() {
        getMetadata()
            .then((result) => {
                this.list_SocialMedias = result.list_SocialMediaComponents;
                this.list_Documents = result.list_DocumentComponents;
                this.handleException(false, "");
            })
            .catch((error) => {
                this.handleException(true, error);
            });
    }

    //redirects to the respective link when user clicks on the social icon
    redirectToSocialLink(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: event.currentTarget.dataset.id
            }
        });
    }

    handleException(blnError, strErrorMessage) {
        if (blnError) {
            this.blnError = true;
            if (strErrorMessage) {
                this.strErrorMessage = JSON.stringify(strErrorMessage);
            }
        } else {
            this.blnError = false;
            this.strErrorMessage = undefined;
        }
    }

    get strMailToEmail() {
        return "mailto:" + this.strSupportEmail;
    }

    handleButton() {
        window.UC_UI.showSecondLayer()
    }
}