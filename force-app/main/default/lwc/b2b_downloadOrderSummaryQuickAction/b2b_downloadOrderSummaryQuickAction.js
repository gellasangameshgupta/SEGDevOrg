import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDownloadActionDetails from '@salesforce/apex/B2B_OrderSummaryActionController.getDownloadActionDetails';

export default class B2b_downloadOrderSummaryQuickAction extends LightningElement {
    @api recordId;

    // @wire(getDownloadActionDetails, {idOrderSummary : '$recordId'})
    // wiredOrderDetails (result) {
    //     let {error, data} = result;
        
    //     if (data) {
    //         if (data.blnIsSuccess) {
    //             console.log(data);
    //         } else {
    //             console.log(JSON.stringify(data.strErrorMessage));
    //         }
    //     } else if (error) {
    //         console.error(JSON.stringify(error));
    //     }
    // }

    @api invoke() {
        getDownloadActionDetails({ idOrderSummary : this.recordId })
        .then(result => {
            if (result.blnIsSuccess) {
                console.log(data);
            } else {
                console.log(JSON.stringify(result.strErrorMessage));
            }
        })
        .catch(error => {
            console.error(JSON.stringify(error));
        })
    }
}