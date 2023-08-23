import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDownloadActionDetails from '@salesforce/apex/B2B_OrderSummaryActionController.getDownloadActionDetails';
import workbook from "@salesforce/resourceUrl/writeExcelFile";
import { loadScript } from "lightning/platformResourceLoader";

//CLB2B00079 - "Download Sheet (in XLSX)" - (It stores the download button label in Order Summary Quick Action Component)
import CLB2B00079 from "@salesforce/label/c.CLB2B00079";

export default class B2b_downloadOrderSummary extends LightningElement {
    // @api recordId;
    @api orderSummaryId;
    list_orderExcelConfigs;
    list_orderSummaries;
    map_CountryConfigRecords;
    strFileName = 'Order Summary';
    list_dataObjects;
    isLibraryLoaded = false;

    //Custom Labels
    downloadButtonLabel = CLB2B00079;
    
    /* Calling an Apex Method - 'getDownloadActionDetails' to fetch all the necessory records to generate Excel Sheet */  
    @wire(getDownloadActionDetails, {idOrderSummary : '$orderSummaryId'})
    wiredOrderDetails (result) {
        let {error, data} = result;
        
        if (data) {
            if (data.blnIsSuccess) {
                console.log(JSON.parse(JSON.stringify(data)));
                this.list_orderExcelConfigs = JSON.parse(JSON.stringify(data.list_orderExcelConfigs));
                this.list_orderSummaries = JSON.parse(JSON.stringify(data.list_orderSummaries));
                this.map_CountryConfigRecords = JSON.parse(JSON.stringify(data.map_CountryConfigs));
                if (data.list_orderSummaries[0].OrderNumber) 
                    this.strFileName += ' - ' + data.list_orderSummaries[0].OrderNumber;
                
                this.list_dataObjects = this.getListRows();
                console.log(this.list_dataObjects);
            } else {
                this.showToastMessage('Error!', data.strErrorMessage, 'error');
            }
        } else if (error) {
            this.showToastMessage('Error!', error.body.message ? error.body.message : error , 'error');
        }
    }

    /* This renderedCallback will load the external JS File in Static Resource - 'writeExcelFile'. */
    renderedCallback() {

        if (this.isLibraryLoaded) return;
        
        this.isLibraryLoaded = true;
        loadScript(this, workbook )
        .then(async (data) => {
            console.log("JS File Loaded Successfully");
        })
        .catch(error => {
            console.error("Failure on JS File Loading");
        });
    }

    /* This method will handle the Download Button. */
    handleDownload () {
        if (this.list_dataObjects)
            this.exportToXLSX();
        else this.showToastMessage('Error', 'No Data for Excel Sheet', 'error');
    }

    /* Calling the external JS File Function - 'writeXlsxFile' from Static Resource - 'writeExcelFile' */
    async exportToXLSX() { 
        await writeXlsxFile(this.list_dataObjects, {
            fileName: this.strFileName + '.xlsx'
        });
    }

