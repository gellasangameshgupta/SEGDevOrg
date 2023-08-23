import { LightningElement, wire, track,api } from 'lwc';
/** Apex */
import getCartItems from '@salesforce/apex/B2B_ShopMeCartItemsController.getCartItems';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//CLB2B00076 - "Please go back to update the cart Items" (Text Message to update cart Items)
import CLB2B00076 from "@salesforce/label/c.CLB2B00076"; 
//CLB2B00077 - "Please Contact your Salesforce Administrator" (This is used to store the Error message)
import CLB2B00077 from "@salesforce/label/c.CLB2B00077"; 



//This is list of columns for the datatable
const COLUMNS = [
    { label: 'Product Name', fieldName: 'ProductName' },
    { label: 'Product Type', fieldName: 'ProductType' },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
    { label: 'Price per Unit', fieldName: 'SalesPrice', type: 'currency' },
    { label: 'Tax Amount', fieldName: 'TotalPriceTaxAmount', type: 'currency' },
    { label: 'Total Amount', fieldName: 'TotalAmount', type: 'currency' },
    { label: 'Plant', fieldName: 'PlantName', type: 'Formula' },
    
];

export default class B2b_cartItemDetails extends LightningElement {  
    @api recordId;
    @track list_CartItems;
    @wire(CurrentPageReference)
    currentPageReference;

    label = {
        CLB2B00076,
        CLB2B00077
    };

    columns = COLUMNS;
   
    connectedCallback() {
        this.baseUrl = window.location.origin;
        this.recordId = this.currentPageReference['attributes']['recordId'];
        
        /**
        *@ author      : Prathiksha Suvarna
        *@ description : This method is used to retrive all the CartItem records. 
        *@ params      : 'recordId' - RecordId of Cart object.  
        **/

        getCartItems({recordId:this.recordId})
        .then(result=>{
            if (result.blnIsSuccess) {
                let list_AllCartItemsTemp = JSON.parse(JSON.stringify(result.list_AllCartItems));
                for (let i = 0; i < list_AllCartItemsTemp.length; i++) {
                    var idelectronicMediaId = result.map_ElectronicMediaIdByCartItemId[list_AllCartItemsTemp[i].Id];
                    list_AllCartItemsTemp[i]["ProductName"] = list_AllCartItemsTemp[i].Product2.Name;
                    list_AllCartItemsTemp[i]["ProductType"] = list_AllCartItemsTemp[i].Product2.B2B_ProductType__c;
                    list_AllCartItemsTemp[i]["imageUrl"] = result.map_ImageURLByManageContentId[idelectronicMediaId];
                    list_AllCartItemsTemp[i]["PlantName"] = list_AllCartItemsTemp[i].Product2.B2B_PlantName__c;
                }
                this.list_CartItems = list_AllCartItemsTemp;
            } else {
                this.showToastMessage('Error', this.label.CLB2B00077, 'error');  
            }
        })
        .catch(error=>{
            this.showToastMessage('Error', this.label.CLB2B00077, 'error');
        });
        
    }

    /**
    *@ author      : Prathiksha Suvarna
    *@ description : This method is used to display the ShowToast event based on the values of
    *@ params      : 'strTitle','strMessage' and 'strVariant'
    **/
    showToastMessage (strTitle, strMessage, strVariant) {
        const event = new ShowToastEvent({
                        title: strTitle,
                        variant: strVariant,
                        message: strMessage,
                      });
        this.dispatchEvent(event);
    }
}