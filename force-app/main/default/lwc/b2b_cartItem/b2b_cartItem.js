import { LightningElement,api } from 'lwc';

//CLB2B00068 - "Product Type" (This label is used to display Product Type in cartItem list)
import CLB2B00068 from "@salesforce/label/c.CLB2B00068"; 
//CLB2B00069 - "Price per unit" (This label is used to display Price per unit in cartItem list)
import CLB2B00069 from "@salesforce/label/c.CLB2B00069"; 
//CLB2B00070 - "Quantity" (This label is used to display Quantity in cartItem list)
import CLB2B00070 from "@salesforce/label/c.CLB2B00070"; 
//CLB2B00071 - "Total Amount" (This label is used to display Total Amount in cartItem list)
import CLB2B00071 from "@salesforce/label/c.CLB2B00071"; 
//CLB2B00071 - "Plant" (This label is used to display Plant in cartItem list)
import CLB2B00078 from "@salesforce/label/c.CLB2B00078"; 

export default class B2b_cartItem extends LightningElement {
    @api cartInformation;
    // Expose the labels to use in the template.
    label = {
        CLB2B00068,
        CLB2B00069,
        CLB2B00070,
        CLB2B00071,
        CLB2B00078
    };
}