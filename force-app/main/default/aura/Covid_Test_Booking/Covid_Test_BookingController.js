({
    doInit : function(component, event, helper) {
        var action = component.get('c.showBookingDetailsButton');            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if(response.getReturnValue()===true)
                {
                    component.set('v.slotColumns', [
                        {label: 'TIME SLOTS', fieldName: 'slot', type: 'text', cellAttributes: { alignment: 'center' }},
                        {label: 'AVAILABLE SLOTS', fieldName: 'availableSlot', type: 'text', cellAttributes: { alignment: 'center' }},
                        {type: "button", cellAttributes: { alignment: 'center' },  typeAttributes: {
                            label: 'Add Me',
                            name: 'AddBooking',
                            title: ' ',
                            disabled: {fieldName: 'AddMeDisabled'},
                            value: 'Add',
                            iconPosition: 'left'
                        }},
                        {type: "button", cellAttributes: { alignment: 'center' }, typeAttributes: {
                            label: 'Remove Me',
                            name: 'RemoveBooking',
                            title: ' ',
                            disabled: {fieldName: 'RemoveMeDisabled'},
                            value: 'Remove',
                            iconPosition: 'left'
                        }},
                        {type: "button", cellAttributes: { alignment: 'center' }, typeAttributes: {
                            label: 'Booking Details',
                            name: 'BookingDetails',
                            title: ' ',
                            disabled: false,
                            value: 'Booking',
                            iconPosition: 'left'
                        }}
                        
                        
                    ]);
                }
                else
                {
                    component.set('v.slotColumns', [
                        {label: 'TIME SLOTS', fieldName: 'slot', type: 'text', cellAttributes: { alignment: 'center' }},
                        {label: 'AVAILABLE SLOTS', fieldName: 'availableSlot', type: 'text', cellAttributes: { alignment: 'center' }},
                        {type: "button",  typeAttributes: {
                            label: 'Add Me',
                            name: 'AddBooking',
                            title: ' ',
                            disabled: {fieldName: 'AddMeDisabled'},
                            value: 'Add',
                            iconPosition: 'left'
                        }},
                        {type: "button", typeAttributes: {
                            label: 'Remove Me',
                            name: 'RemoveBooking',
                            title: ' ',
                            disabled: {fieldName: 'RemoveMeDisabled'},
                            value: 'Remove',
                            iconPosition: 'left'
                        }}
                    ]);    
                }
            }            
        });
        $A.enqueueAction(action);
        
    },
    handleRowAction :function(component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('*****row:'+JSON.stringify(row));
        switch (action.name) {
            case 'AddBooking':
                helper.helperAddBooking(component, event, helper, row);
                break;
            case 'RemoveBooking':
                helper.helperRemoveBooking(component, event, helper, row);
                break;
            case 'BookingDetails':
                helper.helperBookingDetails(component, event, helper, row);
                break;
            case 'AddGuests':
                helper.helperAddGuestBookingModal(component, event, helper, row);
                break;
            case 'RemoveGuests':
                helper.helperRemoveGuestBooking(component, event, helper, row);
                break;
        }
    },  
    addBookingGuest: function(component, event, helper) {
        
        var slot=parseInt(component.get("v.guestBooking.CanteenBookingNoOfSlots__c"));
        var available=parseInt(component.get("v.guestBooking.availableSlot"));
        
        if(slot!=null && slot<=0)
            helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError5"),"error")
            else if(slot>available)
                helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError6"),"error")
                else if(slot<=available)
                    helper.helperAddGuestBooking(component, event, helper);
                    else 
                        helper.ToastMethod("Error!",$A.get("$Label.c.CanteenBookingError7"),"error")
    },
    closeModal: function(component, event, helper) {
        component.set("v.showBookings",false);
        component.set("v.showAddGuestBooking",false);
    },
    dateChange: function(component, event, helper) {
        helper.helperSearchDateChanged(component, event, helper,component.get("v.selectedDate"));
    }
})