import { LightningElement, wire, track, api } from 'lwc';
import getStatus from '@salesforce/apex/B2B_OrderSummaryForAfterMarketUser.getStatus';
import updateStatus from '@salesforce/apex/B2B_OrderSummaryForAfterMarketUser.updateStatus';
import { CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class B2b_orderSummaryForAfterMarketUser extends LightningElement {
    @track baseUrl;
    @track recordId;
    @track list_Options = [];
    @track strSelectedOption = '';
    
    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        this.baseUrl = window.location.origin;
        this.recordId = this.currentPageReference['attributes']['recordId'];
        getStatus({
         
        }).then(result=>
            {
                this.list_Options = result;
            }
            
        ).catch(error=>{
            console.log('Error'+JSON.stringify(error));
        })
    }

    handlechange(event) {   
        this.strSelectedOption = event.target.value;
    }

    handlesave() {
        updateStatus({
            strSelectedStatus:this.strSelectedOption,
            strRecordId:this.recordId
        }).then(result=>
            {
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
            }
            
        ).catch(error=>{
            console.log('Error:'+JSON.stringify(error));
        })
    }
}