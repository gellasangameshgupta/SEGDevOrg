import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CLAQT00002 from "@salesforce/label/c.CLAQT00002"; // Error message for duplicate part number
import CLAQT00003 from "@salesforce/label/c.CLAQT00003"; // Error handle message
import CLAQT00006 from "@salesforce/label/c.CLAQT00006"; // Select row to remove
import CLAQT00007 from "@salesforce/label/c.CLAQT00007"; // Quote is submitted for approval

// Toast message
export function showToast(component, title, message, variant) {
    const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    component.dispatchEvent(toastEvent);
}

export function duplicateRecordExist(list_selectedRecord) {
    let blnIsDuplicateRecord = false;
    const tempListSelectedRecord = JSON.parse(JSON.stringify(list_selectedRecord));
    if (tempListSelectedRecord) {
        var size = Object.keys(tempListSelectedRecord).length;
        const map = new Map(tempListSelectedRecord.map((obj) => [obj.PartNumber, obj]));
        const deduplicatedArr = [...map.values()];
        if (size > deduplicatedArr.length) {
            blnIsDuplicateRecord = true;
        }
    }
    return blnIsDuplicateRecord;
}
// Fetch custom labels
const label = {
    CLAQT00002: CLAQT00002,
    CLAQT00003: CLAQT00003,
    CLAQT00006: CLAQT00006,
    CLAQT00007: CLAQT00007
};
export { label };