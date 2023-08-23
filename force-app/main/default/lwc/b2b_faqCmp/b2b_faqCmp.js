import { LightningElement, track } from "lwc";
import getFAQList from "@salesforce/apex/B2B_FAQsController.getAllFAQRecords";

//import custom labels
import CLB2B00017 from "@salesforce/label/c.CLB2B00017"; //CLB2B00017 = Frequently asked questions
import CLB2B00018 from "@salesforce/label/c.CLB2B00018"; //CLB2B00018 = All Topics
import CLB2B00019 from "@salesforce/label/c.CLB2B00019"; //CLB2B00019 = Enter Keyword

export default class B2b_faqCmp extends LightningElement {
    /* Map to store the complete list of FAQs */
    map_AllFAQData;
    /* Map to store the list of FAQs that need to be displayed */
    @track map_DisplayedFAQData;
    /* String to specify which item in vertical navigation list is currently selected */
    @track strInitiallySelected;
    /* List to store the Topics to be displayed in the vertical navigation */
    list_NavigationData;
    /* List of all FAQs */
    list_AllFAQs;
    /* Displayed FAQs */
    @track list_DisplayedFAQs;
    /* Search Text */
    @track strSearchText;
    /* Sort direction of the data table */
    strSortDirection = "ASC";
    /* Flag to Show/ Hide spinner */
    @track blnShowSpinner;
    blnError; //true when an exception occurs
    strErrorMessage; //holds the exception message

    //Expose the labels to use in the template.
    label = {
        CLB2B00017,
        CLB2B00018,
        CLB2B00019
    };

    connectedCallback() {
        this.doInit();
    }

    /* To fetch all the articles during initial launch */
    doInit() {
        this.blnShowSpinner = true;
        getFAQList({})
            .then((data) => {
                this.handleException(false, "");

                let map_DataTemp = [];
                let list_Items = [];
                let list_TempArray = [];
                list_Items.push({ label: this.label.CLB2B00018, value: "All Topics" });
                for (let key in data) {
                    if (data.hasOwnProperty(key)) {
                        for (let val in data[key]) {
                            list_TempArray.push(data[key][val]);
                        }
                        list_Items.push({ label: key, value: key });
                        map_DataTemp.push({ key: key, value: data[key] });
                    }
                }
                this.map_AllFAQData = map_DataTemp;
                this.list_AllFAQs = list_TempArray;
                this.list_DisplayedFAQs = list_TempArray;
                this.strInitiallySelected = "All Topics";
                this.list_NavigationData = list_Items;
            })
            .catch((error) => {
                this.handleException(true, error);
            })
            .finally(() => {
                this.blnShowSpinner = false;
            });
    }

    /* To handle when we click Show/ Hide button for an article */
    handleClick(event) {
        try {
            this.blnShowSpinner = true;
            let list_TempArray = this.list_DisplayedFAQs;
            let strAttribute = event.currentTarget.getAttribute("data-name");
            // When the Show button is clicked

            if (strAttribute !== undefined && strAttribute === "") {
                for (let key in list_TempArray) {
                    if (
                        list_TempArray[key].strSubject ===
                        event.currentTarget.getAttribute("data-value")
                    ) {
                        list_TempArray[key].strDisplayedDescription =
                            list_TempArray[key].strDescription;
                        break;
                    }
                }
                this.list_DisplayedFAQs = list_TempArray;
                this.blnShowSpinner = false;
            } else {
                // When the hide button is clicked
                for (let key in list_TempArray) {
                    if (
                        list_TempArray[key].strSubject ===
                        event.currentTarget.getAttribute("data-value")
                    ) {
                        list_TempArray[key].strDisplayedDescription = "";
                        break;
                    }
                }
                this.list_DisplayedFAQs = list_TempArray;
                this.blnShowSpinner = false;
            }
        } catch (error) {
            this.handleException(true, error);
        }
    }

    /* To handle whenever a topic is selected from the dropdown */
    handleTopicChange(event) {
        try {
            const strselectedTopic = event.detail.value;
            this.strInitiallySelected = strselectedTopic;
            let map_DataTemp2 = this.map_AllFAQData;
            if (strselectedTopic === "All Topics") {
                this.resetAllData();
            } else {
                let list_TempArray = this.list_AllFAQs;
                for (let key in list_TempArray) {
                    list_TempArray[key].strDisplayedDescription = "";
                }
                this.list_DisplayedFAQs = list_TempArray;
                let resultArray = map_DataTemp2.find((element) => element.key === strselectedTopic);
                if (resultArray != undefined) {
                    this.list_DisplayedFAQs = resultArray.value;
                }
            }
        } catch (error) {
            this.handleException(true, error);
        }
    }

    /* To handle when user enters any search key in the search bar */
    handleOnchange(event) {
        try {
            let strEnteredText = event.target.value;
            this.strSearchText = strEnteredText;
            let tempArray = [];
            let list_TempAllFAQ = this.list_AllFAQs;
            list_TempAllFAQ.forEach(function (item) {
                if (item.strSubject.toLowerCase().includes(strEnteredText.toLowerCase())) {
                    tempArray.push(item);
                }
            });
            this.list_DisplayedFAQs = tempArray;
        } catch (error) {
            this.handleException(true, error);
        }
    }

    /* To handle we Reset button is clicked */
    handleReset(event) {
        this.blnShowSpinner = true;
        this.strSearchText = "";
        this.resetAllData();
        this.blnShowSpinner = false;
    }

    /* To reset all the data */
    resetAllData() {
        this.strInitiallySelected = "All Topics";
        let list_TempArray = this.list_AllFAQs;
        for (let key in list_TempArray) {
            list_TempArray[key].strDisplayedDescription = "";
        }
        this.list_DisplayedFAQs = list_TempArray;
    }

    /* Perform actions after rendering */
    renderedCallback() {
        if (this.template.querySelector(".rounded-border")) {
            const style = document.createElement("style");
            style.innerText = `
                .slds-button_icon-border-filled, .slds-button--icon-border-filled {
                    border-bottom-left-radius: 50%;
                    border-top-left-radius: 50%;
                    border-bottom-right-radius: 50%;
                    border-top-right-radius: 50%;
                }
                `;
            this.template.querySelector(".rounded-border").appendChild(style);
        }
    }

    /* Peform sorting in the data table */
    handleSort(event) {
        this.blnShowSpinner = true;
        if (this.strSortDirection === "ASC") {
            //Descending sorting
            this.strSortDirection = "DESC";
            this.list_DisplayedFAQs.sort(function (firstItem, secondItem) {
                if (firstItem.strCategory < secondItem.strCategory) {
                    return 1;
                }
                if (firstItem.strCategory > secondItem.strCategory) {
                    return -1;
                }
                // text must be equal
                return 0;
            });
        } else {
            this.strSortDirection = "ASC"; //Ascending sorting
            this.list_DisplayedFAQs.sort(function (firstItem, secondItem) {
                if (firstItem.strCategory < secondItem.strCategory) {
                    return -1;
                }
                if (firstItem.strCategory > secondItem.strCategory) {
                    return 1;
                }
                // text must be equal
                return 0;
            });
        }
        this.blnShowSpinner = false;
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
}