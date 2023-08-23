import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/** Wire Adapter */
import { getRecord } from "lightning/uiRecordApi";
/** Apex */
import getStepInformation from "@salesforce/apex/B2B_ContactSetupAssistantController.getStepInformation";
import enableBuyerAccount from "@salesforce/apex/B2B_ContactSetupAssistantController.enableBuyerAccount";
import addBuyerGroup from "@salesforce/apex/B2B_ContactSetupAssistantController.addBuyerGroup";
import getBuyerGroup from "@salesforce/apex/B2B_ContactSetupAssistantController.getBuyerGroup";
import getContactPointAddresses from "@salesforce/apex/B2B_ContactSetupAssistantController.getContactPointAddresses";
import fetchRecords from "@salesforce/apex/B2B_CustomLookupController.fetchRecords";
import resetPassword from "@salesforce/apex/B2B_ResetPasswordController.resetPassword";
/** Object & Field Schema */
import ACCOUNT_ID from "@salesforce/schema/Contact.AccountId";
import strSFDCContactPointAddressObjectApiName from "@salesforce/schema/ContactPointAddress";
/** Custom Labels */
import CLB2B00029 from "@salesforce/label/c.CLB2B00029"; // Add Account
import CLB2B00030 from "@salesforce/label/c.CLB2B00030"; // Add account reference on contact
import CLB2B00031 from "@salesforce/label/c.CLB2B00031"; // Enable Buyer Account
import CLB2B00032 from "@salesforce/label/c.CLB2B00032"; // Enable account as buyer account
import CLB2B00033 from "@salesforce/label/c.CLB2B00033"; // Enable
import CLB2B00034 from "@salesforce/label/c.CLB2B00034"; // Add Buyer Group
import CLB2B00035 from "@salesforce/label/c.CLB2B00035"; // Add Buyer Group to Buyer Account
import CLB2B00036 from "@salesforce/label/c.CLB2B00036"; // Add Buyer Group - Button Label
import CLB2B00037 from "@salesforce/label/c.CLB2B00037"; // Enable Customer User
import CLB2B00038 from "@salesforce/label/c.CLB2B00038"; // Enable user as customer user for B2B portal access
import CLB2B00039 from "@salesforce/label/c.CLB2B00039"; // Add Contact Point Addresses
import CLB2B00040 from "@salesforce/label/c.CLB2B00040"; // Add Shipping and Billing contact point addresses on Account
import CLB2B00041 from "@salesforce/label/c.CLB2B00041"; // Add Billing Address
import CLB2B00042 from "@salesforce/label/c.CLB2B00042"; // Add Shipping Address
import CLB2B00043 from "@salesforce/label/c.CLB2B00043"; // Set Sharing Rule
import CLB2B00044 from "@salesforce/label/c.CLB2B00044"; // Set Sharing
import CLB2B00045 from "@salesforce/label/c.CLB2B00045"; // Reset Password
import CLB2B00046 from "@salesforce/label/c.CLB2B00046"; // Reset

const columns = [
    { label: "Buyer Group Name", fieldName: "strGroupName" },
    { label: "Buyer Name", fieldName: "strBuyerName" }
];

const columnsForContactPointAddress = [
    { label: "Street", fieldName: "Street" },
    { label: "City", fieldName: "City" },
    { label: "State", fieldName: "State" },
    { label: "Country", fieldName: "Country" },
    { label: "PostalCode", fieldName: "PostalCode" }
];

export default class B2b_contactSetupAssistant extends LightningElement {
    // record id from record detail page
    @api recordId;

    //Properties to Show Hide Steps from Contact Asssitant
    @api blnShowAccountAvialability = false;
    @api blnShowEnableBuyerAccount = false;
    @api blnShowAddBuyerGroup = false;
    @api blnShowEnableCustomer = false;
    @api blnShowAddContactPointAddresses = false;
    @api blnShowSetSharingRule = false;
    @api blnShowResetPassword = false;

    //Setup Assistant Flags and Initial Data
    blnAccountAvailable = false; // Account availability step's status
    blnBuyerAccountEnabled = false; // Whether buyer account is enabled
    blnBuyerGroupAvailable = false; // Buyer group's availability status
    blnCustomerUserEnabled = false; // Whether customer user is enabled
    blnContactPointAddressesAvailable = false; // Whether contact point addresses are available or not
    blnAccountSharingRuleEnabled = false; // Whether buyer account is enabled
    blnBuyerPermissionEnabled = false; // Whether buyer account is enabled

