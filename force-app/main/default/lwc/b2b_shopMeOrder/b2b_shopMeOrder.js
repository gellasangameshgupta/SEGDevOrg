import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
/** Apex */
import createShopMeOrders from '@salesforce/apex/B2B_ShopMeOrderController.createShopMeOrders';

import CLB2B00058 from "@salesforce/label/c.CLB2B00058"; // Order Confirmation Text
import CLB2B00059 from "@salesforce/label/c.CLB2B00059"; // Order Status Text

export default class b2b_shopMeOrder extends NavigationMixin(LightningElement) {
    @track ObjOrderSummary ={};
    blnIsButtonVisible = true;
    currentPageReference = null;
    blnRegularOrder = false;
    blnPickMeOrder = false;
    objRegularOrder = {};
    objPickMeOrder = {};
    objShopMeOrder = {};
    objRegularOrderId ;
    objPickMeOrderId ; 
    recordId;
    orderNumber;  
    baseUrl;
    pageReference;

    // Expose the labels to use in the template.
    label = {
        CLB2B00058,
        CLB2B00059
    };
    
    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        this.baseUrl = window.location.origin;
        this.recordId = this.currentPageReference['attributes']['recordId'];
        createShopMeOrders({
            idOrderSummaryId: this.recordId            
        }).then(result=>
            {
                this.ObjOrderSummary = result;
                for (let objShopMeOrder of result.ShopMe_Orders__r){
                    if(objShopMeOrder.OrderType__c == 'Regular'){
                        this.objRegularOrderId = objShopMeOrder.Id;
                        this.objRegularOrder = objShopMeOrder.Name;
                        this.blnRegularOrder = true;
                    }
                    else{
                        this.objPickMeOrderId = objShopMeOrder.Id;
                        this.objPickMeOrder = objShopMeOrder.Name;
                        this.blnPickMeOrder = true;
                    }
                }
                
            }
        ).catch(error=>{
            console.log('Error:'+error);
        })
    }

    navigationToHomePage(){
    // Navigate to the About page
        this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: 'Home'
        }
        });
    }

    toggleViewMyOrder(){
    // Navigate to the Order Summary Page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                name: 'Order_Summary_Detail',
                recordId: this.recordId,
                actionName: 'view'
            }
            });
    }

    toggleViewRegularOrder(){
    // Navigate to the ShopMe Regular Order Page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                name: 'ShopMe_Order_Detail__c',
                recordId: this.objRegularOrderId,         
                actionName: 'view'
            }
        });
    }

    toggleViewPickMeOrder(){
    // Navigate to the ShopMe PickMe Order Page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                name: 'ShopMe_Order_Detail__c',
                recordId: this.objPickMeOrderId,         
                actionName: 'view'
            }
        });
    }

}