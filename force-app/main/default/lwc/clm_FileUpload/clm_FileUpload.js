import { LightningElement, api } from 'lwc';
import {updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Clm_FileUpload extends LightningElement {
    @api fieldName;
    @api title;
    @api status;
    @api recordId;
    
    handleFileUpload(){
        const fields = {};
        fields[this.fieldName] = true;
        fields['Id'] = this.recordId;
        if(this.status){
         //   fields['IT_Agreement_Status__c'] = this.status;
        }
        if(this.fieldName == 'DPA_Uploaded__c'){
            fields['DPA_ApprovalStatus__c'] = 'Approval Required';
        }
        const record = {fields};

        updateRecord(record)
        .then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'File uploaded',
                    variant: 'success'
                })
            );
        })
        .catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
        
    }

}