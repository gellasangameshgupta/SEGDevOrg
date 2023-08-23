import { LightningElement, api, track } from "lwc";
import getTableData from "@salesforce/apex/B2B_GenericDataTableByFieldSetController.getTableData";

export default class B2b_genericDataTableByFieldSet extends LightningElement {
    @api strRecordId; // record id from record detail page
    @api strSFDCobjectApiName; //='B2B_ProductApplication__c'; //kind of related list object API Name e.g. 'Product2'
    @api strSFDCParentobjectApiName; //='B2B_ProductApplication__c'; //kind of related list object API Name e.g. 'Product2'
    @api strFieldSetName; //='B2B_ProductDetailPageRelatedList'; // FieldSet which is defined on that above object e.g. 'ProductApplicationRelatedListFS'
    @api strCriteriaFieldAPIName; //='Product__c'; // This field will be used in WHERE condition e.g.'Product'
    @api strParentCriteriaFieldAPIName; //='SEGIAMNumber__c'; // This field will be used in WHERE condition e.g.'Product'
    @api blnFirstColumnAsRecordHyperLink; //='false'; //if the first column can be displayed as hyperlink
    @api blnShowHeader; //='false'; //if the header should not be displayed
    @api blnShowView; //='false';
    @api strMaxTableRow;

    list_Columns; //columns for List of fields datatable
    @track list_TableData = []; //data for list of fields datatable
    @track list_RemainingData = [];
    strRecordCount = 0; //this displays record count inside the ()
    strLabelObjectName; //this displays the Object Name whose records are getting displayed
    blnModalContainer = false; //Added for modal popup
    strSelectedRowId; //Added to pass parmeter to record view form

    blnShowResults = false;
    blnShowSpinner = false;
    blnError; //true when an exception occurs
    strErrorMessage; //holds the exception message

    connectedCallback() {
        this.fetchData();
    }

    fetchData() {
        this.blnShowSpinner = true;
        let blnFirstTimeEntry = false;
        let strFirstFieldAPI;

        getTableData({
            strRecordId: this.strRecordId,
            strObjectApiName: this.strSFDCobjectApiName,
            strFieldSetName: this.strFieldSetName,
            strCriteriaField: this.strCriteriaFieldAPIName,
            strParentObjectAPIName: this.strSFDCParentobjectApiName,
            strParentCriteriaField: this.strParentCriteriaFieldAPIName,
            strLimitRow: this.strMaxTableRow
        })
            .then((data) => {
                if (data && data.strFieldList && data.strRecordList && data.strSobjectLabel) {
                    /* retrieve listOfFields from the map,
                    here order is reverse of the way it has been inserted in the map */
                    let list_Fields = JSON.parse(data.strFieldList);

                    //retrieve listOfRecords from the map
                    let list_Records = JSON.parse(data.strRecordList);
                    this.strLabelObjectName = JSON.parse(data.strSobjectLabel);

                    let items = [];

                    if (this.blnShowView) {
                        items = [
                            ...items,
                            {
                                label: "View",
                                type: "button-icon",
                                fixedWidth: 50,
                                typeAttributes: {
                                    iconName: "action:preview",
                                    title: "Preview",
                                    variant: "border-filled",
                                    alternativeText: "View"
                                }
                            }
                        ];
                    }

                    /*if user wants to display first column has hyperlink and clicking on the link it will
                        naviagte to record detail page. Below code prepare the first column with type = url
                    */
                    list_Fields.map((element) => {
                        //it will enter this if-block just once
                        if (this.blnFirstColumnAsRecordHyperLink && blnFirstTimeEntry == false) {
                            strFirstFieldAPI = element.fieldPath;
                            //perpare first column as hyperlink
                            items = [
                                ...items,
                                {
                                    label: element.label,
                                    fieldName: "strURLField",
                                    fixedWidth: 150,
                                    wrapText: true,
                                    type: "url",
                                    typeAttributes: {
                                        label: {
                                            fieldName: element.fieldPath
                                        },
                                        target: "_blank"
                                    },
                                    sortable: true,
                                    wrapText: true
                                }
                            ];

                            blnFirstTimeEntry = true;
                        } else {
                            items = [
                                ...items,
                                {
                                    label: element.label,
                                    fieldName: element.fieldPath,
                                    wrapText: true
                                }
                            ];
                        }
                    });

                    /*if user wants to display first column has hyperlink and clicking on the link it will
                        naviagte to record detail page. Below code prepare the field value of first column
                    */
                    if (this.blnFirstColumnAsRecordHyperLink) {
                        let strURLField;
                        //retrieve Id, create URL with Id and push it into the array
                        let list_TableData = list_Records.map((item) => {
                            strURLField =
                                "/lightning/r/" +
                                this.strSFDCobjectApiName +
                                "/" +
                                item.Id +
                                "/view";
                            return { ...item, strURLField };
                        });

                        //now create final array excluding firstFieldAPI
                        list_Records = list_TableData.filter(
                            (item) => item.fieldPath != strFirstFieldAPI
                        );
                    }

                    //finally assigns item array to columns
                    this.list_Columns = items;
                    //assign values to display Object Name and Record Count on the screen
                    if (list_Records && list_Records) {
                        this.strRecordCount = list_Records.length;
                        this.sliceGridData(list_Records);
                    }

                    this.blnShowResults = true;
                    this.handleException(false, "");
                } else {
                    this.handleException(true, "No results returned");
                }
            })
            .catch((error) => {
                this.list_TableData = undefined;
                this.handleException(true, error);
            })
            .finally(() => {
                this.blnShowSpinner = false;
            });
    }

    //Added for Modal Pop up
    handleRowAction(event) {
        const dataRow = event.detail.row;
        this.strSelectedRowId = dataRow.Id;
        this.blnModalContainer = true;
    }

    //For Showing Header
    get headerVisible() {
        return this.blnShowHeader;
    }

    //For B2B_Modal Generic Component Logic
    handlePositiveAction() {}

    handleNegativeAction() {
        this.handleButtonClick();
    }

    handleButtonClick() {
        this.blnModalContainer = this.blnModalContainer ? false : true;
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

    handleScroll() {
        let parameter = ".b2b-table-container";
        let myDiv = this.template.querySelector(parameter);
        if (this.list_RemainingData && this.list_RemainingData.length) {
            if (
                parseInt(myDiv.scrollTop) + parseInt(myDiv.offsetHeight) + 1 >
                parseInt(myDiv.scrollHeight)
            ) {
                this.sliceGridData(this.list_RemainingData);
            }
        }
    }

    sliceGridData(records) {
        if (records.length > 50) {
            this.list_TableData = this.list_TableData.concat(records.slice(0, 49));
            this.list_RemainingData = records.slice(49);
        } else {
            this.list_TableData = this.list_TableData.concat(records);
            this.list_RemainingData = [];
        }
    }
}