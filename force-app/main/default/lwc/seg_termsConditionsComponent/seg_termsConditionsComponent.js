import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/** Apex */
import permisson from '@salesforce/apex/SEG_B2BBuyerController.permisson';
import isPermissonAlreadyAssigned from '@salesforce/apex/SEG_B2BBuyerController.isPermissonAlreadyAssigned';

import CLB2B00060 from '@salesforce/label/c.CLB2B00060'; // Accept Text
import CLB2B00061 from '@salesforce/label/c.CLB2B00061'; // Reject Text
import CLB2B00062 from '@salesforce/label/c.CLB2B00062'; // I Accept Text
import CLB2B00063 from '@salesforce/label/c.CLB2B00063'; // Terms and Conditions Text
import CLB2B00064 from '@salesforce/label/c.CLB2B00064'; // Terms and Conditions Accepted Text
import CLB2B00065 from '@salesforce/label/c.CLB2B00065'; // Please Accept Terms and Conditions Text
import CLB2B00067 from '@salesforce/label/c.CLB2B00067'; // Used to display required field Text

export default class Seg_termsConditionsComponent extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track blnIsModalOpen = false;
    @track blnIsdisableAccept = true;

    // Expose the labels to use in the template.
    label = {
        CLB2B00060,
        CLB2B00061,
        CLB2B00063,
        CLB2B00062,
        CLB2B00064,
        CLB2B00065,
        CLB2B00067
    };

    connectedCallback(){
        isPermissonAlreadyAssigned({  
        }).then(result => 
            {
                if (result) {
                    this.openModal();
                }
            }
            ).catch(error => 
                {
                console.log(JSON.stringify(error));
            })
    }
       
    openModal() {
        // to open modal set blnIsModalOpen tarck value as true
        this.blnIsModalOpen = true;
    }

    closeModal() {
        // to close modal set blnIsModalOpen tarck value as false
        this.blnIsModalOpen = false;
        this.blnIsdisableAccept = true;
    }

    submitDetails() {
        // to close modal set blnIsModalOpen tarck value as false
        this.blnIsModalOpen = false;
    }
 
    handleCheckbox(event) {
        this.blnIsdisableAccept = !event.target.checked;
    }

    handleReject() {
        this.blnIsModalOpen = false;
        this.blnIsdisableAccept = true;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: CLB2B00065,
            variant: 'error'
        }));
    }

    handleAccept() {
        this.blnIsModalOpen = false;
        this.blnIsdisableAccept = true;
        permisson({
        }).then(result => 
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: CLB2B00064,
                    variant: 'success'
                }));
            }
        ).catch(error => 
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            }
        ).finally(() => 
        {
            location.reload(true);
        });
    }
}