    /* This method will return all the data rows and column header row for excel sheet. */ 
    getListRows () {
        /* Getting seperate records for each of Child Order Product Summary Records. */
        let list_rowsOfData = [];
        this.list_orderSummaries.forEach(objOrderRecord => {
            if (objOrderRecord.hasOwnProperty('OrderItemSummaries')) {
                [...objOrderRecord.OrderItemSummaries].forEach(objItemSummary => {
                    let objRow = {};
                    Object.keys(objOrderRecord).forEach(strFieldName => {
                        if (strFieldName != 'OrderItemSummaries')
                            objRow[strFieldName] = objOrderRecord[strFieldName];
                    });
                    Object.keys(objItemSummary).forEach(strFieldName => {
                        objRow[strFieldName] = objItemSummary[strFieldName];
                    });
                    list_rowsOfData.push(objRow);
                });
            } else {
                let objRow = {};
                Object.keys(objOrderRecord).forEach(strFieldName => {
                    objRow[strFieldName] = objOrderRecord[strFieldName];
                });
                list_rowsOfData.push(objRow);
            }
        });

        /* Creating a list of list rows including all the order summaries records along with column header row at top. */
        let list_listOfRows = new Array(list_rowsOfData.length);
        for (let index = 0; index < list_listOfRows.length; index++) {
            list_listOfRows[index] = new Array(this.list_orderExcelConfigs.length);
        }

        for (let index = 0 ; index < list_rowsOfData.length ; index++) {
            let objRowDataOrder = list_rowsOfData[index];
            for (let innerIndex = 0 ; innerIndex < this.list_orderExcelConfigs.length ; innerIndex++) {
                let objExcelConfig = this.list_orderExcelConfigs[innerIndex];
                let obj = {value : objExcelConfig.DefaultValue__c 
                                   ? this.callFormatter(objExcelConfig.DefaultValue__c, objExcelConfig, objRowDataOrder)
                                   : "" };


                if (!objExcelConfig.hasOwnProperty('FieldName__c')) {
                    list_listOfRows[index][innerIndex] = obj;
                } else if (objExcelConfig.hasOwnProperty('MetaDataField__c') &&
                           objExcelConfig.hasOwnProperty('FieldName__c')
                ) {
                    if (objRowDataOrder.hasOwnProperty(objExcelConfig.FieldName__c)) {
                        let strFieldValue = String(objRowDataOrder[objExcelConfig.FieldName__c]).toLowerCase().trim();
                        if (this.map_CountryConfigRecords[strFieldValue] && this.map_CountryConfigRecords[strFieldValue][objExcelConfig.MetaDataField__c]) {
                            let changedValue = this.map_CountryConfigRecords[strFieldValue][objExcelConfig.MetaDataField__c];
                            obj = {value : this.callFormatter(changedValue, objExcelConfig, objRowDataOrder)}
                        } else {
                            obj = {value : this.callFormatter(objRowDataOrder[objExcelConfig.FieldName__c], objExcelConfig, objRowDataOrder)}
                        }
                        list_listOfRows[index][innerIndex] = obj;
                    } else {
                        list_listOfRows[index][innerIndex] = obj;
                    }
                } else if (objExcelConfig.hasOwnProperty('FieldName__c')) {
                    if (objRowDataOrder.hasOwnProperty(objExcelConfig.FieldName__c)) {
                        let strFieldValue = objRowDataOrder[objExcelConfig.FieldName__c];
                        obj = {value : this.callFormatter(strFieldValue, objExcelConfig, objRowDataOrder)};
                        list_listOfRows[index][innerIndex] = obj;
                    } else {
                        list_listOfRows[index][innerIndex] = obj;
                    }
                }
            }
        }


        let list_headerRow = [...this.list_orderExcelConfigs].map(objCurrentExcelConfig => {
            let objColumnAttributes = {};
            objColumnAttributes['value'] = objCurrentExcelConfig.Name;
            objColumnAttributes['fontWeight'] = 'bold'
            objColumnAttributes['backgroundColor'] = '#004f79'
            objColumnAttributes['color'] = '#ffffff';
            objColumnAttributes['align'] = 'center';
            return objColumnAttributes;
        });

        list_listOfRows.unshift(list_headerRow);
        return list_listOfRows;
    }

    /* This method will call the 'formattedData' method with appropriate parameters and return the actual cell value */
    callFormatter (data, objExcelConfigRecord, objRowOrderData){
        let cellValue;
        if (String(objExcelConfigRecord.ColumnType__c).toLowerCase() === 'currency') {
            cellValue = this.formattedData({currency : data, currencyCode : objRowOrderData.CurrencyIsoCode},
                                            objExcelConfigRecord);
        } else {
            cellValue = this.formattedData(data, objExcelConfigRecord);
        }
        return cellValue;
    }

    /* This method will change the data format for date and currency column type */
    formattedData (data, objExcelConfig) {
        let formattedData = "";

        if (!objExcelConfig.hasOwnProperty('ColumnType__c')) return data;

        switch(String(objExcelConfig.ColumnType__c).toLowerCase()) {
            case 'date':
                if (!isNaN(Date.parse(data))) {
                    let dateValue = new Date(data);
                    formattedData = String(dateValue.getDate()).padStart(2, '0') 
                                    + '.' 
                                    + String(dateValue.getMonth() + 1).padStart(2, '0')
                                    + '.' 
                                    + String(dateValue.getFullYear());
                } else {
                    console.error('Error : '+ objExcelConfig.Name +' has been provided invalid Date.');
                    formattedData = 'InvalidDate';
                }
                break;
            case 'currency':
                if (!isNaN(Number.parseFloat(data.currency).toFixed(2))) {
                    formattedData = objExcelConfig.ShowCurrencyCode__c ? data.currencyCode + ' ' : '';
                    formattedData += Intl.NumberFormat('en-IN').format(Number.parseFloat(data.currency).toFixed(2));
                } else {
                    console.error('Error : '+ objExcelConfig.Name +' has been provided invalid Currency.');
                    formattedData = 'InvalidCurrency';
                }
                break;
            default:
                formattedData = data;
                break;
        }
        return formattedData;
    }

    /* This method is used to display the ShowToast event based on the values of
       'strTitle', 'strMessage' and 'strVariant' */
    showToastMessage (strTitle, strMessage, strVariant) {
        const event = new ShowToastEvent({
                        title: strTitle,
                        variant: strVariant,
                        message: strMessage,
                      });
        this.dispatchEvent(event);
    }
}