    //Contact's Shiiping Address
    @track objContactOtherAddressStreet;
    @track objContactOtherAddressPostalCode;
    @track objContactOtherAddressCity;
    @track objContactOtherAddressState;
    @track objContactOtherAddressCountry;
    @track objContactOtherAddressBuildingNo;

    //Contact's Billing Address
    @track objContactMailingAddressStreet;
    @track objContactMailingAddressCity;
    @track objContactMailingAddressPostalCode;
    @track objContactMailingAddressState;
    @track objContactMailingAddressCountry;
    @track objContactMailingAddressBuildingNo;

    //Default Values to be configured in address based on corresponding button click
    @track objContactAddressStreet;
    @track objContactAddressCity;
    @track objContactAddressPostalCode;
    @track objContactAddressState;
    @track objContactAddressCountry;
    @track strAddressType;
    @track strContactPointAddressName;
    @track objContactAddressBuildingNo;

    // Buyer Group additon and Custom lookup's supporting sttributes
    strAccountId;
    strAccountName;
    strBuyerGroupId;
    objectName = "BuyerGroup";
    fieldName = "Name";
    required = false;
    searchString;
    selectedRecord;
    recordsList;
    message;
    showPill = false;
    blnShowSpinner = false;
    showDropdown = false;
    list_buyerAccountRecords;
    list_columns = columns;

    list_AddressRecords;
    list_AddressColumns = columnsForContactPointAddress;

    strSFDCContactPointAddressObjectApiName = strSFDCContactPointAddressObjectApiName;

    // Show / Hide Respective Modal's Flag
    blnModalContainerBuyerGroup = false;
    blnModalContainerContactPoint = false;
    blnShowExistingContactPointAddresses = false;

    //Property for using refreshApex
    fetchDataResults;

    // Expose the labels to use in the template.
    label = {
        CLB2B00029,
        CLB2B00030,
        CLB2B00031,
        CLB2B00032,
        CLB2B00033,
        CLB2B00034,
        CLB2B00035,
        CLB2B00036,
        CLB2B00037,
        CLB2B00038,
        CLB2B00039,
        CLB2B00040,
        CLB2B00041,
        CLB2B00042,
        CLB2B00043,
        CLB2B00044,
        CLB2B00045,
        CLB2B00046
    };

    @wire(getRecord, { recordId: "$recordId", fields: [ACCOUNT_ID] })
    getAccountAvailability({ error, data }) {
        if (error) {
            this.handleException(error);
        } else if (data) {
            if (data.fields.AccountId.value) {
                this.strAccountId = data.fields.AccountId.value;
                this.blnAccountAvailable = true;
                this.doInit();
            } else {
                this.reset();
            }
        }
    }

    get handleBuyerAccountEnabled() {
        return this.blnBuyerAccountEnabled;
    }

    get handleBuyerGroupEnabled() {
        return !this.blnBuyerAccountEnabled;
    }

    get handleSharingAccountAndPermissionRuleEnabled() {
        if (this.blnAccountSharingRuleEnabled && this.blnBuyerPermissionEnabled) {
            return true;
        }

        return false;
    }

    /* To fetch all the step details */
    doInit() {
        this.blnShowSpinner = true;
        getStepInformation({
            strRecordId: this.recordId,
            strAccountId: this.strAccountId
        })
            .then((data) => {
                this.blnAccountAvailable = data.blnAccountAvailable;
                this.blnBuyerAccountEnabled = data.blnBuyerAccountEnabled;
                this.blnBuyerGroupAvailable = data.blnBuyerGroupAvailable;
                this.blnCustomerUserEnabled = data.blnCustomerUserEnabled;
                this.blnAccountSharingRuleEnabled = data.blnAccountSharingRuleEnabled;
                this.blnBuyerPermissionEnabled = data.blnBuyerPermissionEnabled;
                this.blnContactPointAddressesAvailable = data.blnContactPointAddressesAvailable;
                this.strAccountId = data.strAccountId;
                this.strAccountName = data.strAccountName;
                if (data.objContactOtherAddress) {
                    this.objContactOtherAddressStreet = data.objContactOtherAddress.street;
                    this.objContactOtherAddressPostalCode = data.objContactOtherAddress.postalCode;
                    this.objContactOtherAddressState = data.objContactOtherAddress.state;
                    this.objContactOtherAddressCountry = data.objContactOtherAddress.country;
                    this.objContactOtherAddressCity = data.objContactOtherAddress.city;
                    this.objContactOtherAddressBuildingNo = data.objContactOtherAddressBuildingNo;
                }
                if (data.objContactMailingAddress) {
                    this.objContactMailingAddressStreet = data.objContactMailingAddress.street;
                    this.objContactMailingAddressPostalCode =
                        data.objContactMailingAddress.postalCode;
                    this.objContactMailingAddressState = data.objContactMailingAddress.state;
                    this.objContactMailingAddressCountry = data.objContactMailingAddress.country;
                    this.objContactMailingAddressCity = data.objContactMailingAddress.city;
                    this.objContactMailingAddressBuildingNo =
                        data.objContactMailingAddressBuildingNo;
                }
            })
            .catch((error) => {
                this.handleException(error);
            })
            .finally(() => {
                this.blnShowSpinner = false;
            });
    }

