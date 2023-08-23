import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getNavigationMenuItems from "@salesforce/apex/B2B_NavigationMenuItemsController.getNavigationMenuItems";
import isGuestUser from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";

/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationMenuItemsController apex class.
 */
export default class NavigationMenu extends NavigationMixin(LightningElement) {
    @api buttonRedirectPageAPIName;
    @api menuName;
    @api strHeaderTitle;
    @api blnShowHeader;

    error;
    href = basePath;
    blnIsLoaded;
    list_menuItems = [];
    strpublishedState;

    @wire(getNavigationMenuItems, {
        menuName: "$menuName",
        strpublishedState: "$strpublishedState"
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.blnIsLoaded) {
            this.list_menuItems = data
                .map((item, index) => {
                    return {
                        target: item.Target,
                        id: index,
                        label: item.Label,
                        defaultListViewId: item.DefaultListViewId,
                        type: item.Type,
                        accessRestriction: item.AccessRestriction
                    };
                })
                .filter((item) => {
                    // Only show "Public" items if guest user
                    return (
                        item.accessRestriction === "None" ||
                        (item.accessRestriction === "LoginRequired" && !isGuestUser)
                    );
                });
            this.error = undefined;
            this.blnIsLoaded = true;
        } else if (error) {
            this.error = error;
            this.list_menuItems = [];
            this.blnIsLoaded = true;
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === "commeditor") {
            this.strpublishedState = "Draft";
        } else {
            this.strpublishedState = "Live";
        }
    }

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: this.buttonRedirectPageAPIName
            }
        });
    }
}