    reset() {
        this.blnAccountAvailable = false;
        this.blnBuyerAccountEnabled = false;
        this.blnBuyerGroupAvailable = false;
        this.blnCustomerUserEnabled = false;
        this.blnContactPointAddressesAvailable = false;
        this.blnAccountSharingRuleEnabled = false;
        this.blnBuyerPermissionEnabled = false;
        this.strAccountId = "";
        this.strAccountName = "";
        this.objContactOtherAddressStreet = "";
        this.objContactOtherAddressPostalCode = "";
        this.objContactOtherAddressState = "";
        this.objContactOtherAddressCountry = "";
        this.objContactOtherAddressCity = "";
        this.objContactOtherAddressBuildingNo = "";
        this.objContactMailingAddressStreet = "";
        this.objContactMailingAddressPostalCode = "";
        this.objContactMailingAddressState = "";
        this.objContactMailingAddressCountry = "";
        this.objContactMailingAddressCity = "";
        this.objContactMailingAddressBuildingNo = "";
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

    handleResetButtonClick() {
        resetPassword({
            strContactId: this.recordId
        })
            .then((data) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Password reset mail sent!",
                        variant: "success"
                    })
                );
            })
            .catch((error) => {
                this.handleException(error);
            });
    }

    handleSetSharingButtonClick() {
        this.template.querySelector("c-b2b_set-sharing-rules").setAccountSharing();
        this.blnAccountSharingRuleEnabled = true;
        this.blnBuyerPermissionEnabled = true;
    }

    //For B2B_Modal Generic Component Logic
    handleSuccess(event) {
        this.closeAllModal();
        this.blnContactPointAddressesAvailable = true;
        const toastEvent = new ShowToastEvent({
            title: "Address Created",
            message: "Contact Point Adddress Created Successfully!!!",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

    handleBuyerGroupNegativeAction() {
        this.blnModalContainerBuyerGroup = this.blnModalContainerBuyerGroup ? false : true;
    }

    handleContactPointNegativeAction() {
        this.blnModalContainerContactPoint = false;
        this.blnShowExistingContactPointAddresses = false;
    }

    //Added for Buyer Group Modal Pop up
    handleBuyerGroupButtonClick() {
        this.blnModalContainerBuyerGroup = true;
        this.getAccountBuyerGroup();
    }

    //Added for Modal Pop up
    handleContactPointShippingButtonClick() {
        this.objContactAddressStreet = this.objContactOtherAddressStreet;
        this.objContactAddressCity = this.objContactOtherAddressCity;
        this.objContactAddressPostalCode = this.objContactOtherAddressPostalCode;
        this.objContactAddressState = this.objContactOtherAddressState;
        this.objContactAddressCountry = this.objContactOtherAddressCountry;
        this.objContactAddressBuildingNo = this.objContactOtherAddressBuildingNo;
        this.strAddressType = "Shipping";
        this.strContactPointAddressName = this.strAccountName
            ? this.strAccountName + "_" + this.strAddressType
            : "";
        this.blnModalContainerContactPoint = true;
        this.getContactAddressRecords();
    }

    //Added for Modal Pop up
    handleContactPointBillingButtonClick() {
        this.objContactAddressStreet = this.objContactMailingAddressStreet;
        this.objContactAddressCity = this.objContactMailingAddressCity;
        this.objContactAddressPostalCode = this.objContactMailingAddressPostalCode;
        this.objContactAddressState = this.objContactMailingAddressState;
        this.objContactAddressCountry = this.objContactMailingAddressCountry;
        this.objContactAddressBuildingNo = this.objContactMailingAddressBuildingNo;
        this.strAddressType = "Billing";
        this.strContactPointAddressName = this.strAccountName
            ? this.strAccountName + "_" + this.strAddressType
            : "";
        this.blnModalContainerContactPoint = true;
        this.getContactAddressRecords();
    }

    get disableBuyerAccountButton() {
        return this.blnBuyerAccountEnabled || !this.blnAccountAvailable;
    }

    enableBuyerAccount() {
        if (!this.blnAccountAvailable) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please add account to contact first !",
                    variant: "error"
                })
            );
        } else {
            enableBuyerAccount({
                strAccountId: this.strAccountId,
                strAccountName: this.strAccountName
            })
                .then(() => {
                    this.blnBuyerAccountEnabled = true;

                    const toastEvent = new ShowToastEvent({
                        title: "Buyer Account Created",
                        message: "Buyer Account Created Successfully!!!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                })
                .catch((error) => {
                    this.handleException(error);
                });
        }
    }

    closeAllModal() {
        this.blnModalContainerBuyerGroup = false;
        this.blnModalContainerContactPoint = false;
        this.blnShowExistingContactPointAddresses = false;
    }

    hanldeSelection(event) {
        this.strBuyerGroupId = event.detail;
    }

    //Add Buyer Group and Custom Lookup
    searchRecords(event) {
        this.searchString = event.target.value;
        if (this.searchString) {
            this.fetchData();
        } else {
            this.showDropdown = false;
        }
    }

    handleSelectedItem(event) {
        if (event.currentTarget.dataset.key) {
            let index = this.recordsList.findIndex(
                (x) => x.strValue === event.currentTarget.dataset.key
            );

            if (index != -1) {
                this.selectedRecord = this.recordsList[index];
                this.showDropdown = false;
                this.showPill = true;
            }
        }
    }

    removeItem() {
        this.showPill = false;
        this.selectedRecord = "";
        this.searchString = "";
    }

    showRecords() {
        if (this.recordsList && this.searchString) {
            this.showDropdown = true;
        }
    }

    blurEvent() {
        this.showDropdown = false;
    }

    fetchData() {
        this.blnShowSpinner = true;
        this.message = "";
        this.recordsList = [];

        if (this.searchString) {
            this.showDropdown = true;
        }

        fetchRecords({
            strObjectName: this.objectName,
            strFilterField: this.fieldName,
            strSearchString: this.searchString,
            strValue: ""
        })
            .then((result) => {
                if (result && result.length) {
                    this.recordsList = result;
                } else {
                    this.message = "No Records Found for '" + this.searchString + "'";
                }

                this.blnShowSpinner = false;
            })
            .catch((error) => {
                this.message = error.message;
                this.blnShowSpinner = false;
            });
    }

    handleAddBuyerGroup() {
        addBuyerGroup({
            strAccountId: this.strAccountId,
            strBuyerGroupId: this.selectedRecord.strValue
        })
            .then((result) => {
                if (result && result.length) {
                    this.list_buyerAccountRecords = result;
                    this.blnBuyerGroupAvailable = true;

                    const toastEvent = new ShowToastEvent({
                        title: "Buyer Group Added",
                        message: "Buyer Group Added Successfully!",
                        variant: "success"
                    });
                    this.dispatchEvent(toastEvent);
                }
            })
            .catch((error) => {
                this.handleException(error);
            });
    }

    //get buyer group records
    getAccountBuyerGroup() {
        getBuyerGroup({
            strAccountId: this.strAccountId
        })
            .then((result) => {
                this.list_buyerAccountRecords = result;
            })
            .catch((error) => {
                this.handleException(error);
            });
    }

    //get contact point address records
    getContactAddressRecords() {
        getContactPointAddresses({
            strAccountId: this.strAccountId,
            strAddressType: this.strAddressType
        })
            .then((result) => {
                this.list_AddressRecords = result;
                if (result && result.length) {
                    this.blnShowExistingContactPointAddresses = true;
                }
            })
            .catch((error) => {
                this.handleException(error);
            });
    }
}